# Task List Views: Surfacing Related-Record Context

Built during Military Trailblazer Office Hours — 2026-06-12

## What It Does

Salesforce Tasks have a polymorphic `WhatId` field that can point to any object, but list views can only display the related record's name — not its account, case subject, or any other context. Formula fields can't traverse a polymorphic relationship, so there's no out-of-the-box way to add that context as a column.

This solution works around the limitation by:

1. Adding typed lookup fields to the Activity object for each relevant related-record type
2. Using a before-context record-triggered flow to detect the object type from the `WhatId` key prefix and populate the correct lookup
3. Adding a formula field that reads from those lookups to build a single display column with the related record and its parent account

The result is a Task list view column that shows something like `AR-0012 (Acme Corp)` or `00001234 (Acme Corp)` instead of a bare record name.

## The Problem

When viewing the Tasks tab in Salesforce, the "Related To" column shows only the name of the related record. If you want to see which account a case task belongs to, or pull any other fields from the related record, you're stuck — `WhatId` is a lookup(polymorphic) field that can't be referenced in formula fields or traversed in standard list view column definitions.

## Custom Activity Fields

Custom fields added to the **Activity** object appear on both Tasks and Events.

| Field | API Name | Type | Related Object |
|-------|----------|------|----------------|
| Account Review | `Account_Review__c` | Lookup | `Account_Review__c` |
| Case | `Case__c` | Lookup | Case |
| Title Field | `Title_Field__c` | Formula (Text) | — |

`Title_Field__c` is the display column. Its formula reads from the two lookup fields:

```
IF(
  NOT(ISBLANK(Account_Review__c)),
  Account_Review__r.Name & " (" & Account_Review__r.Account__r.Name & ")",
  IF(NOT(ISBLANK(Case__c)), Case__r.CaseNumber & " (" & Case__r.Account.Name & ")", "Other")
)
```

## Flow Logic

**Flow:** `Set lookup fields on task insert / update` — AutoLaunched, triggers **before** Task create or update.

Running in the before context means assignment elements update the record directly — no separate Update Records element needed.

1. **Formula resource** (`RelatedRecordType`) — extracts the object type from the first three characters of `WhatId` using a `CASE` statement with hardcoded key prefixes:
   ```
   CASE(LEFT({!$Record.WhatId}, 3),
     "a0X", "Account Review",
     "500", "Case",
     ""
   )
   ```
2. **Decision** (`Object Type`) — routes on `RelatedRecordType`: Account Review path, Case path, or Other (no action).
3. **Account Review path** — assigns `Account_Review__c = WhatId`, clears `Case__c`.
4. **Case path** — assigns `Case__c = WhatId`, clears `Account_Review__c`.

Clearing the unused field handles the case where a task is re-linked from one object type to another.

## List View

**`OpenTasks`** — includes `Title_Field__c` as a column alongside Subject, Related To, Due Date, Status, and Priority. Filtered to open, non-recurring tasks due within the last 30 days.

## Files

| File | Purpose |
|------|---------|
| `force-app/main/default/flows/Set_lookup_fields_on_task_insert_update.flow-meta.xml` | Record-triggered flow (built on the call) |
| `force-app/main/default/flows/Set_lookup_fields_on_task_insert_update_Entity_Definition.flow-meta.xml` | Improved flow using EntityDefinition lookup (see below) |
| `force-app/main/default/objects/Activity/fields/Account_Review__c.field-meta.xml` | Lookup field → Account Review |
| `force-app/main/default/objects/Activity/fields/Case__c.field-meta.xml` | Lookup field → Case |
| `force-app/main/default/objects/Activity/fields/Title_Field__c.field-meta.xml` | Formula display field |
| `force-app/main/default/objects/Task/listViews/OpenTasks.listView-meta.xml` | Open Tasks list view |

---

## Bonus: EntityDefinition Approach

During the session, it was pointed out that hardcoded key prefixes are org-specific — a custom object's prefix can differ between sandboxes and production. The `EntityDefinition` object has a `KeyPrefix` field that lets you query the object type dynamically, making the flow environment-agnostic.

**Flow:** `Set lookup fields on task insert / update - Entity Definition` — same trigger, same structure, but replaces the hardcoded CASE formula with a Get Records step.

1. **Formula resource** (`RelatedRecordPrefix`) — extracts only the raw prefix: `LEFT({!$Record.WhatId}, 3)`
2. **Get Records** (`Get_entity_type`) — queries `EntityDefinition` where `KeyPrefix = RelatedRecordPrefix`, returns the first match. The `Label` field on the result is the object's display name (e.g., "Account Review", "Case").
3. **Decision** (`Object Type`) — routes on `Get_entity_type.Label` instead of the hardcoded string. Everything else is identical.

The EntityDefinition version is what's deployed (`Active`). The original CASE version is marked `Obsolete`.

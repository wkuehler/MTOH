# Getting a Picklist Label from its API Value in Flow

Built during Military Trailblazer Office Hours — 2026-07-10

**GitHub Repo:** https://github.com/wkuehler/MTOH/tree/main/2026/2026-07-10

## Watch the Session

[![Watch the session on YouTube](https://img.youtube.com/vi/rXYE5HrNyqM/maxresdefault.jpg)](https://youtu.be/rXYE5HrNyqM)

## The Use Case

A client wanted to default a record's Name field on creation — e.g., every time an
Opportunity is created, set its name to `Account Name - Stage`. Normally the label and API
name of a picklist value match, so it doesn't matter which one automation grabs. But this
client's picklist **labels** and **API names** were completely different: because an
integration pushed values back and forth with an external system, the API names were clunky,
prefixed strings never meant to be shown to users.

Their record-triggered flow concatenated the account name with the stage and got back the
ugly API name instead of the friendly label. So the question for the group was: **in a Flow,
how do you get the _label_ of a picklist value when you only have its API name?**

## Approaches Discussed

| Approach | Verdict |
|---|---|
| **CASE formula** — hardcode `if API name = X, use label Y` | Easy for a few values, but you must maintain the case statements in every flow that references the picklist, for every picklist. Not scalable. |
| **Custom metadata** — a lookup table you edit like a spreadsheet | Safer to maintain than code, but still a manual task whenever values change, multiplied across every picklist. |
| **Query the picklist metadata** (`PicklistValueInfo`) | The "hard" way — build it once as a reusable subflow and it works for any picklist on any object going forward. This is what we built. |

## The Solution: A Reusable Subflow

Rather than hardcode anything into the flow that needed it, we built an **auto-launched
subflow** that resolves a picklist label for any object/field/value combination. Build it
once, then call it anywhere you need to turn a picklist API value into its display label.

**Flow:** `Get_picklist_label_from_value` — AutoLaunched, **Active**

**Inputs:**
- `objectName` (Text) — the object API name, e.g. `Account`
- `fieldName` (Text) — the picklist field API name, e.g. `Rating`
- `picklistValueName` (Text) — the picklist value's API name, e.g. `50-Hot`

**Output:**
- `picklistLabelText` (Text) — the friendly label, e.g. `Hot`

It works through three chained Get Records queries — the first is intuitive, the next two are
not (and only need to be figured out once):

1. **`Get_entity_definition`** — `EntityDefinition` where `QualifiedApiName = objectName`.
   Returns the object's `DurableId`.
2. **`Get_field_definition`** — `FieldDefinition` where
   `EntityDefinitionId = Get_entity_definition.DurableId` **and**
   `QualifiedApiName = fieldName`. Returns the field's `DurableId`.
3. **`Get_picklist_value`** — `PicklistValueInfo` where
   `EntityParticleId = Get_field_definition.DurableId` **and** `Value = picklistValueName`.
   Returns the matching value record.
4. **Assignment** (`Set_the_label_for_return`) — sets
   `picklistLabelText = Get_picklist_value.Label`.

The non-obvious parts are the `DurableId` / `EntityDefinitionId` / `EntityParticleId`
linkages between these system objects — not the friendly names you'd expect.

> **The gotcha:** you can't just query `PicklistValueInfo` on its own. Try it and Salesforce
> throws *"A filter on a reified column is required"* — you have to reach it through the
> EntityDefinition → FieldDefinition → PicklistValueInfo chain above.

## The Demo Screen Flow

**Flow:** `Account_Details` — Screen Flow, Draft (built to demonstrate the subflow)

Takes an Account `recordId` and shows the same rating value three ways:

- **From the Fields tab** — a record field placed via the screen's Fields tab renders the
  friendly label automatically (`Hot`).
- **From the Components tab** — a Display Text component that references `{!recordId.Rating}`
  directly renders the raw API name (`50-Hot`).
- **Subflow output** — the screen calls `Get_picklist_label_from_value` (passing
  `objectName = Account`, `fieldName = Rating`, `picklistValueName = recordId.Rating`) and
  displays `picklistLabelText`, recovering the friendly label from the API value.

## Files

| File | Purpose |
|------|---------|
| `force-app/main/default/flows/Get_picklist_label_from_value.flow-meta.xml` | The reusable auto-launched subflow (Active) |
| `force-app/main/default/flows/Account_Details.flow-meta.xml` | Screen flow demonstrating the subflow (Draft) |

## Credit

Thanks to **The Org Wizard** — this solution was adapted from their Medium article, which
walks through the same EntityDefinition → FieldDefinition → PicklistValueInfo pattern:

- [How to Get Picklist Labels in Salesforce Flow](https://medium.com/the-org-wizard/how-to-get-picklist-labels-in-salesforce-flow-f0b79fed6266)

## Notes

- Because it's a subflow, you build it **once** and reference it from any flow that needs to
  turn a picklist API value into its label — record-triggered, screen, or scheduled.
- For production use you'd add error handling (object/field/value not found) around each Get
  Records step; the demo keeps it simple to focus on the metadata query pattern.

---

MTOH meets every Friday at 12 PM Eastern.

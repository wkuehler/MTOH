# Auto-Create Tasks on Record Creation

Built during Military Trailblazer Office Hours — 2026-06-05

## What It Does

When a new `Account_Review__c` record is created, a record-triggered Flow automatically generates a set of Tasks linked to that record — so follow-up steps kick off the moment the review is logged, with no manual task creation required.

## Custom Object

`Account_Review__c` (Account Review) is the trigger object for this demo.

| Field | Type | Purpose |
|-------|------|---------|
| `Name` | Auto Number (AR{000}) | Unique record identifier |
| `Account__c` | Lookup (Account) | The account being reviewed |
| `Date__c` | Date | Date of the review |
| `Notes__c` | Text Area | Review notes |

## Flow Logic

**Flow:** `Account_Review_Tasks` — AutoLaunched, triggers after `Account_Review__c` record creation.

1. **Build subject list** — Assigns all task subjects into a text collection variable (`TaskSubjects`). Adding subjects here is the only change needed to add or remove tasks.
2. **Loop** — Iterates through `TaskSubjects` in ascending order.
3. **Set task details** — For each subject, assigns `WhatId` (the new record's ID), `OwnerId` (the running user), `ActivityDate` (today), and `Subject` to the `CurrentTask` variable.
4. **Collect for insert** — Adds `CurrentTask` to the `TasksForInsert` collection.
5. **Bulk insert** — After the loop, inserts all tasks in a single DML operation.

## Files

| File | Purpose |
|------|---------|
| `force-app/main/default/flows/Account_Review_Tasks.flow-meta.xml` | Record-triggered flow |
| `force-app/main/default/flows/Account_Review_Tasks_Test.flow-meta.xml` | Flow test suite |
| `force-app/main/default/flowtests/Account_Review_Tasks_Task_Creation_Test.flowtest-meta.xml` | Flow test — task creation |
| `force-app/main/default/flowtests/Account_Review_Tasks_Test_Account_Review_Tasks_Confirm_Creation.flowtest-meta.xml` | Flow test — confirm creation |
| `force-app/main/default/objects/Account_Review__c/` | Custom object and fields |
| `force-app/main/default/flexipages/Account_Review_Record_Page.flexipage-meta.xml` | Lightning record page |

## Key Variables

| Variable | Type | Purpose |
|----------|------|---------|
| `TaskSubjects` | Text Collection | List of task subjects to create |
| `CurrentTask` | Task (SObject) | Holds task field values during each loop iteration |
| `TasksForInsert` | Task Collection | Accumulates tasks before the bulk insert |

# Military Trailblazer Office Hours — 2026-05-22

Topics covered in this session: Salesforce Passkeys, Lightning Types, and Apex-Defined Data Types in Flows.

**GitHub Repo:** https://github.com/wkuehler/MTOH/tree/main/2026/2026-05-22

---

## Topics

### Passkeys

Salesforce now supports passkeys as a passwordless login option. Passkeys replace passwords with cryptographic key pairs tied to your device, making accounts significantly more phishing-resistant.

- [NYT Wirecutter: What Are Passkeys?](https://www.nytimes.com/wirecutter/reviews/what-are-passkeys/)

---

### Lightning Types

Lightning Types let you define structured, typed data schemas that can be used natively in Flows and other platform features — without writing Apex.

**Demo:** `Person` type defined in `force-app/main/default/lightningTypes/Person/schema.json`

```json
{
  "title": "Person",
  "lightning:type": "lightning__objectType",
  "required": ["firstName", "lastName", "birthDate"],
  "properties": {
    "firstName": { "lightning:type": "lightning__textType" },
    "lastName":  { "lightning:type": "lightning__textType" },
    "birthDate": { "lightning:type": "lightning__dateType" }
  }
}
```

**Flows:**
- `Lightning_Types_Hardcoded` — hardcoded values assigned to a Lightning Type variable
- `Lightning_Types_Entry_Loop` — user entry collected in a loop, stored in a Lightning Type collection

**Reference:** [Custom Lightning Types (developer.salesforce.com)](https://developer.salesforce.com/docs/platform/lightning-types/overview)

---

### Apex-Defined Data Types in Flows

Apex classes with `@AuraEnabled` properties can be used as structured data types directly inside Flows, giving you access to complex types like Sets and Maps that aren't natively available in Flow.

**Demo class:** `force-app/main/default/classes/DataTypeTest.cls`

Key patterns demonstrated:
- Primitive `@AuraEnabled` properties (Integer, String, Decimal, List)
- **Set via write-only property** — Flow writes to `addToStringSet`; read back via `string_set_to_list` (since Flow can't work with Sets directly)
- **Map counter** — Flow sets `setMapKey` to look up a count, and writes to `addToCounterMap` to increment it

**Flows:**
- `Apex_Types_Tech_Demo` — foundational walkthrough of primitives, Set workaround, and Map counter
- `Apex_Types_Account_Contact_Demo` — applied demo using Account/Contact data with the same patterns

---

## Session Links

| Resource | Link |
|---|---|
| GitHub Repo | https://github.com/wkuehler/MTOH/tree/main/2026/2026-05-22 |
| Lightning Types Docs | https://developer.salesforce.com/docs/platform/lightning-types/overview |
| Passkeys Explainer | https://www.nytimes.com/wirecutter/reviews/what-are-passkeys/ |

---

MTOH meets every Friday at 12 PM Eastern.

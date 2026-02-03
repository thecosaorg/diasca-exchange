# Semantic Core (V2)

> The minimum shared structure that enables many use cases.

## Status

🚧 **In Development** – This document is a placeholder for the V2 minimal semantic core.

---

## Core Concepts

The semantic core has **6 concepts**:

| Concept | Description |
|---------|-------------|
| **Site** | A physical place (plot, farm, factory, warehouse) |
| **Actor** | A person or organization |
| **Relationship** | Actor connected to Site |
| **Transaction** | Movement of goods between actors/sites |
| **Claim** | Statement about a site, actor, or transaction |
| **Evidence** | Data supporting a claim |

---

## Conceptual Diagram

```
Actor ───── owns/manages ───── Site
Actor ───── transacts with ───── Actor
Transaction ───── involves ───── Site
Claim ───── refers to ───── Site / Actor / Transaction
Evidence ───── supports ───── Claim
```

---

## Why This Works

This structure is sufficient to support:

- **EUDR** – Plot polygon (Site), supplier identity (Actor), deforestation risk (Claim)
- **Compliance** – Audit findings (Claim), remediation evidence (Evidence)
- **Metrics** – Sustainability indicators (Claim), survey responses (Evidence)
- **Traceability** – Product movement (Transaction), origin (Site)
- **Certifications** – Certification status (Claim), audit reports (Evidence)

---

## Next Steps

- [ ] Define entity attributes
- [ ] Create DBML schema (`semantic_core.dbml`)
- [ ] Generate SQL DDL (`semantic_core.sql`)
- [ ] Create visual diagram
- [ ] Document exchange profile mappings

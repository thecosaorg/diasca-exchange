# Compliance & Remediation Exchange Profile

> **Specification for Audit Findings, Corrective Actions, and Remediation Tracking**

The Compliance Exchange Profile structures labor rights, child protection, environmental compliance, and safety remediation data using the DIASCA V2 Semantic Core.

---

## 📋 Overview

Compliance and certification programs (Fairtrade, Rainforest Alliance, internal corporate sustainability programs) require tracking field audit observations, non-compliance issues, corrective action plans (CAP), and verification of remediation.

---

## 🧩 Mapping to DIASCA V2 Core

| Compliance Concept | DIASCA Entity | Mapping & Details |
|--------------------|---------------|-------------------|
| Audited Entity (Farm/Worker) | `Person` / `Site` | Subject of audit observation |
| Auditor / Auditing Body | `Person` / `Enterprise` | `role=auditor`, `enterprise_type=certifier` |
| Audit Finding / Non-Compliance | `Claim` | `type=compliance` / `observation`, `status=pending` / `disputed` |
| Remediation Plan & Deadline | `Claim` metadata | `key=corrective_action_plan`, `valid_until=deadline` |
| Audit Report & Photo Evidence | `Evidence` | `type=audit_report` / `image`, `claim_id` |
| Verification Status Update | `Claim` update | `status=verified` / `expired` |

---

## ⚡ Example Payload

```json
{
  "claim_id": "b2c3d4e5-f6a7-8b9c-0d1e-2f3a4b5c6d7e",
  "type": "compliance",
  "subject_type": "site",
  "subject_id": "8f3b1a20-4e56-4123-a890-112233445566",
  "key": "ppe_chemical_storage_safety",
  "value": "non_compliant_remediation_required",
  "status": "pending",
  "claim_date": "2026-06-01",
  "valid_until": "2026-09-01",
  "source": "Third-Party Safety Audit 2026",
  "metadata": {
    "corrective_action_required": "Install locked storage shed for agrochemicals and provide protective gear.",
    "assigned_field_agent": "person-4455"
  }
}
```

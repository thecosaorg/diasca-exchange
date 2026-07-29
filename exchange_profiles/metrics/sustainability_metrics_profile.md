# Sustainability & Livelihoods Metrics Exchange Profile

> **Specification for Farmer Income, Carbon Footprint, Soil Health, and Social Impact Metrics**

The Sustainability Metrics Exchange Profile defines how ESG, carbon, and socio-economic indicators are attached to supply chain entities.

---

## 📋 Overview

Impact investors, roasters, brand buyers, and NGOs measure farmer livelihoods (living income gap), agricultural practices (agroforestry, shade trees), carbon sequestration, and water usage without redesigning their data structures.

---

## 🧩 Mapping to DIASCA V2 Core

| Indicator Category | DIASCA Entity | Mapping |
|-------------------|---------------|---------|
| Living Income | `Claim` | `type=sustainability`, `key=annual_net_household_income`, `unit=USD` |
| Yield per Hectare | `Claim` | `type=indicator`, `key=cherry_yield_ha`, `value=1200`, `unit=kg/ha` |
| Shade Tree Density | `Claim` | `type=sustainability`, `key=shade_tree_count`, `value=45`, `unit=trees/ha` |
| Household Survey | `Evidence` | `type=survey`, `observation_data={...}` |

---

## ⚡ Example Payload

```json
{
  "claim_id": "d4e5f6a7-b8c9-0d1e-2f3a-4b5c6d7e8f9a",
  "type": "sustainability",
  "subject_type": "person",
  "subject_id": "p1234567-89ab-cdef-0123-456789abcdef",
  "key": "living_income_benchmark_attainment",
  "value": "78.5",
  "value_type": "number",
  "unit": "percent",
  "category": "livelihoods",
  "status": "verified",
  "confidence_score": 0.92,
  "claim_date": "2026-05-15",
  "source": "COSA Livelihoods Assessment v2",
  "created_by_system": "cosa-impact-survey-tool"
}
```

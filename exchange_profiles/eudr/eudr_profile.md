# EUDR Exchange Profile

> Minimum dataset required for EU Deforestation Regulation compliance.

## Status

🚧 **In Development** – This document is a placeholder.

---

## Overview

The EUDR Exchange Profile defines the minimum data structure required to demonstrate compliance with the EU Deforestation Regulation (EUDR), using only concepts from the Semantic Core.

---

## Required Fields

| Field | Semantic Core Mapping | EUDR Requirement |
|-------|----------------------|------------------|
| Plot polygon (GeoJSON) | Site.geometry | Article 9 geolocation |
| Supplier identity | Actor | Operator identification |
| Contract reference | Relationship | Supply chain linkage |
| Deforestation risk | Claim | Due diligence statement |
| Evidence | Evidence | Supporting documentation |
| Transaction reference | Transaction | Trade documentation |

---

## Mapping to Semantic Core

```
Site (Plot)
├── geometry: GeoJSON polygon
├── coordinates: lat/lon
└── country, region

Actor (Supplier/Operator)
├── name
├── identifier (tax ID, GLN)
└── address

Claim (Deforestation Risk)
├── type: "deforestation_free"
├── status: compliant/non-compliant
└── assessment_date

Evidence
├── type: satellite_imagery, audit_report, certification
├── source
└── date
```

---

## Next Steps

- [ ] Define JSON schema
- [ ] Create DBML subset
- [ ] Document validation rules
- [ ] Provide example payloads

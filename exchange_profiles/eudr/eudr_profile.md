# EUDR Exchange Profile

> **Minimum Dataset Specification for EU Deforestation Regulation (EUDR) Article 9 Compliance**

The EUDR Exchange Profile defines the exact data payloads, required fields, and validation rules necessary to construct a complete EUDR Due Diligence Statement (DDS) using the DIASCA V2 Semantic Core.

---

## 📋 Overview & Requirements

Under EUDR Article 9, operators and traders placing relevant commodities (coffee, cocoa, rubber, palm oil, soy, wood, cattle) on the EU market must submit due diligence statements containing:

1. **Description of product** (commodity type, quantity, net mass, trade name)
2. **Country of production** (ISO 3166-1 alpha-2 code)
3. **Geolocation of all plots of production**:
   - Plots ≤ 4 hectares: Single GPS point (latitude + longitude, minimum 6 decimal places)
   - Plots > 4 hectares: GeoJSON polygon boundary with mandatory anti-self-intersection validation
4. **Time range of production** (harvest date or date range)
5. **Supplier / Operator Identity** (Name, legal registration, address, GLN/TIN)
6. **Deforestation-free Verification**: Verification that product was not produced on land deforested after Dec 31, 2020.
7. **Legality Assertion**: Verification that production complied with relevant local legislation.

---

## 🧩 Mapping to DIASCA V2 Core

| EUDR Article 9 Requirement | DIASCA Entity | Field / Mapping |
|----------------------------|---------------|-----------------|
| Operator / Supplier Identity | `Enterprise` | `legal_name`, `registration_id`, `tax_id`, `gln`, `legal_address` |
| Producer / Farmer Identity | `Person` | `name`, `role=farmer`, `linked_enterprise_id` |
| Plot Geolocation | `Site` | `type=plot`, `latitude`, `longitude`, `geometry` (GeoJSON), `country` |
| Supply Chain Linkage | `Relationship` | `type=manages`/`owns`/`supplies`, source `Person`/`Enterprise`, target `Site`/`Enterprise` |
| Physical Product Batch | `Lot` | `product_type`, `origin_site_id`, `quantity`, `unit`, `harvest_date`, `harvest_date_end` |
| Processing & Lineage | `LotLineage` | `input_lot_id`, `output_lot_id`, `transformation_type` (`split`, `merge`, `process`, `blend`) |
| Trade / Export Movement | `Transaction` | `type=export_tx` / `transfer`, `lot_id`, `source_enterprise_id`, `target_enterprise_id` |
| Deforestation-Free Assertion | `Claim` | `type=deforestation_free`, `subject_type=lot`, `status=verified`, `key=cutoff_date_20201231` |
| Satellite / Legal Evidence | `Evidence` | `type=satellite`/`audit_report`, `claim_id`, `file_hash`, `url`, `observation_date` |

---

## ⚡ EUDR Payload Workflow & Example

```
      [Plot Site]
     (GeoJSON > 4ha)
           │
           ▼
     [Harvest Lot] ─── (Lineage) ───► [Export Lot]
           │                                │
           ▼                                ▼
[Deforestation Claim]              [Transaction]
(Verified by Satellite)           (Export / Trade)
           │
           ▼
  [Evidence Record]
(SHA-256 GeoTIFF hash)
```

### 1. Plot Creation (`Site`)
```json
{
  "site_id": "8f3b1a20-4e56-4123-a890-112233445566",
  "name": "Coop Plot #1042",
  "type": "plot",
  "country": "CI",
  "region": "Haut-Sassandra",
  "size": 5.2,
  "size_unit": "hectares",
  "latitude": 6.842100,
  "longitude": -6.447200,
  "geometry": {
    "type": "Polygon",
    "coordinates": [[
      [-6.447200, 6.842100],
      [-6.445000, 6.843000],
      [-6.444000, 6.840500],
      [-6.446500, 6.840000],
      [-6.447200, 6.842100]
    ]]
  },
  "created_by_system": "farm-mapping-app-v1",
  "authority_type": "cooperative_registry"
}
```

### 2. Traceable Product Lot (`Lot`)
```json
{
  "lot_id": "c1a2b3c4-d5e6-7f8a-9b0c-1d2e3f4a5b6c",
  "product_type": "cocoa_fresh",
  "origin_site_id": "8f3b1a20-4e56-4123-a890-112233445566",
  "harvest_date": "2026-10-15",
  "harvest_date_end": "2026-10-20",
  "quantity": 1450.0,
  "unit": "kg",
  "owner_enterprise_id": "e9876543-21fe-4321-bba9-9876543210ab",
  "batch_number": "LOT-2026-CI-1042",
  "created_by_system": "coop-traceability-sys"
}
```

### 3. Deforestation-Free Claim & Evidence (`Claim` + `Evidence`)
```json
{
  "claim_id": "a9b8c7d6-e5f4-3a2b-1c0d-9e8f7a6b5c4d",
  "type": "deforestation_free",
  "subject_type": "lot",
  "subject_id": "c1a2b3c4-d5e6-7f8a-9b0c-1d2e3f4a5b6c",
  "key": "eudr_deforestation_free_post_2020",
  "value": "true",
  "value_type": "boolean",
  "status": "verified",
  "confidence_score": 0.98,
  "methodology": "sentinel-2-forest-loss-v3",
  "created_by_system": "sat-deforestation-tool"
}
```

---

## 🔒 EUDR Validation Rules

1. **Polygon Area Match**: If `site.geometry` is a Polygon, its calculated geodesic area must match `site.size` within a 10% error margin.
2. **GeoJSON Winding Order**: Polygons must follow the RFC 7946 right-hand rule.
3. **Cutoff Date**: Satellite evidence observation dates must cover the period up to Dec 31, 2020 through present harvest date.
4. **Lineage Mass Balance**: For any processing transformation linked to an EUDR Lot, `sum(input_qty) >= sum(output_qty)`.

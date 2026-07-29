# Semantic Core (V2)

> The minimum shared structure that enables many use cases.

## Overview

The V2 Semantic Core defines **9 core concepts** providing an interoperable foundation for agricultural traceability, EUDR compliance, and sustainability data exchange. This version aligns with the Hornbill DIASCA data model.

Key structural changes from the previous version:

- **Person** and **Enterprise** are separate entities (previously unified as `Actor`)
- **Lot** is a first-class concept — the central traceable unit of product
- **LotLineage** tracks transformations between lots (split, merge, blend, process)

- [DBML Schema](semantic_core.dbml) - Formal data model definition
- [SQL DDL](semantic_core.sql) - PostgreSQL implementation
- [JSON Schemas](json_schemas/) - Draft 2020-12 JSON Schema definitions for all 9 entities

---

## Core Concepts

| # | Concept | Description | V1 Mapping |
|---|---------|-------------|------------|
| 1 | **Person** | An individual actor | People |
| 2 | **Enterprise** | An organization | Enterprises |
| 3 | **Site** | A physical place | Sites, origin_plot |
| 4 | **Relationship** | Connection between actors and sites | EnterprisePeople, site ownership |
| 5 | **Lot** | A traceable unit of product | BatchesLotsSerials |
| 6 | **Transaction** | A timestamped activity or movement | Events, BusinessTransactions |
| 7 | **LotLineage** | Transformation between lots | New (EUDR) |
| 8 | **Claim** | Statement about any entity | Attributes, Observations, Activities |
| 9 | **Evidence** | Data supporting a claim | DataSource, AuditAttributesObservations |

---

## Entity Definitions

### 1. Person

An individual actor participating in the supply chain.

Examples: Farmer, Field Agent, Auditor, Inspector.

| Field | Type | Required | Description | V1 Source |
|-------|------|----------|-------------|-----------|
| `person_id` | UUID | Yes | Unique identifier | People.id |
| `name` | string(100) | Yes | Full name | People.name |
| `role` | enum | Yes | Function in supply chain | People.role |
| `email` | string | No | Contact email | People.email |
| `phone` | string | No | Contact phone | People.telephone |
| `linked_enterprise_id` | UUID | No | Primary organization or cooperative | New |
| `metadata` | jsonb | No | Extensible key-value pairs | Attributes |
| `created_at` | timestamp | Yes | Record creation time | created_at |
| `updated_at` | timestamp | No | Last modification time | updated_at |

**Person Roles:**

- `farmer` — Primary agricultural producer
- `field_agent` — Field data collector or extension worker
- `auditor` — Internal or third-party auditor
- `inspector` — Regulatory or certification inspector
- `producer` — General producer role
- `buyer` — Purchasing agent
- `certifier` — Certification body representative

> `linked_enterprise_id` must reference an existing Enterprise. Formal employment and membership relationships are modelled via the **Relationship** entity.

---

### 2. Enterprise

An organization participating in the supply chain.

Examples: Cooperative, Processor, Trader, Exporter, Importer, Certifier.

| Field | Type | Required | Description | V1 Source |
|-------|------|----------|-------------|-----------|
| `enterprise_id` | UUID | Yes | Unique identifier | Enterprises.id |
| `legal_name` | string(200) | Yes | Registered legal name | Enterprises.name |
| `enterprise_type` | enum | Yes | Organization type | New |
| `registration_id` | string(100) | No | Legal/national identifier | New |
| `legal_address` | text | No | Registered address | Enterprises.legal_address |
| `tax_id` | string(100) | No | National tax identifier | Enterprises.tax_id |
| `gln` | string(13) | No | GS1 Global Location Number | Enterprises.gln |
| `parent_enterprise_id` | UUID | No | Parent organization (subsidiaries) | New |
| `metadata` | jsonb | No | Extensible key-value pairs | Attributes |
| `created_at` | timestamp | Yes | Record creation time | created_at |
| `updated_at` | timestamp | No | Last modification time | updated_at |

**Enterprise Types:**

- `cooperative` — Farmer cooperative or union
- `processor` — Processing facility operator
- `trader` — Commodity trader
- `exporter` — Export company
- `importer` — Import company
- `retailer` — Retail business
- `certifier` — Certification body
- `government` — Government agency
- `ngo` — Non-governmental organization

> `registration_id` validation is country-dependent and optional. `tax_id` and `registration_id` may refer to the same identifier depending on jurisdiction.

---

### 3. Site

A physical location where actors operate, products originate, or events occur.

Examples: Plot, Farm, Warehouse, Processing Facility, Port.

| Field | Type | Required | Description | V1 Source |
|-------|------|----------|-------------|-----------|
| `site_id` | UUID | Yes | Unique identifier | Sites.id |
| `name` | string(100) | Yes | Human-readable name | Sites.name |
| `type` | enum | Yes | Site classification | site_types enum |
| `parent_id` | UUID | No | Hierarchical parent site | Sites.parent_id |
| `owner_person_id` | UUID | No | Person who owns/operates the site | New |
| `owner_enterprise_id` | UUID | No | Enterprise that owns/operates the site | Sites.enterprise_id |
| `address` | text | No | Physical/postal address | Sites.address |
| `latitude` | decimal(9,6) | No* | GPS latitude (-90 to 90) | Sites.latitude |
| `longitude` | decimal(9,6) | No* | GPS longitude (-180 to 180) | Sites.longitude |
| `altitude` | float | No | Elevation in meters | Sites.altitude |
| `geometry` | GeoJSON | No* | Plot polygon for complex shapes | New (EUDR) |
| `size` | decimal(10,4) | No | Area (hectares or local unit) | Sites.size |
| `size_unit` | string(20) | No | Unit of measurement | New |
| `country` | string(2) | No* | ISO 3166-1 alpha-2 code | BatchesLotsSerials.country_of_production |
| `region` | string(100) | No | Subnational region | BatchesLotsSerials.region_of_production |
| `is_headquarters` | boolean | No | Is this the main office? | Sites.is_headquarters |
| `metadata` | jsonb | No | Extensible key-value pairs | Attributes |
| `created_at` | timestamp | Yes | Record creation time | Sites.created_at |
| `updated_at` | timestamp | No | Last modification time | Sites.updated_at |

**Site Types:**

- `plot` — Agricultural land parcel
- `farm` — Collection of plots
- `factory` — Manufacturing facility
- `warehouse` — Storage facility
- `processing_facility` — Processing/transformation site
- `distribution_center` — Logistics hub
- `office` — Administrative location
- `port` — Import/export point

**Validation Rules:**

- Geometry must be valid GeoJSON; polygon must be closed
- Coordinates must lie within the declared `country` boundary

> **EUDR Note:** For EUDR compliance, `latitude`/`longitude` OR `geometry` is required, plus `country`.

---

### 4. Relationship

A connection between actors and/or sites, defining roles and associations.

| Field | Type | Required | Description | V1 Source |
|-------|------|----------|-------------|-----------|
| `relationship_id` | UUID | Yes | Unique identifier | New |
| `type` | enum | Yes | Relationship type | New |
| `source_person_id` | UUID | Cond. | Source person | EnterprisePeople.people_id |
| `source_enterprise_id` | UUID | Cond. | Source enterprise | New |
| `target_person_id` | UUID | Cond. | Target person | New |
| `target_enterprise_id` | UUID | Cond. | Target enterprise | EnterprisePeople.enterprise_id |
| `site_id` | UUID | Cond. | Related site | Sites.enterprise_id |
| `role` | string(50) | No | Role in this relationship | New |
| `start_date` | date | No | When relationship began | New |
| `end_date` | date | No | When relationship ended | New |
| `metadata` | jsonb | No | Extensible key-value pairs | Attributes |
| `created_at` | timestamp | Yes | Record creation time | created_at |
| `updated_at` | timestamp | No | Last modification time | updated_at |

**Relationship Types:**

- `employs` — Enterprise employs person
- `owns` — Person or Enterprise owns a site
- `manages` — Person or Enterprise manages a site
- `member_of` — Person is member of cooperative/group
- `supplies` — Enterprise supplies to another enterprise
- `certifies` — Enterprise certifies another actor or site
- `audits` — Person or Enterprise audits another actor or site

> Exactly one source (`source_person_id` OR `source_enterprise_id`) and at least one target (`target_person_id`, `target_enterprise_id`, or `site_id`) must be populated.

---

### 5. Lot

The traceable unit of product. Lots are the central object for agricultural traceability — tracking a commodity from harvest through all transformations to export.

Examples: Coffee cherries, Parchment coffee, Green coffee, Cocoa beans.

| Field | Type | Required | Description | V1 Source |
|-------|------|----------|-------------|-----------|
| `lot_id` | UUID | Yes | Unique identifier | BatchesLotsSerials.id |
| `product_type` | enum | Yes | Commodity and processing stage | BatchesLotsSerials.product_type |
| `origin_site_id` | UUID | Yes | Source plot where product originated | BatchesLotsSerials.origin_plot_id |
| `harvest_date` | date | No | Date or start of harvest period | BatchesLotsSerials.production_date |
| `harvest_date_end` | date | No | End of harvest period (for ranges) | New |
| `quantity` | decimal(18,4) | Yes | Quantity in this lot | BatchesLotsSerials.quantity |
| `unit` | enum | Yes | Unit of measure | BatchesLotsSerials.unit |
| `owner_enterprise_id` | UUID | Yes | Current custodian/owner | New |
| `batch_number` | string(100) | No | Internal batch/lot identifier | BatchesLotsSerials.batch_lot_serial_number |
| `disposition` | string(50) | No | Current state (GS1 CBV) | BatchesLotsSerials.disposition |
| `metadata` | jsonb | No | Extensible key-value pairs | Attributes |
| `created_at` | timestamp | Yes | Record creation time | created_at |
| `updated_at` | timestamp | No | Last modification time | updated_at |

**Product Types (Commodity Stages):**

- `raw_cherry` — Freshly harvested coffee cherries
- `parchment` — Wet-processed parchment coffee
- `green_coffee` — Milled green coffee beans
- `roasted_coffee` — Roasted coffee
- `cocoa_fresh` — Fresh cocoa pods/beans
- `cocoa_dried` — Dried cocoa beans
- `cocoa_processed` — Processed cocoa (butter, powder, liquor)
- `other` — Other commodity

**Units:**

- `kg` — Kilograms
- `mt` — Metric tonnes
- `bags` — Standard export bags
- `liters` — Litres

**Validation Rules:**

- `origin_site_id` must reference a Site of type `plot`
- `harvest_date` must precede any transformation events referencing this lot
- `owner_enterprise_id` must reference an existing Enterprise

---

### 6. Transaction

A timestamped activity, movement, or commercial exchange.

| Field | Type | Required | Description | V1 Source |
|-------|------|----------|-------------|-----------|
| `transaction_id` | UUID | Yes | Unique identifier | Events.id / BusinessTransactions.id |
| `type` | enum | Yes | Transaction classification | gs1_event_types / New |
| `description` | string(200) | No | Human-readable description | Events.description |
| `timestamp` | timestamp | Yes | When transaction occurred | Events.timestamp |
| `source_enterprise_id` | UUID | No | Originating enterprise | BusinessTransactions.seller_enterprise_id |
| `target_enterprise_id` | UUID | No | Receiving enterprise | BusinessTransactions.buyer_enterprise_id |
| `source_site_id` | UUID | No | Originating site | Events.sites_id |
| `target_site_id` | UUID | No | Destination site | New |
| `lot_id` | UUID | No | Primary lot involved | New |
| `product_name` | string(100) | No | Product name (if no discrete Lot) | Products.name |
| `product_sku` | string(100) | No | Internal product code | Products.sku |
| `product_gtin` | string(14) | No | GS1 Global Trade Item Number | Products.gtin |
| `product_category` | string(100) | No | Product classification | Products.category |
| `quantity` | decimal(18,2) | No | Amount transacted | BatchesLotsSerials.quantity |
| `unit` | string(50) | No | Unit of measure | BatchesLotsSerials.unit |
| `sales_order_ref` | string(50) | No | Sales order reference | BusinessTransactions.sales_order_ref |
| `purchase_order_ref` | string(50) | No | Purchase order reference | BusinessTransactions.purchase_order_ref |
| `production_date` | date | No | When product was produced | BatchesLotsSerials.production_date |
| `expiry_date` | date | No | Product expiration date | BatchesLotsSerials.expiry_date |
| `metadata` | jsonb | No | Extensible key-value pairs | Attributes |
| `created_at` | timestamp | Yes | Record creation time | created_at |
| `updated_at` | timestamp | No | Last modification time | updated_at |

**Transaction Types:**

- `harvest` — Harvesting from plot
- `receive` — Receiving a lot at a facility
- `aggregate` — Combining lots at a collection point
- `process` — Transformation of product (triggers LotLineage)
- `store` — Storage event
- `transfer` — Physical movement between sites
- `transport` — In-transit movement
- `sale` — Commercial transaction
- `inspection` — Quality check event
- `certification` — Certification event
- `export` — Cross-border export
- `import` — Cross-border import

> When `type` is `process`, a **LotLineage** record must be created to link input and output lots.

---

### 7. LotLineage

Records the transformation relationship between lots. Each record links one input lot to one output lot within a transformation event. Multiple records sharing an `event_id` represent complex transformations (splits, merges, blends).

| Field | Type | Required | Description | V1 Source |
|-------|------|----------|-------------|-----------|
| `lineage_id` | UUID | Yes | Unique identifier | New |
| `event_id` | UUID | Yes | Transformation Transaction | New |
| `input_lot_id` | UUID | Yes | Source lot consumed | New |
| `output_lot_id` | UUID | Yes | Produced lot | New |
| `input_qty` | decimal(18,4) | Yes | Quantity consumed from input lot | New |
| `output_qty` | decimal(18,4) | Yes | Quantity produced in output lot | New |
| `transformation_type` | enum | Yes | Type of transformation | New |
| `conversion_factor` | decimal(10,6) | No | Yield ratio (output/input) | New |
| `metadata` | jsonb | No | Extensible key-value pairs | New |
| `created_at` | timestamp | Yes | Record creation time | New |

**Transformation Types:**

- `split` — One lot divided into multiple output lots
- `merge` — Multiple lots combined into one
- `process` — Chemical or physical transformation (e.g., wet milling)
- `blend` — Homogeneous mixing of lots
- `package` — Repackaging into new lot units
- `grade` — Separation by quality grade

**Validation Rule:**

```
For all LotLineage records sharing the same event_id:
  sum(input_qty) >= sum(output_qty)
```

Material loss is allowed (drying, hulling, etc.). Yield gain is not permitted.

> **Split:** one input row + multiple output rows sharing `event_id`.  
> **Merge:** multiple input rows + one output row sharing `event_id`.

---

### 8. Claim

A statement, assertion, or measurement about any entity.

| Field | Type | Required | Description | V1 Source |
|-------|------|----------|-------------|-----------|
| `claim_id` | UUID | Yes | Unique identifier | Attributes.id / Observations.id |
| `type` | enum | Yes | Claim classification | observation_keys / New |
| `subject_type` | enum | Yes | What this claim is about | New |
| `subject_id` | UUID | Yes | ID of the subject entity | Attributes.record_id |
| `key` | string(100) | Yes | Claim identifier/name | Attributes.key |
| `value` | text | No | Claim value (string, number, JSON) | Attributes.value |
| `value_type` | enum | No | Data type of value | New |
| `unit` | string(50) | No | Unit of measurement | New |
| `category` | string(100) | No | Logical grouping | Attributes.category |
| `status` | enum | No | Claim status | New |
| `confidence_score` | decimal(3,2) | No | Confidence level (0.00–1.00) | DataSource.confidence_level |
| `claim_date` | date | No | When claim applies | Attributes.attribute_date |
| `valid_from` | date | No | Start of validity period | New |
| `valid_until` | date | No | End of validity period | New |
| `source` | string(200) | No | Origin of the claim | DataSource.name |
| `source_type` | enum | No | Type of source | New |
| `metadata` | jsonb | No | Extensible key-value pairs | New |
| `created_at` | timestamp | Yes | Record creation time | created_at |
| `updated_at` | timestamp | No | Last modification time | updated_at |

**Claim Types:**

- `certification` — Certification status (organic, fair trade)
- `quality` — Quality measurement
- `compliance` — Regulatory compliance status
- `deforestation_free` — EUDR deforestation-free assertion
- `risk` — Risk assessment (deforestation, labor)
- `sustainability` — Sustainability metric
- `survey_response` — Survey/questionnaire answer
- `indicator` — KPI or indicator value
- `observation` — Field observation

**Subject Types:**

- `person`
- `enterprise`
- `site`
- `lot`
- `transaction`
- `claim` (nested claims)

**Value Types:** `string` · `number` · `boolean` · `date` · `json`

**Claim Status:** `pending` · `verified` · `disputed` · `expired` · `revoked`

---

### 9. Evidence

Data, documents, or references that support a claim.

Examples: Satellite imagery, Audit report, Certification document, Photo, GPS trace.

| Field | Type | Required | Description | V1 Source |
|-------|------|----------|-------------|-----------|
| `evidence_id` | UUID | Yes | Unique identifier | DataSource.id |
| `claim_id` | UUID | Yes | The claim this evidence supports | AuditAttributesObservations |
| `type` | enum | Yes | Evidence classification | New |
| `source_name` | string(200) | Yes | Name of evidence source | DataSource.name |
| `source_provider` | string(200) | No | Organization providing evidence | DataSource.provider |
| `description` | text | No | Human-readable description | DataSource.description |
| `url` | text | No | Link to external evidence | New |
| `file_hash` | string(64) | No | SHA-256 hash for integrity | New |
| `confidence_score` | decimal(3,2) | No | Confidence level (0.00–1.00) | DataSource.confidence_level |
| `observation_date` | date | No | When evidence was collected | Observations.observation_date |
| `submission_date` | date | No | When evidence was submitted | DataSource.submission_date |
| `observation_data` | jsonb | No | Structured observation content | Observations.observation |
| `metadata` | jsonb | No | Extensible key-value pairs | New |
| `created_at` | timestamp | Yes | Record creation time | created_at |
| `updated_at` | timestamp | No | Last modification time | updated_at |

**Evidence Types:**

- `document` — PDF, certificate, contract
- `image` — Photo evidence
- `satellite` — Satellite imagery analysis
- `audit_report` — Third-party audit
- `lab_result` — Laboratory analysis
- `sensor_data` — IoT/sensor readings
- `gps_trace` — GPS track data
- `survey` — Survey response data
- `self_declaration` — Self-reported data
- `blockchain` — Blockchain attestation

---

## Conceptual Diagram

```
┌────────────┐   linked_to    ┌──────────────────┐
│   Person   │───────────────►│   Enterprise     │
└─────┬──────┘                └──────┬───────────┘
      │                              │
      │         Relationship         │
      └──────────────┬───────────────┘
                     │ owns/operates/employs
              ┌──────▼──────┐
              │    Site     │
              └──────┬──────┘
                     │ origin_site_id
              ┌──────▼──────┐
              │     Lot     │◄── owner_enterprise_id
              └──────┬──────┘
                     │ lot_id
              ┌──────▼──────┐
              │ Transaction │
              └──────┬──────┘
                     │ event_id
              ┌──────▼──────┐
              │ LotLineage  │ (input_lot → output_lot)
              └──────┬──────┘
                     │ subject_id
              ┌──────▼──────┐
              │    Claim    │◄── subject: person/enterprise/site/lot/transaction
              └──────┬──────┘
                     │ claim_id
              ┌──────▼──────┐
              │  Evidence   │
              └─────────────┘
```

---

## V1 to V2 Migration Mapping

| V1 Entity | V2 Concept | Notes |
|-----------|------------|-------|
| Sites | Site | Direct mapping; `site_id` replaces `id` |
| People | Person | Direct mapping; `person_id` replaces `id` |
| Enterprises | Enterprise | Direct mapping; `enterprise_id` replaces `id` |
| EnterprisePeople | Relationship (type=employs) | Links Person to Enterprise |
| BatchesLotsSerials | Lot | `lot_id` is the new traceable unit |
| Products | Lot.product_type / Transaction.product_name | Product info split: commodity stage on Lot, commercial product details on Transaction |
| Events | Transaction | Event types → Transaction types |
| BusinessTransactions | Transaction (type=sale) | Commercial fields preserved |
| Attributes | Claim | Key-value pairs become Claims |
| Observations | Claim + Evidence | Split into assertion and supporting evidence |
| DataSource | Evidence | Source metadata |
| AuditAttributesObservations | Evidence.claim_id | Links evidence to claims |
| Groups | Relationship (type=member_of) or Claim | Depends on use case |
| Activities | Claim (type=indicator) | Activity outcomes as claims |
| Records | Removed | UUID strategy replaces record_id pattern |
| RecordsGroups | Removed | Use Relationship or Claim grouping |
| RecordFieldSource | Evidence | Field-level provenance |

---

## Design Decisions

### 1. Person and Enterprise as Separate Entities

V2 previously unified people and organizations under a single `Actor` concept. V2.1 separates them because:

- Field sets are genuinely different (e.g., `gln`/`tax_id` for enterprises; `role` enum for persons)
- Validation rules differ (enterprise type from controlled vocabulary; person role from controlled vocabulary)
- Identity semantics differ (a person and an enterprise have different identity proofs)

The `Relationship` entity links Person ↔ Enterprise for membership and employment.

### 2. Lot as the Central Traceability Object

In V1 and earlier V2, lot/batch data was embedded inside Transaction. V2.1 promotes `Lot` to a first-class entity because:

- A lot exists independently of its movements (ownership can change without a transaction)
- Multiple transactions can reference the same lot
- Lot state (quantity, owner, disposition) needs to be tracked separately from events
- LotLineage (transformations) requires stable lot identities as anchors

### 3. LotLineage for Transformation Tracking

`LotLineage` makes transformation chains explicit. This is essential for EUDR compliance — deforestation-free claims must be traceable back through all processing steps to origin plots.

The design uses one row per input/output lot pair, sharing an `event_id`. This supports:
- **Split**: 1 input row → N output rows (same `event_id`)
- **Merge**: N input rows → 1 output row (same `event_id`)
- **1:1 process**: 1 input row → 1 output row

Validation: `sum(input_qty) >= sum(output_qty)` — material loss is allowed.

### 4. Denormalization of Product Info on Transaction

Transaction retains embedded product fields (`product_name`, `product_gtin`, etc.) for systems that do not use discrete Lot entities. When a `lot_id` is present, embedded fields are optional aliases.

### 5. Flexible Metadata via JSONB

Each entity includes a `metadata` field (JSONB) for profile-specific extensions without schema changes. This replaces the generic Attributes table.

---

## Next Steps

- [x] Create DBML schema ([semantic_core.dbml](semantic_core.dbml))
- [x] Generate SQL DDL ([semantic_core.sql](semantic_core.sql))
- [ ] Update DBML and SQL DDL for Person/Enterprise split, Lot, LotLineage
- [ ] Create JSON Schema for each entity
- [ ] Define exchange profile mappings (EUDR, compliance, metrics)
- [ ] Document validation rules per profile

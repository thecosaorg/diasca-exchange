# Semantic Core (V2)

> The minimum shared structure that enables many use cases.

## Overview

The V2 Semantic Core simplifies the V1 data model from 17+ tables to **6 core concepts** while preserving essential information. Each concept maps to multiple V1 entities, providing a unified abstraction layer.

- [DBML Schema](semantic_core.dbml) - Formal data model definition
- [SQL DDL](semantic_core.sql) - PostgreSQL implementation

---

## Core Concepts

| Concept | Description | V1 Mapping |
|---------|-------------|------------|
| **Site** | A physical place | Sites, origin_plot |
| **Actor** | A person or organization | People, Enterprises |
| **Relationship** | Connection between actors and sites | EnterprisePeople, site ownership |
| **Transaction** | Movement of goods or value | BusinessTransactions, BatchesLotsSerials, Events |
| **Claim** | Statement about any entity | Attributes, Observations, Activities |
| **Evidence** | Data supporting a claim | DataSource, AuditAttributesObservations |

---

## Entity Definitions

### 1. Site

A physical location where actors operate, products originate, or events occur.

| Field | Type | Required | Description | V1 Source |
|-------|------|----------|-------------|-----------|
| `id` | UUID | Yes | Unique identifier | Sites.id |
| `name` | string(100) | Yes | Human-readable name | Sites.name |
| `type` | enum | Yes | Site classification | site_types enum |
| `parent_id` | UUID | No | Hierarchical parent site | Sites.parent_id |
| `owner_actor_id` | UUID | No | Actor who owns/operates the site | Sites.enterprise_id |
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

- `plot` - Agricultural land parcel
- `farm` - Collection of plots (new)
- `factory` - Manufacturing facility
- `warehouse` - Storage facility
- `processing_facility` - Processing/transformation site
- `distribution_center` - Logistics hub
- `office` - Administrative location
- `port` - Import/export point (new)

> **\* EUDR Note:** For EUDR compliance, `latitude`/`longitude` OR `geometry` is required, plus `country`.

---

### 2. Actor

A person or organization participating in the supply chain.

| Field | Type | Required | Description | V1 Source |
|-------|------|----------|-------------|-----------|
| `id` | UUID | Yes | Unique identifier | People.id / Enterprises.id |
| `type` | enum | Yes | Actor classification | New |
| `name` | string(100) | Yes | Legal or display name | name field |
| `role` | string(50) | No | Function (producer, buyer, certifier) | People.role |
| `email` | string | No | Contact email | People.email |
| `phone` | string | No | Contact phone | People.telephone |
| `legal_address` | text | No | Registered address | Enterprises.legal_address |
| `tax_id` | string(100) | No | National tax identifier | Enterprises.tax_id |
| `gln` | string(13) | No | GS1 Global Location Number | Enterprises.gln |
| `parent_actor_id` | UUID | No | Parent organization | New (for cooperatives) |
| `metadata` | jsonb | No | Extensible key-value pairs | Attributes |
| `created_at` | timestamp | Yes | Record creation time | created_at |
| `updated_at` | timestamp | No | Last modification time | updated_at |

**Actor Types:**

- `person` - Individual (farmer, inspector, agent)
- `enterprise` - Legal entity (company, cooperative, NGO)
- `government` - Government agency (new)

---

### 3. Relationship

A connection between actors and/or sites, defining roles and associations.

| Field | Type | Required | Description | V1 Source |
|-------|------|----------|-------------|-----------|
| `id` | UUID | Yes | Unique identifier | New |
| `type` | enum | Yes | Relationship type | New |
| `source_actor_id` | UUID | Cond. | The actor in the relationship | EnterprisePeople.people_id |
| `target_actor_id` | UUID | Cond. | Related actor | EnterprisePeople.enterprise_id |
| `site_id` | UUID | Cond. | Related site | Sites.enterprise_id |
| `role` | string(50) | No | Role in relationship | New |
| `start_date` | date | No | When relationship began | New |
| `end_date` | date | No | When relationship ended | New |
| `metadata` | jsonb | No | Extensible key-value pairs | Attributes |
| `created_at` | timestamp | Yes | Record creation time | created_at |
| `updated_at` | timestamp | No | Last modification time | updated_at |

**Relationship Types:**

- `employs` - Enterprise employs person
- `owns` - Actor owns site
- `manages` - Actor manages site
- `member_of` - Person is member of cooperative/group
- `supplies` - Actor supplies to another actor
- `certifies` - Actor certifies another actor
- `audits` - Actor audits another actor

---

### 4. Transaction

Movement of goods, products, or value between actors/sites. Covers physical movements and commercial exchanges.

| Field | Type | Required | Description | V1 Source |
|-------|------|----------|-------------|-----------|
| `id` | UUID | Yes | Unique identifier | Events.id / BusinessTransactions.id |
| `type` | enum | Yes | Transaction classification | gs1_event_types / New |
| `description` | string(200) | No | Human-readable description | Events.description |
| `timestamp` | timestamp | Yes | When transaction occurred | Events.timestamp |
| `source_actor_id` | UUID | No | Originating actor | BusinessTransactions.seller_enterprise_id |
| `target_actor_id` | UUID | No | Receiving actor | BusinessTransactions.buyer_enterprise_id |
| `source_site_id` | UUID | No | Originating site | Events.sites_id |
| `target_site_id` | UUID | No | Destination site | New |
| `product_name` | string(100) | No | What was transacted | Products.name |
| `product_sku` | string(100) | No | Internal product code | Products.sku |
| `product_gtin` | string(14) | No | GS1 Global Trade Item Number | Products.gtin |
| `product_category` | string(100) | No | Product classification | Products.category |
| `batch_number` | string(100) | No | Batch/lot identifier | BatchesLotsSerials.batch_lot_serial_number |
| `quantity` | decimal(18,2) | No | Amount transacted | BatchesLotsSerials.quantity |
| `unit` | string(50) | No | Unit of measure | BatchesLotsSerials.unit |
| `sales_order_ref` | string(50) | No | Sales order reference | BusinessTransactions.sales_order_ref |
| `purchase_order_ref` | string(50) | No | Purchase order reference | BusinessTransactions.purchase_order_ref |
| `production_date` | date | No | When product was produced | BatchesLotsSerials.production_date |
| `expiry_date` | date | No | Product expiration date | BatchesLotsSerials.expiry_date |
| `origin_site_id` | UUID | No | Where product originated | BatchesLotsSerials.origin_plot_id |
| `disposition` | string(50) | No | Current status (GS1 CBV) | BatchesLotsSerials.disposition |
| `metadata` | jsonb | No | Extensible key-value pairs | Attributes |
| `created_at` | timestamp | Yes | Record creation time | created_at |
| `updated_at` | timestamp | No | Last modification time | updated_at |

**Transaction Types:**

- `harvest` - Harvesting from plot
- `processing` - Transformation of product
- `transfer` - Physical movement
- `sale` - Commercial transaction
- `inspection` - Quality check event
- `certification` - Certification event
- `import` - Cross-border import
- `export` - Cross-border export

---

### 5. Claim

A statement, assertion, or measurement about any entity (site, actor, transaction, or another claim).

| Field | Type | Required | Description | V1 Source |
|-------|------|----------|-------------|-----------|
| `id` | UUID | Yes | Unique identifier | Attributes.id / Observations.id |
| `type` | enum | Yes | Claim classification | observation_keys / New |
| `subject_type` | enum | Yes | What this claim is about | New |
| `subject_id` | UUID | Yes | ID of the subject entity | Attributes.record_id |
| `key` | string(100) | Yes | Claim identifier/name | Attributes.key |
| `value` | text | No | Claim value (string, number, JSON) | Attributes.value |
| `value_type` | enum | No | Data type of value | New |
| `unit` | string(50) | No | Unit of measurement | New |
| `category` | string(100) | No | Logical grouping | Attributes.category |
| `status` | enum | No | Claim status | New |
| `confidence_score` | decimal(3,2) | No | Confidence level (0.00-1.00) | DataSource.confidence_level (normalized) |
| `claim_date` | date | No | When claim applies | Attributes.attribute_date |
| `valid_from` | date | No | Start of validity period | New |
| `valid_until` | date | No | End of validity period | New |
| `source` | string(200) | No | Origin of the claim | DataSource.name |
| `source_type` | enum | No | Type of source | New |
| `metadata` | jsonb | No | Extensible key-value pairs | New |
| `created_at` | timestamp | Yes | Record creation time | created_at |
| `updated_at` | timestamp | No | Last modification time | updated_at |

**Claim Types:**

- `certification` - Certification status (organic, fair trade)
- `quality` - Quality measurement
- `compliance` - Regulatory compliance status
- `risk` - Risk assessment (deforestation, labor)
- `sustainability` - Sustainability metric
- `survey_response` - Survey/questionnaire answer
- `indicator` - KPI or indicator value
- `observation` - Field observation

**Subject Types:**

- `site`
- `actor`
- `transaction`
- `claim` (for nested claims)

**Value Types:**

- `string`
- `number`
- `boolean`
- `date`
- `json`

**Claim Status:**

- `pending` - Awaiting verification
- `verified` - Confirmed by evidence
- `disputed` - Under review
- `expired` - No longer valid
- `revoked` - Withdrawn

---

### 6. Evidence

Data, documents, or references that support a claim.

| Field | Type | Required | Description | V1 Source |
|-------|------|----------|-------------|-----------|
| `id` | UUID | Yes | Unique identifier | DataSource.id |
| `claim_id` | UUID | Yes | The claim this evidence supports | AuditAttributesObservations |
| `type` | enum | Yes | Evidence classification | New |
| `source_name` | string(200) | Yes | Name of evidence source | DataSource.name |
| `source_provider` | string(200) | No | Organization providing evidence | DataSource.provider |
| `description` | text | No | Human-readable description | DataSource.description |
| `url` | text | No | Link to external evidence | New |
| `file_hash` | string(64) | No | SHA-256 hash for integrity | New |
| `confidence_score` | decimal(3,2) | No | Confidence level (0.00-1.00) | DataSource.confidence_level (normalized) |
| `observation_date` | date | No | When evidence was collected | Observations.observation_date |
| `submission_date` | date | No | When evidence was submitted | DataSource.submission_date |
| `observation_data` | jsonb | No | Structured observation content | Observations.observation |
| `metadata` | jsonb | No | Extensible key-value pairs | New |
| `created_at` | timestamp | Yes | Record creation time | created_at |
| `updated_at` | timestamp | No | Last modification time | updated_at |

**Evidence Types:**

- `document` - PDF, certificate, contract
- `image` - Photo evidence
- `satellite` - Satellite imagery analysis
- `audit_report` - Third-party audit
- `lab_result` - Laboratory analysis
- `sensor_data` - IoT/sensor readings
- `survey` - Survey response data
- `self_declaration` - Self-reported data
- `blockchain` - Blockchain attestation

---

## Conceptual Diagram

```
                    ┌──────────────┐
                    │ Relationship │
                    └──────┬───────┘
                           │
        ┌──────────────────┼──────────────────┐
        │                  │                  │
        ▼                  ▼                  ▼
   ┌─────────┐      ┌─────────────┐      ┌─────────┐
   │  Actor  │◄────►│ Transaction │◄────►│  Site   │
   └────┬────┘      └──────┬──────┘      └────┬────┘
        │                  │                  │
        │    ┌─────────────┼─────────────┐    │
        │    │             │             │    │
        └────┼─────►┌──────▼──────┐◄─────┼────┘
             │      │    Claim    │      │
             │      └──────┬──────┘      │
             │             │             │
             │      ┌──────▼──────┐      │
             │      │  Evidence   │      │
             │      └─────────────┘      │
             │                           │
             └───────────────────────────┘

```

---

## V1 to V2 Migration Mapping

| V1 Entity | V2 Concept | Notes |
|-----------|------------|-------|
| Sites | Site | Direct mapping |
| People | Actor (type=person) | Role becomes Actor.role |
| Enterprises | Actor (type=enterprise) | Includes GLN, tax_id |
| EnterprisePeople | Relationship (type=employs) | Links actors |
| Products | Transaction (embedded) | Product info denormalized into Transaction |
| BatchesLotsSerials | Transaction (embedded) | Batch info denormalized into Transaction |
| Events | Transaction | Event types → Transaction types |
| BusinessTransactions | Transaction (type=sale) | Commercial transactions |
| Attributes | Claim | Key-value pairs become Claims |
| Observations | Claim + Evidence | Split into claim and supporting evidence |
| DataSource | Evidence | Source metadata |
| AuditAttributesObservations | Evidence.claim_id | Links evidence to claims |
| Groups | Actor (parent_actor_id) or Claim | Depends on use case |
| Activities | Claim (type=indicator) | Activity outcomes as claims |
| Records | Removed | UUID strategy replaces record_id pattern |
| RecordsGroups | Removed | Use Relationship or Claim grouping |
| RecordFieldSource | Evidence | Field-level provenance |

---

## Design Decisions

### 1. Denormalization of Products and Batches

In V1, Products and BatchesLotsSerials are separate tables with complex relationships. In V2, product and batch information is **embedded directly in Transaction** for simpler querying and exchange.

**Rationale:** In practice, product info is almost always needed alongside transaction data. Denormalization reduces joins and simplifies exchange profiles.

### 2. Records Pattern Removed

V1 uses a `Records` table as a universal anchor for all entities. V2 **removes this pattern** and relies on UUIDs for cross-entity references.

**Rationale:** The Records pattern added complexity. UUIDs provide unique identification without the indirection.

### 3. Groups Absorbed into Relationships and Claims

V1 Groups and RecordsGroups are replaced by:

- **Relationship** (type=member_of) for organizational groupings
- **Claim** for logical groupings (e.g., "part of certification program")

**Rationale:** Groups served multiple purposes that are better handled by more specific concepts.

### 4. Flexible Metadata via JSONB

Each entity includes a `metadata` field (JSONB) for extensible key-value pairs. This replaces the generic Attributes table while maintaining flexibility.

**Rationale:** Allows profile-specific extensions without schema changes.

---

## Next Steps

- [x] Create DBML schema ([semantic_core.dbml](semantic_core.dbml))
- [x] Generate SQL DDL ([semantic_core.sql](semantic_core.sql))
- [ ] Create JSON Schema for each entity
- [ ] Define exchange profile mappings (EUDR, compliance, metrics)
- [ ] Document validation rules

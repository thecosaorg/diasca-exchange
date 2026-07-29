# DIASCA DPI Architecture & Integration Roadmap

> **Comprehensive Specification for DIASCA Digital Public Infrastructure (DPI), API Contracts, OAuth Scopes, Event Streams, and Federation Model**

---

## 🏛️ Executive Summary

DIASCA (Data Interoperability for Agricultural Supply Chain Actors) defines a **Minimum Viable DPI** for agricultural traceability, regulatory compliance, and sustainability data exchange. 

This document outlines the architectural blueprint, integration model, capability scopes, hybrid API design, contribution provenance, event streaming, and federated topology required to deploy a production-grade DIASCA DPI service node.

---

## 📍 1. What the Central DIASCA DPI Provides

The central DIASCA DPI is **not** a software application for farmers or supply chain actors; it is a **shared digital infrastructure**.

```
DIASCA DPI Node
├── 1. Canonical Data Model (9 V2 Core Entities: Person, Enterprise, Site, Relationship, Lot, Transaction, LotLineage, Claim, Evidence)
├── 2. Shared Identifiers (UUIDv4 canonical keys + cross-system mapping GLN, TaxID, GeoID)
├── 3. Validation Rules (Geometry area/winding, Lineage mass balance sum(input) >= sum(output), Date constraints)
├── 4. Authentication & Authorization (OAuth2 + JWT + Fine-grained Scopes + Tenant Consent)
├── 5. Provenance & Audit History (Immutable contribution graph, audit logs, source attribution)
├── 6. API & Event Interfaces (RESTful CRUD + Domain Operations + Pub/Sub Event Topics)
├── 7. Schema & Version Registry (JSON Schema registry draft 2020-12)
└── 8. Reference Implementation (Modular monolith on Cloud Run + PostGIS)
```

### Integration Philosophy

A participating application **does not need to change its internal database schema**. An app does not need to store `Person`, `Site`, `Lot`, `Claim`, and `Evidence` internally using DIASCA table names or field names.

Instead, a participating app must only:
1. **Understand** the relevant DIASCA canonical resources.
2. **Map** its internal objects to those canonical resources upon data exchange (e.g., mapping internal `member` or `producer` records to `Person`).
3. **Respect** DIASCA canonical identifiers and validation rules when transmitting data.
4. **Declare** its capability scopes and authorization boundaries.

---

## 🔐 2. Tool Capabilities & Fine-Grained OAuth Scopes

Access control in DIASCA is enforced through **granular capability scopes**, avoiding monolithic `read`/`write` roles.

### Fine-Grained OAuth Scopes Catalog

| Scope | Category | Description |
|-------|----------|-------------|
| `people:read` | Person | View person records |
| `people:create` | Person | Register new individual actors |
| `people:update` | Person | Update non-authoritative profile details |
| `people:link_enterprise` | Person | Associate a person with an enterprise |
| `enterprises:read` | Enterprise | View enterprise details |
| `enterprises:create` | Enterprise | Register new legal organizations |
| `enterprises:validate` | Enterprise | Verify tax ID, registration ID, or GLN legitimacy |
| `sites:read` | Site | View site records |
| `sites:create` | Site | Register new physical plots or facilities |
| `sites:update_geometry` | Site | Submit or revise plot GeoJSON boundaries |
| `sites:attach_external_identifier` | Site | Attach external IDs (e.g., FAO GeoID, national cadastre) |
| `sites:validate_geometry` | Site | Run topological and overlap validation |
| `lots:read` | Lot | Query traceable product units |
| `lots:create` | Lot | Create new harvest lots |
| `lots:transform` | Lot | Execute split, merge, blend, or process operations |
| `events:read` | Transaction | Query supply chain transactions |
| `events:create` | Transaction | Record physical movements, receipts, or sales |
| `lineage:read` | LotLineage | Query transformation graph |
| `lineage:create` | LotLineage | Record input-to-output lot transformations |
| `claims:read` | Claim | View assertions and risk assessments |
| `claims:create` | Claim | Submit new claims (deforestation, organic, yield) |
| `claims:verify` | Claim | Formally verify or reject pending claims |
| `claims:supersede` | Claim | Replace an outdated claim with a newer assessment |
| `evidence:read` | Evidence | Download/view evidence documents and data |
| `evidence:create` | Evidence | Upload evidence files, satellite hashes, or survey data |

### Participating Tool Capability Matrix

| Participating Tool | Typical Role / System | Required Scopes |
|-------------------|----------------------|-----------------|
| **Farmer Registry App** | Cooperative software | `people:read`, `people:create`, `people:update`, `enterprises:read`, `sites:read`, `sites:create` |
| **FAO GeoID Integration** | Global ID provider | `sites:read`, `sites:create`, `sites:attach_external_identifier` |
| **Farm Mapping App** | GIS / Drone app | `sites:read`, `sites:create`, `sites:update_geometry`, `sites:validate_geometry` |
| **Traceability System** | Supply chain platform | `lots:read`, `lots:create`, `lots:transform`, `events:create`, `lineage:create` |
| **Deforestation Assessment** | Remote sensing platform | `sites:read`, `claims:create`, `claims:verify`, `evidence:create` |
| **Certification Body** | Third-party certifier | `claims:read`, `claims:create`, `claims:verify`, `claims:supersede`, `evidence:create` |
| **Buyer / Importer System** | Enterprise ERP | `lots:read`, `events:read`, `lineage:read`, `claims:read`, `evidence:read` |
| **Farmer Advisory App** | Mobile extension tool | `people:read`, `sites:read`, `claims:read`, `evidence:create` (observations) |
| **Government Registry** | Ministry of Agriculture | `enterprises:validate`, `sites:read`, `sites:attach_external_identifier`, `claims:verify` |

---

## 🔀 3. Hybrid API Design (Resource CRUD + Custom Domain Operations)

Unrestricted CRUD APIs allow systems to bypass business logic, obscure provenance, and overwrite data incorrectly. DIASCA implements a **Hybrid API Architecture**: standard RESTful CRUD endpoints for entity retrieval and basic creation, combined with **RPC-style Custom Domain Operations** for state transitions and business actions.

```
                  ┌───────────────────────────────────────────────────────────┐
                  │                 DIASCA Hybrid API Layer                   │
                  └─────────────────────────────┬─────────────────────────────┘
                                                │
                 ┌──────────────────────────────┴──────────────────────────────┐
                 │                                                             │
                 ▼                                                             ▼
   [Resource-Oriented Endpoints]                                 [Domain-Specific Operations]
  - GET  /v2/people/{id}                                        - POST /v2/sites/{id}:attachGeoId
  - POST /v2/people                                             - POST /v2/sites/{id}:updateGeometry
  - GET  /v2/sites/{id}                                         - POST /v2/sites/{id}:validateGeometry
  - POST /v2/sites                                              - POST /v2/lots/{id}:split
  - GET  /v2/lots/{id}                                          - POST /v2/lots:merge
  - POST /v2/lots                                               - POST /v2/claims/{id}:verify
  - GET  /v2/claims/{id}                                        - POST /v2/claims/{id}:supersede
  - POST /v2/claims                                             - POST /v2/people/{id}:linkEnterprise
```

### Resource-Oriented Endpoints (CRUD)
- `POST   /v2/people` – Register new person
- `GET    /v2/people/{person_id}` – Fetch person profile
- `POST   /v2/enterprises` – Register new enterprise
- `GET    /v2/enterprises/{enterprise_id}` – Fetch enterprise
- `POST   /v2/sites` – Register physical site/plot
- `GET    /v2/sites/{site_id}` – Fetch site metadata & location
- `POST   /v2/lots` – Create traceable lot
- `GET    /v2/lots/{lot_id}` – Fetch lot state
- `POST   /v2/events` – Record supply chain activity
- `POST   /v2/claims` – Submit claim
- `GET    /v2/claims/{claim_id}` – Retrieve claim & status
- `POST   /v2/evidence` – Attach evidence record

### Domain-Specific Operations

#### Site Operations
- `POST /v2/sites/{site_id}:attachGeoId` – Attach an FAO GeoID or national registry reference without modifying ownership fields.
- `POST /v2/sites/{site_id}:updateGeometry` – Submit a revised GeoJSON polygon boundary. Triggers automated topology checks and audit log entries.
- `POST /v2/sites/{site_id}:validateGeometry` – Run self-intersection, winding order, and overlap analysis against national forest boundaries.

#### Claim Operations
- `POST /v2/claims/{claim_id}:verify` – Certifier or auditor approves a pending claim, attaching verification methodology and confidence score.
- `POST /v2/claims/{claim_id}:reject` – Formally dispute or reject an invalid claim with reason code.
- `POST /v2/claims/{claim_id}:supersede` – Invalidate a previous claim and link it to a newly created replacement claim.

#### Lot & Lineage Operations
- `POST /v2/lots/{lot_id}:split` – Divide 1 input lot into N output lots. Automatically generates `LotLineage` records.
- `POST /v2/lots:merge` – Combine N input lots into 1 output lot. Automatically validates product compatibility and generates `LotLineage` records.
- `POST /v2/events/{event_id}:recordTransformation` – Atomic processing operation (e.g. wet milling) consuming input lots and outputting parchment lots.

#### Identity & Relationship Operations
- `POST /v2/people:match` – Fuzzy match person records across source systems based on name, phone, and location to prevent duplicates.
- `POST /v2/people/{person_id}:linkEnterprise` – Formalize employment or cooperative membership with an enterprise.

---

## 📜 4. Contribution Records & Information Graph Model

DIASCA avoids "last-update-wins" overwrites by acting as an **Immutable Information Graph with Source Provenance**.

Rather than allowing external applications to directly edit canonical properties of a central record, applications submit **Contribution Records**.

```json
// Example 1: FAO GeoID Contribution
POST /v2/sites/site-123:attachGeoId
{
  "identifier_type": "fao_geoid",
  "identifier_value": "GEO-2026-889911",
  "subject_type": "site",
  "subject_id": "site-123",
  "source_system": "fao-geoid-service",
  "authority_type": "external_provider",
  "contributed_at": "2026-07-29T10:00:00Z"
}

// Example 2: Drone Mapping Geometry Contribution
POST /v2/sites/site-123:updateGeometry
{
  "subject_type": "site",
  "subject_id": "site-123",
  "geometry": {
    "type": "Polygon",
    "coordinates": [[[-6.44, 6.84], [-6.43, 6.84], [-6.43, 6.83], [-6.44, 6.84]]]
  },
  "source_system": "drone-mapper-v2",
  "authority_type": "third_party_auditor",
  "observed_at": "2026-07-28T14:30:00Z"
}
```

---

## 🏷️ 5. Provenance & Metadata Model

Every object and contribution in DIASCA distinguishes between **Ownership**, **Authorship**, **Authority**, and **Custody**.

### Four Core Questions

| Question | Metadata Field | Example |
|----------|---------------|---------|
| **Who owns the underlying subject?** | `owner_person_id` / `owner_enterprise_id` | Farmer owns plot; Exporter owns Lot |
| **Who created the digital record?** | `created_by_system` + `created_by_actor` | Cooperative software app registered the Site |
| **Who supplied this attribute?** | `source_system` | FAO GeoID service supplied external ID |
| **Who is authoritative for it?** | `authority_type` | National Land Ministry is authoritative for plot boundaries |

### Common Provenance Metadata Schema

```json
{
  "created_by_system": "coop-farmer-app-v1",
  "created_by_actor": "agent-user-998",
  "source_system": "fao-geoid",
  "authority_type": "government_registry",
  "created_at": "2026-07-29T10:00:00Z",
  "updated_at": "2026-07-29T10:00:00Z",
  "schema_version": "2.0.0",
  "status": "active",
  
  // For Claims & Evidence:
  "methodology": "sentinel-2-forest-loss-v3",
  "confidence": 0.96,
  "valid_from": "2026-01-01",
  "valid_until": "2027-01-01"
}
```

---

## 🏗️ 6. Recommended Service Boundaries & Cloud Run Architecture

To prevent unnecessary operational complexity, DIASCA is structured as a **Modular Monolith** (`diasca-api`) for initial deployment, designed for seamless future extraction into microservices if needed.

### Internal Component Layout

```
diasca-api
├── identity          # AuthN, JWT parsing, OAuth client management
├── authorization     # Fine-grained scope checker & RBAC policy engine
├── people            # Person entity manager & matching algorithms
├── enterprises       # Enterprise entity manager & GLN/TaxID validation
├── sites             # Site & plot manager, PostGIS spatial queries
├── identifiers       # External identifier cross-reference registry
├── lots              # Traceable product lot manager
├── events            # Transaction & activity event recorder
├── lineage           # Mass-balance lot transformation graph engine
├── claims            # Claim assertion lifecycle & verification workflow
├── evidence          # Evidence metadata, file hashing, Cloud Storage links
├── provenance        # Immutable audit log & contribution history recorder
└── interoperability  # Schema registry & event publisher
```

### Google Cloud Infrastructure Blueprint

```
                      [ External Client Applications ]
                                     │
                                     ▼
                        [ Google Cloud API Gateway ]
                    (TLS Termination & JWT Scope Checking)
                                     │
                                     ▼
                    [ DIASCA API on Google Cloud Run ]
                       (Stateless Container: Go/Python)
                                     │
         ┌───────────────────────────┼───────────────────────────┐
         ▼                           ▼                           ▼
[ Cloud SQL PostgreSQL ]   [ Google Cloud Storage ]   [ Google Cloud Pub/Sub ]
 (PostGIS spatial tables +   (Evidence files, PDFs,     (Integration Event
  Audit provenance log)       satellite images)          Broadcaster)
```

Why **Google Cloud Run**:
- Stateless, auto-scaling execution (scales to zero when idle).
- Language-agnostic container execution (Go or Python).
- Built-in HTTPS endpoints with Cloud IAM & API Gateway protection.

---

## 📡 7. API Integration Event Topics

DIASCA uses an Event-Driven Architecture to notify subscribing systems about changes without polling.

### Event Catalog & Schema

| Event Topic | Payload Summary | Triggering Action |
|-------------|-----------------|-------------------|
| `person.created` | `person_id`, `name`, `role`, `source_system` | New Person registered |
| `site.created` | `site_id`, `type`, `country`, `latitude`, `longitude` | New Site registered |
| `site.geometry.updated` | `site_id`, `geometry`, `size`, `source_system` | Plot boundary updated |
| `site.identifier.attached` | `site_id`, `identifier_type`, `identifier_value` | GeoID attached |
| `lot.created` | `lot_id`, `product_type`, `origin_site_id`, `quantity` | Harvest lot registered |
| `lot.transformed` | `event_id`, `input_lot_ids`, `output_lot_ids`, `transformation_type` | Split / Merge / Processing |
| `claim.created` | `claim_id`, `type`, `subject_type`, `subject_id`, `key` | Claim submitted |
| `claim.verified` | `claim_id`, `status`, `confidence_score`, `verified_by` | Claim approved |
| `evidence.attached` | `evidence_id`, `claim_id`, `type`, `file_hash` | Evidence attached |

### Example Interoperability Sequence Workflow

```
[Farmer Registry] ──► POST /v2/sites (creates Site)
                              │
                              ▼
                      Publish: site.created
                              │
            ┌─────────────────┴─────────────────┐
            ▼                                   ▼
[FAO GeoID Service]                      [Deforestation Engine]
  Listens: site.created                    Listens: site.created
  attaches GeoID                           runs satellite analysis
  POST /sites/{id}:attachGeoId             POST /claims (type=deforestation_free)
            │                                   │
            ▼                                   ▼
Publish: site.identifier.attached        Publish: claim.created
```

---

## 🌐 8. Federated Architecture & "DPI of DPI" Model

While a single central node suffices for a country or organization, the long-term vision aligns with GIZ's **"DPI of DPI" Federation Model**.

```
                           ┌─────────────────────────┐
                           │   DPI of DPI Global     │
                           │    Discovery Layer      │
                           └────────────┬────────────┘
                                        │
             ┌──────────────────────────┼──────────────────────────┐
             ▼                          ▼                          ▼
    [Country Node: Ivory Coast]   [Producer Node: COSA]     [Certification Node]
    (DIASCA Core Implementation)  (DIASCA Core Implementation) (DIASCA Core Implementation)
```

### Global Federation Layer Responsibilities
1. **Node Discovery**: Locate national or organizational DIASCA nodes.
2. **Trust Federation**: Verify cryptographic node identities and compliance certifications.
3. **Schema Registry**: Publish canonical DIASCA versions and custom Exchange Profile extensions.
4. **Cross-Network Identifiers**: Resolve global product lots across borders without duplicating underlying agricultural databases.
5. **Consent & Authorization Exchange**: Manage farmer data privacy and consent tokens across network boundaries.

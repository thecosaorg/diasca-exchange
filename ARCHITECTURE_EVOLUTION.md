# DIASCA Data Model – Architecture Evolution

## Purpose of this Repository

This repository contains the canonical DIASCA data model (DBML, SQL DDL, ER specification, and related tools) for agricultural supply chain data exchange.

**This version is NOT discarded.**  
Instead, it becomes **Version 1 (V1)** of our thinking.

The purpose of this project now is:

> To evolve from a complex "full data model" into a **Minimal Semantic Core + Exchange Profiles** approach that is easier to understand, easier to implement, and more aligned with real field experience from COSA and recent EUDR-related implementations.

This repository will therefore manage **multiple versions** of the model without losing history.

---

## Why Simplification Is Needed

During implementations (notably with EUDR-related work with an association in Africa), we observed:

- The original model tried to be too complete.
- Implementers struggled to understand which parts were truly required.
- Data collection tools became coupled with data exchange design.
- The model was correct in theory but heavy in practice.
- Teams needed **much less structure** to achieve interoperability than expected.

This led to a key realization:

> Interoperability does **not** require a big data model.  
> It requires a **small shared semantic core** and **clear exchange profiles**.

---

## Goals of This Project

1. Preserve the original DIASCA model as reference (V1).
2. Extract from it a **Minimal Semantic Core (V2)**.
3. Define **Exchange Profiles** (EUDR, Compliance, Metrics, etc.).
4. Provide diagrams and documentation that are understandable by:
   - NGOs
   - Governments
   - Implementers
   - Software teams
5. Align the work with DIASCA, DPI, SAFE, and data space conversations.
6. Propose practical answers to recurring DIASCA questions.

---

## DIASCA as Digital Public Infrastructure (DPI)

DIASCA aims to define a **Minimum Viable DPI** for agricultural supply chains.

### What is DPI?

Digital Public Infrastructure refers to shared digital systems that enable interoperability across many actors—like identity systems, payment rails, or data exchange standards. DPI is:

- **Open** – built on open standards, not proprietary lock-in
- **Interoperable** – allows different systems to exchange data
- **Inclusive** – usable by small actors, not just large enterprises
- **Foundational** – enables many use cases without prescribing solutions

### How DIASCA Aligns with DPI Principles

| DPI Principle | DIASCA Approach |
|---------------|-----------------|
| Shared rails, not shared apps | Define data exchange standards, not software |
| Minimal by design | Semantic Core with only 6 concepts |
| Use-case agnostic | Exchange Profiles adapt the core to EUDR, compliance, livelihoods, etc. |
| No vendor lock-in | SQL, DBML, and JSON schemas—implementable anywhere |
| Federation over centralization | Each actor manages their own data; standards enable exchange |

### The MVP DPI Vision

> DIASCA's Minimal Semantic Core is the **smallest possible shared vocabulary** that enables traceability, compliance, and sustainability data to flow between systems without requiring a central database or a single software platform.

This positions DIASCA not as a product, but as **infrastructure**—a set of agreements that make interoperability possible.

---

## Current Repository Structure

The repository is organized as follows:

```
/v1_original_model          # Original comprehensive DIASCA model
    /dbml
        diasca-model.dbml   # DBML source for ER diagram
        diasca-model.png    # Rendered ER diagram
    /sql
        diasca-schema.mysql.sql   # MySQL DDL
        diasca-schema.psql.sql    # PostgreSQL DDL
    /spec
        er-spec.md          # Full Entity-Relationship Model Documentation
    /podcast
        diasca-data-model-explained.mp3   # Audio walkthrough
    DIASCA data model Layman's terms - 20250731.pdf  # Visual overview

/v2_semantic_core           # Minimal semantic core (in development)
    semantic_core.md        # Documentation
    semantic_core.dbml      # DBML source
    semantic_core.sql       # SQL DDL

/exchange_profiles          # Use-case specific data profiles
    /eudr                   # EU Deforestation Regulation
        eudr_profile.md
        eudr_profile.dbml
    /compliance             # Compliance & remediation (placeholder)
    /metrics                # Sustainability metrics (placeholder)

/diagrams                   # Visual documentation

/docs                       # Additional documentation
    lessons_from_recent_implementations.md
    design_principles.md
    open_questions.md

/tools
    /geojson-validator      # Python library for GeoJSON validation
        /src
        /docs
        /tests

# Root files
ARCHITECTURE_EVOLUTION.md   # This document
README.md                   # Repository overview
LICENSE                     # MIT License
```

### Key Components

| Component | Description |
|-----------|-------------|
| **V1 Model** | Complete DIASCA model with DBML, SQL, spec, and podcast |
| **V2 Semantic Core** | Minimal 6-concept core (in development) |
| **Exchange Profiles** | EUDR, compliance, metrics profiles (planned) |
| **GeoJSON Validator** | Python library for validating plot geometries |
| **PDF Overview** | Visual "layman's terms" document for non-technical audiences |

---

## Lessons Learned from recent Implementations

When attempting to apply the original DIASCA model in Africa:

- The team only needed:
  - Plots
  - Farmers
  - Buyers
  - Claims
  - Basic transactions
- Many tables were never used.
- Confusion arose around which entities were mandatory.
- Implementation time increased due to model complexity.
- What was really needed was:
  - A plot registry
  - A simple way to relate actors
  - A way to attach claims and evidence

This heavily informs V2.

---

## Minimal Semantic Core (V2)

The semantic core should answer:

> What is the minimum shared structure that enables many use cases?

### Core Concepts

| Concept | Description |
|---------|-------------|
| Site | A physical place (plot, farm, factory, warehouse) |
| Actor | A person or organization |
| Relationship | Actor connected to Site |
| Transaction | Movement of goods between actors/sites |
| Claim | Statement about a site, actor, or transaction |
| Evidence | Data supporting a claim |

---

## Semantic Core Diagram (Textual)

```
Actor ───── owns/manages ───── Site
Actor ───── transacts with ───── Actor
Transaction ───── involves ───── Site
Claim ───── refers to ───── Site / Actor / Transaction
Evidence ───── supports ───── Claim
```

This structure is sufficient to support:

- EUDR
- Compliance
- Metrics
- Traceability
- Certifications

---

## Exchange Profiles

Instead of expanding the core model, use **Exchange Profiles**.

> An Exchange Profile defines the **minimum dataset required** for a specific use case.

### EUDR Exchange Profile

Minimum required:

| Field | From Semantic Core |
|------|---------------------|
| Plot polygon (GeoJSON) | Site |
| Supplier identity | Actor |
| Contract reference | Relationship |
| Deforestation risk | Claim |
| Evidence | Evidence |
| Transaction reference | Transaction |

No additional model required.

---

### Farmer Livelihoods as an Exchange Profile

- Indicators are claims
- Surveys are evidence
- Farmers are actors
- Farms are sites

```
Actor (Farmer) ─── manages ─── Site (Farm/Plot)
Evidence (Survey Response) ─── supports ─── Claim (Indicator value)
Claim ─── refers to ─── Actor / Site
```

> Traceability, compliance, and farmer livelihoods are not separate data problems. They are different exchange profiles over the same minimal semantic core.

---

## Other Potential Exchange Profiles

- Compliance Remediation Profile
- Sustainability Metrics Profile
- Certification Profile

All reusing the same semantic core.

---

## Plot Registry Question (AgStack vs Self-Managed)

Key design question:

Should we rely on external plot registries (e.g., AgStack) or define a minimal self-managed concept?

Proposed answer:

> Define a minimal, self-managed plot registry concept based on the Semantic Core that can integrate with AgStack or others, but does not depend on them.

---

## Questions DIASCA Should Be Able to Answer

This project aims to propose answers to:

1. What is the minimum data required for EUDR traceability?
2. How can we avoid creating new farmer apps?
3. What is a reusable plot registry?
4. How do we separate data collection tools from data exchange?
5. What is a "data space" in practical terms?
6. How can multiple use cases reuse the same data?

---

## Design Principles

- Small core, many profiles
- Tool-agnostic
- Implementation-friendly
- Field-proven
- Easy to explain visually

---

## Expected Outputs

- Simplified DBML
- Simplified SQL
- Visual diagrams
- Clear markdown documentation
- Reusable exchange profile templates

---

## Target Audience

- DIASCA community
- DPI practitioners
- NGOs implementing traceability
- Software vendors
- Governments

---

## Final Vision

This repository should evolve into:

> A practical reference for how to design agricultural data interoperability **without overengineering**.

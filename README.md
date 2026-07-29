# DIASCA

> **Digital Public Infrastructure for Agricultural Supply Chain Data Exchange**

DIASCA (Data Interoperability for Agricultural Supply Chain Actors) defines a minimal, open data model for traceability, compliance, and sustainability in agricultural supply chains.

## 🎯 What is DIASCA?

DIASCA is a **Minimum Viable DPI** (Digital Public Infrastructure) that enables:

- **Interoperability** – Different systems can exchange data without vendor lock-in
- **Traceability** – Track products from farm to market
- **Compliance** – Support EUDR and other regulatory requirements
- **Sustainability** – Capture farmer livelihoods and environmental metrics

### Philosophy

> Interoperability does **not** require a big data model.  
> It requires a **small shared semantic core** and **clear exchange profiles**.

## 📂 Repository Structure

```
/v2_semantic_core           # Minimal semantic core — start here
    semantic_core.md        # Documentation
    semantic_core.dbml      # DBML source
    semantic_core.sql       # PostgreSQL DDL
    /json_schemas           # Draft 2020-12 JSON Schemas for all 9 entities

/exchange_profiles          # Use-case specific data profiles
    /eudr                   # EU Deforestation Regulation
    /compliance             # Compliance & remediation
    /metrics                # Sustainability metrics

/docs                       # Architecture & Integration documentation
    dpi_architecture_roadmap.md  # API design & event streaming model
    integration_mapping_guide.md # Guide for participating tools

/diasca-node                # Reference Implementation Scaffold
    app/                    # FastAPI monolith (CRUD + Domain Operations)
    alembic/                # Database migrations
    openapi.yaml            # OpenAPI 3.1 Contract

/tools                      # Utilities
    /geojson-validator      # Python library for plot geometry validation

/v1_original_model          # Archive — original comprehensive model (reference only)
```

## 🚀 Quick Start

### View the Data Model

1. **Specification**: Open [`v2_semantic_core/semantic_core.md`](v2_semantic_core/semantic_core.md)
2. **DBML Schema**: View [`v2_semantic_core/semantic_core.dbml`](v2_semantic_core/semantic_core.dbml)

### Apply the Schema

```bash
psql -U user -d dbname -f v2_semantic_core/semantic_core.sql
```

### Use the GeoJSON Validator

```bash
cd tools/geojson-validator
poetry install
poetry run pytest
```

## 🧠 Core Concepts (V2 Semantic Core)

The semantic core has **9 concepts**:

| Concept | Description |
|---------|-------------|
| **Person** | An individual (farmer, agent, auditor, inspector) |
| **Enterprise** | An organization (cooperative, trader, exporter, certifier) |
| **Site** | A physical place (plot, farm, factory, warehouse, port) |
| **Relationship** | Connection between actors and/or sites |
| **Lot** | A traceable unit of product — the central traceability object |
| **Transaction** | A timestamped activity or movement |
| **LotLineage** | Transformation record linking input lots to output lots |
| **Claim** | Statement about any entity (deforestation-free, certified, etc.) |
| **Evidence** | Data supporting a claim |

```
Person / Enterprise ─── Relationship ─── Site
                                           │
                                          Lot ──── Transaction ──── LotLineage
                                           │
                                         Claim ──── Evidence
```

## 📖 Documentation

- [DPI Architecture & Roadmap](docs/dpi_architecture_roadmap.md) – DPI capabilities, OAuth scopes, hybrid API, provenance, & Cloud Run architecture
- [V2 Semantic Core](v2_semantic_core/semantic_core.md) – Minimal 9-concept core specification
- [Architecture Evolution](ARCHITECTURE_EVOLUTION.md) – Rationale and transition from V1 to V2
- [EUDR Exchange Profile](exchange_profiles/eudr/eudr_profile.md) – EU Deforestation Regulation specification
- [Compliance Profile](exchange_profiles/compliance/compliance_profile.md) – Audit & remediation tracking
- [Sustainability Metrics Profile](exchange_profiles/metrics/sustainability_metrics_profile.md) – Socio-economic & ESG indicators
- [GeoJSON Validator](tools/geojson-validator/README.md) – Plot geometry validation tool

<details>
<summary>V1 archive (reference only)</summary>

- [V1 ER Specification](v1_original_model/spec/er-spec.md) – Original comprehensive model
- [Visual Overview (PDF)](v1_original_model/DIASCA%20data%20model%20Layman's%20terms%20-%2020250731.pdf) – Non-technical overview

</details>

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/improvement`)
3. Submit a Pull Request
4. Open Issues for spec changes or questions

## ⚖️ License

MIT License – See [LICENSE](LICENSE)

---

_Maintained by [COSA](https://thecosa.org) – Committee on Sustainability Assessment_

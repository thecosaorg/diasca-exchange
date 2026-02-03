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
/v1_original_model          # Original comprehensive DIASCA model
    /dbml                   # Database Markup Language source + diagram
    /sql                    # MySQL and PostgreSQL DDL
    /spec                   # Full ER specification (774 lines)
    /podcast                # Audio walkthrough

/v2_semantic_core           # Minimal semantic core (in development)
    semantic_core.md        # Documentation
    semantic_core.dbml      # DBML source
    semantic_core.sql       # SQL DDL

/exchange_profiles          # Use-case specific data profiles
    /eudr                   # EU Deforestation Regulation
    /compliance             # Compliance & remediation
    /metrics                # Sustainability metrics

/diagrams                   # Visual documentation
/docs                       # Additional documentation
/tools                      # Utilities
    /geojson-validator      # Python library for plot geometry validation
```

## 🚀 Quick Start

### View the Data Model

1. **ER Specification**: Open [`v1_original_model/spec/er-spec.md`](v1_original_model/spec/er-spec.md)
2. **Visual Diagram**: View [`v1_original_model/dbml/diasca-model.png`](v1_original_model/dbml/diasca-model.png)
3. **Listen**: Play [`v1_original_model/podcast/diasca-data-model-explained.mp3`](v1_original_model/podcast/diasca-data-model-explained.mp3)

### Apply the Schema

```bash
# PostgreSQL
psql -U user -d dbname -f v1_original_model/sql/diasca-schema.psql.sql

# MySQL
mysql -u user -p < v1_original_model/sql/diasca-schema.mysql.sql
```

### Use the GeoJSON Validator

```bash
cd tools/geojson-validator
poetry install
poetry run pytest
```

## 🧠 Core Concepts (V2 Semantic Core)

The minimal semantic core has just **6 concepts**:

| Concept | Description |
|---------|-------------|
| **Site** | A physical place (plot, farm, factory, warehouse) |
| **Actor** | A person or organization |
| **Relationship** | Actor connected to Site |
| **Transaction** | Movement of goods between actors/sites |
| **Claim** | Statement about a site, actor, or transaction |
| **Evidence** | Data supporting a claim |

```
Actor ───── owns/manages ───── Site
Actor ───── transacts with ───── Actor
Transaction ───── involves ───── Site
Claim ───── refers to ───── Site / Actor / Transaction
Evidence ───── supports ───── Claim
```

## 📖 Documentation

- [Architecture Evolution](ARCHITECTURE_EVOLUTION.md) – Project vision and roadmap
- [ER Specification](v1_original_model/spec/er-spec.md) – Complete V1 data model
- [GeoJSON Validator](tools/geojson-validator/README.md) – Tool documentation
- [Visual Overview (PDF)](v1_original_model/DIASCA%20data%20model%20Layman's%20terms%20-%2020250731.pdf) – Non-technical overview

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/improvement`)
3. Submit a Pull Request
4. Open Issues for spec changes or questions

## ⚖️ License

MIT License – See [LICENSE](LICENSE)

---

_Maintained by [COSA](https://thecosa.org) – Committee on Sustainability Assessment_

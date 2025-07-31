# diasca-exchange

> Canonical ER Spec, SQL DDL, DBML, GeoJSON validator, and related assets for DIASCA Data Exchange.

## 📂 Repository Structure

- **dbml/**
    - `diasca-model.dbml` — source for your ER diagram
    - `diasca-model.png` — rendered ER diagram

- **spec/**
    - `er-spec.md` — full **Entity-Relationship Model Documentation** in Markdown (tables, columns, relationships, notes)
    - `json-schema/` — JSON Schema files per entity

- **sql/**
    - `diasca-schema.mysql.sql` — MySQL DDL
    - `diasca-schema.psql.sql` — PostgreSQL DDL

- **geojson-validator/**  
  DIASCA-specific GeoJSON validation library
    - `src/`, `docs/`, `tests/`

- **podcast/**
    - `diasca-data-model-explained.mp3` — Podcast walkthrough

## 🚀 Getting Started

### 1. Clone
   ```bash
   git clone git@github.com:cosaorg/diasca-exchange.git
   cd diasca-exchange
   ```

### 2. View the ER Spec
Open spec/er-spec.md to see the complete data model documentation in Markdown.

### 3. Render the Diagram
- View dbml/diasca-model.png or open dbml/diasca-model.dbml in a DBML tool.

### 4. Apply the Schema

  ```bash
  # MySQL
  mysql -u user -p < sql/diasca-schema.mysql.sql
  
  # PostgreSQL
  psql -U user -d dbname -f sql/diasca-schema.psql.sql
  ```

### 5. GeoJSON Validator

  ```bash
  cd geojson-validator
  pip install .
  ```

### 6. Listen to the Podcast
Play podcast/diasca-data-model-explained.mp3.

## 📖 Documentation
ER Specification: spec/er-spec.md

GeoJSON Validator: geojson-validator/README.md

## 🤝 Contributing
1. Fork
2. Create feature branch
3. Open PR
4. Raise Issues for spec changes

## ⚖️ License
MIT

_Maintained by COSA – Committee on Sustainability Assessment_


-- ============================================================================
-- DIASCA Semantic Core V2 - PostgreSQL DDL
-- ============================================================================
--
-- Minimal semantic core for agricultural supply chain data exchange.
-- 9 core concepts aligned with the Hornbill DIASCA traceability model.
--
-- Philosophy: Interoperability requires a small shared semantic core,
--             not a comprehensive data model.
--
-- Database: PostgreSQL 14+
-- Generated from: semantic_core.dbml
-- See semantic_core.md for full documentation and V1 migration mapping.
-- ============================================================================

CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ============================================================================
-- ENUMS
-- ============================================================================

CREATE TYPE person_role AS ENUM (
    'farmer',       -- Primary agricultural producer
    'field_agent',  -- Field data collector or extension worker
    'auditor',      -- Internal or third-party auditor
    'inspector',    -- Regulatory or certification inspector
    'producer',     -- General producer role
    'buyer',        -- Purchasing agent
    'certifier'     -- Certification body representative
);

CREATE TYPE enterprise_type AS ENUM (
    'cooperative',  -- Farmer cooperative or union
    'processor',    -- Processing facility operator
    'trader',       -- Commodity trader
    'exporter',     -- Export company
    'importer',     -- Import company
    'retailer',     -- Retail business
    'certifier',    -- Certification body
    'government',   -- Government agency
    'ngo'           -- Non-governmental organization
);

CREATE TYPE site_type AS ENUM (
    'plot',                 -- Agricultural land parcel
    'farm',                 -- Collection of plots under common management
    'factory',              -- Manufacturing or processing facility
    'warehouse',            -- Storage facility
    'processing_facility',  -- Transformation/processing site
    'distribution_center',  -- Logistics and distribution hub
    'office',               -- Administrative location
    'port'                  -- Import/export point
);

CREATE TYPE relationship_type AS ENUM (
    'employs',    -- Enterprise employs person
    'owns',       -- Actor owns site
    'manages',    -- Actor manages site (without ownership)
    'member_of',  -- Person is member of cooperative/group
    'supplies',   -- Enterprise supplies to another enterprise
    'certifies',  -- Enterprise certifies another actor or site
    'audits'      -- Person or enterprise audits another actor or site
);

CREATE TYPE product_type AS ENUM (
    'raw_cherry',       -- Freshly harvested coffee cherries
    'parchment',        -- Wet-processed parchment coffee
    'green_coffee',     -- Milled green coffee beans
    'roasted_coffee',   -- Roasted coffee
    'cocoa_fresh',      -- Fresh cocoa pods/beans
    'cocoa_dried',      -- Dried cocoa beans
    'cocoa_processed',  -- Processed cocoa (butter, powder, liquor)
    'other'             -- Other commodity
);

CREATE TYPE lot_unit AS ENUM (
    'kg',     -- Kilograms
    'mt',     -- Metric tonnes
    'bags',   -- Standard export bags
    'liters'  -- Litres
);

CREATE TYPE transaction_type AS ENUM (
    'harvest',       -- Harvesting from plot
    'receive',       -- Receiving a lot at a facility
    'aggregate',     -- Combining lots at a collection point
    'process',       -- Transformation of product (triggers LotLineage)
    'store',         -- Storage event
    'transfer',      -- Physical movement between sites (GS1: Shipping/Receiving)
    'transport',     -- In-transit movement
    'sale',          -- Commercial transaction
    'inspection',    -- Quality check event (GS1: Inspection)
    'certification', -- Certification event
    'export_tx',     -- Cross-border export
    'import_tx'      -- Cross-border import
);

CREATE TYPE transformation_type AS ENUM (
    'split',    -- One lot divided into multiple output lots
    'merge',    -- Multiple lots combined into one
    'process',  -- Chemical or physical transformation (e.g., wet milling)
    'blend',    -- Homogeneous mixing of lots
    'package',  -- Repackaging into new lot units
    'grade'     -- Separation by quality grade
);

CREATE TYPE claim_type AS ENUM (
    'certification',       -- Certification status (organic, fair trade, Rainforest Alliance)
    'quality',             -- Quality measurement or grade
    'compliance',          -- Regulatory compliance status (EUDR, etc.)
    'deforestation_free',  -- EUDR deforestation-free assertion
    'risk',                -- Risk assessment (deforestation, labor, climate)
    'sustainability',      -- Sustainability metric or indicator
    'survey_response',     -- Survey or questionnaire answer
    'indicator',           -- KPI or performance indicator value
    'observation'          -- Field observation or note
);

CREATE TYPE subject_type AS ENUM (
    'person',       -- Claim about an individual
    'enterprise',   -- Claim about an organization
    'site',         -- Claim about a physical location
    'lot',          -- Claim about a traceable product unit
    'transaction',  -- Claim about an activity or movement
    'claim'         -- Claim about another claim (nested)
);

CREATE TYPE value_type AS ENUM (
    'string',
    'number',
    'boolean',
    'date',
    'json'
);

CREATE TYPE claim_status AS ENUM (
    'pending',   -- Awaiting verification
    'verified',  -- Confirmed by evidence
    'disputed',  -- Under review or challenged
    'expired',   -- No longer valid (past valid_until)
    'revoked'    -- Withdrawn or cancelled
);

CREATE TYPE evidence_type AS ENUM (
    'document',          -- PDF, certificate, contract
    'image',             -- Photo evidence
    'satellite',         -- Satellite imagery analysis
    'audit_report',      -- Third-party audit report
    'lab_result',        -- Laboratory analysis
    'sensor_data',       -- IoT or sensor readings
    'gps_trace',         -- GPS track data
    'survey',            -- Survey response data
    'self_declaration',  -- Self-reported data
    'blockchain'         -- Blockchain attestation
);

-- ============================================================================
-- TABLE 1: ENTERPRISE (created before person — person has FK to enterprise)
-- ============================================================================
-- An organization participating in the supply chain.
-- Maps to: V1 Enterprises table
-- ============================================================================

CREATE TABLE enterprise (
    enterprise_id   UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    legal_name      VARCHAR(200) NOT NULL,
    enterprise_type enterprise_type NOT NULL,
    registration_id VARCHAR(100),  -- Legal/national identifier (country-specific)
    legal_address   TEXT,
    tax_id          VARCHAR(100),  -- National tax identifier (TIN, VAT, etc.)
    gln             VARCHAR(13),   -- GS1 Global Location Number (13 digits)

    parent_enterprise_id UUID REFERENCES enterprise(enterprise_id),

    metadata   JSONB,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP,

    CONSTRAINT enterprise_gln_format CHECK (gln IS NULL OR LENGTH(gln) = 13)
);

CREATE INDEX idx_enterprise_type   ON enterprise(enterprise_type);
CREATE INDEX idx_enterprise_name   ON enterprise(legal_name);
CREATE INDEX idx_enterprise_tax_id ON enterprise(tax_id);
CREATE INDEX idx_enterprise_gln    ON enterprise(gln);
CREATE INDEX idx_enterprise_reg_id ON enterprise(registration_id);
CREATE INDEX idx_enterprise_parent ON enterprise(parent_enterprise_id);

COMMENT ON TABLE enterprise IS 'Organizations in the supply chain: cooperatives, processors, traders, exporters, certifiers.';

-- ============================================================================
-- TABLE 2: PERSON
-- ============================================================================
-- An individual actor participating in the supply chain.
-- Maps to: V1 People table
-- ============================================================================

CREATE TABLE person (
    person_id   UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name        VARCHAR(100) NOT NULL,
    role        person_role  NOT NULL,
    email       VARCHAR(255),
    phone       VARCHAR(50),

    linked_enterprise_id UUID REFERENCES enterprise(enterprise_id),

    metadata   JSONB,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP,

    CONSTRAINT person_email_format CHECK (
        email IS NULL OR email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'
    )
);

CREATE INDEX idx_person_role       ON person(role);
CREATE INDEX idx_person_enterprise ON person(linked_enterprise_id);
CREATE INDEX idx_person_name       ON person(name);

COMMENT ON TABLE person IS 'Individual actors: farmers, field agents, auditors, inspectors. Formal employment/membership tracked via relationship table.';

-- ============================================================================
-- TABLE 3: SITE
-- ============================================================================
-- A physical location where actors operate, products originate, or events occur.
-- Maps to: V1 Sites + geographic fields from BatchesLotsSerials
-- ============================================================================

CREATE TABLE site (
    site_id   UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    name      VARCHAR(100) NOT NULL,
    type      site_type    NOT NULL,

    parent_id            UUID REFERENCES site(site_id),
    owner_person_id      UUID,  -- FK to person (added after person created — see below)
    owner_enterprise_id  UUID,  -- FK to enterprise (added below)

    address   TEXT,
    latitude  DECIMAL(9,6),   -- GPS latitude (-90 to 90)
    longitude DECIMAL(9,6),   -- GPS longitude (-180 to 180)
    altitude  FLOAT,

    geometry  JSONB,           -- GeoJSON polygon (required for EUDR plots > 4ha)

    size      DECIMAL(10,4),
    size_unit VARCHAR(20) DEFAULT 'hectares',

    country   VARCHAR(2),      -- ISO 3166-1 alpha-2 — required for EUDR
    region    VARCHAR(100),

    is_headquarters BOOLEAN DEFAULT FALSE,

    metadata   JSONB,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP,

    CONSTRAINT site_latitude_range  CHECK (latitude  IS NULL OR (latitude  >= -90  AND latitude  <= 90)),
    CONSTRAINT site_longitude_range CHECK (longitude IS NULL OR (longitude >= -180 AND longitude <= 180)),
    CONSTRAINT site_country_format  CHECK (country IS NULL OR LENGTH(country) = 2)
);

CREATE INDEX idx_site_owner_person     ON site(owner_person_id);
CREATE INDEX idx_site_owner_enterprise ON site(owner_enterprise_id);
CREATE INDEX idx_site_type             ON site(type);
CREATE INDEX idx_site_country          ON site(country);
CREATE INDEX idx_site_coordinates      ON site(latitude, longitude);
CREATE INDEX idx_site_parent           ON site(parent_id);

COMMENT ON TABLE site IS 'Physical locations: plots, farms, factories, warehouses, ports. For EUDR: country required; lat/lon or geometry required.';

-- Add FKs now that both person and enterprise exist
ALTER TABLE site
    ADD CONSTRAINT site_owner_person_fk
        FOREIGN KEY (owner_person_id) REFERENCES person(person_id),
    ADD CONSTRAINT site_owner_enterprise_fk
        FOREIGN KEY (owner_enterprise_id) REFERENCES enterprise(enterprise_id);

-- ============================================================================
-- TABLE 4: RELATIONSHIP
-- ============================================================================
-- Connections between actors and/or sites.
-- Maps to: V1 EnterprisePeople + implicit site ownership relationships
-- ============================================================================

CREATE TABLE relationship (
    relationship_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    type            relationship_type NOT NULL,

    source_person_id     UUID REFERENCES person(person_id),
    source_enterprise_id UUID REFERENCES enterprise(enterprise_id),
    target_person_id     UUID REFERENCES person(person_id),
    target_enterprise_id UUID REFERENCES enterprise(enterprise_id),
    site_id              UUID REFERENCES site(site_id),

    role       VARCHAR(50),
    start_date DATE,
    end_date   DATE,

    metadata   JSONB,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP,

    CONSTRAINT relationship_has_source CHECK (
        source_person_id IS NOT NULL OR source_enterprise_id IS NOT NULL
    ),
    CONSTRAINT relationship_has_target CHECK (
        target_person_id IS NOT NULL OR target_enterprise_id IS NOT NULL OR site_id IS NOT NULL
    ),
    CONSTRAINT relationship_dates_valid CHECK (
        end_date IS NULL OR start_date IS NULL OR end_date >= start_date
    )
);

CREATE INDEX idx_rel_source_person     ON relationship(source_person_id);
CREATE INDEX idx_rel_source_enterprise ON relationship(source_enterprise_id);
CREATE INDEX idx_rel_target_person     ON relationship(target_person_id);
CREATE INDEX idx_rel_target_enterprise ON relationship(target_enterprise_id);
CREATE INDEX idx_rel_site              ON relationship(site_id);
CREATE INDEX idx_rel_type              ON relationship(type);

COMMENT ON TABLE relationship IS 'Connections between actors and sites. Source must be one person or enterprise. Target must be at least one person, enterprise, or site.';

-- ============================================================================
-- TABLE 5: LOT
-- ============================================================================
-- The traceable unit of product. Central object for agricultural traceability.
-- Maps to: V1 BatchesLotsSerials
-- ============================================================================

CREATE TABLE lot (
    lot_id       UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    product_type product_type NOT NULL,

    origin_site_id UUID REFERENCES site(site_id) NOT NULL,  -- Must be type=plot

    harvest_date     DATE,
    harvest_date_end DATE,

    quantity DECIMAL(18,4) NOT NULL,
    unit     lot_unit      NOT NULL,

    owner_enterprise_id UUID REFERENCES enterprise(enterprise_id) NOT NULL,

    batch_number VARCHAR(100),
    disposition  VARCHAR(50),  -- GS1 CBV: active, in_progress, quarantined

    metadata   JSONB,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP,

    CONSTRAINT lot_quantity_positive         CHECK (quantity > 0),
    CONSTRAINT lot_harvest_dates_valid       CHECK (harvest_date_end IS NULL OR harvest_date IS NULL OR harvest_date_end >= harvest_date)
);

CREATE INDEX idx_lot_product_type ON lot(product_type);
CREATE INDEX idx_lot_origin_site  ON lot(origin_site_id);
CREATE INDEX idx_lot_owner        ON lot(owner_enterprise_id);
CREATE INDEX idx_lot_harvest_date ON lot(harvest_date);
CREATE INDEX idx_lot_batch_number ON lot(batch_number);

COMMENT ON TABLE lot IS 'The central traceability object. Tracks a commodity unit from harvest through all transformations to export. origin_site_id must reference a plot.';

-- ============================================================================
-- TABLE 6: TRANSACTION
-- ============================================================================
-- A timestamped activity, movement, or commercial exchange.
-- Maps to: V1 Events + BusinessTransactions + Products
-- ============================================================================

CREATE TABLE transaction (
    transaction_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    type           transaction_type NOT NULL,
    description    VARCHAR(200),
    "timestamp"    TIMESTAMP NOT NULL,

    source_enterprise_id UUID REFERENCES enterprise(enterprise_id),
    target_enterprise_id UUID REFERENCES enterprise(enterprise_id),

    source_site_id UUID REFERENCES site(site_id),
    target_site_id UUID REFERENCES site(site_id),

    lot_id UUID REFERENCES lot(lot_id),  -- Preferred over embedded product fields

    -- Embedded product fields (for systems without discrete Lot entities)
    product_name     VARCHAR(100),
    product_sku      VARCHAR(100),
    product_gtin     VARCHAR(14),   -- GS1 Global Trade Item Number
    product_category VARCHAR(100),
    quantity         DECIMAL(18,2),
    unit             VARCHAR(50),
    production_date  DATE,
    expiry_date      DATE,

    sales_order_ref    VARCHAR(50),
    purchase_order_ref VARCHAR(50),

    metadata   JSONB,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP,

    CONSTRAINT transaction_quantity_positive CHECK (quantity IS NULL OR quantity > 0),
    CONSTRAINT transaction_dates_valid       CHECK (expiry_date IS NULL OR production_date IS NULL OR expiry_date >= production_date),
    CONSTRAINT transaction_gtin_format       CHECK (product_gtin IS NULL OR LENGTH(product_gtin) IN (8, 12, 13, 14))
);

CREATE INDEX idx_transaction_type                ON transaction(type);
CREATE INDEX idx_transaction_timestamp           ON transaction("timestamp");
CREATE INDEX idx_transaction_source_enterprise   ON transaction(source_enterprise_id);
CREATE INDEX idx_transaction_target_enterprise   ON transaction(target_enterprise_id);
CREATE INDEX idx_transaction_source_site         ON transaction(source_site_id);
CREATE INDEX idx_transaction_target_site         ON transaction(target_site_id);
CREATE INDEX idx_transaction_lot                 ON transaction(lot_id);
CREATE INDEX idx_transaction_gtin                ON transaction(product_gtin);

COMMENT ON TABLE transaction IS 'All supply chain activities. When type=process, create a lot_lineage record. Embedded product fields for systems without discrete lots.';

-- ============================================================================
-- TABLE 7: LOT_LINEAGE
-- ============================================================================
-- Transformation records between lots.
-- Maps to: New (EUDR chain-of-custody requirement)
-- ============================================================================

CREATE TABLE lot_lineage (
    lineage_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    event_id      UUID REFERENCES transaction(transaction_id) NOT NULL,
    input_lot_id  UUID REFERENCES lot(lot_id) NOT NULL,
    output_lot_id UUID REFERENCES lot(lot_id) NOT NULL,

    input_qty  DECIMAL(18,4) NOT NULL,
    output_qty DECIMAL(18,4) NOT NULL,

    transformation_type transformation_type NOT NULL,
    conversion_factor   DECIMAL(10,6),  -- output_qty / input_qty

    metadata   JSONB,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),

    CONSTRAINT lot_lineage_input_qty_positive  CHECK (input_qty  > 0),
    CONSTRAINT lot_lineage_output_qty_positive CHECK (output_qty > 0),
    CONSTRAINT lot_lineage_different_lots      CHECK (input_lot_id <> output_lot_id)
);

CREATE INDEX idx_lineage_event        ON lot_lineage(event_id);
CREATE INDEX idx_lineage_input_lot    ON lot_lineage(input_lot_id);
CREATE INDEX idx_lineage_output_lot   ON lot_lineage(output_lot_id);
CREATE INDEX idx_lineage_event_input  ON lot_lineage(event_id, input_lot_id);
CREATE INDEX idx_lineage_event_output ON lot_lineage(event_id, output_lot_id);

COMMENT ON TABLE lot_lineage IS 'Transformation records between lots. Validation: sum(input_qty) >= sum(output_qty) per event_id. Split: 1 input + N outputs. Merge: N inputs + 1 output.';

-- ============================================================================
-- TABLE 8: CLAIM
-- ============================================================================
-- A statement, assertion, or measurement about any entity.
-- Maps to: V1 Attributes + Observations + partial Activities
-- ============================================================================

CREATE TABLE claim (
    claim_id     UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    type         claim_type   NOT NULL,
    subject_type subject_type NOT NULL,
    subject_id   UUID         NOT NULL,

    key        VARCHAR(100) NOT NULL,
    value      TEXT,
    value_type value_type DEFAULT 'string',
    unit       VARCHAR(50),
    category   VARCHAR(100),

    status           claim_status DEFAULT 'pending',
    confidence_score DECIMAL(3,2),

    claim_date  DATE,
    valid_from  DATE,
    valid_until DATE,

    source      VARCHAR(200),
    source_type VARCHAR(50),

    metadata   JSONB,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP,

    CONSTRAINT claim_confidence_range CHECK (confidence_score IS NULL OR (confidence_score >= 0 AND confidence_score <= 1)),
    CONSTRAINT claim_validity_dates   CHECK (valid_until IS NULL OR valid_from IS NULL OR valid_until >= valid_from)
);

CREATE INDEX idx_claim_type             ON claim(type);
CREATE INDEX idx_claim_subject          ON claim(subject_type, subject_id);
CREATE INDEX idx_claim_key              ON claim(key);
CREATE INDEX idx_claim_category         ON claim(category);
CREATE INDEX idx_claim_status           ON claim(status);
CREATE INDEX idx_claim_date             ON claim(claim_date);
CREATE INDEX idx_claim_valid_until      ON claim(valid_until);
CREATE INDEX idx_claim_subject_key_date ON claim(subject_id, key, claim_date);

COMMENT ON TABLE claim IS 'Assertions about any entity (person, enterprise, site, lot, transaction, or claim). Use for certifications, EUDR compliance, sustainability metrics, survey responses.';

-- ============================================================================
-- TABLE 9: EVIDENCE
-- ============================================================================
-- Data, documents, or references that support a claim.
-- Maps to: V1 DataSource + Observations + AuditAttributesObservations
-- ============================================================================

CREATE TABLE evidence (
    evidence_id UUID PRIMARY KEY DEFAULT gen_random_uuid(),

    claim_id        UUID REFERENCES claim(claim_id) NOT NULL,
    type            evidence_type NOT NULL,
    source_name     VARCHAR(200)  NOT NULL,
    source_provider VARCHAR(200),
    description     TEXT,

    url       TEXT,
    file_hash VARCHAR(64),  -- SHA-256 hash for integrity verification

    confidence_score DECIMAL(3,2),

    observation_date DATE,
    submission_date  DATE,

    observation_data JSONB,

    metadata   JSONB,
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP,

    CONSTRAINT evidence_confidence_range CHECK (confidence_score IS NULL OR (confidence_score >= 0 AND confidence_score <= 1)),
    CONSTRAINT evidence_hash_format      CHECK (file_hash IS NULL OR LENGTH(file_hash) = 64)
);

CREATE INDEX idx_evidence_claim            ON evidence(claim_id);
CREATE INDEX idx_evidence_type             ON evidence(type);
CREATE INDEX idx_evidence_provider         ON evidence(source_provider);
CREATE INDEX idx_evidence_observation_date ON evidence(observation_date);
CREATE INDEX idx_evidence_claim_type       ON evidence(claim_id, type);

COMMENT ON TABLE evidence IS 'Supporting data for claims. Store files externally, reference via url. Use file_hash (SHA-256) to verify integrity.';

-- ============================================================================
-- TRIGGER: Auto-update updated_at timestamp
-- ============================================================================

CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER enterprise_updated_at    BEFORE UPDATE ON enterprise    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER person_updated_at        BEFORE UPDATE ON person        FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER site_updated_at          BEFORE UPDATE ON site          FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER relationship_updated_at  BEFORE UPDATE ON relationship  FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER lot_updated_at           BEFORE UPDATE ON lot           FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER transaction_updated_at   BEFORE UPDATE ON transaction   FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER claim_updated_at         BEFORE UPDATE ON claim         FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER evidence_updated_at      BEFORE UPDATE ON evidence      FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- ============================================================================
-- GRANTS (adjust role names as needed)
-- ============================================================================
-- Uncomment and modify these for your deployment:
--
-- GRANT SELECT, INSERT, UPDATE, DELETE ON ALL TABLES IN SCHEMA public TO diasca_app;
-- GRANT USAGE ON ALL SEQUENCES IN SCHEMA public TO diasca_app;

-- ============================================================================
-- END OF DIASCA SEMANTIC CORE V2 DDL
-- ============================================================================

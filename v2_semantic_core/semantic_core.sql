-- ============================================================================
-- DIASCA Semantic Core V2 - PostgreSQL DDL
-- ============================================================================
-- 
-- This SQL DDL creates the minimal semantic core for agricultural supply chain
-- data exchange. It reduces 17+ V1 tables to 6 core concepts while preserving
-- essential traceability and compliance information.
--
-- Philosophy: Interoperability requires a small shared semantic core,
--             not a comprehensive data model.
--
-- Database: PostgreSQL 14+
-- Generated from: semantic_core.dbml
-- See semantic_core.md for full documentation and V1 migration mapping.
-- ============================================================================

-- Enable UUID generation
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ============================================================================
-- ENUMS - Controlled vocabularies for type fields
-- ============================================================================

-- Site classification - where things happen
CREATE TYPE site_type AS ENUM (
    'plot',                  -- Agricultural land parcel
    'farm',                  -- Collection of plots under common management
    'factory',               -- Manufacturing or processing facility
    'warehouse',             -- Storage facility
    'processing_facility',   -- Transformation/processing site
    'distribution_center',   -- Logistics and distribution hub
    'office',                -- Administrative location
    'port'                   -- Import/export point
);

-- Actor classification - who participates
CREATE TYPE actor_type AS ENUM (
    'person',      -- Individual (farmer, inspector, agent)
    'enterprise',  -- Legal entity (company, cooperative, NGO)
    'government'   -- Government agency or regulatory body
);

-- Relationship classification - how entities connect
CREATE TYPE relationship_type AS ENUM (
    'employs',     -- Enterprise employs person
    'owns',        -- Actor owns site
    'manages',     -- Actor manages site (without ownership)
    'member_of',   -- Person is member of cooperative/group
    'supplies',    -- Actor supplies to another actor
    'certifies',   -- Actor certifies another actor
    'audits'       -- Actor audits another actor
);

-- Transaction classification - what movements occur
-- Aligned with GS1 EPCIS event types where applicable
CREATE TYPE transaction_type AS ENUM (
    'harvest',       -- Harvesting from plot
    'processing',    -- Transformation of product (GS1: Transformation)
    'transfer',      -- Physical movement between sites (GS1: Shipping/Receiving)
    'sale',          -- Commercial transaction
    'inspection',    -- Quality check event (GS1: Inspection)
    'certification', -- Certification event
    'import_tx',     -- Cross-border import
    'export_tx'      -- Cross-border export
);

-- Claim classification - what assertions are made
CREATE TYPE claim_type AS ENUM (
    'certification',     -- Certification status (organic, fair trade, Rainforest Alliance)
    'quality',           -- Quality measurement or grade
    'compliance',        -- Regulatory compliance status (EUDR, etc.)
    'risk',              -- Risk assessment (deforestation, labor, climate)
    'sustainability',    -- Sustainability metric or indicator
    'survey_response',   -- Survey or questionnaire answer
    'indicator',         -- KPI or performance indicator value
    'observation'        -- Field observation or note
);

-- What entity a claim refers to
CREATE TYPE subject_type AS ENUM (
    'site',        -- Claim about a physical location
    'actor',       -- Claim about a person or organization
    'transaction', -- Claim about a movement or exchange
    'claim'        -- Claim about another claim (nested)
);

-- Data type of claim values
CREATE TYPE value_type AS ENUM (
    'string',
    'number',
    'boolean',
    'date',
    'json'
);

-- Claim lifecycle status
CREATE TYPE claim_status AS ENUM (
    'pending',   -- Awaiting verification
    'verified',  -- Confirmed by evidence
    'disputed',  -- Under review or challenged
    'expired',   -- No longer valid (past valid_until)
    'revoked'    -- Withdrawn or cancelled
);

-- Evidence classification - how claims are supported
CREATE TYPE evidence_type AS ENUM (
    'document',          -- PDF, certificate, contract
    'image',             -- Photo evidence
    'satellite',         -- Satellite imagery analysis
    'audit_report',      -- Third-party audit report
    'lab_result',        -- Laboratory analysis
    'sensor_data',       -- IoT or sensor readings
    'survey',            -- Survey response data
    'self_declaration',  -- Self-reported data
    'blockchain'         -- Blockchain attestation
);

-- ============================================================================
-- TABLE 1: SITE
-- ============================================================================
-- A physical location where actors operate, products originate, or events occur.
-- Maps to: V1 Sites table + geographic fields from BatchesLotsSerials
-- EUDR Note: For compliance, latitude/longitude OR geometry required, plus country.
-- ============================================================================

CREATE TABLE site (
    -- Primary key
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Core fields
    name VARCHAR(100) NOT NULL,
    type site_type NOT NULL,
    
    -- Hierarchy
    parent_id UUID REFERENCES site(id),
    owner_actor_id UUID,  -- FK added after actor table created
    
    -- Location - address
    address TEXT,
    
    -- Location - coordinates (EUDR requirement)
    latitude DECIMAL(9,6),   -- GPS latitude (-90 to 90) - required for EUDR if no geometry
    longitude DECIMAL(9,6),  -- GPS longitude (-180 to 180) - required for EUDR if no geometry
    altitude FLOAT,          -- Elevation in meters above sea level
    
    -- Location - polygon for complex shapes (EUDR requirement for plots > 4ha)
    geometry JSONB,  -- GeoJSON geometry for plot polygons
    
    -- Size
    size DECIMAL(10,4),            -- Area measurement (typically hectares)
    size_unit VARCHAR(20) DEFAULT 'hectares',
    
    -- Administrative location (EUDR requirement)
    country VARCHAR(2),       -- ISO 3166-1 alpha-2 country code - required for EUDR
    region VARCHAR(100),      -- Subnational region or administrative area
    
    -- Flags
    is_headquarters BOOLEAN DEFAULT FALSE,
    
    -- Extensibility
    metadata JSONB,
    
    -- Audit fields
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP,
    
    -- Constraints
    CONSTRAINT site_latitude_range CHECK (latitude IS NULL OR (latitude >= -90 AND latitude <= 90)),
    CONSTRAINT site_longitude_range CHECK (longitude IS NULL OR (longitude >= -180 AND longitude <= 180)),
    CONSTRAINT site_country_format CHECK (country IS NULL OR LENGTH(country) = 2)
);

-- Site indexes
CREATE INDEX idx_site_owner ON site(owner_actor_id);
CREATE INDEX idx_site_type ON site(type);
CREATE INDEX idx_site_country ON site(country);
CREATE INDEX idx_site_coordinates ON site(latitude, longitude);
CREATE INDEX idx_site_parent ON site(parent_id);

COMMENT ON TABLE site IS 'Physical locations in the supply chain: plots, farms, factories, warehouses. For EUDR compliance: country required; latitude/longitude OR geometry required.';

-- ============================================================================
-- TABLE 2: ACTOR
-- ============================================================================
-- A person or organization participating in the supply chain.
-- Maps to: V1 People + Enterprises tables (unified with type discriminator)
-- ============================================================================

CREATE TABLE actor (
    -- Primary key
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Type discriminator
    type actor_type NOT NULL,
    
    -- Core fields
    name VARCHAR(100) NOT NULL,
    role VARCHAR(50),  -- Function in supply chain (producer, buyer, certifier, etc.)
    
    -- Contact information
    email VARCHAR(255),
    phone VARCHAR(50),
    
    -- Enterprise-specific fields (when type = enterprise)
    legal_address TEXT,
    tax_id VARCHAR(100),     -- National tax identifier (TIN, VAT number, etc.)
    gln VARCHAR(13),         -- GS1 Global Location Number (exactly 13 digits)
    
    -- Hierarchy (for cooperatives, subsidiaries)
    parent_actor_id UUID REFERENCES actor(id),
    
    -- Extensibility
    metadata JSONB,
    
    -- Audit fields
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP,
    
    -- Constraints
    CONSTRAINT actor_gln_format CHECK (gln IS NULL OR LENGTH(gln) = 13),
    CONSTRAINT actor_email_format CHECK (email IS NULL OR email ~* '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$')
);

-- Actor indexes
CREATE INDEX idx_actor_type ON actor(type);
CREATE INDEX idx_actor_name ON actor(name);
CREATE INDEX idx_actor_tax_id ON actor(tax_id);
CREATE INDEX idx_actor_gln ON actor(gln);
CREATE INDEX idx_actor_parent ON actor(parent_actor_id);

COMMENT ON TABLE actor IS 'People and organizations in the supply chain. Use type to distinguish: person (farmers, inspectors), enterprise (companies, cooperatives), government (regulatory bodies).';

-- Add FK from site to actor (now that actor exists)
ALTER TABLE site ADD CONSTRAINT site_owner_actor_fk 
    FOREIGN KEY (owner_actor_id) REFERENCES actor(id);

-- ============================================================================
-- TABLE 3: RELATIONSHIP
-- ============================================================================
-- Connections between actors and/or sites.
-- Maps to: V1 EnterprisePeople + implicit site ownership relationships
-- ============================================================================

CREATE TABLE relationship (
    -- Primary key
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Relationship type
    type relationship_type NOT NULL,
    
    -- Participants (at least one actor and optionally a target actor or site)
    source_actor_id UUID REFERENCES actor(id),
    target_actor_id UUID REFERENCES actor(id),
    site_id UUID REFERENCES site(id),
    
    -- Role specification
    role VARCHAR(50),  -- Specific role within the relationship (e.g., "manager", "board member")
    
    -- Temporal bounds
    start_date DATE,   -- When the relationship began
    end_date DATE,     -- When the relationship ended (null if ongoing)
    
    -- Extensibility
    metadata JSONB,
    
    -- Audit fields
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP,
    
    -- Constraints
    CONSTRAINT relationship_has_source CHECK (source_actor_id IS NOT NULL),
    CONSTRAINT relationship_has_target CHECK (target_actor_id IS NOT NULL OR site_id IS NOT NULL),
    CONSTRAINT relationship_dates_valid CHECK (end_date IS NULL OR start_date IS NULL OR end_date >= start_date)
);

-- Relationship indexes
CREATE INDEX idx_relationship_source_actor ON relationship(source_actor_id);
CREATE INDEX idx_relationship_target_actor ON relationship(target_actor_id);
CREATE INDEX idx_relationship_site ON relationship(site_id);
CREATE INDEX idx_relationship_type ON relationship(type);
CREATE INDEX idx_relationship_actors_type ON relationship(source_actor_id, target_actor_id, type);
CREATE INDEX idx_relationship_actor_site_type ON relationship(source_actor_id, site_id, type);

COMMENT ON TABLE relationship IS 'Connections between actors and sites. Patterns: employs (enterprise→person), owns/manages (actor→site), supplies (actor→actor).';

-- ============================================================================
-- TABLE 4: TRANSACTION
-- ============================================================================
-- Movement of goods, products, or value between actors/sites.
-- Maps to: V1 Events + BusinessTransactions + Products + BatchesLotsSerials
-- Note: Product and batch info denormalized for simpler querying and exchange.
-- ============================================================================

CREATE TABLE transaction (
    -- Primary key
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Transaction type
    type transaction_type NOT NULL,
    description VARCHAR(200),
    
    -- When
    "timestamp" TIMESTAMP NOT NULL,  -- When the transaction occurred
    
    -- Who (actors involved)
    source_actor_id UUID REFERENCES actor(id),
    target_actor_id UUID REFERENCES actor(id),
    
    -- Where (sites involved)
    source_site_id UUID REFERENCES site(id),
    target_site_id UUID REFERENCES site(id),
    origin_site_id UUID REFERENCES site(id),  -- Original production site (plot of origin)
    
    -- What - Product information (denormalized from V1 Products)
    product_name VARCHAR(100),
    product_sku VARCHAR(100),
    product_gtin VARCHAR(14),       -- GS1 Global Trade Item Number
    product_category VARCHAR(100),
    
    -- What - Batch information (denormalized from V1 BatchesLotsSerials)
    batch_number VARCHAR(100),
    quantity DECIMAL(18,2),
    unit VARCHAR(50),
    production_date DATE,
    expiry_date DATE,
    
    -- Commercial references
    sales_order_ref VARCHAR(50),
    purchase_order_ref VARCHAR(50),
    
    -- Status (GS1 CBV disposition)
    disposition VARCHAR(50),  -- Current status: active, in_progress, quarantined
    
    -- Extensibility
    metadata JSONB,
    
    -- Audit fields
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP,
    
    -- Constraints
    CONSTRAINT transaction_quantity_positive CHECK (quantity IS NULL OR quantity > 0),
    CONSTRAINT transaction_dates_valid CHECK (expiry_date IS NULL OR production_date IS NULL OR expiry_date >= production_date),
    CONSTRAINT transaction_gtin_format CHECK (product_gtin IS NULL OR LENGTH(product_gtin) IN (8, 12, 13, 14))
);

-- Transaction indexes
CREATE INDEX idx_transaction_type ON transaction(type);
CREATE INDEX idx_transaction_timestamp ON transaction("timestamp");
CREATE INDEX idx_transaction_source_actor ON transaction(source_actor_id);
CREATE INDEX idx_transaction_target_actor ON transaction(target_actor_id);
CREATE INDEX idx_transaction_source_site ON transaction(source_site_id);
CREATE INDEX idx_transaction_target_site ON transaction(target_site_id);
CREATE INDEX idx_transaction_origin_site ON transaction(origin_site_id);
CREATE INDEX idx_transaction_batch ON transaction(batch_number);
CREATE INDEX idx_transaction_gtin ON transaction(product_gtin);
CREATE INDEX idx_transaction_actors_time ON transaction(source_actor_id, target_actor_id, "timestamp");

COMMENT ON TABLE transaction IS 'Movement of goods or value. Product and batch info embedded for simpler exchange. Types aligned with GS1 EPCIS.';

-- ============================================================================
-- TABLE 5: CLAIM
-- ============================================================================
-- A statement, assertion, or measurement about any entity.
-- Maps to: V1 Attributes + Observations + partial Activities
-- This is the primary mechanism for capturing certifications, compliance,
-- sustainability metrics, and other assertions.
-- ============================================================================

CREATE TABLE claim (
    -- Primary key
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Claim classification
    type claim_type NOT NULL,
    
    -- Subject - what this claim is about
    subject_type subject_type NOT NULL,
    subject_id UUID NOT NULL,  -- ID of the entity this claim is about
    
    -- Claim content
    key VARCHAR(100) NOT NULL,  -- Claim identifier (e.g., "organic_certified", "deforestation_risk")
    value TEXT,                  -- Claim value - interpretation depends on value_type
    value_type value_type DEFAULT 'string',
    unit VARCHAR(50),            -- Unit of measurement (for numeric values)
    category VARCHAR(100),       -- Logical grouping (e.g., "environmental", "social")
    
    -- Claim status and confidence
    status claim_status DEFAULT 'pending',
    confidence_score DECIMAL(3,2),  -- Confidence level 0.00-1.00
    
    -- Temporal information
    claim_date DATE,       -- Date the claim applies to or was observed
    valid_from DATE,       -- Start of validity period
    valid_until DATE,      -- End of validity period
    
    -- Source tracking
    source VARCHAR(200),       -- Origin of the claim
    source_type VARCHAR(50),   -- Type of source (auditor, satellite, self-reported)
    
    -- Extensibility
    metadata JSONB,
    
    -- Audit fields
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP,
    
    -- Constraints
    CONSTRAINT claim_confidence_range CHECK (confidence_score IS NULL OR (confidence_score >= 0 AND confidence_score <= 1)),
    CONSTRAINT claim_validity_dates CHECK (valid_until IS NULL OR valid_from IS NULL OR valid_until >= valid_from)
);

-- Claim indexes
CREATE INDEX idx_claim_type ON claim(type);
CREATE INDEX idx_claim_subject ON claim(subject_type, subject_id);
CREATE INDEX idx_claim_key ON claim(key);
CREATE INDEX idx_claim_category ON claim(category);
CREATE INDEX idx_claim_status ON claim(status);
CREATE INDEX idx_claim_date ON claim(claim_date);
CREATE INDEX idx_claim_valid_until ON claim(valid_until);
CREATE INDEX idx_claim_subject_key_date ON claim(subject_id, key, claim_date);

COMMENT ON TABLE claim IS 'Assertions about any entity. Use for certifications, compliance status, sustainability metrics, survey responses. Claims can reference sites, actors, transactions, or other claims.';

-- ============================================================================
-- TABLE 6: EVIDENCE
-- ============================================================================
-- Data, documents, or references that support a claim.
-- Maps to: V1 DataSource + Observations + AuditAttributesObservations
-- ============================================================================

CREATE TABLE evidence (
    -- Primary key
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    
    -- Link to claim
    claim_id UUID REFERENCES claim(id) NOT NULL,
    
    -- Evidence classification
    type evidence_type NOT NULL,
    
    -- Source information
    source_name VARCHAR(200) NOT NULL,   -- Name of the evidence source
    source_provider VARCHAR(200),        -- Organization providing the evidence
    description TEXT,
    
    -- External reference
    url TEXT,                     -- Link to external evidence
    file_hash VARCHAR(64),        -- SHA-256 hash for integrity verification
    
    -- Confidence
    confidence_score DECIMAL(3,2),  -- Confidence level 0.00-1.00
    
    -- Dates
    observation_date DATE,   -- When the evidence was collected
    submission_date DATE,    -- When the evidence was submitted
    
    -- Structured observation data
    observation_data JSONB,  -- Structured content (survey answers, sensor readings)
    
    -- Extensibility
    metadata JSONB,
    
    -- Audit fields
    created_at TIMESTAMP NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP,
    
    -- Constraints
    CONSTRAINT evidence_confidence_range CHECK (confidence_score IS NULL OR (confidence_score >= 0 AND confidence_score <= 1)),
    CONSTRAINT evidence_hash_format CHECK (file_hash IS NULL OR LENGTH(file_hash) = 64)
);

-- Evidence indexes
CREATE INDEX idx_evidence_claim ON evidence(claim_id);
CREATE INDEX idx_evidence_type ON evidence(type);
CREATE INDEX idx_evidence_provider ON evidence(source_provider);
CREATE INDEX idx_evidence_observation_date ON evidence(observation_date);
CREATE INDEX idx_evidence_claim_type ON evidence(claim_id, type);

COMMENT ON TABLE evidence IS 'Supporting data for claims. Store actual files externally and reference via url. Use file_hash (SHA-256) to verify integrity.';

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

-- Apply trigger to all tables
CREATE TRIGGER site_updated_at BEFORE UPDATE ON site FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER actor_updated_at BEFORE UPDATE ON actor FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER relationship_updated_at BEFORE UPDATE ON relationship FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER transaction_updated_at BEFORE UPDATE ON transaction FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER claim_updated_at BEFORE UPDATE ON claim FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();
CREATE TRIGGER evidence_updated_at BEFORE UPDATE ON evidence FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

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

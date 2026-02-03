# **Entity-Relationship Model Documentation**

### **Summary**

This document presents the Entity-Relationship (ER) data model for the traceability system, designed to support interoperable traceability across diverse stakeholders in agri-food supply chains. Developed in alignment with the GS1 Global Traceability Standard (GS1 GTS) and EU Deforestation Regulation (EUDR) requirements, the model integrates practical insights from multiple pilot initiatives.

The ER model is structured to enable consistent and reliable data exchange, facilitating end-to-end visibility, accountability, and data integrity. By harmonizing core data entities, such as products, actors, processes, and traceability events, the model ensures that each data point is interoperable and can be validated both upstream and downstream.

The scope of the traceability system spans primary production, aggregation, transformation, transportation, and final product identification, allowing for seamless data flow across heterogeneous systems. Each entity has been carefully designed to reflect GS1 GTS principles, particularly in terms of unique identification, event-based traceability, and shared responsibility across stakeholders.

The foundational data architecture consists of a sophisticated metadata framework centered around the Records entity. This entity serves as the universal anchor point for all traceable objects within the platform. This design enables flexible data modeling while maintaining referential integrity across complex multi-stakeholder networks. The framework supports dynamic attribute extension through key-value pair structures, allowing for domain-specific metadata capture without requiring schema modifications. Field-level provenance tracking ensures complete data lineage from source to consumer, supporting forensic investigations and regulatory audits required under increasingly stringent transparency mandates.

Regulatory compliance capabilities are deeply integrated throughout the data model, with specific provisions for EUDR Article 9 due diligence requirements, GS1 EPCIS event serialization, and third-party certification validation workflows. The system maintains geospatial coordinates for deforestation risk assessment, supports multi-jurisdiction regulatory reporting, and provides audit trail mechanisms for demonstrating compliance with international trade requirements. Automated validation rules and confidence scoring mechanisms enable real-time compliance monitoring while reducing manual oversight burdens on supply chain participants.

Performance and scalability considerations are embedded in the database design through strategic indexing, optimized foreign key relationships, and hierarchical data organization patterns. The platform supports high-volume transaction processing, concurrent multi-user access, and real-time event ingestion from IoT devices and mobile applications. Partitioning strategies enable efficient data archiving and retrieval, while composite indexes support complex analytical queries across temporal and geospatial dimensions.

Integration capabilities extend across diverse technological ecosystems through standardized APIs, blockchain network compatibility, and support for emerging interoperability protocols. The data model facilitates seamless connections with enterprise resource planning systems, warehouse management platforms, certification databases, satellite monitoring services, and regulatory reporting portals. Export mechanisms support multiple data formats including JSON-LD, XML, and GS1 EPCIS structures, enabling participation in global supply chain networks and digital marketplaces. Secure data sharing protocols protect sensitive commercial information while providing the necessary transparency for compliance and sustainability verification.

Future-proofing and extensibility mechanisms ensure the platform can evolve with changing regulatory landscapes, emerging technologies, and new business requirements. The modular entity design supports incremental feature additions without disrupting existing operations, while version control capabilities enable smooth system upgrades and data migrations. Support for emerging standards, such as digital product passports, carbon footprint tracking, and social impact measurement, ensures long-term relevance and regulatory compliance. The flexible metadata architecture accommodates new attribute types, measurement units, and validation criteria as sustainability frameworks continue to evolve and mature.

## **GROUP 1: CORE METADATA ENTITIES**

### **Records**

This is the central metadata table used to **register, track, and link all traceable entities** across the platform (e.g., people, enterprises, sites, products, transactions, events, batches, groups). This foundational entity serves as the universal anchor point for the entire traceability system, enabling seamless integration with GS1 EPCIS frameworks and EUDR compliance requirements. 

Each business object across the traceability network references a unique “record\_id” for validation, provenance, auditability, and source attribution. The Records table facilitates cross-system data exchange, supports multi-stakeholder governance models, and enables forensic traceability investigations. It provides the backbone for data lineage tracking, regulatory reporting, and third-party auditing processes essential for supply chain transparency and accountability.

**Attributes**

| Field Name | Data Type | Default Value | Indexes & Performance Notes | Description | Constraints & Validation Rules |
| :---- | :---- | :---- | :---- | :---- | :---- |
| **id** | INT GENERATED BY DEFAULT AS IDENTITY | Auto-generated | Primary Key | Unique identifier for the record | Required, unique, auto-increment |
| **type** | RecordType | NULL | Indexed | Enumerated type representing the entity category | Required, ENUM (Enterprise, Person, Site, Transaction, Event, Batch, Product, Group) |
| **created\_at** | TIMESTAMP | NOW() | — | Timestamp of record creation | Required, auto-generated |
| **updated\_at** | TIMESTAMP | NULL | — | Timestamp of last update | Optional, updated upon data modification |

**Entity Relationships**

| Relationship Type | Related Entity Name | Cardinality | Description |
| :---- | :---- | :---- | :---- |
| **Has One** | People | 1:1 | One-to-one link to the People entity |
| **Has One** | Enterprises | 1:1 | One-to-one link to the Enterprises entity |
| **Has One** | Sites | 1:1 | One-to-one link to the Sites entity |
| **Has One** | Products | 1:1 | One-to-one link to the Products entity |
| **Has One** | BatchesLotsSerials | 1:1 | One-to-one link to the Batches or Lots entity |
| **Has One** | BusinessTransactions | 1:1 | One-to-one link to the business transaction |
| **Has One** | Events | 1:1 | One-to-one link to traceability events |
| **Has One** | Groups | 1:1 | One-to-one link to group entities |
| **Has Many** | Attributes | 1:N | Attributes (key-value pairs) related to the record |
| **Has Many** | Record\_Field\_Source | 1:N | Provenance and data source linkage for field-level traceability |
| **Has Many** | RecordsGroups | 1:N | Link to grouping structure of records |

**Business Logic & Data Exchange**

* Serves as a **universal anchor for traceability**, enabling audit trails, data attribution, and integration consistency across all major entities.  
* Introduces a powerful pattern for **multi-entity validation and enrichment**, supporting flexible data models without sacrificing normalization.  
* All business entities must have a corresponding “record\_id”, ensuring full compliance with GS1 GTS principles regarding traceable object identification.  
* The type ENUM enables filtering and logic branching in downstream systems, especially for cross-entity queries and reporting pipelines.  
* **Data provenance tracking** is enabled through the Record\_Field\_Source table, crucial for EUDR compliance and forensic validation.  
* Modular architecture benefits from referencing the “record\_id” field instead of using hard joins across entity tables, easing integration, and reducing coupling.  
* Systems importing/exporting traceable data (via JSON-LD, XML, EPCIS) use “record\_id” as a unique global reference.  
* Changes in entity attributes do not affect the “record\_id” field, enabling **temporal consistency** and versioned traceability without breaking referential links.

### **RecordsGroups**

This Join table is used to associate individual Records with logical or functional Groups. This structure enables the classification or aggregation of various traceable entities according to commonalities such as certification, batch, project, program, activity, or geographic unit. This allows for scalable multi-record operations, reporting, access control, and traceability layering.

**Attributes**

| Field Name | Data Type | Default Value | Indexes & Performance Notes | Description | Constraints & Validation Rules |
| :---- | :---- | :---- | :---- | :---- | :---- |
| **id** | INT GENERATED BY DEFAULT AS IDENTITY | Auto-generated | Primary Key | Unique identifier for the linking row | Required, unique, auto-increment |
| **group\_id** | int |  | Foreign Key to Groups | Refers to the Groups entity associated with the record | Required, FK to Groups(id), Not Null |
| **record\_id** | int |  | Foreign Key to Records | Refers to the Records entry associated with the group | Required, unique, FK to Records(id), Not Null |
| **created\_at** | TIMESTAMP | NOW() | — | Timestamp when the link was created | Required, auto-generated |
| **updated\_at** | TIMESTAMP | NULL | — | Timestamp of last modification | Optional, updated upon data modification |

**Entity Relationships**

| Relationship Type | Related Entity Name | Cardinality | Description |
| :---- | :---- | :---- | :---- |
| **Belongs To** | Groups | M:1 | Each link connects a record to a group |
| **Belongs To** | Records | M:1 | Each link connects a group back to a single traceable record |
| **Has Many Through** | RecordsGroups | M:N | Enables many-to-many relationships between Records and Groups |

**Business Logic & Data Exchange**

* Used to dynamically group traceable records (e.g., linking multiple Products, Sites, or Events under a single project or certification).  
* Enables bulk operations or reporting across all records within a group, critical for scalability and traceability audits.  
* Supports **multi-dimensional groupings**, such as temporal, geographic, operational, or certification-based classifications.   
* Enforces that each “group\_id” and “record\_id” pair is unique to avoid redundant or ambiguous group assignments.  
* When a group is deleted, cascading rules ensure linked rows are either deleted or flagged to preserve historical context.  
* Group membership may inform user access rights (e.g., certain users see only records within groups they belong to).  
* If extended to include “group\_type” or “membership\_role”, more complex semantics can be supported such as ownership or read-only access.  
* Changes to group composition trigger metadata refreshes or reindexing in systems using cached views.

### **Groups**

This entity represents **collections of related records** within the system, such as project groupings, certification programs, monitoring campaigns, regional clusters, or programmatic activities. It is used to logically associate traceable items (people, enterprises, activities, events, etc.) under a shared context and enables multi-entity reporting, filtering, and enforcement of business logic.

**Attributes**

| Field Name | Data Type | Default Value | Indexes & Performance Notes | Description | Constraints & Validation Rules |
| :---- | :---- | :---- | :---- | :---- | :---- |
| **id** | INT GENERATED BY DEFAULT AS IDENTITY | Auto-generated | Primary Key | Unique identifier for the group | Required, unique, auto-increment |
| **name** | VARCHAR(100) | NULL | Indexed | Human-readable name of the group | Required, max 100 characters |
| **record\_id** | int |  | Foreign Key | Links to the canonical metadata record | Required, unique, FK to Records(id) |
| **created\_at** | TIMESTAMP | NOW() | — | Timestamp when the group was created | Required, auto-generated |
| **updated\_at** | TIMESTAMP | NULL | — | Timestamp of last update | Recommended addition for audit trails |

**Entity Relationships**

| Relationship Type | Related Entity Name | Cardinality | Description |
| :---- | :---- | :---- | :---- |
| **Belongs To** | Records | 1:1 | Each group is represented by one metadata record |
| **Has Many** | RecordsGroups | 1:N | A group can include multiple records |
| **Has Many Through** | Records | M:N | Enables grouping of any traceable entities via join table |
| **Has Many** | Activities | 1:N | Can be linked to activities where the group is a beneficiary |

**Business Logic & Data Exchange**

* Enables the flexible aggregation of traceability data across entities and types, supporting custom reporting and analytics.  
* Critical for **program-based management** where multiple actors, sites, and activities are organized under shared initiatives.  
* Supports **certification schemes** where certified entities or compliance programs with shared standards are represented by groups.  
* Group membership is defined dynamically via the RecordsGroups table—no direct foreign key to specific business tables is needed.  
* Deleting a group is validated against dependent relationships to avoid data orphaning or traceability gaps.  
* “name” must be unique or namespaced to prevent confusion when presenting in multi-actor platforms or exported reports.  
* Grouping logic can be used to enforce access controls or scoping in multi-tenant systems (e.g., show records within user's groups).  
* When exporting traceability data, groups can be used to **package batches of related events or entities** (e.g., EPCIS AggregationEvents).

## **GROUP 2: ATTRIBUTE & OBSERVATION ENTITIES**

### **Attributes**

This schema-agnostic entity stores dynamic **key-value pairs** that provide flexible metadata extension capabilities for all traceable records within the platform. It enables custom data enrichment, contextual tagging, and extensible property management without requiring database schema modifications. Through standardized attribute vocabularies and controlled data sets, it supports **GS1 EPCIS extension mechanisms** and **EUDR-specific data requirements.** 

Attributes facilitates integration with diverse external systems, certification schemes, and regulatory frameworks by providing a unified mechanism for capturing domain-specific metadata (e.g., carbon footprint scores, organic certification details, social compliance indicators, quality parameters). It enables dynamic business rule implementation, custom reporting requirements, and stakeholder-specific data collection while maintaining data consistency and validation capabilities. It also supports multi-language metadata, temporal attribute values, and hierarchical data organization, making it essential for complex supply chain scenarios involving multiple jurisdictions, certification programs, and stakeholder requirements.

**Attributes**

| Field Name | Data Type | Default Value | Indexes & Performance Notes | Description | Constraints & Validation Rules |
| :---- | :---- | :---- | :---- | :---- | :---- |
| **id** | int | Auto-generated | Primary Key | Unique identifier for the attribute | Required, unique, auto-increment |
| **record\_id** | int |  | Foreign Key | Refers to the associated record | Required, unique, FK to Records(id) |
| **category** | varchar | NULL | Indexed | Logical category of the attribute | Optional, recommended for organizing attributes |
| **key** | varchar | NULL | Indexed | Name of the attribute field | Required, semantic standardization recommended |
| **value** | text | NULL | — | Value of the attribute | Optional, validate format when data type is known |
| **attribute\_date** | date | NULL | — | Date the attribute value applies to | Optional, ISO 8601 format |
| **created\_at** | TIMESTAMP | NOW() | — | Timestamp of record creation | Required, auto-generated |
| **updated\_at** | TIMESTAMP | NULL | — | Timestamp of last update | Optional, updated upon data modification |

**Entity Relationships**

| Relationship Type | Related Entity Name | Cardinality | Description |
| :---- | :---- | :---- | :---- |
| **Belongs To** | Records | M:1 | Each attribute is associated with one record |
| **Has Many Through** | AuditAttributesObservations | M:N | Allows observations to be attached to attributes |

**Business Logic & Data Exchange**

* Key-value structure provides schema flexibility and extensibility, ideal for evolving pilot programs and EPCIS event enrichment.  
* Enables partial record comparison, version tracking, and forensic analysis when combined with “attribute\_date”.  
* Supports **EUDR-specific metadata** such as deforestation risk scores, certification statuses, and compliance flags.  
* “value” is untyped in the database, so external systems enforce type and format validation based on “key” and “category”.  
* Can be used for **contextual partitioning**, improving clarity in UI displays and API filtering.   
* Privacy-sensitive keys must follow data protection policies and access restrictions.  
* The same record can hold multiple attributes—even repeated “key” values—unless restricted by business logic.  
* When synchronizing across systems, attributes should be normalized into expected types/formats before ingestion.

### **AuditAttributesObservations**

This Audit table links specific Attributes (key-value data points) to corresponding Observations made by external or internal sources. It supports **auditing, verification,** and **validation** of record-level data within traceability systems. This mapping structure enables evidence-based compliance checks, forensic verification of field-level claims, and interoperability with third-party validation providers.

**Attributes**

| Field Name | Data Type | Default Value | Indexes & Performance Notes | Description | Constraints & Validation Rules |
| :---- | :---- | :---- | :---- | :---- | :---- |
| **id** | integer | Auto-generated | Primary Key | Unique identifier for the audit mapping record | Required, unique, auto-increment |
| **attribute\_id** | integer | NULL | Foreign Key | Reference to the Attributes entry being validated | Required, FK to Attributes(id) |
| **observation\_id** | integer | NULL | Foreign Key | Reference to the Observations entry used as evidence | Required, FK to Observations(id) |
| **created\_at** | TIMESTAMP | NOW() | — | Timestamp of audit mapping creation | Required, auto-generated |
| **updated\_at** | TIMESTAMP | NULL | — | Timestamp of last update | Recommended addition for audit trails |

**Entity Relationships**

| Relationship Type | Related Entity Name | Cardinality | Description |
| :---- | :---- | :---- | :---- |
| **Belongs To** | Attributes | M:1 | Each audit record links to one attribute being validated |
| **Belongs To** | Observations | M:1 | Each audit record links to one observation providing evidence |
| **Has Many Through** | Records (indirect) | M:N | Enables data lineage back to the original record |

**Business Logic & Data Exchange**

* Enables **attribute-level validation** by associating key-value fields with documented observations such as lab reports or audit findings.  
* Ensures foreign keys to Attributes and Observations are valid and referential integrity is enforced during external audit ingestion.  
* Useful for **EUDR** and **GS1-aligned audit trails** where third-party validators provide traceable evidence for claims.  
* Critical for demonstrating compliance with deforestation-free sourcing requirements under EUDR regulations.  
* Attributes “created\_at” and “updated\_at” support temporal validation and allow reconstruction of validation histories.  
* Exporting this data for regulators should use the linked “record\_id” context to aggregate all validations per record.  
* Privacy-sensitive or proprietary observations may need encrypted storage or access restriction for high-value lots.  
* Large-scale implementations should optimize for indexing and optionally archive stale audits while preserving mappings.

### **Observations**

This entity captures **qualitative or quantitative observations** provided by internal systems or external sources (e.g., field agents, certifiers, labs, satellite providers). These observations serve as evidence to support or challenge traceability claims and can be linked to Attributes via the Audit table. This structure supports GS1/EUDR-aligned validation, anomaly tracking, and data provenance modeling.

**Attributes**

| Field Name | Data Type | Default Value | Indexes & Performance Notes | Description | Constraints & Validation Rules |
| :---- | :---- | :---- | :---- | :---- | :---- |
| **id** | integer | Auto-generated | Primary Key | Unique identifier for the observation | Required, unique, auto-increment |
| **key** | enum | NULL | Indexed | Controlled keyword or type for the observation | Required, enumerated list, should follow agreed vocabulary |
| **data\_source\_id** | int | NULL | Foreign Key | Links to the data source that generated the observation | Required, FK to DataSource(id) |
| **observation** | text | NULL | — | Free-text or JSON payload containing the observation | Optional, format depends on key |
| **observation\_date** | date | NULL | Indexed | Date when the observation was made | Required, ISO 8601 format |
| **created\_at** | TIMESTAMP | NOW() | — | Timestamp when the observation was recorded | As defined in SQL schema |
| **updated\_at** | TIMESTAMP | NULL | — | Timestamp of last update | Recommended addition for audit trails |

**Entity Relationships**

| Relationship Type | Related Entity Name | Cardinality | Description |
| :---- | :---- | :---- | :---- |
| **Belongs To** | DataSource | M:1 | Each observation is linked to the origin data source |
| **Has Many Through** | Attributes (via Audit table) | M:N | Observations validate or contextualize Attributes |
| **Has Many Through** | Records (indirectly) | M:N | Enables indirect validation of traceable records |

**Business Logic & Data Exchange**

* Each Observation references a valid DataSource to ensure information traceability and credibility.  
* Format can be free-form (TEXT) or structured (JSON), so downstream systems must validate expected schema formats.  
* Can be used in traceability validations and **EUDR compliance checks** for sustainability scores and origin confirmation.  
* “key” field is **centrally governed** to avoid inconsistent labeling of similar observation types across datasets.  
* May be **sensitive or confidential**, especially if provided by third parties—encryption and access control are required.  
* When exporting for regulators, Observations must be joined with related Attributes and Records for context.  
* For scalability, consider **archiving old Observations** or separating high-frequency inputs from audit-level validations.  
* Integration with IoT sensors, satellite imagery, and certification databases requires standardized data ingestion protocols.

### **DataSource**

This entity captures comprehensive metadata about the **origin or provider of data** throughout the traceability ecosystem. This includes third-party certification bodies, satellite data providers, mobile data collection applications, IoT sensor networks, laboratory systems, and internal enterprise databases. 

DataSource serves as the foundation for **data provenance tracking**, **evidence-based compliance verification**, and **forensic traceability investigations** required under GS1 transparency standards and EUDR audit frameworks. It enables confidence scoring and reliability assessment of information sources, supporting automated validation workflows and conflict resolution mechanisms when multiple sources provide contradictory data. It also facilitates integration with external verification systems, blockchain networks, and regulatory reporting platforms while maintaining clear attribution chains essential for legal compliance and stakeholder trust in multi-actor supply chain environments.

**Attributes**

| Field Name | Data Type | Default Value | Indexes & Performance Notes | Description | Constraints & Validation Rules |
| :---- | :---- | :---- | :---- | :---- | :---- |
| **id** | int | Auto-generated | Primary Key | Unique identifier for the data source | Required, unique, auto-increment |
| **provider** | text | NULL | Indexed | Name of the organization or platform supplying the data | Required, non-empty string |
| **name** | text | NULL | Indexed | Descriptive label or alias for the specific dataset | Required, must be unique or clearly distinguishable |
| **description** | text | NULL | — | Optional human-readable explanation of the data source | Optional |
| **confidence\_level** | int | NULL | — | Confidence or trust level (e.g., 1–5 scale) | Optional, numeric, range: 1 (low) to 5 (high) |
| **submission\_date** | date | NULL | Indexed | Date the dataset or evidence was submitted | Optional, ISO 8601 format |
| **created\_at** | TIMESTAMP | NOW() | — | Timestamp of record creation | As defined in SQL schema |
| **updated\_at** | TIMESTAMP | NULL | — | Timestamp of last update | Recommended addition for audit trails |

**Entity Relationships**

| Relationship Type | Related Entity Name | Cardinality | Description |
| :---- | :---- | :---- | :---- |
| **Has Many** | Observations | 1:N | Data sources generate one or more observations |
| **Has Many** | Record\_Field\_Source | 1:N | Used to track field-level provenance on Records |

**Business Logic & Data Exchange**

* All observational data and record-level field provenance reference a valid DataSource to ensure traceability and audit readiness.  
* Critical for **EUDR compliance** where data sources must be documented and verifiable for regulatory submissions.  
* When exchanging traceability data (e.g., EPCIS, JSON-LD, GHG disclosures), DataSource can be mapped to source, issuer, or DataProvider.  
* Duplicate or ambiguous “provider” or “name” values can create traceability gaps—enforce controlled vocabulary or external registry alignment.   
* Confidence scoring enables systems to assign different **weights** to **evidence** from different sources when validating conflicting claims.  
* Sources with low “confidence\_level” values trigger alerts or require human verification before acceptance into the traceability pipeline.  
* Systems should consider **access control and reputation scoring** for external data sources to prevent manipulation or bias.  
* Integration with certification bodies and remote sensing providers requires standardized API mappings and authentication protocols.

### **Record\_Field\_Source**

This entity captures **field-level provenance** by documenting the source of truth for individual fields in a Record. This enables forensic traceability, compliance with data transparency mandates (e.g., EUDR), and support for verifiable claims by linking specific data points to their origin (e.g., external datasets, user entry, machine sensors, or certified sources).

**Attributes**

| Field Name | Data Type | Default Value | Indexes & Performance Notes | Description | Constraints & Validation Rules |
| :---- | :---- | :---- | :---- | :---- | :---- |
| **id** | int | Auto-generated | Primary Key | Unique identifier for field-source mapping | Required, unique, auto-increment |
| **record\_id** | int |  | Foreign Key | Reference to target Record where field appears | Required, unique, FK to Records(id) |
| **data\_source\_id** | int | NULL | Foreign Key | Source of the field's data | Required, FK to DataSource(id) |
| **field\_name** | VARCHAR(50) | NULL | Indexed | Name of the specific field in the record | Required, max 50 characters |
| **created\_at** | TIMESTAMP | NOW() | — | Timestamp of field-source linkage creation | As defined in SQL schema |
| **updated\_at** | TIMESTAMP | NULL | — | Timestamp of last update to source metadata | Recommended addition for audit trails |

**Entity Relationships**

| Relationship Type | Related Entity Name | Cardinality | Description |
| :---- | :---- | :---- | :---- |
| **Belongs To** | Records | M:1 | Each field-source record belongs to a specific record |
| **Belongs To** | DataSource | M:1 | Each field value is traced to a single source |
| **Has Many Through** | Records (via metadata) | M:N | Enables provenance tracking for multiple fields |

**Business Logic & Data Exchange**

* Enables integration with **provenance-aware data ingestion pipelines** where source attribution is maintained during bulk uploads.  
* Used in **EUDR submissions** to prove origin, ownership, or sustainability attributes with confidence by tracing back to verifiable sources.  
* Facilitates the granular validation of datasets, allowing third parties to inspect only the fields they are responsible for.  
* Generates dynamic data lineage graphs in dashboards showing which fields are validated, disputed, or externally verified.  
* Every field carrying regulatory weight or audit implications has a traceable Record\_Field\_Source entry.  
* Downstream systems ensure “field\_name” matches actual schema fields within the corresponding Record.type.  
* Security-sensitive source links are managed with access control and encryption as needed.  
* Systems detect and flag conflicting sources for the same field and apply resolution policies based on confidence level.

## **GROUP 3: ACTIVITY ENTITIES**

### **Activities**

This entity represents planned or completed **interventions, programs,** or **actions** undertaken by an enterprise or implementer such as training, input distribution, field monitoring, social programs, or improvement initiatives. Activities can be grouped, tracked over time, linked to beneficiaries (as Groups), and described using extended Attributes. This supports program transparency, traceability of support measures, and links between enterprise actions and supply chain outcomes.

**Attributes**

| Field Name | Data Type | Default Value | Indexes & Performance Notes | Description | Constraints & Validation Rules |
| :---- | :---- | :---- | :---- | :---- | :---- |
| **id** | INT GENERATED BY DEFAULT AS IDENTITY | Auto-generated | Primary Key | Unique identifier for the activity | Required, unique, auto-increment |
| **name** | VARCHAR(100) | NULL | Indexed | Activity name or label | Required, max 100 characters |
| **description** | VARCHAR(200) | NULL | — | Short description of the activity | Optional, recommended for clarity, max 200 characters |
| **budget\_quantity** | DECIMAL(18,2) | NULL | — | Total allocated budget | Optional, must be a non-negative number |
| **budget\_currency** | VARCHAR(10) | NULL | — | ISO currency code (e.g., USD, EUR) | Optional, should match ISO 4217 |
| **beneficiary\_group\_id** | int | NULL | Foreign Key | Refers to a Group benefiting from the activity | Required, FK to Groups(id) |
| **record\_id** | int |  | Foreign Key | Metadata reference for traceability and data validation | Required, unique, FK to Records(id) |
| **start\_date** | date | NULL | Indexed | Start date of the activity | Optional, ISO 8601 format |
| **end\_date** | date | NULL | Indexed | End date of the activity | Optional, must be ≥ start\_date |
| **implementer** | int | NULL | Foreign Key | Enterprise responsible for execution | Required, FK to Enterprises(id) |
| **created\_at** | TIMESTAMP | NOW() | — | Timestamp of creation | Required, auto-generated |
| **updated\_at** | TIMESTAMP | NULL | — | Timestamp of last update | Recommended addition for audit trails |

**Entity Relationships**

| Relationship Type | Related Entity Name | Cardinality | Description |
| :---- | :---- | :---- | :---- |
| **Belongs To** | Enterprises | N:1 | Each activity is executed by a specific enterprise |
| **Belongs To** | Groups | N:1 | Activities target a group of beneficiaries |
| **Belongs To** | Records | N:1 | Activities inherit metadata and traceability context |

**Business Logic & Data Exchange**

* Allows supply chain actors to **record non-product interventions** that affect sustainability, social, or economic outcomes.  
* Activity-level Attributes allow extensible documentation of specific goals, KPIs, or outcomes (e.g., carbon mitigation, training hours).  
* Can be used to demonstrate **social and environmental impact** as part of sustainability reporting and certification requirements.  
* “implementer” and “beneficiary\_group\_id” are enforced as required to support relational integrity and group-level reporting.  
* “start\_date” and “end\_date” support chronological reporting and are key for **time-based filtering** in program dashboards and audits.  
* Exporting activity data includes “record\_id” and Group context to maintain linkage with traceable actors.  
* Systems must control access to sensitive fields (e.g., budget) based on user roles in multi-stakeholder environments.  
* Integration with project management systems and donor platforms requires standardized progress tracking and outcome measurement.

## **GROUP 4: PEOPLE & ENTERPRISE ENTITIES**

### **People**

This entity represents individual people involved in the traceability network (e.g., producers, auditors, inspectors, certifiers, field agents, quality controllers). Each person may be associated with one or more enterprises and serve different roles across supply chain operations, supporting flexible workforce management and multi-stakeholder collaboration scenarios. 

People enables precise tracking of individual responsibility and enhances transparency and accountability throughout the system by linking specific actions and decisions to verified personnel. It supports **personal data management**, **role-based access control**, and **certification program requirements** for auditor qualifications and training records. It also facilitates integration with HR systems, certification databases, and mobile workforce management applications while maintaining necessary privacy protections and data sovereignty controls essential for global supply chain operations.

**Attributes**

| Field Name | Data Type | Default Value | Indexes & Performance Notes | Description | Constraints & Validation Rules |
| :---- | :---- | :---- | :---- | :---- | :---- |
| **id** | INT GENERATED BY DEFAULT AS IDENTITY | Auto-generated | Primary Key | Unique identifier for the person | Required, unique, auto-increment |
| **record\_id** | int |  | Unique | Links People to Records for metadata and provenance | Required, unique, FK to Records(id) |
| **name** | VARCHAR(100) | NULL | Indexed | Full name of the person | Required, max 100 characters, alphabetic characters and separators |
| **role** | VARCHAR(50) | NULL | Indexed | The function or position this person fulfills | Required, enumerated list recommended |
| **email** | varchar | NULL | Indexed | Email address for communication | Optional, must follow valid email format |
| **telephone** | varchar | NULL | Indexed | Contact telephone number | Optional, valid international format |
| **created\_at** | TIMESTAMP | NOW() | — | Timestamp of record creation | As defined in SQL schema |
| **updated\_at** | TIMESTAMP | NULL | — | Timestamp of last update | Recommended addition for audit trails |

**Entity Relationships**

| Relationship Type | Related Entity Name | Cardinality | Description |
| :---- | :---- | :---- | :---- |
| **Has Many** | EnterprisePeople | 1:N | A person can be associated with multiple enterprises |
| **Belongs To** | Records | 1:1 | Each person is uniquely tied to a Records entity |

**Business Logic & Data Exchange**

* Each person is linked to a unique “record\_id” to ensure interoperability across systems and support traceability audits.  
* All entries support **versioning and source traceability** via the Records table for transparent change logs.  
* Indexes on “name”, “role”, and “contact” fields improve search/filtering in multi-tenant systems with many stakeholders.  
* Contact information is optional but recommended for actors in compliance-related roles (e.g., certifiers, auditors).  
* For consistency, roles should be standardized using enumerations based on GS1 or project-specific controlled vocabularies.  
* Updates to roles or contact info should be logged via “updated\_at”, and optionally stored in “changelog” for audit trails.  
* Sensitive personal data must comply with GDPR or local privacy regulations—encryption or restricted access required.

### **EnterprisePeople**

This Join table represents **many-to-many relationships** between People and Enterprises. It defines the association of individuals with one or more enterprises, capturing roles, affiliations, and operational responsibilities. This mapping enables a flexible actor model across traceability networks where individuals may operate across multiple enterprises.

**Attributes**

| Field Name | Data Type | Default Value | Indexes & Performance Notes | Description | Constraints & Validation Rules |
| :---- | :---- | :---- | :---- | :---- | :---- |
| **people\_id** | integer | NULL | Foreign Key, Indexed | Reference to a People entity | Required, FK to People(id) |
| **enterprise\_id** | integer | NULL | Foreign Key, Indexed | Reference to an Enterprises entity | Required, FK to Enterprises(id) |
| **created\_at** | TIMESTAMP | NOW() | — | Timestamp when the association was created | Required, auto-generated |
| **updated\_at** | TIMESTAMP | NULL | — | Timestamp of the last modification | Recommended addition for audit trails |

**Entity Relationships**

| Relationship Type | Related Entity Name | Cardinality | Description |
| :---- | :---- | :---- | :---- |
| **Belongs To** | People | M:1 | Each link connects back to a single person |
| **Belongs To** | Enterprises | M:1 | Each link connects back to a single enterprise |
| **Has Many Through** | EnterprisePeople | M:N | Enables many-to-many mapping between people and enterprises |

**Business Logic & Data Exchange**

* Mapping allows for many-to-many relationships, supporting multi-role actors and dynamic assignments—critical in supply chains where a person can act on behalf of various organizations (e.g., shared certifiers, contract producers).   
* Validation ensures both foreign keys “people\_id” and “enterprise\_id” exist and are valid references at time of insert.  
* Consider enforcing uniqueness on “people\_id” and “enterprise\_id” to prevent redundant mappings and simplify downstream processing.  
* “created\_at” and “updated\_at” timestamps maintain a clear historical view of organizational changes and accountability in traceability audits.  
* Relationships are queryable in both directions—from person to enterprise and enterprise to person—to ensure bi-directional indexing.  
* External data systems resolve relationships to correctly assign roles and actions to users across different business contexts.  
* No sensitive personal information is stored in this table, but the links it forms must be access-controlled in systems with restricted enterprise visibility.  
* In multi-tenant deployments, these links should respect enterprise-level data boundaries.

### **Enterprises**

This entity represents legal business entities and organizations involved throughout the agri-food supply chain (e.g., producers, exporters, processors, certifiers, traders, cooperatives). This master data entity serves as the foundational anchor for linking all operational activities, traceability events, and compliance data to accountable business actors within the platform. 

Enterprises enables seamless integration with global business registries, government databases, and certification systems through standardized identifiers like **GLNs (Global Location Numbers)** and **tax IDs**. It supports multi-stakeholder traceability networks by facilitating secure data sharing agreements, role-based access controls, and cross-border regulatory compliance reporting. It also provides essential context for **EUDR due diligence requirements**, **GS1 EPCIS trading partner identification**, and supply chain risk assessment frameworks. Additionally, it supports sustainability impact tracking, certification program management, and third-party auditing processes critical for modern supply chain transparency and regulatory compliance.

**Attributes**

| Field Name | Data Type | Default Value | Indexes & Performance Notes | Description | Constraints & Validation Rules |
| :---- | :---- | :---- | :---- | :---- | :---- |
| **id** | INT GENERATED BY DEFAULT AS IDENTITY | Auto-generated | Primary Key | Unique identifier for the enterprise | Required, unique, auto-increment |
| **record\_id** | int |  | Unique | Link to Records for metadata and audit tracking | Required, unique, FK to Records(id) |
| **name** | VARCHAR(100) | NULL | Indexed | Legal name of the enterprise | Required, max 100 characters |
| **type** | VARCHAR(50) | NULL | Indexed | Business type or classification | Optional, controlled vocabulary recommended |
| **legal\_address** | TEXT | NULL | — | Registered legal address of the enterprise | Optional, validate as full postal address string |
| **tax\_id** | VARCHAR(100) | NULL | Indexed | National or regional tax identifier | Optional, format per country requirements |
| **gln** | VARCHAR(13) | NULL | Indexed | Global Location Number, as per GS1 standard | Optional, must follow GS1 GLN format (13 digits) |
| **created\_at** | TIMESTAMP | NOW() | — | Record creation timestamp | As defined in SQL schema |
| **updated\_at** | TIMESTAMP | NULL | — | Record last updated timestamp | Recommended addition for audit trails |

**Entity Relationships**

| Relationship Type | Related Entity Name | Cardinality | Description |
| :---- | :---- | :---- | :---- |
| **Has Many** | Sites | 1:N | An enterprise can operate multiple physical locations |
| **Has Many Through** | EnterprisePeople | 1:N | Enterprise can be associated with multiple People through linking table |
| **Belongs To** | Records | 1:1 | Each enterprise links to a record metadata row |
| **Has Many** | Events | 1:N | Enterprise responsible for traceability events |
| **Has Many** | BusinessTransactions | 1:N | As seller or buyer enterprise in commercial transactions |
| **Has Many** | Activities | 1:N | Enterprise implements projects or activities |

**Business Logic & Data Exchange**

* Every enterprise has a unique “record\_id” for interoperability and traceability validation across different systems.  
* GLN is optional but recommended for GS1 alignment, especially when integrating with external actors or using EPCIS-based traceability.  
* Data consumers use “name” and “gln” as identifiers during event ingestion or reporting in traceability applications.  
* Table is indexed on “name”, “gln”, and “tax\_id” when supporting fuzzy matching or external registry reconciliation.  
* Privacy rules may apply to “tax\_id”, depending on local data protection legislation—encryption or access restriction required.   
* “type” field follows a controlled vocabulary to standardize business classifications (e.g., farmer, trader, certifier).  
* Changes in enterprise data trigger updates in connected entities, so “updated\_at” is crucial for consistency checks.  
* In multi-stakeholder platforms, enterprise visibility is scoped by tenant access controls to prevent data leakage.

### **Sites**

This entity represents the physical or operational locations where Critical Tracking Events (CTEs) occur including farms, plots, processing facilities, warehouses, ports, and distribution centers. This geospatially-enabled entity serves as the foundation for **GS1 EPCIS ReadPoint and BizLocation** identification, enabling precise mapping of all traceability events to verified locations. 

Sites supports **EUDR geolocation requirements** for proving deforestation-free sourcing through GPS coordinates and administrative boundaries. It facilitates hierarchical site management for complex operations (e.g., farm plots within cooperatives, processing lines within facilities), enabling both micro-level traceability and macro-level supply chain visibility. It also integrates with GIS systems, satellite monitoring platforms, and mobile data collection applications to support real-time location verification, environmental monitoring, and compliance auditing. Additionally, it enables risk assessment based on geographic factors, supports certification program requirements for site-level standards, and provides the spatial context necessary for supply chain optimization and sustainability impact measurement.

**Attributes**

| Field Name | Data Type | Default Value | Indexes & Performance Notes | Description | Constraints & Validation Rules |
| :---- | :---- | :---- | :---- | :---- | :---- |
| **id** | INT GENERATED BY DEFAULT AS IDENTITY | Auto-generated | Primary Key | Unique identifier for the site | Required, unique, auto-increment |
| **parent\_id** | INT | NULL | FK to self, allows hierarchy | Optional reference to a parent site | Optional, FK to Sites(id) |
| **enterprise\_id** | INT | NULL | Indexed | Enterprise that owns or operates the site | Required, FK to Enterprises(id) |
| **record\_id** | int |  | Unique | Link to Records metadata | Required, unique, FK to Records(id) |
| **name** | VARCHAR(100) | NULL | Indexed | Site name or identifier | Required, max 100 characters |
| **type** | enum | NULL | Indexed | Type of site per GS1 CBV site types (farm, warehouse, processing facility) | Required, should follow GS1 Core Business Vocabulary |
| **address** | TEXT | NULL | — | Physical or postal address | Optional, recommended postal format |
| **altitude** | DECIMAL(8,2) | NULL | — | Optional elevation data | Optional, realistic range (-500 to \+9000 meters) |
| **latitude** | DECIMAL(9,6) | NULL | Geospatial Index | GPS coordinate: latitude | Required if geolocation used: \-90.000000 to 90.000000 |
| **longitude** | DECIMAL(9,6) | NULL | Geospatial Index | GPS coordinate: longitude | Required if geolocation used: \-180.000000 to 180.000000 |
| **size** | DECIMAL(10,4) | NULL | — | Physical size of the site | Optional, should match unit of measure logic |
| **created\_at** | TIMESTAMP | NOW() | — | Timestamp of record creation | As defined in SQL schema |
| **is\_headquarters** | BOOLEAN | NULL | Partial Unique Index | Indicates whether this site is the HQ | Optional, only one TRUE per enterprise\_id |
| **updated\_at** | TIMESTAMP | NULL | — | Timestamp of last update | Recommended addition for audit trails |

**Entity Relationships**

| Relationship Type | Related Entity Name | Cardinality | Description |
| :---- | :---- | :---- | :---- |
| **Belongs To** | Enterprises | N:1 | Each site is owned or operated by one enterprise |
| **Has Many** | Sites (self-ref) | 1:N | A site may have sub-sites |
| **Belongs To** | Records | 1:1 | Links to record metadata for auditing and validation |
| **Has Many** | Events | 1:N | Traceability events occur at sites |
| **Has Many** | BatchesLotsSerials (origin) | 1:N | Sites can be origin locations for batches |

**Business Logic & Data Exchange**

* “type” conforms to GS1 Core Business Vocabulary (CBV) for standardized data exchange.  
* **Unique Headquarters Constraint:** An enterprise can only have one designated headquarters. This rule is enforced at the database level to prevent duplicates. The constraint works by applying the uniqueness check only to records that are flagged as a headquarters. 

  *Example Index:*
```postgresql
CREATE UNIQUE INDEX unique\_enterprise\_hq\_idx ON Sites (enterprise\_id) WHERE is\_headquarters \= TRUE;
```
* “name” value is unique within the scope of an enterprise for clarity, even if not enforced at DB level.  
* Changes in geolocation or parent structure trigger updates in linked events to preserve historical integrity.  
* Accurate latitude and longitude fields allow geospatial validation of traceability events and GIS integration.   
* “parent\_id” enables modeling of **hierarchical sites**, useful in large facilities or multi-unit operations.  
* Systems integrating with EPCIS can derive ReadPoint and BizLocation from site metadata using GLN mapping.  
* For privacy-sensitive operations, GPS coordinates may require obfuscation or tiered access controls.

## **GROUP 5: PRODUCT & TRACEABILITY ENTITIES**

### **Products**

This entity defines **product master data** used across the supply chain. Each product represents a traceable item type such as raw materials, semi-finished goods, or final products. It provides the foundation for assigning batches, managing product identifiers (e.g., SKU, GTIN), and supporting traceability records. It aligns with **GS1 product identification standards** for interoperability and regulatory compliance.

**Attributes**

| Field Name | Data Type | Default Value | Indexes & Performance Notes | Description | Constraints & Validation Rules |
| :---- | :---- | :---- | :---- | :---- | :---- |
| **id** | INT GENERATED BY DEFAULT AS IDENTITY | Auto-generated | Primary Key | Unique identifier for each product | Required, unique, auto-increment |
| **record\_id** | int |  | Unique | Metadata reference for traceability and audit linkage | Required, unique, FK to Records(id) |
| **name** | VARCHAR(100) | NULL | Indexed | Name of the product | Required, max 100 characters |
| **sku** | VARCHAR(100) | NULL | Indexed | Stock Keeping Unit — internal product identifier | Optional, should be unique per enterprise |
| **gtin** | VARCHAR(100) | NULL | Indexed | Global Trade Item Number per GS1 standards | Optional, 8 to 14-digit number (validated if present) |
| **description** | TEXT | NULL | — | Long-form description of the product | Optional |
| **category** | VARCHAR(100) | NULL | Indexed | Classification of product | Optional, should follow controlled vocabulary |
| **created\_at** | TIMESTAMP | NOW() | — | Timestamp when product record was created | As defined in SQL schema |
| **updated\_at** | TIMESTAMP | NULL | — | Timestamp of last update | Recommended addition for audit trails |

**Entity Relationships**

| Relationship Type | Related Entity Name | Cardinality | Description |
| :---- | :---- | :---- | :---- |
| **Has Many** | BatchesLotsSerials | 1:N | A product may have many traceable batches or serials |
| **Belongs To** | Records | 1:1 | Each product is registered in the unified record metadata model |

**Business Logic & Data Exchange**

* Defines the **template context** for all traceable batches and transactions—no batch exists without a product definition.  
* Product categories align with **EUDR commodity classifications** for regulatory reporting and compliance tracking.  
* “record\_id” linkage enables each product to carry versioned metadata, enriched attributes, and source references.  
* GTIN aligns with **GS1 global product identification** and supports automated scanning, international data sharing, and retail integration.  
* SKUs are enterprise-specific so systems must avoid relying solely on SKU as a universal identifier unless partitioned per organization.  
* If the system is multi-tenant, the uniqueness of SKU or GTIN is scoped per tenant or implementing enterprise.  
* When integrating with ERP, WMS, or e-commerce platforms, product-level information should be harmonized through API mappings.   
* Unauthorized changes to product master data can cause downstream inconsistency—"updated\_at” should be used for syncing.

### **BatchesLotsSerials**

This entity represents **batches, lots, or serialized units**. These function as the fundamental traceability objects which enable precise tracking of physical product groupings throughout complex supply chains. This entity is the cornerstone of the platform's **event-based traceability architecture**, capturing critical production metadata, origin information, quantities, and regulatory compliance data. 

BatchesLotsSerials directly supports **EUDR due diligence obligations** by maintaining verifiable links to production locations and deforestation-free sourcing evidence. It enables **GS1-compliant unique batch identification** through enterprise-specific numbering schemes and supports seamless integration with **EPCIS ObjectEvent and AggregationEvent** structures for global supply chain interoperability. It facilitates mass balance calculations, yield analysis, quality control tracking, and expiration management across transformation processes. It also provides the granular foundation for **blockchain-based provenance verification**, **IoT sensor data integration**, and **third-party certification validation**. Additionally, it supports regulatory reporting requirements, sustainability impact measurement, and consumer transparency initiatives by maintaining immutable links between physical products and their complete production history.

**Attributes**

| Field Name | Data Type | Default Value | Indexes & Performance Notes | Description | Constraints & Validation Rules |
| :---- | :---- | :---- | :---- | :---- | :---- |
| **id** | integer | Auto-generated | Primary Key | Unique identifier for each batch/lot/serial | Required, unique, auto-increment |
| **batch\_lot\_serial\_number** | VARCHAR(100) | NULL | Indexed | Enterprise-level identifier for the batch | Required, unique per enterprise, GS1 guidelines |
| **product\_id** | integer | NULL | Foreign Key | Product associated with the batch | Required, FK to Products(id) |
| **origin\_plot\_id** | integer | NULL | Optional Foreign Key | Refers to the Sites entry representing the origin | Optional, required for EUDR-relevant data |
| **quantity** | DECIMAL(18,2) | NULL | — | Total quantity of items/materials in the batch | Required, must be ≥ 0 |
| **unit** | VARCHAR(50) | NULL | — | Unit of measure (e.g., kg, liters, units) | Required, should match GS1 standard units |
| **production\_date** | date | NULL | Indexed | Date the batch was produced | Required, ISO 8601 format |
| **expiry\_date** | date | NULL | — | Optional date of expiration | Optional, must be ≥ production\_date |
| **country\_of\_production** | varchar | NULL | Indexed (EUDR) | Country of origin—critical for regulatory reporting | Required for EUDR compliance, ISO country codes |
| **region\_of\_production** | varchar | NULL | — | Subnational region of origin | Required for EUDR, official regional designations |
| **disposition** | VARCHAR(50) | NULL | — | Current status of the batch | Optional, should use GS1 CBV disposition vocabulary |
| **record\_id** | int |  | Unique | Links to Records for metadata and validation provenance | Required, unique, FK to Records(id) |
| **created\_at** | TIMESTAMP | NOW() | — | Timestamp of batch registration | Required, auto-generated |
| **updated\_at** | TIMESTAMP | NULL | — | Timestamp of last update | Recommended addition for audit trails |

**Entity Relationships**

| Relationship Type | Related Entity Name | Cardinality | Description |
| :---- | :---- | :---- | :---- |
| **Belongs To** | Products | N:1 | Each batch is associated with a specific product |
| **Belongs To** | Sites (origin) | N:1 | Optionally links to the origin site |
| **Belongs To** | Records | 1:1 | Each batch is tied to one Records entry for auditing |
| **Has Many** | BatchesEvents | 1:N | Can be linked to multiple traceability events |
| **Has Many** | BusinessTransactionsBatches | 1:N | Linked to commercial transactions |

**Business Logic & Data Exchange**

* All traceable products are assigned to at least one BatchesLotsSerials entry for **GS1 EPCIS-compliant event-based traceability**, ensuring no gaps in the chain of custody from origin to consumer.  
* “batch\_lot\_serial\_number” values follow **GS1 GIAI (Global Individual Asset Identifier)** or **GTIN \+ Lot** guidelines and are **unique per enterprise-product combination** to prevent cross-contamination in global supply chains.  
* “disposition” values conform to **GS1 CBV disposition vocabulary** (active, in\_progress, recalled, destroyed) to ensure consistent status reporting across multi-stakeholder trading networks.  
* “origin\_plot\_id”, “country\_of\_production”, and “region\_of\_production” are **mandatory for EUDR Article 9 operator statements** and reference verified geolocation data with deforestation risk assessments.  
* Production and expiry dates enable **shelf-life management, HACCP compliance**, and automated alerts for quality control processes in time-sensitive supply chains.  
* “quantity” and “unit” fields support **mass balance validation algorithms** essential for detecting fraud, ensuring yield consistency, and validating transformation ratios across processing events.  
* **EPCIS serialization** capabilities enable individual item tracking within batches for high-value products requiring granular traceability (e.g., specialty coffees, premium cocoa).  
* **Regulatory reporting automation** leverages batch-level aggregation for generating EUDR due diligence statements, customs declarations, and sustainability impact reports without manual intervention.  
* Cross-system data exchange requires **standardized unit conversions** and **tolerance calculations** to account for processing losses and measurement variations between trading partners.  
* Integration with **blockchain networks** requires immutable batch identifiers and cryptographic hash validation of all attribute changes to prevent tampering.

### **BatchesEvents**

This table serves as a **pivot table** that links batches (BatchesLotsSerials) to traceability events (Events). It enables the recording of **which batch was involved** during a **specific event**, and in what **quantity** and **direction** (input/output). This design supports **many-to-many relationships** between events and batches, enabling precise traceability, mass balance calculations, and compliance with EPCIS event modeling.

**Attributes**

| Field Name | Data Type | Default Value | Indexes & Performance Notes | Description | Constraints & Validation Rules |
| :---- | :---- | :---- | :---- | :---- | :---- |
| **id** | integer | NULL | — | Unique identifier for the linking record | Required, unique, auto-increment |
| **events\_id** | integer | NULL | Foreign Key | Reference to Events | Required, FK to Events(id) |
| **type** | input\_output | NULL | Indexed | Whether the batch is input or output in the event | Required, ENUM (input, output) |
| **batch\_id** | integer | NULL | Foreign Key | Batch involved in the event | Required, FK to BatchesLotsSerials(id) |
| **quantity** | integer | NULL | — | Quantity of the batch being processed | Required, must be ≥ 0 |
| **unit** | varchar(50) | NULL | — | Unit of measure for the quantity | Required, must match standardized units |
| **created\_at** | TIMESTAMP | NOW() | — | Timestamp of linkage creation | Required, auto-generated |
| **updated\_at** | TIMESTAMP | NULL | — | Timestamp of last update | Optional, updated upon data modification |

**Entity Relationships**

| Relationship Type | Related Entity Name | Cardinality | Description |
| :---- | :---- | :---- | :---- |
| **Belongs To** | Events | N:1 | Each batch-event record belongs to an event |
| **Belongs To** | BatchesLotsSerials | N:1 | Each record refers to one batch involved in the event |
| **Has One Through** | Products | N:1 | Indirectly links back to product via batch |

**Business Logic & Data Exchange**

* Enables precise documentation of **batch-level movements** across events, supporting EPCIS-compatible data exchange and auditing.  
* “type” field (input/output) is critical for **transformation events** where batches may be consumed or produced.  
* “unit” aligns with the batch's declared unit or is **convertible** for proper aggregation and mass balance calculations.  
* “created\_at” provides a reliable timestamp for when the linkage was logged—not necessarily when the physical event occurred.  
* Prevent duplication with a unique constraint on “events\_id”, “BatchesLotsSerials\_id”, and “type” to avoid incorrect volume counting.  
* When integrating with external systems, this table can be exported to show detailed event participation data.  
* If discrepancies between expected and actual quantities are tracked, additional fields for “actual\_quantity” can be introduced.  
* Permissions ensure that only authorized users can create or modify this linkage in **multi-stakeholder supply chains**.

### **Events**

This entity captures **Critical Tracking Events (CTEs)** throughout the supply chain where batches undergo various processes, movements, or status changes. It serves as the temporal backbone of the traceability system, enabling comprehensive documentation of all significant occurrences that affect product provenance, quality, and compliance status. 

Directly aligned with **GS1 EPCIS Event classes** (ObjectEvent, AggregationEvent, TransformationEvent, TransactionEvent), Events ensures seamless interoperability with global traceability standards and regulatory reporting systems. It supports **real-time supply chain visibility**, **EUDR compliance monitoring**, and **forensic traceability investigations** by maintaining immutable records of when, where, who, and what occurred at each stage of the value chain. It integrates with IoT devices, mobile applications, and enterprise systems to capture events automatically or through manual data entry, supporting both high-volume processing operations and small-scale producer environments. It also enables supply chain analytics, performance optimization, risk management, and sustainability impact measurement while providing the audit trail foundation required for certification programs and regulatory compliance.

**Attributes**

| Field Name | Data Type | Default Value | Indexes & Performance Notes | Description | Constraints & Validation Rules |
| :---- | :---- | :---- | :---- | :---- | :---- |
| **id** | integer | Auto-generated | Primary Key | Unique identifier for the event record | Required, unique, auto-increment |
| **event\_type** | gs1\_event\_types | NULL | Indexed | GS1-aligned event type describing the process | Required, ENUM from GS1 CBV event types |
| **description** | VARCHAR(100) | NULL | — | Human-readable description of the event | Optional, max 100 characters |
| **timestamp** | timestamp | NULL | Indexed | Date and time when the event occurred | Required, ISO 8601 timestamp format |
| **enterprise\_id** | integer |  | Foreign Key | Enterprise responsible for the event | Required, FK to Enterprises(id) |
| **sites\_id** | integer |  | Foreign Key | Location where the event took place | Required, FK to Sites(id) |
| **record\_id** | int |  | Unique | Reference to Record metadata for audit and validation | Required, unique, FK to Records(id) |
| **created\_at** | TIMESTAMP | NOW() | — | Timestamp when the event record was created | Required, auto-generated |
| **updated\_at** | TIMESTAMP | NULL | — | Timestamp of last update | Recommended addition for audit trails |

**Entity Relationships**

| Relationship Type | Related Entity Name | Cardinality | Description |
| :---- | :---- | :---- | :---- |
| **Belongs To** | Enterprises | N:1 | Event is performed by an enterprise |
| **Belongs To** | Sites | N:1 | Event occurs at a specific site |
| **Belongs To** | Records | 1:1 | Traceability and metadata linkage |
| **Has Many** | BatchesEvents | 1:N | Links to batches involved in the event |

**Business Logic & Data Exchange**

* “event\_type” conforms to **GS1 CBV** values to enable standardization and interoperability across systems (e.g., commissioning, shipping, processing).  
* Downstream systems rely on “timestamp” for chronological ordering and creating audit trails for forensic analysis.  
* “record\_id” enables events to carry enriched metadata through Attributes for compliance purposes (e.g., certifications, lab results).  
* Data is serializable to EPCIS-compliant structures for integration with regulatory or partner systems.  
* BatchesEvents linkage allows for precise tracking of which batches participated in each event including quantities and directionality.  
* Changes to event timing or location are carefully managed to preserve historical integrity and chain of custody.  
* Integration with IoT devices, mobile apps, and enterprise systems requires standardized event capture and validation protocols.

## **GROUP 6: TRANSACTION ENTITIES**

### **BusinessTransactionsBatches**

This table serves as a **pivot table** linking batches (BatchesLotsSerials) to commercial transactions (BusinessTransactions). It enables the recording of **which batch was traded** and in what **quantity** and **unit**, during a **specific commercial transaction**. This design supports **many-to-many relationships** between transactions and batches, enabling precise commercial traceability and compliance.

**Attributes**

| Field Name | Data Type | Default Value | Indexes & Performance Notes | Description | Constraints & Validation Rules |
| :---- | :---- | :---- | :---- | :---- | :---- |
| **id** | integer | Auto-generated | Primary Key | Unique identifier for the linking record | Required, unique, auto-increment |
| **transaction\_id** | integer | NULL | Foreign Key | Reference to BusinessTransactions | Required, FK to BusinessTransactions(id) |
| **batch\_id** | integer | NULL | Foreign Key | Batch involved in the transaction | Required, FK to BatchesLotsSerials(id) |
| **transaction\_quantity** | DECIMAL(18,2) | NULL | — | Quantity of the batch being transferred | Required, must be ≥ 0 |
| **transaction\_unit** | VARCHAR(50) | NULL | — | Unit of measure for the transferred quantity | Required, must match standardized units |
| **created\_at** | TIMESTAMP | NOW() | — | Timestamp of linkage creation | Required, auto-generated |
| **updated\_at** | TIMESTAMP | NULL | — | Timestamp of last update | Optional, updated upon data modification |

**Entity Relationships**

| Relationship Type | Related Entity Name | Cardinality | Description |
| :---- | :---- | :---- | :---- |
| **Belongs To** | BusinessTransactions | N:1 | Each batch-transaction record belongs to a transaction |
| **Belongs To** | BatchesLotsSerials | N:1 | Each record refers to one batch involved in the transaction |
| **Has One Through** | Products | N:1 | Indirectly links back to product via batch |

**Business Logic & Data Exchange**

* Enables precise documentation of **batch-level commercial movements**, supporting regulatory compliance and commercial auditing.  
* Critical for **value chain analysis** and demonstrating compliance with fair trade or sustainability premium distributions.  
* “transaction\_unit” aligns with the batch's declared unit or is **convertible** for proper aggregation and financial calculations.  
* “created\_at” provides a reliable timestamp for when the commercial linkage was logged.  
* Prevent duplication with a unique constraint on “transaction\_id” and “batch\_id” to avoid incorrect volume double counting.  
* When integrating with external systems (e.g., customs, financial platforms), this table provides detailed commercial movement data.  
* If discrepancies between contracted and delivered quantities are tracked, additional fields for “actual\_quantity\_delivered” can be introduced.  
* Permissions ensure that only authorized users can create or modify this linkage, especially in **multi-stakeholder commercial environments**.

### **BusinessTransactions**

This entity captures **commercial transaction events** representing the exchange of goods and ownership between enterprises. Each record reflects a business agreement with associated order references, buyer/seller information, and traceable actor documentation. This aligns with GS1 EPCIS BusinessTransactionEvent and supports commercial traceability, ownership documentation, and regulatory audit trails.

**Attributes**

| Field Name | Data Type | Default Value | Indexes & Performance Notes | Description | Constraints & Validation Rules |
| :---- | :---- | :---- | :---- | :---- | :---- |
| **id** | INT GENERATED BY DEFAULT AS IDENTITY | Auto-generated | Primary Key | Unique identifier for the business transaction | Required, unique, auto-increment |
| **record\_id** | int |  | Unique | Reference to Records for traceability metadata | Required, unique, FK to Records(id) |
| **sales\_order\_ref** | varchar(50) | NULL | — | Reference to sales order document | Optional, unique per enterprise |
| **purchase\_order\_ref** | varchar(50) | NULL | — | Reference to purchase order document | Optional |
| **seller\_enterprise\_id** | INT | NULL | Foreign Key | Enterprise selling or transferring the product | Required, FK to Enterprises(id) |
| **buyer\_entreprise\_id** | INT | NULL | Foreign Key | Enterprise purchasing or receiving the product | Required, FK to Enterprises(id) |
| **created\_at** | TIMESTAMP | NOW() | — | Timestamp when the transaction was logged | As defined in SQL schema |
| **updated\_at** | TIMESTAMP | NULL | — | Timestamp of last update | Recommended addition for audit trails |

**Entity Relationships**

| Relationship Type | Related Entity Name | Cardinality | Description |
| :---- | :---- | :---- | :---- |
| **Belongs To** | Enterprises (seller) | N:1 | Seller enterprise is linked |
| **Belongs To** | Enterprises (buyer) | N:1 | Buyer enterprise is linked |
| **Belongs To** | Records | 1:1 | Used for metadata linkage and provenance tracking |
| **Has Many** | BusinessTransactionsBatches | 1:N | Each transaction can involve multiple batches |

**Business Logic & Data Exchange**

* Each entry references **both seller and buyer enterprises** to support complete commercial traceability.  
* Order references are validated against source systems and matched to external ERP or procurement platforms.  
* The “record\_id” enables the transaction to carry **attributes, observations,** and **source provenance** for audit and certification validation.  
* The transaction record is registered upon the conclusion of the **commercial agreement**, not necessarily upon physical movement.  
* Ownership transfer logic is clearly documented to avoid conflating commercial agreements with physical custody.  
* When batching is involved, the link to BusinessTransactionsBatches allows for **granular tracking of quantities and values**.  
* Systems must enforce access rules, especially when transactions cross **enterprise boundaries** or involve sensitive commercial data.   
* Integration with financial systems, customs platforms, and regulatory bodies requires standardized data exchange formats.

## **DATA TYPES AND ENUMERATIONS**

### **ENUM Types Defined**

#### **gs1\_event\_types**

Enumeration aligned with GS1 Core Business Vocabulary (CBV) for standardized event classification:

* Commissioning, Shipping, Receiving, Loading, Unloading, Decommissioning  
* Transformation, Processing, Harvesting, Slaughtering  
* PackingAggregation, UnpackingDisaggregation  
* Inspection, Sampling, Quarantining, Releasing, Observation

#### **input\_output**

Simple enumeration for batch flow directionality in events:

* input \- batch consumed or used as input in the event  
* output \- batch produced or resulting from the event

#### **RecordType**

Core enumeration defining the types of entities that can be registered in the Records table:

* Enterprise, Person, Site, Transaction, Event, Batch, Product, Group
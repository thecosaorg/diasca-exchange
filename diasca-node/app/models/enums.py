import enum

class PersonRole(str, enum.Enum):
    FARMER = "farmer"
    FIELD_AGENT = "field_agent"
    AUDITOR = "auditor"
    INSPECTOR = "inspector"
    PRODUCER = "producer"
    BUYER = "buyer"
    CERTIFIER = "certifier"

class EnterpriseType(str, enum.Enum):
    COOPERATIVE = "cooperative"
    PROCESSOR = "processor"
    TRADER = "trader"
    EXPORTER = "exporter"
    IMPORTER = "importer"
    RETAILER = "retailer"
    CERTIFIER = "certifier"
    GOVERNMENT = "government"
    NGO = "ngo"

class SiteType(str, enum.Enum):
    PLOT = "plot"
    FARM = "farm"
    FACTORY = "factory"
    WAREHOUSE = "warehouse"
    PROCESSING_FACILITY = "processing_facility"
    DISTRIBUTION_CENTER = "distribution_center"
    OFFICE = "office"
    PORT = "port"

class RelationshipType(str, enum.Enum):
    EMPLOYS = "employs"
    OWNS = "owns"
    MANAGES = "manages"
    MEMBER_OF = "member_of"
    SUPPLIES = "supplies"
    CERTIFIES = "certifies"
    AUDITS = "audits"

class ProductType(str, enum.Enum):
    RAW_CHERRY = "raw_cherry"
    PARCHMENT = "parchment"
    GREEN_COFFEE = "green_coffee"
    ROASTED_COFFEE = "roasted_coffee"
    COCOA_FRESH = "cocoa_fresh"
    COCOA_DRIED = "cocoa_dried"
    COCOA_PROCESSED = "cocoa_processed"
    OTHER = "other"

class LotUnit(str, enum.Enum):
    KG = "kg"
    MT = "mt"
    BAGS = "bags"
    LITERS = "liters"

class TransactionType(str, enum.Enum):
    HARVEST = "harvest"
    RECEIVE = "receive"
    AGGREGATE = "aggregate"
    PROCESS = "process"
    STORE = "store"
    TRANSFER = "transfer"
    TRANSPORT = "transport"
    SALE = "sale"
    INSPECTION = "inspection"
    CERTIFICATION = "certification"
    EXPORT_TX = "export_tx"
    IMPORT_TX = "import_tx"

class TransformationType(str, enum.Enum):
    SPLIT = "split"
    MERGE = "merge"
    PROCESS = "process"
    BLEND = "blend"
    PACKAGE = "package"
    GRADE = "grade"

class ClaimType(str, enum.Enum):
    CERTIFICATION = "certification"
    QUALITY = "quality"
    COMPLIANCE = "compliance"
    DEFORESTATION_FREE = "deforestation_free"
    RISK = "risk"
    SUSTAINABILITY = "sustainability"
    SURVEY_RESPONSE = "survey_response"
    INDICATOR = "indicator"
    OBSERVATION = "observation"

class SubjectType(str, enum.Enum):
    PERSON = "person"
    ENTERPRISE = "enterprise"
    SITE = "site"
    LOT = "lot"
    TRANSACTION = "transaction"
    CLAIM = "claim"

class ValueType(str, enum.Enum):
    STRING = "string"
    NUMBER = "number"
    BOOLEAN = "boolean"
    DATE = "date"
    JSON = "json"

class ClaimStatus(str, enum.Enum):
    PENDING = "pending"
    VERIFIED = "verified"
    DISPUTED = "disputed"
    EXPIRED = "expired"
    REVOKED = "revoked"

class EvidenceType(str, enum.Enum):
    DOCUMENT = "document"
    IMAGE = "image"
    SATELLITE = "satellite"
    AUDIT_REPORT = "audit_report"
    LAB_RESULT = "lab_result"
    SENSOR_DATA = "sensor_data"
    GPS_TRACE = "gps_trace"
    SURVEY = "survey"
    SELF_DECLARATION = "self_declaration"
    BLOCKCHAIN = "blockchain"

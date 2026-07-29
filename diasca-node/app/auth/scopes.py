from enum import Enum

class DiascaScope(str, Enum):
    PEOPLE_READ = "people:read"
    PEOPLE_CREATE = "people:create"
    PEOPLE_UPDATE = "people:update"
    PEOPLE_LINK_ENTERPRISE = "people:link_enterprise"
    
    ENTERPRISES_READ = "enterprises:read"
    ENTERPRISES_CREATE = "enterprises:create"
    ENTERPRISES_VALIDATE = "enterprises:validate"
    
    SITES_READ = "sites:read"
    SITES_CREATE = "sites:create"
    SITES_UPDATE_GEOMETRY = "sites:update_geometry"
    SITES_ATTACH_EXTERNAL_IDENTIFIER = "sites:attach_external_identifier"
    SITES_VALIDATE_GEOMETRY = "sites:validate_geometry"
    
    LOTS_READ = "lots:read"
    LOTS_CREATE = "lots:create"
    LOTS_TRANSFORM = "lots:transform"
    
    EVENTS_READ = "events:read"
    EVENTS_CREATE = "events:create"
    
    LINEAGE_READ = "lineage:read"
    LINEAGE_CREATE = "lineage:create"
    
    CLAIMS_READ = "claims:read"
    CLAIMS_CREATE = "claims:create"
    CLAIMS_VERIFY = "claims:verify"
    CLAIMS_SUPERSEDE = "claims:supersede"
    
    EVIDENCE_READ = "evidence:read"
    EVIDENCE_CREATE = "evidence:create"

# For FastAPI Security
SCOPE_DESCRIPTIONS = {
    scope.value: scope.name.replace("_", " ").title() for scope in DiascaScope
}

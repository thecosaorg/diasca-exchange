from typing import List, Optional, Any
from uuid import UUID
from pydantic import BaseModel, Field

class SplitLotRequest(BaseModel):
    input_lot_id: UUID
    output_lots: List[dict] = Field(description="List of properties for the new output lots")

class MergeLotRequest(BaseModel):
    input_lot_ids: List[UUID]
    output_lot: dict = Field(description="Properties for the merged output lot")

class AttachGeoIdRequest(BaseModel):
    identifier_type: str
    identifier_value: str
    source_system: str
    authority_type: str

class UpdateGeometryRequest(BaseModel):
    geometry: dict = Field(description="GeoJSON geometry")
    source_system: str
    authority_type: str

class ValidateGeometryRequest(BaseModel):
    geometry: dict = Field(description="GeoJSON geometry")

class VerifyClaimRequest(BaseModel):
    confidence_score: Optional[float] = None
    methodology: Optional[str] = None

class RejectClaimRequest(BaseModel):
    reason: str

class SupersedeClaimRequest(BaseModel):
    new_claim_id: UUID
    reason: str

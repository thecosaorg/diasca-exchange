from typing import Generic, TypeVar, List, Optional
from pydantic import BaseModel, ConfigDict

T = TypeVar('T')

class PaginationParams(BaseModel):
    limit: int = 100
    offset: int = 0

class PaginatedResponse(BaseModel, Generic[T]):
    items: List[T]
    total: int
    limit: int
    offset: int

class ErrorResponse(BaseModel):
    detail: str
    error_code: Optional[str] = None

class ProvenanceMixin(BaseModel):
    created_by_system: str
    created_by_actor: Optional[str] = None
    source_system: Optional[str] = None
    authority_type: Optional[str] = None
    
    model_config = ConfigDict(from_attributes=True)

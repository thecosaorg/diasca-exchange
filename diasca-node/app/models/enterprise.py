from datetime import datetime
from typing import Optional, Dict, Any
from uuid import UUID, uuid4
from sqlmodel import SQLModel, Field
from sqlalchemy.dialects.postgresql import JSONB
from sqlalchemy import Column
from app.models.enums import EnterpriseType

class EnterpriseBase(SQLModel):
    legal_name: str = Field(max_length=200)
    enterprise_type: EnterpriseType
    registration_id: Optional[str] = Field(default=None, max_length=100)
    legal_address: Optional[str] = None
    tax_id: Optional[str] = Field(default=None, max_length=100)
    gln: Optional[str] = Field(default=None, max_length=13)
    parent_enterprise_id: Optional[UUID] = Field(default=None, foreign_key="enterprise.enterprise_id")
    metadata_: Optional[Dict[str, Any]] = Field(default=None, sa_column=Column("metadata", JSONB))

class Enterprise(EnterpriseBase, table=True):
    __tablename__ = "enterprise"
    enterprise_id: UUID = Field(default_factory=uuid4, primary_key=True)
    created_at: datetime = Field(default_factory=datetime.utcnow, nullable=False)
    updated_at: Optional[datetime] = None

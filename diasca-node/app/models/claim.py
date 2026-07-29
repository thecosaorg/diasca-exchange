from datetime import datetime, date
from typing import Optional, Dict, Any
from uuid import UUID, uuid4
from sqlmodel import SQLModel, Field
from sqlalchemy.dialects.postgresql import JSONB
from sqlalchemy import Column
from app.models.enums import ClaimType, SubjectType, ValueType, ClaimStatus

class ClaimBase(SQLModel):
    type: ClaimType
    subject_type: SubjectType
    subject_id: UUID
    key: str = Field(max_length=100)
    value: Optional[str] = None
    value_type: ValueType = Field(default=ValueType.STRING)
    unit: Optional[str] = Field(default=None, max_length=50)
    category: Optional[str] = Field(default=None, max_length=100)
    status: ClaimStatus = Field(default=ClaimStatus.PENDING)
    confidence_score: Optional[float] = None
    claim_date: Optional[date] = None
    valid_from: Optional[date] = None
    valid_until: Optional[date] = None
    source: Optional[str] = Field(default=None, max_length=200)
    source_type: Optional[str] = Field(default=None, max_length=50)
    metadata_: Optional[Dict[str, Any]] = Field(default=None, sa_column=Column("metadata", JSONB))

class Claim(ClaimBase, table=True):
    __tablename__ = "claim"
    claim_id: UUID = Field(default_factory=uuid4, primary_key=True)
    created_at: datetime = Field(default_factory=datetime.utcnow, nullable=False)
    updated_at: Optional[datetime] = None

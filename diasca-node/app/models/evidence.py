from datetime import datetime, date
from typing import Optional, Dict, Any
from uuid import UUID, uuid4
from sqlmodel import SQLModel, Field
from sqlalchemy.dialects.postgresql import JSONB
from sqlalchemy import Column
from app.models.enums import EvidenceType

class EvidenceBase(SQLModel):
    claim_id: UUID = Field(foreign_key="claim.claim_id")
    type: EvidenceType
    source_name: str = Field(max_length=200)
    source_provider: Optional[str] = Field(default=None, max_length=200)
    description: Optional[str] = None
    url: Optional[str] = None
    file_hash: Optional[str] = Field(default=None, max_length=64)
    confidence_score: Optional[float] = None
    observation_date: Optional[date] = None
    submission_date: Optional[date] = None
    observation_data: Optional[Dict[str, Any]] = Field(default=None, sa_column=Column("observation_data", JSONB))
    metadata_: Optional[Dict[str, Any]] = Field(default=None, sa_column=Column("metadata", JSONB))

class Evidence(EvidenceBase, table=True):
    __tablename__ = "evidence"
    evidence_id: UUID = Field(default_factory=uuid4, primary_key=True)
    created_at: datetime = Field(default_factory=datetime.utcnow, nullable=False)
    updated_at: Optional[datetime] = None

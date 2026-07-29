from datetime import datetime, date
from typing import Optional, Dict, Any
from uuid import UUID, uuid4
from sqlmodel import SQLModel, Field
from sqlalchemy.dialects.postgresql import JSONB
from sqlalchemy import Column
from app.models.enums import RelationshipType

class RelationshipBase(SQLModel):
    type: RelationshipType
    source_person_id: Optional[UUID] = Field(default=None, foreign_key="person.person_id")
    source_enterprise_id: Optional[UUID] = Field(default=None, foreign_key="enterprise.enterprise_id")
    target_person_id: Optional[UUID] = Field(default=None, foreign_key="person.person_id")
    target_enterprise_id: Optional[UUID] = Field(default=None, foreign_key="enterprise.enterprise_id")
    site_id: Optional[UUID] = Field(default=None, foreign_key="site.site_id")
    role: Optional[str] = Field(default=None, max_length=50)
    start_date: Optional[date] = None
    end_date: Optional[date] = None
    metadata_: Optional[Dict[str, Any]] = Field(default=None, sa_column=Column("metadata", JSONB))

class Relationship(RelationshipBase, table=True):
    __tablename__ = "relationship"
    relationship_id: UUID = Field(default_factory=uuid4, primary_key=True)
    created_at: datetime = Field(default_factory=datetime.utcnow, nullable=False)
    updated_at: Optional[datetime] = None

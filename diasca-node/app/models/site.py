from datetime import datetime
from typing import Optional, Dict, Any
from uuid import UUID, uuid4
from sqlmodel import SQLModel, Field
from sqlalchemy.dialects.postgresql import JSONB
from sqlalchemy import Column
from geoalchemy2 import Geometry
from app.models.enums import SiteType

class SiteBase(SQLModel):
    name: str = Field(max_length=100)
    type: SiteType
    parent_id: Optional[UUID] = Field(default=None, foreign_key="site.site_id")
    owner_person_id: Optional[UUID] = Field(default=None, foreign_key="person.person_id")
    owner_enterprise_id: Optional[UUID] = Field(default=None, foreign_key="enterprise.enterprise_id")
    address: Optional[str] = None
    latitude: Optional[float] = None
    longitude: Optional[float] = None
    altitude: Optional[float] = None
    size: Optional[float] = None
    size_unit: Optional[str] = Field(default="hectares", max_length=20)
    country: Optional[str] = Field(default=None, max_length=2)
    region: Optional[str] = Field(default=None, max_length=100)
    is_headquarters: Optional[bool] = Field(default=False)
    metadata_: Optional[Dict[str, Any]] = Field(default=None, sa_column=Column("metadata", JSONB))

class Site(SiteBase, table=True):
    __tablename__ = "site"
    site_id: UUID = Field(default_factory=uuid4, primary_key=True)
    geometry: Optional[Any] = Field(default=None, sa_column=Column(Geometry(geometry_type="GEOMETRY", srid=4326)))
    created_at: datetime = Field(default_factory=datetime.utcnow, nullable=False)
    updated_at: Optional[datetime] = None

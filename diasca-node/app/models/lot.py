from datetime import datetime, date
from typing import Optional, Dict, Any
from uuid import UUID, uuid4
from sqlmodel import SQLModel, Field
from sqlalchemy.dialects.postgresql import JSONB
from sqlalchemy import Column
from app.models.enums import ProductType, LotUnit

class LotBase(SQLModel):
    product_type: ProductType
    origin_site_id: UUID = Field(foreign_key="site.site_id")
    harvest_date: Optional[date] = None
    harvest_date_end: Optional[date] = None
    quantity: float
    unit: LotUnit
    owner_enterprise_id: UUID = Field(foreign_key="enterprise.enterprise_id")
    batch_number: Optional[str] = Field(default=None, max_length=100)
    disposition: Optional[str] = Field(default=None, max_length=50)
    metadata_: Optional[Dict[str, Any]] = Field(default=None, sa_column=Column("metadata", JSONB))

class Lot(LotBase, table=True):
    __tablename__ = "lot"
    lot_id: UUID = Field(default_factory=uuid4, primary_key=True)
    created_at: datetime = Field(default_factory=datetime.utcnow, nullable=False)
    updated_at: Optional[datetime] = None

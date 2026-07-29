from datetime import datetime
from typing import Optional, Dict, Any
from uuid import UUID, uuid4
from sqlmodel import SQLModel, Field
from sqlalchemy.dialects.postgresql import JSONB
from sqlalchemy import Column
from app.models.enums import TransformationType

class LotLineageBase(SQLModel):
    event_id: UUID = Field(foreign_key="transaction.transaction_id")
    input_lot_id: UUID = Field(foreign_key="lot.lot_id")
    output_lot_id: UUID = Field(foreign_key="lot.lot_id")
    input_qty: float
    output_qty: float
    transformation_type: TransformationType
    conversion_factor: Optional[float] = None
    metadata_: Optional[Dict[str, Any]] = Field(default=None, sa_column=Column("metadata", JSONB))

class LotLineage(LotLineageBase, table=True):
    __tablename__ = "lot_lineage"
    lineage_id: UUID = Field(default_factory=uuid4, primary_key=True)
    created_at: datetime = Field(default_factory=datetime.utcnow, nullable=False)

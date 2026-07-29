from datetime import datetime, date
from typing import Optional, Dict, Any
from uuid import UUID, uuid4
from sqlmodel import SQLModel, Field
from sqlalchemy.dialects.postgresql import JSONB
from sqlalchemy import Column
from app.models.enums import TransactionType

class TransactionBase(SQLModel):
    type: TransactionType
    description: Optional[str] = Field(default=None, max_length=200)
    timestamp: datetime
    source_enterprise_id: Optional[UUID] = Field(default=None, foreign_key="enterprise.enterprise_id")
    target_enterprise_id: Optional[UUID] = Field(default=None, foreign_key="enterprise.enterprise_id")
    source_site_id: Optional[UUID] = Field(default=None, foreign_key="site.site_id")
    target_site_id: Optional[UUID] = Field(default=None, foreign_key="site.site_id")
    lot_id: Optional[UUID] = Field(default=None, foreign_key="lot.lot_id")
    
    # Embedded product fields
    product_name: Optional[str] = Field(default=None, max_length=100)
    product_sku: Optional[str] = Field(default=None, max_length=100)
    product_gtin: Optional[str] = Field(default=None, max_length=14)
    product_category: Optional[str] = Field(default=None, max_length=100)
    quantity: Optional[float] = None
    unit: Optional[str] = Field(default=None, max_length=50)
    production_date: Optional[date] = None
    expiry_date: Optional[date] = None
    
    sales_order_ref: Optional[str] = Field(default=None, max_length=50)
    purchase_order_ref: Optional[str] = Field(default=None, max_length=50)
    metadata_: Optional[Dict[str, Any]] = Field(default=None, sa_column=Column("metadata", JSONB))

class Transaction(TransactionBase, table=True):
    __tablename__ = "transaction"
    transaction_id: UUID = Field(default_factory=uuid4, primary_key=True)
    created_at: datetime = Field(default_factory=datetime.utcnow, nullable=False)
    updated_at: Optional[datetime] = None

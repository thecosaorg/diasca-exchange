from datetime import datetime
from typing import Optional, List
from uuid import UUID, uuid4
from sqlmodel import SQLModel, Field, Relationship

class PlatformScopeBase(SQLModel):
    scope: str = Field(max_length=100)

class PlatformScope(PlatformScopeBase, table=True):
    __tablename__ = "platform_scope"
    id: UUID = Field(default_factory=uuid4, primary_key=True)
    platform_id: UUID = Field(foreign_key="platform.platform_id")

class PlatformBase(SQLModel):
    name: str = Field(max_length=100, unique=True)
    client_id: str = Field(max_length=100, unique=True)
    client_secret_hash: str = Field(max_length=255)
    is_active: bool = Field(default=True)

class Platform(PlatformBase, table=True):
    __tablename__ = "platform"
    platform_id: UUID = Field(default_factory=uuid4, primary_key=True)
    created_at: datetime = Field(default_factory=datetime.utcnow, nullable=False)
    updated_at: Optional[datetime] = None
    
    scopes: List[PlatformScope] = Relationship(sa_relationship_kwargs={"cascade": "all, delete-orphan"})

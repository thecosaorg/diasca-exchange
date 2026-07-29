import os
from fastapi import APIRouter, Request, Depends, Form
from fastapi.responses import HTMLResponse, RedirectResponse
from fastapi.templating import Jinja2Templates
from sqlalchemy.ext.asyncio import AsyncSession
from sqlmodel import select
import secrets
import hashlib
import uuid

from app.database import get_session
from app.models.platform import Platform
from app.auth.scopes import SCOPE_DESCRIPTIONS

router = APIRouter(prefix="/admin", tags=["Admin UI"])

# Get the directory of the current file
current_dir = os.path.dirname(os.path.abspath(__file__))
templates_dir = os.path.join(current_dir, "templates")

templates = Jinja2Templates(directory=templates_dir)

@router.get("/platforms", response_class=HTMLResponse)
async def list_platforms(request: Request, session: AsyncSession = Depends(get_session)):
    result = await session.execute(select(Platform))
    platforms = result.scalars().all()
    return templates.TemplateResponse(request=request, name="platforms.html", context={"platforms": platforms})

@router.post("/platforms")
async def create_platform(request: Request, name: str = Form(...), session: AsyncSession = Depends(get_session)):
    # Generate credentials
    client_id = f"client_{secrets.token_hex(8)}"
    client_secret = secrets.token_urlsafe(32)
    client_secret_hash = hashlib.sha256(client_secret.encode()).hexdigest()
    
    # Create DB record
    new_platform = Platform(
        platform_id=uuid.uuid4(),
        name=name,
        client_id=client_id,
        client_secret_hash=client_secret_hash,
        is_active=True
    )
    
    session.add(new_platform)
    await session.commit()
    
    # Fetch platforms to re-render the page
    result = await session.execute(select(Platform))
    platforms = result.scalars().all()
    
    # Render with the new credentials so the user can copy the secret
    return templates.TemplateResponse(
        request=request, 
        name="platforms.html", 
        context={
            "platforms": platforms,
            "new_client_id": client_id,
            "new_client_secret": client_secret
        }
    )

@router.get("/scopes", response_class=HTMLResponse)
async def list_scopes(request: Request, platform: str = None, session: AsyncSession = Depends(get_session)):
    # Group SCOPE_DESCRIPTIONS by prefix
    grouped_scopes = {}
    for scope_id, desc in SCOPE_DESCRIPTIONS.items():
        prefix = scope_id.split(":")[0].title()
        if prefix not in grouped_scopes:
            grouped_scopes[prefix] = {}
        grouped_scopes[prefix][scope_id] = desc
        
    return templates.TemplateResponse(request=request, name="scopes.html", context={
        "grouped_scopes": grouped_scopes,
        "platform_id": platform
    })

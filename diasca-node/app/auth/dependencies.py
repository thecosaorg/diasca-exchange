from fastapi import Depends, HTTPException, status, Security
from fastapi.security import OAuth2PasswordBearer, SecurityScopes
from app.auth.jwt import decode_access_token
from app.auth.scopes import SCOPE_DESCRIPTIONS

oauth2_scheme = OAuth2PasswordBearer(
    tokenUrl="token",
    scopes=SCOPE_DESCRIPTIONS,
)

async def get_current_platform(
    security_scopes: SecurityScopes, token: str = Depends(oauth2_scheme)
):
    if security_scopes.scopes:
        authenticate_value = f'Bearer scope="{security_scopes.scope_str}"'
    else:
        authenticate_value = "Bearer"
        
    credentials_exception = HTTPException(
        status_code=status.HTTP_401_UNAUTHORIZED,
        detail="Could not validate credentials",
        headers={"WWW-Authenticate": authenticate_value},
    )
    
    payload = decode_access_token(token)
    if payload is None:
        raise credentials_exception
        
    platform_id: str = payload.get("sub")
    if platform_id is None:
        raise credentials_exception
        
    token_scopes = payload.get("scopes", [])
    
    # Check if the token has the required scopes
    for scope in security_scopes.scopes:
        if scope not in token_scopes:
            raise HTTPException(
                status_code=status.HTTP_403_FORBIDDEN,
                detail="Not enough permissions",
                headers={"WWW-Authenticate": authenticate_value},
            )
            
    # In a real implementation, we would fetch the platform from the DB here
    return {"platform_id": platform_id, "scopes": token_scopes}

def require_scopes(*scopes: str):
    """
    Dependency to require specific scopes for an endpoint.
    Example: Depends(require_scopes(DiascaScope.SITES_READ, DiascaScope.SITES_CREATE))
    """
    return Security(get_current_platform, scopes=list(scopes))

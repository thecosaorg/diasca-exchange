from fastapi import APIRouter

router = APIRouter(prefix="/enterprises", tags=["Enterprises"])

@router.get("/")
async def list_enterprises():
    return {"message": "List enterprises endpoint"}

@router.post("/")
async def create_enterprise():
    return {"message": "Create enterprise endpoint"}

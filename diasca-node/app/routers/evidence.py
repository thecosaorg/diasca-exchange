from fastapi import APIRouter

router = APIRouter(prefix="/evidence", tags=["Evidence"])

@router.get("/")
async def list_evidence():
    return {"message": "List evidence endpoint"}

@router.post("/")
async def create_evidence():
    return {"message": "Create evidence endpoint"}

from fastapi import APIRouter

router = APIRouter(prefix="/claims", tags=["Claims"])

@router.get("/")
async def list_claims():
    return {"message": "List claims endpoint"}

@router.post("/")
async def create_claim():
    return {"message": "Create claim endpoint"}

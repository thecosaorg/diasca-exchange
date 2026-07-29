from fastapi import APIRouter

router = APIRouter(prefix="/lots", tags=["Lots"])

@router.get("/")
async def list_lots():
    return {"message": "List lots endpoint"}

@router.post("/")
async def create_lot():
    return {"message": "Create lot endpoint"}

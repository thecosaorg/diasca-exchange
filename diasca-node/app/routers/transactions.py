from fastapi import APIRouter

router = APIRouter(prefix="/transactions", tags=["Transactions"])

@router.get("/")
async def list_transactions():
    return {"message": "List transactions endpoint"}

@router.post("/")
async def create_transaction():
    return {"message": "Create transaction endpoint"}

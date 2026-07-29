from fastapi import APIRouter

router = APIRouter(prefix="/people", tags=["People"])

@router.get("/")
async def list_people():
    return {"message": "List people endpoint"}

@router.post("/")
async def create_person():
    return {"message": "Create person endpoint"}

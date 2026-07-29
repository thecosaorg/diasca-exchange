from fastapi import APIRouter

router = APIRouter(tags=["System"])

@router.get("/ready")
async def readiness_check():
    # TODO: Check DB connection
    return {"status": "ready"}

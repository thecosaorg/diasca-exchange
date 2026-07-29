from fastapi import APIRouter

from .health import router as health_router
from .sites import router as sites_router
from .people import router as people_router
from .enterprises import router as enterprises_router
from .lots import router as lots_router
from .transactions import router as transactions_router
from .claims import router as claims_router
from .evidence import router as evidence_router

router = APIRouter()
router.include_router(health_router)
router.include_router(sites_router, prefix="/v2")
router.include_router(people_router, prefix="/v2")
router.include_router(enterprises_router, prefix="/v2")
router.include_router(lots_router, prefix="/v2")
router.include_router(transactions_router, prefix="/v2")
router.include_router(claims_router, prefix="/v2")
router.include_router(evidence_router, prefix="/v2")

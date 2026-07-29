from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI(
    title="DIASCA DPI Node",
    description="Reference API for the DIASCA Digital Public Infrastructure",
    version="0.1.0",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

from app.routers import router as api_router
from app.admin import router as admin_router

app.include_router(api_router)
app.include_router(admin_router)

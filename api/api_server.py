# ------------------------------------------------------------
# NookMesh API
# FastAPI bootstrap / router registration
# ------------------------------------------------------------

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from geojson_filter import router as geojson_router
from assets import router as assets_router

# ------------------------------------------------------------
# Application
# ------------------------------------------------------------
app = FastAPI(
    title="NookMesh API"
)

# ------------------------------------------------------------
# Middleware
# ------------------------------------------------------------
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_methods=["*"],
    allow_headers=["*"],
)

# ------------------------------------------------------------
# Routes
# ------------------------------------------------------------
app.include_router(geojson_router)
app.include_router(assets_router)
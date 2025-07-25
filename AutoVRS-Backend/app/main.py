# app/main.py
from fastapi import FastAPI, Depends, HTTPException # type: ignore
from fastapi.middleware.cors import CORSMiddleware # type: ignore
from app.database.database import init_db
from app.api.endpoints import models, lots, boards, defects, config, system

# Initialize FastAPI app
app = FastAPI(
    title="AutoVRS Backend API",
    description="Visual Recognition System Backend API",
    version="1.0.0",
    docs_url="/docs",
    redoc_url="/redoc"
)

# CORS middleware for Flutter frontend
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Allow Flutter app connections
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Initialize database on startup
@app.on_event("startup")
async def startup_event():
    init_db()
    print("🚀 AutoVRS Backend API started successfully!")

# Include API routers
app.include_router(models.router, prefix="/api/models", tags=["Models"])
app.include_router(lots.router, prefix="/api/lots", tags=["Lots"])
app.include_router(boards.router, prefix="/api/boards", tags=["Boards"])
app.include_router(defects.router, prefix="/api/defects", tags=["Defects"])
app.include_router(config.router, prefix="/api/config", tags=["Configuration"])
app.include_router(system.router, prefix="/api/system", tags=["System"])

# Root endpoint
@app.get("/")
async def root():
    return {
        "message": "AutoVRS Backend API",
        "version": "1.0.0",
        "status": "running",
        "docs": "/docs"
    }

# Health check endpoint
@app.get("/health")
async def health_check():
    return {
        "status": "healthy",
        "version": "1.0.0",
        "database": "connected"
    }

if __name__ == "__main__":
    import uvicorn
    print("🔥 Starting AutoVRS Backend Server...")
    print("📡 API Documentation: http://localhost:8000/docs")
    print("🏠 Home Screen API: http://localhost:8000/api/system/status")
    uvicorn.run(app, host="0.0.0.0", port=8000, reload=True)# type: ignore

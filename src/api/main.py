from typing import Dict
from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from src.api.routes import photons

app = FastAPI(
    title="Black Hole Visualizer API",
    description="High-performance bridge between BigQuery and Three.js visualizer.",
    version="1.0.0"
)

# Configure CORS to allow the React/Three.js frontend to communicate with the API
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Security: In production, substitute with specific domain(s)
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Register specialized routers for different domain entities
app.include_router(photons.router)


@app.get("/health")
async def health_check() -> Dict[str, str]:
    """Provides the current operational status of the API bridge.

    Returns:
        A dictionary containing the status and the core physics model being served.
    """
    return {"status": "online", "model": "Schwarzschild Metric"}


if __name__ == "__main__":
    import uvicorn
    # Direct execution entry point for development environments
    uvicorn.run("main:app", host="0.0.0.0", port=8000, reload=True)

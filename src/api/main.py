from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from src.api.routes import photons

app = FastAPI(
    title="Black Hole Visualizer API",
    description="High-performance bridge between BigQuery and Three.js visualizer.",
    version="1.0.0"
)

# Configure CORS for React/Three.js frontend
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # In production, specify actual domain
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Include Routers
app.include_router(photons.router)

@app.get("/health")
async def health_check():
    return {"status": "online", "model": "Schwarzschild Metric"}

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8000)

from fastapi import APIRouter, HTTPException
from src.api.services.bigquery_service import bq_service
from typing import List, Dict, Any

router = APIRouter(prefix="/v1/photons", tags=["photons"])

@router.get("/{photon_id}")
async def get_photon(photon_id: int):
    """
    Get the complete geodesic path for a specific photon.
    """
    path = await bq_service.get_photon_path(photon_id)
    if not path:
        raise HTTPException(status_code=404, detail=f"Photon {photon_id} not found in BigQuery")
    return {"photon_id": photon_id, "path": path}

@router.get("/sample/batch")
async def get_sample(limit: int = 50):
    """
    Get a batch of photon paths for initial rendering.
    """
    paths = await bq_service.get_sample_paths(limit)
    # Re-group by photon_id for easier frontend consumption
    grouped = {}
    for row in paths:
        p_id = row['photon_id']
        if p_id not in grouped:
            grouped[p_id] = []
        grouped[p_id].append({
            "step": row['step'],
            "r": row['r'],
            "theta": row['theta'],
            "phi": row['phi']
        })
    
    return {"count": len(grouped), "photons": grouped}

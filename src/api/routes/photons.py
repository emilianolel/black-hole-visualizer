from typing import List, Dict, Any, Union
from fastapi import APIRouter, HTTPException
from src.api.services.bigquery_service import bq_service

router = APIRouter(prefix="/v1/photons", tags=["photons"])


@router.get("/{photon_id}")
async def get_photon(photon_id: int) -> Dict[str, Union[int, List[Dict[str, Any]]]]:
    """Retrieves the complete geodesic path for a specific photon.

    Args:
        photon_id: Unique identifier for the simulated photon.

    Returns:
        A dictionary containing the photon ID and its full path array.

    Raises:
        HTTPException: If the photon is not found in the BigQuery warehouse.
    """
    path = await bq_service.get_photon_path(photon_id)
    if not path:
        raise HTTPException(
            status_code=404, 
            detail=f"Photon {photon_id} not found in BigQuery"
        )
    return {"photon_id": photon_id, "path": path}


@router.get("/sample/batch")
async def get_sample(limit: int = 50) -> Dict[str, Any]:
    """Retrieves a batch of multiple photon paths for initial 3D rendering.

    This endpoint groups raw BigQuery rows into a structured dictionary keyed 
    by photon_id to simplify frontend consumption.

    Args:
        limit: The maximum number of distinct photons to retrieve.

    Returns:
        A dictionary with 'count' and a 'photons' map {id: [step_data, ... ]}.
    """
    paths = await bq_service.get_sample_paths(limit)
    
    # Re-group by photon_id for easier consumption by Three.js line renderers
    grouped_paths: Dict[int, List[Dict[str, Any]]] = {}
    for row in paths:
        p_id = row['photon_id']
        if p_id not in grouped_paths:
            grouped_paths[p_id] = []
        
        grouped_paths[p_id].append({
            "step": row['step'],
            "r": row['r'],
            "theta": row['theta'],
            "phi": row['phi']
        })
    
    return {"count": len(grouped_paths), "photons": grouped_paths}

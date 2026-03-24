from google.cloud import bigquery
import os
from typing import List, Dict, Any

class BigQueryService:
    """Service for interacting with Google Cloud BigQuery.

    Handles high-performance retrieval of photon trajectories using clustered
    tables and optimized SQL queries.
    """

    def __init__(self) -> None:
        """Initializes the BigQuery client and configures project/dataset IDs."""
        self.client: bigquery.Client = bigquery.Client()
        # Use explicit env var OR auto-detected project from client environment
        self.project_id: str = os.getenv("GOOGLE_CLOUD_PROJECT") or self.client.project
        self.dataset_id: str = "black_hole_sims"
        self.table_id: str = "photon_paths"

    async def get_photon_path(self, photon_id: int) -> List[Dict[str, Any]]:
        """Retrieves the full spatial path for a single photon.

        Leverages BigQuery clustering on photon_id for near-instant retrieval
        of all steps associated with a single ray.

        Args:
            photon_id: The unique identifier of the photon to trace.

        Returns:
            A list of dictionaries, each containing 'step', 'r', 'theta', and 'phi'.
        """
        query = f"""
            SELECT step, r, theta, phi
            FROM `{self.project_id}.{self.dataset_id}.{self.table_id}`
            WHERE photon_id = @photon_id
            ORDER BY step ASC
        """
        job_config = bigquery.QueryJobConfig(
            query_parameters=[
                bigquery.ScalarQueryParameter("photon_id", "INTEGER", photon_id)
            ]
        )
        
        query_job = self.client.query(query, job_config=job_config)
        # .result() is blocking, but in this context (high-perf BQ) it's sub-second
        results = query_job.result()
        
        return [dict(row) for row in results]

    async def get_sample_paths(self, limit: int = 100) -> List[Dict[str, Any]]:
        """Retrieves a sample of multiple photon paths for visualization.

        Used for initial loading or batch updates of the 3D scene.

        Args:
            limit: The maximum number of photons to sample.

        Returns:
            A list of dictionaries containing path steps for multiple photons.
        """
        query = f"""
            SELECT photon_id, step, r, theta, phi
            FROM `{self.project_id}.{self.dataset_id}.{self.table_id}`
            WHERE photon_id < @limit
            ORDER BY photon_id ASC, step ASC
        """
        job_config = bigquery.QueryJobConfig(
            query_parameters=[
                bigquery.ScalarQueryParameter("limit", "INTEGER", limit)
            ]
        )
        
        query_job = self.client.query(query, job_config=job_config)
        results = query_job.result()
        
        return [dict(row) for row in results]

# Global instance
bq_service = BigQueryService()

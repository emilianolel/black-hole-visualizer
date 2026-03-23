from google.cloud import bigquery
import os
from typing import List, Dict, Any

class BigQueryService:
    def __init__(self):
        self.client = bigquery.Client()
        self.project_id = os.getenv("GOOGLE_CLOUD_PROJECT")
        self.dataset_id = "black_hole_sims"
        self.table_id = "photon_paths"

    async def get_photon_path(self, photon_id: int) -> List[Dict[str, Any]]:
        """
        Retrieves the full spatial path for a single photon.
        Leverages clustering on photon_id for near-instant retrieval.
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
        results = query_job.result()
        
        return [dict(row) for row in results]

    async def get_sample_paths(self, limit: int = 100) -> List[Dict[str, Any]]:
        """
        Retrieves a sample of photon paths for initial visualization.
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

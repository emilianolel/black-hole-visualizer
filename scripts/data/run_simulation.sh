#!/bin/bash
# run_simulation.sh — Submits the ray-tracing physics job to Dataproc.

# Load Project Configuration
PROJECT_ID=$(gcloud config get-value project 2>/dev/null)
REGION="northamerica-northeast2"
ENV=${1:-dev}
CLUSTER_NAME="${ENV}-dataproc-cluster"

echo "----------------------------------------------------"
echo "🚀 Submitting Black Hole Simulation (Phase 2)"
echo "Cluster: $CLUSTER_NAME"
echo "----------------------------------------------------"

# 1. Stage the files in GCS (Mirroring Standard)
echo "Synchronizing engine code to GCS..."
BUCKET_NAME="black-hole-visualizer-project-bh-vis-dataproc-config"
gcloud storage cp "src/engine/integrator.py" "gs://${BUCKET_NAME}/deploy/src/engine/integrator.py" --quiet
gcloud storage cp "src/engine/simulation_job.py" "gs://${BUCKET_NAME}/deploy/src/engine/simulation_job.py" --quiet
echo "Sync Complete."

# 2. Submit PySpark Job
# Note: We include integrator.py as a py-file so Spark can distribute it to executors.
echo "Launching distributed Spark job..."
gcloud dataproc jobs submit pyspark \
    "gs://${BUCKET_NAME}/deploy/src/engine/simulation_job.py" \
    --cluster="$CLUSTER_NAME" \
    --region="$REGION" \
    --project="$PROJECT_ID" \
    --py-files="gs://${BUCKET_NAME}/deploy/src/engine/integrator.py" \
    --jars="gs://spark-lib/bigquery/spark-bigquery-latest_2.12.jar" # Ready for Phase 3

echo "----------------------------------------------------"
echo "✅ Job submitted! Monitor progress in the GCP Console."
echo "----------------------------------------------------"

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
# We include integrator.py as a py-file so Spark can distribute it to executors.
# We increase memory properties to avoid SIGKILL (memory pressure) errors.
echo "Launching distributed Spark job..."
gcloud dataproc jobs submit pyspark \
    "gs://${BUCKET_NAME}/deploy/src/engine/simulation_job.py" \
    --cluster="$CLUSTER_NAME" \
    --region="$REGION" \
    --project="$PROJECT_ID" \
    --py-files="gs://${BUCKET_NAME}/deploy/src/engine/integrator.py" \
    --jars="gs://spark-lib/bigquery/spark-bigquery-latest_2.12.jar" \
    --properties="spark.driver.memory=1g,spark.executor.memory=1g,spark.executor.memoryOverhead=512m,spark.sql.execution.arrow.pyspark.enabled=true"

echo "----------------------------------------------------"
echo "✅ Job submitted! Monitor progress in the GCP Console."
echo "----------------------------------------------------"

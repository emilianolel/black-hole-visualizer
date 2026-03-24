#!/bin/bash
# run_simulation.sh — Submits the ray-tracing physics job to Google Cloud Dataproc.
#
# Usage: ./scripts/data/run_simulation.sh [dev|prod]

set -euo pipefail

# --- Configuration ---
readonly PROJECT_ID="$(gcloud config get-value project 2>/dev/null)"
readonly REGION="northamerica-northeast2"
readonly CLUSTER_ENV="${1:-dev}"
readonly CLUSTER_NAME="${CLUSTER_ENV}-dataproc-cluster"

readonly CONFIG_BUCKET="black-hole-visualizer-project-bh-vis-dataproc-config"
readonly TEMP_BUCKET="black-hole-visualizer-project-bh-vis-dataproc-temp"
readonly OUTPUT_PATH="gs://${TEMP_BUCKET}/simulations/output/parquet"

function sync_engine_code() {
    echo "----------------------------------------------------"
    echo "🚀 Synchronizing engine code to GCS..."
    gcloud storage cp "src/engine/integrator.py" "gs://${CONFIG_BUCKET}/deploy/src/engine/integrator.py" --quiet
    gcloud storage cp "src/engine/simulation_job.py" "gs://${CONFIG_BUCKET}/deploy/src/engine/simulation_job.py" --quiet
    echo "✅ Sync Complete."
}

function submit_pyspark_job() {
    echo "----------------------------------------------------"
    echo "📡 Launching distributed Spark job on: ${CLUSTER_NAME}"
    echo "----------------------------------------------------"

    # Submit job using optimized Spark configuration for large-scale ray-tracing
    gcloud dataproc jobs submit pyspark \
        "gs://${CONFIG_BUCKET}/deploy/src/engine/simulation_job.py" \
        --cluster="${CLUSTER_NAME}" \
        --region="${REGION}" \
        --project="${PROJECT_ID}" \
        --py-files="gs://${CONFIG_BUCKET}/deploy/src/engine/integrator.py" \
        --properties="spark.driver.memory=4g,spark.executor.memory=4g,spark.driver.maxResultSize=2g,spark.sql.execution.arrow.pyspark.enabled=true,spark.driver.memoryOverhead=1024,spark.executor.memoryOverhead=1024" \
        -- \
        --output="${OUTPUT_PATH}"

    echo "----------------------------------------------------"
    echo "✅ Job submitted successfully!"
}

# --- Main ---
sync_engine_code
submit_pyspark_job

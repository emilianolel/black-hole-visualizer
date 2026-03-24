#!/bin/bash
# run_ingestion.sh — Submits the GCS-to-BigQuery ingestion job to Google Cloud Dataproc.
#
# Usage: ./scripts/data/run_ingestion.sh [dev|prod] [append|overwrite]

set -euo pipefail

# --- Configuration ---
readonly PROJECT_ID="$(gcloud config get-value project 2>/dev/null)"
readonly REGION="northamerica-northeast2"
readonly CLUSTER_ENV="${1:-dev}"
readonly INGEST_MODE="${2:-append}"
readonly CLUSTER_NAME="${CLUSTER_ENV}-dataproc-cluster"

# Specific Buckets from Terraform
readonly CONFIG_BUCKET="black-hole-visualizer-project-bh-vis-dataproc-config"
readonly TEMP_BUCKET="black-hole-visualizer-project-bh-vis-dataproc-temp"
readonly SOURCE_PATH="gs://${TEMP_BUCKET}/simulations/output/parquet"

function sync_ingestion_code() {
    echo "----------------------------------------------------"
    echo "🚀 Synchronizing ingestion code to GCS..."
    gcloud storage cp "src/engine/ingestion_job.py" "gs://${CONFIG_BUCKET}/deploy/src/engine/ingestion_job.py" --quiet
    echo "✅ Sync Complete."
}

function submit_ingestion_job() {
    echo "----------------------------------------------------"
    echo "📡 Launching Data Ingestion Job: ${CLUSTER_NAME}"
    echo "Mode:   ${INGEST_MODE}"
    echo "----------------------------------------------------"

    # Use the official Google Cloud Spark-BigQuery connector
    # indirectWrite is enabled via temporaryGcsBucket
    gcloud dataproc jobs submit pyspark \
        "gs://${CONFIG_BUCKET}/deploy/src/engine/ingestion_job.py" \
        --cluster="${CLUSTER_NAME}" \
        --region="${REGION}" \
        --properties="spark.datasource.bigquery.temporaryGcsBucket=${TEMP_BUCKET},spark.jars.packages=com.google.cloud.spark:spark-bigquery-with-dependencies_2.12:0.29.0" \
        -- \
        --source="${SOURCE_PATH}" \
        --mode="${INGEST_MODE}"

    echo "----------------------------------------------------"
    echo "✅ Ingestion process submitted successfully!"
}

# --- Main ---
sync_ingestion_code
submit_ingestion_job

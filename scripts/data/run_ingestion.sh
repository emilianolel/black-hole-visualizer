#!/bin/bash
# run_ingestion.sh — Submits the GCS-to-BigQuery ingestion job to Dataproc.

# Load Project Configuration
PROJECT_ID=$(gcloud config get-value project 2>/dev/null)
REGION="northamerica-northeast2"
ENV=${1:-dev}
MODE=${2:-append}
CLUSTER_NAME="${ENV}-dataproc-cluster"

# Specific Buckets from Terraform
CONFIG_BUCKET="black-hole-visualizer-project-bh-vis-dataproc-config"
TEMP_BUCKET="black-hole-visualizer-project-bh-vis-dataproc-temp"
SOURCE_PATH="gs://${TEMP_BUCKET}/simulations/output/parquet"

echo "----------------------------------------------------"
echo "🚀 Submitting Data Ingestion Job (Phase 3)"
echo "Cluster: $CLUSTER_NAME"
echo "Mode:    $MODE"
echo "Source:  $SOURCE_PATH"
echo "----------------------------------------------------"

# 1. Stage the ingestion script in GCS
echo "Synchronizing ingestion code to GCS..."
gcloud storage cp "src/engine/ingestion_job.py" "gs://${CONFIG_BUCKET}/deploy/src/engine/ingestion_job.py" --quiet
echo "Sync Complete."

# 2. Submit PySpark Job with BigQuery Connector
# We use the spark.jars.packages property to download the official Spark-BigQuery connector.
# We also set the temporaryGcsBucket required for indirect writes.
echo "Launching ingestion job..."
gcloud dataproc jobs submit pyspark \
    "gs://${CONFIG_BUCKET}/deploy/src/engine/ingestion_job.py" \
    --cluster="$CLUSTER_NAME" \
    --region="$REGION" \
    --properties="spark.datasource.bigquery.temporaryGcsBucket=${TEMP_BUCKET},spark.jars.packages=com.google.cloud.spark:spark-bigquery-with-dependencies_2.12:0.29.0" \
    -- \
    --source="$SOURCE_PATH" \
    --mode="$MODE"

echo "----------------------------------------------------"
echo "✅ Ingestion process finished."
echo "----------------------------------------------------"

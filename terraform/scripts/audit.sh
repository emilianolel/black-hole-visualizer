#!/usr/bin/env bash
###############################################################################
# audit.sh — Quick audit of active resources in the GCP project
# Usage: bash scripts/audit.sh [PROJECT_ID]
###############################################################################

set -euo pipefail

# Get PROJECT_ID from argument or current gcloud config
PROJECT_ID="${1:-$(gcloud config get-value project)}"

echo "🔍 AUDIT: Black Hole Visualizer Resources"
echo "----------------------------------------------------------"
echo "🛰️  Project: $PROJECT_ID"
echo "----------------------------------------------------------"

echo "📦 Cloud Storage (Buckets):"
gcloud storage buckets list --project="${PROJECT_ID}" --format="value(name)" || echo "   - None"
echo ""

echo "📊 BigQuery (Datasets):"
bq ls --project_id "${PROJECT_ID}" --format=sparse | grep -v "datasetId" | grep -v "\-\-\-" || echo "   - None"
echo ""

echo "🖥️  Compute Engine (Instances):"
gcloud compute instances list --project="${PROJECT_ID}" --format="table(name, zone, status, networkInterfaces[0].accessConfigs[0].natIP:label=EXTERNAL_IP)" 2>/dev/null || echo "   - None"
echo ""

echo "🤖 Dataproc (Clusters):"
gcloud dataproc clusters list --project="${PROJECT_ID}" --region=northamerica-northeast2 --format="table(clusterName, status.state, config.masterConfig.machineType)" 2>/dev/null || echo "   - None (northamerica-northeast2)"
echo ""

echo "🌐 Networking (VPCs):"
gcloud compute networks list --project="${PROJECT_ID}" --format="value(name)" 2>/dev/null || echo "   - None"
echo ""

echo "🔌 Enabled APIs (Core services):"
gcloud services list --project="${PROJECT_ID}" --enabled --filter="name:googleapis.com" --format="value(config.title)" 2>/dev/null | grep -E "Compute|Storage|BigQuery|Dataproc|IAM" || echo "   - None"
echo ""

echo "👤 Service Accounts (Human-readable):"
gcloud iam service-accounts list --project="${PROJECT_ID}" --format="value(email)" | grep -E "terraform-admin|dataproc-worker" || echo "   - No relevant SAs found"

echo "----------------------------------------------------------"
echo "✅ Audit complete."

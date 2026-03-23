#!/usr/bin/env bash
###############################################################################
# audit.sh — Auditoría rápida de recursos activos en el proyecto GCP
# Uso: bash scripts/audit.sh [PROJECT_ID]
###############################################################################

set -euo pipefail

# Obtener PROJECT_ID del argumento o de la configuración actual de gcloud
PROJECT_ID="${1:-$(gcloud config get-value project)}"

echo "🔍 AUDIT: Black Hole Visualizer Resources"
echo "----------------------------------------------------------"
echo "🛰️  Project: $PROJECT_ID"
echo "----------------------------------------------------------"

echo "📦 Cloud Storage (Buckets):"
gcloud storage buckets list --project="${PROJECT_ID}" --format="value(name)" || echo "   - Ninguno"
echo ""

echo "📊 BigQuery (Datasets):"
bq ls --project_id "${PROJECT_ID}" --format=sparse | grep -v "datasetId" | grep -v "\-\-\-" || echo "   - Ninguno"
echo ""

echo "🖥️  Compute Engine (Instancias):"
gcloud compute instances list --project="${PROJECT_ID}" --format="table(name, zone, status, networkInterfaces[0].accessConfigs[0].natIP:label=EXTERNAL_IP)" 2>/dev/null || echo "   - Ninguna"
echo ""

echo "🤖 Dataproc (Clusters):"
gcloud dataproc clusters list --project="${PROJECT_ID}" --region=northamerica-northeast2 --format="table(clusterName, status.state, config.masterConfig.machineType)" 2>/dev/null || echo "   - Ninguno (northamerica-northeast2)"
echo ""

echo "🌐 Networking (VPCs):"
gcloud compute networks list --project="${PROJECT_ID}" --format="value(name)" 2>/dev/null || echo "   - Ninguna"
echo ""

echo "🔌 APIs Habilitadas (Servicios principales):"
gcloud services list --project="${PROJECT_ID}" --enabled --filter="name:googleapis.com" --format="value(config.title)" 2>/dev/null | grep -E "Compute|Storage|BigQuery|Dataproc|IAM" || echo "   - Ninguna"
echo ""

echo "👤 Service Accounts (Human-readable):"
gcloud iam service-accounts list --project="${PROJECT_ID}" --format="value(email)" | grep -E "terraform-admin|dataproc-worker" || echo "   - Ninguna relevante encontrada"

echo "----------------------------------------------------------"
echo "✅ Auditoría finalizada."

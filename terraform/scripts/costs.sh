#!/usr/bin/env bash
###############################################################################
# costs.sh — Reporte de costos para el Black Hole Visualizer
###############################################################################

set -euo pipefail

PROJECT_ID="${1:-$(gcloud config get-value project)}"

echo "----------------------------------------------------------"
echo "💰 COST REPORT: Black Hole Visualizer"
echo "----------------------------------------------------------"
echo "🛰️  Project: $PROJECT_ID"
echo "----------------------------------------------------------"

# 1. Verificar APIs habilitadas
echo "📊 Servicios activos facturables:"
gcloud services list --project="${PROJECT_ID}" --enabled --filter="name:googleapis.com" --format="value(config.title)" | grep -E "Compute|Storage|BigQuery|Dataproc" | xargs -I {} echo "   - {} [ACTIVO]"

echo "----------------------------------------------------------"
echo "💡 Nota: Para obtener el MONTO EXACTO EN USD desglosado por servicio,"
echo "   Google requiere habilitar la exportación a BigQuery."
echo "----------------------------------------------------------"

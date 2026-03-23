#!/usr/bin/env bash
###############################################################################
# costs.sh — Cost report for the Black Hole Visualizer
###############################################################################

set -euo pipefail

PROJECT_ID="${1:-$(gcloud config get-value project)}"

echo "----------------------------------------------------------"
echo "💰 COST REPORT: Black Hole Visualizer"
echo "----------------------------------------------------------"
echo "🛰️  Project: $PROJECT_ID"
echo "----------------------------------------------------------"

# 1. Verify enabled APIs
echo "📊 Billable active services:"
gcloud services list --project="${PROJECT_ID}" --enabled --filter="name:googleapis.com" --format="value(config.title)" | grep -E "Compute|Storage|BigQuery|Dataproc" | xargs -I {} echo "   - {} [ACTIVE]"

echo "----------------------------------------------------------"
echo "💡 Note: To get the EXACT AMOUNT IN USD broken down by service,"
echo "   Google requires enabling BigQuery export."
echo "----------------------------------------------------------"

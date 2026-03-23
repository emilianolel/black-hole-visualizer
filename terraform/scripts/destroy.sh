#!/usr/bin/env bash
###############################################################################
# destroy.sh — Destroys the infrastructure of a specific environment.
# Usage: bash scripts/destroy.sh <ENV>   (env = dev | prod)
# WARNING: This operation deletes resources. Use with caution in prod.
###############################################################################

set -euo pipefail

ENV="${1:?ERROR: You must pass the environment as an argument (dev | prod)}"

if [[ "$ENV" == "prod" ]]; then
  echo "⚠️  WARNING: You are about to destroy the PRODUCTION environment."
  read -r -p "Are you sure? Type 'yes' to continue: " confirm
  if [[ "$confirm" != "yes" ]]; then
    echo "❌ Operation cancelled."
    exit 0
  fi
fi

ENV_DIR="$(dirname "$0")/../environments/${ENV}"

if [[ ! -d "$ENV_DIR" ]]; then
  echo "❌ Environment '${ENV}' does not exist in terraform/environments/"
  exit 1
fi

echo "🗑️  Destroying environment: ${ENV}"
cd "$ENV_DIR"
terraform destroy -auto-approve

echo "🧹 Cleaning up residual Dataproc buckets..."
# Searches and deletes buckets that GCP creates automatically outside of Terraform
# These are usually called dataproc-staging-<region>-<project_number>-*
# and dataproc-temp-<region>-<project_number>-*
gcloud storage buckets list --format="value(name)" | grep -E "^dataproc-(staging|temp)-" | xargs -I {} gcloud storage rm --recursive gs://{} || echo "   ℹ️ No residual buckets found to clean."

echo "✅ Environment ${ENV} destroyed and cleaned."

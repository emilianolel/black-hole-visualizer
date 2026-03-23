#!/usr/bin/env bash
###############################################################################
# init.sh — Black Hole Visualizer project bootstrap
###############################################################################

set -euo pipefail

# Configuration
PROJECT_ID=$1
STATE_BUCKET=$2
REGION=$3
OPERATOR_EMAIL=$4
SA_NAME="bh-vis-admin"
SA_EMAIL="${SA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com"

echo "----------------------------------------------------------"
echo "🌑 BLACK HOLE VISUALIZER - GCP INITIALIZATION"
echo "----------------------------------------------------------"
echo "🛰️  Project: ${PROJECT_ID}"
echo "🪣  Terraform State: gs://${STATE_BUCKET}"
echo "📍 Region: ${REGION}"
echo "📧 Operator: ${OPERATOR_EMAIL}"
echo "----------------------------------------------------------"

# 1. Enable minimal APIs for bootstrap
echo "🔧 Enabling critical APIs..."
gcloud services enable \
    serviceusage.googleapis.com \
    cloudresourcemanager.googleapis.com \
    iam.googleapis.com \
    storage.googleapis.com \
    compute.googleapis.com \
    bigquery.googleapis.com \
    dataproc.googleapis.com --project="${PROJECT_ID}"

# 2. Create Bucket for Terraform State
echo "🪣  Verifying state bucket..."
if ! gcloud storage buckets describe "gs://${STATE_BUCKET}" --project="${PROJECT_ID}" &>/dev/null; then
    gcloud storage buckets create "gs://${STATE_BUCKET}" \
        --project="${PROJECT_ID}" \
        --location="${REGION}" \
        --uniform-bucket-level-access
    echo "✅ Bucket gs://${STATE_BUCKET} created."
else
    echo "ℹ️  Bucket gs://${STATE_BUCKET} already exists."
fi

# 3. Create Admin Service Account
echo "👤 Verifying Service Account ${SA_NAME}..."
if ! gcloud iam service-accounts describe "${SA_EMAIL}" --project="${PROJECT_ID}" &>/dev/null; then
    gcloud iam service-accounts create "${SA_NAME}" \
        --display-name="Black Hole Visualizer Admin" \
        --project="${PROJECT_ID}"
    echo "✅ Service Account created. Waiting for propagation (5s)..."
    sleep 5
else
    echo "ℹ️  Service Account already exists."
fi

# 4. Assign Owner role (simplified for admin)
echo "🛡️  Assigning roles..."
gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
    --member="serviceAccount:${SA_EMAIL}" \
    --role="roles/owner"

# 5. Configure Impersonation for the operator
echo "🔐 Configuring impersonation for ${OPERATOR_EMAIL}..."
gcloud iam service-accounts add-iam-policy-binding "${SA_EMAIL}" \
    --project="${PROJECT_ID}" \
    --role="roles/iam.serviceAccountTokenCreator" \
    --member="user:${OPERATOR_EMAIL}"

echo "════════════════════════════════════════════════════════════════"
echo "  ✅ Black Hole Visualizer bootstrap completed"
echo "════════════════════════════════════════════════════════════════"
echo ""
echo "  Terraform SA : ${SA_EMAIL}"
echo "  State Bucket : gs://${STATE_BUCKET}"
echo ""
echo "  Next steps:"
echo "  1. Copy terraform.tfvars.example to terraform.tfvars"
echo "  2. Update values (project_id, terraform_admin_sa, etc.)"
echo "  3. Run: terraform init"
echo "  4. Run: terraform apply"

#!/usr/bin/env bash
###############################################################################
# sync-project.sh — Synchronizes project identifiers across Terraform config
# Usage: bash scripts/sync-project.sh [PROJECT_ID] [BUCKET_NAME] [REGION] [USER_EMAIL]
###############################################################################

set -euo pipefail

# Argument Validation
if [ "$#" -ne 4 ]; then
    echo "❌ Error: Missing arguments."
    echo "Usage: bash $0 [PROJECT_ID] [BUCKET_NAME] [REGION] [USER_EMAIL]"
    echo "Example: bash $0 black-hole-project my-tf-state northamerica-northeast2 user@email.com"
    exit 1
fi

PROJECT_ID=$1
BUCKET_NAME=$2
REGION=$3
USER_EMAIL=$4
ADMIN_SA="bh-vis-admin@${PROJECT_ID}.iam.gserviceaccount.com"

echo "🔄 Synchronizing identifiers for project: ${PROJECT_ID}..."

# 1. Get terraform folder path (assuming script is in scripts/)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TERRAFORM_DIR="$(dirname "$SCRIPT_DIR")"

# 2. Update .tfvars files
echo "📝 Updating .tfvars files..."
find "$TERRAFORM_DIR" -name "*.tfvars" -type f | while read -r file; do
    sed -i '' "s/project_id *= \".*\"/project_id         = \"${PROJECT_ID}\"/g" "$file"
    sed -i '' "s/region *= \".*\"/region             = \"${REGION}\"/g" "$file"
    sed -i '' "s/terraform_admin_sa *= \".*\"/terraform_admin_sa = \"${ADMIN_SA}\"/g" "$file"
done

# Special case: terraform_operators in global/terraform.tfvars
GLOBAL_VARS="${TERRAFORM_DIR}/global/terraform.tfvars"
if [ -f "$GLOBAL_VARS" ]; then
    echo "👤 Updating operators in global/terraform.tfvars..."
    # Attempt to replace operator list (simple format for a single user)
    sed -i '' "s|user:.*@.*\"|user:${USER_EMAIL}\"|g" "$GLOBAL_VARS"
fi

# 3. Update backend.tf files
echo "🪣 Updating state buckets in backend.tf..."
find "$TERRAFORM_DIR" -name "backend.tf" -type f | while read -r file; do
    sed -i '' "s/bucket *= \".*\"/bucket = \"${BUCKET_NAME}\"/g" "$file"
done

# 4. Update defaults in variables.tf (optional but recommended)
echo "⚙️ Updating default regions in variables.tf..."
find "$TERRAFORM_DIR" -name "variables.tf" -type f | while read -r file; do
    sed -i '' "s/default *= \"us-central1.*\"/default     = \"${REGION}\"/g" "$file"
    sed -i '' "s/default *= \"northamerica-northeast2.*\"/default     = \"${REGION}\"/g" "$file"
done

echo "✅ Synchronization complete."
echo "----------------------------------------------------------"
echo "Remember to run 'terraform init -reconfigure' in each environment."

#!/usr/bin/env bash
###############################################################################
# init.sh — Bootstrap del proyecto Black Hole Visualizer
###############################################################################

set -euo pipefail

# Configuración
PROJECT_ID=$1
STATE_BUCKET=$2
REGION=$3
OPERATOR_EMAIL=$4
SA_NAME="bh-vis-admin"
SA_EMAIL="${SA_NAME}@${PROJECT_ID}.iam.gserviceaccount.com"

echo "----------------------------------------------------------"
echo "🌑 BLACK HOLE VISUALIZER - GCP INITIALIZATION"
echo "----------------------------------------------------------"
echo "🛰️  Proyecto: ${PROJECT_ID}"
echo "🪣  Estado Terraform: gs://${STATE_BUCKET}"
echo "📍 Región: ${REGION}"
echo "📧 Operador: ${OPERATOR_EMAIL}"
echo "----------------------------------------------------------"

# 1. Habilitar APIs mínimas para el bootstrap
echo "🔧 Habilitando APIs críticas..."
gcloud services enable \
    serviceusage.googleapis.com \
    cloudresourcemanager.googleapis.com \
    iam.googleapis.com \
    storage.googleapis.com --project="${PROJECT_ID}"

# 2. Crear Bucket para el Estado de Terraform
echo "🪣  Verificando bucket de estado..."
if ! gcloud storage buckets describe "gs://${STATE_BUCKET}" --project="${PROJECT_ID}" &>/dev/null; then
    gcloud storage buckets create "gs://${STATE_BUCKET}" \
        --project="${PROJECT_ID}" \
        --location="${REGION}" \
        --uniform-bucket-level-access
    echo "✅ Bucket gs://${STATE_BUCKET} creado."
else
    echo "ℹ️  El bucket gs://${STATE_BUCKET} ya existe."
fi

# 3. Crear Service Account de administración
echo "👤 Verificando Service Account ${SA_NAME}..."
if ! gcloud iam service-accounts describe "${SA_EMAIL}" --project="${PROJECT_ID}" &>/dev/null; then
    gcloud iam service-accounts create "${SA_NAME}" \
        --display-name="Black Hole Visualizer Admin" \
        --project="${PROJECT_ID}"
    echo "✅ Service Account creada. Esperando propagación (5s)..."
    sleep 5
else
    echo "ℹ️  La Service Account ya existe."
fi

# 4. Asignar rol de Propietario (simplificado para admin)
echo "🛡️  Asignando roles..."
gcloud projects add-iam-policy-binding "${PROJECT_ID}" \
    --member="serviceAccount:${SA_EMAIL}" \
    --role="roles/owner"

# 5. Configurar Impersonación para el operador
echo "🔐 Configurando impersonación para ${OPERATOR_EMAIL}..."
gcloud iam service-accounts add-iam-policy-binding "${SA_EMAIL}" \
    --project="${PROJECT_ID}" \
    --role="roles/iam.serviceAccountTokenCreator" \
    --member="user:${OPERATOR_EMAIL}"

echo "════════════════════════════════════════════════════════════════"
echo "  ✅ Bootstrap del Black Hole Visualizer completado"
echo "════════════════════════════════════════════════════════════════"
echo ""
echo "  SA de Terraform : ${SA_EMAIL}"
echo "  Bucket de estado: gs://${STATE_BUCKET}"
echo ""
echo "  Próximos pasos:"
echo "  1. Copia terraform.tfvars.example a terraform.tfvars"
echo "  2. Actualiza los valores (project_id, terraform_admin_sa, etc.)"
echo "  3. Ejecuta: terraform init"
echo "  4. Ejecuta: terraform apply"

#!/usr/bin/env bash
###############################################################################
# sync-project.sh — Sincroniza identificadores de proyecto en todo Terraform
# Uso: bash scripts/sync-project.sh [PROJECT_ID] [BUCKET_NAME] [REGION] [USER_EMAIL]
###############################################################################

set -euo pipefail

# Validar argumentos
if [ "$#" -ne 4 ]; then
    echo "❌ Error: Faltan argumentos."
    echo "Uso: bash $0 [PROJECT_ID] [BUCKET_NAME] [REGION] [USER_EMAIL]"
    echo "Ejemplo: bash $0 black-hole-project my-tf-state northamerica-northeast2 user@email.com"
    exit 1
fi

PROJECT_ID=$1
BUCKET_NAME=$2
REGION=$3
USER_EMAIL=$4
ADMIN_SA="bh-vis-admin@${PROJECT_ID}.iam.gserviceaccount.com"

echo "🔄 Sincronizando identificadores para el proyecto: ${PROJECT_ID}..."

# 1. Obtener la ruta de la carpeta terraform (asumiendo que el script está en scripts/)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TERRAFORM_DIR="$(dirname "$SCRIPT_DIR")"

# 2. Actualizar archivos .tfvars
echo "📝 Actualizando archivos .tfvars..."
find "$TERRAFORM_DIR" -name "*.tfvars" -type f | while read -r file; do
    sed -i '' "s/project_id *= \".*\"/project_id         = \"${PROJECT_ID}\"/g" "$file"
    sed -i '' "s/region *= \".*\"/region             = \"${REGION}\"/g" "$file"
    sed -i '' "s/terraform_admin_sa *= \".*\"/terraform_admin_sa = \"${ADMIN_SA}\"/g" "$file"
done

# Caso especial: terraform_operators en global/terraform.tfvars
GLOBAL_VARS="${TERRAFORM_DIR}/global/terraform.tfvars"
if [ -f "$GLOBAL_VARS" ]; then
    echo "👤 Actualizando operadores en global/terraform.tfvars..."
    # Intenta reemplazar la lista de operadores (formato simple para un solo usuario)
    sed -i '' "s|user:.*@.*\"|user:${USER_EMAIL}\"|g" "$GLOBAL_VARS"
fi

# 3. Actualizar archivos backend.tf
echo "🪣 Actualizando buckets de estado en backend.tf..."
find "$TERRAFORM_DIR" -name "backend.tf" -type f | while read -r file; do
    sed -i '' "s/bucket *= \".*\"/bucket = \"${BUCKET_NAME}\"/g" "$file"
done

# 4. Actualizar defaults en variables.tf (opcional pero recomendado)
echo "⚙️ Actualizando regiones por defecto en variables.tf..."
find "$TERRAFORM_DIR" -name "variables.tf" -type f | while read -r file; do
    sed -i '' "s/default *= \"us-central1.*\"/default     = \"${REGION}\"/g" "$file"
    sed -i '' "s/default *= \"northamerica-northeast2.*\"/default     = \"${REGION}\"/g" "$file"
done

echo "✅ Sincronización completada."
echo "----------------------------------------------------------"
echo "Recuerda ejecutar 'terraform init -reconfigure' en cada entorno."

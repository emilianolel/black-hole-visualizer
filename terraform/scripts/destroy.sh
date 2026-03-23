#!/usr/bin/env bash
###############################################################################
# destroy.sh — Destruye la infraestructura de un entorno específico
# Uso: bash scripts/destroy.sh <ENV>   (env = dev | prod)
# ADVERTENCIA: Esta operación elimina recursos. Úsala con precaución en prod.
###############################################################################

set -euo pipefail

ENV="${1:?ERROR: Debes pasar el entorno como argumento (dev | prod)}"

if [[ "$ENV" == "prod" ]]; then
  echo "⚠️  ADVERTENCIA: Estás a punto de destruir el entorno de PRODUCCIÓN."
  read -r -p "¿Estás seguro? Escribe 'yes' para continuar: " confirm
  if [[ "$confirm" != "yes" ]]; then
    echo "❌ Operación cancelada."
    exit 0
  fi
fi

ENV_DIR="$(dirname "$0")/../environments/${ENV}"

if [[ ! -d "$ENV_DIR" ]]; then
  echo "❌ El entorno '${ENV}' no existe en terraform/environments/"
  exit 1
fi

echo "🗑️  Destruyendo entorno: ${ENV}"
cd "$ENV_DIR"
terraform destroy -auto-approve

echo "🧹 Limpiando buckets residuales de Dataproc..."
# Busca y elimina buckets que GCP crea automáticamente fuera de Terraform
# Estos suelen llamarse dataproc-staging-<region>-<project_number>-*
# y dataproc-temp-<region>-<project_number>-*
gcloud storage buckets list --format="value(name)" | grep -E "^dataproc-(staging|temp)-" | xargs -I {} gcloud storage rm --recursive gs://{} || echo "   ℹ️ No se encontraron buckets residuales para limpiar."

echo "✅ Entorno ${ENV} destruido y limpiado."

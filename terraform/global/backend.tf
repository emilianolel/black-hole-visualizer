###############################################################################
# Backend remoto — Estado de Terraform almacenado en GCS
# IMPORTANTE: Este bucket debe existir ANTES de inicializar Terraform.
# Créalo manualmente o usando el script scripts/init.sh
###############################################################################

terraform {
  backend "gcs" {
    # Reemplaza con el nombre real de tu bucket de estado
    bucket = "my-tf-state-dnqxxt-bucket"
    prefix = "terraform/global"
  }

  required_version = ">= 1.5.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

# NOTA DE BOOTSTRAP:
# La PRIMERA vez debes ejecutar esto con tu cuenta personal (tiene roles de owner/admin):
#   gcloud auth application-default login
#   terraform apply  ← Crea la SA y le asigna roles
#
# DESPUÉS del bootstrap, usa siempre impersonación:
#   export TF_VAR_impersonate_sa="terraform-admin@YOUR_PROJECT.iam.gserviceaccount.com"
#   terraform apply
#
# O configura impersonate_service_account directamente en el bloque provider:
provider "google" {
  project = var.project_id
  region  = var.region

  # Descomenta y reemplaza con el email de la SA una vez creada con bootstrap:
  impersonate_service_account = "terraform-admin@new-dez-project.iam.gserviceaccount.com"
}

provider "google-beta" {
  project                     = var.project_id
  region                      = var.region
  impersonate_service_account = "terraform-admin@new-dez-project.iam.gserviceaccount.com"
}

###############################################################################
# Remote Backend — Terraform State stored in GCS
# IMPORTANT: This bucket must exist BEFORE initializing Terraform.
# Create it manually or using the scripts/init.sh script
###############################################################################

terraform {
  backend "gcs" {
    # Replace with the actual name of your state bucket
    bucket = "bh-tf-state-dnqxxt-bucket"
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

# BOOTSTRAP NOTE:
# The FIRST time you must run this with your personal account (with owner/admin roles):
#   gcloud auth application-default login
#   terraform apply  ← Creates the SA and assigns roles
#
# AFTER bootstrap, always use impersonation:
#   export TF_VAR_impersonate_sa="terraform-admin@YOUR_PROJECT.iam.gserviceaccount.com"
#   terraform apply
#
# Or configure impersonate_service_account directly in the provider block:
provider "google" {
  project = var.project_id
  region  = var.region

  # Uncomment and replace with the SA email once created with bootstrap:
  impersonate_service_account = "bh-vis-admin@black-hole-visualizer-project.iam.gserviceaccount.com"
}

provider "google-beta" {
  project                     = var.project_id
  region                      = var.region
  impersonate_service_account = "bh-vis-admin@black-hole-visualizer-project.iam.gserviceaccount.com"
}

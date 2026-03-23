terraform {
  backend "gcs" {
    bucket = "my-tf-state-dnqxxt-bucket"
    prefix = "terraform/environments/dev"
  }

  required_version = ">= 1.5.0"

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 5.0"
    }
  }
}

provider "google" {
  project = var.project_id
  region  = var.region

  # Reemplaza con el email real de la SA después del bootstrap:
  impersonate_service_account = var.terraform_admin_sa
}

provider "google-beta" {
  project                     = var.project_id
  region                      = var.region
  impersonate_service_account = var.terraform_admin_sa
}

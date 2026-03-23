variable "project_id" {
  description = "ID del proyecto en GCP"
  type        = string
}

variable "region" {
  description = "Región principal de GCP"
  type        = string
  default     = "us-central1"
}

variable "gcp_service_apis" {
  description = "Lista de APIs de GCP a habilitar"
  type        = list(string)
  default = [
    "compute.googleapis.com",
    "storage.googleapis.com",
    "bigquery.googleapis.com",
    "dataproc.googleapis.com",
    "iam.googleapis.com",
    "cloudresourcemanager.googleapis.com",
    "iamcredentials.googleapis.com",
    "serviceusage.googleapis.com",
    "cloudbilling.googleapis.com",
    "billingbudgets.googleapis.com",
  ]
}

variable "terraform_operators" {
  description = <<-EOT
    Lista de identidades que pueden impersonar la SA terraform-admin.
    Formato: ["user:tu@email.com", "group:equipo@dominio.com"]
    Estas identidades podrán ejecutar Terraform localmente o en CI/CD
    sin necesitar roles de administrador directamente en su cuenta.
  EOT
  type        = list(string)
}

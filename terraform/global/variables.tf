variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "Core GCP Region"
  type        = string
  default     = "northamerica-northeast2"
}

variable "gcp_service_apis" {
  description = "List of GCP APIs to enable"
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
    List of identities allowed to impersonate the terraform-admin SA.
    Format: ["user:you@email.com", "group:team@domain.com"]
    These identities can run Terraform locally or in CI/CD 
    without requiring admin roles directly on their personal account.
  EOT
  type        = list(string)
}

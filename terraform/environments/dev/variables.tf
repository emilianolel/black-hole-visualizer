variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "subnet_cidr" {
  description = "IP range for the main subnet"
  type        = string
}

variable "pods_cidr" {
  description = "Secondary IP range for GKE Pods (if applicable)"
  type        = string
}

variable "services_cidr" {
  description = "Secondary IP range for GKE Services (if applicable)"
  type        = string
}

variable "region" {
  description = "Core GCP Region"
  type        = string
  default     = "northamerica-northeast2"
}

variable "env" {
  description = "Environment name (dev, prod)"
  type        = string
}

variable "terraform_admin_sa" {
  description = "Email of the terraform-admin SA used for impersonation. Example: terraform-admin@PROJECT_ID.iam.gserviceaccount.com"
  type        = string
}

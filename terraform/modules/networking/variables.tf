variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP Region"
  type        = string
}

variable "env" {
  description = "Environment (dev, prod)"
  type        = string
}

variable "subnet_cidr" {
  description = "IP range for the main subnet"
  type        = string
}

variable "pods_cidr" {
  description = "Secondary IP range for GKE Pods"
  type        = string
}

variable "services_cidr" {
  description = "Secondary IP range for GKE Services"
  type        = string
}

variable "project_id" {
  description = "GCP Project ID"
  type        = string
}

variable "region" {
  description = "GCP Region"
  type        = string
}

variable "zone" {
  description = "GCP Zone"
  type        = string
  default     = "northamerica-northeast2-a"
}

variable "env" {
  description = "Environment (dev, prod)"
  type        = string
}

variable "vpc_network" {
  description = "VPC network ID"
  type        = string
}

variable "vpc_subnetwork" {
  description = "Subnetwork ID"
  type        = string
}

variable "machine_type" {
  description = "Machine type"
  type        = string
  default     = "e2-medium"
}

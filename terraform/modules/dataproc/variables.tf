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

variable "vpc_subnetwork" {
  description = "Subnetwork ID"
  type        = string
}

variable "service_account" {
  description = "Service Account email for the nodes"
  type        = string
}

variable "config_bucket" {
  description = "Bucket for Dataproc configuration"
  type        = string
}

variable "temp_bucket" {
  description = "Bucket for Dataproc temporary files"
  type        = string
}

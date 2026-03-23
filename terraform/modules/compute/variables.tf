variable "project_id" {
  description = "ID del proyecto GCP"
  type        = string
}

variable "region" {
  description = "Región de GCP"
  type        = string
}

variable "zone" {
  description = "Zona de GCP"
  type        = string
  default     = "us-central1-a"
}

variable "env" {
  description = "Entorno (dev, prod)"
  type        = string
}

variable "vpc_network" {
  description = "ID de la VPC"
  type        = string
}

variable "vpc_subnetwork" {
  description = "ID de la subred"
  type        = string
}

variable "machine_type" {
  description = "Tipo de máquina"
  type        = string
  default     = "e2-medium"
}

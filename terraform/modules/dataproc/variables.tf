variable "project_id" {
  description = "ID del proyecto GCP"
  type        = string
}

variable "region" {
  description = "Región de GCP"
  type        = string
}

variable "env" {
  description = "Entorno (dev, prod)"
  type        = string
}

variable "vpc_subnetwork" {
  description = "ID de la subred"
  type        = string
}

variable "service_account" {
  description = "Email de la Service Account para los nodos"
  type        = string
}

variable "config_bucket" {
  description = "Bucket para configuración de Dataproc"
  type        = string
}

variable "temp_bucket" {
  description = "Bucket para archivos temporales de Dataproc"
  type        = string
}

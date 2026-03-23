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

variable "subnet_cidr" {
  description = "Rango de IP para la subred principal"
  type        = string
}

variable "pods_cidr" {
  description = "Rango de IP secundario para los Pods de GKE"
  type        = string
}

variable "services_cidr" {
  description = "Rango de IP secundario para los Servicios de GKE"
  type        = string
}

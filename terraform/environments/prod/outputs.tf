output "project_id" {
  description = "ID del proyecto desplegado"
  value       = var.project_id
}

output "environment" {
  description = "Entorno activo"
  value       = var.env
}

output "region" {
  description = "Región desplegada"
  value       = var.region
}

output "vm_external_ip" {
  value       = module.compute.static_ip
  description = "Public static IP of the Ubuntu VM"
}

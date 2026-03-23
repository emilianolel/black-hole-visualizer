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
  description = "IP externa de la instancia de Compute Engine"
  value       = module.compute.external_ip
}

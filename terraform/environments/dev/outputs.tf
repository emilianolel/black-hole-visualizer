output "project_id" {
  description = "Deployed Project ID"
  value       = var.project_id
}

output "environment" {
  description = "Active environment"
  value       = var.env
}

output "region" {
  description = "Deployed region"
  value       = var.region
}

output "vm_external_ip" {
  value       = module.compute.static_ip
  description = "Public static IP of the Ubuntu VM"
}

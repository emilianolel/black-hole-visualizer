output "enabled_apis" {
  description = "APIs habilitadas en el proyecto"
  value       = [for svc in google_project_service.apis : svc.service]
}

output "terraform_admin_sa_email" {
  description = "Email de la Service Account de administración de Terraform"
  value       = google_service_account.terraform_admin.email
}

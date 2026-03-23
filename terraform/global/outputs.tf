output "enabled_apis" {
  description = "Enabled APIs in the project"
  value       = [for svc in google_project_service.apis : svc.service]
}

output "terraform_admin_sa_email" {
  description = "Email of the Terraform administration Service Account"
  value       = google_service_account.terraform_admin.email
}

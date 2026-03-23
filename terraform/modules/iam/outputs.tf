output "dataproc_worker_email" {
  value       = google_service_account.dataproc_worker.email
  description = "Dataproc Service Account email"
}

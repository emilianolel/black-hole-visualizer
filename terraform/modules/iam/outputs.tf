output "dataproc_worker_email" {
  value       = google_service_account.dataproc_worker.email
  description = "Email de la Service Account de Dataproc"
}

###############################################################################
# Module: IAM — Service Accounts and bindings for each service
###############################################################################

# Service Account for Dataproc cluster nodes
resource "google_service_account" "dataproc_worker" {
  account_id   = "${var.env}-dataproc-worker"
  display_name = "Dataproc Worker SA — ${var.env}"
  project      = var.project_id
}

# Necessary roles for Dataproc
locals {
  dataproc_roles = [
    "roles/dataproc.worker",
    "roles/storage.objectAdmin",
    "roles/bigquery.dataEditor",
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
  ]
}

resource "google_project_iam_member" "dataproc_roles" {
  for_each = toset(local.dataproc_roles)
  project  = var.project_id
  role     = each.value
  member   = "serviceAccount:${google_service_account.dataproc_worker.email}"
}

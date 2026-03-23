###############################################################################
# Module: BigQuery — Infrastructure for Black Hole Visualizer
###############################################################################

resource "google_bigquery_dataset" "raw" {
  dataset_id  = "bh_raw"
  project     = var.project_id
  location    = var.region
  description = "Raw astronomical image data"

  labels = {
    env     = var.env
    project = "black-hole-visualizer"
  }
}

resource "google_bigquery_dataset" "staging" {
  dataset_id  = "bh_staging"
  project     = var.project_id
  location    = var.region
  description = "Staging data for ray tracing"

  labels = {
    env     = var.env
    project = "black-hole-visualizer"
  }
}

resource "google_bigquery_dataset" "analytics" {
  dataset_id  = "black_hole_sims"
  project     = var.project_id
  location    = var.region
  description = "Final results for geodesics and metrics"

  labels = {
    env     = var.env
    project = "black-hole-visualizer"
  }
}

resource "google_bigquery_table" "photon_paths" {
  dataset_id = google_bigquery_dataset.analytics.dataset_id
  table_id   = "photon_paths"
  project    = var.project_id

  # Dataproc-BQ connector will manage the schema automatically.
  # We apply clustering for performance.
  clustering = ["photon_id", "step"]

  labels = {
    env     = var.env
    project = "black-hole-visualizer"
  }
}

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
  dataset_id  = "bh_analytics"
  project     = var.project_id
  location    = var.region
  description = "Final results for geodesics and metrics"

  labels = {
    env     = var.env
    project = "black-hole-visualizer"
  }
}

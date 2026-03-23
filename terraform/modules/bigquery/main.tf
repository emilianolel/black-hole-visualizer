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
  deletion_protection = false

  /* Temporarily commented to disable protection in state first
  schema = <<EOF
[
  {"name": "photon_id", "type": "INTEGER", "mode": "REQUIRED", "description": "Unique identifier for the photon"},
  {"name": "step", "type": "INTEGER", "mode": "REQUIRED", "description": "Step index in the geodesic path"},
  {"name": "r", "type": "FLOAT", "mode": "REQUIRED", "description": "Radial coordinate (Schwarzschild)"},
  {"name": "theta", "type": "FLOAT", "mode": "REQUIRED", "description": "Polar angle coordinate"},
  {"name": "phi", "type": "FLOAT", "mode": "REQUIRED", "description": "Azimuthal angle coordinate"}
]
EOF

  range_partitioning {
    field = "photon_id"
    range {
      start    = 0
      end      = 100000000
      interval = 10000
    }
  }

  clustering = ["photon_id", "step"]
  */

  labels = {
    env     = var.env
    project = "black-hole-visualizer"
  }
}

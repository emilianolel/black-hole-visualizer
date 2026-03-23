###############################################################################
# Módulo: BigQuery — Infraestructura para el Black Hole Visualizer
###############################################################################

resource "google_bigquery_dataset" "raw" {
  dataset_id  = "bh_raw"
  project     = var.project_id
  location    = var.region
  description = "Datos crudos de imágenes astronómicas"

  labels = {
    env     = var.env
    project = "black-hole-visualizer"
  }
}

resource "google_bigquery_dataset" "staging" {
  dataset_id  = "bh_staging"
  project     = var.project_id
  location    = var.region
  description = "Datos temporales de trazo de rayos"

  labels = {
    env     = var.env
    project = "black-hole-visualizer"
  }
}

resource "google_bigquery_dataset" "analytics" {
  dataset_id  = "bh_analytics"
  project     = var.project_id
  location    = var.region
  description = "Resultados finales de geodésicas y métricas"

  labels = {
    env     = var.env
    project = "black-hole-visualizer"
  }
}

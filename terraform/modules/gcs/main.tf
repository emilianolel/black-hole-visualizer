###############################################################################
# Module: GCS — Infrastructure for Black Hole Visualizer
###############################################################################

locals {
  bucket_prefix = "${var.project_id}-bh-vis"
}

resource "google_storage_bucket" "raw" {
  name                        = "${local.bucket_prefix}-raw"
  location                    = var.region
  project                     = var.project_id
  uniform_bucket_level_access = true
  force_destroy               = true

  labels = {
    env     = var.env
    project = "black-hole-visualizer"
    layer   = "raw"
  }
}

resource "google_storage_bucket" "staging" {
  name                        = "${local.bucket_prefix}-staging"
  location                    = var.region
  project                     = var.project_id
  uniform_bucket_level_access = true
  force_destroy               = true

  labels = {
    env     = var.env
    project = "black-hole-visualizer"
    layer   = "staging"
  }
}

resource "google_storage_bucket" "curated" {
  name                        = "${local.bucket_prefix}-curated"
  location                    = var.region
  project                     = var.project_id
  uniform_bucket_level_access = true
  force_destroy               = true

  labels = {
    env     = var.env
    project = "black-hole-visualizer"
    layer   = "curated"
  }
}

resource "google_storage_bucket" "dataproc_config" {
  name                        = "${local.bucket_prefix}-dataproc-config"
  location                    = var.region
  project                     = var.project_id
  uniform_bucket_level_access = true
  force_destroy               = true
}

resource "google_storage_bucket" "dataproc_temp" {
  name                        = "${local.bucket_prefix}-dataproc-temp"
  location                    = var.region
  project                     = var.project_id
  uniform_bucket_level_access = true
  force_destroy               = true
}

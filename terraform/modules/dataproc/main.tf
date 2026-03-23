resource "google_dataproc_cluster" "main" {
  name    = "${var.env}-dataproc-cluster"
  project = var.project_id
  region  = var.region

  cluster_config {
    staging_bucket = var.config_bucket
    temp_bucket    = var.temp_bucket

    master_config {
      num_instances = 1
      machine_type  = "e2-standard-2"
      disk_config {
        boot_disk_size_gb = 50
      }
    }

    worker_config {
      num_instances = 2
      machine_type  = "e2-standard-2"
      disk_config {
        boot_disk_size_gb = 50
      }
    }

    gce_cluster_config {
      subnetwork       = var.vpc_subnetwork
      service_account  = var.service_account
      service_account_scopes = [
        "https://www.googleapis.com/auth/cloud-platform"
      ]
      tags = ["dataproc"]
    }
  }
}

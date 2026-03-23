output "raw_bucket_name" { value = google_storage_bucket.raw.name }
output "staging_bucket_name" { value = google_storage_bucket.staging.name }
output "curated_bucket" {
  value = google_storage_bucket.curated.name
}

output "dataproc_config_bucket" {
  value = google_storage_bucket.dataproc_config.name
}

output "dataproc_temp_bucket" {
  value = google_storage_bucket.dataproc_temp.name
}

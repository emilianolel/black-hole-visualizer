###############################################################################
# Entorno: DEV
# Este archivo invoca todos los módulos necesarios para el entorno de desarrollo
###############################################################################

module "networking" {
  source        = "../../modules/networking"
  project_id    = var.project_id
  region        = var.region
  env           = var.env
  subnet_cidr   = var.subnet_cidr
  pods_cidr     = var.pods_cidr
  services_cidr = var.services_cidr
}

module "iam" {
  source     = "../../modules/iam"
  project_id = var.project_id
  env        = var.env
}

module "gcs" {
  source     = "../../modules/gcs"
  project_id = var.project_id
  region     = var.region
  env        = var.env
}

module "bigquery" {
  source     = "../../modules/bigquery"
  project_id = var.project_id
  region     = var.region
  env        = var.env
}

module "compute" {
  source         = "../../modules/compute"
  project_id     = var.project_id
  region         = var.region
  env            = var.env
  vpc_network    = module.networking.vpc_network
  vpc_subnetwork = module.networking.vpc_subnetwork
}

module "dataproc" {
  source          = "../../modules/dataproc"
  project_id      = var.project_id
  region          = var.region
  env             = var.env
  vpc_subnetwork  = module.networking.vpc_subnetwork
  service_account = module.iam.dataproc_worker_email
  config_bucket   = module.gcs.dataproc_config_bucket
  temp_bucket     = module.gcs.dataproc_temp_bucket
}

###############################################################################
# Módulo: Networking — VPC, subnets y reglas de firewall
###############################################################################

resource "google_compute_network" "vpc" {
  name                    = "${var.env}-data-vpc"
  project                 = var.project_id
  auto_create_subnetworks = false
  description             = "VPC principal para entorno ${var.env}"
}

resource "google_compute_subnetwork" "data_subnet" {
  name          = "${var.env}-data-subnet"
  project       = var.project_id
  region        = var.region
  network       = google_compute_network.vpc.id
  ip_cidr_range = var.subnet_cidr

  private_ip_google_access = true

  secondary_ip_range {
    range_name    = "pods"
    ip_cidr_range = var.pods_cidr
  }

  secondary_ip_range {
    range_name    = "services"
    ip_cidr_range = var.services_cidr
  }
}

# Regla: permite tráfico interno dentro de la VPC
resource "google_compute_firewall" "internal" {
  name    = "${var.env}-allow-internal"
  project = var.project_id
  network = google_compute_network.vpc.name

  allow {
    protocol = "tcp"
    ports    = ["0-65535"]
  }
  allow {
    protocol = "udp"
    ports    = ["0-65535"]
  }
  allow {
    protocol = "icmp"
  }

  source_ranges = [var.subnet_cidr]
}

# Router para Cloud NAT
resource "google_compute_router" "router" {
  name    = "${var.env}-router"
  project = var.project_id
  region  = var.region
  network = google_compute_network.vpc.id
}

# Cloud NAT: permite que nodos en subredes privadas salgan a internet (necesario para GKE/Composer)
resource "google_compute_router_nat" "nat" {
  name                               = "${var.env}-nat"
  project                            = var.project_id
  router                             = google_compute_router.router.name
  region                             = var.region
  nat_ip_allocate_option             = "AUTO_ONLY"
  source_subnetwork_ip_ranges_to_nat = "ALL_SUBNETWORKS_ALL_IP_RANGES"

  log_config {
    enable = true
    filter = "ERRORS_ONLY"
  }
}

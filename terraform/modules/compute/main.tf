resource "google_compute_address" "static_ip" {
  name    = "${var.env}-vm-static-ip"
  project = var.project_id
  region  = var.region
}

resource "google_compute_instance" "ubuntu_vm" {
  name         = "${var.env}-ubuntu-vm"
  project      = var.project_id
  machine_type = var.machine_type
  zone         = var.zone

  boot_disk {
    initialize_params {
      image = "ubuntu-os-cloud/ubuntu-2204-lts"
      size  = 20
    }
  }

  network_interface {
    network    = var.vpc_network
    subnetwork = var.vpc_subnetwork

    access_config {
      nat_ip = google_compute_address.static_ip.address
    }
  }

  tags = ["http-server", "ssh-server"]

  metadata = {
    env = var.env
  }
}

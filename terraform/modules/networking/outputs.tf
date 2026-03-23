output "vpc_network" { value = google_compute_network.vpc.self_link }
output "vpc_subnetwork" { value = google_compute_subnetwork.data_subnet.self_link }

output "external_ip" {
  value       = google_compute_address.static_ip.address
  description = "IP externa estática de la VM"
}

output "instance_name" {
  value = google_compute_instance.ubuntu_vm.name
}

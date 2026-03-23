output "static_ip" {
  description = "Static external IP for the VM"
  value       = google_compute_address.static_ip.address
}

output "instance_name" {
  value = google_compute_instance.ubuntu_vm.name
}

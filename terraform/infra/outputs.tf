output "network_name" {
  value = google_compute_network.main.name
}

output "subnetwork_name" {
  value = google_compute_subnetwork.main.name
}

output "app_service_account_email" {
  value = google_service_account.app.email
}

output "lb_ip_address" {
  value = google_compute_global_address.main.address
}

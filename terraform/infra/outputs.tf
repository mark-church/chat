output "app_service_account_email" {
  description = "The email of the service account for the application."
  value       = google_service_account.app.email
}

output "lb_ip_address" {
  description = "The IP address of the global load balancer."
  value       = google_compute_global_address.main.address
}

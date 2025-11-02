output "app_service_account_email" {
  description = "The email of the service account for the application."
  value       = google_service_account.app.email
}

output "lb_ip_address" {
  description = "The IP address of the global load balancer."
  value       = google_compute_global_address.main.address
}

output "load_balancer_console_url" {
  description = "The URL of the application's load balancer in the Google Cloud Console."
  value       = "https://console.cloud.google.com/net-services/loadbalancing/details/global/http/${google_compute_backend_service.main.name}/overview?project=${var.project_id}"
}

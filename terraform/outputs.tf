output "load_balancer_ip" {
  description = "The IP address of the global load balancer."
  value       = "https://${module.infra.lb_ip_address}"
}

output "cloud_run_service_urls" {
  description = "The URLs of the Cloud Run services."
  value       = module.app.cloud_run_service_urls
}

output "cloud_sql_console_url" {
  description = "The resource URL of the Cloud SQL database instance."
  value       = module.app.cloud_sql_console_url
}

output "load_balancer_ip" {
  description = "The IP address of the global load balancer."
  value       = "https://${module.infra.lb_ip_address}"
}

output "app_hub_console_url" {
  description = "The URL of the App Hub application in the Google Cloud Console."
  value       = "https://console.cloud.google.com/apphub/applications/details/global/chatter?project=${var.project_id}"
}

output "image_by_tag" {
  description = "The URL of the container image, referenced by its tag."
  value       = module.app.image_by_tag
}

output "image_by_digest" {
  description = "The URL of the container image, referenced by its unique digest."
  value       = module.app.image_by_digest
}

output "artifact_registry_image_url" {
  description = "The URL of the container image in the Google Cloud Console."
  value       = module.app.artifact_registry_image_url
}

output "cloud_run_service_urls" {
  description = "The URLs of the Cloud Run services."
  value       = module.app.cloud_run_service_urls
}

output "cloud_run_console_urls" {
  description = "The URLs to the Cloud Run services in the Google Cloud Console."
  value       = module.app.cloud_run_console_urls
}

output "cloud_sql_console_url" {
  description = "The resource URL of the Cloud SQL database instance."
  value       = module.app.cloud_sql_console_url
}

output "load_balancer_console_url" {
  description = "The URL of the application's load balancer in the Google Cloud Console."
  value       = module.infra.load_balancer_console_url
}

output "locust_load_generator_url" {
  description = "The URL of the Locust load generator."
  value       = module.cicd.locust_lb_public_ip
}

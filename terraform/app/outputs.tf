output "artifact_registry_repository_id" {
  description = "The ID of the Artifact Registry repository."
  value       = google_artifact_registry_repository.main.repository_id
}

output "cloud_run_service_name" {
  description = "A map of Cloud Run service names keyed by region."
  value       = { for k, v in google_cloud_run_v2_service.main : k => v.name }
}

output "app_image_url" {
  description = "The URL of the container image."
  value       = "us-central1-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.main.repository_id}/${var.app_name}:${var.manual_build_tag}"
}

output "cloud_run_service_urls" {
  description = "The URLs of the Cloud Run services."
  value       = { for k, v in google_cloud_run_v2_service.main : k => v.uri }
}

output "cloud_sql_console_url" {
  description = "The URL to the Cloud SQL instance in the Google Cloud Console."
  value       = "https://console.cloud.google.com/sql/instances/${google_sql_database_instance.main.name}/overview?project=${var.project_id}"
}
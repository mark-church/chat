output "artifact_registry_repository_id" {
  description = "The ID of the Artifact Registry repository."
  value       = google_artifact_registry_repository.main.repository_id
}

output "cloud_run_service_name" {
  description = "A map of Cloud Run service names keyed by region."
  value       = { for k, v in google_cloud_run_v2_service.main : k => v.name }
}

output "image_by_tag" {
  description = "The URL of the container image, referenced by its tag."
  value       = "us-central1-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.main.repository_id}/${var.app_name}:${var.manual_build_tag}"
}

output "image_by_digest" {
  description = "The URL of the container image, referenced by its unique digest."
  value       = "us-central1-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.main.repository_id}/${var.app_name}@${chomp(data.local_file.image_digest.content)}"
}

output "artifact_registry_image_url" {
  description = "The URL of the container image in the Google Cloud Console."
  value       = "https://console.cloud.google.com/artifacts/docker/${var.project_id}/${var.region}/${google_artifact_registry_repository.main.repository_id}/${var.app_name}/tag/${var.manual_build_tag}?project=${var.project_id}"
}

output "cloud_run_service_urls" {
  description = "The URLs of the Cloud Run services."
  value       = { for k, v in google_cloud_run_v2_service.main : k => v.uri }
}

output "cloud_run_console_urls" {
  description = "The URLs to the Cloud Run services in the Google Cloud Console."
  value       = { for k, v in google_cloud_run_v2_service.main : k => "https://console.cloud.google.com/run/detail/${k}/${v.name}/observability/metrics?project=${var.project_id}" }
}

output "cloud_sql_console_url" {
  description = "The URL to the Cloud SQL instance in the Google Cloud Console."
  value       = "https://console.cloud.google.com/sql/instances/${google_sql_database_instance.main.name}/overview?project=${var.project_id}"
}
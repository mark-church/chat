output "cloud_run_service_name" {
  value = { for region, service in google_cloud_run_v2_service.main : region => service.name }
}

output "artifact_registry_repository_id" {
  value = google_artifact_registry_repository.main.repository_id
}

output "app_image_url" {
  value = "us-central1-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.main.repository_id}/${var.app_name}:${data.archive_file.source.output_sha}"
}

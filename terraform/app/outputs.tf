output "cloud_run_service_name" {
  value = google_cloud_run_v2_service.main.name
}

output "artifact_registry_repository_id" {
  value = google_artifact_registry_repository.main.repository_id
}

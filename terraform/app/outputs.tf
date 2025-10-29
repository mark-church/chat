output "cloud_run_service_name" {
  value = { for region, service in google_cloud_run_v2_service.main : region => service.name }
}

output "artifact_registry_repository_id" {
  value = google_artifact_registry_repository.main.repository_id
}

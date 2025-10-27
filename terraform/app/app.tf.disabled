
resource "google_apphub_application" "chatter" {
  project        = var.project_id
  location       = var.region
  application_id = "chatter"
  display_name   = "Chatter"
  scope {
    type = "REGIONAL"
  }
}

resource "google_apphub_service" "chat_app" {
  project      = var.project_id
  location     = var.region
  application_id = google_apphub_application.chatter.application_id
  service_id     = google_cloud_run_v2_service.main.name
  display_name = "Chat App"
  discovered_service = google_cloud_run_v2_service.main.uri

  depends_on = [
    google_cloud_run_v2_service.main
  ]
}

resource "google_apphub_service" "chat_app_backend" {
  project      = var.project_id
  location     = var.region
  application_id = google_apphub_application.chatter.application_id
  service_id     = "chat-app-backend"
  display_name = "Chat App Backend"
  # This is a workaround as there is no direct way to get the discovered service URI for a backend service
  discovered_service = "projects/${var.project_id}/locations/${var.region}/services/chat-app-backend"

  depends_on = [
    google_compute_backend_service.main
  ]
}

resource "google_apphub_workload" "chat_app_forwarding_rule" {
  project      = var.project_id
  location     = var.region
  application_id = google_apphub_application.chatter.application_id
  workload_id    = "chat-app-forwarding-rule"
  display_name = "Chat App Forwarding Rule"
  # This is a workaround as there is no direct way to get the discovered workload URI for a forwarding rule
  discovered_workload = "projects/${var.project_id}/locations/global/workloads/chat-app-forwarding-rule"

  depends_on = [
    google_compute_global_forwarding_rule.main
  ]
}

resource "google_apphub_workload" "chat_app_db_password" {
  project      = var.project_id
  location     = var.region
  application_id = google_apphub_application.chatter.application_id
  workload_id    = "chat-app-db-password"
  display_name = "Chat App DB Password"
  discovered_workload = google_secret_manager_secret.db_password.id

  depends_on = [
    google_secret_manager_secret.db_password
  ]
}

resource "google_apphub_workload" "chat_app_db_instance" {
  project      = var.project_id
  location     = var.region
  application_id = google_apphub_application.chatter.application_id
  workload_id    = "chat-app-db-instance"
  display_name = "Chat App DB Instance"
  discovered_workload = google_sql_database_instance.main.self_link

  depends_on = [
    google_sql_database_instance.main
  ]
}

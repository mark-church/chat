# Copyright 2025 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     https://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.



resource "google_artifact_registry_repository" "main" {
  project      = var.project_id
  location     = var.region
  repository_id = "${var.app_name}-repo"
  format       = "DOCKER"
}



resource "google_cloud_run_v2_service" "main" {
  for_each = toset(var.app_regions)
  project  = var.project_id
  name     = "${var.app_name}-${each.key}"
  location = each.key

  template {
    service_account = var.app_service_account_email
    max_instance_request_concurrency = 80
    timeout = "30s"

    scaling {
      max_instance_count = 10
    }

    containers {
      image = "us-central1-docker.pkg.dev/${var.project_id}/${google_artifact_registry_repository.main.repository_id}/${var.app_name}:${var.manual_build_tag}"
      ports {
        container_port = 8080
      }
      startup_probe {
        failure_threshold = 3
        period_seconds    = 10
        timeout_seconds   = 10
        http_get {
          path = "/healthz"
          port = 8080
        }
      }
      liveness_probe {
        timeout_seconds   = 10
        http_get {
          path = "/healthz"
          port = 8080
        }
      }
      env {
        name  = "INSTANCE_CONNECTION_NAME"
        value = google_sql_database_instance.main.connection_name
      }
      env {
        name  = "DB_USER"
        value = google_sql_user.main.name
      }
      env {
        name = "DB_PASS"
        value_source {
          secret_key_ref {
            secret  = google_secret_manager_secret.db_password.secret_id
            version = "latest"
          }
        }
      }
      env {
        name  = "DB_NAME"
        value = google_sql_database.main.name
      }
    }

    containers {
      image = "gcr.io/cloud-sql-connectors/cloud-sql-proxy"
      args  = ["--structured-logs", "--port=5432", google_sql_database_instance.main.connection_name]
    }
  }

  depends_on = [
    null_resource.gcloud_build
  ]

  lifecycle {
    create_before_destroy = true
  }
}

resource "google_cloud_run_v2_service_iam_binding" "allow_unauthenticated" {
  for_each = google_cloud_run_v2_service.main
  project  = each.value.project
  location = each.value.location
  name     = each.value.name
  role     = "roles/run.invoker"
  members  = ["allUsers"]
}

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



resource "google_service_account" "app" {
  project      = var.project_id
  account_id   = "${var.app_name}-sa"
  display_name = "Chat App Service Account"
}

resource "google_project_iam_member" "app_roles" {
  project = var.project_id
  for_each = toset([
    "roles/cloudsql.client",
    "roles/secretmanager.secretAccessor",
  ])
  role   = each.key
  member = google_service_account.app.member
}

# Data source to get the project number
data "google_project" "project" {
  project_id = var.project_id
}

# Grant the default Compute Engine service account permissions for manual builds
resource "google_project_iam_member" "compute_build_permissions" {
  project = var.project_id
  for_each = toset([
    "roles/artifactregistry.admin",
    "roles/logging.logWriter",
  ])
  role   = each.key
  member = "serviceAccount:${data.google_project.project.number}-compute@developer.gserviceaccount.com"
}


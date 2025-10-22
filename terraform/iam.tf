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

resource "google_project_service" "iam_services" {
  for_each = toset([
    "iam.googleapis.com",
  ])
  project = var.project_id
  service = each.key
}

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

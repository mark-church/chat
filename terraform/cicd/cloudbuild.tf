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

resource "google_cloudbuildv2_connection" "github" {
  project  = var.project_id
  location = var.region
  name     = "github"

  github_config {
    app_installation_id = 85874871
    authorizer_credential {
      oauth_token_secret_version = "projects/${var.project_id}/secrets/github-github-oauthtoken-7dbc8c/versions/latest"
    }
  }
}

resource "google_cloudbuildv2_repository" "main" {
  project           = var.project_id
  location          = var.region
  name              = "mark-church-chat"
  parent_connection = google_cloudbuildv2_connection.github.name
  remote_uri        = "https://github.com/${var.github_owner}/${var.github_repo_name}.git"
}



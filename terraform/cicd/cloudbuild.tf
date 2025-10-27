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

resource "google_cloudbuild_trigger" "main" {
  project  = var.project_id
  name     = "${var.app_name}-build-trigger"
  location = var.region

  github {
    owner = var.github_owner
    name  = var.github_repo_name
    push {
      branch = "^main$"
    }
  }

  substitutions = {
    _IMAGE_NAME = "${var.region}-docker.pkg.dev/${var.project_id}/${var.app_name}-repo"
    _SERVICE_NAME   = var.service_name
  }

  filename = "cloudbuild.yaml"

  build {
    step {
      name = "gcr.io/cloud-builders/docker"
      args = ["build", "-t", "$_IMAGE_NAME:$COMMIT_SHA", "."]
    }

    images = ["$_IMAGE_NAME:$COMMIT_SHA"]
  }
}

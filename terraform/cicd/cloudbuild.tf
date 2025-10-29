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

resource "google_cloudbuild_trigger" "main" {
  project  = var.project_id
  name     = "${var.app_name}-build-trigger"
  location = var.region

  repository_event_config {
    repository = google_cloudbuildv2_repository.main.id
    push {
      branch = "^main$"
    }
  }

  substitutions = {
    _IMAGE_NAME = "${var.region}-docker.pkg.dev/${var.project_id}/${var.app_name}-repo"
  }

  build {
    step {
      name = "gcr.io/cloud-builders/docker"
      id   = "BUILD_IMAGE"
      args = [
        "build",
        "-t", "${var.region}-docker.pkg.dev/${var.project_id}/${var.artifact_registry_repository_id}/${var.app_name}:$COMMIT_SHA",
        "-t", "${var.region}-docker.pkg.dev/${var.project_id}/${var.artifact_registry_repository_id}/${var.app_name}:latest",
        "--build-arg", "IMAGE_TAG=$COMMIT_SHA",
        "-f", "Dockerfile",
        "."
      ]
    }

    step {
      name = "gcr.io/google.com/cloudsdktool/cloud-sdk"
      id   = "UPDATE_ADC"
      entrypoint = "bash"
      args = [
        "-c",
        <<-EOT
          set -e
          echo "Updating apt-get and installing jq..."
          apt-get update && apt-get install -y jq curl

          LATEST_IMAGE="${var.region}-docker.pkg.dev/$${PROJECT_ID}/${var.artifact_registry_repository_id}/${var.app_name}:$${COMMIT_SHA}"

          echo "Fetching latest app config for ${var.adc_application_name}..."
          gcloud alpha design-center spaces applications describe "${var.adc_application_name}" --space="${var.adc_space_name}" --project="$${PROJECT_ID}" --location="${var.region}" --format="json(componentParameters)" | jq '.componentParameters | map(del(.state, .componentParameterSchema))' > component_parameters.json

          echo "Updating component ${var.adc_target_service_name} CR image to version $${COMMIT_SHA}..."
          jq --arg comp_name "${var.adc_target_service_name}" --arg image_name "$${LATEST_IMAGE}" 'map(if (.parameters[] | select(.key == "service_name").value == $comp_name) then .parameters |= map(if .key == "containers" then .value |= map(.container_image = $image_name) else . end) else . end)' component_parameters.json > temp.json && mv temp.json component_parameters.json

          echo "Updating ADC application ${var.adc_application_name}..."
          gcloud alpha design-center spaces applications update "${var.adc_application_name}" --space="${var.adc_space_name}" --project="$${PROJECT_ID}" --location="${var.region}" --component-parameters=component_parameters.json

          echo "Deploying ADC application ${var.adc_application_name}... (This may take a while)"
          gcloud alpha design-center spaces applications deploy "${var.adc_application_name}" --space="${var.adc_space_name}" --project="$${PROJECT_ID}" --location="${var.region}"
          # --async flag removed

          rm -f component_parameters.json temp.json
          echo "ADC deployment command finished."
        EOT
      ]
      wait_for = ["BUILD_IMAGE"]
    }

    images = [
      "${var.region}-docker.pkg.dev/${var.project_id}/${var.artifact_registry_repository_id}/${var.app_name}:$COMMIT_SHA",
      "${var.region}-docker.pkg.dev/${var.project_id}/${var.artifact_registry_repository_id}/${var.app_name}:latest"
    ]

    timeout = "1200s"
  }
}
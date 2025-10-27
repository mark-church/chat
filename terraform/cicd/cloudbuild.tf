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
    _SERVICE_NAME = var.service_name
    _SPACE        = var.space
    _APP_NAME     = var.app_name
  }

  build {
    step {
      name = "gcr.io/cloud-builders/docker"
      args = ["build", "-t", "$_IMAGE_NAME:$COMMIT_SHA", "."]
    }
    step {
      name = "gcr.io/google.com/cloudsdktool/cloud-sdk"
      entrypoint = "bash"
      args = [
        "-c",
        <<-EOT
          echo "Updating apt-get and installing jq..."
          apt-get update && apt-get install -y jq curl

          echo "Fetching latest app config..."
          gcloud alpha design-center spaces applications describe ${_APP_NAME} --space=${_SPACE} --project=$PROJECT_ID --location=${var.region} --format="json(componentParameters)" | jq '.componentParameters | map(del(.state, .componentParameterSchema))' > component_parameters.json

          echo "Updating ${_SERVICE_NAME} CR image..."
          # JQ command from YAML, only service name is parameterized, using _IMAGE_NAME
          jq 'map(if .parameters[] | select(.key == "service_name").value == "'"${_SERVICE_NAME}"'" then .parameters |= map(if .key == "containers" then .value |= map(.container_image = "'"${_IMAGE_NAME}:${COMMIT_SHA}"'") else . end) else . end)' component_parameters.json > temp.json && mv temp.json component_parameters.json

          gcloud alpha design-center spaces applications update ${_APP_NAME} --space=${_SPACE} --project=$PROJECT_ID --location=${var.region} --component-parameters=component_parameters.json

          echo "Deploying application....."
          gcloud alpha design-center spaces applications deploy ${_APP_NAME} --space=${_SPACE} --project=$PROJECT_ID --location=${var.region} --async
          
          rm -f component_parameters.json
        EOT
      ]
    }
    images = ["$_IMAGE_NAME:$COMMIT_SHA"]
  }
  options {
    logging = "CLOUD_LOGGING_ONLY"
    dynamic_substitutions = true
  }
}

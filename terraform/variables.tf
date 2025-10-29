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

variable "project_id" {
  description = "The project ID to deploy to."
  type        = string
}

variable "region" {
  description = "The region to deploy to."
  type        = string
}

variable "app_name" {
  description = "The name of the application."
  type        = string
}

variable "db_name" {
  description = "The name of the database."
  type        = string
}

variable "db_user" {
  description = "The name of the database user."
  type        = string
}

variable "github_owner" {
  description = "The GitHub owner (user or organization)."
  type        = string
}

variable "github_repo_name" {
  description = "The name of the GitHub repository."
  type        = string
}

variable "app_regions" {
  description = "The regions to deploy the application to."
  type        = list(string)
}

variable "adc_application_name" {
  description = "The name of the Application Design Center application."
  type        = string
}

variable "adc_space_name" {
  description = "The name of the Application Design Center space."
  type        = string
}
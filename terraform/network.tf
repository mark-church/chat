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

resource "google_project_service" "vpc_services" {
  for_each = toset([
    "compute.googleapis.com",
    "dns.googleapis.com",
  ])
  project = var.project_id
  service = each.key
}

resource "google_compute_network" "main" {
  project                 = var.project_id
  name                    = "${var.app_name}-vpc"
  auto_create_subnetworks = false
}

resource "google_compute_subnetwork" "main" {
  project       = var.project_id
  name          = "${var.app_name}-subnet"
  ip_cidr_range = "10.0.0.0/24"
  network       = google_compute_network.main.id
  region        = var.region
}

resource "google_compute_subnetwork" "proxy_only" {
  project       = var.project_id
  name          = "${var.app_name}-proxy-only-subnet"
  ip_cidr_range = "10.20.0.0/24"
  network       = google_compute_network.main.id
  region        = var.region
  purpose       = "REGIONAL_MANAGED_PROXY"
  role          = "ACTIVE"
}

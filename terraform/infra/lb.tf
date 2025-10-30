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



resource "google_compute_global_address" "main" {
  project = var.project_id
  name    = "${var.app_name}-lb-ip"
}

resource "google_compute_ssl_certificate" "main" {
  project      = var.project_id
  name         = "${var.app_name}-self-signed-ssl-cert"
  private_key  = file("${path.module}/self-signed.key")
  certificate  = file("${path.module}/self-signed.crt")
}

resource "google_compute_backend_service" "main" {
  project   = var.project_id
  name      = "${var.app_name}-backend"
  protocol  = "HTTP"
  port_name = "http"
  load_balancing_scheme = "EXTERNAL_MANAGED"

  log_config {
    enable      = true
    sample_rate = 1.0
  }

  dynamic "backend" {
    for_each = google_compute_region_network_endpoint_group.main
    content {
      group = backend.value.id
    }
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "google_compute_region_network_endpoint_group" "main" {
  for_each              = toset(var.app_regions)
  project               = var.project_id
  name                  = "${var.app_name}-neg-${each.key}"
  region                = each.key
  network_endpoint_type = "SERVERLESS"
  cloud_run {
    service = var.cloud_run_service_names[each.key]
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "google_compute_url_map" "main" {
  project         = var.project_id
  name            = "${var.app_name}-url-map"
  default_service = google_compute_backend_service.main.id
}

resource "google_compute_target_https_proxy" "main" {
  project          = var.project_id
  name             = "${var.app_name}-https-proxy"
  url_map          = google_compute_url_map.main.id
  ssl_certificates = [google_compute_ssl_certificate.main.id]
}

resource "google_compute_global_forwarding_rule" "main" {
  project               = var.project_id
  name                  = "${var.app_name}-forwarding-rule"
  target                = google_compute_target_https_proxy.main.id
  ip_address            = google_compute_global_address.main.address
  port_range            = "443"
  load_balancing_scheme = "EXTERNAL_MANAGED"
}

resource "google_compute_security_policy" "main" {
  project = var.project_id
  name    = "${var.app_name}-security-policy"
  rule {
    action   = "allow"
    priority = "2147483647"
    match {
      versioned_expr = "SRC_IPS_V1"
      config {
        src_ip_ranges = ["*"]
      }
    }
    description = "Default allow all"
  }
}

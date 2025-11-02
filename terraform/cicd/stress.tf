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

# 1. Define a template for the VM
resource "google_compute_instance_template" "locust_vm_template" {
  project      = var.project_id
  name         = "${var.app_name}-locust-template"
  machine_type = "e2-standard-8"
  tags         = ["locust-vm"]

  disk {
    source_image = "debian-cloud/debian-11"
    auto_delete  = true
    boot         = true
  }

  network_interface {
    network = "default"
    access_config {
      // Ephemeral public IP for internet access during startup
    }
  }

  service_account {
    email  = var.app_service_account_email
    scopes = ["cloud-platform"]
  }

  metadata_startup_script = <<-EOT
    #!/bin/bash
    apt-get update
    apt-get install -y git python3-pip
    pip3 install locust
    
    git clone https://github.com/${var.github_owner}/${var.repo_name}.git /srv/app
    
    cd /srv/app/stress
    locust -f locustfile_readonly.py --host ${var.public_app_url} --web-port 8089
  EOT
}

# 2. Create a Managed Instance Group (MIG) with 1 instance
resource "google_compute_instance_group_manager" "locust_mig" {
  project            = var.project_id
  zone               = "us-central1-a"
  name               = "${var.app_name}-locust-mig"
  base_instance_name = "${var.app_name}-locust-vm"
  target_size        = 1

  version {
    instance_template = google_compute_instance_template.locust_vm_template.id
    name              = "primary"
  }

  named_port {
    name = "http"
    port = 8089
  }

  lifecycle {
    create_before_destroy = true
  }
}

resource "google_compute_firewall" "allow_locust_lb" {
  project = var.project_id
  name    = "${var.app_name}-allow-locust-lb"
  network = "default"

  allow {
    protocol = "tcp"
    ports    = ["8089"]
  }

  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]
  target_tags   = ["locust-vm"]
}

resource "google_compute_health_check" "locust_health_check" {
  project = var.project_id
  name    = "${var.app_name}-locust-health-check"
  tcp_health_check {
    port = 8089
  }
}

# 3. Update the backend service to point to the new MIG
resource "google_compute_backend_service" "locust_backend" {
  project               = var.project_id
  name                  = "${var.app_name}-locust-backend"
  protocol              = "HTTP"
  port_name             = "http"
  load_balancing_scheme = "EXTERNAL"
  health_checks         = [google_compute_health_check.locust_health_check.id]

  backend {
    group = google_compute_instance_group_manager.locust_mig.instance_group
  }
}

resource "google_compute_url_map" "locust_url_map" {
  project         = var.project_id
  name            = "${var.app_name}-locust-url-map"
  default_service = google_compute_backend_service.locust_backend.id
}

resource "google_compute_target_http_proxy" "locust_http_proxy" {
  project = var.project_id
  name    = "${var.app_name}-locust-http-proxy"
  url_map = google_compute_url_map.locust_url_map.id
}

resource "google_compute_global_address" "locust_lb_ip" {
  project = var.project_id
  name    = "${var.app_name}-locust-lb-ip"
}

resource "google_compute_global_forwarding_rule" "locust_forwarding_rule" {
  project               = var.project_id
  name                  = "${var.app_name}-locust-forwarding-rule"
  target                = google_compute_target_http_proxy.locust_http_proxy.id
  ip_address            = google_compute_global_address.locust_lb_ip.address
  port_range            = "80"
  load_balancing_scheme = "EXTERNAL"
}

output "locust_lb_public_ip" {
  description = "The public IP address of the Locust Load Balancer."
  value       = google_compute_global_address.locust_lb_ip.address
}
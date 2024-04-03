terraform {
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "5.16.0"
    }
  }
}

provider "google" {
  project = var.project
  region  = var.region
  zone    = var.zone
}

resource "google_compute_firewall" "allow_http" {
  for_each = var.vpcs
  name     = "${each.key}-allow-http"
  network  = google_compute_network.vpc_network[each.key].self_link

  allow {
    protocol = var.protocol
    ports    = [var.httpport]
  }

  source_ranges = [google_compute_global_address.load_balance_ip.address]
  target_tags   = ["webapp"]
}

resource "google_compute_firewall" "deny_ssh" {
  for_each = var.vpcs
  name     = "${each.key}-deny-ssh"
  network  = google_compute_network.vpc_network[each.key].self_link

  allow {
    protocol = var.protocol
    ports    = [var.sshport]
  }

  source_ranges = [var.source_ranges]
  target_tags   = ["webapp"]
}

resource "google_compute_firewall" "sql_access" {
  for_each  = var.vpcs
  name      = "${each.key}-allow-sql-access"
  network   = google_compute_network.vpc_network[each.key].id
  direction = var.ingress
  priority  = var.firewall_allow_priority

  allow {
    protocol = "tcp"
    ports    = [var.db_port]
  }

  source_ranges      = [var.source_ranges]
  source_tags        = ["webapp"]
  destination_ranges = [google_sql_database_instance.database_instance[each.key].first_ip_address]
}

resource "google_compute_firewall" "deny_sql_access" {
  for_each  = var.vpcs
  name      = "${each.key}-deny-sql-access"
  network   = google_compute_network.vpc_network[each.key].id
  direction = var.ingress
  priority  = var.firewall_deny_priority

  deny {
    protocol = "tcp"
  }

  source_ranges = [var.source_ranges]
  destination_ranges = [
    google_sql_database_instance.database_instance[each.key].first_ip_address
  ]
}

//lb_firewall

resource "google_compute_firewall" "default" {
  for_each = var.vpcs
  name     = var.google_compute_firewall_name
  allow {
    protocol = var.protocol
    ports    = [var.httpport]
  }
  direction     = "INGRESS"
  network       = google_compute_network.vpc_network[each.key].id
  priority      = 1000
  source_ranges = ["130.211.0.0/22", "35.191.0.0/16"]
  target_tags   = ["webapp"]
}

resource "google_compute_health_check" "default" {
  name               = var.health_check_name
  check_interval_sec = 5
  healthy_threshold  = 2
  http_health_check {
    request_path = "/healthz"
    port         = var.httpport
  }
  timeout_sec         = 5
  unhealthy_threshold = 2
}

resource "google_compute_backend_service" "default" {
  for_each              = var.vpcs
  name                  = var.backend_service_name
  load_balancing_scheme = "EXTERNAL_MANAGED"
  health_checks         = [google_compute_health_check.default.id]
  protocol              = "HTTP"
  timeout_sec           = 30
  backend {
    group           = google_compute_region_instance_group_manager.app_manager[each.key].instance_group
    balancing_mode  = "UTILIZATION"
    capacity_scaler = 1.0
  }
}

resource "google_compute_url_map" "default" {
  for_each        = var.vpcs
  name            = var.url_map_name
  default_service = google_compute_backend_service.default[each.key].id
}

resource "google_compute_global_forwarding_rule" "default" {
  for_each              = var.vpcs
  name                  = var.forwarding_rule_name
  load_balancing_scheme = "EXTERNAL_MANAGED"
  port_range            = "443"
  target                = google_compute_target_https_proxy.lb_default[each.key].self_link
  ip_address            = google_compute_global_address.load_balance_ip.address
}

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
  name    = "${each.key}-allow-http"
  network = google_compute_network.vpc_network[each.key].self_link

  allow {
    protocol = var.protocol
    ports    = [var.httpport]
  }

  source_ranges = [var.source_ranges]
  target_tags = ["webapp"]
}

resource "google_compute_firewall" "deny_ssh" {
  for_each = var.vpcs
  name    = "${each.key}-deny-ssh"
  network = google_compute_network.vpc_network[each.key].self_link

  deny {
    protocol = var.protocol
    ports    = [var.sshport]
  }

  source_ranges = [var.source_ranges]
  target_tags = ["webapp"]
}
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

resource "google_compute_network" "vpc_network" {
  for_each                = var.vpcs
  name                    = each.key
  auto_create_subnetworks = false
  routing_mode            = var.network_routing_mode
  delete_default_routes_on_create = true
}

resource "google_compute_firewall" "allow_http" {
  for_each = var.vpcs
  name    = "${each.key}-allow-http"
  network = google_compute_network.vpc_network[each.key].self_link

  allow {
    protocol = "tcp"
    ports    = ["80"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags = ["webapp"]
}

resource "google_compute_firewall" "deny_ssh" {
  for_each = var.vpcs
  name    = "${each.key}-deny-ssh"
  network = google_compute_network.vpc_network[each.key].self_link

  deny {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
  target_tags = ["webapp"]
}

resource "google_compute_subnetwork" "webapp_subnet" {
  for_each      = var.vpcs
  name          = "${each.key}-webapp"
  ip_cidr_range = each.value.webapp_subnet_cidr
  region        = each.value.region
  network       = google_compute_network.vpc_network[each.key].self_link
}

resource "google_compute_subnetwork" "db_subnet" {
  for_each      = var.vpcs
  name          = "${each.key}-db"
  ip_cidr_range = each.value.db_subnet_cidr
  region        = each.value.region
  network       = google_compute_network.vpc_network[each.key].self_link
}

resource "google_compute_route" "webapp_route" {
  for_each      = var.vpcs
  name          = "${each.key}-route"
  dest_range    = "0.0.0.0/0"
  network       = google_compute_network.vpc_network[each.key].self_link
  next_hop_gateway = var.next_hop_gateway
  tags = ["webapp"]
}
resource "google_compute_instance" "custom_instance" {
  name         = "custom-instance-${var.instance_vpc_name}"
  machine_type = var.machine_type
  zone         = var.zone
  network_interface {
    subnetwork = google_compute_subnetwork.webapp_subnet[var.instance_vpc_name].self_link
  }

  boot_disk {
    initialize_params {
      image = var.image  # Reference to your existing custom image
      size  = var.size
      type  = var.type
    }
  }

  tags = ["webapp"]
}
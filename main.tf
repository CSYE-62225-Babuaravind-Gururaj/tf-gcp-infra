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
  routing_mode            = "REGIONAL"
  delete_default_routes_on_create = true
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
  next_hop_gateway = "default-internet-gateway"
  tags = ["webapp"]
}
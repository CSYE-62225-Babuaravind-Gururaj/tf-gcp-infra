resource "google_compute_instance" "custom_instance" {
  for_each     = var.vpcs
  name         = "custom-instance-${var.instance_vpc_name}"
  machine_type = var.machine_type
  zone         = var.zone

  network_interface {
    subnetwork = google_compute_subnetwork.webapp_subnet[var.instance_vpc_name].self_link
    access_config {
    }
  }

  service_account {
    email  = google_service_account.service_account.email
    scopes = [
      "https://www.googleapis.com/auth/cloud-platform",
    ]
  }

  boot_disk {
    initialize_params {
      image = var.image
      size  = var.size
      type  = var.type
    }
    auto_delete = true
  }

  tags = ["webapp"]

  metadata_startup_script = templatefile("${path.module}/userdata.sh", {
    for_each         = var.vpcs
    application_port = var.httpport
    db_port          = var.db_port
    ip_address       = google_sql_database_instance.database_instance[each.key].ip_address.0.ip_address
    username         = google_sql_user.users[each.key].name
    password         = google_sql_user.users[each.key].password
    db_name          = google_sql_database.database[each.key].name
  })

}

resource "google_dns_record_set" "a_record" {
  for_each     = var.vpcs
  name         = var.dns_name
  type         = "A"
  ttl          = 300
  managed_zone = var.dns_zone_name
  rrdatas      = [google_compute_instance.custom_instance[each.key].network_interface[0].access_config[0].nat_ip]
}

resource "google_service_account" "service_account" {
  account_id   = "service-account-id"
  display_name = "Service Account"
}

resource "google_project_iam_binding" "logging_admin_binding" {
  project = var.project
  role    = "roles/logging.admin"

  members = [
    "serviceAccount:${google_service_account.service_account.email}",
  ]
}

resource "google_project_iam_binding" "monitoring_metric_writer_binding" {
  project = var.project
  role    = "roles/monitoring.metricWriter"

  members = [
    "serviceAccount:${google_service_account.service_account.email}",
  ]
}
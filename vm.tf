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
    scopes = ["logging-write", "monitoring-write", "pubsub"]
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
    GCP_PROJECT_ID   = var.project
  })

}

resource "google_dns_record_set" "a_record" {
  for_each     = var.vpcs
  name         = var.dns_name
  type         = "A"
  ttl          = 300
  managed_zone = var.dns_zone_name
  rrdatas      = [google_compute_global_address.load_balance_ip.address]
}

resource "google_service_account" "service_account" {
  account_id   = "service-account-id"
  display_name = "Service Account"
}

resource "google_service_account" "cloud_func_service_account" {
  account_id   = "cloud-func-service-account-id"
  display_name = "Cloud Function Service Account"
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

data "google_project" "project" {
}
 
resource "google_kms_crypto_key_iam_binding" "vm_enc_decrypt_binding" {
  crypto_key_id = google_kms_crypto_key.vm_key.id
  role          = "roles/cloudkms.cryptoKeyEncrypterDecrypter"
 
  members = [
    "serviceAccount:service-${data.google_project.project.number}@compute-system.iam.gserviceaccount.com",
  ]
}

resource "google_project_iam_binding" "terraform_cloud_fn" {
  project = var.project
  role    = "roles/run.invoker"

  members = [
    "serviceAccount:${google_service_account.cloud_func_service_account.email}",
  ]
}
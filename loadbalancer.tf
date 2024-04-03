resource "google_compute_region_instance_template" "default" {
  for_each         = var.vpcs
  name = var.region_instance_name
  disk {
    auto_delete  = true
    source_image = var.image
    disk_size_gb = 100
  }
  machine_type = var.lb_machine_type
 metadata_startup_script = templatefile("${path.module}/userdata.sh", {
    for_each         = var.vpcs
    application_port = var.httpport
    db_port          = var.db_port
    ip_address       = google_sql_database_instance.database_instance[each.key].ip_address.0.ip_address
    username         = google_sql_user.users[each.key].name
    password         = google_sql_user.users[each.key].password
    db_name          = google_sql_database.database[each.key].name
    GCP_PROJECT_ID   = var.project
  }
  )
  network_interface {
    subnetwork = google_compute_subnetwork.webapp_subnet[each.key].id
  }
  service_account {
    email  = google_service_account.service_account.email
    scopes = ["logging-write", "monitoring-write", "pubsub"]
  }
  tags = ["webapp"]
}

resource "google_compute_target_https_proxy" "lb_default" {
  for_each = var.vpcs
  name     = "myservice-https-proxy"
  url_map  = google_compute_url_map.default[each.key].id
  ssl_certificates = [var.lb_proxy]
}

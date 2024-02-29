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
resource "google_service_networking_connection" "db_private_vpc_conn" {
  for_each                  = var.vpcs
  network                   = google_compute_network.vpc_network[each.key].id
  service                   = var.service_network
  reserved_peering_ranges   = [google_compute_global_address.db_private_ip[each.key].name]
}

resource "google_sql_database_instance" "database_instance" {
  for_each            = var.vpcs
  name                = "${each.key}-database-instance"
  database_version    = var.database_version
  depends_on          = [google_service_networking_connection.db_private_vpc_conn]
  deletion_protection = false

  settings {
    tier              = var.db_tier
    availability_type = var.db_availability_type
    disk_size         = var.db_disk_size
    disk_type         = var.db_disk_type

    ip_configuration {
        authorized_networks {
        name            = "Network Name"
        value           = "192.0.2.0/24"
        expiration_time = "3021-11-15T16:19:00.094Z"
        }
        ipv4_enabled                                  = false
        private_network                               = google_compute_network.vpc_network[each.key].id
        enable_private_path_for_google_cloud_services = true
    }

    backup_configuration {
      enabled            = true
    }
  }
}

resource "google_sql_database" "database" {
  for_each  = var.vpcs
  name      = "${each.key}-db"
  instance  = google_sql_database_instance.database_instance[each.key].name
}

resource "google_compute_global_address" "db_private_ip" {
  for_each      = var.vpcs
  name          = "${each.key}-db-private-ip"
  purpose       = var.db_address_purpose
  prefix_length = var.db_address_prefix
  address_type  = var.db_address_type
  network       = google_compute_network.vpc_network[each.key].id
}

resource "random_password" "password" {
  length           = var.pass_Len
  special          = false
  //override_special = "!#$%&*()-_=+[]{}<>:?"
}

resource "google_sql_user" "users" {
  for_each  = var.vpcs
  name      = var.webapp_name
  instance  = google_sql_database_instance.database_instance[each.key].name
  password  = random_password.password.result
}
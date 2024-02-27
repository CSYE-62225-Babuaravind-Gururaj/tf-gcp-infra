resource "google_compute_instance" "custom_instance" {
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
      image = var.image  # Reference to your existing custom image
      size  = var.size
      type  = var.type
    }
  }

  tags = ["webapp"]
}
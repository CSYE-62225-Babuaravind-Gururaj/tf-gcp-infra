resource "google_compute_region_instance_group_manager" "app_manager" {
  for_each         = var.vpcs
  name               = var.instance_group_manager
  region             = var.region

  version {
    instance_template  = google_compute_region_instance_template.default[each.key].self_link
  }
  base_instance_name = "instance-manager"

  named_port {
    name = var.named_port_type
    port = var.httpport
  }

  auto_healing_policies {
    health_check      = google_compute_health_check.default.self_link
    initial_delay_sec = 300
  }
}

resource "google_compute_region_autoscaler" "app_autoscaler" {
  for_each         = var.vpcs
  name   = "app-autoscaler"
  region = var.region
  target = google_compute_region_instance_group_manager.app_manager[each.key].self_link

  autoscaling_policy {
    max_replicas    = var.max_replicas
    min_replicas    = var.min_replicas
    cooldown_period = var.cool_down_period
    cpu_utilization {
      target = var.cpu_utlization
    }
  }
}

resource "google_compute_backend_service" "app_backend_service" {
  for_each    = var.vpcs
  name        = "app-backend-service"
  protocol    = "HTTPS"
  health_checks = [google_compute_health_check.default.self_link]

  backend {
    group = google_compute_region_instance_group_manager.app_manager[each.key].instance_group
  }
}

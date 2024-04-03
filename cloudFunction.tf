resource "google_cloudfunctions2_function" "verify_email_function" {
  for_each    = var.vpcs
  location    = var.region
  name        = var.cloud_func_topic
  description = "cloud function for email"

  build_config {
    runtime     = var.go_runtime
    entry_point = var.function_entry
    source {
      storage_source {
        bucket = google_storage_bucket.functions_bucket.name
        object = google_storage_bucket_object.serverless_function_archive.name
      }
    }
  }

  service_config {
    max_instance_count             = 1
    available_memory               = var.cloud_func_memory
    timeout_seconds                = var.cloud_func_timeout
    ingress_settings               = var.cloud_func_ingress
    all_traffic_on_latest_revision = true
    service_account_email          = google_service_account.service_account.email
    environment_variables = {
      DB_HOST = "${google_sql_database_instance.database_instance[each.key].ip_address.0.ip_address}"
      DBUSER                  = "${google_sql_user.users[each.key].name}"
      DBPASS                  = "${google_sql_user.users[each.key].password}"
      DBNAME = "${google_sql_database.database[each.key].name}"
      MAILGUN_API_KEY         = var.mailgun_api_key
      SENDER_DOMAIN           = var.sender_domain
    }
    vpc_connector                 = google_vpc_access_connector.connector[each.key].id
    vpc_connector_egress_settings = "PRIVATE_RANGES_ONLY"
  }

  event_trigger {
    trigger_region = var.region
    event_type     = "google.cloud.pubsub.topic.v1.messagePublished"
    pubsub_topic   = google_pubsub_topic.verify_email_topic.id
    retry_policy   = "RETRY_POLICY_DO_NOT_RETRY"
  }

}

//iam for cloud member
resource "google_cloudfunctions2_function_iam_member" "functions_invoker_member" {
  for_each       = var.vpcs
  cloud_function = google_cloudfunctions2_function.verify_email_function[each.key].name

  role   = var.cloud_func_role
  member = "serviceAccount:${google_service_account.service_account.email}"
}
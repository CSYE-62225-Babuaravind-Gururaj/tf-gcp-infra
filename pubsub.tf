# resource "google_pubsub_topic" "verify_email" {
#   name = "verify_email"
# }

# resource "google_pubsub_subscription" "verify_email_subscription" {
#   name  = "verify_email_subscription"
#   topic = google_pubsub_topic.verify_email.name

#   message_retention_duration = "604800s" # 7 days
#   ack_deadline_seconds       = 20
# }

resource "google_pubsub_topic" "verify_email_topic" {
  name                       = "verify_email"
  message_retention_duration = "604800s"
}

resource "google_pubsub_subscription" "verify_email_subscription" {
  name  = "verify-email-subscription"
  topic = google_pubsub_topic.verify_email_topic.id

  message_retention_duration   = "604800s"
  ack_deadline_seconds         = 20
  enable_message_ordering      = true
  enable_exactly_once_delivery = true
}

resource "google_pubsub_topic_iam_member" "pubsub_publisher_member" {
  for_each  = var.vpcs
  project   = google_pubsub_topic.verify_email_topic.project
  topic     = google_pubsub_topic.verify_email_topic.name
  role      = "roles/pubsub.publisher"
  member    = "serviceAccount:${google_service_account.service_account.email}"
}

resource "google_pubsub_subscription_iam_member" "pubsub_subscriber_member" {
  for_each     = var.vpcs
  subscription = google_pubsub_subscription.verify_email_subscription.name
  role         = "roles/pubsub.subscriber"
  member       = "serviceAccount:${google_service_account.service_account.email}"
}

data "archive_file" "source" {
  type        = "zip"
  source_dir  = "/Users/aravind/babuaravind_gururaj_002798604/serverless"
  output_path = "/tmp/serverless.zip"
}

resource "google_storage_bucket" "functions_bucket" {
  name          = "${var.project}-functions-bucket"
  location      = var.region
  force_destroy = true
  # encryption {
  #   default_kms_key_name = google_kms_crypto_key.storage_key.id
  # }
}
resource "google_storage_bucket_object" "serverless_function_archive" {
  name   = "${data.archive_file.source.output_md5}.zip"
  bucket = google_storage_bucket.functions_bucket.name
  source = data.archive_file.source.output_path
}

resource "google_project_iam_binding" "serverless_binding" {
  project = var.project
  role    = "roles/cloudkms.cryptoKeyEncrypterDecrypter"

  members = [
    "serviceAccount:${google_service_account.service_account.email}",
  ]
}
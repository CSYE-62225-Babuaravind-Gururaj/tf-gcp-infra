resource "google_kms_key_ring" "keyring" {
  name     = "cloud-key-ring3"
  location = var.region
}

//CMEK setup
resource "google_kms_crypto_key" "vm_key" {
  name            = "vm-crypto-key"
  key_ring        = google_kms_key_ring.keyring.id
  rotation_period = "2592000s"

  lifecycle {
    prevent_destroy = false
  }
}

resource "google_kms_crypto_key" "sql_key" {
  name            = "sql-key"
  key_ring        = google_kms_key_ring.keyring.id
  rotation_period = "2592000s"

  lifecycle {
    prevent_destroy = false
  }
}

resource "google_kms_crypto_key" "storage_key" {
  name            = "storage-key"
  key_ring        = google_kms_key_ring.keyring.id
  rotation_period = "2592000s"

  lifecycle {
    prevent_destroy = false
  }
}

resource "google_storage_bucket" "compliant_bucket" {
  name     = "${var.project_id}-compliant-bucket"
  location = var.region
  project  = var.project_id

  # Uniform bucket-level access enabled
  uniform_bucket_level_access = true

  # Versioning enabled
  versioning {
    enabled = true
  }

  # Logging enabled
  logging {
    log_bucket        = "${var.project_id}-logs-bucket"
    log_object_prefix = "storage-logs"
  }

  retention_policy {
    retention_period = 2592000 # 30 days in seconds
    is_locked        = true
  }
}

# Logs bucket with retention policy and bucket lock
resource "google_storage_bucket" "logs_bucket" {
  name     = "${var.project_id}-logs-bucket"
  location = var.region
  project  = var.project_id

  # Uniform bucket-level access enabled
  uniform_bucket_level_access = true

  # Retention policy with bucket lock
  retention_policy {
    retention_period = 2592000 # 30 days in seconds
    is_locked        = true
  }

  # Versioning enabled
  versioning {
    enabled = true
  }
}

# Private access through IAM binding
resource "google_storage_bucket_iam_binding" "private_binding" {
  bucket  = google_storage_bucket.compliant_bucket.name
  role    = "roles/storage.objectViewer"
  members = ["serviceAccount:${google_service_account.runsa.email}"] # Only service account has access
}

# Audit logs bucket
resource "google_storage_bucket" "audit_logs" {
  name                        = "${var.project_id}-audit-logs"
  location                    = var.region
  project                     = var.project_id
  uniform_bucket_level_access = false

  # Retention policy with bucket lock
  retention_policy {
    retention_period = 2592000 # 30 days in seconds
    is_locked        = true
  }
}

# IAM binding for all logs sink writer
resource "google_storage_bucket_iam_binding" "all_logs_sink_writer" {
  bucket = google_storage_bucket.audit_logs.name
  role   = "roles/storage.objectCreator"
  members = [
    google_logging_project_sink.all_logs_sink.writer_identity,
  ]
}

# IAM binding for audit sink writer
resource "google_storage_bucket_iam_binding" "audit_sink_writer" {
  bucket = google_storage_bucket.audit_logs.name
  role   = "roles/storage.objectCreator"
  members = [
    google_logging_project_sink.audit_sink.writer_identity,
  ]
}
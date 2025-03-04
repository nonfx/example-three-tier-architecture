# Service account for Cloud Run
resource "google_service_account" "runsa" {
  project      = var.project_id
  account_id   = "${var.deployment_name}-run-sa"
  display_name = "Service Account for Cloud Run"
}

# IAM roles for the service account
resource "google_project_iam_member" "allrun" {
  for_each = toset(var.run_roles_list)
  project  = data.google_project.project.number
  role     = each.key
  member   = "serviceAccount:${google_service_account.runsa.email}"
}

# Service account with least privilege
resource "google_service_account" "least_privilege_sa" {
  project      = var.project_id
  account_id   = "${var.deployment_name}-least-privilege-sa"
  display_name = "Service Account with least privilege"
}

# Granting minimal permissions to service account
resource "google_project_iam_member" "least_privilege_sa_viewer" {
  project = var.project_id
  role    = "roles/viewer" # Read-only role
  member  = "serviceAccount:${google_service_account.least_privilege_sa.email}"
}

# Service account for viewer role
resource "google_service_account" "viewer_sa" {
  project      = var.project_id
  account_id   = "${var.deployment_name}-viewer-sa"
  display_name = "Service Account with viewer role"
}

# Assign viewer role to service account
resource "google_project_iam_member" "viewer_member" {
  project = var.project_id
  role    = "roles/viewer"
  member  = "serviceAccount:${google_service_account.viewer_sa.email}"
}

# Assign storage viewer role to service account using binding
resource "google_project_iam_binding" "storage_viewer_binding" {
  project = var.project_id
  role    = "roles/storage.objectViewer"
  members = [
    "serviceAccount:${google_service_account.viewer_sa.email}"
  ]
}

# Cloud Run service IAM member for API
resource "google_cloud_run_service_iam_member" "noauth_api" {
  location = google_cloud_run_service.api.location
  project  = google_cloud_run_service.api.project
  service  = google_cloud_run_service.api.name
  role     = "roles/run.invoker"
  member   = "serviceAccount:${google_service_account.runsa.email}"
}

# Cloud Run service IAM member for frontend
resource "google_cloud_run_service_iam_member" "noauth_fe" {
  location = google_cloud_run_service.fe.location
  project  = google_cloud_run_service.fe.project
  service  = google_cloud_run_service.fe.name
  role     = "roles/run.invoker"
  member   = "serviceAccount:${google_service_account.runsa.email}"
}

# API Key with restrictions
resource "google_apikeys_key" "compliant_api_key" {
  name         = "${var.deployment_name}-restricted-api-key"
  display_name = "Compliant API Key with restrictions"
  project      = var.project_id

  # API restrictions
  restrictions {
    api_targets {
      service = "compute.googleapis.com"
    }
    browser_key_restrictions {
      allowed_referrers = ["example.com/*"]
    }
  }
}

# Access Approval configuration
resource "google_access_approval_project_settings" "project_access_approval" {
  project_id = var.project_id
  enrolled_services {
    cloud_product = "all"
  }
}

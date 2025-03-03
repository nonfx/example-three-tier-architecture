# Enable required Google APIs
resource "google_project_service" "compute_api" {
  project                    = var.project_id
  service                    = "compute.googleapis.com"
  disable_dependent_services = false
  disable_on_destroy         = false
}

resource "google_project_service" "cloudapis_api" {
  project                    = var.project_id
  service                    = "cloudapis.googleapis.com"
  disable_dependent_services = false
  disable_on_destroy         = false
}

resource "google_project_service" "vpcaccess_api" {
  project                    = var.project_id
  service                    = "vpcaccess.googleapis.com"
  disable_dependent_services = false
  disable_on_destroy         = false
}

resource "google_project_service" "servicenetworking_api" {
  project                    = var.project_id
  service                    = "servicenetworking.googleapis.com"
  disable_dependent_services = false
  disable_on_destroy         = false
}

resource "google_project_service" "cloudbuild_api" {
  project                    = var.project_id
  service                    = "cloudbuild.googleapis.com"
  disable_dependent_services = false
  disable_on_destroy         = false
}

resource "google_project_service" "sql_component_api" {
  project                    = var.project_id
  service                    = "sql-component.googleapis.com"
  disable_dependent_services = false
  disable_on_destroy         = false
}

resource "google_project_service" "sqladmin_api" {
  project                    = var.project_id
  service                    = "sqladmin.googleapis.com"
  disable_dependent_services = false
  disable_on_destroy         = false
}

resource "google_project_service" "storage_api" {
  project                    = var.project_id
  service                    = "storage.googleapis.com"
  disable_dependent_services = false
  disable_on_destroy         = false
}

resource "google_project_service" "run_api" {
  project                    = var.project_id
  service                    = "run.googleapis.com"
  disable_dependent_services = false
  disable_on_destroy         = false
}

resource "google_project_service" "redis_api" {
  project                    = var.project_id
  service                    = "redis.googleapis.com"
  disable_dependent_services = false
  disable_on_destroy         = false
}

resource "google_project_service" "dns_api" {
  project                    = var.project_id
  service                    = "dns.googleapis.com"
  disable_dependent_services = false
  disable_on_destroy         = false
}

resource "google_project_service" "accessapproval_api" {
  project                    = var.project_id
  service                    = "accessapproval.googleapis.com"
  disable_dependent_services = false
  disable_on_destroy         = false
}

resource "google_project_service" "monitoring_api" {
  project                    = var.project_id
  service                    = "monitoring.googleapis.com"
  disable_dependent_services = false
  disable_on_destroy         = false
}

# Explicitly enable Cloud IAM API
resource "google_project_service" "iam_api" {
  project                    = var.project_id
  service                    = "iam.googleapis.com"
  disable_dependent_services = false
  disable_on_destroy         = false
}

# Explicitly enable API Gateway API
resource "google_project_service" "apigateway_api" {
  project                    = var.project_id
  service                    = "apigateway.googleapis.com"
  disable_dependent_services = false
  disable_on_destroy         = false
}

# Explicitly enable Cloud Asset Inventory API
resource "google_project_service" "cloud_asset_inventory" {
  project                    = var.project_id
  service                    = "cloudasset.googleapis.com"
  disable_dependent_services = false
  disable_on_destroy         = false
}

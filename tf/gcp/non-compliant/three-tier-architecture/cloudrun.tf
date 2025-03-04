# Cloud Run API service
resource "google_cloud_run_service" "api" {
  name     = "${var.deployment_name}-api"
  provider = google-beta
  location = var.region
  project  = var.project_id
  template {
    spec {
      service_account_name = google_service_account.runsa.email
      containers {
        image = local.api_image
        dynamic "env" {
          for_each = var.database_type == "postgresql" ? local.api_env_vars_postgresql : local.api_env_vars_mysql
          content {
            name  = env.key
            value = env.value
          }
        }
      }
    }
    metadata {
      annotations = {
        "autoscaling.knative.dev/maxScale"        = "8"
        "run.googleapis.com/cloudsql-instances"   = google_sql_database_instance.main.connection_name
        "run.googleapis.com/client-name"          = "terraform"
        "run.googleapis.com/vpc-access-egress"    = "all"
        "run.googleapis.com/vpc-access-connector" = google_vpc_access_connector.main.id
      }
      labels = {
        "run.googleapis.com/startupProbeType" = "Default"
      }
    }
  }
  metadata {
    labels = var.labels
  }
  autogenerate_revision_name = true
  depends_on = [
    google_sql_user.main,
    google_sql_database.database
  ]
}

# Cloud Run frontend service
resource "google_cloud_run_service" "fe" {
  name     = "${var.deployment_name}-fe"
  location = var.region
  project  = var.project_id
  template {
    spec {
      service_account_name = google_service_account.runsa.email
      containers {
        image = local.fe_image
        ports {
          container_port = 80
        }
        env {
          name  = "ENDPOINT"
          value = google_cloud_run_service.api.status[0].url
        }
      }
    }
    metadata {
      annotations = {
        "autoscaling.knative.dev/maxScale" = "8"
      }
      labels = {
        "run.googleapis.com/startupProbeType" = "Default"
      }
    }
  }
  metadata {
    labels = var.labels
  }
}

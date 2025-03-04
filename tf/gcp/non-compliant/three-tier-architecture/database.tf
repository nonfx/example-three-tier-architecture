# Redis instance
resource "google_redis_instance" "main" {
  authorized_network      = google_compute_network.main.name
  connect_mode            = "DIRECT_PEERING"
  location_id             = var.zone
  memory_size_gb          = 1
  name                    = "${var.deployment_name}-cache"
  display_name            = "${var.deployment_name}-cache"
  project                 = var.project_id
  redis_version           = "REDIS_6_X"
  region                  = var.region
  reserved_ip_range       = "10.137.125.88/29"
  tier                    = "BASIC"
  transit_encryption_mode = "TRANSIT_ENCRYPTION_MODE_SERVER_AUTHENTICATION"
  labels                  = var.labels
}

# Random ID for database instance name
resource "random_id" "id" {
  byte_length = 2
}

# Cloud SQL instance
resource "google_sql_database_instance" "main" {
  name             = "${var.deployment_name}-db-${random_id.id.hex}"
  database_version = (var.database_type == "mysql" ? "MYSQL_8_0" : "POSTGRES_14")
  region           = var.region
  project          = var.project_id
  settings {
    tier                  = "db-g1-small"
    disk_autoresize       = true
    disk_autoresize_limit = 0
    disk_size             = 10
    disk_type             = "PD_SSD"
    user_labels           = var.labels
    ip_configuration {
      ipv4_enabled    = false
      private_network = "projects/${var.project_id}/global/networks/${google_compute_network.main.name}"
    }
    location_preference {
      zone = var.zone
    }
    dynamic "database_flags" {
      for_each = var.database_type == "postgresql" ? [1] : []
      content {
        name  = "cloudsql.iam_authentication"
        value = "on"
      }
    }

    database_flags {
      name  = "cloudsql.enable_pgaudit"
      value = "on"
    }

    # Compliant database flags
    database_flags {
      name  = "log_connections"
      value = "on"
    }

    database_flags {
      name  = "log_disconnections"
      value = "on"
    }

    # For PostgreSQL
    dynamic "database_flags" {
      for_each = var.database_type == "postgresql" ? [1] : []
      content {
        name  = "log_min_duration_statement"
        value = "-1"
      }
    }

    dynamic "database_flags" {
      for_each = var.database_type == "postgresql" ? [1] : []
      content {
        name  = "log_min_error_statement"
        value = "ERROR"
      }
    }

    dynamic "database_flags" {
      for_each = var.database_type == "postgresql" ? [1] : []
      content {
        name  = "log_min_messages"
        value = "warning"
      }
    }

    dynamic "database_flags" {
      for_each = var.database_type == "postgresql" ? [1] : []
      content {
        name  = "log_min_duration_statement"
        value = "-1"
      }
    }

    dynamic "database_flags" {
      for_each = var.database_type == "postgresql" ? [1] : []
      content {
        name  = "log_error_verbosity"
        value = "DEFAULT"
      }
    }

    # For MySQL
    dynamic "database_flags" {
      for_each = var.database_type == "mysql" ? [1] : []
      content {
        name  = "local_infile"
        value = "off"
      }
    }

    dynamic "database_flags" {
      for_each = var.database_type == "mysql" ? [1] : []
      content {
        name  = "skip_show_database"
        value = "on"
      }
    }
  }
  deletion_protection = false
  depends_on = [
    google_service_networking_connection.main
  ]
}

# Database user
resource "google_sql_user" "main" {
  project         = var.project_id
  instance        = google_sql_database_instance.main.name
  deletion_policy = "ABANDON"
  name            = var.database_type == "postgresql" ? "${google_service_account.runsa.account_id}@${var.project_id}.iam" : "foo"
  type            = var.database_type == "postgresql" ? "CLOUD_IAM_SERVICE_ACCOUNT" : null
  password        = var.database_type == "mysql" ? "bar" : null
}

# Database
resource "google_sql_database" "database" {
  project         = var.project_id
  name            = "todo"
  instance        = google_sql_database_instance.main.name
  deletion_policy = "ABANDON"
}
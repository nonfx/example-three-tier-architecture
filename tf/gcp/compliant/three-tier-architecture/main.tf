provider "google" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

provider "google-beta" {
  project = var.project_id
  region  = var.region
  zone    = var.zone
}

provider "random" {}

data "google_project" "project" {
  project_id = var.project_id
}

resource "google_compute_instance" "critical_vm" {
  name         = "${var.deployment_name}-critical-vm"
  machine_type = "e2-medium"
  zone         = var.zone
  project      = var.project_id
  tags         = ["critical", "production"]
  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
      size  = 20
      type  = "pd-standard"
    }
    # Using disk encryption key
    disk_encryption_key_raw = "SGVsbG8gZnJvbSBHb29nbGUgQ2xvdWQgUGxhdGZvcm0="
  }
  network_interface {
    network = google_compute_network.main.self_link
    # No public IP
  }
  metadata = {
    environment = "production"
    criticality = "high"
    # Serial port disabled
    serial-port-enable = "false"
    # Block project SSH keys enabled
    # Added block-project-ssh-keys to prevent shared key access across project instances
    block-project-ssh-keys = "true"
    # OS Login enabled
    enable-oslogin = "true"
  }
  labels = {
    critical    = "true"
    environment = "production"
  }
  service_account {
    email  = google_service_account.runsa.email
    scopes = ["cloud-platform"]
  }
  # IP forwarding disabled
  can_ip_forward = false

  # Shielded VM settings enabled
  shielded_instance_config {
    enable_secure_boot          = true
    enable_vtpm                 = true
    enable_integrity_monitoring = true
  }

  # Confidential computing enabled for enhanced data security during processing
  confidential_instance_config {
    enable_confidential_compute = true
  }
}

# VM using specific service account
resource "google_compute_instance" "specific_sa_vm" {
  name         = "${var.deployment_name}-specific-sa-vm"
  machine_type = "e2-medium"
  zone         = var.zone
  project      = var.project_id

  boot_disk {
    initialize_params {
      image = "debian-cloud/debian-11"
    }
    # Using disk encryption key
    disk_encryption_key_raw = "SGVsbG8gZnJvbSBHb29nbGUgQ2xvdWQgUGxhdGZvcm0="
  }

  network_interface {
    network = google_compute_network.main.self_link
    # No public IP
  }

  metadata = {
    # OS Login enabled
    enable-oslogin = "true"
    # Block project SSH keys enabled
    block-project-ssh-keys = "true"
    # Serial port disabled
    serial-port-enable = "false"
  }

  # Using specific service account
  service_account {
    email  = google_service_account.runsa.email
    scopes = ["cloud-platform"]
  }

  # Shielded VM settings enabled
  shielded_instance_config {
    enable_secure_boot          = true
    enable_vtpm                 = true
    enable_integrity_monitoring = true
  }

  # Confidential computing
  confidential_instance_config {
    enable_confidential_compute = true
  }

  # IP forwarding disabled
  can_ip_forward = false
}
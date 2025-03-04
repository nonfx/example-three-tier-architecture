resource "google_compute_network" "main" {
  provider                = google-beta
  name                    = "${var.deployment_name}-private-network"
  auto_create_subnetworks = true
  project                 = var.project_id
}

resource "google_dns_policy" "default_policy" {
  name           = "${var.deployment_name}-dns-policy"
  project        = var.project_id
  enable_logging = true
  networks {
    network_url = google_compute_network.main.id
  }
}

resource "google_compute_global_address" "main" {
  name          = "${var.deployment_name}-vpc-address"
  provider      = google-beta
  purpose       = "VPC_PEERING"
  address_type  = "INTERNAL"
  prefix_length = 16
  network       = google_compute_network.main.name
  project       = var.project_id
}

resource "google_service_networking_connection" "main" {
  network                 = google_compute_network.main.self_link
  service                 = "servicenetworking.googleapis.com"
  reserved_peering_ranges = [google_compute_global_address.main.name]
}

resource "google_vpc_access_connector" "main" {
  provider       = google-beta
  project        = var.project_id
  name           = "${var.deployment_name}-vpc-cx"
  ip_cidr_range  = "10.8.0.0/28"
  network        = google_compute_network.main.name
  region         = var.region
  max_throughput = 300
}

resource "google_compute_subnetwork" "compliant_subnet" {
  name          = "${var.deployment_name}-subnet-with-flow-logs"
  ip_cidr_range = "10.2.0.0/16"
  region        = var.region
  project       = var.project_id
  network       = google_compute_network.main.id

  log_config {
    aggregation_interval = "INTERVAL_5_SEC"
    flow_sampling        = 0.5
    metadata             = "INCLUDE_ALL_METADATA"
  }
}

resource "google_compute_firewall" "restrict_ssh" {
  name    = "${var.deployment_name}-restrict-ssh"
  network = google_compute_network.main.name
  project = var.project_id

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["192.168.1.0/24", "10.0.0.0/8"]
}

resource "google_compute_firewall" "restrict_rdp" {
  name    = "${var.deployment_name}-restrict-rdp"
  network = google_compute_network.main.name
  project = var.project_id

  allow {
    protocol = "tcp"
    ports    = ["3389"]
  }

  source_ranges = ["192.168.1.0/24", "10.0.0.0/8"]
}

resource "google_compute_url_map" "compliant_url_map" {
  name            = "${var.deployment_name}-url-map"
  project         = var.project_id
  default_service = google_compute_backend_service.compliant_backend.id
}

resource "google_compute_backend_service" "compliant_backend" {
  name          = "${var.deployment_name}-backend"
  project       = var.project_id
  port_name     = "http"
  protocol      = "HTTP"
  timeout_sec   = 10
  health_checks = [google_compute_health_check.compliant_health_check.id]

  # Logging configuration
  log_config {
    enable      = true
    sample_rate = 1.0
  }
}

resource "google_compute_health_check" "compliant_health_check" {
  name               = "${var.deployment_name}-health-check"
  project            = var.project_id
  check_interval_sec = 5
  timeout_sec        = 5

  http_health_check {
    port = 80
  }
}

resource "google_compute_target_https_proxy" "default" {
  name             = "${var.deployment_name}-https-proxy"
  project          = var.project_id
  url_map          = google_compute_url_map.compliant_url_map.id
  ssl_certificates = [google_compute_ssl_certificate.default.id]
}

resource "google_compute_ssl_certificate" "default" {
  name        = "${var.deployment_name}-certificate"
  project     = var.project_id
  private_key = file("${path.module}/ssl/example.key")
  certificate = file("${path.module}/ssl/example.crt")
}

resource "google_compute_global_forwarding_rule" "default" {
  name       = "${var.deployment_name}-forwarding-rule"
  project    = var.project_id
  target     = google_compute_target_https_proxy.default.id
  port_range = "443"
}

resource "google_compute_global_forwarding_rule_logging" "default" {
  project         = var.project_id
  forwarding_rule = google_compute_global_forwarding_rule.default.name
  enable          = true
  metadata        = "INCLUDE_ALL_METADATA"
}
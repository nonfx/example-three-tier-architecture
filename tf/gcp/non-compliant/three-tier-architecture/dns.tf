resource "google_dns_managed_zone" "compliant_zone" {
  name        = "${var.deployment_name}-example-zone"
  dns_name    = "example-${var.deployment_name}.com."
  description = "Example DNS zone with DNSSEC"
  project     = var.project_id

  dnssec_config {
    state = "on"
    default_key_specs {
      algorithm  = "rsasha256"
      key_length = 2048
      key_type   = ""
      kind       = "dns#dnsKeySpec"
    }
    default_key_specs {
      algorithm  = "rsasha1"
      key_length = 1024
      key_type   = ""
      kind       = "dns#dnsKeySpec"
    }
  }
}
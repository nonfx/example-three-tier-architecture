resource "google_dns_managed_zone" "compliant_zone" {
  name        = "${var.deployment_name}-example-zone"
  dns_name    = "example-${var.deployment_name}.com."
  description = "Example DNS zone with DNSSEC"
  project     = var.project_id

  # Changed key_type to "keySigning" for the RSASHA256 key spec to ensure proper key signing
  # Using RSASHA256 instead of RSASHA1 for key signing as per CIS benchmark 3.4
  # RSASHA1 is considered insecure for key signing and has been deprecated by Google
  dnssec_config {
    state = "on"
    default_key_specs {
      algorithm  = "rsasha256"
      key_length = 2048
      key_type   = "keySigning"
      kind       = "dns#dnsKeySpec"
    }
    default_key_specs {
      algorithm  = "rsasha1"
      key_length = 1024
      key_type   = "zoneSigning"
      kind       = "dns#dnsKeySpec"
    }
  }
}
terraform {
  required_version = ">= 0.13"
  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "<= 4.74, != 4.75.0"
    }
    google-beta = {
      source  = "hashicorp/google-beta"
      version = "<= 4.74, != 4.75.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 2.2"
    }
  }

  provider_meta "google" {
    module_name = "blueprints/terraform/terraform-google-three-tier-app/v0.1.9"
  }
}

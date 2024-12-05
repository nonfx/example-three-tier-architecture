terraform {
  required_providers {
    starchitect = {
      source = "registry.terraform.io/nonfx/starchitect"
      version = "1.0.0"
    }
  }
}

provider "starchitect" {}

resource "starchitect_iac_pac" "demo_example" {
    iac_path = var.iac_path
}

variable "iac_path" {
  default = "../tf/aws/non-compliant/three-tier-architecture"
}

output "scan_result" {
    value = starchitect_iac_pac.demo_example.scan_result
}

output "score" {
    value = starchitect_iac_pac.demo_example.score
}

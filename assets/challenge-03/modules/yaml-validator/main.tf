terraform {
  required_version = ">= 1.14"
}

locals {
  # Parse YAML
  config = yamldecode(file(var.config_file))

  # Check required keys
  missing_keys = [
    for key in var.required_keys :
    key if !contains(keys(local.config), key)
  ]

  # Validation checks
  has_all_keys = length(local.missing_keys) == 0
}

# Validation: Required keys present
resource "terraform_data" "validate_keys" {
  lifecycle {
    precondition {
      condition     = local.has_all_keys
      error_message = "Missing required keys: ${join(", ", local.missing_keys)}"
    }
  }
}

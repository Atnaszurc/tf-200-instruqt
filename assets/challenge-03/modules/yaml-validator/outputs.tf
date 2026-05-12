output "config" {
  description = "Parsed YAML configuration"
  value       = local.config
}

output "validation_status" {
  description = "Validation status"
  value = {
    valid        = local.has_all_keys
    missing_keys = local.missing_keys
  }
}

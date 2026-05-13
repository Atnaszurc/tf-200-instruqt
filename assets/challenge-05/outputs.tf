output "environment" {
  description = "Current environment"
  value       = var.environment
}

output "legacy_resources" {
  description = "Imported legacy resources"
  value = {
    network = "legacy-app-network (unmanaged)"
    server  = libvirt_domain.legacy.name
  }
}

output "app_stack" {
  description = "Application stack outputs"
  value       = module.app_stack
}

output "stack_summary" {
  description = "Path to stack summary file"
  value       = module.app_stack.stack_summary
}

output "network_id" {
  description = "Network ID (created or existing)"
  value       = local.network_id
}

output "vm_ids" {
  description = "Map of VM IDs"
  value       = { for k, v in libvirt_domain.vms : k => v.id }
}

output "monitoring_enabled" {
  description = "Whether monitoring is enabled"
  value       = local.monitoring_enabled
}

output "backup_enabled" {
  description = "Whether backup is enabled"
  value       = local.backup_enabled
}

output "autostart_enabled" {
  description = "Whether VMs auto-start"
  value       = local.autostart
}

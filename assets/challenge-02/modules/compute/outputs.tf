output "vm_ids" {
  description = "Map of VM IDs"
  value       = { for k, v in libvirt_domain.vms : k => v.id }
}

output "vm_names" {
  description = "Map of VM names"
  value       = { for k, v in libvirt_domain.vms : k => v.name }
}

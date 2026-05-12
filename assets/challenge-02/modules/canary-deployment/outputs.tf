output "deployment_summary" {
  description = "Deployment summary"
  value = {
    total_instances   = var.total_instances
    stable_count      = local.stable_count
    canary_count      = local.canary_count
    stable_version    = var.stable_version
    canary_version    = var.canary_version
    canary_percentage = var.canary_percentage
  }
}

output "stable_vm_ids" {
  description = "Stable version VM IDs"
  value       = [for vm in libvirt_domain.stable : vm.id]
}

output "canary_vm_ids" {
  description = "Canary version VM IDs"
  value       = [for vm in libvirt_domain.canary : vm.id]
}

output "stable_vm_names" {
  description = "Stable version VM names"
  value       = [for vm in libvirt_domain.stable : vm.name]
}

output "canary_vm_names" {
  description = "Canary version VM names"
  value       = [for vm in libvirt_domain.canary : vm.name]
}

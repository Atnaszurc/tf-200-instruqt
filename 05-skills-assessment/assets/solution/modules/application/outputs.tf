  description = "ID of the application network"
  value       = libvirt_network.application.id
}

output "stable_servers" {
  description = "Names of stable application servers"
  value       = libvirt_domain.application_stable[*].name
}

output "canary_servers" {
  description = "Names of canary application servers"
  value       = libvirt_domain.application_canary[*].name
}

output "total_server_count" {
  description = "Total number of application servers"
  value       = local.stable_count + local.canary_count
}

output "service_discovery_config" {
  description = "Service discovery configuration file"
  value       = local_file.service_discovery.filename
}

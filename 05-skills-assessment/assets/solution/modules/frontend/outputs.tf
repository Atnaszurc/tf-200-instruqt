output "network_id" {
  description = "ID of the frontend network"
  value       = libvirt_network.frontend.id
}

output "network_name" {
  description = "Name of the frontend network"
  value       = libvirt_network.frontend.name
}

output "server_names" {
  description = "Names of frontend servers"
  value       = libvirt_domain.frontend[*].name
}

output "server_count" {
  description = "Number of frontend servers"
  value       = length(libvirt_domain.frontend)
}

output "load_balancer_config" {
  description = "Load balancer configuration file path"
  value       = local_file.load_balancer_config.filename
}

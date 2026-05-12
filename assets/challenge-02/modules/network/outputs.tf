output "id" {
  description = "Network ID"
  value       = libvirt_network.network.id
}

output "name" {
  description = "Network name"
  value       = libvirt_network.network.name
}

output "bridge" {
  description = "Bridge interface"
  value       = libvirt_network.network.bridge
}

output "ips" {
  description = "Network IP configuration"
  value       = libvirt_network.network.ips
}

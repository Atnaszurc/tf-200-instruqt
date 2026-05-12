output "id" {
  description = "Network ID"
  value       = libvirt_network.this.id
}

output "name" {
  description = "Network name"
  value       = libvirt_network.this.name
}

output "bridge" {
  description = "Bridge interface"
  value       = libvirt_network.this.bridge
}

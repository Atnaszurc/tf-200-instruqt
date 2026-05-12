# modules/libvirt-network/outputs.tf

output "id" {
  description = "ID of the network"
  value       = libvirt_network.network.id
}

output "name" {
  description = "Name of the network"
  value       = libvirt_network.network.name
}

output "bridge" {
  description = "Bridge interface name"
  value       = libvirt_network.network.bridge
}

output "addresses" {
  description = "Network address ranges"
  value       = libvirt_network.network.addresses
}

# modules/libvirt-vm/outputs.tf

output "id" {
  description = "ID of the VM"
  value       = libvirt_domain.vm.id
}

output "name" {
  description = "Name of the VM"
  value       = libvirt_domain.vm.name
}

output "network_interfaces" {
  description = "Network interfaces of the VM"
  value       = libvirt_domain.vm.network_interface
}

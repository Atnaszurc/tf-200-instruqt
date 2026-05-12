output "pool_id" {
  description = "Storage pool ID"
  value       = libvirt_pool.this.id
}

output "pool_name" {
  description = "Storage pool name"
  value       = libvirt_pool.this.name
}

output "volume_ids" {
  description = "Map of volume IDs"
  value       = { for k, v in libvirt_volume.volumes : k => v.id }
}

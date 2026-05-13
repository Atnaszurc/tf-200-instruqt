output "network_id" {
  description = "ID of the database network"
  value       = libvirt_network.database.id
}

output "primary_server" {
  description = "Name of primary database server"
  value       = libvirt_domain.database_primary.name
}

output "replica_servers" {
  description = "Names of replica database servers"
  value       = libvirt_domain.database_replica[*].name
}

output "backup_pool_id" {
  description = "ID of backup storage pool"
  value       = var.backup_enabled ? libvirt_pool.backup[0].id : null
}

output "total_server_count" {
  description = "Total number of database servers"
  value       = 1 + length(libvirt_domain.database_replica)
}

# Database Module

## Description

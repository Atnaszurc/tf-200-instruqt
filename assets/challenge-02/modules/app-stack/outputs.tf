output "network_info" {
  description = "Network information"
  value = {
    id     = module.network.id
    name   = module.network.name
    bridge = module.network.bridge
  }
}

output "storage_info" {
  description = "Storage information"
  value = {
    pool_id   = module.storage.pool_id
    pool_name = module.storage.pool_name
  }
}

output "vm_info" {
  description = "VM information"
  value = {
    ids   = module.compute.vm_ids
    names = module.compute.vm_names
  }
}

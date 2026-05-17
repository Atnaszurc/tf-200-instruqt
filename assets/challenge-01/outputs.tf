# Example outputs
# Rename to outputs.tf to use

output "network_info" {
  description = "Network information"
  value = {
    id     = module.app_network.id
    name   = module.app_network.name
    bridge = module.app_network.bridge
  }
}

output "vms" {
  description = "Information about all VMs"
  value = {
    web_server = {
      id   = module.web_server.id
      name = module.web_server.name
    }
    api_server = {
      id   = module.api_server.id
      name = module.api_server.name
    }
    database = {
      id   = module.database.id
      name = module.database.name
    }
  }
}

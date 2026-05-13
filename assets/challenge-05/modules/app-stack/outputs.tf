output "environment" {
  description = "Environment name"
  value       = var.config.environment
}

output "frontend" {
  description = "Frontend tier outputs"
  value = {
    network_id   = module.frontend.network_id
    server_count = module.frontend.server_count
    servers      = module.frontend.server_names
  }
}

output "application" {
  description = "Application tier outputs"
  value = {
    network_id     = module.application.network_id
    server_count   = module.application.total_server_count
    stable_servers = module.application.stable_servers
    canary_servers = module.application.canary_servers
  }
}

output "database" {
  description = "Database tier outputs"
  value = {
    network_id   = module.database.network_id
    server_count = module.database.total_server_count
    primary      = module.database.primary_server
    replicas     = module.database.replica_servers
  }
}

output "stack_summary" {
  description = "Complete stack summary file"
  value       = local_file.stack_summary.filename
}


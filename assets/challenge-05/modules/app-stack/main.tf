# Composes frontend, application, and database tiers

module "frontend" {
  source = "../frontend"

  environment        = var.config.environment
  server_count       = var.config.frontend.server_count
  network_cidr       = var.config.frontend.network_cidr
  monitoring_enabled = var.config.frontend.monitoring_enabled
  base_volume_id     = var.base_volume_id
}

module "application" {
  source = "../application"

  environment         = var.config.environment
  server_count        = var.config.application.server_count
  network_cidr        = var.config.application.network_cidr
  frontend_network_id = module.frontend.network_id
  caching_enabled     = var.config.application.caching_enabled
  canary_enabled      = var.enable_canary
  canary_percentage   = var.canary_percentage
  base_volume_id      = var.base_volume_id

  depends_on = [module.frontend]
}

module "database" {
  source = "../database"

  environment         = var.config.environment
  server_count        = var.config.database.server_count
  network_cidr        = var.config.database.network_cidr
  backup_enabled      = var.config.database.backup_enabled
  replication_enabled = var.config.database.replication_enabled
  base_volume_id      = var.base_volume_id

  depends_on = [module.application]
}

# Stack summary
resource "local_file" "stack_summary" {
  filename = "${path.root}/generated/${var.config.environment}-stack-summary.json"
  content = jsonencode({
    environment = var.config.environment
    created_at  = timestamp()
    tiers = {
      frontend = {
        network      = module.frontend.network_name
        server_count = module.frontend.server_count
        servers      = module.frontend.server_names
      }
      application = {
        server_count   = module.application.total_server_count
        stable_servers = module.application.stable_servers
        canary_servers = module.application.canary_servers
      }
      database = {
        server_count = module.database.total_server_count
        primary      = module.database.primary_server
        replicas     = module.database.replica_servers
      }
    }
  })
}

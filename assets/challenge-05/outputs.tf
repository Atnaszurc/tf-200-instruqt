  }
}

# Deploy complete application stack
module "app_stack" {
  source = "./modules/app-stack"
  
  config = local.config
  
  # Enable canary for staging and prod
  enable_canary     = contains(["staging", "prod"], var.environment)
  canary_percentage = var.environment == "prod" ? 20 : 10
}

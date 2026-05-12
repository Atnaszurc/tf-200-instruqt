# Example root module demonstrating all patterns
# Rename to main.tf to use

terraform {
  required_version = ">= 1.14"
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "~> 0.9"
    }
  }
}

provider "libvirt" {
  uri = "qemu:///system"
}

# Example 1: Nested Module (App Stack)
module "my_app" {
  source = "./modules/app-stack"
  
  app_name    = "webapp"
  environment = "dev"
  
  vms = {
    web = { memory_mb = 512, vcpu_count = 1, disk_gb = 1 }
    api = { memory_mb = 512, vcpu_count = 1, disk_gb = 1 }
    db  = { memory_mb = 1024, vcpu_count = 2, disk_gb = 2 }
  }
}

# Example 2: Conditional Resources
module "dev_app" {
  source = "./modules/conditional-vm"
  
  app_name          = "myapp"
  environment       = "dev"
  create_network    = true
  enable_monitoring = false
  enable_backup     = false
  
  vms = {
    web = { memory_mb = 512, vcpu_count = 1 }
  }
}

# Example 3: Canary Deployment
module "canary_network" {
  source = "./modules/network"
  
  network_name = "canary-network"
  addresses    = ["192.168.220.0/24"]
}

module "app_canary" {
  source = "./modules/canary-deployment"
  
  app_name          = "myapp"
  total_instances   = 5
  enable_canary     = false  # Start with 100% stable
  canary_percentage = 0
  stable_version    = "v1.0.0"
  canary_version    = "v1.1.0"
  network_id        = module.canary_network.id
}
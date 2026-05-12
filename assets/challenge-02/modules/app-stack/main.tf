terraform {
  required_version = ">= 1.14"
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "~> 0.9"
    }
  }
}

# Layer 1: Network
module "network" {
  source = "../network"

  network_name = "${var.app_name}-${var.environment}-network"
  network_mode = "nat"
  addresses    = ["192.168.200.0/24"]
  domain       = "${var.app_name}.${var.environment}.local"
}

# Layer 2: Storage
module "storage" {
  source = "../storage"

  pool_name = "${var.app_name}-${var.environment}-pool"
  pool_type = "dir"
  pool_path = "/var/lib/libvirt/images/${var.app_name}-${var.environment}"

  volumes = {
    for vm_name, vm_config in var.vms :
    vm_name => {
      size_gb = vm_config.disk_gb
      format  = "qcow2"
    }
  }
}

# Layer 3: Compute
module "compute" {
  source = "../compute"

  network_id = module.network.id
  autostart  = var.environment == "prod"

  vms = {
    for vm_name, vm_config in var.vms :
    "${var.app_name}-${var.environment}-${vm_name}" => {
      memory_mb  = vm_config.memory_mb
      vcpu_count = vm_config.vcpu_count
      volume_id  = module.storage.volume_ids[vm_name]
    }
  }

  depends_on = [module.storage]
}

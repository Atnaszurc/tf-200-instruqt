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

# Environment selection
variable "environment" {
  description = "Environment to deploy (dev, staging, prod)"
  type        = string
  default     = "dev"
  
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod"
  }
}

# Parse environment-specific configuration
locals {
  env_config = yamldecode(file("${path.module}/config/environments/${var.environment}.yaml"))
  
  # Extract configuration
  network_cidr = local.env_config.network.cidr
  vm_count     = local.env_config.vms.count
  vm_memory    = local.env_config.vms.memory_mb
  vm_vcpu      = local.env_config.vms.vcpu
  vm_disk_gb   = local.env_config.vms.disk_gb
}

# Validate environment configuration
module "validate_env" {
  source = "./modules/yaml-validator"
  
  config_file   = "${path.module}/config/environments/${var.environment}.yaml"
  required_keys = ["environment", "network", "vms"]
}

# Create environment network
resource "libvirt_network" "env_network" {
  name      = "${var.environment}-network"
  autostart = true
  
  ips = [
    {
      address = split("/", local.network_cidr)[0]
      prefix  = tonumber(split("/", local.network_cidr)[1])
      dhcp = {
        ranges = [{
          start = cidrhost(local.network_cidr, 2)
          end   = cidrhost(local.network_cidr, -2)
        }]
      }
    }
  ]
  
  forward = {
    mode = "nat"
  }
  
  dns = {
    enabled = true
  }
}

# Create storage pool
resource "libvirt_pool" "env_pool" {
  name = "${var.environment}-pool"
  type = "dir"
  
  target = {
    path = "/var/lib/libvirt/images/${var.environment}"
  }
}

# Create VM volumes
resource "libvirt_volume" "vm_volumes" {
  count = local.vm_count
  
  name     = "${var.environment}-vm-${count.index + 1}-disk.qcow2"
  pool     = libvirt_pool.env_pool.name
  capacity = local.vm_disk_gb * 1024 * 1024 * 1024
  
  target = {
    format = {
      type = "qcow2"
    }
  }
}

# Create VMs
resource "libvirt_domain" "vms" {
  count = local.vm_count
  
  name   = "${var.environment}-vm-${count.index + 1}"
  type   = "kvm"
  memory = local.vm_memory
  vcpu   = local.vm_vcpu
  
  devices = {
    disks = [
      {
        volume_id = libvirt_volume.vm_volumes[count.index].id
      }
    ]
    
    network_interfaces = [
      {
        network_id     = libvirt_network.env_network.id
        wait_for_lease = true
      }
    ]
    
    consoles = [
      {
        type        = "pty"
        target_port = 0
      }
    ]
  }
}

# Output environment details
output "environment_info" {
  description = "Environment deployment details"
  value = {
    environment = var.environment
    network = {
      name = libvirt_network.env_network.name
      cidr = local.network_cidr
    }
    vms = {
      count  = local.vm_count
      memory = local.vm_memory
      vcpu   = local.vm_vcpu
      disk   = local.vm_disk_gb
      names  = [for vm in libvirt_domain.vms : vm.name]
    }
  }
}
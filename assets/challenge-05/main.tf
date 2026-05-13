terraform {
  required_version = ">= 1.5.0"
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "~> 0.9"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.5"
    }
  }
}

provider "libvirt" {
  uri = "qemu:///system"
}

# Parse YAML configuration
locals {
  config = yamldecode(file("${path.module}/config/${var.environment}.yaml"))
}

# Import legacy resources
import {
  to = libvirt_network.legacy
  id = "legacy-app-network"
}

import {
  to = libvirt_domain.legacy
  id = "legacy-app-server"
}

# Legacy resources (imported)
resource "libvirt_network" "legacy" {
  name      = "legacy-app-network"
  autostart = true
  
  ips = [{
    address = "10.100.0.1"
    prefix  = 24
    dhcp = {
      ranges = [{
        start = "10.100.0.2"
        end   = "10.100.0.254"
      }]
    }
  }]
  
  forward = {
    mode = "nat"
  }
  
  dns = {
    enabled = true
  }
}

resource "libvirt_domain" "legacy" {
  name   = "legacy-app-server"
  memory = 512
  vcpu   = 1
  type   = "kvm"
  
  devices = {
    network_interfaces = [{
      network_id = libvirt_network.legacy.id
    }]
    
    disks = [{
      file = "/var/lib/libvirt/images/legacy/legacy-app-server.qcow2"
    }]
    
    consoles = [{
      type        = "pty"
      target_type = "serial"
      target_port = 0
    }]
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
EOF

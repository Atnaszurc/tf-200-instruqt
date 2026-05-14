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
  to = libvirt_domain.legacy
  id = "legacy-app-server"
}

# Legacy domain (imported) - network is left unmanaged to avoid provider bug
resource "libvirt_domain" "legacy" {
  name   = "legacy-app-server"
  memory = 512
  vcpu   = 1
  type   = "kvm"

  os = {
    type = "hvm"
  }

  devices = {
    network_interfaces = [{
      network_id = var.legacy_network_uuid
    }]

    disks = [{
      source = {
        file = "/var/lib/libvirt/images/legacy/legacy-app-server.qcow2"
      }
      target = {
        dev = "vda"
        bus = "virtio"
      }
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

terraform {
  required_version = ">= 1.7.0"
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

# Complete Migration Scenario
# Demonstrates end-to-end migration workflow

# Step 1: Import existing legacy networks
import {
  to = libvirt_network.production
  id = "legacy-net-1"
}

import {
  to = libvirt_network.staging
  id = "legacy-net-2"
}

import {
  to = libvirt_network.handoff
  id = "legacy-net-3"
}

# Step 2: Define resources with better names
resource "libvirt_network" "production" {
  name      = "legacy-net-1"
  autostart = true

  ips = [{
    address = "10.50.0.1"
    prefix  = 24
    dhcp = {
      ranges = [{
        start = "10.50.0.2"
        end   = "10.50.0.254"
      }]
    }
  }]

  forward = {
    mode = "nat"
  }
}

resource "libvirt_network" "staging" {
  name      = "legacy-net-2"
  autostart = true

  ips = [{
    address = "10.51.0.1"
    prefix  = 24
    dhcp = {
      ranges = [{
        start = "10.51.0.2"
        end   = "10.51.0.254"
      }]
    }
  }]

  forward = {
    mode = "nat"
  }
}

resource "libvirt_network" "handoff" {
  name      = "legacy-net-3"
  autostart = true

  ips = [{
    address = "10.52.0.1"
    prefix  = 24
    dhcp = {
      ranges = [{
        start = "10.52.0.2"
        end   = "10.52.0.254"
      }]
    }
  }]

  forward = {
    mode = "nat"
  }
}

# Step 3: After import, hand off legacy-net-3 to network team
# (Uncomment removed block after initial import is complete)
#
# removed {
#   from = libvirt_network.handoff
#   
#   lifecycle {
#     destroy = false
#   }
# }

# Output migration status
output "migration_status" {
  description = "Migration progress and resource status"
  value = {
    imported = {
      production = {
        id   = libvirt_network.production.id
        cidr = "${libvirt_network.production.ips[0].address}/${libvirt_network.production.ips[0].prefix}"
      }
      staging = {
        id   = libvirt_network.staging.id
        cidr = "${libvirt_network.staging.ips[0].address}/${libvirt_network.staging.ips[0].prefix}"
      }
    }
    # handoff will be removed after applying removed block
    pending_handoff = {
      network = "legacy-net-3"
      target  = "Network Team"
      status  = "Managed by Terraform (pending handoff)"
    }
  }
}

# Migration workflow:
# 1. terraform init
# 2. terraform plan -generate-config-out=generated.tf
# 3. Review generated.tf and update resource definitions
# 4. terraform apply (imports resources)
# 5. Uncomment removed block for handoff
# 6. terraform apply (removes handoff from state)
# 7. Verify legacy-net-3 still running: virsh net-list
# 8. Remove import and removed blocks (cleanup)

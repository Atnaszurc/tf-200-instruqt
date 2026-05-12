terraform {
  required_version = ">= 1.5.0"
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

# Bulk Import with for_each
# Import multiple resources efficiently

locals {
  networks = {
    "tier1" = { name = "tier1-network", cidr = "10.10.0.0/24" }
    "tier2" = { name = "tier2-network", cidr = "10.20.0.0/24" }
    "tier3" = { name = "tier3-network", cidr = "10.30.0.0/24" }
  }
}

# Bulk import blocks
import {
  for_each = local.networks
  to       = libvirt_network.tiers[each.key]
  id       = each.value.name
}

# Resource definitions for all tiers
resource "libvirt_network" "tiers" {
  for_each = local.networks

  name      = each.value.name
  mode      = "nat"
  addresses = [each.value.cidr]
  autostart = true

  dns {
    enabled = true
  }

  dhcp {
    enabled = true
  }
}

# Output all imported tier networks
output "tier_networks" {
  description = "All tier network details"
  value = {
    for key, net in libvirt_network.tiers :
    key => {
      id   = net.id
      name = net.name
      cidr = net.addresses[0]
    }
  }
}

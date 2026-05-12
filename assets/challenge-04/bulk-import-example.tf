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
  for_each  = local.networks
  name      = each.value.name
  autostart = true

  ips = [{
    address = split("/", each.value.cidr)[0]
    prefix  = tonumber(split("/", each.value.cidr)[1])
    dhcp = {
      ranges = [{
        start = cidrhost(each.value.cidr, 2)
        end   = cidrhost(each.value.cidr, -2)
      }]
    }
  }]

  forward = {
    mode = "nat"
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
      cidr = "${net.ips[0].address}/${net.ips[0].prefix}"
    }
  }
}

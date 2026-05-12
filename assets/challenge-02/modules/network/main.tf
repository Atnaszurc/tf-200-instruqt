terraform {
  required_version = ">= 1.14"
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "~> 0.9"
    }
  }
}

resource "libvirt_network" "network" {
  name      = var.network_name
  autostart = true

  # IP configuration - using list of objects with = syntax
  ips = [
    for addr in var.addresses : {
      address = split("/", addr)[0]
      prefix  = tonumber(split("/", addr)[1])
      dhcp = var.dhcp_enabled ? {
        ranges = [{
          start = cidrhost(addr, 2)
          end   = cidrhost(addr, -2)
        }]
      } : null
    }
  ]

  # Network forwarding mode - nested attribute
  forward = {
    mode = var.network_mode
  }

  # DNS domain configuration - nested attribute
  domain = {
    name = var.domain
  }
}

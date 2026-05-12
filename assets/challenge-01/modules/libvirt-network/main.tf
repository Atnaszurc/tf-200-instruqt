# modules/libvirt-network/main.tf

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
  name      = var.name
  autostart = var.autostart

  # IP configuration from variable
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

  # Network forwarding mode
  forward = {
    mode = var.mode
  }

  # DNS domain configuration
  domain = {
    name = var.domain
  }
}

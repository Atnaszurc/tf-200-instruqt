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
  mode      = var.mode
  domain    = var.domain
  addresses = var.addresses
  autostart = var.autostart

  # DHCP configuration
  dynamic "dhcp" {
    for_each = var.dhcp_enabled ? [1] : []
    content {
      enabled = true
    }
  }
}

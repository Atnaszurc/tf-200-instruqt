terraform {
  required_version = ">= 1.14"
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "~> 0.9"
    }
  }
}

resource "libvirt_network" "this" {
  name      = var.network_name
  mode      = var.network_mode
  domain    = var.domain
  addresses = var.addresses
  autostart = true

  dhcp {
    enabled = true
  }
}

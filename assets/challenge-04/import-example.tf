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

# Modern Import Blocks (Terraform 1.5+)
# Import blocks are declarative and version-controlled

import {
  to = libvirt_network.legacy
  id = "legacy-network"
}

import {
  to = libvirt_network.app
  id = "app-network"
}

import {
  to = libvirt_network.db
  id = "db-network"
}

# Resource definitions for imported networks
resource "libvirt_network" "legacy" {
  name      = "legacy-network"
  mode      = "nat"
  addresses = ["10.100.0.0/24"]
  autostart = true

  dns {
    enabled = true
  }

  dhcp {
    enabled = true
  }
}

resource "libvirt_network" "app" {
  name      = "app-network"
  mode      = "nat"
  addresses = ["10.101.0.0/24"]
  autostart = true

  dns {
    enabled = true
  }

  dhcp {
    enabled = true
  }
}

resource "libvirt_network" "db" {
  name      = "db-network"
  mode      = "nat"
  addresses = ["10.102.0.0/24"]
  autostart = true

  dns {
    enabled = true
  }

  dhcp {
    enabled = true
  }
}

# Output imported network information
output "imported_networks" {
  description = "Imported network details"
  value = {
    legacy = {
      id   = libvirt_network.legacy.id
      cidr = libvirt_network.legacy.addresses[0]
    }
    app = {
      id   = libvirt_network.app.id
      cidr = libvirt_network.app.addresses[0]
    }
    db = {
      id   = libvirt_network.db.id
      cidr = libvirt_network.db.addresses[0]
    }
  }
}

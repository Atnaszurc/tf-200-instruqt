terraform {
  required_version = ">= 1.1.0"
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

# moved Blocks for Safe Refactoring (Terraform 1.1+)
# Rename resources without destroying infrastructure

moved {
  from = libvirt_network.legacy
  to   = libvirt_network.production
}

moved {
  from = libvirt_network.app
  to   = libvirt_network.application
}

moved {
  from = libvirt_network.db
  to   = libvirt_network.database
}

# Resources with improved names
resource "libvirt_network" "production" {
  name      = "legacy-network" # Actual network name unchanged
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

resource "libvirt_network" "application" {
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

resource "libvirt_network" "database" {
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

# Output refactored network information
output "refactored_networks" {
  description = "Refactored network details"
  value = {
    production = {
      id   = libvirt_network.production.id
      cidr = libvirt_network.production.addresses[0]
    }
    application = {
      id   = libvirt_network.application.id
      cidr = libvirt_network.application.addresses[0]
    }
    database = {
      id   = libvirt_network.database.id
      cidr = libvirt_network.database.addresses[0]
    }
  }
}

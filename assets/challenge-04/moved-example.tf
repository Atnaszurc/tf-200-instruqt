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
  autostart = true

  ips = [{
    address = "10.100.0.1"
    prefix  = 24
    dhcp = {
      ranges = [{
        start = "10.100.0.2"
        end   = "10.100.0.254"
      }]
    }
  }]

  forward = {
    mode = "nat"
  }
}

resource "libvirt_network" "application" {
  name      = "app-network"
  autostart = true

  ips = [{
    address = "10.101.0.1"
    prefix  = 24
    dhcp = {
      ranges = [{
        start = "10.101.0.2"
        end   = "10.101.0.254"
      }]
    }
  }]

  forward = {
    mode = "nat"
  }
}

resource "libvirt_network" "database" {
  name      = "db-network"
  autostart = true

  ips = [{
    address = "10.102.0.1"
    prefix  = 24
    dhcp = {
      ranges = [{
        start = "10.102.0.2"
        end   = "10.102.0.254"
      }]
    }
  }]

  forward = {
    mode = "nat"
  }
}

# Output refactored network information
output "refactored_networks" {
  description = "Refactored network details"
  value = {
    production = {
      id   = libvirt_network.production.id
      cidr = "${libvirt_network.production.ips[0].address}/${libvirt_network.production.ips[0].prefix}"
    }
    application = {
      id   = libvirt_network.application.id
      cidr = "${libvirt_network.application.ips[0].address}/${libvirt_network.application.ips[0].prefix}"
    }
    database = {
      id   = libvirt_network.database.id
      cidr = "${libvirt_network.database.ips[0].address}/${libvirt_network.database.ips[0].prefix}"
    }
  }
}

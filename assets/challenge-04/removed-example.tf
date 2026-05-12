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

# removed Blocks for Resource Handoff (Terraform 1.7+)
# Remove from state but keep resource running

removed {
  from = libvirt_network.database

  lifecycle {
    destroy = false # Keep the network running
  }
}

# Continue managing these networks
resource "libvirt_network" "production" {
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

# database network removed from state but still running
# Now managed by DBA team

# Output remaining managed networks
output "managed_networks" {
  description = "Networks still under Terraform management"
  value = {
    production = {
      id   = libvirt_network.production.id
      cidr = libvirt_network.production.addresses[0]
    }
    application = {
      id   = libvirt_network.application.id
      cidr = libvirt_network.application.addresses[0]
    }
  }
}

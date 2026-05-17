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
  autostart = true

  ips = [{
    address = "10.100.0.1"
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

# database network removed from state but still running
# Now managed by DBA team

# Output remaining managed networks
output "managed_networks" {
  description = "Networks still under Terraform management"
  value = {
    production = {
      id   = libvirt_network.production.id
      cidr = "${libvirt_network.production.ips[0].address}/${libvirt_network.production.ips[0]}"
    }
    application = {
      id   = libvirt_network.application.id
      cidr = "${libvirt_network.application.ips[0].address}/${libvirt_network.application.ips[0]}"
    }
  }
}

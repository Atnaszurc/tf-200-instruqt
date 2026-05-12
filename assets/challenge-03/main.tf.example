terraform {
  required_version = ">= 1.14"
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

# Parse YAML configuration
locals {
  network_config = yamldecode(file("${path.module}/config/networks.yaml"))
  
  # Transform to map for for_each
  networks = {
    for net in local.network_config.networks :
    net.name => net
  }
}

# Create networks from YAML
resource "libvirt_network" "networks" {
  for_each = local.networks
  
  name      = each.value.name
  autostart = true
  
  ips = [
    {
      address = split("/", each.value.cidr)[0]
      prefix  = tonumber(split("/", each.value.cidr)[1])
      dhcp = {
        ranges = [{
          start = cidrhost(each.value.cidr, 2)
          end   = cidrhost(each.value.cidr, -2)
        }]
      }
    }
  ]
  
  forward = {
    mode = each.value.mode
  }
}

# Output network information
output "networks" {
  description = "Created networks"
  value = {
    for name, net in libvirt_network.networks :
    name => {
      id   = net.id
      cidr = "${net.ips[0].address}/${net.ips[0].prefix}"
    }
  }
}
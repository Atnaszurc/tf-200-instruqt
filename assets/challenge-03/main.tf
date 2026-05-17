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

# Validate configuration before use
module "config_validator" {
  source = "./modules/yaml-validator"

  config_file = "${path.module}/config/infrastructure.yaml"
  required_keys = [
    "infrastructure",
    "environment"
  ]
}

# Use validated configuration
locals {
  validated_config       = module.config_validator.config
  infra_config_validated = local.validated_config.infrastructure
  env_config             = local.validated_config.environment
}

# Custom validation rules

# Validate network CIDRs don't overlap
locals {
  network_cidrs = [
    for name, net in local.infra_networks :
    net.cidr
  ]

  # Check for duplicate CIDRs
  unique_cidrs   = toset(local.network_cidrs)
  has_duplicates = length(local.network_cidrs) != length(local.unique_cidrs)
}

resource "terraform_data" "validate_networks" {
  lifecycle {
    precondition {
      condition     = !local.has_duplicates
      error_message = "Network CIDRs must be unique"
    }
  }
}

# Validate VM memory is reasonable
locals {
  vm_memory_checks = {
    for name, vm in local.infra_vms :
    name => vm.memory_mb >= 512 && vm.memory_mb <= 16384
  }

  invalid_memory_vms = [
    for name, valid in local.vm_memory_checks :
    name if !valid
  ]
}

resource "terraform_data" "validate_vm_memory" {
  lifecycle {
    precondition {
      condition     = length(local.invalid_memory_vms) == 0
      error_message = "VMs with invalid memory: ${join(", ", local.invalid_memory_vms)}"
    }
  }
}

# Validate VM references valid networks
locals {
  vm_network_checks = {
    for name, vm in local.infra_vms :
    name => contains(keys(local.infra_networks), vm.network)
  }

  invalid_network_vms = [
    for name, valid in local.vm_network_checks :
    name if !valid
  ]
}

resource "terraform_data" "validate_vm_networks" {
  lifecycle {
    precondition {
      condition     = length(local.invalid_network_vms) == 0
      error_message = "VMs reference invalid networks: ${join(", ", local.invalid_network_vms)}"
    }
  }
}

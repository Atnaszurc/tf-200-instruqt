locals {
  infra_config = yamldecode(file("${path.module}/config/infrastructure.yaml"))

  # Extract sections
  infra_networks = local.infra_config.infrastructure.networks
  infra_pools    = local.infra_config.infrastructure.storage.pools
  infra_vms      = local.infra_config.infrastructure.vms
  infra_env      = local.infra_config.environment
}

# Create networks
resource "libvirt_network" "infra_networks" {
  for_each = local.infra_networks

  name      = "${local.infra_env.name}-${each.key}-network"
  autostart = true

  forward = {
    mode = each.value.mode
  }

  domain = {
    name = each.value.domain
  }

  ips = [
    {
      address = cidrhost(each.value.cidr, 1)
      prefix  = split("/", each.value.cidr)[1]
      dhcp = {
        enabled = true
      }
    }
  ]
}

# Create storage pools
resource "libvirt_pool" "infra_pools" {
  for_each = local.infra_pools

  name = "${local.infra_env.name}-${each.key}-pool"
  type = each.value.type

  target = {
    path = each.value.path
  }
}

# Create VM volumes
resource "libvirt_volume" "infra_vm_disks" {
  for_each = local.infra_vms

  name = "${local.infra_env.name}-${each.key}.qcow2"
  pool = libvirt_pool.infra_pools[each.value.pool].name

  target = {
    format = {
      type = "qcow2"
    }
  }

  capacity = each.value.disk_gb * 1073741824 # Convert GB to bytes
}

# Create VMs
resource "libvirt_domain" "infra_vms" {
  for_each = local.infra_vms

  name      = "${local.infra_env.name}-${each.key}"
  memory    = each.value.memory_mb
  vcpu      = each.value.vcpu
  autostart = each.value.autostart
  type      = "kvm"
  os = {
    type = "hvm"
  }

  devices = {
    disks = [
      {
        source = {
          volume = {
            pool   = each.value.pool
            volume = libvirt_volume.infra_vm_disks[each.key].name
          }
        }
        target = {
          dev = "vda"
          bus = "virtio"
        }
      }
    ]

    interfaces = [
      {
        network = {
          network = libvirt_network.infra_networks[each.value.network].name
        }
        model = {
          type = "virtio"
        }
        wait_for_lease = true
      }
    ]

    console = [
      {
        type = "pty"
        target = {
          type = "serial"
          port = 0
        }
      }
    ]
  }
}

# Create metadata file with tags
resource "local_file" "infra_vm_metadata" {
  for_each = local.infra_vms

  filename = "/tmp/${local.infra_env.name}-${each.key}-metadata.json"
  content = jsonencode({
    vm_name     = each.key
    environment = local.infra_env.name
    network     = each.value.network
    pool        = each.value.pool
    tags        = each.value.tags
    owner       = local.infra_env.owner
    cost_center = local.infra_env.cost_center
  })
}
output "infrastructure_summary" {
  description = "Complete infrastructure summary"
  value = {
    environment = local.infra_env.name
    networks    = length(libvirt_network.infra_networks)
    pools       = length(libvirt_pool.infra_pools)
    vms         = length(libvirt_domain.infra_vms)
  }
}

output "network_details" {
  description = "Network details"
  value = {
    for name, net in libvirt_network.infra_networks :
    name => {
      id     = net.id
      bridge = net.bridge
    }
  }
}

output "vm_details" {
  description = "VM details"
  value = {
    for name, vm in libvirt_domain.infra_vms :
    name => {
      id      = vm.id
      memory  = vm.memory
      vcpu    = vm.vcpu
      network = local.infra_vms[name].network
      tags    = local.infra_vms[name].tags
    }
  }
}

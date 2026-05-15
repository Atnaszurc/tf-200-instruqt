# Manages application servers, network, and service discovery

terraform {
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "~> 0.9"
    }
  }
}

resource "libvirt_network" "application" {
  name      = "${var.environment}-application-network"
  autostart = true

  ips = [{
    address = split("/", var.network_cidr)[0]
    prefix  = tonumber(split("/", var.network_cidr)[1])
    dhcp = {
      ranges = [{
        start = cidrhost(var.network_cidr, 2)
        end   = cidrhost(var.network_cidr, -2)
      }]
    }
  }]

  forward = {
    mode = "nat"
  }

  dns = {
    enabled = true
  }
}

# Calculate canary and stable server counts
locals {
  canary_count = var.canary_enabled ? ceil(var.server_count * var.canary_percentage / 100) : 0
  stable_count = var.server_count - local.canary_count
}

# Stable servers
resource "libvirt_volume" "application_stable" {
  count = local.stable_count

  name     = "${var.environment}-app-stable-${count.index + 1}.qcow2"
  pool     = "default"
  capacity = 2147483648 # 2GB

  target = {
    format = {
      type = "qcow2"
    }
  }
}

resource "libvirt_domain" "application_stable" {
  count = local.stable_count

  name   = "${var.environment}-app-stable-${count.index + 1}"
  type   = "kvm"
  memory = 1024
  vcpu   = 2

  os = {
    type = "hvm"
  }

  devices = {
    disks = [{
      source = {
        volume = {
          pool   = "default"
          volume = libvirt_volume.application_stable[count.index].name
        }
      }
      target = {
        dev = "vda"
        bus = "virtio"
      }
    }]

    network_interfaces = [{
      network_id     = libvirt_network.application.id
      wait_for_lease = false
    }]

    consoles = [{
      type        = "pty"
      target_type = "serial"
      target_port = 0
    }]
  }
}

# Canary servers (conditional)
resource "libvirt_volume" "application_canary" {
  count = local.canary_count

  name     = "${var.environment}-app-canary-${count.index + 1}.qcow2"
  pool     = "default"
  capacity = 2147483648 # 2GB

  target = {
    format = {
      type = "qcow2"
    }
  }

  backing_store = {
    path = var.base_volume_id
    format = {
      type = "qcow2"
    }
  }
}

resource "libvirt_domain" "application_canary" {
  count = local.canary_count

  name   = "${var.environment}-app-canary-${count.index + 1}"
  type   = "kvm"
  memory = 1024
  vcpu   = 2

  os = {
    type = "hvm"
  }

  devices = {
    disks = [{
      source = {
        volume = {
          pool   = "default"
          volume = libvirt_volume.application_canary[count.index].id
        }
      }
      target = {
        dev = "vda"
        bus = "virtio"
      }
    }]

    network_interfaces = [{
      network_id     = libvirt_network.application.id
      wait_for_lease = false
    }]

    consoles = [{
      type        = "pty"
      target_type = "serial"
      target_port = 0
    }]
  }
}

# Service discovery configuration
resource "local_file" "service_discovery" {
  filename = "${path.root}/generated/${var.environment}-service-discovery.json"
  content = jsonencode({
    environment = var.environment
    services = {
      stable = {
        version = "stable"
        servers = libvirt_domain.application_stable[*].name
        weight  = 100 - var.canary_percentage
      }
      canary = var.canary_enabled ? {
        version = "canary"
        servers = libvirt_domain.application_canary[*].name
        weight  = var.canary_percentage
      } : null
    }
    frontend_network = var.frontend_network_id
  })
}

# Caching configuration (conditional)
resource "local_file" "cache_config" {
  count = var.caching_enabled ? 1 : 0

  filename = "${path.root}/generated/${var.environment}-cache-config.json"
  content = jsonencode({
    environment = var.environment
    cache_type  = "redis"
    ttl_seconds = 3600
    max_memory  = "256mb"
  })
}

# Manages database servers, network, and backup infrastructure

terraform {
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "~> 0.9"
    }
  }
}

resource "libvirt_network" "database" {
  name      = "${var.environment}-database-network"
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

# Backup storage pool (conditional)
resource "libvirt_pool" "backup" {
  count = var.backup_enabled ? 1 : 0

  name = "${var.environment}-backup-pool"
  type = "dir"
  target = {
    path = "/var/lib/libvirt/images/${var.environment}-backups"
  }
}

# Primary database server
resource "libvirt_volume" "database_primary" {
  name     = "${var.environment}-db-primary.qcow2"
  pool     = "default"
  capacity = 5368709120 # 5GB

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

resource "libvirt_domain" "database_primary" {
  name   = "${var.environment}-db-primary"
  type   = "kvm"
  memory = 2048
  vcpu   = 2

  os = {
    type = "hvm"
  }

  devices = {
    disks = [{
      source = {
        volume = {
          pool   = "default"
          volume = libvirt_volume.database_primary.name
        }
      }
      target = {
        dev = "vda"
        bus = "virtio"
      }
    }]

    network_interfaces = [{
      network_id     = libvirt_network.database.id
      wait_for_lease = false
    }]

    consoles = [{
      type        = "pty"
      target_type = "serial"
      target_port = 0
    }]
  }
}

# Replica database server (conditional)
resource "libvirt_volume" "database_replica" {
  count = var.replication_enabled ? var.server_count - 1 : 0

  name     = "${var.environment}-db-replica-${count.index + 1}.qcow2"
  pool     = "default"
  capacity = 5368709120 # 5GB

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

resource "libvirt_domain" "database_replica" {
  count = var.replication_enabled ? var.server_count - 1 : 0

  name   = "${var.environment}-db-replica-${count.index + 1}"
  type   = "kvm"
  memory = 2048
  vcpu   = 2

  os = {
    type = "hvm"
  }

  devices = {
    disks = [{
      source = {
        volume = {
          pool   = "default"
          volume = libvirt_volume.database_replica[count.index].id
        }
      }
      target = {
        dev = "vda"
        bus = "virtio"
      }
    }]

    network_interfaces = [{
      network_id     = libvirt_network.database.id
      wait_for_lease = false
    }]

    consoles = [{
      type        = "pty"
      target_type = "serial"
      target_port = 0
    }]
  }
}

# Backup configuration
resource "local_file" "backup_config" {
  count = var.backup_enabled ? 1 : 0

  filename = "${path.root}/generated/${var.environment}-backup-config.json"
  content = jsonencode({
    environment     = var.environment
    backup_enabled  = true
    backup_schedule = "0 2 * * *" # 2 AM daily
    retention_days  = var.environment == "prod" ? 30 : 7
    backup_pool     = libvirt_pool.backup[0].name
    primary_server  = libvirt_domain.database_primary.name
  })
}

# Replication configuration
resource "local_file" "replication_config" {
  count = var.replication_enabled ? 1 : 0

  filename = "${path.root}/generated/${var.environment}-replication-config.json"
  content = jsonencode({
    environment = var.environment
    primary     = libvirt_domain.database_primary.name
    replicas    = libvirt_domain.database_replica[*].name
    sync_mode   = var.environment == "prod" ? "synchronous" : "asynchronous"
  })
}

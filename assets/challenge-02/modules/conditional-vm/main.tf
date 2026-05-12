terraform {
  required_version = ">= 1.14"
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "~> 0.9"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.7"
    }
  }
}

locals {
  # Use created or existing network
  network_id = var.create_network ? libvirt_network.this[0].id : var.existing_network_id

  # Auto-start only in production
  autostart = var.environment == "prod"

  # Monitoring enabled in staging and prod
  monitoring_enabled = var.enable_monitoring && contains(["staging", "prod"], var.environment)

  # Backup enabled only in prod
  backup_enabled = var.enable_backup && var.environment == "prod"
}

# Conditional network creation
resource "libvirt_network" "this" {
  count = var.create_network ? 1 : 0

  name      = "${var.app_name}-${var.environment}-network"
  mode      = "nat"
  addresses = ["192.168.210.0/24"]
  autostart = true

  dhcp {
    enabled = true
  }
}

# Create volumes for VMs
resource "libvirt_volume" "vm_disks" {
  for_each = var.vms

  name   = "${var.app_name}-${var.environment}-${each.key}.qcow2"
  pool   = "default"
  format = "qcow2"
  size   = 1073741824 # 1GB
}

# Create VMs
resource "libvirt_domain" "vms" {
  for_each = var.vms

  name      = "${var.app_name}-${var.environment}-${each.key}"
  memory    = each.value.memory_mb
  vcpu      = each.value.vcpu_count
  autostart = local.autostart

  os {
    type    = "hvm"
    arch    = "x86_64"
    machine = "pc"
  }

  disk {
    volume_id = libvirt_volume.vm_disks[each.key].id
  }

  network_interface {
    network_id = local.network_id
  }

  console {
    type        = "pty"
    target_type = "serial"
    target_port = "0"
  }
}

# Conditional monitoring configuration
resource "local_file" "monitoring_config" {
  count = local.monitoring_enabled ? 1 : 0

  filename = "/tmp/${var.app_name}-${var.environment}-monitoring.conf"
  content  = <<-EOT
    # Monitoring Configuration
    # Environment: ${var.environment}
    # VMs: ${join(", ", keys(var.vms))}
    
    monitoring_enabled = true
    check_interval     = ${var.environment == "prod" ? "30s" : "60s"}
    alert_threshold    = ${var.environment == "prod" ? "90" : "95"}
  EOT
}

# Conditional backup configuration
resource "local_file" "backup_config" {
  count = local.backup_enabled ? 1 : 0

  filename = "/tmp/${var.app_name}-${var.environment}-backup.conf"
  content  = <<-EOT
    # Backup Configuration
    # Environment: ${var.environment}
    
    backup_enabled  = true
    backup_schedule = "0 2 * * *"  # Daily at 2 AM
    retention_days  = 30
    vms_to_backup   = [${join(", ", [for k, v in var.vms : "\"${k}\""])}]
  EOT
}

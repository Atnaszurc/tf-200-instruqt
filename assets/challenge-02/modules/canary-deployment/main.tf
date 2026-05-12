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
  # Calculate instance counts
  stable_count = var.enable_canary ? 
    floor(var.total_instances * (1 - var.canary_percentage / 100)) : 
    var.total_instances
  
  canary_count = var.enable_canary ? 
    ceil(var.total_instances * (var.canary_percentage / 100)) : 
    0
}

# Stable version volumes
resource "libvirt_volume" "stable" {
  count = local.stable_count
  
  name   = "${var.app_name}-stable-${count.index + 1}.qcow2"
  pool   = "default"
  format = "qcow2"
  size   = 1073741824  # 1GB
}

# Canary version volumes
resource "libvirt_volume" "canary" {
  count = local.canary_count
  
  name   = "${var.app_name}-canary-${count.index + 1}.qcow2"
  pool   = "default"
  format = "qcow2"
  size   = 1073741824  # 1GB
}

# Stable version instances
resource "libvirt_domain" "stable" {
  count = local.stable_count
  
  name      = "${var.app_name}-stable-${count.index + 1}"
  memory    = var.memory_mb
  vcpu      = var.vcpu_count
  autostart = false
  
  os {
    type     = "hvm"
    arch     = "x86_64"
    machine  = "pc"
  }
  
  disk {
    volume_id = libvirt_volume.stable[count.index].id
  }
  
  network_interface {
    network_id = var.network_id
  }
  
  console {
    type        = "pty"
    target_type = "serial"
    target_port = "0"
  }
}

# Canary version instances
resource "libvirt_domain" "canary" {
  count = local.canary_count
  
  name      = "${var.app_name}-canary-${count.index + 1}"
  memory    = var.memory_mb
  vcpu      = var.vcpu_count
  autostart = false
  
  os {
    type     = "hvm"
    arch     = "x86_64"
    machine  = "pc"
  }
  
  disk {
    volume_id = libvirt_volume.canary[count.index].id
  }
  
  network_interface {
    network_id = var.network_id
  }
  
  console {
    type        = "pty"
    target_type = "serial"
    target_port = "0"
  }
}

# Deployment status file
resource "local_file" "deployment_status" {
  filename = "/tmp/${var.app_name}-deployment-status.json"
  content = jsonencode({
    app_name          = var.app_name
    total_instances   = var.total_instances
    stable_count      = local.stable_count
    canary_count      = local.canary_count
    stable_version    = var.stable_version
    canary_version    = var.canary_version
    canary_percentage = var.canary_percentage
    canary_enabled    = var.enable_canary
    timestamp         = timestamp()
  })
}
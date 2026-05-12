terraform {
  required_version = ">= 1.14"
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "~> 0.9"
    }
  }
}

resource "libvirt_pool" "this" {
  name = var.pool_name
  type = var.pool_type
  path = var.pool_path
}

resource "libvirt_volume" "volumes" {
  for_each = var.volumes

  name   = "${each.key}.${each.value.format}"
  pool   = libvirt_pool.this.name
  format = each.value.format
  size   = each.value.size_gb * 1073741824 # Convert GB to bytes
}

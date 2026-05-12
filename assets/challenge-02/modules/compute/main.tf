terraform {
  required_version = ">= 1.14"
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "~> 0.9"
    }
  }
}

resource "libvirt_domain" "vms" {
  for_each = var.vms

  name      = each.key
  memory    = each.value.memory_mb
  vcpu      = each.value.vcpu_count
  autostart = var.autostart

  os {
    type    = "hvm"
    arch    = "x86_64"
    machine = "pc"
  }

  disk {
    volume_id = each.value.volume_id
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

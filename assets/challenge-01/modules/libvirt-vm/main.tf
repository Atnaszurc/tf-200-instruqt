# modules/libvirt-vm/main.tf

terraform {
  required_version = ">= 1.14"
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "~> 0.9"
    }
  }
}

# Create a simple disk
resource "libvirt_volume" "vm_disk" {
  name   = "${var.name}-disk.qcow2"
  pool   = "default"
  format = "qcow2"
  size   = 1073741824 # 1GB
}

# Create the VM
resource "libvirt_domain" "vm" {
  name      = var.name
  memory    = var.memory
  vcpu      = var.vcpu
  autostart = var.autostart

  os {
    type    = "hvm"
    arch    = "x86_64"
    machine = "pc"
  }

  disk {
    volume_id = libvirt_volume.vm_disk.id
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

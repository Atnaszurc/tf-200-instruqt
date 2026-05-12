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
  name     = "${var.name}-disk.qcow2"
  pool     = "default"
  capacity = 1073741824 # 1GB

  target = {
    format = {
      type = "qcow2"
    }
  }
}

# Create the VM
resource "libvirt_domain" "vm" {
  name      = var.name
  type      = "kvm"
  memory    = var.memory
  vcpu      = var.vcpu
  autostart = var.autostart

  os = {
    type    = "hvm"
    arch    = "x86_64"
    machine = "pc"
  }

  devices = {
    disks = [{
      volume_id = libvirt_volume.vm_disk.id
    }]

    interfaces = [{
      network_id = var.network_id
    }]

    consoles = [{
      type        = "pty"
      target_type = "serial"
      target_port = "0"
    }]
  }
}

# Frontend Module - Web Tier
# Manages web servers, network, and load balancer configuration

terraform {
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "~> 0.9"
    }
  }
}

resource "libvirt_network" "frontend" {
  name      = "${var.environment}-frontend-network"
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

resource "libvirt_volume" "frontend" {
  count = var.server_count

  name     = "${var.environment}-frontend-${count.index + 1}.qcow2"
  pool     = "default"
  capacity = 1073741824 # 1GB

  target = {
    format = {
      type = "qcow2"
    }
  }
}

resource "libvirt_domain" "frontend" {
  count = var.server_count

  name   = "${var.environment}-frontend-${count.index + 1}"
  type   = "kvm"
  memory = 512
  vcpu   = 1

  devices = {
    disks = [{
      volume_id = libvirt_volume.frontend[count.index].id
    }]

    network_interfaces = [{
      network_id = libvirt_network.frontend.id
    }]

    consoles = [{
      type        = "pty"
      target_type = "serial"
      target_port = 0
    }]
  }
}

# Load balancer configuration (simulated)
resource "local_file" "load_balancer_config" {
  filename = "${path.root}/generated/${var.environment}-lb-config.json"
  content = jsonencode({
    environment = var.environment
    backend_servers = [
      for i, domain in libvirt_domain.frontend : {
        name = domain.name
        # Calculate IP from network_cidr: 192.168.X.0/24 -> 192.168.X.(10+i)
        ip = "${cidrhost(var.network_cidr, 0)}.${10 + i}"
      }
    ]
    health_check_enabled = true
  })
}

# Monitoring configuration (conditional)
resource "local_file" "monitoring_config" {
  count = var.monitoring_enabled ? 1 : 0

  filename = "${path.root}/generated/${var.environment}-frontend-monitoring.json"
  content = jsonencode({
    environment    = var.environment
    tier           = "frontend"
    servers        = libvirt_domain.frontend[*].name
    metrics        = ["cpu", "memory", "network", "requests"]
    alerts_enabled = true
  })
}

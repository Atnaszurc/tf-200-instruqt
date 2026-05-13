    dhcp = {
      ranges = [{
        start = "10.100.0.2"
        end   = "10.100.0.254"
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

resource "libvirt_domain" "legacy" {
  name   = "legacy-app-server"
  memory = 512
  vcpu   = 1
  type   = "kvm"
  
  devices = {
    network_interfaces = [{
      network_id = libvirt_network.legacy.id
    }]
    
    disks = [{
      file = "/var/lib/libvirt/images/legacy/legacy-app-server.qcow2"
    }]
    
    consoles = [{
      type        = "pty"
      target_type = "serial"
      target_port = 0
    }]
  }
}

# Deploy complete application stack
module "app_stack" {
  source = "./modules/app-stack"
  
  config = local.config
  
  # Enable canary for staging and prod
  enable_canary     = contains(["staging", "prod"], var.environment)
  canary_percentage = var.environment == "prod" ? 20 : 10
}

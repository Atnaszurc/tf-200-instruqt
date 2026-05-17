# Example root module - Module Composition
# Rename to main.tf to use

terraform {
  required_version = ">= 1.14"
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "~> 0.9"
    }
  }
}

provider "libvirt" {
  uri = "qemu:///system"
}

# Create a network using our network module
module "app_network" {
  source = "./modules/libvirt-network"
  
  name         = "app-network"
  mode         = "nat"
  domain       = "app.local"
  addresses    = ["192.168.100.0/24"]
  dhcp_enabled = true
  autostart    = true
}

# Create web server VM
module "web_server" {
  source = "./modules/libvirt-vm"
  
  name       = "web-server"
  memory     = 512
  vcpu       = 1
  network_id = module.app_network.id
  autostart  = false
}

# Create API server VM
module "api_server" {
  source = "./modules/libvirt-vm"
  
  name       = "api-server"
  memory     = 512
  vcpu       = 1
  network_id = module.app_network.id
  autostart  = false
}

# Create database VM
module "database" {
  source = "./modules/libvirt-vm"
  
  name       = "database"
  memory     = 1024
  vcpu       = 2
  network_id = module.app_network.id
  autostart  = false
}
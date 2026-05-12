# modules/libvirt-network/variables.tf

variable "name" {
  description = "Name of the network"
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{1,30}[a-z0-9]$", var.name))
    error_message = "name must be 3-32 lowercase alphanumeric characters or hyphens."
  }
}

variable "mode" {
  description = "Network mode (nat, route, bridge)"
  type        = string
  default     = "nat"

  validation {
    condition     = contains(["nat", "route", "bridge"], var.mode)
    error_message = "mode must be nat, route, or bridge."
  }
}

variable "domain" {
  description = "DNS domain for the network"
  type        = string
  default     = "local"
}

variable "addresses" {
  description = "List of IP address ranges for the network"
  type        = list(string)
  default     = ["192.168.100.0/24"]

  validation {
    condition     = length(var.addresses) > 0
    error_message = "At least one address range must be specified."
  }
}

variable "dhcp_enabled" {
  description = "Enable DHCP on the network"
  type        = bool
  default     = true
}

variable "autostart" {
  description = "Start network automatically"
  type        = bool
  default     = true
}

# modules/libvirt-vm/variables.tf

variable "name" {
  description = "Name of the VM"
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{1,30}[a-z0-9]$", var.name))
    error_message = "name must be 3-32 lowercase alphanumeric characters or hyphens."
  }
}

variable "memory" {
  description = "Memory in MB"
  type        = number
  default     = 512

  validation {
    condition     = var.memory >= 256 && var.memory <= 8192
    error_message = "memory must be between 256 and 8192 MB."
  }
}

variable "vcpu" {
  description = "Number of virtual CPUs"
  type        = number
  default     = 1

  validation {
    condition     = var.vcpu >= 1 && var.vcpu <= 4
    error_message = "vcpu must be between 1 and 4."
  }
}

variable "network_id" {
  description = "ID of the network to attach to"
  type        = string
}

variable "autostart" {
  description = "Start VM automatically"
  type        = bool
  default     = false
}

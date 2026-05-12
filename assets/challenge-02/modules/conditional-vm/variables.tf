variable "app_name" {
  description = "Application name"
  type        = string
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
}

variable "create_network" {
  description = "Create a new network (false = use existing)"
  type        = bool
  default     = true
}

variable "existing_network_id" {
  description = "ID of existing network (if create_network = false)"
  type        = string
  default     = ""
}

variable "vms" {
  description = "Map of VMs to create"
  type = map(object({
    memory_mb  = number
    vcpu_count = number
  }))
}

variable "enable_monitoring" {
  description = "Enable monitoring resources"
  type        = bool
  default     = false
}

variable "enable_backup" {
  description = "Enable backup configuration"
  type        = bool
  default     = false
}

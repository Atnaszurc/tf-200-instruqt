variable "app_name" {
  description = "Application name"
  type        = string
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be dev, staging, or prod"
  }
}

variable "vms" {
  description = "Map of VMs to create"
  type = map(object({
    memory_mb  = number
    vcpu_count = number
    disk_gb    = number
  }))
}

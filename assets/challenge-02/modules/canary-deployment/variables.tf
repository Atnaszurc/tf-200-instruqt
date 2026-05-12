variable "app_name" {
  description = "Application name"
  type        = string
}

variable "total_instances" {
  description = "Total number of instances"
  type        = number

  validation {
    condition     = var.total_instances >= 1 && var.total_instances <= 10
    error_message = "total_instances must be between 1 and 10"
  }
}

variable "enable_canary" {
  description = "Enable canary deployment"
  type        = bool
  default     = false
}

variable "canary_percentage" {
  description = "Percentage of instances for canary (0-100)"
  type        = number
  default     = 0

  validation {
    condition     = var.canary_percentage >= 0 && var.canary_percentage <= 100
    error_message = "canary_percentage must be between 0 and 100"
  }
}

variable "stable_version" {
  description = "Stable version identifier"
  type        = string
  default     = "v1.0.0"
}

variable "canary_version" {
  description = "Canary version identifier"
  type        = string
  default     = "v1.1.0"
}

variable "network_id" {
  description = "Network ID for VMs"
  type        = string
}

variable "memory_mb" {
  description = "Memory per instance in MB"
  type        = number
  default     = 512
}

variable "vcpu_count" {
  description = "vCPU count per instance"
  type        = number
  default     = 1
}

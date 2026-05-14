variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

variable "server_count" {
  description = "Total number of application servers"
  type        = number
  default     = 2

  validation {
    condition     = var.server_count >= 1 && var.server_count <= 10
    error_message = "Server count must be between 1 and 10"
  }
}

variable "network_cidr" {
  description = "CIDR block for application network"
  type        = string
}

variable "frontend_network_id" {
  description = "ID of the frontend network (dependency)"
  type        = string
}

variable "caching_enabled" {
  description = "Enable caching layer"
  type        = bool
  default     = false
}

variable "canary_enabled" {
  description = "Enable canary deployment"
  type        = bool
  default     = false
}

variable "canary_percentage" {
  description = "Percentage of traffic for canary deployment"
  type        = number
  default     = 10

  validation {
    condition     = var.canary_percentage >= 0 && var.canary_percentage <= 50
    error_message = "Canary percentage must be between 0 and 50"
  }
}

variable "base_volume_id" {
  description = "ID of the base volume for VM disks"
  type        = string
}

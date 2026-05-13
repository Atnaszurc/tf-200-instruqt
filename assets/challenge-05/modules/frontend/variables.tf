variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

variable "server_count" {
  description = "Number of frontend servers to create"
  type        = number
  default     = 2
  
  validation {
    condition     = var.server_count >= 1 && var.server_count <= 5
    error_message = "Server count must be between 1 and 5"
  }
}

variable "network_cidr" {
  description = "CIDR block for frontend network"
  type        = string
  
  validation {
    condition     = can(cidrhost(var.network_cidr, 0))
    error_message = "Must be a valid CIDR block"
  }
}

variable "monitoring_enabled" {
  description = "Enable monitoring for frontend tier"
  type        = bool
  default     = false
}


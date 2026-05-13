variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

variable "server_count" {
  description = "Number of database servers (1 primary + N-1 replicas)"
  type        = number
  default     = 1
  
  validation {
    condition     = var.server_count >= 1 && var.server_count <= 3
    error_message = "Server count must be between 1 and 3"
  }
}

variable "network_cidr" {
  description = "CIDR block for database network"
  type        = string
}

variable "backup_enabled" {
  description = "Enable backup infrastructure"
  type        = bool
  default     = false
}

variable "replication_enabled" {
  description = "Enable database replication"
  type        = bool
  default     = false
}


variable "config" {
  description = "Complete configuration object from YAML"
  type = object({
    environment = string
    frontend = object({
      server_count       = number
      network_cidr       = string
      monitoring_enabled = bool
    })
    application = object({
      server_count    = number
      network_cidr    = string
      caching_enabled = bool
    })
    database = object({
      server_count        = number
      network_cidr        = string
      backup_enabled      = bool
      replication_enabled = bool
    })
  })
}

variable "enable_canary" {
  description = "Enable canary deployment for application tier"
  type        = bool
  default     = false
}

variable "canary_percentage" {
  description = "Percentage of traffic for canary"
  type        = number
  default     = 10
}

variable "base_volume_id" {
  description = "ID of the base volume for VM disks"
  type        = string
}

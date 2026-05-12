variable "vms" {
  description = "Map of VMs to create"
  type = map(object({
    memory_mb  = number
    vcpu_count = number
    volume_id  = string
  }))
}

variable "network_id" {
  description = "Network ID to attach VMs to"
  type        = string
}

variable "autostart" {
  description = "Auto-start VMs"
  type        = bool
  default     = false
}

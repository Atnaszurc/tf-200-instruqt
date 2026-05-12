variable "pool_name" {
  description = "Name of the storage pool"
  type        = string
}

variable "pool_type" {
  description = "Type of storage pool"
  type        = string
  default     = "dir"
}

variable "pool_path" {
  description = "Path for directory-based pool"
  type        = string
  default     = "/var/lib/libvirt/images"
}

variable "volumes" {
  description = "Map of volumes to create"
  type = map(object({
    size_gb = number
    format  = string
  }))
  default = {}
}

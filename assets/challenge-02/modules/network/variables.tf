variable "network_name" {
  description = "Name of the network"
  type        = string
}

variable "network_mode" {
  description = "Network mode (nat, route, bridge)"
  type        = string
  default     = "nat"
}

variable "addresses" {
  description = "Network address ranges"
  type        = list(string)
  default     = ["192.168.200.0/24"]
}

variable "domain" {
  description = "DNS domain"
  type        = string
  default     = "local"
}

variable "dhcp_enabled" {
  description = "Enable DHCP on the network"
  type        = bool
  default     = true
}

variable "config_file" {
  description = "Path to YAML configuration file"
  type        = string
}

variable "required_keys" {
  description = "Required top-level keys"
  type        = list(string)
  default     = []
}

variable "schema_version" {
  description = "Expected schema version"
  type        = string
  default     = "1.0"
}

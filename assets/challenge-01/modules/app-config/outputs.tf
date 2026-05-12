# modules/app-config/outputs.tf

output "config_dir" {
  description = "Directory containing configuration files"
  value       = local.output_dir
}

output "config_files" {
  description = "Map of configuration file paths"
  value = {
    app_config   = local_file.app_config.filename
    env_override = local_file.env_overrides.filename
    metadata     = local_file.metadata.filename
  }
}

output "tags" {
  description = "All tags applied to resources"
  value       = local.all_tags
}

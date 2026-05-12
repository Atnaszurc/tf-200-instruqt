# App Config Module

Creates application configuration files for different environments.

## Features

- ✅ Environment-specific configuration
- ✅ Validation of inputs
- ✅ Automatic tagging
- ✅ Override support

## Usage

```hcl
module "app_config" {
  source = "./modules/app-config"
  
  app_name    = "my-app"
  environment = "dev"
  port        = 8080
  log_level   = "debug"
  
  tags = {
    Team = "platform"
  }
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| app_name | Application name | string | n/a | yes |
| environment | Environment (dev/staging/prod) | string | n/a | yes |
| port | Application port | number | 8080 | no |
| log_level | Log level | string | "info" | no |
| debug_mode | Enable debug | bool | false | no |
| base_dir | Base directory | string | "/tmp/configs" | no |
| tags | Resource tags | map(string) | {} | no |
| env_overrides | Environment overrides | map(string) | {} | no |

## Outputs

| Name | Description |
|------|-------------|
| config_dir | Configuration directory path |
| config_files | Map of configuration file paths |
| tags | All applied tags |
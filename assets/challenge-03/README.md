# Challenge 3: YAML-Driven Configuration

This challenge demonstrates YAML-driven infrastructure configuration patterns in Terraform.

## Overview

YAML-driven configuration allows you to:
- Separate configuration data from infrastructure code
- Make infrastructure more accessible to non-Terraform users
- Enable configuration-as-data patterns
- Simplify multi-environment deployments

## Directory Structure

```
challenge-03/
├── config/
│   ├── networks.yaml              # Simple network configuration
│   ├── infrastructure.yaml        # Complex nested infrastructure
│   └── environments/
│       ├── dev.yaml              # Development environment
│       ├── staging.yaml          # Staging environment
│       └── prod.yaml             # Production environment
├── modules/
│   └── yaml-validator/           # YAML validation module
│       ├── variables.tf
│       ├── main.tf
│       └── outputs.tf
├── main.tf.example               # Basic YAML parsing
├── infrastructure.tf.example     # Complex YAML structures
└── environments.tf.example       # Multi-environment pattern
```

## Configuration Files

### networks.yaml
Simple list-based configuration for networks:
```yaml
networks:
  - name: "web-network"
    mode: "nat"
    cidr: "10.10.0.0/24"
```

### infrastructure.yaml
Complex nested configuration for complete infrastructure:
```yaml
infrastructure:
  networks:
    web:
      cidr: "192.168.10.0/24"
  storage:
    pools:
      default:
        type: "dir"
  vms:
    web-01:
      memory_mb: 1024
      vcpu: 2
```

### Environment Files
Environment-specific configurations (dev.yaml, staging.yaml, prod.yaml):
```yaml
environment: "dev"
network:
  cidr: "10.100.0.0/24"
vms:
  count: 1
  memory_mb: 512
  vcpu: 1
```

## Modules

### yaml-validator
Validates YAML configuration files and checks for required keys:
```hcl
module "validate_config" {
  source = "./modules/yaml-validator"
  
  config_file   = "${path.module}/config/networks.yaml"
  required_keys = ["networks"]
}
```

## Usage Examples

### 1. Basic YAML Parsing (main.tf.example)
Parse simple YAML and create resources:
```bash
cp main.tf.example main.tf
terraform init
terraform plan
```

### 2. Complex Infrastructure (infrastructure.tf.example)
Deploy complete infrastructure from YAML:
```bash
cp infrastructure.tf.example main.tf
terraform init
terraform plan
```

### 3. Multi-Environment (environments.tf.example)
Deploy environment-specific configurations:
```bash
cp environments.tf.example main.tf
terraform init

# Deploy dev environment
terraform plan -var="environment=dev"

# Deploy staging environment
terraform plan -var="environment=staging"

# Deploy production environment
terraform plan -var="environment=prod"
```

## Key Concepts

### yamldecode() Function
Parse YAML files into Terraform data structures:
```hcl
locals {
  config = yamldecode(file("${path.module}/config/networks.yaml"))
}
```

### Configuration Transformation
Transform YAML lists to maps for for_each:
```hcl
locals {
  networks = {
    for net in local.config.networks :
    net.name => net
  }
}
```

### Validation with Preconditions
Validate configuration before resource creation:
```hcl
resource "terraform_data" "validate" {
  lifecycle {
    precondition {
      condition     = length(local.missing_keys) == 0
      error_message = "Missing required keys"
    }
  }
}
```

## Best Practices

1. **Schema Validation**: Always validate YAML structure before use
2. **Required Keys**: Check for required configuration keys
3. **Type Safety**: Use Terraform validation to ensure correct types
4. **Documentation**: Document YAML schema and expected structure
5. **Defaults**: Provide sensible defaults for optional values
6. **Environment Separation**: Keep environment configs in separate files

## Common Patterns

### Pattern 1: Simple List Configuration
Best for: Networks, security groups, simple resources
```yaml
items:
  - name: "item-1"
    value: "config"
```

### Pattern 2: Nested Object Configuration
Best for: Complex infrastructure, multi-tier applications
```yaml
infrastructure:
  tier1:
    resource1: {}
  tier2:
    resource2: {}
```

### Pattern 3: Environment-Specific Configuration
Best for: Multi-environment deployments
```yaml
environment: "dev"
resources:
  count: 1
  size: "small"
```

## Troubleshooting

### YAML Parse Errors
```
Error: Invalid YAML syntax
```
**Solution**: Validate YAML syntax with `yamllint` or online validators

### Missing Required Keys
```
Error: Missing required keys: networks
```
**Solution**: Ensure all required keys are present in YAML file

### Type Mismatches
```
Error: Expected string, got number
```
**Solution**: Quote numeric values that should be strings in YAML

## Additional Resources

- [Terraform yamldecode() Function](https://www.terraform.io/language/functions/yamldecode)
- [YAML Specification](https://yaml.org/spec/)
- [Configuration-as-Data Patterns](https://www.hashicorp.com/resources/configuration-as-data)
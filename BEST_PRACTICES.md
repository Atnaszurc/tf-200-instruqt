# TF-200 Modules Lab - Best Practices

This guide provides best practices for working with Terraform modules, based on real-world experience and HashiCorp recommendations.

## Table of Contents

1. [Module Design Principles](#module-design-principles)
2. [Module Structure](#module-structure)
3. [Variable Design](#variable-design)
4. [Output Design](#output-design)
5. [Module Composition](#module-composition)
6. [YAML-Driven Configuration](#yaml-driven-configuration)
7. [Import and Migration](#import-and-migration)
8. [Testing and Validation](#testing-and-validation)
9. [Documentation](#documentation)
10. [Version Control](#version-control)

---

## Module Design Principles

### Single Responsibility Principle

**DO**: Create modules that do one thing well
```hcl
# Good: Focused module
module "vpc" {
  source = "./modules/vpc"
  cidr_block = "10.0.0.0/16"
}

module "database" {
  source = "./modules/database"
  vpc_id = module.vpc.id
}
```

**DON'T**: Create monolithic modules that do everything
```hcl
# Bad: Kitchen sink module
module "everything" {
  source = "./modules/everything"
  # 50+ variables for VPC, DB, compute, storage, etc.
}
```

### Composability

**DO**: Design modules to work together
```hcl
# Good: Composable modules
module "frontend" {
  source = "./modules/frontend"
  vpc_id = module.vpc.id
  subnet_ids = module.vpc.public_subnet_ids
}

module "backend" {
  source = "./modules/backend"
  vpc_id = module.vpc.id
  subnet_ids = module.vpc.private_subnet_ids
  frontend_sg_id = module.frontend.security_group_id
}
```

### Reusability

**DO**: Make modules reusable across environments
```hcl
# Good: Environment-agnostic module
module "app" {
  source = "./modules/app"
  
  environment = var.environment
  instance_count = var.environment == "prod" ? 3 : 1
  instance_type = var.environment == "prod" ? "large" : "small"
}
```

**DON'T**: Hardcode environment-specific values
```hcl
# Bad: Hardcoded values
module "app" {
  source = "./modules/app"
  instance_count = 3  # What about dev/staging?
  instance_type = "large"  # Always large?
}
```

---

## Module Structure

### Standard Layout

Always use this structure for consistency:

```
modules/
└── my-module/
    ├── main.tf           # Primary resources
    ├── variables.tf      # Input variables
    ├── outputs.tf        # Output values
    ├── versions.tf       # Provider requirements
    ├── README.md         # Documentation
    └── examples/         # Usage examples
        └── basic/
            ├── main.tf
            └── README.md
```

### File Organization

**main.tf**: Group related resources
```hcl
# Good: Logical grouping
# Network resources
resource "libvirt_network" "main" { ... }

# Storage resources
resource "libvirt_volume" "main" { ... }

# Compute resources
resource "libvirt_domain" "main" { ... }
```

**variables.tf**: Group and document variables
```hcl
# Good: Organized with descriptions
# Network Configuration
variable "network_cidr" {
  description = "CIDR block for the network"
  type        = string
  default     = "10.0.0.0/16"
}

# Compute Configuration
variable "instance_count" {
  description = "Number of instances to create"
  type        = number
  default     = 1
  
  validation {
    condition     = var.instance_count > 0 && var.instance_count <= 10
    error_message = "Instance count must be between 1 and 10"
  }
}
```

**outputs.tf**: Provide useful outputs
```hcl
# Good: Well-documented outputs
output "instance_ids" {
  description = "List of instance IDs created by this module"
  value       = libvirt_domain.main[*].id
}

output "network_id" {
  description = "ID of the created network"
  value       = libvirt_network.main.id
}
```

---

## Variable Design

### Use Appropriate Types

**DO**: Use specific types
```hcl
# Good: Specific types
variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

variable "subnet_config" {
  description = "Subnet configuration"
  type = object({
    cidr_block = string
    az         = string
    public     = bool
  })
}
```

**DON'T**: Use generic types
```hcl
# Bad: Generic types
variable "config" {
  description = "Configuration"
  type        = any  # Too generic!
}
```

### Provide Sensible Defaults

**DO**: Default to secure, common values
```hcl
# Good: Secure defaults
variable "enable_monitoring" {
  description = "Enable monitoring for resources"
  type        = bool
  default     = true  # Monitoring on by default
}

variable "backup_retention_days" {
  description = "Number of days to retain backups"
  type        = number
  default     = 30  # Reasonable default
}
```

### Use Validation

**DO**: Validate input values
```hcl
# Good: Input validation
variable "environment" {
  description = "Environment name"
  type        = string
  
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod"
  }
}

variable "instance_size" {
  description = "Instance size in GB"
  type        = number
  
  validation {
    condition     = var.instance_size >= 10 && var.instance_size <= 1000
    error_message = "Instance size must be between 10 and 1000 GB"
  }
}
```

### Mark Sensitive Variables

**DO**: Mark sensitive data
```hcl
# Good: Sensitive marking
variable "database_password" {
  description = "Database password"
  type        = string
  sensitive   = true
}

output "db_connection_string" {
  description = "Database connection string"
  value       = "postgresql://${var.db_user}:${var.database_password}@${libvirt_domain.db.network_interface[0].addresses[0]}"
  sensitive   = true
}
```

---

## Output Design

### Output Useful Information

**DO**: Provide outputs that consumers need
```hcl
# Good: Useful outputs
output "instance_id" {
  description = "ID of the created instance"
  value       = libvirt_domain.main.id
}

output "instance_ip" {
  description = "IP address of the instance"
  value       = libvirt_domain.main.network_interface[0].addresses[0]
}

output "security_group_id" {
  description = "ID of the security group for connecting to this instance"
  value       = libvirt_network.main.id
}
```

**DON'T**: Output everything
```hcl
# Bad: Too much information
output "entire_resource" {
  value = libvirt_domain.main  # Exposes everything!
}
```

### Use Descriptive Names

**DO**: Use clear, descriptive names
```hcl
# Good: Clear names
output "database_connection_string" { ... }
output "load_balancer_dns_name" { ... }
output "api_endpoint_url" { ... }
```

**DON'T**: Use cryptic names
```hcl
# Bad: Unclear names
output "conn" { ... }
output "lb" { ... }
output "url" { ... }
```

---

## Module Composition

### Layer Modules Appropriately

**DO**: Create logical layers
```hcl
# Good: Layered architecture
# Layer 1: Foundation
module "network" {
  source = "./modules/network"
}

# Layer 2: Data
module "database" {
  source = "./modules/database"
  network_id = module.network.id
}

# Layer 3: Application
module "app" {
  source = "./modules/app"
  network_id = module.network.id
  database_endpoint = module.database.endpoint
}
```

### Use Composition Modules

**DO**: Create composition modules for common patterns
```hcl
# Good: Composition module
module "app_stack" {
  source = "./modules/app-stack"
  
  config = {
    frontend = { ... }
    backend  = { ... }
    database = { ... }
  }
}

# modules/app-stack/main.tf
module "frontend" {
  source = "../frontend"
  config = var.config.frontend
}

module "backend" {
  source = "../backend"
  config = var.config.backend
  frontend_endpoint = module.frontend.endpoint
}

module "database" {
  source = "../database"
  config = var.config.database
}
```

### Handle Dependencies Explicitly

**DO**: Use explicit dependencies
```hcl
# Good: Explicit dependencies
module "app" {
  source = "./modules/app"
  
  network_id = module.network.id
  database_endpoint = module.database.endpoint
  
  depends_on = [
    module.network,
    module.database
  ]
}
```

---

## YAML-Driven Configuration

### Structure YAML Logically

**DO**: Use clear, hierarchical structure
```yaml
# Good: Clear structure
environment: production

network:
  cidr: "10.0.0.0/16"
  subnets:
    - name: public-1
      cidr: "10.0.1.0/24"
    - name: private-1
      cidr: "10.0.2.0/24"

compute:
  instances:
    - name: web-1
      type: large
      subnet: public-1
    - name: app-1
      type: xlarge
      subnet: private-1
```

### Validate YAML Structure

**DO**: Validate YAML in Terraform
```hcl
# Good: YAML validation
locals {
  config = yamldecode(file("${path.module}/config.yaml"))
  
  # Validate required fields
  validated_config = {
    environment = lookup(local.config, "environment", null) != null ? local.config.environment : error("environment is required")
    network     = lookup(local.config, "network", null) != null ? local.config.network : error("network configuration is required")
  }
}

# Use preconditions
resource "libvirt_network" "main" {
  name = local.validated_config.network.name
  
  lifecycle {
    precondition {
      condition     = can(regex("^[a-z0-9-]+$", local.validated_config.network.name))
      error_message = "Network name must contain only lowercase letters, numbers, and hyphens"
    }
  }
}
```

### Use Environment-Specific Files

**DO**: Separate configs by environment
```
config/
├── dev.yaml
├── staging.yaml
└── prod.yaml
```

```hcl
# Good: Environment selection
locals {
  config = yamldecode(file("${path.module}/config/${var.environment}.yaml"))
}
```

### Document YAML Schema

**DO**: Provide schema documentation
```yaml
# config/schema.yaml - Documentation only
# This file documents the expected YAML structure

environment: string  # Required: dev, staging, or prod

network:
  cidr: string      # Required: Network CIDR block
  subnets:          # Required: List of subnets
    - name: string  # Required: Subnet name
      cidr: string  # Required: Subnet CIDR

compute:
  instances:        # Optional: List of instances
    - name: string  # Required: Instance name
      type: string  # Required: Instance type (small, medium, large)
      subnet: string # Required: Subnet name to place instance in
```

---

## Import and Migration

### Use Import Blocks (Terraform 1.5+)

**DO**: Use declarative import blocks
```hcl
# Good: Import blocks
import {
  to = libvirt_network.legacy
  id = "legacy-network"
}

resource "libvirt_network" "legacy" {
  name = "legacy-network"
  mode = "nat"
  addresses = ["10.0.0.0/24"]
}
```

**DON'T**: Use legacy CLI import for new code
```bash
# Avoid: Legacy CLI import (unless Terraform < 1.5)
terraform import libvirt_network.legacy legacy-network
```

### Generate Configuration

**DO**: Use `-generate-config-out` for imports
```bash
# Good: Generate configuration
terraform plan -generate-config-out=generated.tf
```

### Use Moved Blocks for Refactoring

**DO**: Use moved blocks when refactoring
```hcl
# Good: Safe refactoring with moved blocks
moved {
  from = libvirt_domain.old_name
  to   = libvirt_domain.new_name
}

resource "libvirt_domain" "new_name" {
  # Resource configuration
}
```

### Use Removed Blocks for Cleanup

**DO**: Use removed blocks (Terraform 1.7+)
```hcl
# Good: Remove from state without destroying
removed {
  from = libvirt_domain.decommissioned
  
  lifecycle {
    destroy = false
  }
}
```

### Plan Import Strategy

**DO**: Import in logical groups
```hcl
# Good: Grouped imports
# Network resources
import {
  to = libvirt_network.main
  id = "main-network"
}

# Storage resources
import {
  to = libvirt_volume.data
  id = "data-volume"
}

# Compute resources
import {
  to = libvirt_domain.app
  id = "app-server"
}
```

---

## Testing and Validation

### Use Preconditions

**DO**: Validate assumptions
```hcl
# Good: Preconditions
resource "libvirt_domain" "app" {
  name = var.instance_name
  
  lifecycle {
    precondition {
      condition     = var.memory_mb >= 512
      error_message = "Memory must be at least 512 MB"
    }
    
    precondition {
      condition     = can(regex("^[a-z0-9-]+$", var.instance_name))
      error_message = "Instance name must contain only lowercase letters, numbers, and hyphens"
    }
  }
}
```

### Use Postconditions

**DO**: Verify outcomes
```hcl
# Good: Postconditions
resource "libvirt_domain" "app" {
  name = var.instance_name
  
  lifecycle {
    postcondition {
      condition     = self.vcpu > 0
      error_message = "Instance must have at least 1 vCPU"
    }
    
    postcondition {
      condition     = length(self.network_interface) > 0
      error_message = "Instance must have at least one network interface"
    }
  }
}
```

### Use Check Blocks

**DO**: Add continuous validation
```hcl
# Good: Check blocks
check "instance_health" {
  data "http" "health" {
    url = "http://${libvirt_domain.app.network_interface[0].addresses[0]}/health"
  }
  
  assert {
    condition     = data.http.health.status_code == 200
    error_message = "Instance health check failed"
  }
}
```

### Test Module Examples

**DO**: Provide testable examples
```
modules/my-module/
└── examples/
    ├── basic/
    │   ├── main.tf
    │   └── README.md
    ├── advanced/
    │   ├── main.tf
    │   └── README.md
    └── tests/
        └── basic_test.go
```

---

## Documentation

### Module README

**DO**: Include comprehensive README
```markdown
# Module Name

Brief description of what the module does.

## Usage

```hcl
module "example" {
  source = "./modules/example"
  
  name = "my-instance"
  size = "large"
}
```

## Requirements

| Name | Version |
|------|---------|
| terraform | >= 1.5 |
| libvirt | >= 0.7 |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| name | Instance name | string | n/a | yes |
| size | Instance size | string | "medium" | no |

## Outputs

| Name | Description |
|------|-------------|
| id | Instance ID |
| ip | Instance IP address |

## Examples

See [examples/](./examples/) directory.
```

### Inline Documentation

**DO**: Document complex logic
```hcl
# Good: Documented logic
locals {
  # Calculate instance count based on environment
  # Production: 3 instances for HA
  # Staging: 2 instances for testing HA
  # Development: 1 instance to save resources
  instance_count = (
    var.environment == "prod" ? 3 :
    var.environment == "staging" ? 2 :
    1
  )
  
  # Generate instance names with zero-padded numbers
  # Example: app-prod-01, app-prod-02, app-prod-03
  instance_names = [
    for i in range(local.instance_count) :
    format("%s-%s-%02d", var.app_name, var.environment, i + 1)
  ]
}
```

---

## Version Control

### Use Semantic Versioning

**DO**: Tag module versions
```bash
# Good: Semantic versioning
git tag -a v1.0.0 -m "Initial release"
git tag -a v1.1.0 -m "Add monitoring support"
git tag -a v2.0.0 -m "Breaking: Change variable names"
```

### Pin Module Versions

**DO**: Pin to specific versions
```hcl
# Good: Pinned version
module "app" {
  source  = "git::https://github.com/org/terraform-modules.git//app?ref=v1.2.0"
  
  name = "my-app"
}
```

**DON'T**: Use unpinned versions in production
```hcl
# Bad: Unpinned version
module "app" {
  source = "git::https://github.com/org/terraform-modules.git//app"  # Uses latest!
}
```

### Document Breaking Changes

**DO**: Maintain CHANGELOG
```markdown
# Changelog

## [2.0.0] - 2024-01-15

### Breaking Changes
- Renamed `instance_type` to `instance_size`
- Changed default network CIDR from /24 to /16

### Migration Guide
```hcl
# Before
module "app" {
  instance_type = "large"
}

# After
module "app" {
  instance_size = "large"
}
```

## [1.1.0] - 2024-01-01

### Added
- Support for custom monitoring endpoints
- New output: `monitoring_url`
```

---

## Summary

Following these best practices will help you:

1. **Create maintainable modules** that are easy to understand and modify
2. **Build reusable components** that work across environments
3. **Implement safe migrations** using modern Terraform features
4. **Write testable code** with proper validation
5. **Document effectively** for team collaboration

Remember: Good module design is about finding the right balance between flexibility and simplicity. Start simple and add complexity only when needed.

---

## Additional Resources

- [Terraform Module Best Practices](https://www.terraform.io/docs/modules/index.html)
- [HashiCorp Module Registry](https://registry.terraform.io/)
- [Terraform Style Guide](https://www.terraform.io/docs/language/syntax/style.html)
- [Module Composition Patterns](https://www.terraform.io/docs/language/modules/develop/composition.html)
# TF-200 Modules Lab - Common Mistakes

This guide covers common mistakes when working with Terraform modules and how to avoid them.

## Table of Contents

1. [Module Design Mistakes](#module-design-mistakes)
2. [Variable and Output Mistakes](#variable-and-output-mistakes)
3. [Module Composition Mistakes](#module-composition-mistakes)
4. [YAML Configuration Mistakes](#yaml-configuration-mistakes)
5. [Import and Migration Mistakes](#import-and-migration-mistakes)
6. [State Management Mistakes](#state-management-mistakes)
7. [Testing and Validation Mistakes](#testing-and-validation-mistakes)
8. [Performance Mistakes](#performance-mistakes)

---

## Module Design Mistakes

### ❌ Mistake 1: Creating Monolithic Modules

**Problem**: Trying to do everything in one module

```hcl
# Bad: Kitchen sink module
module "everything" {
  source = "./modules/everything"
  
  # 50+ variables for VPC, subnets, security groups,
  # instances, databases, load balancers, etc.
  vpc_cidr = "10.0.0.0/16"
  instance_count = 3
  db_size = "large"
  # ... 47 more variables
}
```

**Why it's wrong**:
- Hard to test individual components
- Difficult to reuse parts
- Changes affect everything
- Unclear dependencies

**Solution**: Break into focused modules

```hcl
# Good: Focused modules
module "network" {
  source = "./modules/network"
  cidr_block = "10.0.0.0/16"
}

module "compute" {
  source = "./modules/compute"
  network_id = module.network.id
  instance_count = 3
}

module "database" {
  source = "./modules/database"
  network_id = module.network.id
  size = "large"
}
```

---

### ❌ Mistake 2: Not Using Module Outputs

**Problem**: Hardcoding values instead of using outputs

```hcl
# Bad: Hardcoded values
module "network" {
  source = "./modules/network"
}

module "app" {
  source = "./modules/app"
  network_id = "network-123"  # Hardcoded!
}
```

**Why it's wrong**:
- Breaks when network changes
- No dependency tracking
- Manual coordination required

**Solution**: Use module outputs

```hcl
# Good: Using outputs
module "network" {
  source = "./modules/network"
}

module "app" {
  source = "./modules/app"
  network_id = module.network.id  # Dynamic!
}
```

---

### ❌ Mistake 3: Circular Dependencies

**Problem**: Modules depending on each other

```hcl
# Bad: Circular dependency
module "app" {
  source = "./modules/app"
  db_endpoint = module.database.endpoint
}

module "database" {
  source = "./modules/database"
  app_security_group = module.app.security_group_id  # Circular!
}
```

**Why it's wrong**:
- Terraform cannot resolve order
- Plan/apply will fail
- Indicates poor design

**Solution**: Restructure dependencies

```hcl
# Good: Linear dependencies
module "network" {
  source = "./modules/network"
}

module "security" {
  source = "./modules/security"
  network_id = module.network.id
}

module "database" {
  source = "./modules/database"
  network_id = module.network.id
  security_group_id = module.security.db_sg_id
}

module "app" {
  source = "./modules/app"
  network_id = module.network.id
  security_group_id = module.security.app_sg_id
  db_endpoint = module.database.endpoint
}
```

---

## Variable and Output Mistakes

### ❌ Mistake 4: Using `any` Type

**Problem**: Using generic `any` type for variables

```hcl
# Bad: Generic type
variable "config" {
  description = "Configuration"
  type        = any  # Too generic!
}
```

**Why it's wrong**:
- No type checking
- No validation
- Unclear expectations
- Runtime errors

**Solution**: Use specific types

```hcl
# Good: Specific type
variable "config" {
  description = "Application configuration"
  type = object({
    name        = string
    environment = string
    replicas    = number
    tags        = map(string)
  })
}
```

---

### ❌ Mistake 5: Not Validating Inputs

**Problem**: Accepting any value without validation

```hcl
# Bad: No validation
variable "environment" {
  description = "Environment name"
  type        = string
}

# User could pass "prodution" (typo) or "PROD" (wrong case)
```

**Why it's wrong**:
- Typos cause issues
- Invalid values accepted
- Errors appear late
- Hard to debug

**Solution**: Add validation

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
```

---

### ❌ Mistake 6: Not Marking Sensitive Data

**Problem**: Exposing sensitive data in outputs

```hcl
# Bad: Sensitive data exposed
variable "database_password" {
  type = string
}

output "db_connection" {
  value = "postgresql://user:${var.database_password}@host/db"
}
```

**Why it's wrong**:
- Passwords visible in logs
- Secrets in state file output
- Security risk

**Solution**: Mark as sensitive

```hcl
# Good: Marked sensitive
variable "database_password" {
  type      = string
  sensitive = true
}

output "db_connection" {
  value     = "postgresql://user:${var.database_password}@host/db"
  sensitive = true
}
```

---

### ❌ Mistake 7: Too Many Optional Variables

**Problem**: Everything is optional with defaults

```hcl
# Bad: Everything optional
variable "instance_type" {
  type    = string
  default = "small"
}

variable "disk_size" {
  type    = number
  default = 10
}

variable "backup_enabled" {
  type    = bool
  default = false  # Dangerous default!
}

# ... 20 more optional variables
```

**Why it's wrong**:
- Users don't know what to configure
- Important settings missed
- Defaults may not fit use case

**Solution**: Make important variables required

```hcl
# Good: Required variables for important settings
variable "instance_type" {
  description = "Instance type (small, medium, large)"
  type        = string
  # No default - must be specified
}

variable "backup_enabled" {
  description = "Enable automated backups"
  type        = bool
  default     = true  # Safe default
}
```

---

## Module Composition Mistakes

### ❌ Mistake 8: Deep Module Nesting

**Problem**: Too many layers of modules

```hcl
# Bad: Too deep
module "layer1" {
  source = "./modules/layer1"
}

# layer1 calls layer2
# layer2 calls layer3
# layer3 calls layer4
# layer4 calls layer5  # Too deep!
```

**Why it's wrong**:
- Hard to understand flow
- Difficult to debug
- Performance impact
- Maintenance nightmare

**Solution**: Keep it shallow (2-3 levels max)

```hcl
# Good: Shallow hierarchy
# Root module
module "foundation" {
  source = "./modules/foundation"
}

module "application" {
  source = "./modules/application"
  foundation_id = module.foundation.id
}

# Application module may call 1-2 sub-modules, but that's it
```

---

### ❌ Mistake 9: Not Using Composition Modules

**Problem**: Repeating the same module pattern everywhere

```hcl
# Bad: Repeated pattern in every environment
# dev/main.tf
module "frontend" { ... }
module "backend" { ... }
module "database" { ... }

# staging/main.tf
module "frontend" { ... }
module "backend" { ... }
module "database" { ... }

# prod/main.tf
module "frontend" { ... }
module "backend" { ... }
module "database" { ... }
```

**Why it's wrong**:
- Code duplication
- Inconsistent configurations
- Hard to maintain

**Solution**: Create composition module

```hcl
# Good: Composition module
# modules/app-stack/main.tf
module "frontend" {
  source = "../frontend"
  config = var.config.frontend
}

module "backend" {
  source = "../backend"
  config = var.config.backend
}

module "database" {
  source = "../database"
  config = var.config.database
}

# Each environment just calls app-stack
module "app" {
  source = "./modules/app-stack"
  config = local.config
}
```

---

### ❌ Mistake 10: Ignoring Module Dependencies

**Problem**: Not using `depends_on` when needed

```hcl
# Bad: Missing dependency
module "app" {
  source = "./modules/app"
  
  # App needs database to be ready, but no explicit dependency
  database_endpoint = module.database.endpoint
}

module "database" {
  source = "./modules/database"
}
```

**Why it's wrong**:
- Race conditions
- Unpredictable behavior
- Intermittent failures

**Solution**: Use explicit dependencies

```hcl
# Good: Explicit dependency
module "app" {
  source = "./modules/app"
  
  database_endpoint = module.database.endpoint
  
  depends_on = [
    module.database
  ]
}
```

---

## YAML Configuration Mistakes

### ❌ Mistake 11: Not Validating YAML Structure

**Problem**: Assuming YAML is correct

```hcl
# Bad: No validation
locals {
  config = yamldecode(file("config.yaml"))
}

# What if config.yaml is missing required fields?
resource "libvirt_domain" "app" {
  name = local.config.app.name  # Could fail!
}
```

**Why it's wrong**:
- Runtime errors
- Unclear error messages
- Hard to debug

**Solution**: Validate YAML structure

```hcl
# Good: Validated YAML
locals {
  raw_config = yamldecode(file("config.yaml"))
  
  # Validate required fields
  config = {
    app = lookup(local.raw_config, "app", null) != null ? local.raw_config.app : error("app configuration is required")
  }
}

resource "libvirt_domain" "app" {
  name = local.config.app.name
  
  lifecycle {
    precondition {
      condition     = can(local.config.app.name)
      error_message = "app.name is required in config.yaml"
    }
  }
}
```

---

### ❌ Mistake 12: Hardcoding YAML File Paths

**Problem**: Fixed YAML file path

```hcl
# Bad: Hardcoded path
locals {
  config = yamldecode(file("prod.yaml"))  # Always prod!
}
```

**Why it's wrong**:
- Can't switch environments
- Must edit code to change config
- Not reusable

**Solution**: Use variable for environment

```hcl
# Good: Dynamic path
variable "environment" {
  type = string
}

locals {
  config = yamldecode(file("${path.module}/config/${var.environment}.yaml"))
}
```

---

### ❌ Mistake 13: Complex YAML Logic

**Problem**: Putting too much logic in YAML

```yaml
# Bad: Logic in YAML
instances:
  - name: web-1
    type: "{{ if environment == 'prod' }}large{{ else }}small{{ end }}"
    count: "{{ environment == 'prod' ? 3 : 1 }}"
```

**Why it's wrong**:
- YAML is for data, not logic
- Hard to validate
- Requires custom parsing

**Solution**: Keep YAML simple, logic in Terraform

```yaml
# Good: Simple YAML
instances:
  - name: web-1
    type: large
    count: 3
```

```hcl
# Logic in Terraform
locals {
  config = yamldecode(file("config.yaml"))
  
  # Apply environment-specific logic
  instance_type = var.environment == "prod" ? local.config.instances[0].type : "small"
  instance_count = var.environment == "prod" ? local.config.instances[0].count : 1
}
```

---

## Import and Migration Mistakes

### ❌ Mistake 14: Not Using Import Blocks

**Problem**: Using legacy CLI import for new code

```bash
# Bad: Legacy CLI import (Terraform 1.5+)
terraform import libvirt_network.main my-network
terraform import libvirt_volume.data my-volume
terraform import libvirt_domain.app my-instance
```

**Why it's wrong**:
- Not declarative
- Not in version control
- Hard to reproduce
- Manual process

**Solution**: Use import blocks (Terraform 1.5+)

```hcl
# Good: Import blocks
import {
  to = libvirt_network.main
  id = "my-network"
}

import {
  to = libvirt_volume.data
  id = "my-volume"
}

import {
  to = libvirt_domain.app
  id = "my-instance"
}

# Resources defined below
resource "libvirt_network" "main" { ... }
resource "libvirt_volume" "data" { ... }
resource "libvirt_domain" "app" { ... }
```

---

### ❌ Mistake 15: Not Generating Configuration

**Problem**: Writing configuration manually for imports

```hcl
# Bad: Manually written (might be wrong!)
import {
  to = libvirt_domain.app
  id = "my-instance"
}

resource "libvirt_domain" "app" {
  name = "my-instance"
  memory = 2048  # Is this correct?
  vcpu = 2       # Is this correct?
  # Missing many attributes!
}
```

**Why it's wrong**:
- Prone to errors
- Missing attributes
- Time-consuming
- May not match actual resource

**Solution**: Use `-generate-config-out`

```bash
# Good: Generate configuration
terraform plan -generate-config-out=generated.tf

# Review generated.tf and move to proper location
```

---

### ❌ Mistake 16: Forgetting Moved Blocks

**Problem**: Renaming resources without moved blocks

```hcl
# Bad: Just renamed
# Before:
# resource "libvirt_domain" "old_name" { ... }

# After:
resource "libvirt_domain" "new_name" { ... }
# Terraform will destroy old_name and create new_name!
```

**Why it's wrong**:
- Resource destroyed and recreated
- Downtime
- Data loss
- Unnecessary churn

**Solution**: Use moved blocks

```hcl
# Good: Safe refactoring
moved {
  from = libvirt_domain.old_name
  to   = libvirt_domain.new_name
}

resource "libvirt_domain" "new_name" {
  # Configuration
}
```

---

### ❌ Mistake 17: Destroying Instead of Removing

**Problem**: Deleting resource block to remove from state

```hcl
# Bad: Deleted resource block
# resource "libvirt_domain" "decommissioned" { ... }
# Terraform will destroy the resource!
```

**Why it's wrong**:
- Resource destroyed
- May want to keep resource
- Can't manage outside Terraform

**Solution**: Use removed blocks (Terraform 1.7+)

```hcl
# Good: Remove from state without destroying
removed {
  from = libvirt_domain.decommissioned
  
  lifecycle {
    destroy = false
  }
}
```

---

## State Management Mistakes

### ❌ Mistake 18: Not Using Remote State

**Problem**: Using local state for team projects

```hcl
# Bad: Local state (default)
# terraform.tfstate in local directory
```

**Why it's wrong**:
- No collaboration
- No locking
- Easy to lose
- No backup

**Solution**: Use remote state

```hcl
# Good: Remote state
terraform {
  backend "s3" {
    bucket = "my-terraform-state"
    key    = "modules/app/terraform.tfstate"
    region = "us-east-1"
  }
}
```

---

### ❌ Mistake 19: Not Using State Locking

**Problem**: Multiple people running Terraform simultaneously

```hcl
# Bad: No locking
terraform {
  backend "s3" {
    bucket = "my-terraform-state"
    key    = "terraform.tfstate"
    region = "us-east-1"
    # No locking configuration!
  }
}
```

**Why it's wrong**:
- Concurrent modifications
- State corruption
- Race conditions

**Solution**: Enable state locking

```hcl
# Good: With locking (Terraform 1.11+ native S3 locking)
terraform {
  backend "s3" {
    bucket = "my-terraform-state"
    key    = "terraform.tfstate"
    region = "us-east-1"
    # Native locking enabled by default in 1.11+
  }
}
```

---

### ❌ Mistake 20: Editing State Manually

**Problem**: Directly editing terraform.tfstate file

```bash
# Bad: Manual state editing
vim terraform.tfstate  # DON'T DO THIS!
```

**Why it's wrong**:
- State corruption
- Breaks checksums
- Loses history
- Dangerous

**Solution**: Use Terraform commands

```bash
# Good: Use Terraform commands
terraform state list
terraform state show libvirt_domain.app
terraform state mv libvirt_domain.old libvirt_domain.new
terraform state rm libvirt_domain.decommissioned
```

---

## Testing and Validation Mistakes

### ❌ Mistake 21: No Input Validation

**Problem**: Accepting any input value

```hcl
# Bad: No validation
variable "memory_mb" {
  type = number
}

# User could pass 0, negative, or unreasonably large values
```

**Why it's wrong**:
- Invalid configurations
- Runtime errors
- Resource creation failures

**Solution**: Add validation

```hcl
# Good: Input validation
variable "memory_mb" {
  description = "Memory in MB"
  type        = number
  
  validation {
    condition     = var.memory_mb >= 512 && var.memory_mb <= 32768
    error_message = "Memory must be between 512 MB and 32 GB"
  }
}
```

---

### ❌ Mistake 22: Not Using Preconditions

**Problem**: Assuming resources will be created correctly

```hcl
# Bad: No preconditions
resource "libvirt_domain" "app" {
  name   = var.instance_name
  memory = var.memory_mb
  vcpu   = var.vcpu_count
}
```

**Why it's wrong**:
- Invalid configurations accepted
- Errors appear late
- Hard to debug

**Solution**: Add preconditions

```hcl
# Good: Preconditions
resource "libvirt_domain" "app" {
  name   = var.instance_name
  memory = var.memory_mb
  vcpu   = var.vcpu_count
  
  lifecycle {
    precondition {
      condition     = var.memory_mb >= 512
      error_message = "Memory must be at least 512 MB"
    }
    
    precondition {
      condition     = var.vcpu_count > 0 && var.vcpu_count <= 16
      error_message = "vCPU count must be between 1 and 16"
    }
    
    precondition {
      condition     = can(regex("^[a-z0-9-]+$", var.instance_name))
      error_message = "Instance name must contain only lowercase letters, numbers, and hyphens"
    }
  }
}
```

---

### ❌ Mistake 23: Not Using Postconditions

**Problem**: Not verifying resource creation

```hcl
# Bad: No postconditions
resource "libvirt_domain" "app" {
  name = var.instance_name
  # ... configuration
}

# Did it actually get an IP address?
# Is it in the right network?
```

**Why it's wrong**:
- Silent failures
- Incomplete resources
- Hard to detect issues

**Solution**: Add postconditions

```hcl
# Good: Postconditions
resource "libvirt_domain" "app" {
  name = var.instance_name
  # ... configuration
  
  lifecycle {
    postcondition {
      condition     = length(self.network_interface) > 0
      error_message = "Instance must have at least one network interface"
    }
    
    postcondition {
      condition     = length(self.network_interface[0].addresses) > 0
      error_message = "Instance must have an IP address"
    }
  }
}
```

---

## Performance Mistakes

### ❌ Mistake 24: Using Count Instead of For_Each

**Problem**: Using count for resources that might change

```hcl
# Bad: Using count
variable "instance_names" {
  default = ["web-1", "web-2", "web-3"]
}

resource "libvirt_domain" "app" {
  count = length(var.instance_names)
  name  = var.instance_names[count.index]
}

# If you remove "web-2", "web-3" gets destroyed and recreated!
```

**Why it's wrong**:
- Unstable addresses
- Unnecessary recreation
- Downtime
- Order-dependent

**Solution**: Use for_each

```hcl
# Good: Using for_each
variable "instances" {
  default = {
    web-1 = { memory = 2048 }
    web-2 = { memory = 2048 }
    web-3 = { memory = 4096 }
  }
}

resource "libvirt_domain" "app" {
  for_each = var.instances
  
  name   = each.key
  memory = each.value.memory
}

# Removing web-2 only affects web-2, not web-3
```

---

### ❌ Mistake 25: Creating Too Many Resources at Once

**Problem**: Creating hundreds of resources in one apply

```hcl
# Bad: Creating 100 instances at once
resource "libvirt_domain" "app" {
  count = 100  # All at once!
  name  = "app-${count.index}"
}
```

**Why it's wrong**:
- Long apply times
- Resource exhaustion
- Hard to troubleshoot
- All-or-nothing

**Solution**: Use gradual rollout

```hcl
# Good: Gradual rollout
variable "canary_percentage" {
  description = "Percentage of instances to create (0-100)"
  type        = number
  default     = 10
}

locals {
  total_instances = 100
  canary_count    = ceil(local.total_instances * var.canary_percentage / 100)
}

resource "libvirt_domain" "app" {
  count = local.canary_count
  name  = "app-${count.index}"
}

# Start with 10%, then 25%, 50%, 100%
```

---

### ❌ Mistake 26: Not Using Parallelism Control

**Problem**: Letting Terraform create everything in parallel

```bash
# Bad: Default parallelism (10)
terraform apply
# Creates 10 resources simultaneously, might overwhelm system
```

**Why it's wrong**:
- Resource exhaustion
- API rate limits
- System overload

**Solution**: Control parallelism

```bash
# Good: Controlled parallelism
terraform apply -parallelism=3

# Or set in environment
export TF_CLI_ARGS_apply="-parallelism=3"
```

---

## Summary

### Top 10 Most Critical Mistakes to Avoid

1. **Creating monolithic modules** - Break into focused components
2. **Not validating inputs** - Always validate variable values
3. **Using `any` type** - Use specific types
4. **Not marking sensitive data** - Mark passwords/secrets as sensitive
5. **Not using import blocks** - Use declarative imports (Terraform 1.5+)
6. **Forgetting moved blocks** - Use when refactoring
7. **Not validating YAML** - Validate structure and required fields
8. **Using count instead of for_each** - Use for_each for stable addresses
9. **No preconditions/postconditions** - Validate assumptions
10. **Not using remote state** - Always use remote state for teams

### Quick Checklist

Before committing module code, verify:

- [ ] Module has single, clear purpose
- [ ] All variables have types and descriptions
- [ ] Important variables have validation
- [ ] Sensitive data marked as sensitive
- [ ] Outputs are documented
- [ ] Using for_each instead of count (where appropriate)
- [ ] Preconditions validate inputs
- [ ] Postconditions verify outcomes
- [ ] Import blocks used (not CLI import)
- [ ] Moved blocks used for refactoring
- [ ] YAML structure validated
- [ ] README.md exists with examples
- [ ] No hardcoded values

---

## Additional Resources

- [Terraform Best Practices](https://www.terraform.io/docs/cloud/guides/recommended-practices/index.html)
- [Module Development Best Practices](https://www.terraform.io/docs/language/modules/develop/index.html)
- [Terraform Style Guide](https://www.terraform.io/docs/language/syntax/style.html)
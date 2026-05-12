# TF-200 Modules Lab - Troubleshooting Guide

This guide helps you diagnose and fix common issues when working with Terraform modules.

## Table of Contents

1. [Module Loading Issues](#module-loading-issues)
2. [Variable and Type Errors](#variable-and-type-errors)
3. [Module Dependency Issues](#module-dependency-issues)
4. [YAML Configuration Issues](#yaml-configuration-issues)
5. [Import and Migration Issues](#import-and-migration-issues)
6. [State Management Issues](#state-management-issues)
7. [Resource Creation Failures](#resource-creation-failures)
8. [Performance Issues](#performance-issues)
9. [Debugging Techniques](#debugging-techniques)

---

## Module Loading Issues

### Issue: "Module not installed"

**Error Message**:
```
Error: Module not installed
│ 
│   on main.tf line 10:
│   10: module "app" {
│ 
│ This module is not yet installed. Run "terraform init" to install all modules required by this configuration.
```

**Cause**: Modules haven't been downloaded

**Solution**:
```bash
terraform init
```

**Prevention**: Always run `terraform init` after:
- Adding new modules
- Changing module sources
- Cloning a repository

---

### Issue: "Could not load plugin"

**Error Message**:
```
Error: Could not load plugin
│ 
│ Plugin reinitialization required. Please run "terraform init".
```

**Cause**: Provider plugins missing or outdated

**Solution**:
```bash
# Reinitialize with upgrade
terraform init -upgrade

# Or force reconfiguration
terraform init -reconfigure
```

---

### Issue: "Module source not found"

**Error Message**:
```
Error: Module not found
│ 
│   on main.tf line 10:
│   10:   source = "./modules/app"
│ 
│ The specified module source could not be found.
```

**Cause**: Incorrect module path

**Solution**:
```bash
# Check if path exists
ls -la ./modules/app

# Verify from root directory
pwd
ls -la modules/

# Fix the path in your configuration
```

**Common Path Issues**:
```hcl
# Wrong: Absolute path
source = "/home/user/project/modules/app"

# Wrong: Missing ./
source = "modules/app"

# Correct: Relative path
source = "./modules/app"
```

---

## Variable and Type Errors

### Issue: "Invalid value for variable"

**Error Message**:
```
Error: Invalid value for variable
│ 
│   on variables.tf line 5:
│    5: variable "environment" {
│ 
│ The given value is not suitable for var.environment: string required.
```

**Cause**: Wrong variable type provided

**Solution**:
```hcl
# Check variable definition
variable "environment" {
  type = string  # Expects string
}

# Provide correct type
environment = "dev"  # Not: environment = ["dev"]
```

**Debugging**:
```bash
# Check what you're passing
terraform console
> var.environment
```

---

### Issue: "Validation failed"

**Error Message**:
```
Error: Invalid value for variable
│ 
│   on variables.tf line 10:
│   10:     condition     = contains(["dev", "staging", "prod"], var.environment)
│ 
│ Environment must be dev, staging, or prod
```

**Cause**: Value doesn't meet validation rules

**Solution**:
```hcl
# Check allowed values
variable "environment" {
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Environment must be dev, staging, or prod"
  }
}

# Use correct value
environment = "dev"  # Not: "development" or "DEV"
```

---

### Issue: "Unsuitable value type"

**Error Message**:
```
Error: Unsuitable value type
│ 
│   on main.tf line 15:
│   15:   config = var.config
│ 
│ Unsuitable value: value must be an object
```

**Cause**: Complex type mismatch

**Solution**:
```hcl
# Check expected type
variable "config" {
  type = object({
    name = string
    size = number
  })
}

# Provide correct structure
config = {
  name = "my-app"
  size = 10
}

# Not: config = "my-app"
```

**Debugging**:
```bash
terraform console
> var.config
> type(var.config)
```

---

## Module Dependency Issues

### Issue: "Cycle in module dependencies"

**Error Message**:
```
Error: Cycle: module.app, module.database
```

**Cause**: Circular dependency between modules

**Solution**:
```hcl
# Bad: Circular dependency
module "app" {
  db_sg = module.database.security_group_id
}
module "database" {
  app_sg = module.app.security_group_id  # Circular!
}

# Good: Break the cycle
module "security" {
  source = "./modules/security"
}

module "app" {
  security_group_id = module.security.app_sg_id
}

module "database" {
  security_group_id = module.security.db_sg_id
}
```

---

### Issue: "Resource depends on unknown value"

**Error Message**:
```
Error: Reference to undeclared resource
│ 
│   on main.tf line 20:
│   20:   network_id = module.network.id
│ 
│ A managed resource "module.network" has not been declared in the root module.
```

**Cause**: Module not defined or typo in name

**Solution**:
```bash
# Check module is defined
grep -n "module \"network\"" *.tf

# Check for typos
# Wrong: module.networks.id
# Correct: module.network.id
```

---

### Issue: "Output not found"

**Error Message**:
```
Error: Unsupported attribute
│ 
│   on main.tf line 25:
│   25:   network_id = module.network.network_id
│ 
│ This object does not have an attribute named "network_id".
```

**Cause**: Output doesn't exist in module

**Solution**:
```bash
# Check available outputs
terraform state show module.network

# Or check module's outputs.tf
cat modules/network/outputs.tf

# Use correct output name
network_id = module.network.id  # Not: network_id
```

---

## YAML Configuration Issues

### Issue: "Error parsing YAML"

**Error Message**:
```
Error: Error in function call
│ 
│   on main.tf line 10:
│   10:   config = yamldecode(file("config.yaml"))
│ 
│ Call to function "yamldecode" failed: invalid YAML syntax
```

**Cause**: Invalid YAML syntax

**Solution**:
```bash
# Validate YAML syntax
python3 -c "import yaml; yaml.safe_load(open('config.yaml'))"

# Or use online validator
# https://www.yamllint.com/

# Common YAML issues:
# - Incorrect indentation (use spaces, not tabs)
# - Missing quotes around special characters
# - Unbalanced brackets
```

**Example Fix**:
```yaml
# Bad: Inconsistent indentation
network:
  cidr: "10.0.0.0/16"
   subnets:  # Wrong indentation!
    - name: public

# Good: Consistent indentation
network:
  cidr: "10.0.0.0/16"
  subnets:
    - name: public
```

---

### Issue: "YAML file not found"

**Error Message**:
```
Error: Error in function call
│ 
│   on main.tf line 10:
│   10:   config = yamldecode(file("config/dev.yaml"))
│ 
│ Call to function "file" failed: no file exists at config/dev.yaml
```

**Cause**: YAML file doesn't exist or wrong path

**Solution**:
```bash
# Check file exists
ls -la config/dev.yaml

# Check current directory
pwd

# Verify path in Terraform
terraform console
> path.module
> file("${path.module}/config/dev.yaml")
```

---

### Issue: "Missing required YAML field"

**Error Message**:
```
Error: Invalid index
│ 
│   on main.tf line 15:
│   15:   name = local.config.app.name
│ 
│ The given key does not identify an element in this collection value.
```

**Cause**: Required field missing in YAML

**Solution**:
```hcl
# Add validation
locals {
  raw_config = yamldecode(file("config.yaml"))
  
  # Validate required fields
  config = {
    app = lookup(local.raw_config, "app", null) != null ? (
      lookup(local.raw_config.app, "name", null) != null ?
      local.raw_config.app :
      error("app.name is required in config.yaml")
    ) : error("app configuration is required in config.yaml")
  }
}
```

**Check YAML**:
```yaml
# Ensure required fields exist
app:
  name: my-app  # Required!
  size: large
```

---

## Import and Migration Issues

### Issue: "Resource already exists"

**Error Message**:
```
Error: resource already exists
│ 
│   on main.tf line 20:
│   20: resource "libvirt_network" "main" {
│ 
│ A resource with the ID "my-network" already exists.
```

**Cause**: Trying to create resource that already exists

**Solution**:
```hcl
# Use import block instead
import {
  to = libvirt_network.main
  id = "my-network"
}

resource "libvirt_network" "main" {
  # Configuration
}
```

---

### Issue: "Import target does not exist"

**Error Message**:
```
Error: Cannot import non-existent remote object
│ 
│ While attempting to import an existing object to "libvirt_network.main", the provider detected that no object exists with the given id.
```

**Cause**: Resource ID doesn't exist

**Solution**:
```bash
# List available resources
virsh net-list --all

# Verify resource ID
virsh net-info my-network

# Use correct ID in import
import {
  to = libvirt_network.main
  id = "correct-network-name"  # Use actual name
}
```

---

### Issue: "Moved block not working"

**Error Message**:
```
Error: Moved object still exists
│ 
│ This object cannot be moved because the source address still exists.
```

**Cause**: Old resource block still exists

**Solution**:
```hcl
# Remove old resource block
# resource "libvirt_domain" "old_name" { ... }  # DELETE THIS

# Keep only moved block and new resource
moved {
  from = libvirt_domain.old_name
  to   = libvirt_domain.new_name
}

resource "libvirt_domain" "new_name" {
  # Configuration
}
```

---

### Issue: "Generated configuration incomplete"

**Error Message**:
```
Error: Insufficient network_interface blocks
│ 
│   on generated.tf line 10:
│   10: resource "libvirt_domain" "app" {
│ 
│ At least 1 "network_interface" blocks are required.
```

**Cause**: Generated config missing required blocks

**Solution**:
```bash
# Regenerate with plan
terraform plan -generate-config-out=generated.tf

# Review and fix generated.tf
# Add missing required blocks manually

# Example fix:
resource "libvirt_domain" "app" {
  name = "app"
  
  # Add missing network_interface
  network_interface {
    network_id = libvirt_network.main.id
  }
}
```

---

## State Management Issues

### Issue: "State lock timeout"

**Error Message**:
```
Error: Error acquiring the state lock
│ 
│ Lock Info:
│   ID:        abc123
│   Path:      terraform.tfstate
│   Operation: OperationTypeApply
│   Who:       user@hostname
│   Created:   2024-01-15 10:30:00
```

**Cause**: Another Terraform process is running or crashed

**Solution**:
```bash
# Check if another terraform process is running
ps aux | grep terraform

# If no process running, force unlock (CAREFUL!)
terraform force-unlock abc123

# Better: Wait for other process to complete
```

---

### Issue: "State file corrupted"

**Error Message**:
```
Error: Failed to load state
│ 
│ Error reading state file: invalid JSON
```

**Cause**: State file corrupted

**Solution**:
```bash
# Restore from backup
cp terraform.tfstate.backup terraform.tfstate

# Or restore from remote state
terraform state pull > terraform.tfstate

# If using S3, download previous version
aws s3api list-object-versions --bucket my-state-bucket --prefix terraform.tfstate
```

---

### Issue: "Resource not in state"

**Error Message**:
```
Error: Resource not found in state
│ 
│ The resource libvirt_domain.app does not exist in the state.
```

**Cause**: Resource not imported or was removed

**Solution**:
```bash
# Check state
terraform state list

# Import if needed
terraform import libvirt_domain.app my-instance

# Or use import block
```

---

## Resource Creation Failures

### Issue: "Network already exists"

**Error Message**:
```
Error: error creating libvirt network: network 'default' already exists
```

**Cause**: Network name conflict

**Solution**:
```bash
# List existing networks
virsh net-list --all

# Use different name or import existing
import {
  to = libvirt_network.main
  id = "default"
}
```

---

### Issue: "Insufficient memory"

**Error Message**:
```
Error: error creating libvirt domain: internal error: process exited while connecting to monitor: Cannot allocate memory
```

**Cause**: Not enough RAM available

**Solution**:
```bash
# Check available memory
free -h

# Reduce instance memory
resource "libvirt_domain" "app" {
  memory = 1024  # Reduce from 2048
}

# Or stop other VMs
virsh list
virsh shutdown other-vm
```

---

### Issue: "Volume already exists"

**Error Message**:
```
Error: error creating libvirt volume: storage volume 'app-disk' already exists
```

**Cause**: Volume name conflict

**Solution**:
```bash
# List volumes
virsh vol-list default

# Delete old volume (if safe)
virsh vol-delete app-disk default

# Or use different name
resource "libvirt_volume" "app" {
  name = "app-disk-v2"
}

# Or import existing
import {
  to = libvirt_volume.app
  id = "/var/lib/libvirt/images/app-disk"
}
```

---

## Performance Issues

### Issue: "Terraform apply very slow"

**Symptoms**: Apply takes much longer than expected

**Causes and Solutions**:

1. **Too many resources created at once**
```hcl
# Reduce parallelism
terraform apply -parallelism=3
```

2. **Large state file**
```bash
# Check state size
ls -lh terraform.tfstate

# Consider splitting into multiple states
```

3. **Slow provider operations**
```bash
# Enable debug logging
export TF_LOG=DEBUG
terraform apply

# Check for slow operations in logs
```

---

### Issue: "Plan takes forever"

**Symptoms**: `terraform plan` runs for minutes

**Solutions**:

1. **Refresh disabled**
```bash
# Skip refresh for faster planning
terraform plan -refresh=false
```

2. **Target specific resources**
```bash
# Plan only specific module
terraform plan -target=module.app
```

3. **Check for expensive data sources**
```hcl
# Bad: Expensive data source in loop
data "http" "health" {
  for_each = var.instances
  url = "http://${each.value.ip}/health"
}

# Good: Use check blocks instead
check "health" {
  data "http" "health" {
    url = "http://${var.instance_ip}/health"
  }
}
```

---

## Debugging Techniques

### Enable Debug Logging

```bash
# Enable detailed logging
export TF_LOG=DEBUG
export TF_LOG_PATH=terraform-debug.log

# Run command
terraform apply

# Review logs
less terraform-debug.log
```

### Use Terraform Console

```bash
# Start console
terraform console

# Test expressions
> var.environment
"dev"

> local.config
{
  "app" = {
    "name" = "my-app"
  }
}

# Test functions
> yamldecode(file("config.yaml"))

# Check module outputs
> module.network.id
"network-123"
```

### Inspect State

```bash
# List all resources
terraform state list

# Show specific resource
terraform state show libvirt_domain.app

# Show module resources
terraform state list module.app
terraform state show module.app.libvirt_domain.main
```

### Validate Configuration

```bash
# Validate syntax
terraform validate

# Format code
terraform fmt -recursive

# Check formatting
terraform fmt -check
```

### Use Targeted Operations

```bash
# Plan specific resource
terraform plan -target=libvirt_domain.app

# Apply specific module
terraform apply -target=module.network

# Destroy specific resource
terraform destroy -target=libvirt_domain.test
```

### Graph Dependencies

```bash
# Generate dependency graph
terraform graph | dot -Tpng > graph.png

# View in browser
open graph.png

# Or use online viewer
terraform graph > graph.dot
# Upload to http://www.webgraphviz.com/
```

---

## Quick Troubleshooting Checklist

When something goes wrong, check these in order:

1. **Basic Checks**
   - [ ] Ran `terraform init`?
   - [ ] Ran `terraform validate`?
   - [ ] Ran `terraform fmt`?
   - [ ] Checked syntax errors?

2. **Module Issues**
   - [ ] Module source path correct?
   - [ ] Module outputs exist?
   - [ ] No circular dependencies?
   - [ ] Module variables provided?

3. **Variable Issues**
   - [ ] Correct variable types?
   - [ ] Required variables provided?
   - [ ] Validation rules met?
   - [ ] Sensitive data marked?

4. **YAML Issues**
   - [ ] YAML syntax valid?
   - [ ] File path correct?
   - [ ] Required fields present?
   - [ ] Indentation correct?

5. **State Issues**
   - [ ] State file accessible?
   - [ ] No state locks?
   - [ ] Resources in state?
   - [ ] State not corrupted?

6. **Resource Issues**
   - [ ] No name conflicts?
   - [ ] Sufficient resources (RAM, disk)?
   - [ ] Provider configured?
   - [ ] Dependencies met?

---

## Getting Help

### Check Documentation

```bash
# Provider documentation
terraform providers

# Resource documentation
terraform providers schema -json | jq '.provider_schemas'

# Built-in function help
terraform console
> help(yamldecode)
```

### Community Resources

- [Terraform Discuss](https://discuss.hashicorp.com/c/terraform-core)
- [Terraform GitHub Issues](https://github.com/hashicorp/terraform/issues)
- [Stack Overflow](https://stackoverflow.com/questions/tagged/terraform)

### Debug Information to Provide

When asking for help, include:

1. Terraform version: `terraform version`
2. Provider versions: `terraform providers`
3. Error message (full output)
4. Relevant configuration (sanitized)
5. Debug logs (if applicable)
6. Steps to reproduce

---

## Summary

Most issues fall into these categories:

1. **Syntax errors** - Use `terraform validate` and `terraform fmt`
2. **Module issues** - Check paths, outputs, and dependencies
3. **Type errors** - Verify variable types and validation
4. **YAML issues** - Validate syntax and structure
5. **State issues** - Check locks and backups
6. **Resource conflicts** - Check for existing resources

**Remember**: When in doubt, check the logs with `TF_LOG=DEBUG`!
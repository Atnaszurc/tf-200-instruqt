---
slug: yaml-driven-configuration
id: xnycw0yahec3
type: challenge
title: 'Challenge 3: YAML-Driven Configuration'
teaser: Drive infrastructure from YAML files using configuration-as-data patterns
notes:
- type: text
  contents: "# Challenge 3: YAML-Driven Configuration\n\nIn this challenge, you'll
    learn to drive Terraform infrastructure from YAML configuration files.\n\n## What
    You'll Learn\n\n✅ **Parse YAML Files** - Use `yamldecode()` to read YAML configuration\n\n✅
    **Dynamic Resources** - Create resources from YAML data with for_each\n\n✅ **Complex
    Structures** - Handle nested YAML objects and lists\n\n✅ **Validation** - Validate
    YAML configuration in Terraform\n\n✅ **Configuration-as-Data** - Separate infrastructure
    logic from configuration\n\n## Why This Matters\n\nYAML-driven configuration enables:\n-
    Non-technical users to manage infrastructure configuration\n- GitOps workflows
    where config changes trigger deployments\n- Clear separation between infrastructure
    logic and values\n- Easier multi-environment management\n\nLet's master configuration-as-data!
    \U0001F680\n"
tabs:
- id: pubzhxtsnktq
  title: Shell
  type: terminal
  hostname: workstation
- id: xbcohyo1rnro
  title: Editor
  type: code
  hostname: workstation
  path: /root/terraform-workspace
difficulty: basic
timelimit: 5400
enhanced_loading: null
---

# Challenge 3: YAML-Driven Configuration

Welcome to Challenge 3! You'll learn to drive Terraform infrastructure from YAML configuration files using the `yamldecode()` function and configuration-as-data patterns.

## 📋 Challenge Overview

This challenge covers YAML-driven infrastructure:

1. **Basic YAML Configuration** - Parse simple YAML files
2. **Complex YAML Structures** - Handle nested objects and lists
3. **YAML Validation** - Validate configuration in Terraform
4. **Multi-Environment Patterns** - Manage multiple environments with YAML

---

## Section 1: Basic YAML Configuration 📄

### Understanding yamldecode()

The `yamldecode()` function parses YAML files into Terraform data structures:

```hcl
locals {
  config = yamldecode(file("${path.module}/config.yaml"))
}
```

**Benefits**:
- ✅ Separate configuration from code
- ✅ Non-technical users can edit YAML
- ✅ Version control configuration separately
- ✅ Enable GitOps workflows

### Lab 1: Create Networks from YAML

Let's create Libvirt networks from a YAML configuration file.

#### Step 1: Create the YAML Configuration

```bash
cd /root/terraform-workspace
mkdir -p config
```

Create `config/networks.yaml`:

```yaml
# Network Configuration
# This file defines all networks for the infrastructure

networks:
  - name: "web-network"
    mode: "nat"
    cidr: "10.10.0.0/24"
    domain: "web.local"
    autostart: true
    description: "Network for web servers"

  - name: "app-network"
    mode: "nat"
    cidr: "10.20.0.0/24"
    domain: "app.local"
    autostart: true
    description: "Network for application servers"

  - name: "db-network"
    mode: "nat"
    cidr: "10.30.0.0/24"
    domain: "db.local"
    autostart: true
    description: "Network for database servers"
```

#### Step 2: Create Terraform Configuration

Create `main.tf`:

```hcl
terraform {
  required_version = ">= 1.14"
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "~> 0.8"
    }
  }
}

provider "libvirt" {
  uri = "qemu:///system"
}

# Parse YAML configuration
locals {
  network_config = yamldecode(file("${path.module}/config/networks.yaml"))

  # Convert list to map for for_each
  networks = {
    for net in local.network_config.networks :
    net.name => net
  }
}

# Create networks from YAML
resource "libvirt_network" "networks" {
  for_each = local.networks

  name      = each.value.name
  mode      = each.value.mode
  addresses = [each.value.cidr]
  domain    = each.value.domain
  autostart = each.value.autostart

  dhcp {
    enabled = true
  }
}
```

Create `outputs.tf`:

```hcl
output "networks" {
  description = "Created networks"
  value = {
    for name, net in libvirt_network.networks :
    name => {
      id     = net.id
      bridge = net.bridge
      cidr   = net.addresses[0]
    }
  }
}

output "network_count" {
  description = "Number of networks created"
  value       = length(libvirt_network.networks)
}
```

#### Step 3: Test the Configuration

```bash
# Initialize
terraform init

# Validate
terraform validate

# Plan (see networks from YAML)
terraform plan

# Note the output shows 3 networks from YAML!
```

**Key Observations**:
- ✅ YAML file defines all networks
- ✅ Terraform code is generic (works with any YAML)
- ✅ Adding networks = editing YAML only
- ✅ No Terraform code changes needed

---

## Section 2: Complex YAML Structures 🏗️

### Handling Nested YAML

Complex infrastructure needs nested YAML structures with multiple resource types.

### Lab 2: Complete Infrastructure from YAML

Let's create a complete infrastructure stack from a single YAML file.

#### Step 1: Create Complex YAML Configuration

Create `config/infrastructure.yaml`:

```yaml
# Complete Infrastructure Configuration
# Defines networks, storage, and VMs

infrastructure:
  # Network Configuration
  networks:
    web:
      cidr: "192.168.10.0/24"
      domain: "web.local"
      mode: "nat"

    app:
      cidr: "192.168.20.0/24"
      domain: "app.local"
      mode: "nat"

    db:
      cidr: "192.168.30.0/24"
      domain: "db.local"
      mode: "nat"

  # Storage Configuration
  storage:
    pools:
      default:
        type: "dir"
        path: "/var/lib/libvirt/images/default"

      fast:
        type: "dir"
        path: "/var/lib/libvirt/images/fast"

  # VM Configuration
  vms:
    web-01:
      network: "web"
      pool: "default"
      memory_mb: 1024
      vcpu: 2
      disk_gb: 10
      autostart: true
      tags:
        role: "webserver"
        tier: "frontend"

    web-02:
      network: "web"
      pool: "default"
      memory_mb: 1024
      vcpu: 2
      disk_gb: 10
      autostart: true
      tags:
        role: "webserver"
        tier: "frontend"

    app-01:
      network: "app"
      pool: "fast"
      memory_mb: 2048
      vcpu: 4
      disk_gb: 20
      autostart: true
      tags:
        role: "application"
        tier: "backend"

    db-01:
      network: "db"
      pool: "fast"
      memory_mb: 4096
      vcpu: 4
      disk_gb: 50
      autostart: true
      tags:
        role: "database"
        tier: "data"

# Environment-specific settings
environment:
  name: "development"
  region: "us-east-1"
  owner: "platform-team"
  cost_center: "engineering"
```

#### Step 2: Create Terraform Configuration

Create `infrastructure.tf`:

```hcl
# Parse infrastructure configuration
locals {
  infra_config = yamldecode(file("${path.module}/config/infrastructure.yaml"))

  # Extract sections
  networks = local.infra_config.infrastructure.networks
  pools    = local.infra_config.infrastructure.storage.pools
  vms      = local.infra_config.infrastructure.vms
  env      = local.infra_config.environment
}

# Create networks
resource "libvirt_network" "networks" {
  for_each = local.networks

  name      = "${local.env.name}-${each.key}-network"
  mode      = each.value.mode
  addresses = [each.value.cidr]
  domain    = each.value.domain
  autostart = true

  dhcp {
    enabled = true
  }
}

# Create storage pools
resource "libvirt_pool" "pools" {
  for_each = local.pools

  name = "${local.env.name}-${each.key}-pool"
  type = each.value.type
  path = each.value.path
}

# Create VM volumes
resource "libvirt_volume" "vm_disks" {
  for_each = local.vms

  name   = "${local.env.name}-${each.key}.qcow2"
  pool   = libvirt_pool.pools[each.value.pool].name
  format = "qcow2"
  size   = each.value.disk_gb * 1073741824  # Convert GB to bytes
}

# Create VMs
resource "libvirt_domain" "vms" {
  for_each = local.vms

  name      = "${local.env.name}-${each.key}"
  memory    = each.value.memory_mb
  vcpu      = each.value.vcpu
  autostart = each.value.autostart

  disk {
    volume_id = libvirt_volume.vm_disks[each.key].id
  }

  network_interface {
    network_id = libvirt_network.networks[each.value.network].id
  }

  console {
    type        = "pty"
    target_type = "serial"
    target_port = "0"
  }
}

# Create metadata file with tags
resource "local_file" "vm_metadata" {
  for_each = local.vms

  filename = "/tmp/${local.env.name}-${each.key}-metadata.json"
  content = jsonencode({
    vm_name     = each.key
    environment = local.env.name
    network     = each.value.network
    pool        = each.value.pool
    tags        = each.value.tags
    owner       = local.env.owner
    cost_center = local.env.cost_center
  })
}
```

Create `infrastructure_outputs.tf`:

```hcl
output "infrastructure_summary" {
  description = "Complete infrastructure summary"
  value = {
    environment = local.env.name
    networks    = length(libvirt_network.networks)
    pools       = length(libvirt_pool.pools)
    vms         = length(libvirt_domain.vms)
  }
}

output "network_details" {
  description = "Network details"
  value = {
    for name, net in libvirt_network.networks :
    name => {
      id     = net.id
      bridge = net.bridge
      cidr   = net.addresses[0]
    }
  }
}

output "vm_details" {
  description = "VM details"
  value = {
    for name, vm in libvirt_domain.vms :
    name => {
      id       = vm.id
      memory   = vm.memory
      vcpu     = vm.vcpu
      network  = local.vms[name].network
      tags     = local.vms[name].tags
    }
  }
}
```

#### Step 3: Test Complex Configuration

```bash
terraform init
terraform validate
terraform plan

# Observe:
# - 3 networks created
# - 2 storage pools created
# - 4 VMs created
# - All from YAML configuration!
```

**Key Benefits**:
- ✅ Single YAML file defines entire infrastructure
- ✅ Easy to understand and modify
- ✅ Non-technical users can manage VMs
- ✅ Terraform code is reusable

---

### Why Validate YAML Configuration? 🤔

**The Problem Without Validation:**

Imagine you have this YAML configuration:

```yaml
infrastructure:
  networks:
    - name: web-network
      cidr: "192.168.10.0/24"
  vms:
    - name: web-server
      memory_mb: 2048
      network: web-netwrok  # ⚠️ Typo! Should be "web-network"
```

**What happens?**
1. ✅ Terraform parses the YAML successfully (syntax is valid)
2. ✅ Terraform starts creating resources
3. ✅ Network gets created
4. ❌ VM creation **fails** because "web-netwrok" doesn't exist
5. 😞 You've wasted time and have partial infrastructure

**The Solution With Validation:**

```hcl
# Validation catches the error BEFORE creating anything
resource "terraform_data" "validate_vm_networks" {
  lifecycle {
    precondition {
      condition     = contains(keys(local.networks), vm.network)
      error_message = "VM references invalid network: ${vm.network}"
    }
  }
}
```

**Result:**
- ❌ Terraform **fails immediately** with clear error message
- ✅ No resources created
- ✅ You fix the typo in YAML
- ✅ Run again successfully

**Why This Matters:**

| Without Validation | With Validation |
|-------------------|-----------------|
| Errors discovered during apply | Errors discovered during plan |
| Partial infrastructure created | Nothing created until valid |
| Unclear error messages | Clear, specific error messages |
| Time wasted debugging | Fast feedback loop |

<details>
<summary>🔍 Real-World Example: The $10,000 Typo</summary>

**True Story:**

A team deployed 50 VMs using YAML configuration. One VM had a typo in the network name. The deployment:
1. Created 49 VMs successfully
2. Failed on the 50th VM
3. Left infrastructure in inconsistent state
4. Required manual cleanup
5. Took 4 hours to fix

**With validation:**
- Would have failed in 5 seconds
- Clear error: "VM 'app-server-50' references invalid network 'prod-netwrok'"
- Fixed typo, rerun, done in 2 minutes

**Cost of no validation:** 4 hours × $250/hour = $1,000 in engineer time, plus potential downtime costs.

</details>

**What You'll Learn:**

In this section, you'll learn to:
1. ✅ Validate required YAML keys exist
2. ✅ Check data types and ranges (memory between 512MB-16GB)
3. ✅ Verify references are valid (VMs reference existing networks)
4. ✅ Prevent duplicate values (no overlapping network CIDRs)
5. ✅ Provide helpful error messages

**Connection to TF-100:**

Remember variable validation from TF-100? This is the same concept, but for YAML configuration:

```hcl
# TF-100: Variable validation
variable "environment" {
  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "Must be dev, staging, or prod"
  }
}

# TF-200: YAML validation (same idea, different source)
resource "terraform_data" "validate" {
  lifecycle {
    precondition {
      condition     = contains(keys(local.networks), vm.network)
      error_message = "VM references invalid network"
    }
  }
}
```

**Key Insight:** Validation is like spell-check for your infrastructure configuration. It catches mistakes before they become expensive problems.

---


## Section 3: YAML Validation 🔍

### Validating YAML Configuration

Terraform can validate YAML configuration to catch errors early.

### Lab 3: Add Validation

Let's add validation to ensure YAML configuration is correct.

#### Step 1: Create Validation Module

```bash
mkdir -p modules/yaml-validator
```

Create `modules/yaml-validator/variables.tf`:

```hcl
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
```

Create `modules/yaml-validator/main.tf`:

```hcl
terraform {
  required_version = ">= 1.14"
}

locals {
  # Parse YAML
  config = yamldecode(file(var.config_file))

  # Check required keys
  missing_keys = [
    for key in var.required_keys :
    key if !contains(keys(local.config), key)
  ]

  # Validation checks
  has_all_keys = length(local.missing_keys) == 0
}

# Validation: Required keys present
resource "terraform_data" "validate_keys" {
  lifecycle {
    precondition {
      condition     = local.has_all_keys
      error_message = "Missing required keys: ${join(", ", local.missing_keys)}"
    }
  }
}
```

Create `modules/yaml-validator/outputs.tf`:

```hcl
output "config" {
  description = "Parsed and validated configuration"
  value       = local.config
}

output "validation_passed" {
  description = "Whether validation passed"
  value       = local.has_all_keys
}
```

#### Step 2: Use Validation Module

Update `main.tf` to include validation:

```hcl
# Validate configuration before use
module "config_validator" {
  source = "./modules/yaml-validator"

  config_file = "${path.module}/config/infrastructure.yaml"
  required_keys = [
    "infrastructure",
    "environment"
  ]
}

# Use validated configuration
locals {
  validated_config = module.config_validator.config
  infra_config     = local.validated_config.infrastructure
  env_config       = local.validated_config.environment
}
```

#### Step 3: Add Custom Validation

Create `validation.tf`:

```hcl
# Custom validation rules

# Validate network CIDRs don't overlap
locals {
  network_cidrs = [
    for name, net in local.networks :
    net.cidr
  ]

  # Check for duplicate CIDRs
  unique_cidrs = toset(local.network_cidrs)
  has_duplicates = length(local.network_cidrs) != length(local.unique_cidrs)
}

resource "terraform_data" "validate_networks" {
  lifecycle {
    precondition {
      condition     = !local.has_duplicates
      error_message = "Network CIDRs must be unique"
    }
  }
}

# Validate VM memory is reasonable
locals {
  vm_memory_checks = {
    for name, vm in local.vms :
    name => vm.memory_mb >= 512 && vm.memory_mb <= 16384
  }

  invalid_memory_vms = [
    for name, valid in local.vm_memory_checks :
    name if !valid
  ]
}

resource "terraform_data" "validate_vm_memory" {
  lifecycle {
    precondition {
      condition     = length(local.invalid_memory_vms) == 0
      error_message = "VMs with invalid memory: ${join(", ", local.invalid_memory_vms)}"
    }
  }
}

# Validate VM references valid networks
locals {
  vm_network_checks = {
    for name, vm in local.vms :
    name => contains(keys(local.networks), vm.network)
  }

  invalid_network_vms = [
    for name, valid in local.vm_network_checks :
    name if !valid
  ]
}

resource "terraform_data" "validate_vm_networks" {
  lifecycle {
    precondition {
      condition     = length(local.invalid_network_vms) == 0
      error_message = "VMs reference invalid networks: ${join(", ", local.invalid_network_vms)}"
    }
  }
}
```

**Validation Benefits**:
- ✅ Catch configuration errors early
- ✅ Provide clear error messages
- ✅ Prevent invalid infrastructure
- ✅ Document configuration requirements

---

## Section 4: Multi-Environment Patterns 🌍

### Managing Multiple Environments

Use separate YAML files for each environment.

### Lab 4: Multi-Environment Configuration

#### Step 1: Create Environment-Specific YAML Files

```bash
mkdir -p config/environments
```

Create `config/environments/dev.yaml`:

```yaml
environment:
  name: "dev"
  region: "us-east-1"

infrastructure:
  networks:
    web:
      cidr: "192.168.10.0/24"
      domain: "web.dev.local"

  vms:
    web-01:
      network: "web"
      memory_mb: 512
      vcpu: 1
      disk_gb: 5
      autostart: false
```

Create `config/environments/staging.yaml`:

```yaml
environment:
  name: "staging"
  region: "us-east-1"

infrastructure:
  networks:
    web:
      cidr: "192.168.10.0/24"
      domain: "web.staging.local"

  vms:
    web-01:
      network: "web"
      memory_mb: 1024
      vcpu: 2
      disk_gb: 10
      autostart: true

    web-02:
      network: "web"
      memory_mb: 1024
      vcpu: 2
      disk_gb: 10
      autostart: true
```

Create `config/environments/prod.yaml`:

```yaml
environment:
  name: "prod"
  region: "us-east-1"

infrastructure:
  networks:
    web:
      cidr: "192.168.10.0/24"
      domain: "web.prod.local"

  vms:
    web-01:
      network: "web"
      memory_mb: 2048
      vcpu: 4
      disk_gb: 20
      autostart: true

    web-02:
      network: "web"
      memory_mb: 2048
      vcpu: 4
      disk_gb: 20
      autostart: true

    web-03:
      network: "web"
      memory_mb: 2048
      vcpu: 4
      disk_gb: 20
      autostart: true
```

#### Step 2: Create Environment Selector

Create `variables.tf`:

```hcl
variable "environment" {
  description = "Environment to deploy (dev, staging, prod)"
  type        = string
  default     = "dev"

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be dev, staging, or prod"
  }
}
```

Create `environments.tf`:

```hcl
# Load environment-specific configuration
locals {
  env_config = yamldecode(
    file("${path.module}/config/environments/${var.environment}.yaml")
  )

  environment  = local.env_config.environment
  networks     = local.env_config.infrastructure.networks
  vms          = local.env_config.infrastructure.vms
}

# Create resources from environment config
resource "libvirt_network" "env_networks" {
  for_each = local.networks

  name      = "${local.environment.name}-${each.key}-network"
  mode      = "nat"
  addresses = [each.value.cidr]
  domain    = each.value.domain
  autostart = true

  dhcp {
    enabled = true
  }
}

resource "libvirt_volume" "env_vm_disks" {
  for_each = local.vms

  name   = "${local.environment.name}-${each.key}.qcow2"
  pool   = "default"
  format = "qcow2"
  size   = each.value.disk_gb * 1073741824
}

resource "libvirt_domain" "env_vms" {
  for_each = local.vms

  name      = "${local.environment.name}-${each.key}"
  memory    = each.value.memory_mb
  vcpu      = each.value.vcpu
  autostart = each.value.autostart

  disk {
    volume_id = libvirt_volume.env_vm_disks[each.key].id
  }

  network_interface {
    network_id = libvirt_network.env_networks[each.value.network].id
  }

  console {
    type        = "pty"
    target_type = "serial"
    target_port = "0"
  }
}
```

#### Step 3: Deploy Different Environments

```bash
# Deploy dev environment (1 VM)
terraform plan -var="environment=dev"

# Deploy staging environment (2 VMs)
terraform plan -var="environment=staging"

# Deploy prod environment (3 VMs)
terraform plan -var="environment=prod"
```

**Multi-Environment Benefits**:
- ✅ Same Terraform code for all environments
- ✅ Environment-specific configuration in YAML
- ✅ Easy to add new environments
- ✅ Clear environment differences

---

## 🎯 Challenge Tasks

Complete these tasks to master YAML-driven configuration:

### Task 1: Basic YAML Configuration ✅
- [ ] Create `config/networks.yaml` with 3 networks
- [ ] Parse YAML with `yamldecode()`
- [ ] Create networks using for_each
- [ ] Verify networks are created from YAML

### Task 2: Complex YAML Structure ✅
- [ ] Create `config/infrastructure.yaml` with networks, pools, and VMs
- [ ] Parse nested YAML structure
- [ ] Create all resources from single YAML file
- [ ] Verify complete infrastructure

### Task 3: YAML Validation ✅
- [ ] Create validation module
- [ ] Add required key validation
- [ ] Add custom validation rules
- [ ] Test validation with invalid YAML

### Task 4: Multi-Environment ✅
- [ ] Create environment-specific YAML files (dev, staging, prod)
- [ ] Implement environment selector
- [ ] Deploy different environments
- [ ] Verify environment-specific resources

---

## 📝 Key Takeaways

### YAML-Driven Configuration
- ✅ Use `yamldecode()` to parse YAML files
- ✅ Convert YAML lists to maps for for_each
- ✅ Separate configuration from infrastructure logic
- ✅ Enable non-technical users to manage config

### Complex Structures
- ✅ Handle nested YAML objects
- ✅ Extract sections with locals
- ✅ Reference between resources
- ✅ Maintain relationships in YAML

### Validation
- ✅ Validate required keys
- ✅ Check data types and ranges
- ✅ Verify references are valid
- ✅ Provide clear error messages

### Multi-Environment
- ✅ One YAML file per environment
- ✅ Same Terraform code for all
- ✅ Environment-specific values
- ✅ Easy to add environments

---

## 🚀 Next Steps

You've mastered YAML-driven configuration! In the next challenge, you'll learn:

- **Import & Migration Strategies** - Import existing infrastructure
- **State Manipulation** - Safely modify Terraform state
- **Refactoring Techniques** - Restructure infrastructure code
- **Migration Patterns** - Move resources between modules

Great work! 🎉

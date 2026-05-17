---
slug: advanced-module-patterns
id: hg45zpeebjht
type: challenge
title: 'Challenge 2: Advanced Module Patterns'
teaser: Master nested modules, conditional resources, for_each patterns, and canary
  deployments
notes:
- type: text
  contents: "# Challenge 2: Advanced Module Patterns\n\nIn this challenge, you'll
    learn enterprise-grade module patterns that scale:\n\n## What You'll Learn\n\n✅
    **Nested Module Hierarchies** - Compose complex infrastructure from simple layers\n\n✅
    **Conditional Resources** - Create resources based on variables and environment\n\n✅
    **For_Each Patterns** - Manage multiple similar resources with stable addresses\n\n✅
    **Canary Deployments** - Implement gradual rollout strategies\n\n✅ **Module Versioning**
    - Use semantic versioning and version constraints\n\n## Why This Matters\n\nSimple
    modules work for small projects, but enterprise infrastructure needs patterns
    that:\n- Scale across complex environments\n- Enable safe deployments\n- Provide
    clear separation of concerns\n- Support gradual rollouts with easy rollback\n\nLet's
    master these advanced patterns! \U0001F680\n"
tabs:
- id: puy4ihtmitdm
  title: Shell
  type: terminal
  hostname: workstation
  workdir: /root/terraform-workspace
- id: 1623fi81iy4t
  title: Editor
  type: code
  hostname: workstation
  path: /root/terraform-workspace
difficulty: basic
timelimit: 5400
enhanced_loading: null
---

# Challenge 2: Advanced Module Patterns

Welcome to Challenge 2! You'll master advanced module patterns including nested modules, conditional resources, for_each patterns, and canary deployments.

## 📋 Challenge Overview

This challenge covers enterprise-grade module patterns:

1. **Nested Module Hierarchies** - Compose infrastructure in layers
2. **Conditional Resources** - Create resources based on conditions
3. **For_Each Patterns** - Manage multiple resources with stable addresses
4. **Canary Deployments** - Implement gradual rollout strategies

---

## Section 1: Nested Module Hierarchies 🏗️

### The Problem: When Do I Need Nested Modules?

**In Challenge 1**, you learned to create modules. But what if a module itself needs to use other modules?

**Example Scenario:**
You're building a complete application stack:
- Network layer (simple module)
- Storage layer (simple module)
- Compute layer (simple module)
- **Application stack** (combines all three)

**Option 1: Flat Structure (What You Know)**
```hcl
# main.tf - everything at top level
module "network" {
  source = "./modules/network"
}

module "storage" {
  source = "./modules/storage"
}

module "compute" {
  source     = "./modules/compute"
  network_id = module.network.id
  storage_id = module.storage.id
}

# User has to wire everything together manually
# User needs to understand all the connections
# Lots of repetition for each environment
```

**Option 2: Nested Structure (What You're Learning)**
```hcl
# main.tf - simple!
module "app_stack" {
  source = "./modules/app-stack"

  environment = "dev"
}

# modules/app-stack/main.tf - handles complexity
module "network" {
  source = "../network"
}

module "storage" {
  source = "../storage"
}

module "compute" {
  source     = "../compute"
  network_id = module.network.id
  storage_id = module.storage.id
}

# Wiring happens inside the module
# User doesn't need to know the details
# Easy to deploy to multiple environments
```

**When to Use Nested Modules:**
- ✅ When modules naturally group together (network + compute + storage)
- ✅ When you want to hide complexity from users
- ✅ When you have common patterns you deploy repeatedly
- ✅ When you need to enforce specific module combinations
- ❌ Don't nest just for the sake of nesting

**Rule of Thumb:**
If you find yourself always using 3 modules together in the same way, create a parent module that combines them.

**Real-World Example:**
- **AWS**: VPC + Subnets + Route Tables → "Network Stack" module
- **Azure**: Resource Group + VNet + NSG → "Foundation" module
- **Libvirt**: Network + Storage Pool + Base Image → "Infrastructure" module

---


### Understanding Nested Modules

**Nested modules** allow you to compose complex infrastructure from simple, reusable layers. Each layer has a single responsibility and can be tested independently.

**Example Architecture**:
```
modules/
├── app-stack/       # Top layer (uses all below)
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
├── network/         # Network layer
├── storage/         # Storage layer
└── compute/         # Compute layer
```

**Benefits**:
- ✅ Clear separation of concerns
- ✅ Reusable components at each layer
- ✅ Simple top-level interface
- ✅ Easy to test each layer independently

### Lab 1: Create a Nested Module Hierarchy

Let's build a 3-layer nested module structure for a complete application stack.

#### Step 1: Create the Network Module

This module creates a Libvirt network (bottom layer).

```bash
cd /root/terraform-workspace
mkdir -p modules/network
cd modules/network
```

Create `modules/network/variables.tf`:

```bash
cat <<EOF > variables.tf
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
EOF
```

Create `modules/network/main.tf`:

```bash
cat <<EOF > main.tf
terraform {
  required_version = ">= 1.14"
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "~> 0.9"
    }
  }
}

resource "libvirt_network" "this" {
  name      = var.network_name
  autostart = true

  # IP configuration - using list of objects with = syntax
  ips = [
    for addr in var.addresses : {
      address = split("/", addr)[0]
      prefix  = tonumber(split("/", addr)[1])
      dhcp = {
        ranges = [{
          start = cidrhost(addr, 2)
          end   = cidrhost(addr, -2)
        }]
      }
    }
  ]

  # Network forwarding mode - nested attribute
  forward = {
    mode = var.network_mode
  }

  # DNS domain configuration - nested attribute
  domain = {
    name = var.domain
  }
}
EOF
```

Create `modules/network/outputs.tf`:

```bash
cat <<EOF > outputs.tf
output "id" {
  description = "Network ID"
  value       = libvirt_network.this.id
}

output "name" {
  description = "Network name"
  value       = libvirt_network.this.name
}

output "bridge" {
  description = "Bridge interface"
  value       = libvirt_network.this.bridge
}
EOF
```

#### Step 2: Create the Storage Module

This module creates storage pools and volumes (middle layer).

```bash
cd /root/terraform-workspace
mkdir -p modules/storage
cd modules/storage
```

Create `modules/storage/variables.tf`:

```bash
cat <<EOF > variables.tf
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
EOF
```

Create `modules/storage/main.tf`:

```bash
cat <<EOF > main.tf
terraform {
  required_version = ">= 1.14"
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "~> 0.9"
    }
  }
}

resource "libvirt_pool" "this" {
  name = var.pool_name
  type = var.pool_type

  target = {
    path = var.pool_path
  }
}

resource "libvirt_volume" "volumes" {
  for_each = var.volumes

  name     = "${each.key}.${each.value.format}"
  pool     = libvirt_pool.this.name
  capacity = each.value.size_gb * 1073741824 # Convert GB to bytes

  target = {
    format = {
      type = each.value.format
    }
  }
}
EOF
```

Create `modules/storage/outputs.tf`:

```bash
cat <<EOF > outputs.tf
output "pool_id" {
  description = "Storage pool ID"
  value       = libvirt_pool.this.id
}

output "pool_name" {
  description = "Storage pool name"
  value       = libvirt_pool.this.name
}

output "volume_names" {
  description = "Map of volume names"
  value       = { for k, v in libvirt_volume.volumes : k => v.name }
}
EOF
```

#### Step 3: Create the Compute Module

This module creates VMs using storage volumes (middle layer).

```bash
cd /root/terraform-workspace
mkdir -p modules/compute
cd modules/compute
```

Create `modules/compute/variables.tf`:

```bash
cat <<EOF > variables.tf

variable "vms" {
  description = "Map of VMs to create"
  type = map(object({
    memory_mb   = number
    vcpu_count  = number
    volume_name = string
  }))
}

variable "network_id" {
  description = "Network ID to attach VMs to"
  type        = string
}

variable "autostart" {
  description = "Auto-start VMs"
  type        = bool
  default     = false
}
EOF
```

Create `modules/compute/main.tf`:

```bash
cat <<EOF > main.tf
terraform {
  required_version = ">= 1.14"
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "~> 0.9"
    }
  }
}

resource "libvirt_domain" "vms" {
  for_each = var.vms

  name      = each.key
  type      = "kvm"
  memory    = each.value.memory_mb
  vcpu      = each.value.vcpu_count
  autostart = var.autostart

  os = {
    type    = "hvm"
    arch    = "x86_64"
    machine = "pc"
  }

  devices = {
    disks = [{
      source = {
        volume = {
          pool   = "default"
          volume = each.value.volume_name
        }
      }
      target = {
        dev = "vda"
        bus = "virtio"
      }
    }]

    interfaces = [{
      network = {
        network = var.network_id
      }
      model = {
        type = "virtio"
      }
      wait_for_lease = true
    }]

    console = [{
      type = "pty"
      target = {
        type = "serial"
        port = 0
      }
    }]
  }
}
EOF
```

Create `modules/compute/outputs.tf`:

```bash
cat << EOF > outputs.tf
output "vm_ids" {
  description = "Map of VM IDs"
  value       = { for k, v in libvirt_domain.vms : k => v.id }
}

output "vm_names" {
  description = "Map of VM names"
  value       = { for k, v in libvirt_domain.vms : k => v.name }
}
EOF
```

#### Step 4: Create the App-Stack Module (Top Layer)

This module composes all three layers into a simple interface.

```bash
cd /root/terraform-workspace
mkdir -p modules/app-stack
cd modules/app-stack
```

Create `modules/app-stack/variables.tf`:

```bash
cat << EOF > variables.tf
variable "app_name" {
  description = "Application name"
  type        = string
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be dev, staging, or prod"
  }
}

variable "vms" {
  description = "Map of VMs to create"
  type = map(object({
    memory_mb  = number
    vcpu_count = number
    disk_gb    = number
  }))
}
EOF
```

Create `modules/app-stack/main.tf`:

```bash
cat << EOF > main.tf
terraform {
  required_version = ">= 1.14"
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "~> 0.8"
    }
  }
}

# Layer 1: Network
module "network" {
  source = "../network"

  network_name = "${var.app_name}-${var.environment}-network"
  network_mode = "nat"
  addresses    = ["192.168.200.0/24"]
  domain       = "${var.app_name}.${var.environment}.local"
}

# Layer 2: Storage
module "storage" {
  source = "../storage"

  pool_name = "${var.app_name}-${var.environment}-pool"
  pool_type = "dir"
  pool_path = "/var/lib/libvirt/images/${var.app_name}-${var.environment}"

  volumes = {
    for vm_name, vm_config in var.vms :
    vm_name => {
      size_gb = vm_config.disk_gb
      format  = "qcow2"
    }
  }
}

# Layer 3: Compute
module "compute" {
  source = "../compute"

  network_id = module.network.id
  autostart  = var.environment == "prod"

  vms = {
    for vm_name, vm_config in var.vms :
    "${var.app_name}-${var.environment}-${vm_name}" => {
      memory_mb   = vm_config.memory_mb
      vcpu_count  = vm_config.vcpu_count
      volume_name = module.storage.volume_names[vm_name]
    }
  }

  depends_on = [module.storage]
}
EOF
```

Create `modules/app-stack/outputs.tf`:

```bash
cat << EOF > outputs.tf
output "network_info" {
  description = "Network information"
  value = {
    id     = module.network.id
    name   = module.network.name
    bridge = module.network.bridge
  }
}

output "storage_info" {
  description = "Storage information"
  value = {
    pool_id   = module.storage.pool_id
    pool_name = module.storage.pool_name
  }
}

output "vm_info" {
  description = "VM information"
  value = {
    ids   = module.compute.vm_ids
    names = module.compute.vm_names
  }
}
EOF
```

#### Step 5: Use the App-Stack Module

Create a root module that uses the app-stack:

```bash
cd /root/terraform-workspace
```

Create `main.tf`:

```bash
cat << EOF > main.tf
terraform {
  required_version = ">= 1.14"
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "~> 0.9"
    }
  }
}

provider "libvirt" {
  uri = "qemu:///system"
}

# Simple interface - complex infrastructure!
module "my_app" {
  source = "./modules/app-stack"

  app_name    = "webapp"
  environment = "dev"

  vms = {
    web = {
      memory_mb  = 512
      vcpu_count = 1
      disk_gb    = 1
    }
    api = {
      memory_mb  = 512
      vcpu_count = 1
      disk_gb    = 1
    }
    db = {
      memory_mb  = 1024
      vcpu_count = 2
      disk_gb    = 2
    }
  }
}
EOF
```

Create `outputs.tf`:

```bash
cat << EOF > outputs.tf
output "app_stack" {
  description = "Complete application stack information"
  value       = module.my_app
}
EOF
```

#### Step 6: Test the Nested Modules

```bash
# Initialize
terraform init

# Validate
terraform validate

# Plan (see the nested module structure)
terraform plan

# Note: We won't apply to save time, but you can see the structure!
```

**Key Observations**:
- ✅ Simple top-level interface (just app_name, environment, vms)
- ✅ Complex infrastructure created automatically
- ✅ Each layer is reusable independently
- ✅ Clear separation of concerns

---

## Section 2: Conditional Resources 🔀

### Recap from TF-100: count and for_each

**You learned `count` and `for_each` to create multiple resources:**
```hcl
# Simplified example showing count concept
resource "libvirt_domain" "vm" {
  count = 3  # Create 3 VMs
  name  = "vm-${count.index}"
  # ... other required attributes (type, os, devices, etc.)
}
```

### New Concept: Conditional Creation

What if you want to create a resource **only sometimes**?

**The Trick:**
Use `count` with 0 or 1:
```hcl
# Simplified example showing conditional creation
resource "libvirt_domain" "monitoring" {
  count = var.enable_monitoring ? 1 : 0  # Create if enabled, skip if not

  name = "monitoring-server"
  # ... other required attributes (type, os, devices, etc.)
}
```

**How It Works:**
- `var.enable_monitoring = true` → `count = 1` → Resource created
- `var.enable_monitoring = false` → `count = 0` → Resource skipped

**Real-World Example:**
```hcl
# Monitoring only in production
resource "local_file" "monitoring_config" {
  count = var.environment == "prod" ? 1 : 0

  filename = "monitoring.conf"
  content  = "..."
}

# Backup only for databases
resource "local_file" "backup_script" {
  count = var.resource_type == "database" ? 1 : 0

  filename = "backup.sh"
  content  = "..."
}
```

**Why This Matters:**
- ✅ Same module works for different environments
- ✅ No need for separate modules for prod vs dev
- ✅ Feature flags built into infrastructure
- ✅ Cost optimization (skip expensive resources in dev)

**Common Patterns:**
```hcl
# Pattern 1: Environment-based
count = var.environment == "prod" ? 1 : 0

# Pattern 2: Feature flag
count = var.enable_feature ? 1 : 0

# Pattern 3: Size-based
count = var.size == "large" ? 3 : 1

# Pattern 4: Multiple conditions
count = var.environment == "prod" && var.enable_monitoring ? 1 : 0
```

<details>
<summary>🔍 count vs for_each for Conditionals</summary>

**Use count for conditionals:**
```hcl
count = var.enabled ? 1 : 0  # ✅ Simple on/off
```

**Use for_each for conditionals:**
```hcl
for_each = var.enabled ? toset(["item"]) : toset([])  # ❌ Overly complex
```

**Why count is better:**
- Simpler syntax
- Clearer intent
- Easier to read

**When to use for_each:**
When you're creating multiple different resources, not just enabling/disabling one.

</details>

---


### Understanding Conditional Resources

**Conditional resources** allow you to create resources based on variables, enabling flexible modules that adapt to different scenarios.

**Use Cases**:
- Create monitoring only in production
- Optional backup configuration
- Environment-specific resources
- Feature flags

### Conditional Patterns

**Pattern 1: Single Resource Conditional (count)**

```hcl
resource "libvirt_network" "this" {
  count = var.create_network ? 1 : 0
  # ...
}
```

**Pattern 2: Multiple Resources Conditional**

```hcl
# Simplified example - full implementation in Lab 4
resource "libvirt_domain" "canary" {
  count = var.enable_canary ? var.canary_count : 0
  # ... other required attributes
}
```

**Pattern 3: Environment-Based Conditional**

```hcl
resource "null_resource" "monitoring" {
  count = var.environment == "production" ? 1 : 0
  # ...
}
```

### Lab 2: Conditional VM Module

Let's create a module that conditionally creates resources based on environment and features.

```bash
mkdir -p modules/conditional-vm
```

Create `modules/conditional-vm/variables.tf`:

```hcl
variable "app_name" {
  description = "Application name"
  type        = string
}

variable "environment" {
  description = "Environment (dev, staging, prod)"
  type        = string
}

variable "create_network" {
  description = "Create a new network (false = use existing)"
  type        = bool
  default     = true
}

variable "existing_network_id" {
  description = "ID (UUID) of existing network (if create_network = false)"
  type        = string
  default     = ""
}

variable "existing_network_name" {
  description = "Name of existing network (if create_network = false)"
  type        = string
  default     = ""
}

variable "vms" {
  description = "Map of VMs to create"
  type = map(object({
    memory_mb  = number
    vcpu_count = number
  }))
}

variable "enable_monitoring" {
  description = "Enable monitoring resources"
  type        = bool
  default     = false
}

variable "enable_backup" {
  description = "Enable backup configuration"
  type        = bool
  default     = false
}
```

Create `modules/conditional-vm/main.tf`:

```hcl
terraform {
  required_version = ">= 1.14"
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "~> 0.9"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.7"
    }
  }
}

locals {
  # Network ID (UUID) for output and reference
  network_id = var.create_network ? libvirt_network.this[0].id : var.existing_network_id
  
  # Network name for device configuration
  network_name = var.create_network ? libvirt_network.this[0].name : var.existing_network_name

  # Auto-start only in production
  autostart = var.environment == "prod"

  # Monitoring enabled in staging and prod
  monitoring_enabled = var.enable_monitoring && contains(["staging", "prod"], var.environment)

  # Backup enabled only in prod
  backup_enabled = var.enable_backup && var.environment == "prod"
}

# Conditional network creation
resource "libvirt_network" "this" {
  count = var.create_network ? 1 : 0

  name      = "${var.app_name}-${var.environment}-network"
  autostart = true

  # Note: In libvirt provider 0.9+, networks are automatically NAT-enabled with DHCP
}

# Create volumes for VMs
resource "libvirt_volume" "vm_disks" {
  for_each = var.vms

  name     = "${var.app_name}-${var.environment}-${each.key}.qcow2"
  pool     = "default"
  capacity = 1073741824  # 1GB

  target = {
    format = {
      type = "qcow2"
    }
  }
}

# Create VMs
resource "libvirt_domain" "vms" {
  for_each = var.vms

  name      = "${var.app_name}-${var.environment}-${each.key}"
  type      = "kvm"
  memory    = each.value.memory_mb
  vcpu      = each.value.vcpu_count
  autostart = local.autostart

  os = {
    type = "hvm"
  }

  devices = {
    disks = [{
      source = {
        volume = {
          pool   = "default"
          volume = libvirt_volume.vm_disks[each.key].name
        }
      }
      target = {
        dev = "vda"
        bus = "virtio"
      }
    }]

    interfaces = [{
      network = {
        network = local.network_name
      }
      model = {
        type = "virtio"
      }
      wait_for_lease = true
    }]

    console = [{
      type = "pty"
      target = {
        type = "serial"
        port = 0
      }
    }]
  }
}

# Conditional monitoring configuration
resource "local_file" "monitoring_config" {
  count = local.monitoring_enabled ? 1 : 0

  filename = "/tmp/${var.app_name}-${var.environment}-monitoring.conf"
  content  = <<-EOT
    # Monitoring Configuration
    # Environment: ${var.environment}
    # VMs: ${join(", ", keys(var.vms))}

    monitoring_enabled = true
    check_interval     = ${var.environment == "prod" ? "30s" : "60s"}
    alert_threshold    = ${var.environment == "prod" ? "90" : "95"}
  EOT
}

# Conditional backup configuration
resource "local_file" "backup_config" {
  count = local.backup_enabled ? 1 : 0

  filename = "/tmp/${var.app_name}-${var.environment}-backup.conf"
  content  = <<-EOT
    # Backup Configuration
    # Environment: ${var.environment}

    backup_enabled  = true
    backup_schedule = "0 2 * * *"  # Daily at 2 AM
    retention_days  = 30
    vms_to_backup   = [${join(", ", [for k, v in var.vms : "\"${k}\""])}]
  EOT
}
```

Create `modules/conditional-vm/outputs.tf`:

```hcl
output "network_id" {
  description = "Network ID (created or existing)"
  value       = local.network_id
}

output "vm_ids" {
  description = "Map of VM IDs"
  value       = { for k, v in libvirt_domain.vms : k => v.id }
}

output "monitoring_enabled" {
  description = "Whether monitoring is enabled"
  value       = local.monitoring_enabled
}

output "backup_enabled" {
  description = "Whether backup is enabled"
  value       = local.backup_enabled
}

output "autostart_enabled" {
  description = "Whether VMs auto-start"
  value       = local.autostart
}
```

### Test Conditional Module

Update your `main.tf`:

```hcl
# Development environment - minimal features
module "dev_app" {
  source = "./modules/conditional-vm"

  app_name        = "myapp"
  environment     = "dev"
  create_network  = true
  enable_monitoring = false
  enable_backup   = false

  vms = {
    web = { memory_mb = 512, vcpu_count = 1 }
  }
}

# Production environment - all features
module "prod_app" {
  source = "./modules/conditional-vm"

  app_name        = "myapp"
  environment     = "prod"
  create_network  = true
  enable_monitoring = true
  enable_backup   = true

  vms = {
    web-01 = { memory_mb = 2048, vcpu_count = 2 }
    web-02 = { memory_mb = 2048, vcpu_count = 2 }
    api-01 = { memory_mb = 4096, vcpu_count = 4 }
  }
}
```

```bash
terraform init
terraform plan
```

**Observe**:
- ✅ Dev: No monitoring, no backup, no autostart
- ✅ Prod: Monitoring enabled, backup enabled, autostart enabled
- ✅ Same module, different behavior based on environment

---

## Section 3: For_Each Patterns 🔄

### Understanding For_Each

**for_each** creates multiple resources with stable addresses based on keys, not indices.

**Why for_each > count**:

**With count** (index-based):
```
Resources: vm[0], vm[1], vm[2]
Remove vm[1] → vm[2] becomes vm[1] (DESTRUCTIVE!)
```

**With for_each** (key-based):
```
Resources: vm["web-01"], vm["web-02"], vm["db-01"]
Remove web-02 → Others unchanged (SAFE!)
```

### For_Each Patterns

**Pattern 1: Map-Based For_Each**

```hcl
# Simplified example showing for_each with map
variable "vms" {
  type = map(object({
    memory_mb  = number
    vcpu_count = number
  }))
}

resource "libvirt_domain" "vm" {
  for_each = var.vms

  name   = each.key
  memory = each.value.memory_mb
  vcpu   = each.value.vcpu_count
  # ... other required attributes (type, os, devices, etc.)
}
```

**Pattern 2: Set-Based For_Each**

```hcl
# Simplified example showing for_each with set
variable "vm_names" {
  type = set(string)
}

resource "libvirt_domain" "vm" {
  for_each = var.vm_names

  name   = each.key
  memory = 512
  vcpu   = 1
  # ... other required attributes (type, os, devices, etc.)
}
```

**Pattern 3: Conditional For_Each**

```hcl
# Simplified example showing conditional for_each
resource "libvirt_domain" "vm" {
  for_each = var.enable_vms ? var.vms : {}
  # ... other required attributes
}
```

### Lab 3: Advanced For_Each Patterns

You've already seen for_each in action! Let's explore more advanced patterns.

**Note**: These are reference examples showing advanced for_each patterns. You can create `for_each_examples.tf` in your working directory to experiment with these patterns, but you'll need to define the referenced variables first (or adapt the examples to use existing variables from your modules).

Create `for_each_examples.tf` (optional reference file):

```hcl
# NOTE: These examples reference variables that don't exist in the root module.
# To use these patterns, either:
# 1. Add these examples to modules/conditional-vm/main.tf (where var.vms exists)
# 2. Define the variables in your root module first
# 3. Use these as reference patterns to understand for_each capabilities

# Example 1: For_each with filtering
locals {
  # Only create VMs with memory >= 1024
  large_vms = {
    for k, v in var.vms :
    k => v
    if v.memory_mb >= 1024
  }
}

# Example 2: For_each with transformation
locals {
  # Transform VM names to include environment
  env_vms = {
    for k, v in var.vms :
    "${var.environment}-${k}" => v
  }
}

# Example 3: For_each with nested objects
variable "vm_groups" {
  type = map(object({
    count      = number
    memory_mb  = number
    vcpu_count = number
  }))
  default = {
    web = { count = 2, memory_mb = 2048, vcpu_count = 2 }
    api = { count = 3, memory_mb = 4096, vcpu_count = 4 }
  }
}

locals {
  # Flatten groups into individual VMs
  flattened_vms = merge([
    for group_name, group_config in var.vm_groups : {
      for i in range(group_config.count) :
      "${group_name}-${i + 1}" => {
        memory_mb  = group_config.memory_mb
        vcpu_count = group_config.vcpu_count
      }
    }
  ]...)
}

# Result: web-1, web-2, api-1, api-2, api-3
```

---

## Section 4: Canary Deployment Pattern 🐤

### Understanding Canary Deployments

**Canary deployment** gradually rolls out a new version to a subset of instances, monitoring for issues before full rollout.

**Deployment Phases**:
1. **Phase 1**: 100% stable, 0% canary (baseline)
2. **Phase 2**: 90% stable, 10% canary (monitor)
3. **Phase 3**: 50% stable, 50% canary (monitor)
4. **Phase 4**: 0% stable, 100% new version (complete)

**Benefits**:
- ✅ Reduced risk (limited exposure)
- ✅ Early issue detection
- ✅ Easy rollback (adjust percentage)
- ✅ Gradual validation

### Lab 4: Implement Canary Deployment

```bash
mkdir -p modules/canary-deployment
```

Create `modules/canary-deployment/variables.tf`:

```hcl
variable "app_name" {
  description = "Application name"
  type        = string
}

variable "total_instances" {
  description = "Total number of instances"
  type        = number

  validation {
    condition     = var.total_instances >= 1 && var.total_instances <= 10
    error_message = "total_instances must be between 1 and 10"
  }
}

variable "enable_canary" {
  description = "Enable canary deployment"
  type        = bool
  default     = false
}

variable "canary_percentage" {
  description = "Percentage of instances for canary (0-100)"
  type        = number
  default     = 0

  validation {
    condition     = var.canary_percentage >= 0 && var.canary_percentage <= 100
    error_message = "canary_percentage must be between 0 and 100"
  }
}

variable "stable_version" {
  description = "Stable version identifier"
  type        = string
  default     = "v1.0.0"
}

variable "canary_version" {
  description = "Canary version identifier"
  type        = string
  default     = "v1.1.0"
}

variable "network_id" {
  description = "Network ID for VMs"
  type        = string
}

variable "memory_mb" {
  description = "Memory per instance in MB"
  type        = number
  default     = 512
}

variable "vcpu_count" {
  description = "vCPU count per instance"
  type        = number
  default     = 1
}
```

Create `modules/canary-deployment/main.tf`:

```hcl
terraform {
  required_version = ">= 1.14"
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "~> 0.8"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.7"
    }
  }
}

locals {
  # Calculate instance counts
  stable_count = var.enable_canary ? floor(var.total_instances * (1 - var.canary_percentage / 100)) : var.total_instances
  canary_count = var.enable_canary ? ceil(var.total_instances * (var.canary_percentage / 100)) : 0

  # Verify counts add up
  total_check = local.stable_count + local.canary_count
}

# Stable version volumes
resource "libvirt_volume" "stable" {
  count = local.stable_count

  name     = "${var.app_name}-stable-${count.index + 1}.qcow2"
  pool     = "default"
  capacity = 1073741824  # 1GB
  
  target = {
    format = {
      type = "qcow2"
    }
  }
}

# Canary version volumes
resource "libvirt_volume" "canary" {
  count = local.canary_count

  name     = "${var.app_name}-canary-${count.index + 1}.qcow2"
  pool     = "default"
  capacity = 1073741824  # 1GB
  
  target = {
    format = {
      type = "qcow2"
    }
  }
}

# Stable version instances
resource "libvirt_domain" "stable" {
  count = local.stable_count

  name      = "${var.app_name}-stable-${count.index + 1}"
  type      = "kvm"
  memory    = var.memory_mb
  vcpu      = var.vcpu_count
  autostart = false

  os = {
    type = "hvm"
  }

  devices = {
    disks = [{
      source = {
        volume = {
          pool   = "default"
          volume = libvirt_volume.stable[count.index].name
        }
      }
      target = {
        dev = "vda"
        bus = "virtio"
      }
    }]

    interfaces = [{
      network = {
        uuid = var.network_id
      }
      model = {
        type = "virtio"
      }
      wait_for_lease = true
    }]

    console = [{
      type = "pty"
      target = {
        type = "serial"
        port = 0
      }
    }]
  }
}

# Canary version instances
resource "libvirt_domain" "canary" {
  count = local.canary_count

  name      = "${var.app_name}-canary-${count.index + 1}"
  type      = "kvm"
  memory    = var.memory_mb
  vcpu      = var.vcpu_count
  autostart = false

  os = {
    type = "hvm"
  }

  devices = {
    disks = [{
      source = {
        volume = {
          pool   = "default"
          volume = libvirt_volume.canary[count.index].name
        }
      }
      target = {
        dev = "vda"
        bus = "virtio"
      }
    }]

    interfaces = [{
      network = {
        uuid = var.network_id
      }
      model = {
        type = "virtio"
      }
      wait_for_lease = true
    }]

    console = [{
      type = "pty"
      target = {
        type = "serial"
        port = 0
      }
    }]
  }
}

# Deployment status file
resource "local_file" "deployment_status" {
  filename = "/tmp/${var.app_name}-deployment-status.json"
  content = jsonencode({
    app_name          = var.app_name
    total_instances   = var.total_instances
    stable_count      = local.stable_count
    canary_count      = local.canary_count
    stable_version    = var.stable_version
    canary_version    = var.canary_version
    canary_percentage = var.canary_percentage
    canary_enabled    = var.enable_canary
    timestamp         = timestamp()
  })
}
```

Create `modules/canary-deployment/outputs.tf`:

```hcl
output "deployment_summary" {
  description = "Deployment summary"
  value = {
    total_instances   = var.total_instances
    stable_count      = local.stable_count
    canary_count      = local.canary_count
    stable_version    = var.stable_version
    canary_version    = var.canary_version
    canary_percentage = var.canary_percentage
  }
}

output "stable_vm_ids" {
  description = "Stable version VM IDs"
  value       = [for vm in libvirt_domain.stable : vm.id]
}

output "canary_vm_ids" {
  description = "Canary version VM IDs"
  value       = [for vm in libvirt_domain.canary : vm.id]
}

output "stable_vm_names" {
  description = "Stable version VM names"
  value       = [for vm in libvirt_domain.stable : vm.name]
}

output "canary_vm_names" {
  description = "Canary version VM names"
  value       = [for vm in libvirt_domain.canary : vm.name]
}
```

### Test Canary Deployment

Update `main.tf` to test canary deployment:

```hcl
# First, create a network for the canary deployment
module "canary_network" {
  source = "./modules/network"

  network_name = "canary-network"
  network_mode = "nat"
  addresses    = ["192.168.220.0/24"]
}

# Phase 1: 100% stable (baseline)
module "app_phase1" {
  source = "./modules/canary-deployment"

  app_name       = "myapp"
  total_instances = 5
  enable_canary   = false
  stable_version  = "v1.0.0"
  network_id      = module.canary_network.id
}

# Phase 2: 90% stable, 10% canary
# module "app_phase2" {
#   source = "./modules/canary-deployment"
#
#   app_name          = "myapp"
#   total_instances   = 5
#   enable_canary     = true
#   canary_percentage = 10
#   stable_version    = "v1.0.0"
#   canary_version    = "v1.1.0"
#   network_id        = module.canary_network.id
# }

# Phase 3: 50% stable, 50% canary
# module "app_phase3" {
#   source = "./modules/canary-deployment"
#
#   app_name          = "myapp"
#   total_instances   = 5
#   enable_canary     = true
#   canary_percentage = 50
#   stable_version    = "v1.0.0"
#   canary_version    = "v1.1.0"
#   network_id        = module.canary_network.id
# }
```

```bash
terraform init
terraform plan

# Observe the output:
# Phase 1: 5 stable, 0 canary
# Phase 2: 4 stable, 1 canary (10%)
# Phase 3: 2 stable, 3 canary (50%)
```

**Rollback Strategy**:
If issues detected, simply reduce `canary_percentage` or set `enable_canary = false`.

---

## 🎯 Challenge Tasks

Complete these tasks to master advanced module patterns:

### Task 1: Nested Modules ✅
- [ ] Create all four modules (network, storage, compute, app-stack)
- [ ] Test the app-stack module with different VM configurations
- [ ] Verify the simple top-level interface

### Task 2: Conditional Resources ✅
- [ ] Create the conditional-vm module
- [ ] Test with dev environment (minimal features)
- [ ] Test with prod environment (all features)
- [ ] Verify monitoring and backup configs are created correctly

### Task 3: For_Each Patterns ✅
- [ ] Use for_each in at least one module
- [ ] Test adding/removing VMs by key
- [ ] Verify stable resource addresses

### Task 4: Canary Deployment ✅
- [ ] Create the canary-deployment module
- [ ] Test Phase 1 (100% stable)
- [ ] Plan Phase 2 (10% canary)
- [ ] Understand the rollback strategy

---

## 📝 Key Takeaways

### Nested Modules
- ✅ Compose complex infrastructure from simple layers
- ✅ Each layer has single responsibility
- ✅ Simple top-level interface
- ✅ Reusable components

### Conditional Resources
- ✅ Use `count` for single resource conditionals
- ✅ Adapt behavior based on environment
- ✅ Feature flags for optional resources
- ✅ Environment-specific configuration

### For_Each Patterns
- ✅ Stable resource addresses (key-based)
- ✅ Safe add/remove operations
- ✅ Better than count for multiple resources
- ✅ Works with maps and sets

### Canary Deployments
- ✅ Gradual rollout reduces risk
- ✅ Easy rollback by adjusting percentage
- ✅ Monitor at each phase
- ✅ Clear separation of versions

---

## 🚀 Next Steps

You've mastered advanced module patterns! In the next challenge, you'll learn:

- **YAML-Driven Configuration** - Drive infrastructure from YAML files
- **Dynamic Resource Creation** - Create resources from data
- **Template-Based Infrastructure** - Use templates for flexibility

Great work! 🎉

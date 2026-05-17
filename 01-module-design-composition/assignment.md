---
slug: module-design-composition
id: ve0mggnklsj8
type: challenge
title: 'Challenge 1: Module Design & Composition'
teaser: Master professional module design, composition patterns, and refactoring techniques
notes:
- type: text
  contents: "# Challenge 1: Module Design & Composition\n\n## What You'll Learn\n\nIn
    this challenge, you'll master the fundamentals of Terraform module design:\n\n-
    ✅ Module structure and design principles\n- ✅ Creating reusable modules\n- ✅ Module
    composition patterns\n- ✅ Refactoring with `moved` blocks\n- ✅ Dynamic module
    sources (Terraform 1.15+)\n\n## Why This Matters\n\nModules are the foundation
    of scalable, maintainable Terraform code. They enable:\n- **Reusability**: Write
    once, use everywhere\n- **Consistency**: Standardized infrastructure patterns\n-
    **Collaboration**: Share modules across teams\n- **Maintainability**: Easier to
    update and test\n\n## Time Estimate\n\n⏱️ **90 minutes** to complete all sections\n\nReady
    to build professional Terraform modules? Let's begin! \U0001F680\n"
- type: text
  contents: |
    # Module Design Principles

    Before we start building, let's understand the key principles:

    ## 1. Single Responsibility
    Each module should do **one thing well**. Don't create a "kitchen sink" module.

    ✅ Good: `network` module creates VPC, subnets, routing
    ❌ Bad: `infrastructure` module creates network, VMs, databases, monitoring

    ## 2. Composability
    Modules should work together seamlessly. Outputs from one module become inputs to another.

    ```hcl
    module "network" { ... }

    module "vm" {
      network_id = module.network.network_id  # Composition!
    }
    ```

    ## 3. Encapsulation
    Hide complexity inside modules. Users shouldn't need to know implementation details.

    ## 4. Flexibility
    Use variables and optional attributes to support different use cases.

    ## 5. Documentation
    Clear README, examples, and well-named variables are essential.

    Let's apply these principles! →
tabs:
- id: cgizfjcmnoyp
  title: Terminal
  type: terminal
  hostname: workstation
  workdir: /root/terraform-workspace
- id: d2yitwkintz5
  title: Code Editor
  type: code
  hostname: workstation
  path: /root/terraform-workspace
difficulty: basic
timelimit: 5400
enhanced_loading: null
---

# Challenge 1: Module Design & Composition

Welcome to Challenge 1! In this comprehensive challenge, you'll learn everything about Terraform module design and composition.

## 📋 Challenge Overview

This challenge is organized into **5 sections**:

1. **Module Fundamentals** - Understanding module structure
2. **Creating Your First Module** - Build a simple configuration module
3. **Building Complex Modules** - Create network and VM modules with Libvirt
4. **Module Composition** - Compose modules together
5. **Refactoring with `moved` Blocks** - Safe code refactoring

Each section builds on the previous one, so complete them in order.

---

## Section 1: Module Fundamentals

### Quick Recap from TF-100

**Remember when you created `main.tf`, `variables.tf`, and `outputs.tf` in one directory?**

That was actually a module! Specifically, the **root module**.

**The Revelation:**
Every Terraform configuration is a module. What you're learning now is how to create **reusable** modules that can be called multiple times.

**Think of it like:**
- **TF-100**: You wrote a program that runs once
- **TF-200**: You're learning to write functions that can be called many times

**Example:**
```hcl
# TF-100 style (root module only)
resource "libvirt_network" "web" {
  name = "web-network"
}
resource "libvirt_domain" "web" {
  name = "web-server"
}

# TF-200 style (using child modules)
module "web_tier" {
  source = "./modules/web"  # Reusable!

  environment = "dev"
}
```

**Why This Matters:**
Instead of copying/pasting code for each environment, you create it once and reuse it.

---


### What Are Terraform Modules?

A **module** is a container for multiple resources that are used together. Every Terraform configuration has at least one module, called the **root module**, which consists of the resources defined in the `.tf` files in the main working directory.

### Module Types

**Root Module**:
- The directory where you run `terraform apply`
- Contains your main configuration
- Calls other modules

**Child Modules**:
- Reusable components called by the root module
- Located in subdirectories or external sources
- Encapsulate specific functionality

### Standard Module Structure

A well-designed module follows this structure:

```
modules/my-module/
├── main.tf          # Primary resource definitions
├── variables.tf     # Input variables
├── outputs.tf       # Output values
├── versions.tf      # Provider version constraints
├── README.md        # Documentation
└── examples/        # Usage examples
    └── basic/
        └── main.tf
```

### File Purposes

| File | Purpose |
|------|---------|
| `main.tf` | Contains the primary resource definitions |
| `variables.tf` | Declares all input variables |
| `outputs.tf` | Declares all output values |
| `versions.tf` | Specifies Terraform and provider version requirements |
| `README.md` | Documents the module's purpose, inputs, outputs, and usage |

### Module Design Principles

#### 1. Single Responsibility
Each module should have a clear, focused purpose:

```hcl
# ✅ Good: Focused module
module "network" {
  source = "./modules/network"
  # Creates VPC, subnets, routing
}

# ❌ Bad: Does too much
module "everything" {
  source = "./modules/everything"
  # Creates network, VMs, databases, monitoring, logging...
}
```

#### 2. Composability

**What is Composition?**
Composition means "building complex things from simple parts" - like LEGO blocks.

**In Terraform:**
- Each module is a LEGO block
- Modules connect through outputs and inputs
- You build complex infrastructure by connecting simple modules

**Real-World Analogy:**
Think of building a house:
- **Foundation module** → outputs: foundation_id
- **Walls module** → inputs: foundation_id (needs foundation first)
- **Roof module** → inputs: walls_id (needs walls first)

**In Code:**
```hcl
# Step 1: Create network (foundation)
module "network" {
  source = "./modules/network"
}

# Step 2: Create VM (walls) - uses network
module "vm" {
  source     = "./modules/vm"
  network_id = module.network.network_id  # ← Composition!
}
```

**The Magic:**
The VM module doesn't know HOW the network was created. It just needs a network_id. This is composition - modules work together without being tightly coupled.

**Why This Matters:**
- ✅ Swap network module without changing VM module
- ✅ Test modules independently
- ✅ Reuse modules in different combinations

<details>
<summary>🔍 Advanced: Composition vs Inheritance</summary>

**Composition** (what Terraform uses):
- Modules are independent
- Connected through inputs/outputs
- Flexible and testable

**Inheritance** (what Terraform doesn't use):
- Child inherits from parent
- Tightly coupled
- Hard to change

Terraform chose composition because it's more flexible for infrastructure.

</details>

#### 3. Encapsulation

**What is Encapsulation?**
Hiding complexity behind a simple interface.

**The Problem Without Encapsulation:**
```hcl
# User has to know ALL the details
resource "libvirt_volume" "db_disk" {
  name     = "db-disk"
  pool     = "default"
  capacity = 10737418240
  # ... 10 more attributes ...
}
resource "libvirt_volume" "db_backup" {
  name = "db-backup"
  # ... more config ...
}
resource "libvirt_pool" "db_pool" {
  # ... more config ...
}
resource "libvirt_domain" "db" {
  # ... 30 lines of config ...
}
resource "local_file" "db_backup_script" {
  # ... more config ...
}
resource "local_file" "db_monitoring" {
  # ... more config ...
}
# ... 20 more resources ...
```

**With Encapsulation:**
```hcl
# User only sees what matters
module "database" {
  source = "./modules/database"

  name = "mydb"
  size = "small"  # Module figures out the rest!
}
```

**Real-World Analogy:**
- **Without encapsulation**: Like driving a car by manually controlling fuel injection, spark timing, transmission gears, brake pressure...
- **With encapsulation**: Like driving a car with a steering wheel, gas pedal, and brake pedal

**Benefits:**
- ✅ Users don't need to understand internals
- ✅ You can change implementation without breaking users
- ✅ Reduces errors (fewer things to configure)
- ✅ Makes code readable

**Example from TF-100:**
Remember creating VMs in Challenge 3? You had to specify:
- Volume configuration
- Network configuration
- Cloud-init setup
- Console configuration
- Memory, CPU, etc.

With a module, users just say "I want a web server" and the module handles the details.

<details>
<summary>🔍 What to Encapsulate vs Expose</summary>

**Encapsulate (hide):**
- Implementation details
- Complex calculations
- Resource dependencies
- Default values

**Expose (make configurable):**
- Environment-specific values
- Resource names
- Sizes/capacities
- Feature flags

**Rule of Thumb:**
If users need to change it per environment, expose it. If it's always the same, encapsulate it.

</details>

#### 4. Flexibility
Use variables and optional attributes:

```hcl
variable "enable_monitoring" {
  description = "Enable monitoring for resources"
  type        = bool
  default     = true  # Sensible default
}

variable "custom_tags" {
  description = "Additional tags to apply"
  type        = map(string)
  default     = {}  # Optional
}
```

#### 5. Documentation
Every module needs clear documentation:

```markdown
# Network Module

Creates a virtual network with subnets.

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| name | Network name | string | n/a | yes |
| cidr | Network CIDR | string | "10.0.0.0/16" | no |

## Outputs

| Name | Description |
|------|-------------|
| network_id | ID of the created network |
```

---

## Section 2: Creating Your First Module

Let's create a simple module that manages application configuration files.

### Step 1: Create Module Directory Structure

Navigate to your workspace and create the module structure:

```bash
cd /root/terraform-workspace
mkdir -p modules/app-config
cd modules/app-config
```

### Step 2: Create variables.tf

Create the input variables for the module:

```bash
cat > variables.tf << 'EOF'
# modules/app-config/variables.tf

variable "app_name" {
  description = "Name of the application"
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{1,30}[a-z0-9]$", var.app_name))
    error_message = "app_name must be 3-32 lowercase alphanumeric characters or hyphens."
  }
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string

  validation {
    condition     = contains(["dev", "staging", "prod"], var.environment)
    error_message = "environment must be dev, staging, or prod."
  }
}

variable "port" {
  description = "Application port number"
  type        = number
  default     = 8080

  validation {
    condition     = var.port >= 1024 && var.port <= 65535
    error_message = "port must be between 1024 and 65535."
  }
}

variable "log_level" {
  description = "Logging level"
  type        = string
  default     = "info"

  validation {
    condition     = contains(["debug", "info", "warn", "error"], var.log_level)
    error_message = "log_level must be debug, info, warn, or error."
  }
}

variable "debug_mode" {
  description = "Enable debug mode"
  type        = bool
  default     = false
}

variable "base_dir" {
  description = "Base directory for configuration files"
  type        = string
  default     = "/tmp/configs"
}

variable "tags" {
  description = "Tags to apply to resources"
  type        = map(string)
  default     = {}
}

variable "env_overrides" {
  description = "Environment-specific configuration overrides"
  type        = map(string)
  default     = {}
}
EOF
```

**Key Points**:
- ✅ Clear descriptions for each variable
- ✅ Appropriate types (string, number, bool, map)
- ✅ Sensible defaults where appropriate
- ✅ Input validation to catch errors early

### Step 3: Create main.tf

Create the main resource definitions:

```bash
cat > main.tf << 'EOF'
# modules/app-config/main.tf

terraform {
  required_version = ">= 1.14"
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.7"
    }
  }
}

locals {
  # Build the full output directory path
  output_dir = "${var.base_dir}/${var.app_name}"

  # Merge caller-supplied tags with module-managed tags
  all_tags = merge(var.tags, {
    Module      = "app-config"
    AppName     = var.app_name
    Environment = var.environment
  })
}

# Main application config file
resource "local_file" "app_config" {
  filename        = "${local.output_dir}/app.conf"
  file_permission = "0644"
  content         = <<-EOT
    # Application Configuration
    # Managed by Terraform module: app-config
    # DO NOT EDIT MANUALLY

    app_name    = "${var.app_name}"
    environment = "${var.environment}"
    port        = ${var.port}
    log_level   = "${var.log_level}"
    debug       = ${var.debug_mode}
  EOT
}

# Environment-specific overrides file
resource "local_file" "env_overrides" {
  filename        = "${local.output_dir}/${var.environment}.conf"
  file_permission = "0644"
  content         = <<-EOT
    # Environment Overrides: ${var.environment}
    # Generated by Terraform module: app-config

    ${join("\n", [for k, v in var.env_overrides : "${k} = ${v}"])}
  EOT
}

# Tags/metadata file
resource "local_file" "metadata" {
  filename        = "${local.output_dir}/metadata.json"
  file_permission = "0644"
  content         = jsonencode(local.all_tags)
}
EOF
```

**Key Points**:
- ✅ Uses `locals` to compute derived values
- ✅ Creates multiple related resources
- ✅ Uses string interpolation and functions
- ✅ Merges user tags with module tags

### Step 4: Create outputs.tf

Define what the module exposes:

```bash
cat > outputs.tf << 'EOF'
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
EOF
```

**Key Points**:
- ✅ Clear descriptions
- ✅ Exposes useful information for composition
- ✅ Returns both simple values and complex objects

### Step 5: Create README.md

Document your module:

````bash
cat > README.md << 'EOF'
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
EOF
````

### Step 6: Test the Module

Create a root module to test it:

```bash
cd /root/terraform-workspace
cat > main.tf << 'EOF'
# Root module - testing app-config module

terraform {
  required_version = ">= 1.14"
  required_providers {
    local = {
      source  = "hashicorp/local"
      version = "~> 2.7"
    }
  }
}

# Development environment
module "dev_config" {
  source = "./modules/app-config"

  app_name    = "my-app"
  environment = "dev"
  port        = 8080
  log_level   = "debug"
  debug_mode  = true

  tags = {
    Team    = "platform"
    Project = "demo"
  }

  env_overrides = {
    cache_enabled = "true"
    max_connections = "100"
  }
}

# Staging environment
module "staging_config" {
  source = "./modules/app-config"

  app_name    = "my-app"
  environment = "staging"
  port        = 8081
  log_level   = "info"

  tags = {
    Team    = "platform"
    Project = "demo"
  }
}

# Production environment
module "prod_config" {
  source = "./modules/app-config"

  app_name    = "my-app"
  environment = "prod"
  port        = 8443
  log_level   = "warn"

  tags = {
    Team    = "platform"
    Project = "demo"
  }

  env_overrides = {
    cache_enabled = "true"
    max_connections = "500"
  }
}
EOF
```

Now test it:

```bash
terraform init
terraform plan
terraform apply -auto-approve
```

Verify the created files:

```bash
tree /tmp/configs/
cat /tmp/configs/my-app/app.conf
cat /tmp/configs/my-app/dev.conf
cat /tmp/configs/my-app/metadata.json
```

**Expected Output**:
```
/tmp/configs/
└── my-app/
    ├── app.conf
    ├── dev.conf
    ├── staging.conf
    ├── prod.conf
    └── metadata.json
```

### Key Takeaways - Section 2

✅ **Module Structure**: Standard files (main.tf, variables.tf, outputs.tf)
✅ **Input Validation**: Catch errors early with validation blocks
✅ **Locals**: Compute derived values
✅ **Outputs**: Expose information for composition
✅ **Documentation**: README is essential
✅ **Testing**: Always test your modules

---

## Section 3: Building Complex Modules with Libvirt

Now let's build more realistic modules that create actual infrastructure using Libvirt.

### Module 1: Network Module

Create a module that manages Libvirt networks:

```bash
cd /root/terraform-workspace
mkdir -p modules/libvirt-network
cd modules/libvirt-network
```

**Create variables.tf**:

```bash
cat > variables.tf << 'EOF'
# modules/libvirt-network/variables.tf

variable "name" {
  description = "Name of the network"
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{1,30}[a-z0-9]$", var.name))
    error_message = "name must be 3-32 lowercase alphanumeric characters or hyphens."
  }
}

variable "mode" {
  description = "Network mode (nat, route, bridge)"
  type        = string
  default     = "nat"

  validation {
    condition     = contains(["nat", "route", "bridge"], var.mode)
    error_message = "mode must be nat, route, or bridge."
  }
}

variable "domain" {
  description = "DNS domain for the network"
  type        = string
  default     = "local"
}

variable "addresses" {
  description = "List of IP address ranges for the network"
  type        = list(string)
  default     = ["192.168.100.0/24"]

  validation {
    condition     = length(var.addresses) > 0
    error_message = "At least one address range must be specified."
  }
}

variable "dhcp_enabled" {
  description = "Enable DHCP on the network"
  type        = bool
  default     = true
}

variable "autostart" {
  description = "Start network automatically"
  type        = bool
  default     = true
}
EOF
```

**Create main.tf**:

```bash
cat > main.tf << 'EOF'
# modules/libvirt-network/main.tf

terraform {
  required_version = ">= 1.14"
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "~> 0.9"
    }
  }
}

resource "libvirt_network" "network" {
  name      = var.name
  autostart = var.autostart

  # IP configuration from variable
  ips = [
    for addr in var.addresses : {
      address = split("/", addr)[0]
      prefix  = tonumber(split("/", addr)[1])
      dhcp = var.dhcp_enabled ? {
        ranges = [{
          start = cidrhost(addr, 2)
          end   = cidrhost(addr, -2)
        }]
      } : null
    }
  ]

  # Network forwarding mode
  forward = {
    mode = var.mode
  }

  # DNS domain configuration
  domain = {
    name = var.domain
  }
}
EOF
```

**Create outputs.tf**:

```bash
cat > outputs.tf << 'EOF'
# modules/libvirt-network/outputs.tf

output "id" {
  description = "ID of the network"
  value       = libvirt_network.network.id
}

output "name" {
  description = "Name of the network"
  value       = libvirt_network.network.name
}

output "bridge" {
  description = "Bridge interface name"
  value       = libvirt_network.network.bridge
}
EOF
```

**Note**: In libvirt provider 0.9+, the `addresses` attribute is not available as an output. Networks are automatically configured with NAT and DHCP.

### Module 2: VM Module

Create a module that creates VMs using the network module:

```bash
cd /root/terraform-workspace
mkdir -p modules/libvirt-vm
cd modules/libvirt-vm
```

**Create variables.tf**:

```bash
cat > variables.tf << 'EOF'
# modules/libvirt-vm/variables.tf

variable "name" {
  description = "Name of the VM"
  type        = string

  validation {
    condition     = can(regex("^[a-z][a-z0-9-]{1,30}[a-z0-9]$", var.name))
    error_message = "name must be 3-32 lowercase alphanumeric characters or hyphens."
  }
}

variable "memory" {
  description = "Memory in MB"
  type        = number
  default     = 512

  validation {
    condition     = var.memory >= 256 && var.memory <= 8192
    error_message = "memory must be between 256 and 8192 MB."
  }
}

variable "vcpu" {
  description = "Number of virtual CPUs"
  type        = number
  default     = 1

  validation {
    condition     = var.vcpu >= 1 && var.vcpu <= 4
    error_message = "vcpu must be between 1 and 4."
  }
}

variable "network_id" {
  description = "ID of the network to attach to"
  type        = string
}

variable "autostart" {
  description = "Start VM automatically"
  type        = bool
  default     = false
}

EOF
```

**Create main.tf**:

```bash
cat > main.tf << 'EOF'
# modules/libvirt-vm/main.tf

terraform {
  required_version = ">= 1.14"
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "~> 0.9"
    }
  }
}

# Create a simple disk
resource "libvirt_volume" "vm_disk" {
  name     = "${var.name}-disk.qcow2"
  pool     = "default"
  capacity = 1073741824 # 1GB

  target = {
    format = {
      type = "qcow2"
    }
  }
}

# Create the VM
resource "libvirt_domain" "vm" {
  name      = var.name
  type      = "kvm"
  memory    = var.memory
  vcpu      = var.vcpu
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
          volume = libvirt_volume.vm_disk.name
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

**Create outputs.tf**:

```bash
cat > outputs.tf << 'EOF'
# modules/libvirt-vm/outputs.tf

output "id" {
  description = "ID of the VM"
  value       = libvirt_domain.vm.id
}

output "name" {
  description = "Name of the VM"
  value       = libvirt_domain.vm.name
}

output "uuid" {
  description = "UUID of the VM"
  value       = libvirt_domain.vm.uuid
}
EOF
```

**Note**: In libvirt provider 0.9+, the `network_interface` attribute is not available as an output. Use `uuid` to identify VMs instead.

---

## Section 4: Module Composition

Now let's compose these modules together to build a complete infrastructure.

### Create Root Module

```bash
cd /root/terraform-workspace
cat > main.tf << 'EOF'
# Root module - Module Composition Example

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

# Create a network using our network module
module "app_network" {
  source = "./modules/libvirt-network"

  name        = "app-network"
  mode        = "nat"
  domain      = "app.local"
  addresses   = ["192.168.100.0/24"]
  dhcp_enabled = true
  autostart   = true
}

# Create web server VM using our VM module
# Notice how it uses the network module's output!
module "web_server" {
  source = "./modules/libvirt-vm"

  name       = "web-server"
  memory     = 512
  vcpu       = 1
  network_id = module.app_network.id  # Composition!
  autostart  = false
}

# Create API server VM
module "api_server" {
  source = "./modules/libvirt-vm"

  name       = "api-server"
  memory     = 512
  vcpu       = 1
  network_id = module.app_network.id  # Composition!
  autostart  = false
}

# Create database VM
module "database" {
  source = "./modules/libvirt-vm"

  name       = "database"
  memory     = 1024
  vcpu       = 2
  network_id = module.app_network.id  # Composition!
  autostart  = false
}
EOF
```

**Create outputs.tf**:

```bash
cat > outputs.tf << 'EOF'
# Root module outputs

output "network_info" {
  description = "Network information"
  value = {
    id        = module.app_network.id
    name      = module.app_network.name
    bridge    = module.app_network.bridge
  }
}

output "vms" {
  description = "Information about all VMs"
  value = {
    web_server = {
      id   = module.web_server.id
      name = module.web_server.name
    }
    api_server = {
      id   = module.api_server.id
      name = module.api_server.name
    }
    database = {
      id   = module.database.id
      name = module.database.name
    }
  }
}
EOF
```

### Test Module Composition

```bash
cd /root/terraform-workspace
terraform init
terraform plan
terraform apply -auto-approve
```

Verify the infrastructure:

```bash
# List networks
virsh net-list --all

# List VMs
virsh list --all

# View outputs
terraform output
```

### Key Takeaways - Module Composition

✅ **Outputs as Inputs**: One module's outputs become another's inputs
✅ **Dependency Management**: Terraform handles the order automatically
✅ **Reusability**: Same modules used multiple times with different configs
✅ **Maintainability**: Change module once, affects all uses
✅ **Testability**: Test modules independently

---

## Section 5: Refactoring with `moved` Blocks

Sometimes you need to rename resources or reorganize code. Without `moved` blocks, Terraform would destroy and recreate resources. Let's learn how to refactor safely.

### The Problem: Renaming Causes Destruction

Let's say you want to rename `web_server` to `web`:

```hcl
# Before
module "web_server" {
  source = "./modules/libvirt-vm"
  name   = "web-server"
  # ...
}

# After (without moved block)
module "web" {
  source = "./modules/libvirt-vm"
  name   = "web-server"
  # ...
}
```

Without a `moved` block, Terraform would:
1. Destroy `module.web_server` and all its resources
2. Create `module.web` and all its resources

**This is catastrophic for production!**

### The Solution: `moved` Blocks

```hcl
# Tell Terraform about the rename
moved {
  from = module.web_server
  to   = module.web
}

# The renamed module
module "web" {
  source = "./modules/libvirt-vm"
  name   = "web-server"
  # ...
}
```

Now Terraform will:
1. Update state to reflect the new name
2. **No destruction or recreation!**

### Hands-On: Safe Refactoring

Let's refactor our infrastructure:

```bash
cd /root/terraform-workspace
cat > main.tf << 'EOF'
# Root module - After refactoring with moved blocks

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

# Network module (unchanged)
module "app_network" {
  source = "./modules/libvirt-network"

  name         = "app-network"
  mode         = "nat"
  domain       = "app.local"
  addresses    = ["192.168.100.0/24"]
  dhcp_enabled = true
  autostart    = true
}

# Renamed from web_server to web
moved {
  from = module.web_server
  to   = module.web
}

module "web" {
  source = "./modules/libvirt-vm"

  name       = "web-server"
  memory     = 512
  vcpu       = 1
  network_id = module.app_network.id
  autostart  = false
}

# Renamed from api_server to api
moved {
  from = module.api_server
  to   = module.api
}

module "api" {
  source = "./modules/libvirt-vm"

  name       = "api-server"
  memory     = 512
  vcpu       = 1
  network_id = module.app_network.id
  autostart  = false
}

# Renamed from database to db
moved {
  from = module.database
  to   = module.db
}

module "db" {
  source = "./modules/libvirt-vm"

  name       = "database"
  memory     = 1024
  vcpu       = 2
  network_id = module.app_network.id
  autostart  = false
}
EOF
```

**Update outputs.tf**:

```bash
cat > outputs.tf << 'EOF'
# Root module outputs (updated names)

output "network_info" {
  description = "Network information"
  value = {
    id        = module.app_network.id
    name      = module.app_network.name
    bridge    = module.app_network.bridge
  }
}

output "vms" {
  description = "Information about all VMs"
  value = {
    web = {
      id   = module.web.id
      name = module.web.name
    }
    api = {
      id   = module.api.id
      name = module.api.name
    }
    db = {
      id   = module.db.id
      name = module.db.name
    }
  }
}
EOF
```

### Test the Refactoring

```bash
terraform init
terraform plan
```

**Expected Output**:
```
module.web_server has moved to module.web
module.api_server has moved to module.api
module.database has moved to module.db

No changes. Your infrastructure matches the configuration.
```

Apply the changes:

```bash
terraform apply -auto-approve
```

Verify state was updated:

```bash
terraform state list
```

**You should see**:
- `module.web.libvirt_domain.vm`
- `module.api.libvirt_domain.vm`
- `module.db.libvirt_domain.vm`

**No resources were destroyed or recreated!**

### When to Remove `moved` Blocks

`moved` blocks are not permanent. Remove them after:

1. All team members have applied the changes
2. All environments (dev, staging, prod) have been updated
3. Typically after 1-2 weeks

For published modules, keep them longer to support users on older versions.

### `moved` Block Use Cases

**1. Renaming a Resource**:
```hcl
moved {
  from = local_file.old_name
  to   = local_file.new_name
}
```

**2. Moving into a Module**:
```hcl
moved {
  from = local_file.config
  to   = module.app_config.local_file.config
}
```

**3. Renaming a Module**:
```hcl
moved {
  from = module.old_network
  to   = module.network
}
```

**4. Moving Between `for_each` Keys**:
```hcl
moved {
  from = local_file.configs["old-key"]
  to   = local_file.configs["new-key"]
}
```

### Key Takeaways - `moved` Blocks

✅ **Safe Refactoring**: Rename without destruction
✅ **Version Controlled**: In Git, reviewable in PRs
✅ **Team-Friendly**: Everyone applies the same change
✅ **Terraform 1.1+**: Modern approach to state management
✅ **Temporary**: Remove after all environments updated

---

## 🎯 Challenge Completion

Congratulations! You've completed Challenge 1 and learned:

✅ **Module Fundamentals**: Structure, design principles, best practices
✅ **Creating Modules**: Built simple and complex modules
✅ **Module Composition**: Composed modules to build infrastructure
✅ **Refactoring**: Used `moved` blocks for safe code changes
✅ **Real Infrastructure**: Created networks and VMs with Libvirt

### Clean Up

Before moving to the next challenge, clean up your infrastructure:

```bash
cd /root/terraform-workspace
terraform destroy -auto-approve
```

### What's Next?

In **Challenge 2**, you'll learn:
- Private registry patterns
- Canary deployment strategies
- Blue-green deployments
- Advanced module versioning

Ready to continue? Click **Check** to validate your work and proceed! 🚀

---

## 📚 Additional Resources

- [Terraform Modules Documentation](https://www.terraform.io/language/modules)
- [Module Development Best Practices](https://www.terraform.io/language/modules/develop/best-practices)
- [moved Blocks Documentation](https://developer.hashicorp.com/terraform/language/modules/develop/refactoring)
- [Libvirt Provider Documentation](https://registry.terraform.io/providers/dmacvicar/libvirt/latest/docs)

---

**Made with ❤️ for the Terraform community**
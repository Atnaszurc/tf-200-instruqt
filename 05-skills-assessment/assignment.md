---
slug: skills-assessment
id: fpkl4y0zmk8x
type: challenge
title: 'Challenge 5: Skills Assessment'
teaser: Demonstrate your mastery of Terraform modules and patterns by building a complete
  modular infrastructure
notes:
- type: text
  contents: "# Challenge 5: Skills Assessment\n\nThis is your final challenge! You'll
    demonstrate everything you've learned in TF-200 by building a complete, production-ready
    modular infrastructure.\n\n## What You'll Build\n\nA multi-tier application infrastructure
    using:\n- **Custom modules** with proper composition\n- **YAML-driven configuration**
    for flexibility\n- **Advanced patterns** (nested modules, conditional resources)\n-
    **Import strategies** for existing resources\n- **Best practices** throughout\n\n##
    No Step-by-Step Instructions\n\nThis challenge provides **requirements only**
    - no detailed instructions. You'll need to apply everything you've learned to
    design and implement the solution.\n\n## Success Criteria\n\nYour solution will
    be validated against:\n- ✅ Module structure and composition\n- ✅ YAML configuration
    usage\n- ✅ Advanced patterns implementation\n- ✅ Import of existing resources\n-
    ✅ Code quality and best practices\n\nReady to prove your skills? Let's go! \U0001F680\n"
- type: text
  contents: "# Assessment Overview\n\n## The Scenario\n\nYou're tasked with creating
    a modular infrastructure for a three-tier web application:\n\n**Tier 1: Frontend**\n-
    Web servers\n- Load balancing\n- Public network\n\n**Tier 2: Application**\n-
    Application servers\n- Private network\n- Service discovery\n\n**Tier 3: Database**\n-
    Database servers\n- Isolated network\n- Backup storage\n\n## Your Mission\n\n1.
    Create reusable modules for each tier\n2. Use YAML files to configure environments
    (dev, staging, prod)\n3. Import existing legacy infrastructure\n4. Implement advanced
    patterns (canary deployments, conditional resources)\n5. Ensure everything follows
    best practices\n\nGood luck! \U0001F3AF\n"
tabs:
- id: s1qg9estdcka
  title: Terminal
  type: terminal
  hostname: workstation
  workdir: /root/terraform
- id: 5ebf42jq8ao7
  title: Editor
  type: code
  hostname: workstation
  path: /root/terraform
difficulty: basic
timelimit: 7200
enhanced_loading: null
---

🎯 Challenge 5: Skills Assessment
==================================

Welcome to your final challenge! This is your opportunity to demonstrate mastery of all TF-200 concepts by building a complete, production-ready modular infrastructure.

## 📋 Challenge Overview

**No step-by-step instructions are provided.** You must design and implement the solution based on the requirements below, applying everything you've learned in Challenges 1-4.

## 🎯 The Scenario

You're building infrastructure for **CloudApp**, a three-tier web application that needs to run in multiple environments (dev, staging, production).

### Business Requirements

1. **Multi-Environment Support**: Dev, staging, and production environments with different configurations
2. **Modular Design**: Reusable modules for each tier
3. **Flexible Configuration**: YAML-driven configuration for easy environment management
4. **Legacy Integration**: Import existing infrastructure into Terraform management
5. **Advanced Patterns**: Implement canary deployments and conditional resources
6. **Production-Ready**: Follow best practices for real-world usage

## 📐 Architecture Requirements

### Tier 1: Frontend (Web Tier)

**Module**: `modules/frontend`

**Resources**:
- Network for frontend servers
- 2-3 web server VMs (configurable per environment)
- Load balancer configuration (simulated with local_file)

**Features**:
- Outputs: network ID, server IPs, load balancer config
- Variables: environment name, server count, network CIDR
- Conditional: Enable/disable monitoring based on environment

### Tier 2: Application (App Tier)

**Module**: `modules/application`

**Resources**:
- Network for application servers
- 2-4 application server VMs (configurable per environment)
- Service discovery configuration (simulated with local_file)

**Features**:
- Depends on frontend network
- Outputs: network ID, server IPs, service endpoints
- Variables: environment name, server count, network CIDR, frontend network ID
- Conditional: Enable/disable caching based on environment

### Tier 3: Database (Data Tier)

**Module**: `modules/database`

**Resources**:
- Isolated network for database servers
- 1-2 database server VMs (configurable per environment)
- Backup storage pool
- Backup configuration (simulated with local_file)

**Features**:
- Outputs: network ID, server IPs, backup pool ID
- Variables: environment name, server count, network CIDR, backup enabled
- Conditional: Enable/disable replication based on environment

### Root Module (Environment Orchestration)

**Module**: `modules/app-stack`

**Purpose**: Compose all three tiers into a complete application stack

**Features**:
- Uses all three tier modules
- Passes outputs between modules
- Configurable via YAML files
- Supports multiple environments

### Module Implementation Guidance 🛠️

**How to Structure Each Module:**

Every module should follow this pattern:

```
modules/frontend/
├── main.tf          # Resources
├── variables.tf     # Input variables
├── outputs.tf       # Output values
└── README.md        # Documentation
```

**Example: Frontend Module Structure**

**`modules/frontend/variables.tf`:**
```hcl
variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
}

variable "server_count" {
  description = "Number of web servers to create"
  type        = number
  default     = 2

  validation {
    condition     = var.server_count >= 1 && var.server_count <= 5
    error_message = "Server count must be between 1 and 5"
  }
}

variable "network_cidr" {
  description = "CIDR block for frontend network"
  type        = string
}

variable "monitoring_enabled" {
  description = "Enable monitoring resources"
  type        = bool
  default     = false
}
```

**`modules/frontend/main.tf`:**
```hcl
# Network for frontend tier
resource "libvirt_network" "frontend" {
  name      = "${var.environment}-frontend-network"
  domain    = "frontend.local"
  autostart = true
}

# Base image for web servers
resource "libvirt_volume" "base" {
  name = "${var.environment}-frontend-base.qcow2"
  pool = "default"

  create = {
    content = {
      url = "https://cloud-images.ubuntu.com/releases/22.04/release/ubuntu-22.04-server-cloudimg-amd64.img"
    }
  }

  target = {
    format = {
      type = "qcow2"
    }
  }
}

# Web server VMs
resource "libvirt_volume" "server" {
  count = var.server_count

  name     = "${var.environment}-web-${count.index + 1}.qcow2"
  pool     = "default"
  capacity = 10737418240  # 10GB

  backing_store = {
    path = libvirt_volume.base.id
    format = {
      type = "qcow2"
    }
  }

  target = {
    format = {
      type = "qcow2"
    }
  }
}

resource "libvirt_domain" "server" {
  count = var.server_count

  name   = "${var.environment}-web-${count.index + 1}"
  memory = 1024
  vcpu   = 1
  type   = "kvm"

  os = {
    type = "hvm"
  }

  devices = {
    disks = [{
      source = {
        volume = {
          pool   = "default"
          volume = libvirt_volume.server[count.index].name
        }
      }
      target = {
        dev = "vda"
        bus = "virtio"
      }
    }]

    interfaces = [{
      network = {
        network = libvirt_network.frontend.name
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

# Conditional monitoring (only if enabled)
resource "local_file" "monitoring" {
  count = var.monitoring_enabled ? 1 : 0

  filename = "${path.module}/monitoring-config.json"
  content = jsonencode({
    environment = var.environment
    servers     = libvirt_domain.server[*].name
    enabled     = true
  })
}

# Load balancer configuration (simulated)
resource "local_file" "loadbalancer" {
  filename = "${path.module}/lb-config.json"
  content = jsonencode({
    environment = var.environment
    backend_servers = [
      for i, server in libvirt_domain.server :
      {
        name = server.name
        ip   = server.devices[0].interfaces[0].addresses[0]
      }
    ]
  })
}
```

**`modules/frontend/outputs.tf`:**
```hcl
output "network_id" {
  description = "ID of the frontend network"
  value       = libvirt_network.frontend.id
}

output "network_name" {
  description = "Name of the frontend network"
  value       = libvirt_network.frontend.name
}

output "server_ips" {
  description = "IP addresses of web servers"
  value = [
    for server in libvirt_domain.server :
    server.devices[0].interfaces[0].addresses[0]
  ]
}

output "server_names" {
  description = "Names of web servers"
  value       = libvirt_domain.server[*].name
}

output "loadbalancer_config" {
  description = "Load balancer configuration file path"
  value       = local_file.loadbalancer.filename
}
```

**`modules/frontend/README.md`:**
```markdown
# Frontend Module

Creates frontend tier infrastructure including network, web servers, and load balancer configuration.

## Resources Created

- 1 libvirt network
- N web server VMs (configurable)
- 1 load balancer configuration file
- 1 monitoring configuration file (conditional)

## Usage

```hcl
module "frontend" {
  source = "./modules/frontend"

  environment        = "dev"
  server_count       = 2
  network_cidr       = "192.168.10.0/24"
  monitoring_enabled = false
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| environment | Environment name | string | - | yes |
| server_count | Number of web servers | number | 2 | no |
| network_cidr | Network CIDR block | string | - | yes |
| monitoring_enabled | Enable monitoring | bool | false | no |

## Outputs

| Name | Description |
|------|-------------|
| network_id | Frontend network ID |
| server_ips | List of server IP addresses |
| loadbalancer_config | Path to LB config file |
```

**Key Patterns to Follow:**

1. **Naming Convention**: `${var.environment}-<component>-<resource>`
2. **Conditional Resources**: Use `count = condition ? 1 : 0`
3. **Dynamic Lists**: Use `for` expressions for outputs
4. **Validation**: Add validation blocks to variables
5. **Documentation**: Always include README.md

**Application Module Differences:**

The application module is similar but:
- Takes `frontend_network_id` as input (dependency)
- Creates caching config conditionally
- Uses different CIDR range

**Database Module Differences:**

The database module additionally:
- Creates backup storage pool
- Implements replication conditionally
- Has stricter resource limits

**App-Stack Module Pattern:**

```hcl
# modules/app-stack/main.tf
module "frontend" {
  source = "../frontend"

  environment        = var.environment
  server_count       = var.frontend_config.server_count
  network_cidr       = var.frontend_config.network_cidr
  monitoring_enabled = var.frontend_config.monitoring_enabled
}

module "application" {
  source = "../application"

  environment         = var.environment
  server_count        = var.application_config.server_count
  network_cidr        = var.application_config.network_cidr
  frontend_network_id = module.frontend.network_id  # Dependency!
  caching_enabled     = var.application_config.caching_enabled
}

module "database" {
  source = "../database"

  environment          = var.environment
  server_count         = var.database_config.server_count
  network_cidr         = var.database_config.network_cidr
  backup_enabled       = var.database_config.backup_enabled
  replication_enabled  = var.database_config.replication_enabled
}
```

**YAML Integration Pattern:**

```hcl
# main.tf (root)
locals {
  config = yamldecode(file("${path.module}/config/${var.environment}.yaml"))
}

module "app_stack" {
  source = "./modules/app-stack"

  environment         = local.config.environment
  frontend_config     = local.config.frontend
  application_config  = local.config.application
  database_config     = local.config.database
}
```


## 📄 YAML Configuration Requirements

Create YAML configuration files for each environment:

### `config/dev.yaml`
```yaml
environment: dev
frontend:
  server_count: 2
  network_cidr: "192.168.10.0/24"
  monitoring_enabled: false
application:
  server_count: 2
  network_cidr: "192.168.11.0/24"
  caching_enabled: false
database:
  server_count: 1
  network_cidr: "192.168.12.0/24"
  backup_enabled: false
  replication_enabled: false
```

### `config/staging.yaml`
```yaml
environment: staging
frontend:
  server_count: 2
  network_cidr: "192.168.20.0/24"
  monitoring_enabled: true
application:
  server_count: 3
  network_cidr: "192.168.21.0/24"
  caching_enabled: true
database:
  server_count: 1
  network_cidr: "192.168.22.0/24"
  backup_enabled: true
  replication_enabled: false
```

### `config/prod.yaml`
```yaml
environment: prod
frontend:
  server_count: 3
  network_cidr: "192.168.30.0/24"
  monitoring_enabled: true
application:
  server_count: 4
  network_cidr: "192.168.31.0/24"
  caching_enabled: true
database:
  server_count: 2
  network_cidr: "192.168.32.0/24"
  backup_enabled: true
  replication_enabled: true
```

## 🔄 Import Requirements

You'll find existing "legacy" infrastructure that needs to be imported:

1. **Legacy Network**: `legacy-app-network` (192.168.100.0/24)
2. **Legacy VM**: `legacy-app-server`

**Task**: Import these resources into your Terraform configuration using import blocks, then refactor them to use your modules.


### Detailed Import Instructions 📝

**Step 1: Discover Legacy Resources**

First, find what exists:

```bash
# List all networks
virsh net-list --all

# You should see: legacy-app-network

# Get network UUID (you'll need this!)
LEGACY_NET_UUID=$(virsh net-uuid legacy-app-network)
echo "Legacy Network UUID: $LEGACY_NET_UUID"

# List all VMs
virsh list --all

# You should see: legacy-app-server

# Get VM UUID
LEGACY_VM_UUID=$(virsh domuuid legacy-app-server)
echo "Legacy VM UUID: $LEGACY_VM_UUID"
```

**Step 2: Create Import Blocks**

Create `imports.tf`:

```hcl
# Import legacy network
import {
  to = libvirt_network.legacy
  id = "<paste-network-uuid-here>"
}

# Import legacy VM
import {
  to = libvirt_domain.legacy
  id = "<paste-vm-uuid-here>"
}
```

**Step 3: Generate Configuration**

Let Terraform generate the configuration:

```bash
# This will create generated.tf with the resource definitions
terraform plan -generate-config-out=generated.tf
```

**Step 4: Review Generated Configuration**

Open `generated.tf` and review:
- Network configuration (CIDR, mode, etc.)
- VM configuration (memory, vcpu, disks, etc.)

**Step 5: Refactor into Modules**

Instead of keeping resources in root, move them into your modules:

```hcl
# Option 1: Use existing module
module "legacy_integration" {
  source = "./modules/application"

  environment  = "legacy"
  server_count = 1
  network_cidr = "192.168.100.0/24"
  # ... other settings from generated config
}

# Option 2: Create dedicated legacy module
module "legacy" {
  source = "./modules/legacy"

  network_uuid = var.legacy_network_uuid
  # ... other settings
}
```

**Step 6: Use moved Blocks for Refactoring**

If you move resources into modules, use moved blocks:

```hcl
moved {
  from = libvirt_network.legacy
  to   = module.legacy.libvirt_network.main
}

moved {
  from = libvirt_domain.legacy
  to   = module.legacy.libvirt_domain.server
}
```

**Step 7: Handle Network UUID Issue**

⚠️ **Important**: Due to libvirt provider limitations, pass the network UUID as a variable instead of managing it:

```hcl
# variables.tf
variable "legacy_network_uuid" {
  description = "UUID of pre-existing legacy network"
  type        = string
}

# main.tf - reference by UUID, don't manage
resource "libvirt_domain" "legacy" {
  devices = {
    interfaces = [{
      network_id = var.legacy_network_uuid  # Use UUID directly
    }]
  }
}

# terraform.tfvars
legacy_network_uuid = "67c3b098-5846-4e5f-8787-f4a3bacca0e4"  # From virsh net-uuid
```

**Step 8: Test Import**

```bash
# Initialize
terraform init

# Plan (should show import operations)
terraform plan

# Apply (imports resources into state)
terraform apply

# Verify
terraform state list
# Should show: libvirt_network.legacy, libvirt_domain.legacy
```

**Common Import Pitfalls:**

❌ **Don't**: Use resource names as IDs
```hcl
import {
  id = "legacy-app-network"  # Wrong! Use UUID
}
```

✅ **Do**: Use UUIDs
```hcl
import {
  id = "67c3b098-5846-4e5f-8787-f4a3bacca0e4"  # Correct!
}
```

❌ **Don't**: Try to manage imported network directly
```hcl
resource "libvirt_network" "legacy" {
  name = "legacy-app-network"
  # Will cause "inconsistent result" errors
}
```

✅ **Do**: Pass UUID as variable
```hcl
variable "legacy_network_uuid" {
  type = string
}
# Reference in VMs, don't manage network itself
```

**Note**: The legacy network UUID must be fetched dynamically and passed as a variable to avoid libvirt provider inconsistencies.

## 🚀 Advanced Pattern Requirements

### 1. Canary Deployment Pattern

Implement a canary deployment for the application tier:
- Deploy a small percentage of servers with new configuration
- Gradually increase the percentage
- Use variables to control canary percentage

### 2. Conditional Resources

Implement conditional resource creation:
- Monitoring resources only in staging/prod
- Caching resources only when enabled
- Replication only in production
- Backup only when enabled

### 3. Module Composition

Create a top-level `app-stack` module that:
- Composes all three tiers
- Manages dependencies between tiers
- Provides unified outputs
- Accepts YAML configuration

## ✅ Validation Criteria

Your solution will be validated against these criteria:

### Module Structure (25 points)
- [ ] Frontend module exists with proper structure
- [ ] Application module exists with proper structure
- [ ] Database module exists with proper structure
- [ ] App-stack module composes all tiers
- [ ] All modules have README.md files

### YAML Configuration (20 points)
- [ ] YAML files exist for dev, staging, prod
- [ ] Configuration is properly parsed with yamldecode()
- [ ] Environment-specific settings are applied
- [ ] YAML structure matches requirements

### Import & Migration (15 points)
- [ ] Legacy network is imported
- [ ] Legacy VM is imported
- [ ] Import blocks are used (not CLI)
- [ ] Resources are refactored to use modules

### Advanced Patterns (20 points)
- [ ] Canary deployment implemented
- [ ] Conditional resources work correctly
- [ ] Module composition is clean
- [ ] Dependencies are properly managed

### Code Quality (20 points)
- [ ] Proper variable definitions with descriptions
- [ ] Meaningful output definitions
- [ ] Consistent naming conventions
- [ ] Comments where appropriate
- [ ] No hardcoded values

## 🗓️ Recommended Approach: Phased Implementation

**Don't try to build everything at once!** Break this challenge into manageable phases.

### Phase 1: Foundation (30 minutes)
**Goal:** Set up basic structure

```bash
# Create directory structure
mkdir -p modules/{frontend,application,database,app-stack}
mkdir -p config

# Create basic files
touch modules/frontend/{main.tf,variables.tf,outputs.tf,README.md}
touch modules/application/{main.tf,variables.tf,outputs.tf,README.md}
touch modules/database/{main.tf,variables.tf,outputs.tf,README.md}
touch modules/app-stack/{main.tf,variables.tf,outputs.tf,README.md}
touch config/{dev,staging,prod}.yaml
```

**Checkpoint:** You have all directories and empty files created.

---

### Phase 2: Frontend Module (45 minutes)
**Goal:** Build and test the frontend tier

**Steps:**
1. Define variables in `modules/frontend/variables.tf`
2. Create network and VMs in `modules/frontend/main.tf`
3. Add outputs in `modules/frontend/outputs.tf`
4. Test with simple `main.tf` in root

**Test:**
```hcl
# main.tf (temporary test)
module "frontend" {
  source = "./modules/frontend"

  environment    = "dev"
  server_count   = 2
  network_cidr   = "192.168.10.0/24"
  monitoring_enabled = false
}

output "frontend_ips" {
  value = module.frontend.server_ips
}
```

```bash
terraform init
terraform plan
terraform apply
```

**Checkpoint:** Frontend module works independently.

---

### Phase 3: Application & Database Modules (60 minutes)
**Goal:** Build remaining tier modules

**Application Module (30 min):**
- Similar structure to frontend
- Add dependency on frontend network
- Include caching conditional

**Database Module (30 min):**
- Similar structure to frontend
- Add backup pool
- Include replication conditional

**Test each module independently** before moving on.

**Checkpoint:** All three tier modules work independently.

---

### Phase 4: YAML Configuration (30 minutes)
**Goal:** Create environment configs

**Steps:**
1. Create `config/dev.yaml` with dev settings
2. Create `config/staging.yaml` with staging settings
3. Create `config/prod.yaml` with prod settings
4. Test YAML parsing in `main.tf`

**Test:**
```hcl
locals {
  config = yamldecode(file("${path.module}/config/dev.yaml"))
}

output "parsed_config" {
  value = local.config
}
```

**Checkpoint:** YAML files parse correctly.

---

### Phase 5: App-Stack Composition (45 minutes)
**Goal:** Compose all tiers into unified stack

**Steps:**
1. Create `modules/app-stack/main.tf` that uses all three tier modules
2. Pass outputs between modules (frontend → application)
3. Accept YAML config as input
4. Test with dev environment

**Checkpoint:** Complete stack deploys for dev environment.

---

### Phase 6: Multi-Environment Testing (30 minutes)
**Goal:** Validate all environments work

**Steps:**
1. Deploy dev environment
2. Deploy staging environment (different workspace or directory)
3. Deploy prod environment
4. Verify different configurations are applied

**Checkpoint:** All three environments deploy successfully.

---

### Phase 7: Import Legacy Resources (30 minutes)
**Goal:** Bring existing infrastructure under management

**Steps:**
1. Create `imports.tf` with import blocks
2. Import legacy network
3. Import legacy VM
4. Generate configuration with `-generate-config-out`
5. Refactor into modules

**Checkpoint:** Legacy resources imported and managed.

---

### Phase 8: Advanced Patterns (30 minutes)
**Goal:** Implement canary and conditionals

**Canary Deployment:**
```hcl
variable "canary_percentage" {
  default = 20
}

locals {
  total_servers = var.server_count
  canary_count  = floor(local.total_servers * var.canary_percentage / 100)
  stable_count  = local.total_servers - local.canary_count
}
```

**Conditional Resources:**
```hcl
resource "local_file" "monitoring" {
  count = var.monitoring_enabled ? 1 : 0
  # ...
}
```

**Checkpoint:** Advanced patterns implemented and tested.

---

### Phase 9: Documentation & Polish (20 minutes)
**Goal:** Add documentation and final touches

**Steps:**
1. Write README.md for each module
2. Add comments to complex logic
3. Verify variable descriptions
4. Check output descriptions
5. Remove any hardcoded values

**Checkpoint:** Code is well-documented and clean.

---

### Phase 10: Final Validation (10 minutes)
**Goal:** Ensure everything passes checks

**Steps:**
1. Run `terraform fmt -recursive`
2. Run `terraform validate`
3. Test all environments one more time
4. Review checklist below
5. Click "Check"

**Checkpoint:** Ready for validation!

---

### ⏱️ Total Estimated Time: 5-6 hours

**Time Management Tips:**
- ✅ Take breaks between phases
- ✅ If stuck on one phase, move to the next and come back
- ✅ Test frequently (don't wait until the end)
- ✅ Use `terraform destroy` between tests to clean up
- ✅ Reference previous challenges for patterns

**If You're Running Out of Time:**

**Priority 1 (Must Have - 70 points):**
- All three tier modules working
- YAML configuration for at least dev
- Basic app-stack composition

**Priority 2 (Should Have - 20 points):**
- Import legacy resources
- Multi-environment support

**Priority 3 (Nice to Have - 10 points):**
- Advanced patterns (canary, conditionals)
- Complete documentation

---


## 🎓 Tips for Success

1. **Start with Module Structure**: Create the module directories and basic files first
2. **Build Incrementally**: Start with one tier, test it, then add the next
3. **Use Previous Challenges**: Reference your work from Challenges 1-4
4. **Test Each Environment**: Validate that dev, staging, and prod work correctly
5. **Import Last**: Get your modules working first, then import legacy resources
6. **Document Your Work**: Add README files to explain your design decisions

## 📚 Resources Available

You have access to:
- All previous challenge materials
- Helper scripts in `/root/terraform/`
- Terraform documentation
- Your notes from previous challenges

## 🚫 What NOT to Do

- ❌ Don't copy/paste entire solutions from previous challenges
- ❌ Don't skip the YAML configuration
- ❌ Don't hardcode environment-specific values
- ❌ Don't ignore the import requirements
- ❌ Don't forget to test each environment

## 📊 Scoring Breakdown

| Category | Points | Description |
|----------|--------|-------------|
| Module Structure | 25 | Proper module organization and composition |
| YAML Configuration | 20 | Environment-specific YAML configs |
| Import & Migration | 15 | Legacy resource import |
| Advanced Patterns | 20 | Canary, conditionals, composition |
| Code Quality | 20 | Best practices, documentation |
| **Total** | **100** | **Passing: 70 points** |

## 🎯 Success Checklist

Before clicking "Check", ensure you have:

- [ ] Created all required modules (frontend, application, database, app-stack)
- [ ] Created YAML configuration files for all environments
- [ ] Implemented YAML-driven configuration with yamldecode()
- [ ] Imported legacy resources using import blocks
- [ ] Implemented canary deployment pattern
- [ ] Implemented conditional resources
- [ ] Tested all three environments (dev, staging, prod)
- [ ] Added README.md files to modules
- [ ] Followed naming conventions
- [ ] Validated with `terraform plan` (no errors)

## 🏆 Bonus Challenges (Optional)

Want to go above and beyond? Try these:

1. **Multi-Region Support**: Extend your solution to support multiple regions
2. **Automated Testing**: Add Terraform test files for your modules
3. **Documentation**: Create comprehensive documentation with diagrams
4. **CI/CD Integration**: Design a CI/CD pipeline for your infrastructure
5. **Cost Optimization**: Add cost estimation and optimization suggestions

## 📝 Submission Notes

When you click "Check", the validation script will:
1. Verify module structure and files
2. Test YAML configuration parsing
3. Validate import of legacy resources
4. Check for advanced patterns
5. Assess code quality and best practices
6. Provide detailed feedback on any issues

## 🎉 Ready?

This is your moment to shine! Take your time, think through the design, and build something you're proud of.

**Remember**: There's no single "correct" solution. We're evaluating your ability to apply TF-200 concepts effectively.

Good luck! 🚀

---

## 💡 Need Help?

If you're stuck:
1. Review the requirements carefully
2. Check your work from previous challenges
3. Start simple and build incrementally
4. Test frequently with `terraform plan`
5. Read error messages carefully

You've got this! 💪
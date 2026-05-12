# Challenge 5: Skills Assessment

This is the final challenge - a comprehensive skills assessment where you demonstrate mastery of all TF-200 concepts by building a complete, production-ready modular infrastructure.

## Overview

**No step-by-step instructions provided.** You must design and implement the solution based on requirements, applying everything learned in Challenges 1-4.

## The Scenario

Build infrastructure for **CloudApp**, a three-tier web application that runs in multiple environments (dev, staging, production).

## Architecture Requirements

### Three-Tier Application Stack

```
┌─────────────────────────────────────────────────────────┐
│                    Frontend Tier                         │
│  - Web servers (2-3 VMs)                                │
│  - Load balancer config                                  │
│  - Public network (10.X0.0.0/24)                        │
│  - Conditional monitoring                                │
└─────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────┐
│                   Application Tier                       │
│  - App servers (2-4 VMs)                                │
│  - Service discovery config                              │
│  - Private network (10.X1.0.0/24)                       │
│  - Conditional caching                                   │
│  - Canary deployment support                             │
└─────────────────────────────────────────────────────────┘
                          │
                          ▼
┌─────────────────────────────────────────────────────────┐
│                    Database Tier                         │
│  - DB servers (1-2 VMs)                                 │
│  - Backup storage pool                                   │
│  - Isolated network (10.X2.0.0/24)                      │
│  - Conditional replication                               │
│  - Conditional backups                                   │
└─────────────────────────────────────────────────────────┘
```

## Required Modules

### 1. Frontend Module (`modules/frontend`)
**Purpose**: Web tier infrastructure

**Resources**:
- Network for frontend servers
- 2-3 web server VMs (environment-dependent)
- Load balancer configuration (local_file)

**Variables**:
- `environment` - Environment name
- `server_count` - Number of web servers
- `network_cidr` - Network CIDR block
- `monitoring_enabled` - Enable/disable monitoring

**Outputs**:
- `network_id` - Frontend network ID
- `server_ips` - List of server IP addresses
- `load_balancer_config` - Load balancer configuration path

### 2. Application Module (`modules/application`)
**Purpose**: Application tier infrastructure

**Resources**:
- Network for application servers
- 2-4 application server VMs (environment-dependent)
- Service discovery configuration (local_file)
- Canary deployment support

**Variables**:
- `environment` - Environment name
- `server_count` - Number of app servers
- `network_cidr` - Network CIDR block
- `frontend_network_id` - Frontend network dependency
- `caching_enabled` - Enable/disable caching
- `canary_percentage` - Percentage for canary deployment

**Outputs**:
- `network_id` - Application network ID
- `server_ips` - List of server IP addresses
- `service_endpoints` - Service discovery endpoints

### 3. Database Module (`modules/database`)
**Purpose**: Data tier infrastructure

**Resources**:
- Isolated network for database servers
- 1-2 database server VMs (environment-dependent)
- Backup storage pool
- Backup configuration (local_file)

**Variables**:
- `environment` - Environment name
- `server_count` - Number of DB servers
- `network_cidr` - Network CIDR block
- `backup_enabled` - Enable/disable backups
- `replication_enabled` - Enable/disable replication

**Outputs**:
- `network_id` - Database network ID
- `server_ips` - List of server IP addresses
- `backup_pool_id` - Backup storage pool ID

### 4. App-Stack Module (`modules/app-stack`)
**Purpose**: Compose all tiers into complete application stack

**Features**:
- Uses all three tier modules
- Manages dependencies between tiers
- Accepts YAML configuration
- Provides unified outputs

**Variables**:
- `config_file` - Path to YAML configuration file

**Outputs**:
- `frontend` - Frontend tier outputs
- `application` - Application tier outputs
- `database` - Database tier outputs
- `environment` - Environment name

## YAML Configuration Files

Three environment configuration files are provided in the `config/` directory:

### config/dev.yaml
Development environment with minimal resources:
- 2 frontend servers
- 2 application servers
- 1 database server
- No monitoring, caching, backups, or replication

### config/staging.yaml
Staging environment with moderate resources:
- 2 frontend servers (with monitoring)
- 3 application servers (with caching)
- 1 database server (with backups)
- No replication

### config/prod.yaml
Production environment with full resources:
- 3 frontend servers (with monitoring)
- 4 application servers (with caching)
- 2 database servers (with backups and replication)

## Import Requirements

Import existing legacy infrastructure:

1. **Legacy Network**: `legacy-app-network` (10.100.0.0/24)
2. **Legacy VM**: `legacy-app-server`

**Task**: Use import blocks (not CLI) to bring these under Terraform management, then refactor to use your modules.

## Advanced Pattern Requirements

### 1. Canary Deployment
Implement canary deployment for application tier:
- Deploy small percentage with new configuration
- Gradually increase percentage
- Use variables to control canary percentage

### 2. Conditional Resources
Implement conditional resource creation:
- Monitoring resources only in staging/prod
- Caching resources only when enabled
- Replication only in production
- Backups only when enabled

### 3. Module Composition
Create app-stack module that:
- Composes all three tiers
- Manages dependencies
- Provides unified outputs
- Accepts YAML configuration

## Validation Criteria

### Module Structure (25 points)
- [ ] Frontend module with proper structure
- [ ] Application module with proper structure
- [ ] Database module with proper structure
- [ ] App-stack module composing all tiers
- [ ] All modules have README.md files

### YAML Configuration (20 points)
- [ ] YAML files for dev, staging, prod
- [ ] Proper parsing with yamldecode()
- [ ] Environment-specific settings applied
- [ ] YAML structure matches requirements

### Import & Migration (15 points)
- [ ] Legacy network imported
- [ ] Legacy VM imported
- [ ] Import blocks used (not CLI)
- [ ] Resources refactored to use modules

### Advanced Patterns (20 points)
- [ ] Canary deployment implemented
- [ ] Conditional resources work correctly
- [ ] Module composition is clean
- [ ] Dependencies properly managed

### Code Quality (20 points)
- [ ] Proper variable definitions with descriptions
- [ ] Meaningful output definitions
- [ ] Consistent naming conventions
- [ ] Comments where appropriate
- [ ] No hardcoded values

## Tips for Success

1. **Start with Module Structure**
   - Create module directories first
   - Define variables and outputs
   - Build incrementally

2. **Build One Tier at a Time**
   - Start with frontend
   - Test thoroughly
   - Add application tier
   - Test again
   - Add database tier

3. **Use Previous Challenges**
   - Reference Challenge 1 for module basics
   - Reference Challenge 2 for advanced patterns
   - Reference Challenge 3 for YAML configuration
   - Reference Challenge 4 for import strategies

4. **Test Each Environment**
   - Validate dev environment first
   - Then staging
   - Finally production
   - Ensure each works correctly

5. **Import Last**
   - Get modules working first
   - Then import legacy resources
   - Refactor to use modules

6. **Document Your Work**
   - Add README to each module
   - Explain design decisions
   - Document usage examples

## Example Module Structure

```
modules/
├── frontend/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── README.md
├── application/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── README.md
├── database/
│   ├── main.tf
│   ├── variables.tf
│   ├── outputs.tf
│   └── README.md
└── app-stack/
    ├── main.tf
    ├── variables.tf
    ├── outputs.tf
    └── README.md
```

## Example Root Module Usage

```hcl
terraform {
  required_version = ">= 1.5.0"
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

# Deploy complete application stack
module "cloudapp" {
  source = "./modules/app-stack"
  
  config_file = "${path.module}/config/${var.environment}.yaml"
}

# Output application details
output "application_stack" {
  description = "Complete application stack details"
  value       = module.cloudapp
}
```

## Scoring Breakdown

| Category | Points | Description |
|----------|--------|-------------|
| Module Structure | 25 | Proper module organization and composition |
| YAML Configuration | 20 | Environment-specific YAML configs |
| Import & Migration | 15 | Legacy resource import |
| Advanced Patterns | 20 | Canary, conditionals, composition |
| Code Quality | 20 | Best practices, documentation |
| **Total** | **100** | **Passing: 70 points** |

## Success Checklist

Before validation, ensure you have:

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

## What NOT to Do

- ❌ Don't copy/paste entire solutions from previous challenges
- ❌ Don't skip the YAML configuration
- ❌ Don't hardcode environment-specific values
- ❌ Don't ignore the import requirements
- ❌ Don't forget to test each environment

## Bonus Challenges (Optional)

Want to go above and beyond?

1. **Multi-Region Support**: Extend solution to support multiple regions
2. **Automated Testing**: Add Terraform test files for modules
3. **Documentation**: Create comprehensive documentation with diagrams
4. **CI/CD Integration**: Design CI/CD pipeline for infrastructure
5. **Cost Optimization**: Add cost estimation and optimization

## Need Help?

If you're stuck:
1. Review requirements carefully
2. Check work from previous challenges
3. Start simple and build incrementally
4. Test frequently with `terraform plan`
5. Read error messages carefully

## Remember

There's no single "correct" solution. We're evaluating your ability to apply TF-200 concepts effectively.

Good luck! 🚀
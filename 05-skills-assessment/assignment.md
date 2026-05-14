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
- id: 5ebf42jq8ao7
  title: Editor
  type: code
  hostname: workstation
  path: /root/terraform
- id: s1qg9estdcka
  title: Terminal
  type: terminal
  hostname: workstation
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
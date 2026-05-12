---
slug: import-migration-strategies
id: yppscfpzgdqi
type: challenge
title: 'Challenge 4: Import & Migration Strategies'
teaser: Master importing existing infrastructure and migrating legacy code to Terraform
  management
notes:
- type: text
  contents: |
    # Challenge 4: Import & Migration Strategies

    In this challenge, you'll learn how to bring existing infrastructure under Terraform management and safely migrate legacy configurations.

    ## What You'll Learn

    - **Import Blocks (Terraform 1.5+)**: Modern declarative import approach
    - **Legacy CLI Import**: Using terraform import command
    - **State Manipulation**: Safe state management with moved blocks
    - **removed Blocks (Terraform 1.7+)**: Declaratively remove resources from state
    - **Migration Strategies**: Planning and executing large-scale migrations

    ## Why This Matters

    Most organizations have existing infrastructure that wasn't created with Terraform. Learning to import and migrate this infrastructure is essential for adopting IaC without starting from scratch.

    ## Real-World Scenarios

    - Adopting Terraform in an existing environment
    - Migrating from manual management to IaC
    - Refactoring legacy Terraform code
    - Transitioning resources between teams
    - Decommissioning old infrastructure

    Let's master the art of importing and migrating infrastructure!
- type: text
  contents: |
    # Import Strategies Overview

    ## Modern Import (Terraform 1.5+)

    ```hcl
    # Declarative import block
    import {
      to = libvirt_network.existing
      id = "existing-network"
    }

    resource "libvirt_network" "existing" {
      name = "existing-network"
      # Configuration will be generated
    }
    ```

    ## Configuration Generation

    ```bash
    # Generate config from existing resources
    terraform plan -generate-config-out=generated.tf
    ```

    ## Benefits

    - ✅ Version-controlled
    - ✅ Reviewable in PRs
    - ✅ Repeatable
    - ✅ Self-documenting

    Ready to import existing infrastructure!
- type: text
  contents: |
    # State Management & Refactoring

    ## moved Blocks

    Safely rename or reorganize resources without destruction:

    ```hcl
    moved {
      from = libvirt_network.old_name
      to   = libvirt_network.new_name
    }
    ```

    ## removed Blocks (Terraform 1.7+)

    Stop managing resources without destroying them:

    ```hcl
    removed {
      from = libvirt_network.handoff

      lifecycle {
        destroy = false  # Keep running
      }
    }
    ```

    ## State Commands

    ```bash
    # Rename in state
    terraform state mv old new

    # Remove from state
    terraform state rm resource

    # Backup state
    terraform state pull > backup.tfstate
    ```

    Let's practice safe state manipulation!
tabs:
- id: unuwkzrakn9u
  title: Editor
  type: code
  hostname: workstation
  path: /root/terraform
- id: hjqfukox02po
  title: Terminal
  type: terminal
  hostname: workstation
difficulty: basic
timelimit: 3600
enhanced_loading: null
---

🎯 Challenge 4: Import & Migration Strategies
===============================================

Welcome to Challenge 4! In this challenge, you'll master the essential skills of importing existing infrastructure into Terraform management and safely migrating legacy configurations.

## 📚 Challenge Overview

Most real-world Terraform adoption involves working with existing infrastructure. You'll learn:

1. **Modern Import Blocks** - Declarative import (Terraform 1.5+)
2. **Configuration Generation** - Auto-generate Terraform code
3. **State Manipulation** - Safe refactoring with moved blocks
4. **Resource Removal** - removed blocks (Terraform 1.7+)
5. **Migration Planning** - Strategies for large-scale migrations

## 🎓 Learning Objectives

By completing this challenge, you will:

- ✅ Import existing resources using import blocks
- ✅ Generate Terraform configuration from existing infrastructure
- ✅ Use moved blocks to refactor without destruction
- ✅ Remove resources from state with removed blocks
- ✅ Manipulate state safely with CLI commands
- ✅ Plan and execute infrastructure migrations
- ✅ Validate imported resources
- ✅ Handle import errors and edge cases

---

## 📖 Section 1: Modern Import with Import Blocks

### Understanding Import Blocks

Import blocks (Terraform 1.5+) provide a **declarative** way to import existing infrastructure:

```hcl
# Traditional approach (imperative)
# terraform import libvirt_network.existing existing-network

# Modern approach (declarative)
import {
  to = libvirt_network.existing
  id = "existing-network"
}

resource "libvirt_network" "existing" {
  name      = "existing-network"
  mode      = "nat"
  addresses = ["10.17.3.0/24"]
}
```

**Benefits of Import Blocks**:
- ✅ **Version-controlled**: Part of your Git repository
- ✅ **Reviewable**: Can be reviewed in pull requests
- ✅ **Repeatable**: Same import process every time
- ✅ **Self-documenting**: Shows resource origin
- ✅ **CI/CD friendly**: Works in automated pipelines

### Configuration Generation

One of the most powerful features is automatic configuration generation:

```bash
# Generate Terraform configuration from existing resources
terraform plan -generate-config-out=generated.tf
```

This creates a file with Terraform configuration matching the actual resource state!

### Import Block Syntax

```hcl
import {
  to = <resource_address>
  id = "<provider_specific_id>"
}

# The resource must also be defined
resource "<type>" "<name>" {
  # Configuration here
}
```

**Key Points**:
- The `id` format varies by provider and resource type
- Check provider documentation for correct ID format
- The resource block must exist (can be minimal initially)
- Use `terraform plan -generate-config-out` to get full config

---

## 🔨 Task 1: Import Existing Networks

We've pre-created some Libvirt networks that need to be imported into Terraform management.

### Step 1: Discover Existing Resources

First, let's see what networks already exist:

```bash
cd /root/terraform/import-demo

# List existing networks
virsh net-list --all

# Get details of a specific network
virsh net-dumpxml legacy-network
```

You should see several networks including `legacy-network`, `app-network`, and `db-network`.

### Step 2: Create Import Configuration

Create `imports.tf` with import blocks:

```bash
cat > imports.tf << 'EOF'
# Import existing networks into Terraform management

import {
  to = libvirt_network.legacy
  id = "legacy-network"
}

import {
  to = libvirt_network.app
  id = "app-network"
}

import {
  to = libvirt_network.db
  id = "db-network"
}
EOF
```

### Step 3: Create Minimal Resource Definitions

Create `networks.tf` with minimal resource definitions:

```bash
cat > networks.tf << 'EOF'
resource "libvirt_network" "legacy" {
  name      = "legacy-network"
  mode      = "nat"
  addresses = ["10.100.0.0/24"]
}

resource "libvirt_network" "app" {
  name      = "app-network"
  mode      = "nat"
  addresses = ["10.101.0.0/24"]
}

resource "libvirt_network" "db" {
  name      = "db-network"
  mode      = "nat"
  addresses = ["10.102.0.0/24"]
}
EOF
```

### Step 4: Generate Full Configuration

Use Terraform to generate the complete configuration:

```bash
# Initialize Terraform
terraform init

# Generate configuration from existing resources
terraform plan -generate-config-out=generated.tf

# Review the generated configuration
cat generated.tf
```

The generated file will contain the **actual** configuration of the existing networks!

### Step 5: Update Your Configuration

Compare `generated.tf` with `networks.tf` and update `networks.tf` to match reality:

```bash
# Review differences
diff networks.tf generated.tf

# Update networks.tf with accurate configuration
# (You may need to add autostart, dns, dhcp settings, etc.)
```

### Step 6: Import the Resources

```bash
# Plan to see what will be imported
terraform plan

# Apply to import into state
terraform apply

# Verify import
terraform state list
terraform state show libvirt_network.legacy
```

### Step 7: Validate No Changes Needed

After import, verify that Terraform sees no changes:

```bash
terraform plan
# Should show: "No changes. Your infrastructure matches the configuration."
```

If you see changes, your configuration doesn't match the actual resource. Update `networks.tf` accordingly.

---

## 📖 Section 2: State Manipulation & Refactoring

### Understanding moved Blocks

When you rename or reorganize resources, Terraform would normally:
1. Destroy the resource at the old address
2. Create a new resource at the new address

**moved blocks** prevent this by updating the state without touching infrastructure:

```hcl
moved {
  from = libvirt_network.old_name
  to   = libvirt_network.new_name
}
```

### State Commands

Terraform provides several commands for state manipulation:

```bash
# List all resources in state
terraform state list

# Show details of a resource
terraform state show <resource_address>

# Rename a resource in state
terraform state mv <old_address> <new_address>

# Remove a resource from state (keeps it running)
terraform state rm <resource_address>

# Backup state to file
terraform state pull > backup.tfstate

# Restore state from file (dangerous!)
terraform state push backup.tfstate
```

**⚠️ Important**: Always backup state before manipulation!

---

## 🔨 Task 2: Refactor with moved Blocks

Let's practice safe refactoring using moved blocks.

### Step 1: Backup Current State

Always backup before refactoring:

```bash
cd /root/terraform/refactor-demo

# Backup state
terraform state pull > backup-$(date +%Y%m%d-%H%M%S).tfstate

# Verify backup
ls -lh backup-*.tfstate
```

### Step 2: Rename Resources with moved Blocks

We want to rename our networks to follow a better naming convention. Update `main.tf`:

```hcl
# Add moved blocks for renaming
moved {
  from = libvirt_network.legacy
  to   = libvirt_network.production
}

moved {
  from = libvirt_network.app
  to   = libvirt_network.application
}

moved {
  from = libvirt_network.db
  to   = libvirt_network.database
}

# Update resource definitions with new names
resource "libvirt_network" "production" {
  name      = "legacy-network"  # Actual network name stays the same
  mode      = "nat"
  addresses = ["10.100.0.0/24"]
  autostart = true
}

resource "libvirt_network" "application" {
  name      = "app-network"
  mode      = "nat"
  addresses = ["10.101.0.0/24"]
  autostart = true
}

resource "libvirt_network" "database" {
  name      = "db-network"
  mode      = "nat"
  addresses = ["10.102.0.0/24"]
  autostart = true
}
```

### Step 3: Apply the Refactoring

```bash
# Plan shows state updates, not infrastructure changes
terraform plan

# Apply the refactoring
terraform apply

# Verify new addresses in state
terraform state list
```

You should see the resources at their new addresses, but **no infrastructure was destroyed or recreated**!

### Step 4: Clean Up moved Blocks

After successful refactoring, remove the moved blocks from your configuration:

```bash
# Edit main.tf to remove the moved blocks
# They've served their purpose
```

---

## 📖 Section 3: removed Blocks (Terraform 1.7+)

### Understanding removed Blocks

Sometimes you need to **stop managing** a resource without destroying it. Before Terraform 1.7, you had to use `terraform state rm` (a manual CLI command). Now you can use **removed blocks**:

```hcl
removed {
  from = libvirt_network.handoff

  lifecycle {
    destroy = false  # Keep the resource running
  }
}
```

### removed vs terraform state rm

| Aspect | removed block | terraform state rm |
|--------|--------------|-------------------|
| Version control | ✅ In .tf files | ❌ CLI only |
| Peer review | ✅ Via PR/MR | ❌ No review |
| Audit trail | ✅ Git history | ❌ No history |
| Plan preview | ✅ Shows in plan | ❌ Immediate |

### removed Block Options

```hcl
# Remove from state, keep resource running
removed {
  from = resource.name
  lifecycle {
    destroy = false
  }
}

# Remove from state AND destroy resource
removed {
  from = resource.name
  lifecycle {
    destroy = true
  }
}
```

---

## 🔨 Task 3: Use removed Blocks

Let's practice removing resources from Terraform management.

### Step 1: Identify Resources to Hand Off

Suppose the database network needs to be handed off to the DBA team for manual management:

```bash
cd /root/terraform/handoff-demo

# Check current state
terraform state list
```

### Step 2: Add removed Block

Update `main.tf` to add a removed block:

```hcl
# Hand off database network to DBA team
removed {
  from = libvirt_network.database

  lifecycle {
    destroy = false  # Keep the network running
  }
}

# Remove the resource block for database network
# (Keep production and application networks)
```

### Step 3: Plan and Apply

```bash
# Plan shows removal from state
terraform plan

# Apply the removal
terraform apply

# Verify database network is gone from state
terraform state list

# But the network still exists!
virsh net-list --all | grep db-network
```

### Step 4: Clean Up removed Block

After successful removal, delete the removed block from your configuration:

```bash
# Edit main.tf to remove the 'removed' block
# It has served its purpose
```

---

## 📖 Section 4: Legacy CLI Import

### When to Use CLI Import

While import blocks are preferred, you might need CLI import for:
- Terraform versions < 1.5
- Quick one-off imports
- Scripting bulk imports
- Legacy CI/CD pipelines

### CLI Import Syntax

```bash
terraform import <resource_address> <provider_specific_id>
```

### CLI Import Workflow

1. **Create resource configuration** (must exist first)
2. **Run terraform import** command
3. **Verify with terraform plan**
4. **Adjust configuration** to match actual resource

---

## 🔨 Task 4: CLI Import Practice

Let's practice the legacy import workflow.

### Step 1: Create Resource Configuration

```bash
cd /root/terraform/cli-import-demo

cat > main.tf << 'EOF'
terraform {
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "~> 0.7"
    }
  }
}

provider "libvirt" {
  uri = "qemu:///system"
}

# Resource configuration (will be imported)
resource "libvirt_network" "cli_imported" {
  name      = "cli-import-network"
  mode      = "nat"
  addresses = ["10.200.0.0/24"]
}
EOF
```

### Step 2: Initialize Terraform

```bash
terraform init
```

### Step 3: Import Using CLI

```bash
# Import the existing network
terraform import libvirt_network.cli_imported cli-import-network

# Verify import
terraform state show libvirt_network.cli_imported
```

### Step 4: Validate Configuration

```bash
# Check for configuration drift
terraform plan

# If there are differences, update main.tf to match
```

---

## 📖 Section 5: Bulk Import Strategies

### Importing Multiple Resources

For bulk imports, you can use:

1. **Import blocks with for_each**
2. **Shell scripts with CLI import**
3. **Configuration generation**

### Example: Bulk Import with for_each

```hcl
locals {
  networks_to_import = {
    "web"  = "web-network"
    "app"  = "app-network"
    "data" = "data-network"
  }
}

import {
  for_each = local.networks_to_import
  to       = libvirt_network.networks[each.key]
  id       = each.value
}

resource "libvirt_network" "networks" {
  for_each = local.networks_to_import

  name      = each.value
  mode      = "nat"
  addresses = ["10.${index(keys(local.networks_to_import), each.key) + 10}.0.0/24"]
  autostart = true
}
```

### Example: Bulk Import Script

```bash
#!/bin/bash
# bulk-import.sh

networks=("web-network" "app-network" "data-network")

for net in "${networks[@]}"; do
  echo "Importing network: $net"
  terraform import "libvirt_network.networks[\"$net\"]" "$net"
done
```

---

## 🔨 Task 5: Bulk Import Exercise

Let's import multiple networks at once.

### Step 1: Create Bulk Import Configuration

```bash
cd /root/terraform/bulk-import-demo

cat > main.tf << 'EOF'
terraform {
  required_providers {
    libvirt = {
      source  = "dmacvicar/libvirt"
      version = "~> 0.7"
    }
  }
}

provider "libvirt" {
  uri = "qemu:///system"
}

locals {
  networks = {
    "tier1" = { name = "tier1-network", cidr = "10.10.0.0/24" }
    "tier2" = { name = "tier2-network", cidr = "10.20.0.0/24" }
    "tier3" = { name = "tier3-network", cidr = "10.30.0.0/24" }
  }
}

import {
  for_each = local.networks
  to       = libvirt_network.tiers[each.key]
  id       = each.value.name
}

resource "libvirt_network" "tiers" {
  for_each = local.networks

  name      = each.value.name
  mode      = "nat"
  addresses = [each.value.cidr]
  autostart = true

  dns {
    enabled = true
  }

  dhcp {
    enabled = true
  }
}
EOF
```

### Step 2: Generate and Import

```bash
# Initialize
terraform init

# Generate configuration
terraform plan -generate-config-out=generated.tf

# Review generated config
cat generated.tf

# Import all networks
terraform apply

# Verify
terraform state list
```

---

## 📖 Section 6: Migration Planning

### Phased Migration Strategy

For large-scale migrations, use a phased approach:

```
Phase 1: Assessment
├── Inventory existing resources
├── Identify dependencies
├── Plan migration order
└── Document current state

Phase 2: Pilot
├── Import non-critical resources
├── Validate and test
├── Refine process
└── Document lessons learned

Phase 3: Incremental Migration
├── Import in logical groups
├── Validate after each group
├── Monitor for issues
└── Adjust as needed

Phase 4: Validation
├── Compare state to reality
├── Test terraform plan (no changes)
├── Document discrepancies
└── Fix any issues

Phase 5: Cleanup
├── Remove temporary resources
├── Optimize configuration
├── Update documentation
└── Train team
```

### Migration Best Practices

1. **Always backup state** before manipulation
2. **Test in non-production** first
3. **Import in small batches** for easier troubleshooting
4. **Validate after each import** with `terraform plan`
5. **Document the process** for future reference
6. **Use import blocks** (Terraform 1.5+) for version control
7. **Review generated config** before using it
8. **Keep moved blocks** until refactoring is complete
9. **Clean up** removed/moved blocks after apply
10. **Monitor infrastructure** during migration

---

## 🔨 Task 6: Complete Migration Exercise

Let's perform a complete migration scenario.

### Scenario

You have a legacy environment with:
- 3 manually created networks
- 2 VMs that need to be imported
- 1 network that needs to be handed off to another team
- Resources that need better naming

### Step 1: Assessment

```bash
cd /root/terraform/migration-demo

# Discover existing resources
virsh net-list --all
virsh list --all

# Document current state
cat > MIGRATION_PLAN.md << 'EOF'
# Migration Plan

## Current State
- legacy-net-1 (10.50.0.0/24) → Import as production_network
- legacy-net-2 (10.51.0.0/24) → Import as staging_network
- legacy-net-3 (10.52.0.0/24) → Hand off to network team
- legacy-vm-1 → Import as production_server
- legacy-vm-2 → Import as staging_server

## Migration Steps
1. Import networks with better names
2. Import VMs
3. Hand off legacy-net-3
4. Validate no changes needed
5. Clean up migration blocks

## Rollback Plan
- State backups in backup-*.tfstate
- Can restore with: terraform state push backup-<timestamp>.tfstate
EOF

cat MIGRATION_PLAN.md
```

### Step 2: Backup State

```bash
# Create backup
terraform state pull > backup-$(date +%Y%m%d-%H%M%S).tfstate

# Verify
ls -lh backup-*.tfstate
```

### Step 3: Create Import Configuration

```bash
cat > imports.tf << 'EOF'
# Import networks with better names
import {
  to = libvirt_network.production
  id = "legacy-net-1"
}

import {
  to = libvirt_network.staging
  id = "legacy-net-2"
}

import {
  to = libvirt_network.handoff
  id = "legacy-net-3"
}
EOF
```

### Step 4: Generate and Apply

```bash
# Initialize
terraform init

# Generate configuration
terraform plan -generate-config-out=generated.tf

# Review and create proper configuration
# (Edit generated.tf and save as networks.tf)

# Import
terraform apply

# Verify
terraform state list
terraform plan  # Should show no changes
```

### Step 5: Hand Off Network

```bash
# Add removed block for handoff network
cat >> main.tf << 'EOF'

# Hand off to network team
removed {
  from = libvirt_network.handoff

  lifecycle {
    destroy = false
  }
}
EOF

# Apply removal
terraform apply

# Verify network still exists but not in state
virsh net-list --all | grep legacy-net-3
terraform state list | grep handoff  # Should be empty
```

### Step 6: Final Validation

```bash
# Clean up migration blocks
# (Remove import and removed blocks from configuration)

# Final validation
terraform plan  # Should show no changes

# Document completion
echo "Migration completed: $(date)" >> MIGRATION_PLAN.md
```

---

## 🎓 Best Practices Summary

### Import Best Practices

1. ✅ **Use import blocks** (Terraform 1.5+) for version control
2. ✅ **Generate configuration** with `-generate-config-out`
3. ✅ **Review generated config** before using it
4. ✅ **Validate with terraform plan** after import
5. ✅ **Document import process** in comments or docs

### State Management Best Practices

1. ✅ **Always backup state** before manipulation
2. ✅ **Use moved blocks** for refactoring
3. ✅ **Use removed blocks** (1.7+) for decommissioning
4. ✅ **Test in non-production** first
5. ✅ **Clean up migration blocks** after apply

### Migration Best Practices

1. ✅ **Plan in phases** for large migrations
2. ✅ **Import in small batches** for easier troubleshooting
3. ✅ **Validate after each batch** with terraform plan
4. ✅ **Document the process** for future reference
5. ✅ **Monitor infrastructure** during migration

---

## ✅ Validation Checklist

Before completing this challenge, ensure you can:

- [ ] Import resources using import blocks
- [ ] Generate configuration from existing resources
- [ ] Use moved blocks to refactor safely
- [ ] Remove resources from state with removed blocks
- [ ] Manipulate state with CLI commands
- [ ] Import multiple resources with for_each
- [ ] Plan and execute a phased migration
- [ ] Validate imported resources with terraform plan
- [ ] Backup and restore state
- [ ] Document migration processes

---

## 🎉 Challenge Complete!

Congratulations! You've mastered import and migration strategies. You now know how to:

- ✅ Import existing infrastructure into Terraform
- ✅ Generate configuration automatically
- ✅ Refactor safely with moved blocks
- ✅ Remove resources declaratively with removed blocks
- ✅ Plan and execute large-scale migrations
- ✅ Validate imported resources
- ✅ Handle complex migration scenarios

### Key Takeaways

1. **Import blocks** (1.5+) are declarative and version-controlled
2. **Configuration generation** saves time and reduces errors
3. **moved blocks** enable safe refactoring
4. **removed blocks** (1.7+) provide declarative state removal
5. **Phased migration** reduces risk for large projects
6. **Always validate** with terraform plan after import
7. **Backup state** before any manipulation

### Next Steps

- **Challenge 5**: Skills Assessment - Test all your TF-200 knowledge
- **TF-300 Series**: Advanced testing, validation, and policy

---

## 📚 Additional Resources

- [Import Blocks Documentation](https://developer.hashicorp.com/terraform/language/import)
- [terraform import CLI](https://developer.hashicorp.com/terraform/cli/commands/import)
- [State Commands](https://developer.hashicorp.com/terraform/cli/commands/state)
- [Moved Blocks](https://developer.hashicorp.com/terraform/language/modules/develop/refactoring)
- [removed Blocks](https://developer.hashicorp.com/terraform/language/resources/syntax#removing-resources)

Ready to test your skills? Proceed to Challenge 5! 🚀
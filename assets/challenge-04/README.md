# Challenge 4: Import & Migration Strategies

This challenge demonstrates modern Terraform import and migration strategies for bringing existing infrastructure under Terraform management.

## Overview

Learn how to:
- Import existing resources using modern import blocks
- Safely refactor resources with moved blocks
- Hand off resources using removed blocks
- Perform bulk imports efficiently
- Plan and execute complete migrations

## Directory Structure

```
challenge-04/
├── import-example.tf              # Modern import blocks (Terraform 1.5+)
├── moved-example.tf               # Safe refactoring with moved blocks
├── removed-example.tf             # Resource handoff with removed blocks
├── bulk-import-example.tf         # Bulk import with for_each
├── complete-migration-example.tf  # End-to-end migration scenario
├── MIGRATION_PLAN.md             # Migration planning template
├── state-commands.sh             # State manipulation reference
└── README.md                     # This file
```

## Example Files

### 1. import-example.tf
Demonstrates modern import blocks (Terraform 1.5+):
```hcl
import {
  to = libvirt_network.legacy
  id = "legacy-network"
}

resource "libvirt_network" "legacy" {
  name      = "legacy-network"
  mode      = "nat"
  addresses = ["10.100.0.0/24"]
  # ... configuration
}
```

**Key Features:**
- Declarative import blocks
- Version-controlled imports
- Configuration generation with `-generate-config-out`
- No state file manipulation needed

**Usage:**
```bash
cp import-example.tf main.tf
terraform init
terraform plan -generate-config-out=generated.tf
terraform apply
```

### 2. moved-example.tf
Safe resource refactoring with moved blocks (Terraform 1.1+):
```hcl
moved {
  from = libvirt_network.legacy
  to   = libvirt_network.production
}

resource "libvirt_network" "production" {
  name = "legacy-network"  # Actual name unchanged
  # ... configuration
}
```

**Key Features:**
- Rename resources without destruction
- State updates only (no infrastructure changes)
- Prevents accidental resource recreation
- Clean up moved blocks after successful refactoring

**Usage:**
```bash
cp moved-example.tf main.tf
terraform init
terraform apply  # State updates only
# After verification, remove moved blocks
```

### 3. removed-example.tf
Resource handoff with removed blocks (Terraform 1.7+):
```hcl
removed {
  from = libvirt_network.database
  
  lifecycle {
    destroy = false  # Keep resource running
  }
}
```

**Key Features:**
- Remove from state but keep resource running
- Declarative state removal
- Useful for handing off to other teams
- Prevents accidental destruction

**Usage:**
```bash
cp removed-example.tf main.tf
terraform init
terraform apply  # Removes from state only
virsh net-list   # Verify resource still running
```

### 4. bulk-import-example.tf
Efficient bulk import with for_each:
```hcl
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
```

**Key Features:**
- Import multiple resources at once
- DRY principle for imports
- Scales to hundreds of resources
- Consistent naming patterns

**Usage:**
```bash
cp bulk-import-example.tf main.tf
terraform init
terraform plan -generate-config-out=generated.tf
terraform apply
```

### 5. complete-migration-example.tf
End-to-end migration scenario:
```hcl
# Step 1: Import legacy networks
import { ... }

# Step 2: Define resources
resource "libvirt_network" "production" { ... }

# Step 3: Hand off to other team
removed {
  from = libvirt_network.handoff
  lifecycle { destroy = false }
}
```

**Key Features:**
- Complete migration workflow
- Import + refactor + handoff
- Production-ready pattern
- Includes rollback strategy

**Usage:**
```bash
cp complete-migration-example.tf main.tf
# Follow step-by-step comments in file
```

## Supporting Files

### MIGRATION_PLAN.md
Comprehensive migration planning template:
- Current state assessment
- Target state definition
- Step-by-step migration plan
- Rollback procedures
- Risk assessment
- Communication plan
- Success criteria

**Usage:**
```bash
cp MIGRATION_PLAN.md my-migration-plan.md
# Fill in details for your specific migration
```

### state-commands.sh
Reference for Terraform state manipulation:
- State backup and restore
- State inspection commands
- State manipulation (mv, rm)
- Legacy CLI import
- Common workflows
- Troubleshooting
- Emergency recovery

**Usage:**
```bash
# Make executable
chmod +x state-commands.sh

# View specific section
grep -A 20 "State Backup" state-commands.sh

# Use as reference for commands
```

## Key Concepts

### Import Blocks (Terraform 1.5+)
Modern, declarative way to import resources:
- Version-controlled
- Supports for_each
- Generates configuration automatically
- No manual state manipulation

### moved Blocks (Terraform 1.1+)
Safe resource refactoring:
- Rename resources without destruction
- Move resources between modules
- State updates only
- Prevents accidental recreation

### removed Blocks (Terraform 1.7+)
Declarative state removal:
- Remove from state, keep resource running
- Useful for handoffs
- Prevents accidental destruction
- Version-controlled

### Configuration Generation
Automatic configuration creation:
```bash
terraform plan -generate-config-out=generated.tf
```
- Generates HCL from existing resources
- Saves time and reduces errors
- Review and refine generated code
- Merge into your configuration

## Best Practices

### Import Best Practices
1. **Always backup state first**
   ```bash
   terraform state pull > backup-$(date +%Y%m%d-%H%M%S).tfstate
   ```

2. **Use import blocks over CLI**
   - Declarative and version-controlled
   - Supports for_each for bulk imports
   - Easier to review and audit

3. **Generate configuration**
   ```bash
   terraform plan -generate-config-out=generated.tf
   ```

4. **Validate after import**
   ```bash
   terraform plan -detailed-exitcode
   ```

### State Management Best Practices
1. **Prefer declarative blocks**
   - Use moved blocks instead of `terraform state mv`
   - Use removed blocks instead of `terraform state rm`
   - Version-controlled and auditable

2. **Always backup before manipulation**
   - Keep backups for at least 30 days
   - Test restoration procedures
   - Document backup locations

3. **Validate changes**
   - Run `terraform plan` after state changes
   - Should show no changes if done correctly
   - Fix any drift immediately

### Migration Best Practices
1. **Plan thoroughly**
   - Use MIGRATION_PLAN.md template
   - Document current and target states
   - Identify dependencies
   - Create rollback plan

2. **Test in non-production**
   - Practice migration in dev/staging
   - Validate procedures
   - Time the migration
   - Document issues

3. **Communicate clearly**
   - Notify stakeholders
   - Schedule maintenance windows
   - Provide status updates
   - Document completion

4. **Validate thoroughly**
   - Check resource functionality
   - Verify dependent resources
   - Run integration tests
   - Monitor for issues

## Common Workflows

### Workflow 1: Import Single Resource
```bash
# 1. Create import block
cat > main.tf << 'EOF'
import {
  to = libvirt_network.imported
  id = "network-name"
}

resource "libvirt_network" "imported" {
  name = "network-name"
  # Minimal config
}
EOF

# 2. Generate full configuration
terraform plan -generate-config-out=generated.tf

# 3. Review and merge generated config
cat generated.tf

# 4. Import
terraform apply

# 5. Validate
terraform plan  # Should show no changes
```

### Workflow 2: Refactor Resource Names
```bash
# 1. Add moved block
cat >> main.tf << 'EOF'
moved {
  from = libvirt_network.old_name
  to   = libvirt_network.new_name
}
EOF

# 2. Update resource definition
# Change resource name in configuration

# 3. Apply refactoring
terraform apply  # State updates only

# 4. Validate
terraform plan  # Should show no changes

# 5. Clean up moved block
# Remove moved block from configuration
```

### Workflow 3: Hand Off Resource
```bash
# 1. Add removed block
cat >> main.tf << 'EOF'
removed {
  from = libvirt_network.handoff
  lifecycle { destroy = false }
}
EOF

# 2. Apply removal
terraform apply  # Removes from state only

# 3. Verify resource still running
virsh net-list | grep handoff

# 4. Clean up removed block
# Remove removed block from configuration
```

## Troubleshooting

### Import Fails
**Problem:** Import block fails with "resource not found"
**Solution:**
- Verify resource ID is correct
- Check resource exists: `virsh net-list`
- Ensure provider is configured correctly

### Configuration Drift After Import
**Problem:** `terraform plan` shows changes after import
**Solution:**
- Review generated configuration
- Update resource definition to match actual state
- Check for computed attributes
- Verify provider version compatibility

### State Corruption
**Problem:** State file appears corrupted
**Solution:**
```bash
# 1. Stop all terraform operations
# 2. Restore from backup
terraform state push backup-YYYYMMDD-HHMMSS.tfstate
# 3. Verify restoration
terraform state list
# 4. Validate
terraform plan
```

### moved Block Not Working
**Problem:** moved block causes resource recreation
**Solution:**
- Verify from/to addresses are correct
- Check resource exists in state: `terraform state list`
- Ensure resource definition matches
- Review Terraform version (requires 1.1+)

## Additional Resources

- [Terraform Import Documentation](https://www.terraform.io/language/import)
- [moved Blocks](https://www.terraform.io/language/modules/develop/refactoring)
- [removed Blocks](https://www.terraform.io/language/resources/syntax#removing-resources)
- [State Management](https://www.terraform.io/language/state)
- [Configuration Generation](https://www.terraform.io/cli/commands/plan#generate-config-out)
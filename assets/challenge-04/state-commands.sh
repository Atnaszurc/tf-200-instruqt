#!/bin/bash
# Terraform State Manipulation Commands Reference
# Use these commands carefully - always backup state first!

# ============================================================================
# State Backup and Restore
# ============================================================================

# Pull current state to local file (backup)
terraform state pull > backup-$(date +%Y%m%d-%H%M%S).tfstate

# Push state from local file (restore)
terraform state push backup-20240101-120000.tfstate

# ============================================================================
# State Inspection
# ============================================================================

# List all resources in state
terraform state list

# Show detailed information about a resource
terraform state show libvirt_network.production

# Show all state in JSON format
terraform state pull

# ============================================================================
# State Manipulation
# ============================================================================

# Move resource to new address (rename)
terraform state mv libvirt_network.old libvirt_network.new

# Move resource to module
terraform state mv libvirt_network.app module.networking.libvirt_network.app

# Move resource from module to root
terraform state mv module.networking.libvirt_network.app libvirt_network.app

# Move entire module
terraform state mv module.old_name module.new_name

# ============================================================================
# State Removal
# ============================================================================

# Remove resource from state (keeps resource running)
terraform state rm libvirt_network.database

# Remove all resources matching pattern
terraform state rm 'libvirt_network.*'

# Remove module and all its resources
terraform state rm module.networking

# ============================================================================
# State Import (Legacy CLI)
# ============================================================================

# Import single resource
terraform import libvirt_network.imported network-name

# Import resource into module
terraform import module.networking.libvirt_network.app app-network

# Import with for_each (requires key)
terraform import 'libvirt_network.tiers["tier1"]' tier1-network

# ============================================================================
# State Locking
# ============================================================================

# Force unlock state (use with caution!)
terraform force-unlock LOCK_ID

# ============================================================================
# State Replacement
# ============================================================================

# Replace resource (destroy and recreate)
terraform apply -replace=libvirt_network.production

# ============================================================================
# Best Practices
# ============================================================================

# 1. Always backup before manipulation
echo "Creating backup..."
terraform state pull > backup-$(date +%Y%m%d-%H%M%S).tfstate

# 2. Verify changes with plan
echo "Verifying no drift..."
terraform plan -detailed-exitcode

# 3. Use moved/removed blocks instead of CLI when possible
echo "Prefer declarative blocks over imperative commands"

# 4. Document state changes
echo "Document all state manipulations in version control"

# ============================================================================
# Common Workflows
# ============================================================================

# Workflow 1: Rename resource safely
echo "=== Rename Resource Workflow ==="
terraform state pull > backup.tfstate
terraform state mv libvirt_network.old libvirt_network.new
# Update configuration to match new name
terraform plan  # Should show no changes

# Workflow 2: Move resource to module
echo "=== Move to Module Workflow ==="
terraform state pull > backup.tfstate
terraform state mv libvirt_network.app module.networking.libvirt_network.app
# Update configuration to reference module
terraform plan  # Should show no changes

# Workflow 3: Remove resource from management
echo "=== Remove from Management Workflow ==="
terraform state pull > backup.tfstate
terraform state rm libvirt_network.database
# Resource continues running but not managed by Terraform

# Workflow 4: Import existing resource
echo "=== Import Existing Resource Workflow ==="
# Create resource configuration first
terraform import libvirt_network.imported network-name
terraform plan  # Adjust configuration to match actual resource

# ============================================================================
# Troubleshooting
# ============================================================================

# Check state file integrity
terraform state pull | jq . > /dev/null && echo "State file valid" || echo "State file corrupted"

# Compare two state files
diff <(terraform state pull | jq -S .) <(cat backup.tfstate | jq -S .)

# Find resource in state
terraform state list | grep network

# Get resource ID from state
terraform state show libvirt_network.production | grep "id ="

# ============================================================================
# Emergency Recovery
# ============================================================================

# If state is corrupted, restore from backup
echo "=== Emergency State Recovery ==="
# 1. Stop all terraform operations
# 2. Locate most recent backup
ls -lt backup-*.tfstate | head -1
# 3. Restore state
terraform state push backup-YYYYMMDD-HHMMSS.tfstate
# 4. Verify restoration
terraform state list
# 5. Run plan to check for drift
terraform plan

# ============================================================================
# Notes
# ============================================================================

# - State manipulation is powerful but dangerous
# - Always backup before making changes
# - Prefer declarative blocks (moved/removed) over CLI commands
# - Test in non-production first
# - Document all state changes
# - Keep state backups for at least 30 days

# Made with Bob

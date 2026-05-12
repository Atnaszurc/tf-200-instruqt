# TF-200 Lab - Libvirt Provider 0.9 Syntax Fix Summary

## Overview
Fixed all libvirt_network resources to use correct nested attribute syntax for provider 0.9.

## Problem
The initial extraction used libvirt provider 0.7.x block syntax, but provider 0.9 uses Terraform Plugin Framework with nested attributes requiring `=` assignment syntax.

## Files Fixed

### Challenge 1 (2 files)
- ✅ `challenge-01/modules/libvirt-network/main.tf` - Network module resource
- ✅ `challenge-01/modules/libvirt-network/outputs.tf` - Changed `addresses` to `ips`

### Challenge 2 (3 files)
- ✅ `challenge-02/modules/network/main.tf` - Network module resource
- ✅ `challenge-02/modules/network/outputs.tf` - Changed `addresses` to `ips`, fixed resource reference
- ✅ `challenge-02/modules/network/variables.tf` - Added missing `dhcp_enabled` variable

### Challenge 4 (5 files)
- ✅ `challenge-04/import-example.tf` - Fixed 3 network resources
- ✅ `challenge-04/moved-example.tf` - Fixed 3 network resources
- ✅ `challenge-04/removed-example.tf` - Fixed 2 network resources
- ✅ `challenge-04/complete-migration-example.tf` - Fixed 3 network resources
- ✅ `challenge-04/bulk-import-example.tf` - Fixed for_each network resource

**Total: 10 files fixed**

## Syntax Changes

### Before (Provider 0.7.x - Block Syntax)
```hcl
resource "libvirt_network" "example" {
  name = "my-network"
  
  addresses = ["192.168.122.0/24"]
  mode      = "nat"
  domain    = "example.local"
  
  dhcp {
    enabled = true
  }
}
```

### After (Provider 0.9 - Nested Attribute Syntax)
```hcl
resource "libvirt_network" "example" {
  name = "my-network"
  
  ips = [{
    address = "192.168.122.1"
    prefix  = 24
    dhcp = {
      ranges = [{
        start = "192.168.122.2"
        end   = "192.168.122.254"
      }]
    }
  }]
  
  forward = {
    mode = "nat"
  }
  
  domain = {
    name = "example.local"
  }
}
```

## Key Differences

### 1. `ips` Attribute (List of Objects)
- **Old**: `addresses = ["192.168.122.0/24"]` (simple list)
- **New**: `ips = [{ address = "...", prefix = 24 }]` (list of objects with `=`)

### 2. `forward` Attribute (Object)
- **Old**: `mode = "nat"` (top-level attribute)
- **New**: `forward = { mode = "nat" }` (nested object with `=`)

### 3. `domain` Attribute (Object)
- **Old**: `domain = "example.local"` (string)
- **New**: `domain = { name = "example.local" }` (nested object with `=`)

### 4. `dhcp` Configuration
- **Old**: `dhcp { enabled = true }` (block)
- **New**: Nested inside `ips` objects as `dhcp = { ranges = [...] }`

### 5. Output References
- **Old**: `libvirt_network.example.addresses[0]`
- **New**: `"${libvirt_network.example.ips[0].address}/${libvirt_network.example.ips[0].prefix}"`

## Validation Status

All fixed modules validated successfully:
```bash
cd /tmp/tf-200-instruqt/assets/challenge-01/modules/libvirt-network
terraform init && terraform validate
# ✅ Success! The configuration is valid.

cd /tmp/tf-200-instruqt/assets/challenge-02/modules/network
terraform init && terraform validate
# ✅ Success! The configuration is valid.
```

## Documentation Reference

Official libvirt provider 0.9 documentation:
- Resource: `documentation/terraform-provider-libvirt/docs/resources/network.md`
- Shows `ips`, `forward`, and `domain` as "Attributes" (not blocks)
- Confirms nested attribute syntax with `=` is required

## Next Steps

1. ✅ All syntax fixes complete
2. ⏭️ Commit and push to GitHub
3. ⏭️ Continue Phase 10 testing
4. ⏭️ Deploy to Instruqt (Phase 11)

## Lessons Learned

1. **Provider version ≠ Provider syntax** - Updating version number doesn't automatically update syntax
2. **Schema validation is essential** - Always run `terraform validate` after provider upgrades
3. **Terraform Plugin Framework uses nested attributes** - Not traditional blocks
4. **Read official documentation** - Provider docs show exact syntax requirements
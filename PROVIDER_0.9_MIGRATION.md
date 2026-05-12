# Libvirt Provider 0.9 Migration Summary

## Overview
Complete migration of all Terraform configurations from libvirt provider 0.7 to 0.9.
This was a comprehensive schema migration affecting networks, volumes, pools, and domains.

## Migration Date
2026-05-12

## Changes Made

### 1. Network Resources (11 files)
**Schema Change**: Block syntax → Nested attribute syntax with `=`

**Before**:
```hcl
resource "libvirt_network" "example" {
  addresses = ["192.168.100.0/24"]
  
  dhcp {
    enabled = true
  }
}
```

**After**:
```hcl
resource "libvirt_network" "example" {
  ips = [{
    address = "192.168.100.1"
    prefix  = 24
    dhcp = {
      ranges = [{
        start = "192.168.100.2"
        end   = "192.168.100.254"
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

**Files Updated**:
- challenge-01/modules/libvirt-network/main.tf + outputs.tf
- challenge-02/modules/network/main.tf + outputs.tf + variables.tf
- challenge-02/modules/conditional-vm/main.tf
- challenge-04/import-example.tf
- challenge-04/moved-example.tf
- challenge-04/removed-example.tf
- challenge-04/complete-migration-example.tf
- challenge-04/bulk-import-example.tf

### 2. Volume Resources (4 files)
**Schema Changes**:
- `size` → `capacity` (in bytes)
- `format` → `target = { format = { type = "qcow2" } }`

**Before**:
```hcl
resource "libvirt_volume" "example" {
  name   = "disk.qcow2"
  pool   = "default"
  format = "qcow2"
  size   = 1073741824
}
```

**After**:
```hcl
resource "libvirt_volume" "example" {
  name     = "disk.qcow2"
  pool     = "default"
  capacity = 1073741824

  target = {
    format = {
      type = "qcow2"
    }
  }
}
```

**Files Updated**:
- challenge-01/modules/libvirt-vm/main.tf
- challenge-02/modules/storage/main.tf
- challenge-02/modules/canary-deployment/main.tf
- challenge-02/modules/conditional-vm/main.tf

### 3. Pool Resources (1 file)
**Schema Change**: `path` → `target = { path = "..." }`

**Before**:
```hcl
resource "libvirt_pool" "example" {
  name = "storage"
  type = "dir"
  path = "/var/lib/libvirt/images"
}
```

**After**:
```hcl
resource "libvirt_pool" "example" {
  name = "storage"
  type = "dir"
  
  target = {
    path = "/var/lib/libvirt/images"
  }
}
```

**Files Updated**:
- challenge-02/modules/storage/main.tf

### 4. Domain Resources (4 files)
**Schema Changes**:
- Added required `type = "kvm"` attribute
- `os`, `disk`, `network_interface`, `console` blocks → nested attributes in `devices = { }`
- Block syntax → nested attribute syntax with `=`

**Before**:
```hcl
resource "libvirt_domain" "example" {
  name   = "vm"
  memory = 512
  vcpu   = 1

  os {
    type = "hvm"
  }

  disk {
    volume_id = libvirt_volume.disk.id
  }

  network_interface {
    network_id = libvirt_network.net.id
  }

  console {
    type        = "pty"
    target_type = "serial"
    target_port = "0"
  }
}
```

**After**:
```hcl
resource "libvirt_domain" "example" {
  name   = "vm"
  type   = "kvm"
  memory = 512
  vcpu   = 1

  os = {
    type    = "hvm"
    arch    = "x86_64"
    machine = "pc"
  }

  devices = {
    disks = [{
      volume_id = libvirt_volume.disk.id
    }]

    interfaces = [{
      network_id = libvirt_network.net.id
    }]

    consoles = [{
      type        = "pty"
      target_type = "serial"
      target_port = "0"
    }]
  }
}
```

**Files Updated**:
- challenge-01/modules/libvirt-vm/main.tf
- challenge-02/modules/compute/main.tf
- challenge-02/modules/canary-deployment/main.tf
- challenge-02/modules/conditional-vm/main.tf

### 5. Output References (1 file)
**Schema Change**: `network_interface` → `devices.interfaces`

**Before**:
```hcl
output "network_interfaces" {
  value = libvirt_domain.vm.network_interface
}
```

**After**:
```hcl
output "network_interfaces" {
  value = libvirt_domain.vm.devices.interfaces
}
```

**Files Updated**:
- challenge-01/modules/libvirt-vm/outputs.tf

### 6. Syntax Fixes (1 file)
**Issue**: Multi-line ternary expressions with incorrect line breaks

**Before**:
```hcl
locals {
  stable_count = var.enable_canary ? 
    floor(var.total_instances * (1 - var.canary_percentage / 100)) : 
    var.total_instances
}
```

**After**:
```hcl
locals {
  stable_count = var.enable_canary ? floor(var.total_instances * (1 - var.canary_percentage / 100)) : var.total_instances
}
```

**Files Updated**:
- challenge-02/modules/canary-deployment/main.tf

## Validation Results

All 10 modules pass `terraform validate`:

✅ challenge-01/modules/libvirt-network
✅ challenge-01/modules/app-config
✅ challenge-01/modules/libvirt-vm
✅ challenge-02/modules/conditional-vm
✅ challenge-02/modules/app-stack
✅ challenge-02/modules/network
✅ challenge-02/modules/storage
✅ challenge-02/modules/compute
✅ challenge-02/modules/canary-deployment
✅ challenge-03/modules/yaml-validator

## Total Files Modified

- **Network resources**: 11 files
- **Volume resources**: 4 files
- **Pool resources**: 1 file
- **Domain resources**: 4 files
- **Output files**: 1 file
- **Syntax fixes**: 1 file

**Total**: 22 files updated across the entire lab

## Key Learnings

1. **Provider 0.9 uses Terraform Plugin Framework** which requires nested attributes with `=` syntax instead of blocks
2. **All resource types changed**, not just one - comprehensive migration required
3. **Schema validation is critical** - used `terraform providers schema -json` to understand exact requirements
4. **Nested objects can be deeply nested** - e.g., `target.format.type` not just `target.format`
5. **Output references must be updated** to match new schema paths

## Testing Approach

1. Updated provider version to `~> 0.9` in all modules
2. Fixed syntax errors incrementally by resource type
3. Validated each module with `terraform init && terraform validate`
4. Ensured all 10 modules pass validation before committing

## Compatibility

- **Terraform Version**: >= 1.14
- **Libvirt Provider**: ~> 0.9 (tested with 0.9.7)
- **Breaking Changes**: Yes - not backward compatible with provider 0.7

## Next Steps

1. Deploy updated lab to Instruqt
2. Test all challenges end-to-end
3. Update any documentation referencing old syntax

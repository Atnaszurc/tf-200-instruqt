# Libvirt Provider 0.9 Syntax Note

## Important: Assignment Examples vs. Working Code

The assignment files for Challenges 1-3 contain **simplified examples** using pre-0.9 syntax for educational clarity. However, the **actual working code** in the assets folders uses the correct libvirt provider 0.9+ syntax.

### Why the Difference?

1. **Learning Focus**: Early challenges focus on module concepts, not provider syntax details
2. **Simplified Examples**: Pre-0.9 syntax is easier to read and understand for beginners
3. **Working Solutions**: All solve scripts and assets use correct 0.9+ syntax

### Correct Libvirt 0.9+ Syntax

When working with libvirt provider 0.9+, use this syntax:

#### For Volumes with Backing Store
```hcl
resource "libvirt_volume" "vm_disk" {
  name     = "vm-disk.qcow2"
  pool     = "default"
  capacity = 1073741824  # 1GB

  target = {
    format = {
      type = "qcow2"
    }
  }

  backing_store = {
    path = libvirt_volume.base.id
    format = {
      type = "qcow2"
    }
  }
}
```

#### For Domains with Volume Disks
```hcl
resource "libvirt_domain" "vm" {
  name   = "my-vm"
  memory = 2048
  vcpu   = 2
  type   = "kvm"

  os = {
    type = "hvm"
  }

  devices = {
    disks = [{
      source = {
        volume = {
          pool   = "default"
          volume = libvirt_volume.vm_disk.id
        }
      }
      target = {
        dev = "vda"
        bus = "virtio"
      }
    }]

    interfaces = [{
      network = {
        network = libvirt_network.main.name
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
```

#### For Domains with File-Based Disks
```hcl
resource "libvirt_domain" "legacy" {
  name   = "legacy-vm"
  memory = 512
  vcpu   = 1
  type   = "kvm"

  os = {
    type = "hvm"
  }

  devices = {
    disks = [{
      source = {
        file = {
          file = "/var/lib/libvirt/images/legacy/vm.qcow2"
        }
      }
      target = {
        dev = "vda"
        bus = "virtio"
      }
    }]

    network_interfaces = [{
      network_id = var.network_uuid
    }]

    consoles = [{
      type        = "pty"
      target_type = "serial"
      target_port = 0
    }]
  }
}
```

### Key Differences from Pre-0.9

| Pre-0.9 (Old) | 0.9+ (Current) |
|---------------|----------------|
| `disk { volume_id = ... }` | `devices = { disks = [{ source = { volume = { pool = "default", volume = ... } } }] }` |
| `network_interface { ... }` | `devices = { interfaces = [{ ... }] }` |
| `console { ... }` | `devices = { console = [{ ... }] }` |
| No `os` block required | `os = { type = "hvm" }` required |
| No `target` in disks | `target = { dev = "vda", bus = "virtio" }` required |

### Where to Find Correct Examples

- **Challenge 5 Assets**: `/root/lab-assets/05-skills-assessment/` - Complete working example
- **TF-100 Challenge 5**: Reference implementation with all correct syntax
- **This File**: Quick reference for common patterns

### Network CIDR Ranges

Use `192.168.x.x` ranges instead of `10.x.x.x` to avoid conflicts with existing interfaces:

- Dev: `192.168.10-12.0/24`
- Staging: `192.168.20-22.0/24`
- Prod: `192.168.30-32.0/24`
- Legacy: `192.168.100.0/24`

### Import Considerations

When importing legacy networks, pass the UUID as a variable instead of managing the network resource directly to avoid provider inconsistencies:

```hcl
# In main.tf
variable "legacy_network_uuid" {
  description = "UUID of the existing legacy network"
  type        = string
}

# In solve script
NETWORK_UUID=$(virsh net-uuid legacy-app-network)
cat > terraform.tfvars << EOF
legacy_network_uuid = "$NETWORK_UUID"
EOF
```

## Summary

- **Assignment examples**: Simplified for learning
- **Working code**: Uses correct 0.9+ syntax
- **When in doubt**: Check the assets folder for the correct implementation
- **Reference**: This file and TF-100 Challenge 5 for complete examples
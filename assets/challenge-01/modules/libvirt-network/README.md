# Libvirt Network Module

Creates a Libvirt virtual network.

## Usage

```hcl
module "network" {
  source = "./modules/libvirt-network"
  
  name         = "app-network"
  mode         = "nat"
  addresses    = ["192.168.100.0/24"]
  dhcp_enabled = true
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| name | Network name | string | n/a | yes |
| mode | Network mode | string | "nat" | no |
| domain | DNS domain | string | "local" | no |
| addresses | IP ranges | list(string) | ["192.168.100.0/24"] | no |
| dhcp_enabled | Enable DHCP | bool | true | no |
| autostart | Auto-start network | bool | true | no |

## Outputs

| Name | Description |
|------|-------------|
| id | Network ID |
| name | Network name |
| bridge | Bridge interface |
| addresses | IP ranges |
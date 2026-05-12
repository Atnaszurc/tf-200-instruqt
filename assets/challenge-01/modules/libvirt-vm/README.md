# Libvirt VM Module

Creates a Libvirt virtual machine.

## Usage

```hcl
module "vm" {
  source = "./modules/libvirt-vm"
  
  name       = "web-server"
  memory     = 512
  vcpu       = 1
  network_id = module.network.id
}
```

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|----------|
| name | VM name | string | n/a | yes |
| memory | Memory in MB | number | 512 | no |
| vcpu | Number of vCPUs | number | 1 | no |
| network_id | Network ID | string | n/a | yes |
| autostart | Auto-start VM | bool | false | no |

## Outputs

| Name | Description |
|------|-------------|
| id | VM ID |
| name | VM name |
| network_interfaces | Network interfaces |
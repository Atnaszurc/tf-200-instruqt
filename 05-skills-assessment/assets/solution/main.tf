
## Usage

```hcl
module "app_stack" {
  source = "./modules/app-stack"
  
  config = yamldecode(file("config/${var.environment}.yaml"))
  
  enable_canary      = true
  canary_percentage  = 20
}
```

# TF-200: Terraform Modules & Patterns Lab

**Level**: Intermediate (200)  
**Duration**: ~6 hours  
**Prerequisites**: TF-100 Terraform Fundamentals  
**Platform**: Instruqt with Libvirt/QEMU

---

## 🎯 Lab Overview

Welcome to **TF-200: Terraform Modules & Patterns**! This hands-on lab transforms you from writing basic Terraform configurations to creating professional, reusable infrastructure components. You'll master module design, advanced patterns, and enterprise-grade practices that are essential for production Terraform usage.

### What Makes This Lab Different

- ✅ **Hands-On Learning**: Real infrastructure with Libvirt/QEMU
- ✅ **Self-Service**: Complete all exercises independently
- ✅ **Pre-Configured**: Terraform and Libvirt ready to use
- ✅ **Progressive**: Build from simple to complex
- ✅ **Enterprise-Ready**: Production patterns and best practices
- ✅ **Skip-Enabled**: Restart at any challenge

---

## 📚 What You'll Learn

### Core Competencies

After completing this lab, you will be able to:

- ✅ **Design Professional Modules**: Create well-structured, reusable infrastructure components
- ✅ **Implement Module Composition**: Build complex infrastructure from simple building blocks
- ✅ **Use Advanced Patterns**: Implement enterprise deployment strategies
- ✅ **Drive Configuration with YAML**: Create flexible, data-driven infrastructure
- ✅ **Import Existing Infrastructure**: Bring existing resources under Terraform management
- ✅ **Migrate and Refactor**: Safely restructure Terraform code
- ✅ **Collaborate with Teams**: Share and version modules effectively

### Skills You'll Master

**Module Design**:
- Professional module structure
- Input variable design (required vs optional)
- Output design for composition
- Optional attributes (Terraform 1.3+)
- Dynamic blocks for flexibility
- Module documentation standards
- Versioning strategies

**Advanced Patterns**:
- Private registry publishing
- Canary deployment patterns
- Blue-green deployments
- Module composition techniques
- Enterprise collaboration

**YAML-Driven Infrastructure**:
- YAML parsing with `yamldecode()`
- JSON parsing with `jsondecode()`
- Data-driven resource creation
- Configuration management
- Multi-environment patterns

**Import & Migration**:
- Import blocks (Terraform 1.5+)
- `terraform import` CLI command
- State migration strategies
- `moved` blocks for refactoring (Terraform 1.1+)
- `removed` blocks (Terraform 1.7+)
- Safe migration practices

---

## 🗂️ Lab Structure

This lab consists of 4 comprehensive challenges plus a final skills assessment:

### Challenge 1: Module Design & Composition (90 minutes)
**What You'll Build**: Professional network and VM modules with composition

**Topics Covered**:
- Module design principles and best practices
- Input variable design (required vs optional)
- Output design for composition
- Optional attributes (Terraform 1.3+)
- Dynamic blocks for flexibility
- Module composition patterns
- `moved` blocks for refactoring (Terraform 1.1+)
- Variables/locals in module source & version (Terraform 1.15+)

**Hands-On**:
- Design a network module from scratch
- Create a VM module that uses the network module
- Implement optional attributes for flexibility
- Use dynamic blocks for complex configurations
- Compose modules together
- Refactor code with `moved` blocks

---

### Challenge 2: Advanced Module Patterns (90 minutes)
**What You'll Build**: Enterprise deployment patterns and registry integration

**Topics Covered**:
- Private registry patterns (HCP Terraform/Terraform Cloud)
- Module publishing and versioning
- Canary deployment implementation
- Blue-green deployment patterns
- Traffic splitting strategies
- Rollback procedures
- Module discovery and access control

**Hands-On**:
- Understand private registry concepts
- Implement canary deployment pattern
- Test deployment strategies
- Practice rollback procedures
- Version modules semantically

---

### Challenge 3: YAML-Driven Configuration (90 minutes)
**What You'll Build**: Flexible, data-driven infrastructure

**Topics Covered**:
- YAML parsing with `yamldecode()`
- JSON parsing with `jsondecode()`
- YAML-driven resource creation
- Using `locals` with YAML data
- `for_each` with YAML configurations
- Complex YAML structures
- YAML validation strategies
- Multi-environment patterns

**Hands-On**:
- Create YAML-driven network configurations
- Build VM infrastructure from YAML files
- Implement multi-environment setup
- Validate YAML configurations
- Create reusable YAML patterns

---

### Challenge 4: Import & Migration Strategies (90 minutes)
**What You'll Build**: Import existing infrastructure and migrate code

**Topics Covered**:
- Import blocks (Terraform 1.5+)
- `terraform import` CLI command
- Importing Libvirt resources
- State migration strategies
- `moved` blocks for refactoring
- `removed` blocks (Terraform 1.7+)
- Resource renaming
- Module refactoring
- Safe migration practices

**Hands-On**:
- Import existing Libvirt resources
- Use import blocks for declarative imports
- Migrate resources between modules
- Refactor code with `moved` blocks
- Use `removed` blocks to stop managing resources
- Practice safe state manipulation

---

### Challenge 5: Skills Assessment (120 minutes)
**What You'll Build**: Real-world scenario requiring all TF-200 skills

**Format**: No step-by-step instructions - test your knowledge!

**Requirements**:
- Design and create modules
- Implement module composition
- Use YAML-driven configuration
- Import existing infrastructure
- Apply advanced patterns

**Success Criteria**: Comprehensive validation of all concepts

---

## 🚀 Getting Started

### Prerequisites

Before starting this lab, you must have:

1. **Completed TF-100** or have equivalent knowledge:
   - Writing Terraform configurations
   - Using variables and loops
   - Managing infrastructure resources
   - Terraform state concepts
   - Basic CLI operations

2. **Comfortable with**:
   - HCL syntax
   - Terraform workflow (init, plan, apply)
   - Resource dependencies
   - State management
   - Basic debugging

3. **Understanding of**:
   - Infrastructure as Code principles
   - Version control concepts
   - YAML/JSON formats
   - Module concepts (even if not expert)

### What's Included

Your lab environment comes pre-configured with:

- ✅ **Terraform** (latest stable, 1.15+)
- ✅ **Libvirt/QEMU** (nested virtualization enabled)
- ✅ **Code Editor** (syntax highlighting, file browser)
- ✅ **Terminal** (bash shell with autocomplete)
- ✅ **Example Code** (pre-populated in workspace)
- ✅ **YAML Tools** (yamllint for validation)
- ✅ **Git** (for version control examples)

### Lab Environment

**VM Specifications**:
- Machine Type: n1-standard-8 (8 vCPUs, 30GB RAM)
- Nested Virtualization: Enabled
- Operating System: Ubuntu 24.04 LTS
- Shell: Bash

**Workspace**:
- Location: `/root/terraform-workspace`
- Pre-populated: Example code for each challenge
- Persistent: Within lab session only

**Time Limits**:
- Total Time: 9 hours (idle timeout)
- Estimated Completion: 6-8 hours
- Skip Enabled: Yes (restart at any challenge)

---

## 💡 How to Use This Lab

### Interface Overview

You have two main interfaces:

1. **Terminal Tab**:
   - Run Terraform commands
   - Execute shell commands
   - View command output
   - Navigate filesystem

2. **Code Editor Tab**:
   - View and edit Terraform files
   - Browse file structure
   - Syntax highlighting
   - File management

### Workflow

For each challenge:

1. **Read Instructions**: Carefully review the assignment
2. **Examine Examples**: Check pre-populated code
3. **Experiment**: Try commands and modifications
4. **Complete Tasks**: Follow the requirements
5. **Validate**: Run check scripts to verify
6. **Learn**: Understand why things work

### Tips for Success

✅ **Use Both Tabs**: Switch between terminal and editor  
✅ **Read Carefully**: Instructions contain all needed information  
✅ **Experiment**: Try things, break things, learn  
✅ **Use Console**: `terraform console` is great for testing  
✅ **Check Often**: Validate your work frequently  
✅ **Take Notes**: Document what you learn  
✅ **Ask Why**: Understand concepts, not just commands  

### Common Commands

```bash
# Initialize Terraform
terraform init

# Validate configuration
terraform validate

# Plan changes
terraform plan

# Apply changes
terraform apply

# Test expressions
terraform console

# Format code
terraform fmt

# Show state
terraform show

# List resources
terraform state list

# Import resource
terraform import <address> <id>
```

---

## 📖 Learning Objectives

### By Challenge

#### After Challenge 1, you will:
- Design modules following industry best practices
- Implement module composition (modules calling modules)
- Use optional attributes effectively (Terraform 1.3+)
- Create dynamic blocks for flexibility
- Version modules properly
- Document modules professionally
- Refactor code with `moved` blocks

#### After Challenge 2, you will:
- Understand private registry concepts
- Implement canary deployment patterns
- Implement blue-green deployment patterns
- Version modules semantically
- Collaborate with teams using modules
- Manage module dependencies

#### After Challenge 3, you will:
- Parse and use YAML configuration files
- Parse and use JSON configuration files
- Create YAML-driven infrastructure
- Separate configuration from logic
- Implement multi-environment patterns
- Validate YAML configurations
- Organize configuration files effectively

#### After Challenge 4, you will:
- Import existing infrastructure into Terraform
- Use import blocks (Terraform 1.5+)
- Migrate resources between modules
- Refactor code safely with `moved` blocks
- Use `removed` blocks to stop managing resources
- Rename resources without recreation
- Perform safe state operations

---

## 🎓 Success Criteria

You've successfully completed TF-200 when you can:

- [ ] Design and create reusable modules
- [ ] Compose modules to build complex infrastructure
- [ ] Implement advanced deployment patterns
- [ ] Create YAML-driven configurations
- [ ] Import existing infrastructure into Terraform
- [ ] Safely refactor and migrate Terraform code
- [ ] Collaborate with teams using modules
- [ ] Document modules professionally
- [ ] Version modules semantically
- [ ] Apply all concepts in real-world scenarios

---

## 🔄 What's Next?

### After TF-200

Once you complete this lab, you're ready for:

1. **TF-300: Testing, Validation & Policy** (Advanced)
   - Input validation techniques
   - Pre/post conditions
   - Terraform test framework
   - Policy as code (OPA/Rego)
   - Workspaces and remote state
   - Advanced functions

2. **TF-400: HCP Terraform & Enterprise** (Expert)
   - HCP Terraform fundamentals
   - Remote runs and VCS integration
   - Security and access control
   - Sentinel policy as code
   - Terraform Stacks

3. **Cloud Provider Modules** (Optional)
   - AWS-200: Apply concepts to AWS
   - AZ-200: Apply concepts to Azure
   - GCP-200: Apply concepts to GCP
   - MC-300: Multi-cloud patterns

4. **Real-World Projects**:
   - Build a module library for your organization
   - Create multi-environment infrastructure
   - Implement GitOps workflows
   - Contribute to open-source modules

---

## 💡 Best Practices

### Module Design Principles

1. **Single Responsibility**: Each module should do one thing well
2. **Composability**: Modules should work together seamlessly
3. **Flexibility**: Use variables and optional attributes
4. **Documentation**: Clear README with examples
5. **Versioning**: Semantic versioning for stability
6. **Testing**: Validate modules work as expected

### Common Pitfalls to Avoid

- ❌ Creating overly complex modules
- ❌ Not documenting module inputs/outputs
- ❌ Hardcoding values that should be variables
- ❌ Not versioning modules
- ❌ Skipping module testing
- ❌ Poor variable naming conventions
- ❌ Not using optional attributes when appropriate
- ❌ Ignoring state migration best practices

### Tips for Module Development

✅ **Start Simple**: Begin with small modules and grow complexity  
✅ **Document Everything**: Good documentation is as important as good code  
✅ **Version Properly**: Use semantic versioning for modules  
✅ **Test Thoroughly**: Test modules in isolation before composition  
✅ **Think Reusability**: Design for multiple use cases, not just one  
✅ **Use Examples**: Provide working examples in module documentation  
✅ **Follow Conventions**: Stick to Terraform naming and structure standards  

---

## 🐛 Troubleshooting

### Common Issues

**Module Not Found**:
```bash
# Ensure module path is correct
terraform init

# For local modules, use relative paths
module "example" {
  source = "./modules/example"
}
```

**Module Version Conflicts**:
```bash
# Clear module cache
rm -rf .terraform/modules/
terraform init
```

**Import Failures**:
```bash
# Verify resource ID format
terraform import libvirt_domain.vm <domain-name>

# Check provider documentation for correct ID format
```

**State Migration Issues**:
```bash
# Always backup state before migration
terraform state pull > backup.tfstate

# Use moved blocks for safe refactoring
```

**YAML Parsing Errors**:
```bash
# Validate YAML syntax
yamllint config.yaml

# Test in terraform console
terraform console
> yamldecode(file("config.yaml"))
```

### Getting Help

If you encounter issues:

1. **Read Error Messages**: They often contain the solution
2. **Check Syntax**: Use `terraform validate`
3. **Review Examples**: Compare with pre-populated code
4. **Use Console**: Test expressions in `terraform console`
5. **Check State**: Use `terraform state list` and `terraform show`
6. **Read Docs**: Links to official documentation provided

---

## 📚 Additional Resources

### Official Documentation

- [Terraform Modules](https://www.terraform.io/language/modules)
- [Module Development](https://www.terraform.io/language/modules/develop)
- [Terraform Registry](https://registry.terraform.io/)
- [Module Composition](https://www.terraform.io/language/modules/develop/composition)
- [Import Blocks](https://www.terraform.io/language/import)
- [Moved Blocks](https://www.terraform.io/language/modules/develop/refactoring)
- [Removed Blocks](https://www.terraform.io/language/resources/syntax#removing-resources)

### Recommended Reading

- [Terraform Module Best Practices](https://www.terraform.io/language/modules/develop/best-practices)
- [Module Structure](https://www.terraform.io/language/modules/develop/structure)
- [Publishing Modules](https://www.terraform.io/language/modules/develop/publish)
- [Semantic Versioning](https://semver.org/)

### Community Modules

- [Terraform AWS Modules](https://github.com/terraform-aws-modules)
- [Azure Verified Modules](https://azure.github.io/Azure-Verified-Modules/)
- [Google Cloud Modules](https://github.com/terraform-google-modules)

---

## 📊 Lab Statistics

- **Total Challenges**: 5 (4 learning + 1 assessment)
- **Estimated Time**: 6-8 hours
- **Hands-On Labs**: 25+
- **Code Examples**: 60+
- **Module Patterns**: 15+
- **Terraform Version**: 1.15+
- **Skip Enabled**: Yes
- **Timeout**: 9 hours

---

## 🎯 Real-World Applications

### What You Can Build

After TF-200, you can:

- **Module Libraries**: Create organization-wide module collections
- **Multi-Environment Infrastructure**: Dev, staging, production from one codebase
- **Self-Service Infrastructure**: Enable teams to deploy standardized infrastructure
- **GitOps Workflows**: Implement infrastructure CI/CD pipelines
- **Migration Projects**: Import and manage existing infrastructure
- **Enterprise Patterns**: Implement advanced deployment strategies

### Industry Use Cases

- **Startups**: Rapid infrastructure deployment with reusable modules
- **Enterprises**: Standardized infrastructure across teams
- **Consultancies**: Reusable modules for multiple clients
- **DevOps Teams**: Self-service infrastructure platforms
- **Cloud Migrations**: Import and manage existing resources

---

## 🙏 Acknowledgments

- HashiCorp for Terraform and module best practices
- The Terraform community for module patterns
- All contributors who help improve this lab

---

## 📜 License

This lab is part of the hashi-training project and is licensed under the MIT License.

---

**Ready to begin?** Start Challenge 1 and master Terraform modules! 🚀

**Need a refresher?** Review TF-100 concepts before starting.

**Questions?** All information needed is provided in each challenge.

---

*Last Updated: 2026-05-08*  
*Lab Version: 1.0*  
*Terraform Version: 1.15+*

---

**Made with ❤️ for the Terraform community**

# Made with Bob
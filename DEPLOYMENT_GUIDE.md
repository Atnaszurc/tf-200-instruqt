# TF-200 Modules Lab - Deployment Guide

This guide provides instructions for deploying the TF-200 Modules Lab to Instruqt.

## Prerequisites

- Instruqt account with appropriate permissions
- Instruqt CLI installed (`instruqt` command)
- Git repository access
- Basic understanding of Instruqt platform

## Lab Overview

**Track Name**: TF-200: Terraform Modules & Patterns  
**Duration**: ~4-5 hours  
**Difficulty**: Intermediate  
**Prerequisites**: TF-100 Fundamentals Lab

### Challenges

1. **Module Design & Composition** (60 min)
   - Module structure and best practices
   - Module composition patterns
   - Using `moved` blocks for refactoring

2. **Advanced Module Patterns** (60 min)
   - Nested module hierarchies
   - Conditional resources
   - For_each vs count
   - Canary deployment patterns

3. **YAML-Driven Configuration** (60 min)
   - Using `yamldecode()` function
   - Dynamic resource creation from YAML
   - Multi-environment patterns
   - YAML validation

4. **Import & Migration Strategies** (60 min)
   - Import blocks (Terraform 1.5+)
   - Configuration generation
   - Moved blocks for refactoring
   - Removed blocks (Terraform 1.7+)

5. **Skills Assessment** (90 min)
   - Comprehensive assessment
   - No step-by-step instructions
   - Multi-tier architecture
   - 100-point scoring system

## Pre-Deployment Checklist

### 1. Verify Lab Structure

```bash
cd instruqt/iac-bootcamp/tf-200-modules-lab

# Check directory structure
tree -L 2

# Expected structure:
# .
# ├── track.yml
# ├── config.yml
# ├── README.md
# ├── .gitignore
# ├── BEST_PRACTICES.md
# ├── COMMON_MISTAKES.md
# ├── TROUBLESHOOTING.md
# ├── DEPLOYMENT_GUIDE.md
# ├── track_scripts/
# │   ├── setup-workstation
# │   └── cleanup-workstation
# ├── 01-module-design/
# │   ├── assignment.md
# │   ├── setup-workstation
# │   ├── check-workstation
# │   └── solve-workstation
# ├── 02-advanced-patterns/
# │   ├── assignment.md
# │   ├── setup-workstation
# │   ├── check-workstation
# │   └── solve-workstation
# ├── 03-yaml-configuration/
# │   ├── assignment.md
# │   ├── setup-workstation
# │   ├── check-workstation
# │   └── solve-workstation
# ├── 04-import-migration/
# │   ├── assignment.md
# │   ├── setup-workstation
# │   ├── check-workstation
# │   └── solve-workstation
# └── 05-skills-assessment/
#     ├── assignment.md
#     ├── setup-workstation
#     ├── check-workstation
#     └── solve-workstation
```

### 2. Verify Script Permissions

```bash
# Make all scripts executable
find . -name "setup-workstation" -exec chmod +x {} \;
find . -name "check-workstation" -exec chmod +x {} \;
find . -name "solve-workstation" -exec chmod +x {} \;
find . -name "cleanup-workstation" -exec chmod +x {} \;

# Verify permissions
find . -type f -name "*-workstation" -exec ls -l {} \;
```

### 3. Validate Configuration Files

```bash
# Validate track.yml
cat track.yml | grep -E "^(slug|title|teaser|description):"

# Validate config.yml
cat config.yml | grep -E "^version:"

# Check for required fields
grep -q "slug: tf-200-modules" track.yml && echo "✓ Slug correct" || echo "✗ Slug missing"
grep -q "version: \"2\"" config.yml && echo "✓ Version correct" || echo "✗ Version incorrect"
```

### 4. Test Scripts Locally (Optional)

```bash
# Test setup script for Challenge 1
cd 01-module-design
./setup-workstation

# Verify setup
ls -la /root/terraform-modules/

# Test check script (should fail initially)
./check-workstation

# Test solve script
./solve-workstation

# Test check script again (should pass)
./check-workstation

# Cleanup
cd ..
```

## Deployment Steps

### Step 1: Initialize Git Repository

```bash
# Navigate to lab directory
cd instruqt/iac-bootcamp/tf-200-modules-lab

# Initialize git if not already done
git init

# Add all files
git add .

# Commit
git commit -m "Initial commit: TF-200 Modules Lab"

# Add remote (replace with your repository URL)
git remote add origin https://github.com/your-org/tf-200-modules-lab.git

# Push to remote
git push -u origin main
```

### Step 2: Login to Instruqt

```bash
# Login to Instruqt CLI
instruqt auth login

# Verify login
instruqt whoami
```

### Step 3: Create Track

```bash
# Create track from current directory
instruqt track create

# Or if track already exists, push updates
instruqt track push

# Verify track was created
instruqt track list | grep tf-200-modules
```

### Step 4: Validate Track

```bash
# Validate track configuration
instruqt track validate

# Check for any errors or warnings
# Fix any issues before proceeding
```

### Step 5: Test Track

```bash
# Start a test instance
instruqt track test

# This will:
# 1. Provision the VM
# 2. Run track setup scripts
# 3. Open browser to test environment
# 4. Allow you to test each challenge

# Test each challenge:
# - Verify setup scripts work
# - Complete challenge manually
# - Verify check scripts work
# - Test solve scripts
# - Verify cleanup between challenges
```

### Step 6: Publish Track

```bash
# Publish to Instruqt
instruqt track push --publish

# Or publish specific version
instruqt track push --publish --version 1.0.0

# Verify publication
instruqt track list --published | grep tf-200-modules
```

## Post-Deployment Verification

### 1. Test Complete Track

```bash
# Start fresh test instance
instruqt track test

# Complete all challenges in order:
# 1. Module Design & Composition
# 2. Advanced Module Patterns
# 3. YAML-Driven Configuration
# 4. Import & Migration Strategies
# 5. Skills Assessment

# Verify:
# - All setup scripts work
# - All check scripts validate correctly
# - All solve scripts provide working solutions
# - Track cleanup works properly
```

### 2. Verify Track Metadata

- **Title**: "TF-200: Terraform Modules & Patterns"
- **Slug**: "tf-200-modules"
- **Duration**: 4-5 hours
- **Difficulty**: Intermediate
- **Tags**: terraform, modules, iac, intermediate
- **Prerequisites**: TF-100 Fundamentals Lab

### 3. Check Challenge Timing

Each challenge should have appropriate time limits:

- Challenge 1: 60 minutes
- Challenge 2: 60 minutes
- Challenge 3: 60 minutes
- Challenge 4: 60 minutes
- Challenge 5: 90 minutes

### 4. Verify VM Configuration

- **Machine Type**: n1-standard-8 (8 vCPU, 30 GB RAM)
- **Shell**: bash
- **Nested Virtualization**: Enabled
- **Terraform Version**: 1.15+
- **Libvirt**: Installed and configured

## Troubleshooting Deployment Issues

### Issue: "Track validation failed"

**Solution**:
```bash
# Check validation errors
instruqt track validate

# Common issues:
# - Missing required fields in track.yml
# - Invalid YAML syntax
# - Missing challenge directories
# - Non-executable scripts

# Fix issues and validate again
```

### Issue: "Script execution failed"

**Solution**:
```bash
# Check script permissions
ls -l */setup-workstation

# Make executable if needed
chmod +x */setup-workstation

# Test script locally
bash -x 01-module-design/setup-workstation
```

### Issue: "VM provisioning timeout"

**Solution**:
```bash
# Check VM configuration in track.yml
# Ensure machine type is appropriate
# Verify nested virtualization is enabled

# May need to increase timeout in config.yml
```

### Issue: "Libvirt not working"

**Solution**:
```bash
# Verify libvirt installation in setup script
# Check track_scripts/setup-workstation

# Ensure these commands are present:
# - apt-get install -y qemu-kvm libvirt-daemon-system
# - systemctl start libvirtd
# - systemctl enable libvirtd
```

## Updating the Track

### Making Changes

```bash
# Make changes to files
vim 01-module-design/assignment.md

# Commit changes
git add .
git commit -m "Update Challenge 1 assignment"

# Push to Instruqt
instruqt track push

# Test changes
instruqt track test
```

### Version Management

```bash
# Create new version
instruqt track push --version 1.1.0

# List versions
instruqt track versions

# Rollback if needed
instruqt track push --version 1.0.0
```

## Maintenance

### Regular Checks

1. **Monthly**: Test complete track end-to-end
2. **Quarterly**: Update Terraform version if needed
3. **As needed**: Fix reported issues
4. **As needed**: Update content for new Terraform features

### Monitoring

```bash
# Check track statistics
instruqt track stats tf-200-modules

# View completion rates
instruqt track analytics tf-200-modules

# Check for user feedback
instruqt track feedback tf-200-modules
```

## Integration with TF-100

### Prerequisites

Students should complete TF-100 before starting TF-200:

1. **TF-100 Topics Covered**:
   - Terraform basics and syntax
   - Variables, loops, and functions
   - Infrastructure resources
   - State management and CLI

2. **TF-200 Builds On**:
   - Module design patterns
   - Advanced composition
   - YAML-driven configuration
   - Import and migration strategies

### Recommended Learning Path

```
TF-100: Fundamentals (6 hours)
    ↓
TF-200: Modules (5 hours)
    ↓
TF-300: Advanced (Optional)
    ↓
TF-400: HCP Terraform (Optional)
```

## Support and Documentation

### Internal Documentation

- `README.md` - Lab overview and learning objectives
- `BEST_PRACTICES.md` - Module best practices
- `COMMON_MISTAKES.md` - Common mistakes and solutions
- `TROUBLESHOOTING.md` - Troubleshooting guide
- `DEPLOYMENT_GUIDE.md` - This file

### External Resources

- [Instruqt Documentation](https://docs.instruqt.com/)
- [Terraform Module Documentation](https://www.terraform.io/docs/language/modules/)
- [HashiCorp Learn](https://learn.hashicorp.com/terraform)

## Rollback Procedure

If issues are discovered after deployment:

```bash
# 1. Unpublish current version
instruqt track unpublish

# 2. Revert to previous version
git revert HEAD
git push

# 3. Push previous version to Instruqt
instruqt track push

# 4. Test thoroughly
instruqt track test

# 5. Republish when ready
instruqt track push --publish
```

## Success Criteria

The deployment is successful when:

- [ ] All 5 challenges are accessible
- [ ] Setup scripts execute without errors
- [ ] Check scripts validate correctly
- [ ] Solve scripts provide working solutions
- [ ] Track cleanup works properly
- [ ] VM performance is adequate
- [ ] Documentation is complete and accurate
- [ ] Track is published and accessible
- [ ] Test users can complete successfully

## Contact

For deployment issues or questions:

- **Technical Issues**: Create GitHub issue
- **Instruqt Platform**: Contact Instruqt support
- **Content Questions**: Contact lab maintainer

---

## Deployment Checklist

Use this checklist for each deployment:

### Pre-Deployment
- [ ] All scripts are executable
- [ ] track.yml is valid
- [ ] config.yml is valid
- [ ] All challenges have required files
- [ ] Documentation is complete
- [ ] Git repository is up to date

### Deployment
- [ ] Logged into Instruqt CLI
- [ ] Track created/updated
- [ ] Track validated successfully
- [ ] Track tested end-to-end
- [ ] Track published

### Post-Deployment
- [ ] All challenges tested
- [ ] Timing verified
- [ ] VM configuration verified
- [ ] Documentation accessible
- [ ] Track listed in catalog
- [ ] Prerequisites linked correctly

### Verification
- [ ] Complete track as student
- [ ] Verify all check scripts
- [ ] Test all solve scripts
- [ ] Check cleanup between challenges
- [ ] Verify final cleanup

---

**Last Updated**: 2024-01-15  
**Version**: 1.0.0  
**Maintainer**: Lab Development Team
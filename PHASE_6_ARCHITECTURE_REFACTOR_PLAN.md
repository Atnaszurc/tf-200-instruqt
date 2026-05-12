# TF-200 Phase 6: Complete Architecture Refactoring Plan

**Status:** 🔄 IN PROGRESS  
**Date:** 2026-05-12  
**Scope:** Major architectural change from inline heredocs to separate files

---

## Executive Summary

**Current Architecture:** Inline heredoc generation (all code in setup scripts)  
**Target Architecture:** Separate `.tf` files with GitHub distribution (like TF-100)  
**Reason:** Enable local `terraform validate` without Instruqt environment

---

## Refactoring Scope

### Files to Create: ~60+ Terraform files

#### Challenge 1: Module Design & Composition
**Assets to create:**
```
assets/challenge-01/
├── modules/
│   ├── app-config/
│   │   ├── variables.tf
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── README.md
│   ├── libvirt-network/
│   │   ├── variables.tf
│   │   ├── main.tf
│   │   ├── outputs.tf
│   │   └── README.md
│   └── libvirt-vm/
│       ├── variables.tf
│       ├── main.tf
│       ├── outputs.tf
│       └── README.md
├── main.tf (root module example)
└── README.md
```
**Estimated:** 13 files

---

#### Challenge 2: Advanced Module Patterns
**Assets to create:**
```
assets/challenge-02/
├── modules/
│   ├── network/
│   │   ├── variables.tf
│   │   ├── main.tf
│   │   └── outputs.tf
│   ├── storage/
│   │   ├── variables.tf
│   │   ├── main.tf
│   │   └── outputs.tf
│   ├── compute/
│   │   ├── variables.tf
│   │   ├── main.tf
│   │   └── outputs.tf
│   ├── app-stack/
│   │   ├── variables.tf
│   │   ├── main.tf
│   │   └── outputs.tf
│   ├── conditional-vm/
│   │   ├── variables.tf
│   │   ├── main.tf
│   │   └── outputs.tf
│   └── canary-deployment/
│       ├── variables.tf
│       ├── main.tf
│       └── outputs.tf
├── main.tf (examples)
└── README.md
```
**Estimated:** 20 files

---

#### Challenge 3: YAML-Driven Configuration
**Assets to create:**
```
assets/challenge-03/
├── config/
│   ├── networks.yaml
│   ├── infrastructure.yaml
│   └── environments/
│       ├── dev.yaml
│       ├── staging.yaml
│       └── prod.yaml
├── modules/
│   └── yaml-validator/
│       ├── variables.tf
│       ├── main.tf
│       └── outputs.tf
├── main.tf (examples)
└── README.md
```
**Estimated:** 11 files

---

#### Challenge 4: Import & Migration Strategies
**Assets to create:**
```
assets/challenge-04/
├── existing-infrastructure/
│   └── (pre-created resources for import practice)
├── import-examples/
│   ├── import.tf (import blocks)
│   └── generated.tf (placeholder)
├── migration-examples/
│   ├── old-structure/
│   │   └── main.tf
│   └── new-structure/
│       └── main.tf
└── README.md
```
**Estimated:** 8 files

---

#### Challenge 5: Skills Assessment
**Assets to create:**
```
assets/challenge-05/
├── assessment-requirements.md
├── starter-template/
│   ├── main.tf
│   ├── variables.tf
│   └── outputs.tf
└── README.md
```
**Estimated:** 5 files

---

## Total Files to Create: ~60 files

---

## Refactoring Steps

### Step 1: Create Assets Directory Structure
```bash
mkdir -p assets/challenge-{01..05}
```

### Step 2: Extract Terraform Code from Heredocs
For each challenge:
1. Read setup-workstation script
2. Extract all `cat > file.tf << 'EOF'` blocks
3. Create corresponding `.tf` files in assets/
4. Update provider versions to `~> 0.9`
5. Ensure all syntax is libvirt 0.9+ compatible

### Step 3: Update Setup Scripts
Replace heredoc generation with file copying:
```bash
# OLD (inline generation)
cat > modules/app-config/variables.tf << 'EOF'
variable "app_name" {
  ...
}
EOF

# NEW (file copying)
cp -r /root/lab-assets/challenge-01/modules/app-config /root/terraform-workspace/modules/
```

### Step 4: Set Up GitHub Distribution
1. Push assets to GitHub repo: https://github.com/Atnaszurc/tf-200-instruqt
2. Update track setup script to clone repo
3. Test file distribution

### Step 5: Update All Scripts
- setup-workstation (5 files)
- solve-workstation (5 files)  
- check-workstation (5 files)
- track_scripts/setup-workstation (1 file)

### Step 6: Update Documentation
- Update README.md
- Update assignment.md files (5 files)
- Update BEST_PRACTICES.md
- Update TROUBLESHOOTING.md

---

## Provider Version Updates

**Current state:**
- Challenges 1-3: `version = "~> 0.8"` (22 instances)
- Challenges 4-5: `version = "~> 0.7"` (23 instances)

**Target state:**
- ALL challenges: `version = "~> 0.9"` (45 instances)

**Reason:** We're using libvirt 0.9+ syntax (os blocks, devices blocks)

---

## Benefits of Refactoring

### ✅ Advantages
1. **Local validation** - Run `terraform validate` without Instruqt
2. **Better testing** - Test modules independently
3. **Version control** - Track changes to Terraform code
4. **Reusability** - Share modules easily
5. **IDE support** - Better syntax highlighting and linting
6. **Consistency** - Same architecture as TF-100

### ⚠️ Trade-offs
1. **More files** - ~60 files vs inline code
2. **GitHub dependency** - Requires repo for distribution
3. **Sync complexity** - Must keep assets and scripts in sync
4. **Larger repo** - More files to manage

---

## Implementation Timeline

### Phase 6A: Extract Challenge 1 (Module Design)
- Create 13 files
- Update 3 scripts
- Test locally

### Phase 6B: Extract Challenge 2 (Advanced Patterns)
- Create 20 files
- Update 3 scripts
- Test locally

### Phase 6C: Extract Challenge 3 (YAML-Driven)
- Create 11 files
- Update 3 scripts
- Test locally

### Phase 6D: Extract Challenge 4 (Import/Migration)
- Create 8 files
- Update 3 scripts
- Test locally

### Phase 6E: Extract Challenge 5 (Skills Assessment)
- Create 5 files
- Update 3 scripts
- Test locally

### Phase 6F: GitHub Distribution Setup
- Push all assets to GitHub
- Update track setup script
- Test end-to-end

### Phase 6G: Documentation Updates
- Update all markdown files
- Update README
- Create migration guide

---

## Success Criteria

✅ All Terraform code extracted to separate files  
✅ All files use libvirt provider `~> 0.9`  
✅ All files have proper `os` blocks  
✅ Can run `terraform validate` locally on all challenges  
✅ Setup scripts copy files instead of generating  
✅ GitHub distribution working  
✅ All check scripts pass  
✅ All solve scripts work  
✅ Documentation updated  

---

## Risk Mitigation

1. **Backup current state** - Already done (Phase 3 complete)
2. **Incremental approach** - One challenge at a time
3. **Test each phase** - Validate before moving to next
4. **Keep old scripts** - Comment out, don't delete
5. **Document changes** - Track all modifications

---

## Next Action

**Start with Phase 6A: Extract Challenge 1**
- This is the simplest challenge (3 modules)
- Good proof of concept
- Tests the entire workflow

Once Challenge 1 is complete and validated, proceed to remaining challenges.
# Migration Plan Template

## Overview
Document your migration strategy before executing changes to ensure safe and reversible operations.

## Current State Assessment

### Existing Resources
List all resources currently managed outside Terraform:

| Resource Type | Resource Name | ID/Identifier | Current Owner |
|--------------|---------------|---------------|---------------|
| libvirt_network | legacy-net-1 | legacy-net-1 | Manual/Legacy |
| libvirt_network | legacy-net-2 | legacy-net-2 | Manual/Legacy |
| libvirt_network | legacy-net-3 | legacy-net-3 | Network Team |

### Dependencies
Document resource dependencies:
- legacy-net-1: Used by production VMs
- legacy-net-2: Used by staging VMs
- legacy-net-3: Used by database VMs (managed by DBA team)

## Target State

### Resources to Import
Resources that will be managed by Terraform:

| Resource | New Terraform Name | Reason |
|----------|-------------------|---------|
| legacy-net-1 | production_network | Standardize naming |
| legacy-net-2 | staging_network | Standardize naming |

### Resources to Hand Off
Resources to remove from Terraform management:

| Resource | Handoff To | Reason |
|----------|-----------|---------|
| legacy-net-3 | DBA Team | Specialized management needed |

## Migration Steps

### Phase 1: Preparation
- [ ] Document current state
- [ ] Backup existing state file
- [ ] Create rollback plan
- [ ] Notify stakeholders
- [ ] Schedule maintenance window (if needed)

### Phase 2: Import
- [ ] Create import blocks
- [ ] Generate configuration
- [ ] Review generated config
- [ ] Apply import
- [ ] Validate no drift

### Phase 3: Refactoring (if needed)
- [ ] Add moved blocks
- [ ] Update resource names
- [ ] Apply refactoring
- [ ] Validate state updates
- [ ] Clean up moved blocks

### Phase 4: Handoff (if needed)
- [ ] Add removed blocks
- [ ] Document handoff
- [ ] Apply removal
- [ ] Verify resource still running
- [ ] Clean up removed blocks

### Phase 5: Validation
- [ ] Run terraform plan (should show no changes)
- [ ] Verify all resources accessible
- [ ] Test dependent resources
- [ ] Update documentation
- [ ] Archive state backups

## Rollback Plan

### Rollback Triggers
- Import fails with errors
- Configuration drift detected
- Dependent resources affected
- Stakeholder concerns

### Rollback Steps
1. Stop all terraform operations
2. Restore state from backup:
   ```bash
   terraform state push backup-<timestamp>.tfstate
   ```
3. Verify state restoration
4. Document issues encountered
5. Plan remediation

## Risk Assessment

### High Risk
- [ ] Production resources involved
- [ ] Complex dependencies
- [ ] No previous state backup
- [ ] Limited testing

### Medium Risk
- [ ] Staging resources only
- [ ] Well-documented dependencies
- [ ] State backup exists
- [ ] Tested in dev environment

### Low Risk
- [ ] Development resources
- [ ] No dependencies
- [ ] Multiple state backups
- [ ] Thoroughly tested

## Communication Plan

### Before Migration
- Notify: [Team/Stakeholders]
- Timeline: [Date/Time]
- Expected Duration: [Duration]
- Impact: [Description]

### During Migration
- Status Updates: [Frequency]
- Contact: [Person/Channel]
- Escalation: [Process]

### After Migration
- Completion Notice: [Recipients]
- Documentation Updates: [Locations]
- Lessons Learned: [Meeting/Document]

## Success Criteria

- [ ] All planned resources imported successfully
- [ ] No configuration drift detected
- [ ] All dependent resources functioning
- [ ] State file backed up
- [ ] Documentation updated
- [ ] Stakeholders notified

## Notes

### Lessons Learned
Document any issues or insights during migration:
- 

### Future Improvements
Ideas for next migration:
- 

## Sign-off

| Role | Name | Date | Signature |
|------|------|------|-----------|
| Engineer | | | |
| Reviewer | | | |
| Approver | | | |

---

**Migration Status:** [ ] Not Started | [ ] In Progress | [ ] Complete | [ ] Rolled Back

**Completion Date:** _______________

**Final Notes:**
# Skill: Rollback

**Category:** Knowledge/Updater
**Priority:** P1
**Approval Required:** Yes (always)

## Purpose

Safely revert knowledge base changes when updates cause issues, validation failures, or unexpected behavior. This skill ensures Homer Pro can quickly recover from problematic updates while maintaining system stability and preserving the ability to investigate what went wrong.

## Voice Commands

- "Rollback the last update"
- "Revert [skill] to previous version"
- "Undo the inspection period change"
- "Restore knowledge base to [date/version]"
- "Emergency rollback - something is broken"

## Triggers

### Automatic
- Validation failure during update-knowledge
- Critical error detected post-update
- Automated test failures after update

### Manual
- Admin requests rollback
- Agent reports issue after update
- System monitoring detects anomaly

## Input Schema

```typescript
interface RollbackInput {
  rollback_type: "version" | "change" | "file" | "emergency";

  // Rollback to specific version
  target_version?: string;

  // Rollback specific change
  change_id?: string;

  // Rollback specific file
  file_path?: string;
  file_version?: string;

  // Emergency rollback (last known good)
  emergency?: {
    scope: "all" | "affected_only";
    reason: string;
  };

  options?: {
    dry_run?: boolean;          // Preview rollback without applying
    preserve_newer?: boolean;   // Keep changes made after target
    create_forward_patch?: boolean; // Save rolled-back changes as patch
    notify_stakeholders?: boolean;  // Send notifications (default: true)
  };

  approval: {
    approved_by: string;
    approved_at: string;
    reason: string;
  };
}
```

## Output Schema

```typescript
interface RollbackOutput {
  success: boolean;
  actionTaken: string;
  result: {
    rollback_id: string;
    rollback_type: string;

    scope: {
      files_affected: number;
      changes_reverted: number;
    };

    versions: {
      from: string;
      to: string;
    };

    files_rolled_back: FileRollback[];

    forward_patch?: {
      patch_id: string;
      patch_path: string;
      can_reapply: boolean;
    };

    validation: {
      pre_rollback_state: "working" | "broken" | "unknown";
      post_rollback_state: "working" | "degraded" | "failed";
      tests_passed: number;
      tests_failed: number;
    };

    notifications_sent: number;

    recovery_options: RecoveryOption[];
  };
  shouldContinue: boolean;
}

interface FileRollback {
  file_path: string;
  previous_version: string;
  restored_version: string;
  status: "restored" | "unchanged" | "failed";
  changes_reverted: ChangeReverted[];
}

interface ChangeReverted {
  change_id: string;
  summary: string;
  applied_at: string;
}

interface RecoveryOption {
  option: string;
  description: string;
  recommended: boolean;
}
```

## Execution Flow

```
START
  │
  ├─── 1. Validate rollback request
  │    │
  │    ├── Verify approval exists and is valid
  │    ├── Verify target version/change exists
  │    ├── Check rollback is possible (data available)
  │    │
  │    └── IF missing approval:
  │        └── REJECT with APPROVAL_REQUIRED error
  │
  ├─── 2. Analyze rollback scope
  │    │
  │    ├── IF rollback_type = "version":
  │    │   ├── Get all changes since target version
  │    │   └── List all affected files
  │    │
  │    ├── IF rollback_type = "change":
  │    │   └── Get files modified by this change
  │    │
  │    ├── IF rollback_type = "file":
  │    │   └── Get history of specific file
  │    │
  │    └── IF rollback_type = "emergency":
  │        ├── Identify last known good state
  │        ├── Get all changes since then
  │        └── Prepare full system rollback
  │
  ├─── 3. Create pre-rollback snapshot
  │    │
  │    ├── Snapshot current state of all affected files
  │    ├── Record current version info
  │    ├── Note any pending changes
  │    │
  │    └── IF create_forward_patch = true:
  │        ├── Generate patch of changes being reverted
  │        └── Save patch for potential reapplication
  │
  ├─── 4. Preview rollback (if dry_run)
  │    │
  │    ├── Show files that will be affected
  │    ├── Show changes that will be reverted
  │    ├── Estimate impact on active deals
  │    │
  │    └── IF dry_run: Return preview and exit
  │
  ├─── 5. Execute rollback
  │    │
  │    ├── FOR EACH affected file:
  │    │   │
  │    │   ├── Get target version content
  │    │   │
  │    │   ├── IF preserve_newer = true:
  │    │   │   └── Merge: Keep changes after target that don't conflict
  │    │   │
  │    │   ├── Write restored content
  │    │   │
  │    │   ├── Validate restored file:
  │    │   │   ├── Syntax check
  │    │   │   ├── Schema validation
  │    │   │   └── Reference check
  │    │   │
  │    │   └── IF validation fails:
  │    │       ├── Attempt auto-fix
  │    │       ├── IF can't fix: Mark as failed
  │    │       └── Continue with other files
  │    │
  │    └── Track all changes made
  │
  ├─── 6. Validate post-rollback state
  │    │
  │    ├── Run syntax validation on all files
  │    ├── Run schema validation
  │    ├── Run integration tests
  │    ├── Check for broken references
  │    │
  │    ├── IF validation fails:
  │    │   ├── Attempt recovery
  │    │   ├── IF can't recover: Flag critical error
  │    │   └── Consider rollback of rollback
  │    │
  │    └── Determine post-rollback_state
  │
  ├─── 7. Update version control
  │    │
  │    ├── Create rollback version entry
  │    ├── Link to rolled-back versions
  │    ├── Update current version pointer
  │    └── Record in audit log
  │
  ├─── 8. Refresh system state
  │    │
  │    ├── Clear all caches
  │    ├── Reload affected skills
  │    ├── Update context.md
  │    └── Verify features operational
  │
  ├─── 9. Notify stakeholders
  │    │
  │    ├── Alert admins of rollback
  │    ├── IF affects active deals:
  │    │   └── Notify affected agents
  │    └── Log for audit
  │
  └─── 10. Return rollback report
        │
        ├── Complete status
        ├── Files affected
        ├── Validation results
        └── Recovery options if issues remain
```

## Rollback Types

### Version Rollback

Revert entire knowledge base to a specific version.

```yaml
input:
  rollback_type: version
  target_version: "v1.3.2"
  approval:
    approved_by: "broker@brokerage.com"
    reason: "v2.0.0 causing calculation errors"

scope:
  - All files changed since v1.3.2
  - Affects: 4 skills, 2 templates, 1 data file
```

### Change Rollback

Revert a specific change while preserving subsequent changes.

```yaml
input:
  rollback_type: change
  change_id: "chg-inspection-period"
  options:
    preserve_newer: true
  approval:
    approved_by: "admin@brokerage.com"
    reason: "Change applied incorrectly, needs review"

scope:
  - Only files modified by this change
  - Preserves: Updates from chg-disclosure-template
```

### File Rollback

Revert a single file to a specific version.

```yaml
input:
  rollback_type: file
  file_path: "skills/deadline/calculate-deadlines.md"
  file_version: "v1.3.2"
  approval:
    approved_by: "admin@brokerage.com"
    reason: "Template syntax error"

scope:
  - Single file only
  - Other files unchanged
```

### Emergency Rollback

Immediate rollback to last known good state when system is broken.

```yaml
input:
  rollback_type: emergency
  emergency:
    scope: "affected_only"
    reason: "Skills failing to load after update"
  approval:
    approved_by: "admin@brokerage.com"
    reason: "EMERGENCY: System not operational"

scope:
  - All recently changed files
  - Immediate execution
  - Skip optional validations
```

## Rollback Examples

### Example 1: Rollback Failed Update

```yaml
trigger: Validation failed during update-knowledge

input:
  rollback_type: change
  change_id: "chg-disclosure-template"
  approval:
    approved_by: "homer-system"  # Auto-approval for validation failures
    reason: "Automatic rollback: Template validation failed"

output:
  success: true
  rollback_id: "rb-20260115-001"

  scope:
    files_affected: 1
    changes_reverted: 1

  files_rolled_back:
    - file_path: skills/comms/templates/wire-disclosure.md
      previous_version: "v1.3.4"
      restored_version: "v1.3.3"
      status: restored

  validation:
    post_rollback_state: working
    tests_passed: 12
    tests_failed: 0
```

### Example 2: Version Rollback with Forward Patch

```yaml
input:
  rollback_type: version
  target_version: "v1.3.2"
  options:
    create_forward_patch: true
  approval:
    approved_by: "broker@brokerage.com"
    reason: "Inspection period change causing agent confusion"

output:
  success: true

  versions:
    from: "v2.0.0"
    to: "v1.3.2"

  files_rolled_back:
    - file_path: skills/deadline/calculate-deadlines.md
      changes_reverted:
        - change_id: "chg-inspection-period"
          summary: "Inspection period 15→10 days"
        - change_id: "chg-hoa-timeline"
          summary: "HOA deadline extension"

  forward_patch:
    patch_id: "patch-v2.0.0-rollback"
    patch_path: "patches/20260115-v2.0.0-changes.patch"
    can_reapply: true

  recovery_options:
    - option: "Reapply with fixes"
      description: "Review and fix issues, then reapply from patch"
      recommended: true
    - option: "Stay on v1.3.2"
      description: "Keep current state until proper review completed"
      recommended: false
```

### Example 3: Emergency Rollback

```yaml
input:
  rollback_type: emergency
  emergency:
    scope: all
    reason: "Multiple skills failing to load after bulk update"
  approval:
    approved_by: "broker@brokerage.com"
    reason: "EMERGENCY - System non-functional"

execution:
  - priority: HIGHEST
  - timeout: 60 seconds
  - skip_optional_validations: true

output:
  success: true

  scope:
    files_affected: 12
    changes_reverted: 5

  versions:
    from: "v2.1.0"
    to: "v1.9.0"  # Last known good from health check

  validation:
    post_rollback_state: working
    tests_passed: 45
    tests_failed: 0

  notifications_sent: 8  # All admins + affected agents
```

## Safety Checks

### Pre-Rollback Checks

```typescript
const PRE_ROLLBACK_CHECKS = [
  {
    check: "approval_valid",
    description: "Valid approval from authorized user",
    required: true,
    skip_for: ["auto_validation_failure"]
  },
  {
    check: "target_exists",
    description: "Target version/content available",
    required: true
  },
  {
    check: "backup_created",
    description: "Current state backed up",
    required: true
  },
  {
    check: "no_active_operations",
    description: "No updates in progress",
    required: false,  // Warn only
    skip_for: ["emergency"]
  },
  {
    check: "deal_impact_assessed",
    description: "Impact on active deals evaluated",
    required: false,
    skip_for: ["emergency"]
  }
];
```

### Post-Rollback Checks

```typescript
const POST_ROLLBACK_CHECKS = [
  {
    check: "files_restored",
    description: "All target files restored successfully",
    required: true
  },
  {
    check: "syntax_valid",
    description: "All files pass syntax validation",
    required: true
  },
  {
    check: "skills_load",
    description: "All skills load without error",
    required: true
  },
  {
    check: "references_valid",
    description: "No broken references between files",
    required: false
  },
  {
    check: "tests_pass",
    description: "Integration tests pass",
    required: false,
    skip_for: ["emergency"]
  }
];
```

## Error Handling

| Error | Cause | Response |
|-------|-------|----------|
| `APPROVAL_REQUIRED` | Missing or invalid approval | Reject, require approval |
| `VERSION_NOT_FOUND` | Target version doesn't exist | List available versions |
| `BACKUP_FAILED` | Couldn't backup current state | Abort rollback |
| `RESTORE_FAILED` | Couldn't restore file | Continue with others, flag error |
| `VALIDATION_FAILED` | Post-rollback validation failed | Attempt recovery, alert admin |
| `SYSTEM_UNSTABLE` | Rollback made things worse | Emergency: rollback the rollback |

## Rollback of Rollback

If a rollback causes issues, the system can automatically recover:

```typescript
const ROLLBACK_RECOVERY = {
  trigger: "post_rollback_validation_failed",

  steps: [
    "Restore from pre-rollback snapshot",
    "Log failure details",
    "Alert all admins immediately",
    "Disable affected features",
    "Queue for manual intervention"
  ],

  escalation: {
    immediate: ["all_admins"],
    after_1_hour: ["broker", "support"],
    after_4_hours: ["engineering"]
  }
};
```

## Quality Checklist

- [x] Always requires explicit approval
- [x] Creates backup before any rollback
- [x] Supports granular rollback (version/change/file)
- [x] Preserves newer changes when possible
- [x] Creates forward patch for reapplication
- [x] Validates post-rollback state
- [x] Handles rollback failures gracefully
- [x] Can rollback a failed rollback
- [x] Notifies all affected stakeholders
- [x] Creates complete audit trail
- [x] Supports emergency mode for critical failures
- [x] Clears caches after rollback

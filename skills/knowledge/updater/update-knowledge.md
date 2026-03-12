# Skill: Update Knowledge

**Category:** Knowledge/Updater
**Priority:** P1
**Approval Required:** Yes (for CRITICAL/HIGH) / No (for MEDIUM/LOW)

## Purpose

Apply approved changes to Homer Pro's knowledge base, updating skills, templates, data files, and configuration based on detected changes from monitored sources. This skill ensures updates are applied consistently, versioned properly, and tested before deployment.

## Voice Commands

- "Apply the approved inspection period update"
- "Update Homer's knowledge about [topic]"
- "Implement the new disclosure requirement"
- "Rollback to previous version of [skill]"

## Triggers

### Automatic
- Impact assessment completed with AUTO_APPLY flag
- Admin approves pending change

### Manual
- Admin triggers update from change queue
- Agent requests knowledge refresh for specific area

## Input Schema

```typescript
interface UpdateKnowledgeInput {
  change_id: string;
  update_type: "skill" | "template" | "data" | "configuration" | "prompt";
  target_files: string[];
  updates: Update[];
  approval?: {
    approved_by: string;
    approved_at: string;
    approval_notes?: string;
  };
  options?: {
    dry_run?: boolean;           // Preview changes without applying
    skip_tests?: boolean;        // Skip validation (not recommended)
    force?: boolean;             // Override safety checks
    backup_first?: boolean;      // Create backup before update (default: true)
  };
}

interface Update {
  file_path: string;
  update_type: "replace" | "insert" | "delete" | "patch";
  location?: {
    section?: string;
    line_number?: number;
    after_pattern?: string;
    before_pattern?: string;
  };
  old_content?: string;          // For replace/delete
  new_content: string;           // For replace/insert
  reason: string;
}
```

## Output Schema

```typescript
interface UpdateKnowledgeOutput {
  success: boolean;
  actionTaken: string;
  result: {
    change_id: string;
    update_id: string;
    status: "applied" | "dry_run" | "failed" | "rolled_back";

    files_updated: FileUpdate[];

    validation: {
      syntax_check: "passed" | "failed" | "skipped";
      schema_check: "passed" | "failed" | "skipped";
      integration_check: "passed" | "failed" | "skipped";
      errors?: string[];
    };

    version_info: {
      previous_version: string;
      new_version: string;
      backup_path?: string;
      rollback_available: boolean;
    };

    affected_features: string[];
    post_update_status: "operational" | "degraded" | "offline";
  };
  shouldContinue: boolean;
}

interface FileUpdate {
  file_path: string;
  status: "updated" | "created" | "unchanged" | "failed";
  changes_made: number;
  backup_created: boolean;
  error?: string;
}
```

## Execution Flow

```
START
  │
  ├─── 1. Validate update request
  │    ├── Verify change_id exists and is approved
  │    ├── Check approval for CRITICAL/HIGH changes
  │    ├── Validate target files exist
  │    └── Verify update permissions
  │
  ├─── 2. Create backups
  │    │
  │    ├── FOR EACH target file:
  │    │   ├── Create timestamped backup
  │    │   ├── Store in version history
  │    │   └── Record backup path
  │    │
  │    └── Create rollback manifest
  │
  ├─── 3. Preview changes (if dry_run or for logging)
  │    │
  │    ├── FOR EACH update:
  │    │   ├── Generate diff preview
  │    │   ├── Validate syntax of new content
  │    │   └── Check for conflicts
  │    │
  │    └── IF dry_run: Return preview and exit
  │
  ├─── 4. Apply updates
  │    │
  │    ├── FOR EACH update (in dependency order):
  │    │   │
  │    │   ├── Load target file
  │    │   │
  │    │   ├── Apply update based on type:
  │    │   │   ├── replace: Find and replace content
  │    │   │   ├── insert: Add at specified location
  │    │   │   ├── delete: Remove specified content
  │    │   │   └── patch: Apply diff patch
  │    │   │
  │    │   ├── Validate file after update
  │    │   │
  │    │   └── IF validation fails:
  │    │       ├── Rollback this file
  │    │       └── Flag error
  │    │
  │    └── Track all changes made
  │
  ├─── 5. Run validation suite
  │    │
  │    ├── Syntax validation:
  │    │   ├── Markdown lint for .md files
  │    │   ├── YAML validation for configs
  │    │   ├── JSON schema validation
  │    │   └── TypeScript type checking
  │    │
  │    ├── Schema validation:
  │    │   ├── Skill schema compliance
  │    │   ├── Template variable coverage
  │    │   └── Required fields present
  │    │
  │    └── Integration validation:
  │        ├── Test skill can be loaded
  │        ├── Test templates render
  │        └── Test affected workflows
  │
  ├─── 6. Handle validation failures
  │    │
  │    ├── IF critical failure:
  │    │   ├── Rollback all changes
  │    │   ├── Restore from backups
  │    │   ├── Alert admin
  │    │   └── Return failure status
  │    │
  │    └── IF minor failure:
  │        ├── Log warning
  │        ├── Flag for review
  │        └── Continue with status: degraded
  │
  ├─── 7. Increment version
  │    ├── Update version in knowledge registry
  │    ├── Update skill metadata
  │    └── Create changelog entry
  │
  ├─── 8. Update context
  │    ├── Refresh Homer's context.md
  │    ├── Clear affected caches
  │    └── Notify dependent systems
  │
  └─── 9. Return results
       └── Complete update report
```

## Update Types

### Skill Updates

```yaml
update_type: skill
target_files:
  - skills/deadline/calculate-deadlines.md

updates:
  - file_path: skills/deadline/calculate-deadlines.md
    update_type: replace
    location:
      section: "Default Deadlines"
    old_content: |
      inspection_period_days: 15
    new_content: |
      inspection_period_days: 10
      # Updated 2026-01-15 per FAR/BAR form revision v7
    reason: "Inspection period default changed in FAR/BAR v7"
```

### Template Updates

```yaml
update_type: template
target_files:
  - skills/comms/templates/inspection-deadline.md

updates:
  - file_path: skills/comms/templates/inspection-deadline.md
    update_type: patch
    new_content: |
      --- a/inspection-deadline.md
      +++ b/inspection-deadline.md
      @@ -5,7 +5,7 @@
       Hi {{buyer_name}},

      -You have **15 days** to complete your inspection.
      +You have **{{inspection_period}} days** to complete your inspection.

       Your inspection deadline is {{inspection_deadline}}.
    reason: "Make inspection period dynamic instead of hardcoded"
```

### Data Updates

```yaml
update_type: data
target_files:
  - data/florida-deadlines.json

updates:
  - file_path: data/florida-deadlines.json
    update_type: replace
    location:
      json_path: "$.deadlines.inspection.default_days"
    old_content: "15"
    new_content: "10"
    reason: "FAR/BAR form update"
```

### Configuration Updates

```yaml
update_type: configuration
target_files:
  - config/disclosure-requirements.yaml

updates:
  - file_path: config/disclosure-requirements.yaml
    update_type: insert
    location:
      after_pattern: "required_disclosures:"
    new_content: |
      - name: wire_fraud_disclosure
        required: true
        timing: "closing_date - 3 days"
        template: wire-fraud-disclosure.md
        effective_date: "2026-07-01"
    reason: "New wire fraud disclosure requirement"
```

## Version Control

### Version Format

```
v{major}.{minor}.{patch}-{timestamp}

Examples:
- v1.0.0-20260115 (Initial release)
- v1.1.0-20260120 (New feature)
- v1.1.1-20260125 (Bug fix)
- v2.0.0-20260201 (Breaking change)
```

### Version Increment Rules

| Change Type | Version Bump | Example |
|-------------|--------------|---------|
| Breaking change (deadline logic) | Major | v1.x.x → v2.0.0 |
| New feature (new disclosure) | Minor | v1.1.x → v1.2.0 |
| Bug fix, clarification | Patch | v1.1.1 → v1.1.2 |
| Data update only | Patch | v1.1.1 → v1.1.2 |

## Update Examples

### Example 1: Auto-Applied Low-Impact Update

```yaml
input:
  change_id: "chg-hoa-timeline"
  update_type: skill
  approval: null  # Not required for LOW impact

process:
  - backup_created: true
  - dry_run_result: "Clean application, no conflicts"
  - validation: all passed

output:
  status: applied
  files_updated:
    - file_path: skills/party/party-types/hoa.md
      status: updated
      changes_made: 1
  version_info:
    previous_version: v1.3.2-20260110
    new_version: v1.3.3-20260115
  post_update_status: operational
```

### Example 2: Approved Critical Update

```yaml
input:
  change_id: "chg-inspection-period"
  update_type: skill
  approval:
    approved_by: "admin@brokerage.com"
    approved_at: "2026-01-15T14:30:00Z"
    approval_notes: "Verified with legal team"

output:
  status: applied
  files_updated:
    - file_path: skills/deadline/calculate-deadlines.md
      status: updated
      changes_made: 3
    - file_path: data/florida-deadlines.json
      status: updated
      changes_made: 1
    - file_path: skills/comms/templates/inspection-deadline.md
      status: updated
      changes_made: 2
  validation:
    syntax_check: passed
    schema_check: passed
    integration_check: passed
  version_info:
    previous_version: v1.3.3-20260115
    new_version: v2.0.0-20260115
  affected_features:
    - deadline calculation
    - inspection alerts
    - compliance checks
```

### Example 3: Failed Update with Rollback

```yaml
input:
  change_id: "chg-disclosure-template"
  update_type: template

process:
  - backup_created: true
  - update_applied: true
  - validation:
      syntax_check: failed
      error: "Missing required variable {{agent_name}}"
  - rollback_triggered: true

output:
  status: rolled_back
  files_updated:
    - file_path: skills/comms/templates/wire-disclosure.md
      status: failed
      error: "Validation failed - missing required variable"
  validation:
    syntax_check: failed
    errors: ["Template missing required variable {{agent_name}}"]
  version_info:
    previous_version: v1.3.3-20260115
    new_version: null  # Not applied
    backup_path: backups/20260115/wire-disclosure.md
    rollback_available: true
```

## Error Handling

| Error | Cause | Response |
|-------|-------|----------|
| `APPROVAL_REQUIRED` | CRITICAL/HIGH change without approval | Reject, queue for approval |
| `FILE_NOT_FOUND` | Target file doesn't exist | Log error, continue with other files |
| `CONFLICT_DETECTED` | Old content doesn't match current | Flag for manual review |
| `VALIDATION_FAILED` | Updated content invalid | Rollback, alert admin |
| `BACKUP_FAILED` | Couldn't create backup | Abort update |
| `PERMISSION_DENIED` | Can't write to file | Alert admin |

## Quality Checklist

- [x] Requires approval for CRITICAL/HIGH changes
- [x] Creates backups before all updates
- [x] Validates syntax after updates
- [x] Validates schema compliance
- [x] Tests integration after updates
- [x] Supports atomic rollback
- [x] Versions all changes
- [x] Creates changelog entries
- [x] Updates context.md after changes
- [x] Clears affected caches
- [x] Handles partial failures gracefully
- [x] Preserves update history

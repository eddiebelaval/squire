# Skill: Version Control

**Category:** Knowledge/Updater
**Priority:** P1
**Approval Required:** No

## Purpose

Manage version history for Homer Pro's knowledge base, tracking all changes with full audit trails, enabling comparisons between versions, and maintaining the ability to understand what changed, when, and why across all skills, templates, and configurations.

## Voice Commands

- "Show version history for [skill]"
- "What changed in the last update?"
- "Compare current version to [date/version]"
- "Who approved the inspection period change?"
- "List all changes this month"

## Triggers

### Automatic
- After every update-knowledge execution
- On system backup schedule

### Manual
- Admin requests version history
- Auditor requires change log
- Agent asks about update history

## Input Schema

```typescript
interface VersionControlInput {
  action: "commit" | "log" | "diff" | "tag" | "search" | "audit";

  // For commit
  commit?: {
    files: string[];
    message: string;
    change_id?: string;
    author: string;
    approved_by?: string;
  };

  // For log
  log?: {
    file_path?: string;        // Specific file history
    limit?: number;            // Number of entries
    since?: string;            // ISO date
    until?: string;            // ISO date
    author?: string;           // Filter by author
  };

  // For diff
  diff?: {
    file_path: string;
    from_version?: string;     // Version or "previous"
    to_version?: string;       // Version or "current"
  };

  // For tag
  tag?: {
    version: string;
    name: string;              // e.g., "v2.0.0"
    description?: string;
  };

  // For search
  search?: {
    query: string;             // Search in commits/files
    file_pattern?: string;     // Glob pattern
    date_range?: { from: string; to: string };
  };

  // For audit
  audit?: {
    scope: "all" | "critical" | "approvals";
    date_range: { from: string; to: string };
    export_format?: "json" | "csv" | "pdf";
  };
}
```

## Output Schema

```typescript
interface VersionControlOutput {
  success: boolean;
  actionTaken: string;
  result: {
    action: string;

    // For commit
    commit_result?: {
      version_id: string;
      version_number: string;
      files_versioned: number;
      commit_hash: string;
      timestamp: string;
    };

    // For log
    log_result?: {
      total_entries: number;
      entries: VersionEntry[];
    };

    // For diff
    diff_result?: {
      file_path: string;
      from_version: string;
      to_version: string;
      changes: DiffChange[];
      summary: {
        lines_added: number;
        lines_removed: number;
        lines_modified: number;
      };
    };

    // For search
    search_result?: {
      total_matches: number;
      matches: SearchMatch[];
    };

    // For audit
    audit_result?: {
      period: { from: string; to: string };
      total_changes: number;
      changes_by_type: Record<string, number>;
      changes_by_author: Record<string, number>;
      approval_summary: ApprovalSummary;
      export_path?: string;
    };
  };
  shouldContinue: boolean;
}

interface VersionEntry {
  version_id: string;
  version_number: string;
  commit_hash: string;
  timestamp: string;
  author: string;
  approved_by?: string;
  message: string;
  change_id?: string;
  files_changed: string[];
  impact_level?: string;
}

interface DiffChange {
  type: "added" | "removed" | "modified";
  line_number: number;
  old_content?: string;
  new_content?: string;
  context?: string[];
}

interface SearchMatch {
  version_id: string;
  file_path: string;
  line_number: number;
  content: string;
  context: string[];
}

interface ApprovalSummary {
  total_requiring_approval: number;
  approved: number;
  pending: number;
  approvers: { name: string; count: number }[];
}
```

## Execution Flow

```
START
  │
  ├─── ACTION: commit
  │    │
  │    ├─── 1. Validate commit request
  │    │    ├── Verify files exist
  │    │    ├── Check for approval (if required)
  │    │    └── Validate author
  │    │
  │    ├─── 2. Generate version info
  │    │    ├── Increment version number
  │    │    ├── Generate commit hash (SHA-256)
  │    │    └── Create timestamp
  │    │
  │    ├─── 3. Store file snapshots
  │    │    ├── FOR EACH file:
  │    │    │   ├── Create content snapshot
  │    │    │   ├── Calculate file hash
  │    │    │   └── Store in version store
  │    │    │
  │    │    └── Link files to version
  │    │
  │    ├─── 4. Create version record
  │    │    ├── Store metadata
  │    │    ├── Link to change_id if provided
  │    │    └── Add to version history
  │    │
  │    └─── 5. Return commit result
  │
  ├─── ACTION: log
  │    │
  │    ├─── 1. Build query
  │    │    ├── Apply file filter if specified
  │    │    ├── Apply date range
  │    │    └── Apply author filter
  │    │
  │    ├─── 2. Fetch version entries
  │    │    ├── Query version store
  │    │    ├── Apply limit
  │    │    └── Sort by timestamp (newest first)
  │    │
  │    └─── 3. Return log entries
  │
  ├─── ACTION: diff
  │    │
  │    ├─── 1. Resolve versions
  │    │    ├── Get from_version content
  │    │    ├── Get to_version content
  │    │    └── Handle "previous"/"current" aliases
  │    │
  │    ├─── 2. Compute diff
  │    │    ├── Line-by-line comparison
  │    │    ├── Identify additions
  │    │    ├── Identify deletions
  │    │    ├── Identify modifications
  │    │    └── Add context lines
  │    │
  │    └─── 3. Return diff result
  │
  ├─── ACTION: tag
  │    │
  │    ├─── 1. Validate version exists
  │    ├─── 2. Create tag record
  │    ├─── 3. Link tag to version
  │    └─── 4. Return tag confirmation
  │
  ├─── ACTION: search
  │    │
  │    ├─── 1. Build search query
  │    │    ├── Parse search terms
  │    │    ├── Apply file pattern
  │    │    └── Apply date range
  │    │
  │    ├─── 2. Search version store
  │    │    ├── Search commit messages
  │    │    ├── Search file contents
  │    │    └── Rank by relevance
  │    │
  │    └─── 3. Return search matches
  │
  └─── ACTION: audit
       │
       ├─── 1. Gather audit data
       │    ├── Query all changes in period
       │    ├── Group by type
       │    ├── Group by author
       │    └── Compile approval records
       │
       ├─── 2. Generate audit report
       │    ├── Summary statistics
       │    ├── Detailed change log
       │    └── Approval verification
       │
       └─── 3. Export if requested
            ├── Generate JSON/CSV/PDF
            └── Store in audit archive
```

## Version Storage Schema

```typescript
interface VersionStore {
  versions: Version[];
  files: VersionedFile[];
  tags: Tag[];

  indexes: {
    by_file: Map<string, string[]>;      // file_path -> version_ids
    by_change: Map<string, string>;      // change_id -> version_id
    by_date: Map<string, string[]>;      // date -> version_ids
    by_author: Map<string, string[]>;    // author -> version_ids
  };
}

interface Version {
  id: string;
  version_number: string;              // "v1.2.3"
  commit_hash: string;                 // SHA-256
  timestamp: string;                   // ISO 8601
  author: string;
  approved_by?: string;
  message: string;
  change_id?: string;
  files: string[];                     // file_path[]
  impact_level?: "critical" | "high" | "medium" | "low";
  parent_version?: string;             // Previous version ID
}

interface VersionedFile {
  id: string;
  version_id: string;
  file_path: string;
  content_hash: string;
  content: string;
  size_bytes: number;
}

interface Tag {
  id: string;
  version_id: string;
  name: string;                        // "v2.0.0"
  description?: string;
  created_at: string;
  created_by: string;
}
```

## Version Number Rules

```typescript
const VERSION_RULES = {
  // Major: Breaking changes
  major: {
    triggers: [
      "Deadline calculation logic change",
      "Contract form version change",
      "Schema breaking change",
      "Required field addition"
    ],
    example: "v1.x.x → v2.0.0"
  },

  // Minor: New features
  minor: {
    triggers: [
      "New disclosure requirement",
      "New template added",
      "New skill added",
      "New data source"
    ],
    example: "v1.1.x → v1.2.0"
  },

  // Patch: Bug fixes, updates
  patch: {
    triggers: [
      "Typo correction",
      "Clarification update",
      "Data value update",
      "Minor template fix"
    ],
    example: "v1.1.1 → v1.1.2"
  }
};
```

## Usage Examples

### Example 1: Commit After Update

```yaml
input:
  action: commit
  commit:
    files:
      - skills/deadline/calculate-deadlines.md
      - data/florida-deadlines.json
    message: "Update inspection period default from 15 to 10 days"
    change_id: "chg-inspection-period"
    author: "homer-system"
    approved_by: "admin@brokerage.com"

output:
  commit_result:
    version_id: "ver-20260115-001"
    version_number: "v2.0.0"
    files_versioned: 2
    commit_hash: "sha256:a1b2c3d4..."
    timestamp: "2026-01-15T14:30:00Z"
```

### Example 2: View Version History

```yaml
input:
  action: log
  log:
    file_path: skills/deadline/calculate-deadlines.md
    limit: 5

output:
  log_result:
    total_entries: 5
    entries:
      - version_id: "ver-20260115-001"
        version_number: "v2.0.0"
        timestamp: "2026-01-15T14:30:00Z"
        author: "homer-system"
        message: "Update inspection period default from 15 to 10 days"
        impact_level: "critical"

      - version_id: "ver-20260110-003"
        version_number: "v1.3.2"
        timestamp: "2026-01-10T09:15:00Z"
        author: "homer-system"
        message: "Add HOA document deadline calculation"
        impact_level: "medium"
```

### Example 3: Compare Versions

```yaml
input:
  action: diff
  diff:
    file_path: skills/deadline/calculate-deadlines.md
    from_version: "v1.3.2"
    to_version: "v2.0.0"

output:
  diff_result:
    file_path: skills/deadline/calculate-deadlines.md
    from_version: "v1.3.2"
    to_version: "v2.0.0"
    changes:
      - type: modified
        line_number: 45
        old_content: "inspection_period_days: 15"
        new_content: "inspection_period_days: 10"
        context:
          - "## Default Deadlines"
          - ""
          - "inspection_period_days: 10"
          - "# Updated 2026-01-15 per FAR/BAR form revision v7"
    summary:
      lines_added: 1
      lines_removed: 0
      lines_modified: 1
```

### Example 4: Audit Report

```yaml
input:
  action: audit
  audit:
    scope: critical
    date_range:
      from: "2026-01-01"
      to: "2026-01-31"
    export_format: pdf

output:
  audit_result:
    period:
      from: "2026-01-01"
      to: "2026-01-31"
    total_changes: 47
    changes_by_type:
      skill_update: 23
      template_update: 12
      data_update: 8
      configuration: 4
    changes_by_author:
      homer-system: 42
      admin@brokerage.com: 5
    approval_summary:
      total_requiring_approval: 8
      approved: 8
      pending: 0
      approvers:
        - name: "admin@brokerage.com"
          count: 5
        - name: "broker@brokerage.com"
          count: 3
    export_path: "audits/2026-01-critical-changes.pdf"
```

## Retention Policy

```typescript
const RETENTION_POLICY = {
  // Full content retention
  full_content: {
    duration_days: 90,
    applies_to: ["all versions"]
  },

  // Metadata only (content deleted)
  metadata_only: {
    duration_days: 365,
    applies_to: ["versions older than 90 days"]
  },

  // Permanent retention
  permanent: {
    applies_to: [
      "tagged versions",
      "critical changes",
      "audit milestones"
    ]
  },

  // Archive
  archive: {
    after_days: 365,
    format: "compressed",
    storage: "cold_storage"
  }
};
```

## Error Handling

| Error | Cause | Response |
|-------|-------|----------|
| `VERSION_NOT_FOUND` | Requested version doesn't exist | Return error with available versions |
| `FILE_NOT_VERSIONED` | File has no version history | Initialize version tracking |
| `STORAGE_FULL` | Version store at capacity | Archive old versions, alert admin |
| `HASH_MISMATCH` | Content integrity issue | Alert admin, investigate corruption |
| `AUDIT_EXPORT_FAILED` | Export generation failed | Retry, fall back to JSON |

## Quality Checklist

- [x] Tracks all knowledge base changes
- [x] Maintains complete audit trail
- [x] Supports version comparison
- [x] Enables rollback capability
- [x] Records approval chain
- [x] Links changes to source change_id
- [x] Supports search across history
- [x] Generates audit reports
- [x] Follows retention policy
- [x] Maintains content integrity (hashes)
- [x] Supports semantic versioning
- [x] Preserves context for each change

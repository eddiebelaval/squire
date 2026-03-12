# Skill: Legal Monitor

**Category:** Knowledge/Monitor
**Priority:** P1
**Approval Required:** No (for updates) / Yes (for critical changes)

## Purpose

Continuously monitor Florida real estate law sources for changes that affect Homer Pro's operations, agent obligations, contract rules, or disclosure requirements. This skill keeps Homer's legal knowledge current and ensures compliance with evolving regulations.

## Triggers

### Scheduled
- **Daily:** Florida Realtors legal updates, NAR legal pulse
- **Weekly:** Florida Statutes, FREC rules, Florida Bar
- **On-Demand:** Agent requests "Check for legal updates"

### Event-Based
- New FAR/BAR contract version released
- Legislative session ends (potential new laws)
- Court decision affecting real estate

## Monitored Sources

### Primary Sources (High Authority)

| Source | URL | Frequency | Focus |
|--------|-----|-----------|-------|
| Florida Statutes Ch. 475 | flsenate.gov/Laws/Statutes/2025/Chapter475 | Weekly | Real estate licensing |
| Florida Statutes Ch. 720 | flsenate.gov/Laws/Statutes/2025/Chapter720 | Weekly | HOA regulations |
| Florida Statutes Ch. 718 | flsenate.gov/Laws/Statutes/2025/Chapter718 | Weekly | Condo regulations |
| FREC Rules | flrules.org/gateway/Division.asp?DivID=195 | Weekly | Commission rules |
| Florida Realtors Legal | floridarealtors.org/law-ethics | Daily | Practice guidance |
| Florida Bar RE Section | floridabar.org | Weekly | Contract updates |

### Secondary Sources (Industry Interpretation)

| Source | URL | Frequency | Focus |
|--------|-----|-----------|-------|
| NAR Legal Pulse | nar.realtor/legal | Daily | National issues |
| CFPB Regulations | consumerfinance.gov | Weekly | Federal requirements |
| HUD Fair Housing | hud.gov/program_offices/fair_housing | Monthly | Fair housing |

## Change Categories

### CRITICAL — Immediate Action Required
- Contract form changes (FAR/BAR)
- Deadline calculation rule changes
- New mandatory disclosures
- License law violations redefined
- Consumer protection changes

### HIGH — Update Within 24 Hours
- Disclosure requirement additions
- Commission rule clarifications
- HOA/Condo law changes
- Insurance requirement changes
- Escrow handling rule changes

### MEDIUM — Update Within 7 Days
- Best practice guidance changes
- Procedural clarifications
- Form revision announcements
- Court decision impacts

### LOW — Track and Log
- Minor clarifications
- Commentary/opinions
- Proposed (not enacted) changes
- Out-of-state developments

## Execution Flow

```
START
  │
  ├─── 1. Load source configuration
  │    ├── Get list of monitored sources
  │    ├── Check last crawl timestamps
  │    └── Identify sources due for check
  │
  ├─── 2. FOR EACH source to check:
  │    │
  │    ├── 2a. Fetch current content
  │    │   ├── Use headless browser (Puppeteer)
  │    │   ├── Handle authentication if needed
  │    │   ├── Extract relevant sections
  │    │   └── Store content snapshot
  │    │
  │    ├── 2b. Compare to previous snapshot
  │    │   ├── Generate content hash
  │    │   ├── If hash unchanged → skip to next source
  │    │   └── If changed → analyze differences
  │    │
  │    ├── 2c. Analyze changes with Claude
  │    │   │
  │    │   └── PROMPT:
  │    │       """
  │    │       You are a Florida real estate legal expert.
  │    │       Compare these two versions of {{source.name}}.
  │    │
  │    │       PREVIOUS VERSION:
  │    │       {{previous_content}}
  │    │
  │    │       CURRENT VERSION:
  │    │       {{current_content}}
  │    │
  │    │       Identify changes affecting:
  │    │       1. Contract requirements or deadlines
  │    │       2. Disclosure obligations
  │    │       3. Agent responsibilities
  │    │       4. Consumer rights/protections
  │    │       5. Escrow/deposit handling
  │    │       6. Signature/execution requirements
  │    │
  │    │       For each change found, provide:
  │    │       - change_type: new | modified | removed
  │    │       - summary: One sentence description
  │    │       - details: Full explanation
  │    │       - impact: CRITICAL | HIGH | MEDIUM | LOW
  │    │       - affected_skills: List of Homer skills to update
  │    │       - action_required: What needs to change
  │    │       - effective_date: When change takes effect
  │    │       """
  │    │
  │    ├── 2d. Process detected changes
  │    │   │
  │    │   ├── FOR EACH change:
  │    │   │   ├── Create knowledge_update record
  │    │   │   ├── Assess impact level
  │    │   │   ├── Identify affected skills
  │    │   │   └── Queue for processing
  │    │   │
  │    │   └── Update source.last_checked_at
  │    │
  │    └── 2e. Handle errors
  │        ├── Increment consecutive_failures
  │        ├── Log error details
  │        └── Alert if 3+ consecutive failures
  │
  ├─── 3. Process change queue
  │    │
  │    ├── FOR EACH queued change:
  │    │   │
  │    │   ├── IF impact = CRITICAL:
  │    │   │   ├── Send immediate alert to all agents
  │    │   │   ├── Flag affected active deals
  │    │   │   ├── Require human review before applying
  │    │   │   └── Schedule skill updates pending approval
  │    │   │
  │    │   ├── IF impact = HIGH:
  │    │   │   ├── Send alert within 24 hours
  │    │   │   ├── Auto-update affected skills
  │    │   │   └── Add to agent's next briefing
  │    │   │
  │    │   ├── IF impact = MEDIUM:
  │    │   │   ├── Auto-update knowledge base
  │    │   │   └── Include in weekly digest
  │    │   │
  │    │   └── IF impact = LOW:
  │    │       └── Update knowledge base, log only
  │    │
  │    └── Mark changes as processed
  │
  ├─── 4. Update affected skills
  │    ├── Load skill file
  │    ├── Apply documented changes
  │    ├── Version control update
  │    └── Log skill update
  │
  ├─── 5. Generate update report
  │    └── Create summary for agent briefing
  │
  └─── 6. Return results
```

## Change Detection Examples

### Example 1: FAR/BAR Contract Form Update

```yaml
source: Florida Realtors Forms
detected: 2026-01-15
change_type: modified
summary: "Inspection period default changed from 15 days to 10 days in new contract version"

details: |
  The FAR/BAR As-Is Residential Contract for Sale and Purchase has been
  updated to version 7 (effective February 1, 2026). Key change:
  - Section 12(a) Inspection Period: Default changed from 15 to 10 days
  - Applies to contracts executed on or after February 1, 2026
  - Existing contracts under version 6 are not affected

impact: CRITICAL

affected_skills:
  - calculate-deadlines.md
  - deadline-alert templates
  - inspection-extension.md
  - compliance/florida-far-bar-rules.md

action_required: |
  1. Update default inspection_period_days from 15 to 10
  2. Add version detection to use correct default
  3. Update all references to "15 day" inspection period
  4. Alert agents about the change

effective_date: 2026-02-01
```

### Example 2: New Disclosure Requirement

```yaml
source: Florida Statutes
detected: 2026-01-20
change_type: new
summary: "New wire fraud disclosure required before closing"

details: |
  HB 1234 adds Section 475.2785 to Florida Statutes requiring:
  - Written wire fraud warning to all buyers
  - Must be delivered at least 3 days before closing
  - Must include specific language about verification
  - Failure to provide creates liability exposure

impact: HIGH

affected_skills:
  - comms/templates/wire-instructions.md
  - compliance/disclosure-requirements.md
  - deadline/calculate-deadlines.md (add new deadline)

action_required: |
  1. Create new wire fraud disclosure template
  2. Add "Wire Fraud Disclosure Due" deadline (closing - 3 days)
  3. Update closing checklist
  4. Alert agents about new requirement

effective_date: 2026-07-01
```

### Example 3: HOA Timeline Change

```yaml
source: Florida Statutes Chapter 720
detected: 2026-02-01
change_type: modified
summary: "HOA document delivery timeline extended from 10 to 15 days"

details: |
  Section 720.401 amended to extend HOA disclosure delivery:
  - Previous: 10 days from request
  - New: 15 days from request
  - Applies to all HOA transactions

impact: MEDIUM

affected_skills:
  - party/party-types/hoa.md
  - deadline/default-deadlines (HOA docs deadline)

action_required: |
  1. Update default HOA document deadline calculation
  2. Update HOA party protocol timeline expectations

effective_date: 2026-03-01
```

## Alert Templates

### CRITICAL Alert (Immediate)

```
🚨 CRITICAL LEGAL UPDATE - ACTION REQUIRED

{{change.summary}}

Effective: {{change.effective_date}}
Source: {{source.name}}

Impact on Your Deals:
{{affected_deals_count}} active deals may be affected.

What Changed:
{{change.details}}

Required Action:
{{change.action_required}}

Homer has flagged this for review. Some automated functions
may be paused until you acknowledge this update.

[Acknowledge & Review] [View Full Details]
```

### HIGH Alert (Daily Briefing)

```
⚠️ LEGAL UPDATE: {{change.summary}}

Effective {{change.effective_date}}, {{change.details_short}}

Homer has automatically updated:
{{updated_skills_list}}

No action required unless you have questions.
```

## Output

```typescript
{
  success: true,
  actionTaken: "Completed legal monitoring check",
  result: {
    sources_checked: 8,
    changes_detected: 2,
    updates: [
      {
        id: "uuid",
        source: "Florida Realtors",
        change_type: "modified",
        summary: "Inspection period default changed",
        impact: "CRITICAL",
        status: "pending_review"
      },
      {
        id: "uuid",
        source: "Florida Statutes",
        change_type: "new",
        summary: "Wire fraud disclosure required",
        impact: "HIGH",
        status: "applied"
      }
    ],
    skills_updated: [
      "calculate-deadlines.md",
      "wire-instructions.md"
    ],
    alerts_sent: 1,
    next_check: "2026-01-22T08:00:00Z"
  }
}
```

## Error Handling

| Error | Cause | Response |
|-------|-------|----------|
| `SOURCE_UNAVAILABLE` | Website down/blocked | Log error, retry in 1 hour, alert after 3 failures |
| `PARSE_FAILED` | Page structure changed | Alert admin, use last known good content |
| `ANALYSIS_UNCERTAIN` | Claude couldn't determine impact | Flag for human review, don't auto-apply |
| `SKILL_UPDATE_FAILED` | Couldn't update skill file | Rollback, alert admin |

## Quality Checklist

- [x] Monitors all critical Florida legal sources
- [x] Detects changes accurately via content comparison
- [x] Classifies impact correctly (CRITICAL/HIGH/MEDIUM/LOW)
- [x] Identifies all affected skills
- [x] Alerts agents appropriately by impact level
- [x] Auto-updates skills for non-critical changes
- [x] Requires human approval for critical changes
- [x] Maintains version control on all updates
- [x] Handles source failures gracefully
- [x] Creates complete audit trail
- [x] Flags affected active deals for critical changes

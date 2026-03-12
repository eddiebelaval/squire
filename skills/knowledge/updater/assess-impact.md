# Skill: Assess Impact

**Category:** Knowledge/Updater
**Priority:** P1
**Approval Required:** Yes (for CRITICAL) / No (for others)

## Purpose

Evaluate detected changes to determine their impact on Homer Pro's operations, active transactions, and agent workflows. This skill prioritizes changes, identifies affected deals, and determines the appropriate response level from immediate alerts to routine updates.

## Voice Commands

- "What's the impact of the new disclosure requirement?"
- "How does this change affect my active deals?"
- "Assess the impact of [change description]"
- "Which transactions are affected by [change]?"

## Triggers

### Automatic
- Change detected by detect-changes skill
- New change record created in database

### Manual
- Agent asks about specific change impact
- Admin requests impact assessment for pending change

## Input Schema

```typescript
interface AssessImpactInput {
  change_id: string;
  change: {
    source_id: string;
    type: "addition" | "modification" | "deletion";
    category: string;
    summary: string;
    details: string;
    effective_date?: string;
    affected_areas?: string[];
  };
  assessment_scope?: {
    check_active_deals?: boolean;     // Default: true
    check_affected_skills?: boolean;  // Default: true
    check_agent_workflows?: boolean;  // Default: true
    specific_deal_ids?: string[];     // Assess specific deals only
  };
  context?: {
    current_date: string;
    agent_id?: string;
    brokerage_id?: string;
  };
}
```

## Output Schema

```typescript
interface AssessImpactOutput {
  success: boolean;
  actionTaken: string;
  result: {
    change_id: string;
    impact_level: "critical" | "high" | "medium" | "low";
    impact_score: number;  // 0-100 for prioritization
    urgency: "immediate" | "24_hours" | "7_days" | "routine";

    assessment: {
      summary: string;
      detailed_analysis: string;
      risk_factors: string[];
      mitigation_steps: string[];
    };

    affected_deals: {
      count: number;
      deals: AffectedDeal[];
      deals_by_stage: Record<string, number>;
    };

    affected_skills: {
      count: number;
      skills: AffectedSkill[];
      update_complexity: "simple" | "moderate" | "complex";
    };

    affected_workflows: {
      count: number;
      workflows: AffectedWorkflow[];
    };

    recommended_actions: RecommendedAction[];

    notification_plan: {
      immediate_alerts: string[];   // Who to alert now
      daily_digest: string[];       // Include in daily update
      weekly_summary: boolean;      // Include in weekly summary
    };

    requires_human_review: boolean;
    review_reason?: string;
  };
  shouldContinue: boolean;
}

interface AffectedDeal {
  deal_id: string;
  property_address: string;
  stage: string;
  agent_id: string;
  impact_description: string;
  action_required: string;
  deadline_affected?: string;
  risk_level: "high" | "medium" | "low";
}

interface AffectedSkill {
  skill_path: string;
  skill_name: string;
  update_type: "logic" | "template" | "data" | "configuration";
  update_description: string;
  estimated_effort: "minutes" | "hours" | "days";
  auto_update_possible: boolean;
}

interface AffectedWorkflow {
  workflow_name: string;
  impact_description: string;
  requires_agent_training: boolean;
}

interface RecommendedAction {
  priority: number;
  action: string;
  responsible: "homer" | "admin" | "agent";
  deadline: string;
  status: "pending" | "in_progress" | "completed";
}
```

## Execution Flow

```
START
  │
  ├─── 1. Load change details
  │    ├── Get change record
  │    ├── Get source metadata
  │    └── Parse effective date
  │
  ├─── 2. Calculate base impact score
  │    │
  │    ├── Factor in change category weight:
  │    │   ├── deadline_rules: +30
  │    │   ├── disclosure_requirements: +25
  │    │   ├── contract_terms: +25
  │    │   ├── compliance: +20
  │    │   ├── procedural: +10
  │    │   └── other: +5
  │    │
  │    ├── Factor in source authority:
  │    │   ├── Florida Statutes: +20
  │    │   ├── FREC Rules: +15
  │    │   ├── FAR/BAR Forms: +15
  │    │   ├── Florida Realtors: +10
  │    │   └── Industry sources: +5
  │    │
  │    └── Factor in timing:
  │        ├── Already effective: +20
  │        ├── < 30 days: +15
  │        ├── 30-90 days: +10
  │        └── > 90 days: +5
  │
  ├─── 3. Assess affected deals
  │    │
  │    ├── Query active deals
  │    │
  │    ├── FOR EACH deal:
  │    │   │
  │    │   ├── Check if change category applies:
  │    │   │   ├── deadline_rules → check deadline dates
  │    │   │   ├── disclosure → check disclosure status
  │    │   │   ├── contract_terms → check contract type
  │    │   │   └── compliance → check all deals
  │    │   │
  │    │   ├── Determine specific impact:
  │    │   │   ├── Which deadlines affected?
  │    │   │   ├── Which documents need updating?
  │    │   │   ├── What agent action required?
  │    │   │   └── What is risk level?
  │    │   │
  │    │   └── Add to affected_deals list
  │    │
  │    └── Adjust impact score based on affected count:
  │        ├── 0 deals: +0
  │        ├── 1-5 deals: +10
  │        ├── 6-20 deals: +20
  │        └── 20+ deals: +30
  │
  ├─── 4. Identify affected skills
  │    │
  │    ├── Load skill registry
  │    │
  │    ├── FOR EACH skill:
  │    │   ├── Check if skill handles affected category
  │    │   ├── Analyze skill content for relevant patterns
  │    │   └── Determine update requirements
  │    │
  │    └── Assess update complexity:
  │        ├── Simple: Text/template change only
  │        ├── Moderate: Logic or data updates
  │        └── Complex: Structural changes needed
  │
  ├─── 5. Identify affected workflows
  │    ├── Map change to agent workflows
  │    ├── Identify training needs
  │    └── Document process changes
  │
  ├─── 6. Determine final impact level
  │    │
  │    ├── Score 80-100: CRITICAL
  │    │   └── Immediate action, pause affected features
  │    │
  │    ├── Score 60-79: HIGH
  │    │   └── Action within 24 hours
  │    │
  │    ├── Score 40-59: MEDIUM
  │    │   └── Action within 7 days
  │    │
  │    └── Score 0-39: LOW
  │        └── Routine update
  │
  ├─── 7. Generate recommendations
  │    │
  │    ├── Create prioritized action list
  │    │
  │    ├── Assign responsibilities:
  │    │   ├── Homer (auto-update skills)
  │    │   ├── Admin (review complex changes)
  │    │   └── Agent (update active deals)
  │    │
  │    └── Set deadlines based on urgency
  │
  ├─── 8. Create notification plan
  │    ├── CRITICAL: Immediate push to all affected agents
  │    ├── HIGH: Add to next daily briefing
  │    ├── MEDIUM: Include in weekly digest
  │    └── LOW: Log for reference
  │
  └─── 9. Return assessment
       └── Full impact report with recommendations
```

## Impact Scoring Matrix

### Change Category Weights

| Category | Base Score | Rationale |
|----------|------------|-----------|
| deadline_rules | 30 | Directly affects transaction timing |
| disclosure_requirements | 25 | Liability and compliance risk |
| contract_terms | 25 | Affects deal validity |
| licensing | 20 | Agent compliance |
| escrow | 20 | Financial handling |
| commission | 15 | Agent compensation |
| procedural | 10 | Process efficiency |
| market_data | 10 | Informational |
| other | 5 | Minimal direct impact |

### Urgency Determination

| Impact Level | Urgency | Response Time | Notification |
|--------------|---------|---------------|--------------|
| CRITICAL | Immediate | < 1 hour | Push notification + email |
| HIGH | 24 Hours | < 24 hours | Daily briefing highlight |
| MEDIUM | 7 Days | < 7 days | Weekly digest |
| LOW | Routine | < 30 days | System log only |

## Assessment Examples

### Example 1: Critical - Inspection Period Change

```yaml
change:
  category: deadline_rules
  summary: "Inspection period reduced from 15 to 10 days"
  effective_date: "2026-02-01"

assessment:
  impact_level: critical
  impact_score: 92
  urgency: immediate

  affected_deals:
    count: 47
    deals_by_stage:
      under_contract: 23
      inspection_pending: 12
      closing_scheduled: 12

  affected_skills:
    count: 4
    skills:
      - skill_path: deadline/calculate-deadlines.md
        update_type: logic
        estimated_effort: hours
        auto_update_possible: false

  recommended_actions:
    - priority: 1
      action: "Alert all agents with active inspection periods"
      responsible: homer
      deadline: immediate

    - priority: 2
      action: "Review and approve deadline calculation update"
      responsible: admin
      deadline: "2026-01-20"

    - priority: 3
      action: "Update calculate-deadlines skill"
      responsible: homer
      deadline: "2026-01-25"

  notification_plan:
    immediate_alerts: ["all_agents_with_active_deals"]
```

### Example 2: High - New Disclosure Requirement

```yaml
change:
  category: disclosure_requirements
  summary: "New wire fraud disclosure required"
  effective_date: "2026-07-01"

assessment:
  impact_level: high
  impact_score: 68
  urgency: 24_hours

  assessment:
    summary: "New mandatory disclosure adds step to closing process"
    detailed_analysis: |
      The new wire fraud disclosure requirement affects all transactions
      closing on or after July 1, 2026. Homer needs to:
      1. Create disclosure template
      2. Add deadline (closing - 3 days)
      3. Update closing checklist

  affected_deals:
    count: 0  # Future deals only

  affected_skills:
    count: 3
    skills:
      - skill_path: comms/templates/wire-instructions.md
        update_type: template
        estimated_effort: hours

  recommended_actions:
    - priority: 1
      action: "Create wire fraud disclosure template"
      responsible: homer
      deadline: "2026-06-15"
```

### Example 3: Low - Minor Clarification

```yaml
change:
  category: procedural
  summary: "Clarified timing for HOA document requests"
  effective_date: "2026-03-01"

assessment:
  impact_level: low
  impact_score: 22
  urgency: routine

  affected_deals:
    count: 8  # Deals with pending HOA requests

  recommended_actions:
    - priority: 1
      action: "Update HOA party documentation"
      responsible: homer
      deadline: "2026-02-15"

  notification_plan:
    immediate_alerts: []
    daily_digest: []
    weekly_summary: true
```

## Error Handling

| Error | Cause | Response |
|-------|-------|----------|
| `NO_ACTIVE_DEALS` | No deals to assess | Complete assessment without deal impact |
| `SKILL_NOT_FOUND` | Referenced skill missing | Log warning, continue assessment |
| `DATE_PARSE_FAILED` | Invalid effective date | Use current date, flag for review |
| `ASSESSMENT_UNCERTAIN` | Can't determine impact | Flag for human review |

## Quality Checklist

- [x] Accurately calculates impact scores
- [x] Identifies all affected active deals
- [x] Maps changes to affected skills correctly
- [x] Provides actionable recommendations
- [x] Sets appropriate urgency levels
- [x] Creates complete notification plans
- [x] Handles edge cases (no deals, future effective dates)
- [x] Flags uncertain assessments for review
- [x] Prioritizes actions logically
- [x] Tracks assessment history

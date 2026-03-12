# Skill: Industry Monitor

**Category:** Knowledge/Monitor
**Priority:** P1
**Approval Required:** No (for updates) / Yes (for critical changes)

## Purpose

Monitor real estate industry developments including MLS policy changes, commission rule updates, NAR/FAR announcements, technology platform changes, and brokerage practice shifts. This skill ensures Homer Pro stays current with industry dynamics that affect how agents conduct business.

## Voice Commands

- "Any changes to MLS rules?"
- "What's happening with commissions?"
- "Check for NAR updates"
- "Any new industry announcements?"
- "What's changing in the industry?"

## Triggers

### Scheduled
- **Daily:** NAR, Florida Realtors news feeds
- **Weekly:** MLS rule updates, commission discussions
- **Monthly:** Industry trend analysis

### Event-Based
- NAR policy announcement
- MLS rule change notification
- Settlement or legal decision affecting industry
- Major brokerage announcement

## Monitored Sources

### Primary Industry Sources

| Source | URL | Frequency | Focus |
|--------|-----|-----------|-------|
| NAR Newsroom | nar.realtor/newsroom | Daily | Policy, settlements, rules |
| Florida Realtors News | floridarealtors.org/news | Daily | FL-specific industry |
| Inman News | inman.com | Daily | Industry trends |
| RealTrends | realtrends.com | Weekly | Brokerage rankings, trends |
| HousingWire | housingwire.com | Daily | Industry analysis |

### MLS Sources

| Source | Focus | Frequency |
|--------|-------|-----------|
| Stellar MLS Updates | Rule changes, tech updates | Weekly |
| Miami MLS Bulletins | South FL policy | Weekly |
| BeachMLS Notices | Gulf Coast policy | Weekly |
| Council of MLS (CMLS) | National MLS policy | Monthly |

### Commission/Settlement Sources

| Source | Focus | Frequency |
|--------|-------|-----------|
| DOJ Antitrust Division | Competition cases | Event-based |
| Class Action Tracker | Commission lawsuits | Weekly |
| NAR Legal Updates | Settlement implementations | Event-based |

## Industry Categories

### MLS CHANGES

```typescript
interface MLSChange {
  mls_name: string;
  change_type: "rule" | "policy" | "fee" | "technology" | "merger";
  summary: string;
  details: string;
  effective_date: string;
  impact: {
    listing_process?: string;
    showing_process?: string;
    offer_process?: string;
    compliance_requirements?: string;
  };
  required_agent_action?: string;
}
```

### COMMISSION RULES

```typescript
interface CommissionUpdate {
  source: string;  // Settlement, NAR policy, state law
  change_type: "disclosure" | "negotiation" | "structure" | "prohibition";
  summary: string;
  details: string;
  effective_date: string;
  affected_practices: string[];
  compliance_requirements: {
    forms_needed?: string[];
    disclosure_timing?: string;
    documentation?: string;
  };
  training_required: boolean;
}
```

### TECHNOLOGY CHANGES

```typescript
interface TechChange {
  platform: string;
  change_type: "new_feature" | "deprecation" | "integration" | "requirement";
  summary: string;
  impact_on_workflow: string;
  training_available?: string;
  deadline?: string;
}
```

### ASSOCIATION UPDATES

```typescript
interface AssociationUpdate {
  organization: "NAR" | "FAR" | "local_board";
  update_type: "policy" | "code_of_ethics" | "dues" | "membership" | "program";
  summary: string;
  details: string;
  member_impact: string;
  action_required?: string;
}
```

## Execution Flow

```
START
  │
  ├─── 1. Check industry sources
  │    ├── Load configured sources
  │    ├── Check last crawl times
  │    └── Identify sources due for check
  │
  ├─── 2. FOR EACH source:
  │    │
  │    ├── 2a. Fetch latest content
  │    │   ├── RSS feeds for news sites
  │    │   ├── API calls for MLS updates
  │    │   └── Web scrape for announcements
  │    │
  │    ├── 2b. Extract relevant items
  │    │   ├── Filter by keywords
  │    │   ├── Filter by date (new since last check)
  │    │   └── Filter by Florida relevance
  │    │
  │    └── 2c. Store new items for analysis
  │
  ├─── 3. Analyze industry developments
  │    │
  │    └── PROMPT:
  │        """
  │        You are a Florida real estate industry analyst.
  │
  │        NEW INDUSTRY DEVELOPMENTS:
  │        {{new_items}}
  │
  │        For each development, analyze:
  │
  │        1. Category:
  │           - MLS rules/policy
  │           - Commission/compensation
  │           - Technology/platforms
  │           - Association/membership
  │           - Legal/regulatory
  │           - Market practice
  │
  │        2. Impact level: CRITICAL | HIGH | MEDIUM | LOW
  │
  │        3. Florida-specific implications:
  │           - Does this apply to Florida?
  │           - Any state-specific variations?
  │
  │        4. Agent impact:
  │           - Changes to daily workflow?
  │           - New compliance requirements?
  │           - Training needed?
  │           - Form or process changes?
  │
  │        5. Timeline:
  │           - When does this take effect?
  │           - What's the preparation window?
  │
  │        6. Homer updates needed:
  │           - Skills to update
  │           - Templates to modify
  │           - Alerts to configure
  │
  │        Focus on actionable implications for Florida agents.
  │        """
  │
  ├─── 4. Categorize by impact
  │    │
  │    ├── CRITICAL:
  │    │   ├── Commission structure changes
  │    │   ├── MLS access rule changes
  │    │   ├── Licensing requirement changes
  │    │   └── Legal compliance deadlines
  │    │
  │    ├── HIGH:
  │    │   ├── New disclosure requirements
  │    │   ├── Form changes
  │    │   ├── Technology platform changes
  │    │   └── Association policy updates
  │    │
  │    ├── MEDIUM:
  │    │   ├── Best practice updates
  │    │   ├── Training opportunities
  │    │   └── Industry trend shifts
  │    │
  │    └── LOW:
  │        ├── Industry news
  │        └── Future developments
  │
  ├─── 5. Queue for Homer updates
  │    ├── Create change records
  │    ├── Identify affected skills
  │    └── Schedule updates
  │
  └─── 6. Generate industry report
       └── Summary for agent briefing
```

## Industry Change Examples

### Example 1: MLS Commission Field Changes

```yaml
source: Stellar MLS Bulletin
detected: 2026-01-15
type: MLS rule change

summary: "Buyer agent compensation no longer displayed in MLS; new field for seller concessions"

details: |
  Effective March 1, 2026, Stellar MLS implements new fields:
  - "Buyer Agent Compensation" field removed from public display
  - New "Seller Concessions" field added
  - Compensation must be negotiated directly with sellers
  - Written buyer representation agreement required before showing

impact: CRITICAL

agent_impact:
  workflow_changes:
    - "Must have signed buyer agreement before MLS search"
    - "Compensation negotiated per-transaction"
    - "New form: Compensation Disclosure Addendum"
  compliance_requirements:
    - "Buyer Rep Agreement before first showing"
    - "Compensation disclosed before offer"
  training_needed: true

homer_updates:
  - skill: "deal/initiate-new-deal.md"
    change: "Add buyer rep agreement checkpoint"
  - skill: "comms/templates/buyer-agreement.md"
    change: "Create new template"
  - skill: "compliance/disclosure-requirements.md"
    change: "Add compensation disclosure"

effective_date: "2026-03-01"
preparation_window: "45 days"
```

### Example 2: NAR Settlement Implementation

```yaml
source: NAR Legal Update
detected: 2026-01-20
type: Commission policy

summary: "NAR settlement practice changes now in effect nationwide"

details: |
  Following the NAR settlement, the following changes are now mandatory:
  1. Written buyer agreements required before touring homes
  2. Compensation offers may not appear in MLS
  3. Seller cannot require buyer agent compensation as condition
  4. All compensation must be transparently disclosed

impact: CRITICAL

compliance_requirements:
  forms_needed:
    - "Buyer Representation Agreement"
    - "Compensation Disclosure Form"
    - "Seller Compensation Authorization"
  disclosure_timing: "Before first property tour"
  documentation: "Retain all compensation agreements for 5 years"

homer_updates:
  - "Add buyer agreement requirement to showing workflow"
  - "Create compensation disclosure templates"
  - "Update compliance checklist"

training_required: true
training_deadline: "Immediate"
```

### Example 3: Technology Platform Update

```yaml
source: Stellar MLS Tech Update
detected: 2026-01-18
type: Platform change

summary: "New digital offer management system launching February 15"

details: |
  Stellar MLS introducing integrated offer management:
  - All offers submitted through MLS platform
  - Digital signature integration
  - Offer tracking and notification
  - Seller response workflow

impact: MEDIUM

agent_impact:
  workflow_changes:
    - "Offers submitted through MLS portal"
    - "Automatic receipt confirmation"
    - "Digital counter-offer process"
  training_needed: true
  training_url: "https://stellarmls.com/training/offer-management"

homer_updates:
  - skill: "deal/submit-offer.md"
    change: "Add MLS portal submission option"

effective_date: "2026-02-15"
```

## Alert Templates

### Critical Industry Alert

```markdown
## Subject: 🚨 CRITICAL INDUSTRY CHANGE: {{summary}}

Hi {{agent_name}},

A significant industry change affects how you conduct business.

### What's Changing
{{details}}

### Effective Date
{{effective_date}} ({{days_until}} days from now)

### What You Need to Do
{{#each action_items}}
- {{this}}
{{/each}}

### New Requirements
{{#each compliance_requirements}}
- {{this}}
{{/each}}

### Homer Updates
Homer will automatically update:
{{#each homer_updates}}
- {{skill}}: {{change}}
{{/each}}

### Training Resources
{{training_url}}

[View Full Details] [Mark as Read]
```

### Weekly Industry Digest

```markdown
## Subject: Industry Update - Week of {{week}}

### This Week's Developments

{{#each developments}}
**{{summary}}** ({{impact}})
- {{one_line_summary}}
{{/each}}

### Upcoming Changes
{{#each upcoming}}
- {{effective_date}}: {{summary}}
{{/each}}

### Industry Trends
{{trends_summary}}

### Action Items
{{#each action_items}}
- [ ] {{action}} (Due: {{due_date}})
{{/each}}
```

## Output Schema

```typescript
interface IndustryMonitorOutput {
  success: boolean;
  actionTaken: string;
  result: {
    sources_checked: number;
    new_developments: number;

    developments: IndustryDevelopment[];

    by_category: {
      mls_changes: number;
      commission_updates: number;
      technology_changes: number;
      association_updates: number;
      legal_regulatory: number;
    };

    by_impact: {
      critical: number;
      high: number;
      medium: number;
      low: number;
    };

    action_items: ActionItem[];

    homer_updates_queued: number;

    next_check: string;
  };
  shouldContinue: boolean;
}

interface IndustryDevelopment {
  id: string;
  source: string;
  category: string;
  summary: string;
  details: string;
  impact: string;
  effective_date?: string;
  florida_specific: boolean;
  action_required: boolean;
  training_needed: boolean;
}

interface ActionItem {
  development_id: string;
  action: string;
  responsible: "agent" | "broker" | "homer";
  due_date: string;
  priority: "high" | "medium" | "low";
}
```

## Error Handling

| Error | Cause | Response |
|-------|-------|----------|
| `SOURCE_UNAVAILABLE` | Website/API down | Use cached, retry later |
| `PARSE_ERROR` | Content structure changed | Alert admin, manual review |
| `AMBIGUOUS_IMPACT` | Can't determine impact level | Flag for human review |
| `FLORIDA_RELEVANCE_UNCLEAR` | Not sure if applies to FL | Include with note |

## Quality Checklist

- [x] Monitors all major industry sources
- [x] Focuses on Florida-relevant developments
- [x] Categorizes by impact level accurately
- [x] Identifies agent workflow impacts
- [x] Flags compliance requirements
- [x] Notes training needs
- [x] Queues Homer updates appropriately
- [x] Provides actionable summaries
- [x] Tracks upcoming effective dates
- [x] Maintains development history

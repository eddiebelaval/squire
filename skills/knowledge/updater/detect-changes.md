# Skill: Detect Changes

**Category:** Knowledge/Updater
**Priority:** P1
**Approval Required:** No

## Purpose

Analyze crawled content to detect meaningful changes between versions. This skill goes beyond simple diff comparison to identify semantically significant changes that affect Homer Pro's operations, filtering out formatting noise and irrelevant modifications.

## Voice Commands

- "What changed on [source] since last check?"
- "Analyze differences in the new FAR/BAR contract"
- "Show me significant changes from this week"
- "Diff the new Florida statutes against previous version"

## Triggers

### Automatic
- Crawl-source returns `content_changed: true`
- Content hash differs from previous snapshot

### Manual
- Admin requests comparison of two versions
- Agent asks about changes to specific source

## Input Schema

```typescript
interface DetectChangesInput {
  source_id: string;
  current_content: {
    text: string;
    hash: string;
    crawl_timestamp: string;
    metadata?: Record<string, unknown>;
  };
  previous_content?: {
    text: string;
    hash: string;
    crawl_timestamp: string;
  };
  detection_mode?: "semantic" | "structural" | "exact";
  focus_areas?: string[];  // Specific areas to analyze
  ignore_patterns?: string[];  // Patterns to ignore (dates, timestamps)
}
```

## Output Schema

```typescript
interface DetectChangesOutput {
  success: boolean;
  actionTaken: string;
  result: {
    source_id: string;
    comparison_id: string;
    has_meaningful_changes: boolean;
    changes: Change[];
    summary: {
      total_changes: number;
      by_type: {
        additions: number;
        modifications: number;
        deletions: number;
      };
      by_impact: {
        critical: number;
        high: number;
        medium: number;
        low: number;
      };
    };
    noise_filtered: number;  // Irrelevant changes filtered out
    confidence: number;      // 0-1 confidence in analysis
    needs_human_review: boolean;
    analysis_notes?: string;
  };
  shouldContinue: boolean;
}

interface Change {
  id: string;
  type: "addition" | "modification" | "deletion";
  category: string;  // legal, procedural, deadline, disclosure, etc.
  location: {
    section?: string;
    paragraph?: number;
    line_range?: [number, number];
  };
  previous_text?: string;
  current_text?: string;
  summary: string;
  details: string;
  impact_assessment: {
    level: "critical" | "high" | "medium" | "low";
    reasoning: string;
    affected_areas: string[];
  };
  keywords: string[];  // For searchability
  requires_action: boolean;
}
```

## Execution Flow

```
START
  │
  ├─── 1. Load content versions
  │    ├── Get current content from crawl result
  │    ├── Get previous content from snapshot store
  │    └── IF no previous version: Mark all as "new content"
  │
  ├─── 2. Preprocess content
  │    ├── Normalize whitespace
  │    ├── Remove boilerplate (headers, footers, nav)
  │    ├── Strip irrelevant patterns (timestamps, session IDs)
  │    └── Segment into logical sections
  │
  ├─── 3. Compute structural diff
  │    │
  │    ├── Line-by-line comparison
  │    ├── Identify added lines
  │    ├── Identify removed lines
  │    ├── Identify modified lines
  │    └── Group adjacent changes
  │
  ├─── 4. Filter noise
  │    │
  │    ├── IGNORE changes that are:
  │    │   ├── Date/timestamp only
  │    │   ├── Copyright year updates
  │    │   ├── Session/tracking IDs
  │    │   ├── Formatting-only changes
  │    │   ├── Reordering without content change
  │    │   └── Patterns in ignore_patterns
  │    │
  │    └── Track filtered count for transparency
  │
  ├─── 5. Semantic analysis with Claude
  │    │
  │    └── PROMPT:
  │        """
  │        You are a Florida real estate legal analyst.
  │
  │        SOURCE: {{source.name}} ({{source.type}})
  │        LAST VERSION: {{previous.crawl_timestamp}}
  │        CURRENT VERSION: {{current.crawl_timestamp}}
  │
  │        STRUCTURAL CHANGES DETECTED:
  │        {{structural_diff}}
  │
  │        Analyze each change and determine:
  │
  │        1. Is this change MEANINGFUL or NOISE?
  │           - Meaningful: Affects legal requirements, deadlines,
  │             disclosures, agent obligations, consumer rights
  │           - Noise: Formatting, typos, date updates, rephrasing
  │
  │        2. For each MEANINGFUL change, provide:
  │           - type: addition | modification | deletion
  │           - category: legal | deadline | disclosure | procedural |
  │                       compliance | financial | other
  │           - summary: One sentence description
  │           - details: Full explanation of what changed
  │           - impact_level: CRITICAL | HIGH | MEDIUM | LOW
  │           - impact_reasoning: Why this level?
  │           - affected_areas: What Homer skills/features affected?
  │           - requires_action: Does Homer need to update anything?
  │
  │        3. Overall assessment:
  │           - Are there any CRITICAL changes requiring immediate attention?
  │           - Confidence level in your analysis (0-1)
  │           - Any uncertainty requiring human review?
  │
  │        Focus particularly on:
  │        {{focus_areas}}
  │
  │        Return structured JSON matching the Change[] schema.
  │        """
  │
  ├─── 6. Validate and enrich results
  │    ├── Verify impact levels are justified
  │    ├── Cross-reference with known patterns
  │    ├── Add keyword tags for searchability
  │    └── Flag anything uncertain for human review
  │
  ├─── 7. Store change records
  │    ├── Create change records in database
  │    ├── Link to source and content snapshots
  │    └── Queue for impact assessment
  │
  └─── 8. Return results
       └── Include full change list and summary
```

## Change Categories

### Legal Categories
- **contract_terms**: Changes to contract language, clauses
- **deadline_rules**: Changes to timing, calculation methods
- **disclosure_requirements**: New or modified disclosure obligations
- **licensing**: Changes to license requirements, continuing ed
- **fair_housing**: Fair housing law updates
- **escrow**: Escrow handling rule changes
- **commission**: Commission structure, disclosure rules
- **liability**: Agent liability, malpractice exposure

### Market Categories
- **interest_rates**: Rate changes affecting buyers
- **lending_guidelines**: Loan qualification changes
- **inventory**: Market supply changes
- **pricing**: Price trend shifts
- **insurance**: Insurance requirement changes

### Industry Categories
- **mls_rules**: MLS policy changes
- **form_updates**: Standard form revisions
- **technology**: Platform or system changes
- **association**: NAR, FAR policy changes

## Change Detection Examples

### Example 1: Contract Deadline Change

```yaml
input:
  source_id: florida-far-bar-contract
  previous_content: "Buyer shall have 15 calendar days..."
  current_content: "Buyer shall have 10 calendar days..."

output:
  has_meaningful_changes: true
  changes:
    - id: "chg-001"
      type: modification
      category: deadline_rules
      location:
        section: "Section 12(a)"
        paragraph: 1
      previous_text: "Buyer shall have 15 calendar days from Effective Date..."
      current_text: "Buyer shall have 10 calendar days from Effective Date..."
      summary: "Inspection period reduced from 15 to 10 days"
      details: |
        The default inspection period in the FAR/BAR As-Is Contract has been
        reduced from 15 calendar days to 10 calendar days. This affects:
        - All new contracts using the updated form
        - Deadline calculation for inspection period
        - Standard negotiation expectations
      impact_assessment:
        level: critical
        reasoning: "Changes default timeline for most transactions"
        affected_areas:
          - calculate-deadlines skill
          - inspection-extension skill
          - deadline alert templates
      keywords: ["inspection", "deadline", "10 days", "FAR/BAR"]
      requires_action: true
```

### Example 2: Noise Filtered Out

```yaml
input:
  source_id: florida-realtors-legal
  structural_diff:
    - "Copyright 2025 → Copyright 2026"
    - "Last updated: Jan 1 → Last updated: Jan 15"
    - "Section 3.2: The agent shall → Section 3.2: The agent must"

output:
  has_meaningful_changes: true
  changes:
    - id: "chg-002"
      type: modification
      category: procedural
      summary: "Agent obligation language strengthened from 'shall' to 'must'"
      impact_assessment:
        level: low
        reasoning: "Semantic difference is minimal but noted for completeness"

  noise_filtered: 2
  analysis_notes: "Copyright and timestamp changes filtered as noise"
```

### Example 3: New Disclosure Requirement

```yaml
input:
  source_id: florida-statutes-475

output:
  changes:
    - id: "chg-003"
      type: addition
      category: disclosure_requirements
      location:
        section: "475.2785 (NEW)"
      current_text: |
        (1) Prior to closing, a licensee shall provide to the buyer
        a written disclosure regarding wire fraud risks...
      summary: "New mandatory wire fraud disclosure requirement added"
      details: |
        New Section 475.2785 creates a mandatory disclosure:
        - Must be in writing
        - Delivered at least 3 days before closing
        - Specific required language about verification
        - Creates liability for failure to provide
      impact_assessment:
        level: high
        reasoning: "New mandatory requirement with liability exposure"
        affected_areas:
          - disclosure templates
          - closing checklist
          - deadline calculation (closing - 3 days)
      requires_action: true
```

## Confidence Levels

| Confidence | Meaning | Action |
|------------|---------|--------|
| 0.9 - 1.0 | High confidence, clear changes | Auto-process |
| 0.7 - 0.9 | Moderate confidence | Process with logging |
| 0.5 - 0.7 | Low confidence | Flag for review |
| < 0.5 | Uncertain | Require human review |

## Error Handling

| Error | Cause | Response |
|-------|-------|----------|
| `NO_PREVIOUS_VERSION` | First crawl of source | Treat all content as baseline |
| `CONTENT_TOO_LARGE` | Content exceeds token limit | Chunk and analyze sections |
| `ANALYSIS_TIMEOUT` | Claude analysis too slow | Retry with smaller context |
| `PARSE_FAILED` | Couldn't structure diff | Fall back to raw diff |
| `LOW_CONFIDENCE` | Analysis uncertain | Flag for human review |

## Quality Checklist

- [x] Distinguishes meaningful changes from noise
- [x] Correctly categorizes change types
- [x] Accurately assesses impact levels
- [x] Identifies affected Homer skills
- [x] Provides actionable summaries
- [x] Handles large documents via chunking
- [x] Flags uncertain analyses for review
- [x] Creates searchable keyword tags
- [x] Maintains change history chain
- [x] Queues changes for impact assessment

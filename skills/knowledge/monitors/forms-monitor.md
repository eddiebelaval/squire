# Skill: Forms Monitor

**Category:** Knowledge/Monitor
**Priority:** P1
**Approval Required:** Yes (for critical changes)

## Purpose

Monitor FAR/BAR contract forms, addenda, and disclosure documents for updates and revisions. This skill ensures Homer Pro uses current forms, understands form changes, and can guide agents on proper form usage and transition periods.

## Voice Commands

- "Are there any new FAR/BAR forms?"
- "What version of the As-Is contract should I use?"
- "Check for form updates"
- "When did the contract change?"
- "What's different in the new contract?"

## Triggers

### Scheduled
- **Daily:** Florida Realtors forms page
- **Weekly:** Florida Bar forms, FREC forms
- **Monthly:** Comprehensive form inventory check

### Event-Based
- Form revision announcement from Florida Realtors
- New form release notification
- Agent reports form version question

## Monitored Sources

### Primary Form Sources

| Source | URL | Frequency | Forms |
|--------|-----|-----------|-------|
| Florida Realtors Forms | floridarealtors.org/forms | Daily | FAR/BAR contracts, addenda |
| Florida Bar | floridabar.org | Weekly | Joint FAR/BAR forms |
| FREC | myfloridalicense.com | Monthly | Required disclosures |
| Florida Realtors Store | store.floridarealtors.org | Daily | Form availability |

### Form Types Monitored

| Category | Examples | Critical Level |
|----------|----------|---------------|
| Purchase Contracts | Residential, As-Is, Vacant Land | CRITICAL |
| Listing Agreements | Exclusive Right, Limited | HIGH |
| Addenda | Financing, Inspection, HOA | HIGH |
| Disclosures | Lead Paint, Property, Mold | CRITICAL |
| Buyer Rep | Buyer Representation Agreements | CRITICAL |
| Commission | Compensation Agreements | CRITICAL |

## Form Data Schema

```typescript
interface FormDefinition {
  form_id: string;
  form_number: string;        // e.g., "FR/BAR-AS IS-6"
  title: string;
  category: "contract" | "addendum" | "disclosure" | "listing" | "buyer_rep" | "other";
  current_version: string;     // e.g., "Rev. 12/25"
  previous_version?: string;
  effective_date: string;
  sunset_date?: string;        // When old version no longer valid

  source: "FAR" | "BAR" | "FAR_BAR" | "FREC" | "other";
  joint_form: boolean;

  changes_from_previous?: FormChange[];
  usage_notes?: string;
  related_forms?: string[];
}

interface FormChange {
  section: string;
  change_type: "added" | "modified" | "removed" | "renumbered";
  description: string;
  legal_significance: "high" | "medium" | "low";
  agent_action?: string;
}
```

## Execution Flow

```
START
  │
  ├─── 1. Check form sources
  │    ├── Florida Realtors forms library
  │    ├── Florida Bar real estate forms
  │    ├── FREC required disclosure forms
  │    └── Check for announcements/bulletins
  │
  ├─── 2. FOR EACH form category:
  │    │
  │    ├── 2a. Get current form inventory
  │    │   ├── List all forms in category
  │    │   ├── Note version numbers
  │    │   └── Check revision dates
  │    │
  │    ├── 2b. Compare to Homer's inventory
  │    │   ├── Identify new forms
  │    │   ├── Identify revised forms
  │    │   ├── Identify deprecated forms
  │    │   └── Flag version mismatches
  │    │
  │    └── 2c. FOR EACH changed form:
  │        │
  │        ├── Download new version
  │        ├── Download previous version
  │        │
  │        └── Analyze changes with Claude:
  │            """
  │            You are a Florida real estate forms expert.
  │
  │            FORM: {{form.title}} ({{form.form_number}})
  │            PREVIOUS VERSION: {{previous_version}}
  │            NEW VERSION: {{new_version}}
  │
  │            Compare these form versions and identify:
  │
  │            1. All textual changes (section by section)
  │
  │            2. For each change, assess:
  │               - Legal significance (HIGH/MEDIUM/LOW)
  │               - Impact on transaction flow
  │               - Required agent awareness
  │
  │            3. Changes to:
  │               - Deadlines or timing
  │               - Default values
  │               - Required disclosures
  │               - Signature requirements
  │               - Contingency language
  │
  │            4. Transition guidance:
  │               - Can old version still be used?
  │               - When must new version be adopted?
  │               - What if transaction started on old version?
  │
  │            5. Homer updates needed:
  │               - Deadline calculations
  │               - Template references
  │               - Compliance checks
  │            """
  │
  ├─── 3. Categorize changes by impact
  │    │
  │    ├── CRITICAL:
  │    │   ├── Contract term changes (deadlines, contingencies)
  │    │   ├── New mandatory disclosures
  │    │   ├── Signature/execution changes
  │    │   └── Liability language changes
  │    │
  │    ├── HIGH:
  │    │   ├── Form structure changes
  │    │   ├── Section renumbering
  │    │   ├── New optional provisions
  │    │   └── Default value changes
  │    │
  │    └── MEDIUM/LOW:
  │        ├── Clarification language
  │        ├── Formatting changes
  │        └── Minor wording updates
  │
  ├─── 4. Update Homer's form registry
  │    │
  │    ├── Update form definitions
  │    ├── Store form change history
  │    ├── Update deadline calculations if needed
  │    └── Update form selection logic
  │
  ├─── 5. Queue notifications
  │    │
  │    ├── CRITICAL: Immediate alert to all agents
  │    ├── HIGH: Include in daily briefing
  │    └── MEDIUM/LOW: Weekly forms digest
  │
  └─── 6. Generate form update report
```

## Form Change Examples

### Example 1: Contract Version Update

```yaml
form:
  form_number: "FR/BAR AS IS-7"
  title: "As Is Residential Contract For Sale And Purchase"
  category: contract
  source: FAR_BAR

version_change:
  previous_version: "Rev. 6/24"
  new_version: "Rev. 12/25"
  effective_date: "2026-02-01"
  sunset_date: "2026-05-01"  # Old version valid until

changes:
  - section: "12(a) Inspection Period"
    change_type: modified
    description: "Default inspection period reduced from 15 to 10 days"
    legal_significance: high
    impact: |
      - Buyers have less time for inspections
      - Agents should discuss timeline with buyers upfront
      - Consider negotiating longer period in Paragraph 12(a)
    agent_action: "Ensure buyers understand tighter timeline"

  - section: "8 Financing"
    change_type: modified
    description: "Added requirement for loan application within 5 days"
    legal_significance: high
    impact: "New deadline: Loan application due 5 days after effective date"
    agent_action: "Add to deadline calendar, remind buyers"

  - section: "19 Dispute Resolution"
    change_type: modified
    description: "Updated mediation language per NAR settlement"
    legal_significance: medium
    impact: "Clarifies mediation process for commission disputes"

  - section: "Addenda checklist"
    change_type: added
    description: "New checklist format for attached addenda"
    legal_significance: low
    impact: "Easier to track which addenda are attached"

transition_guidance:
  old_version_valid: true
  old_version_until: "2026-05-01"
  mixed_versions: "If contract started on v6, continue with v6"
  new_transactions: "Use v7 for contracts executed on or after 2/1/26"

homer_updates:
  - skill: "deadline/calculate-deadlines.md"
    change: "Update inspection default to 10 days, add loan app deadline"
  - skill: "deal/initiate-new-deal.md"
    change: "Detect contract version, use appropriate defaults"
  - skill: "compliance/florida-far-bar-rules.md"
    change: "Add v7 specific rules"

alert:
  level: CRITICAL
  message: |
    New FAR/BAR As-Is Contract (v7) effective February 1, 2026

    Key Changes:
    - Inspection period default: 15 → 10 days
    - New: Loan application due within 5 days

    Use v7 for all new contracts starting Feb 1.
    Existing contracts on v6 may continue on v6.
```

### Example 2: New Required Disclosure

```yaml
form:
  form_number: "WFD-1"
  title: "Wire Fraud Warning Disclosure"
  category: disclosure
  source: FREC

version_change:
  previous_version: null  # New form
  new_version: "Rev. 1/26"
  effective_date: "2026-07-01"

form_details:
  required: true
  timing: "At least 3 days before closing"
  parties_required: "All buyers in transaction"
  retention: "5 years"

content_summary:
  required_language:
    - "Warning about wire fraud schemes"
    - "Verification procedures for wire instructions"
    - "Contact information for title company"
    - "Instructions to verify via phone (not email)"
  signatures_required:
    - "Buyer(s) signature"
    - "Date signed"

compliance_requirements:
  delivery_method: "Written (email, DocuSign, in-person)"
  timing: "Closing date minus 3 days minimum"
  documentation: "Retain signed copy in transaction file"
  failure_consequence: "Potential liability for wire fraud losses"

homer_updates:
  - skill: "disclosure/required-disclosures.md"
    change: "Add Wire Fraud Disclosure to required list"
  - skill: "deadline/calculate-deadlines.md"
    change: "Add 'Wire Fraud Disclosure Due' (closing - 3 days)"
  - skill: "comms/templates/wire-fraud-disclosure.md"
    change: "Create new template"
  - skill: "compliance/closing-checklist.md"
    change: "Add Wire Fraud Disclosure checkbox"

alert:
  level: HIGH
  message: |
    New Required Form: Wire Fraud Warning Disclosure (WFD-1)

    Effective July 1, 2026, you must provide this disclosure
    to all buyers at least 3 days before closing.

    Homer will add this to your closing checklists automatically.
```

### Example 3: Buyer Rep Agreement Update

```yaml
form:
  form_number: "BRA-18"
  title: "Exclusive Buyer Brokerage Agreement"
  category: buyer_rep
  source: FAR

version_change:
  previous_version: "Rev. 8/24"
  new_version: "Rev. 1/26"
  effective_date: "2026-03-01"

changes:
  - section: "Compensation"
    change_type: modified
    description: "Expanded compensation disclosure per NAR settlement"
    legal_significance: high
    details: |
      - Must specify exact compensation amount/percentage
      - Must disclose if seeking from seller
      - Buyer must initial compensation section
    agent_action: "Review compensation terms with buyer before signing"

  - section: "Duration"
    change_type: modified
    description: "Maximum term limited to 6 months"
    legal_significance: medium
    details: "Cannot exceed 6 months without buyer renewal"

  - section: "Scope of Services"
    change_type: modified
    description: "Clearer definition of services included"
    legal_significance: low

homer_updates:
  - skill: "buyer/buyer-representation.md"
    change: "Update agreement process for new form"
  - skill: "compliance/disclosure-requirements.md"
    change: "Add compensation disclosure requirements"

alert:
  level: HIGH
```

## Form Registry Schema

```typescript
interface FormRegistry {
  last_updated: string;
  forms: FormDefinition[];

  categories: {
    contracts: string[];       // Form IDs
    addenda: string[];
    disclosures: string[];
    listings: string[];
    buyer_rep: string[];
    other: string[];
  };

  version_history: {
    form_id: string;
    versions: {
      version: string;
      effective_date: string;
      sunset_date?: string;
      changes?: string;
    }[];
  }[];

  current_transitions: {
    form_id: string;
    old_version: string;
    new_version: string;
    transition_end: string;
    guidance: string;
  }[];
}
```

## Output Schema

```typescript
interface FormsMonitorOutput {
  success: boolean;
  actionTaken: string;
  result: {
    forms_checked: number;
    updates_found: number;

    new_forms: FormUpdate[];
    revised_forms: FormUpdate[];
    deprecated_forms: FormUpdate[];

    active_transitions: {
      form_id: string;
      title: string;
      old_version: string;
      new_version: string;
      transition_ends: string;
    }[];

    homer_updates_needed: {
      form_id: string;
      skills_affected: string[];
      update_type: string;
    }[];

    alerts_sent: number;
    next_check: string;
  };
  shouldContinue: boolean;
}

interface FormUpdate {
  form_id: string;
  form_number: string;
  title: string;
  change_type: "new" | "revised" | "deprecated";
  version: string;
  effective_date: string;
  impact_level: "critical" | "high" | "medium" | "low";
  summary: string;
  changes?: FormChange[];
}
```

## Error Handling

| Error | Cause | Response |
|-------|-------|----------|
| `FORM_SOURCE_DOWN` | Florida Realtors site unavailable | Retry, use cached inventory |
| `FORM_PARSE_FAILED` | Can't extract form details | Alert admin, manual review |
| `VERSION_CONFLICT` | Unclear which version is current | Flag for review, don't auto-update |
| `FORM_NOT_FOUND` | Referenced form doesn't exist | Log warning, investigate |

## Quality Checklist

- [x] Monitors all FAR/BAR contract forms
- [x] Tracks addenda and disclosure forms
- [x] Detects version changes accurately
- [x] Analyzes form changes in detail
- [x] Identifies legal significance of changes
- [x] Provides transition guidance
- [x] Updates Homer's form registry
- [x] Alerts agents appropriately
- [x] Maintains form version history
- [x] Tracks active transition periods

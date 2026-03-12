# Skill: Lender Monitor

**Category:** Knowledge/Monitor
**Priority:** P1
**Approval Required:** No

## Purpose

Monitor lending guideline changes, mortgage product updates, and financing requirements from major lenders and GSEs. This skill ensures Homer Pro provides accurate financing guidance to agents and helps identify deals that may be affected by lending changes.

## Voice Commands

- "What are current loan requirements?"
- "Any changes to FHA guidelines?"
- "Check for lending updates"
- "What's the minimum down payment for conventional?"
- "Are there any new loan programs?"
- "What changed with [lender/program]?"

## Triggers

### Scheduled
- **Daily:** Major lender rate sheets, overlay updates
- **Weekly:** GSE guideline bulletins (Fannie/Freddie)
- **Monthly:** FHA/VA/USDA handbook updates
- **Quarterly:** Comprehensive lending landscape review

### Event-Based
- Conforming loan limit announcement (November)
- FHA limit announcement (December)
- Major lender guideline change
- New loan program launch

## Monitored Sources

### Government-Sponsored Enterprises (GSEs)

| Source | URL | Frequency | Focus |
|--------|-----|-----------|-------|
| Fannie Mae Selling Guide | fanniemae.com/selling-guide | Weekly | Conventional guidelines |
| Freddie Mac Guide | guide.freddiemac.com | Weekly | Conventional guidelines |
| FHA Handbook | hud.gov/program_offices/housing/sfh | Monthly | FHA requirements |
| VA Lender Handbook | benefits.va.gov/HOMELOANS | Monthly | VA loan requirements |
| USDA Handbook | rd.usda.gov/programs-services | Monthly | Rural development loans |

### Major Lenders (Overlays)

| Lender | Focus | Frequency |
|--------|-------|-----------|
| United Wholesale Mortgage | Wholesale guidelines | Weekly |
| Rocket Mortgage | Retail guidelines | Weekly |
| loanDepot | Retail/wholesale | Weekly |
| PennyMac | TPO guidelines | Weekly |
| Chase | Bank portfolio products | Monthly |
| Wells Fargo | Bank portfolio products | Monthly |

### Industry Sources

| Source | Focus | Frequency |
|--------|-------|-----------|
| Mortgage Bankers Association | Industry trends | Weekly |
| CFPB Bulletins | Regulatory changes | Event-based |
| FHFA Announcements | Conforming limits, policy | Event-based |

## Lending Data Schema

### GUIDELINE CHANGE

```typescript
interface GuidelineChange {
  source: string;              // "Fannie Mae", "FHA", etc.
  loan_type: "conventional" | "fha" | "va" | "usda" | "jumbo" | "other";
  change_type: "requirement" | "limit" | "program" | "rate" | "fee" | "process";

  bulletin_number?: string;    // e.g., "SEL-2026-01"
  effective_date: string;
  announcement_date: string;

  summary: string;
  details: string;

  previous_requirement?: string;
  new_requirement: string;

  impact: {
    borrower_types: string[];  // First-time, investor, etc.
    property_types: string[];  // SFR, condo, multi-family
    transaction_types: string[]; // Purchase, refi, cash-out
  };

  agent_implications: string;
  client_talking_points: string[];
}
```

### LOAN LIMITS

```typescript
interface LoanLimits {
  year: number;
  effective_date: string;

  conforming: {
    single_family: number;
    two_unit: number;
    three_unit: number;
    four_unit: number;
    high_cost_areas: HighCostArea[];
  };

  fha: {
    floor: number;
    ceiling: number;
    county_limits: CountyLimit[];
  };

  va: {
    standard: number;        // No limit with full entitlement
    high_cost_areas: HighCostArea[];
  };

  changes_from_previous: {
    conforming_change_pct: number;
    fha_change_pct: number;
  };
}

interface HighCostArea {
  county: string;
  state: string;
  limit: number;
}

interface CountyLimit {
  county: string;
  limit: number;
}
```

### LOAN REQUIREMENTS

```typescript
interface LoanRequirements {
  loan_type: string;
  last_updated: string;

  credit: {
    min_score: number;
    min_score_with_conditions?: { score: number; conditions: string[] };
    tradelines_required: number;
    credit_history_months: number;
  };

  down_payment: {
    minimum_pct: number;
    source_requirements: string[];
    gift_allowed: boolean;
    gift_donor_requirements?: string;
  };

  dti: {
    front_end_max: number;
    back_end_max: number;
    exceptions?: string;
  };

  reserves: {
    months_required: number;
    exceptions?: string;
  };

  property: {
    types_allowed: string[];
    appraisal_requirements: string;
    condition_requirements: string;
  };

  employment: {
    history_required_months: number;
    self_employed_requirements: string;
    gaps_allowed: string;
  };
}
```

## Execution Flow

```
START
  │
  ├─── 1. Check scheduled sources
  │    ├── Load source check schedule
  │    ├── Identify sources due for check
  │    └── Prioritize by importance
  │
  ├─── 2. FOR EACH source:
  │    │
  │    ├── 2a. Fetch updates
  │    │   ├── Check bulletin/announcement feeds
  │    │   ├── Check guideline documents
  │    │   └── Compare to cached versions
  │    │
  │    ├── 2b. Parse changes
  │    │   ├── Extract bulletin numbers
  │    │   ├── Identify affected programs
  │    │   └── Note effective dates
  │    │
  │    └── 2c. Analyze with Claude
  │        """
  │        You are a mortgage lending guideline expert.
  │
  │        SOURCE: {{source.name}}
  │        UPDATE TYPE: {{update_type}}
  │
  │        NEW CONTENT:
  │        {{content}}
  │
  │        Analyze this lending update:
  │
  │        1. What specifically changed?
  │           - Previous requirement/limit
  │           - New requirement/limit
  │
  │        2. Who is affected?
  │           - Borrower types (first-time, investor, etc.)
  │           - Property types (SFR, condo, multi-family)
  │           - Loan amounts
  │
  │        3. Impact level:
  │           - CRITICAL: Affects loan eligibility
  │           - HIGH: Affects terms significantly
  │           - MEDIUM: Process or documentation change
  │           - LOW: Minor clarification
  │
  │        4. Florida-specific implications:
  │           - Condo approval issues
  │           - Insurance requirements
  │           - Hurricane-related requirements
  │
  │        5. Agent talking points:
  │           - How to explain to clients
  │           - Deal-saving strategies
  │
  │        6. Active deals potentially affected:
  │           - What deal characteristics would be impacted
  │        """
  │
  ├─── 3. Check for annual limit updates
  │    │
  │    ├── November: Check FHFA conforming limit announcement
  │    ├── December: Check FHA limit announcement
  │    │
  │    └── IF new limits announced:
  │        ├── Parse county-level limits for Florida
  │        ├── Calculate changes from current year
  │        └── Update Homer's limit tables
  │
  ├─── 4. Categorize by impact
  │    │
  │    ├── CRITICAL (immediate alert):
  │    │   ├── Credit score minimum changes
  │    │   ├── Down payment requirement changes
  │    │   ├── DTI limit changes
  │    │   ├── Property type eligibility changes
  │    │   └── Loan limit announcements
  │    │
  │    ├── HIGH (daily briefing):
  │    │   ├── Documentation requirement changes
  │    │   ├── Reserve requirement changes
  │    │   ├── Rate/fee changes
  │    │   └── New program launches
  │    │
  │    └── MEDIUM/LOW (weekly digest):
  │        ├── Process clarifications
  │        └── Minor guideline updates
  │
  ├─── 5. Match to active deals
  │    │
  │    ├── Query deals with financing contingencies
  │    │
  │    ├── FOR EACH potentially affected deal:
  │    │   ├── Check loan type match
  │    │   ├── Check borrower profile match
  │    │   └── Flag if change could affect approval
  │    │
  │    └── Create deal-specific alerts
  │
  ├─── 6. Update Homer's lending knowledge
  │    ├── Update loan requirement tables
  │    ├── Update limit tables
  │    └── Refresh agent talking points
  │
  └─── 7. Return lending report
```

## Change Examples

### Example 1: Conforming Loan Limit Increase

```yaml
source: FHFA
announcement_date: 2025-11-26
effective_date: 2026-01-01

change:
  type: limit
  loan_type: conventional

  previous:
    single_family: $766,550
    high_cost_max: $1,149,825

  new:
    single_family: $802,650
    high_cost_max: $1,203,975

  change_pct: +4.7%

florida_high_cost_counties:
  - county: "Monroe"
    limit: $929,200
  - county: "Collier"
    limit: $802,650  # Standard

impact:
  level: CRITICAL
  summary: "Buyers can borrow ~$36K more under conventional limits"

buyer_impact: |
  - Can purchase higher-priced homes without jumbo loan
  - Better rates available up to new limit
  - Down payment requirements same percentage but higher dollars

agent_talking_points:
  - "Good news for buyers - you can qualify for a bigger loan at conventional rates"
  - "Homes up to $802,650 now eligible for best conventional rates"
  - "This is the biggest limit increase in years"

alert:
  level: CRITICAL
  timing: "Announce in November for January transactions"
  message: |
    2026 Conforming Loan Limits Announced

    New limit: $802,650 (up $36,100 from 2025)

    This means buyers can purchase higher-priced homes
    with conventional financing and better rates.

    [View County Limits] [Calculator]
```

### Example 2: FHA Credit Score Overlay Change

```yaml
source: United Wholesale Mortgage
bulletin: "UWM 2026-05"
effective_date: 2026-02-01

change:
  type: requirement
  loan_type: fha
  category: credit

  previous:
    min_score: 580
    min_score_96.5_ltv: 580

  new:
    min_score: 600
    min_score_96.5_ltv: 620

  scope: "Overlay (UWM specific, not FHA guideline)"

impact:
  level: HIGH
  borrowers_affected: "FHA buyers with 580-619 credit"

  implications:
    - "Borrowers with 580-599 credit no longer eligible at UWM"
    - "Borrowers with 600-619 need 5%+ down payment"
    - "Other lenders may still offer lower scores"

agent_action: |
  For clients affected by this change:
  - Check credit score on current deals
  - Consider alternative lenders
  - Discuss credit improvement if time allows

alternative_lenders:
  - name: "Carrington Mortgage"
    min_score: 500
  - name: "NewRez"
    min_score: 580

alert:
  level: HIGH
  include_in: daily_briefing
```

### Example 3: Condo Approval Requirement Change

```yaml
source: Fannie Mae
bulletin: "SEL-2026-03"
effective_date: 2026-03-15

change:
  type: requirement
  loan_type: conventional
  category: property
  property_type: condo

  summary: "New reserve requirements for condo project approval"

  previous:
    reserve_requirement: "10% of annual budget"

  new:
    reserve_requirement: "15% of annual budget or completed reserve study"
    additional: "Buildings 4+ stories require structural inspection"

florida_specific:
  relevance: "HIGH - Many FL condos affected"
  connection_to_condo_safety_law: |
    Aligns with Florida SB 4-D condo safety requirements.
    Buildings without completed inspections may face
    financing challenges.

impact:
  level: CRITICAL

  affected_properties: |
    - Condos in buildings 4+ stories
    - Condos with reserves below 15%
    - Older buildings without reserve studies

  financing_risk: |
    Buyers may not be able to get conventional financing
    for condos that don't meet new requirements.

agent_action: |
  For condo transactions:
  - Verify reserve percentage early
  - Check for reserve study availability
  - For 4+ story buildings, confirm structural inspection
  - Have backup financing plan (portfolio lender)

deals_to_review:
  criteria: "Active deals with condo property type"
  action: "Verify project meets new requirements"

alert:
  level: CRITICAL
```

## Florida Loan Limits Table

```typescript
interface FloridaLoanLimits {
  year: number;
  conventional: {
    standard: number;
    high_cost_counties: {
      county: string;
      limit: number;
    }[];
  };
  fha: {
    floor: number;
    ceiling: number;
    by_county: {
      county: string;
      limit: number;
    }[];
  };
}

// Example for 2026
const FLORIDA_LIMITS_2026: FloridaLoanLimits = {
  year: 2026,
  conventional: {
    standard: 802650,
    high_cost_counties: [
      { county: "Monroe", limit: 929200 }
    ]
  },
  fha: {
    floor: 498257,
    ceiling: 1149825,
    by_county: [
      { county: "Miami-Dade", limit: 621000 },
      { county: "Broward", limit: 621000 },
      { county: "Palm Beach", limit: 621000 },
      { county: "Monroe", limit: 929200 },
      { county: "Collier", limit: 580400 },
      // ... all 67 counties
    ]
  }
};
```

## Output Schema

```typescript
interface LenderMonitorOutput {
  success: boolean;
  actionTaken: string;
  result: {
    sources_checked: number;
    updates_found: number;

    guideline_changes: GuidelineChange[];

    by_loan_type: {
      conventional: number;
      fha: number;
      va: number;
      usda: number;
      jumbo: number;
    };

    by_impact: {
      critical: number;
      high: number;
      medium: number;
      low: number;
    };

    limit_updates: {
      year: number;
      type: string;
      new_limit: number;
      change: number;
    }[];

    deals_affected: {
      deal_id: string;
      property: string;
      loan_type: string;
      change: string;
      impact: string;
    }[];

    homer_updates_needed: string[];

    next_check: string;
  };
  shouldContinue: boolean;
}
```

## Error Handling

| Error | Cause | Response |
|-------|-------|----------|
| `SOURCE_UNAVAILABLE` | Lender site down | Use cached guidelines, log staleness |
| `BULLETIN_PARSE_FAILED` | Can't parse guideline document | Alert admin, flag for manual review |
| `LIMIT_DATA_MISSING` | County limit not found | Use standard limit, flag for verification |
| `CONFLICTING_INFO` | Sources disagree | Note conflict, recommend verification |

## Quality Checklist

- [x] Monitors all major GSE guidelines
- [x] Tracks lender-specific overlays
- [x] Catches annual limit updates
- [x] Identifies Florida-specific implications
- [x] Provides agent talking points
- [x] Matches changes to active deals
- [x] Maintains current loan limit tables
- [x] Alerts by impact level
- [x] Updates Homer's lending knowledge
- [x] Tracks condo approval requirements

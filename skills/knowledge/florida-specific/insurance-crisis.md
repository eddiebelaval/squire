# Skill: Insurance Crisis Monitor

**Category:** Knowledge/Florida-Specific
**Priority:** P1
**Approval Required:** No

## Purpose

Monitor Florida's ongoing property insurance market crisis, including carrier solvency, rate changes, availability issues, Citizens Insurance status, and policy requirements that affect real estate transactions. This skill helps agents navigate insurance challenges that frequently derail Florida deals.

## Voice Commands

- "What's happening with Florida insurance?"
- "Can my buyer get insurance in [area]?"
- "Which insurance companies are still writing in Florida?"
- "What's the status of Citizens?"
- "Are there any new insurance requirements?"
- "Insurance update for [county]"

## Triggers

### Scheduled
- **Daily:** Carrier news, Citizens updates
- **Weekly:** Rate filing tracker, carrier status
- **Monthly:** Market analysis, availability assessment
- **Quarterly:** Comprehensive insurance landscape report

### Event-Based
- Carrier insolvency announcement
- Major rate filing approval
- Citizens eligibility change
- Legislative insurance reform
- Hurricane season impact on market

## Monitored Sources

### Regulatory Sources

| Source | URL | Frequency | Focus |
|--------|-----|-----------|-------|
| FL Office of Insurance Regulation | floir.com | Daily | Filings, orders |
| FL Insurance Consumer Advocate | myfloridacfo.com | Weekly | Consumer issues |
| Citizens Property Insurance | citizensfl.com | Daily | Citizens status |
| FIGA (Guaranty Association) | figafacts.com | Event-based | Insolvencies |

### Industry Sources

| Source | Focus | Frequency |
|--------|-------|-----------|
| Insurance Journal | Industry news | Daily |
| Florida Insurance News | FL-specific | Daily |
| AM Best | Carrier ratings | Weekly |
| Demotech | Financial ratings | Event-based |
| FLOIR Rate Filings | Rate changes | Weekly |

### Market Participants

| Carrier Type | Examples | Monitoring |
|--------------|----------|------------|
| Florida Domestics | Universal, Heritage, Federated National | Daily |
| National Carriers | State Farm, Allstate (limited FL) | Weekly |
| Citizens | Citizens Property Insurance | Daily |
| Surplus Lines | Lloyd's, various | Weekly |

## Insurance Market Schema

```typescript
interface FloridaInsuranceMarket {
  last_updated: string;
  market_status: "crisis" | "stressed" | "stabilizing" | "normal";

  carriers: CarrierStatus[];

  citizens: {
    policy_count: number;
    trend: "growing" | "stable" | "declining";
    exposure: number;  // Billions
    depopulation_active: boolean;
    eligibility_changes?: string;
  };

  availability: {
    by_county: CountyAvailability[];
    coastal_restrictions: string[];
    wind_only_areas: string[];
  };

  rates: {
    average_increase_ytd: number;
    pending_filings: RateFiling[];
    recent_approvals: RateFiling[];
  };

  legislative: {
    recent_reforms: string[];
    pending_legislation: string[];
    effective_dates: Record<string, string>;
  };
}

interface CarrierStatus {
  name: string;
  am_best_rating?: string;
  demotech_rating?: string;
  status: "writing" | "limited" | "non-renewing" | "insolvent" | "exited";
  florida_exposure: number;
  writing_new: boolean;
  counties_writing?: string[];
  restrictions?: string[];
  recent_news?: string;
}

interface CountyAvailability {
  county: string;
  availability: "good" | "limited" | "difficult" | "critical";
  carriers_writing: number;
  citizens_percentage: number;
  average_premium: number;
  notes?: string;
}

interface RateFiling {
  carrier: string;
  type: "homeowners" | "wind_only" | "flood";
  requested_change: number;
  approved_change?: number;
  status: "pending" | "approved" | "denied" | "withdrawn";
  effective_date?: string;
}
```

## Transaction Impact Schema

```typescript
interface InsuranceTransactionImpact {
  property: {
    address: string;
    county: string;
    property_type: string;
    roof_age?: number;
    construction_year?: number;
    flood_zone?: string;
  };

  availability_assessment: {
    difficulty: "easy" | "moderate" | "difficult" | "very_difficult";
    estimated_carriers: number;
    citizens_likely: boolean;
    expected_timeline_days: number;
  };

  cost_estimate: {
    annual_premium_range: { low: number; high: number };
    wind_coverage: number;
    flood_if_required: number;
    total_annual: { low: number; high: number };
  };

  potential_issues: {
    issue: string;
    likelihood: "high" | "medium" | "low";
    mitigation: string;
  }[];

  requirements: {
    roof_inspection_likely: boolean;
    four_point_required: boolean;
    wind_mitigation_helpful: boolean;
    flood_required: boolean;
  };

  recommendations: string[];

  lender_considerations: {
    acceptable_carriers: string[];
    rating_requirements: string;
    escrow_requirements: string;
  };
}
```

## Execution Flow

```
START
  │
  ├─── 1. Check carrier status
  │    │
  │    ├── Monitor for insolvency announcements
  │    ├── Track carrier rating changes
  │    ├── Check for market entry/exit news
  │    │
  │    └── Update carrier status database
  │
  ├─── 2. Check Citizens Insurance
  │    │
  │    ├── Policy count updates
  │    ├── Eligibility changes
  │    ├── Rate changes
  │    ├── Depopulation programs
  │    │
  │    └── Assess Citizens growth trend
  │
  ├─── 3. Monitor rate filings
  │    │
  │    ├── New filings submitted
  │    ├── Filing approvals/denials
  │    ├── Calculate market-wide trends
  │    │
  │    └── Track effective dates
  │
  ├─── 4. Assess county availability
  │    │
  │    ├── FOR EACH Florida county:
  │    │   ├── Count active carriers
  │    │   ├── Check Citizens share
  │    │   ├── Note any restrictions
  │    │   └── Assess difficulty level
  │    │
  │    └── Identify problem areas
  │
  ├─── 5. Monitor legislative changes
  │    │
  │    ├── Track insurance reform bills
  │    ├── Note regulatory changes
  │    └── Update requirement knowledge
  │
  ├─── 6. Analyze transaction impacts
  │    │
  │    └── PROMPT:
  │        """
  │        You are a Florida insurance market expert.
  │
  │        CURRENT MARKET STATUS:
  │        {{market_status}}
  │
  │        RECENT DEVELOPMENTS:
  │        {{recent_developments}}
  │
  │        Analyze how these developments affect:
  │
  │        1. Transaction timelines:
  │           - How long to obtain insurance quotes?
  │           - Closing delays expected?
  │
  │        2. Buyer affordability:
  │           - Premium increases impact on DTI
  │           - Escrow increases
  │
  │        3. Property types most affected:
  │           - Coastal properties
  │           - Older homes
  │           - Condos
  │
  │        4. Agent guidance:
  │           - What to tell buyers early
  │           - When to involve insurance agent
  │           - Contingency recommendations
  │
  │        5. Deal-saving strategies:
  │           - Wind mitigation credits
  │           - Roof certification value
  │           - Citizens as backup
  │        """
  │
  ├─── 7. Generate agent guidance
  │    ├── County-specific availability
  │    ├── Timeline expectations
  │    ├── Cost estimates
  │    └── Risk mitigation tips
  │
  └─── 8. Return insurance update
```

## County Availability Ratings

```typescript
const COUNTY_RATINGS = {
  // Examples - Updated dynamically
  critical: [
    "Monroe",       // Keys - extreme difficulty
  ],

  difficult: [
    "Miami-Dade",   // Coastal exposure
    "Broward",      // High claims history
    "Palm Beach",   // Coastal exposure
  ],

  limited: [
    "Lee",          // Ian impact
    "Collier",      // Coastal
    "Pinellas",     // Peninsula exposure
    "Brevard",      // Coastal
  ],

  moderate: [
    "Hillsborough",
    "Orange",
    "Duval",
    "Volusia",
  ],

  good: [
    "Alachua",
    "Leon",
    "Marion",
    // Interior counties
  ]
};
```

## Insurance Alert Examples

### Example 1: Carrier Insolvency

```yaml
trigger: Carrier insolvency announcement
detected: 2026-01-15

carrier:
  name: "Florida Peninsula Insurance"
  status: "INSOLVENT"
  policies_affected: 85000
  claims_status: "Transferred to FIGA"

impact:
  level: HIGH
  affected_deals: |
    - Buyers with pending policies from this carrier
    - Sellers whose buyers had this carrier
    - Existing policies being assumed

agent_action:
  immediate:
    - "Check if any pending deals have Florida Peninsula policies"
    - "Contact buyers to arrange replacement coverage"
    - "May delay closings while new coverage obtained"

  for_affected_deals:
    - "FIGA covers claims but new policy needed"
    - "Allow 2-3 weeks for replacement coverage"
    - "Consider Citizens as backup"

alert:
  level: HIGH
  recipients: all_agents
  message: |
    CARRIER ALERT: Florida Peninsula Insurance declared insolvent

    ~85,000 policies affected statewide.

    If you have deals with Florida Peninsula coverage:
    - Buyer needs replacement policy before closing
    - Allow extra 2-3 weeks for insurance
    - Contact insurance agent immediately

    [Check My Deals] [Carrier Alternatives]
```

### Example 2: Citizens Eligibility Change

```yaml
trigger: Citizens policy change
effective: 2026-04-01

change:
  type: eligibility
  summary: "Citizens coverage limit reduced to $700,000 (from $1M)"

details: |
  Properties with insurable value over $700,000 are no longer
  eligible for Citizens coverage. Must obtain private market
  insurance or surplus lines.

impact:
  affected_properties: "Homes valued $700K-$1M"
  market_effect: "More homes pushed to surplus lines"
  premium_impact: "Likely higher premiums for affected properties"

agent_guidance:
  for_listings:
    - "Disclose insurance challenges for luxury homes"
    - "Obtain insurance quotes before listing"

  for_buyers:
    - "Insurance quotes critical for homes over $700K"
    - "Budget for potentially higher premiums"
    - "Start insurance shopping immediately"

alert:
  level: MEDIUM
  include_in: weekly_digest
```

### Example 3: County Availability Crisis

```yaml
trigger: Multiple carriers exit county
detected: 2026-01-20

county: "Lee County"

situation:
  carriers_remaining: 3
  carriers_12_months_ago: 12
  citizens_share: 45%
  average_premium: $8500
  wait_time_days: 30-45

analysis:
  cause: "Post-Ian claims losses driving carrier exits"
  trend: "Worsening"
  stabilization_expected: "Not before 2027"

transaction_impact:
  difficulty: "very_difficult"
  timeline: "Add 30-45 days for insurance"
  premium_impact: "50-100% higher than 2023"

agent_guidance:
  for_buyers:
    - "Start insurance shopping at contract signing"
    - "Budget $7000-$10000+ annual insurance"
    - "Consider insurance contingency"
    - "Wind mitigation inspection highly valuable"

  for_sellers:
    - "Provide all mitigation docs upfront"
    - "Roof certification if roof < 10 years"
    - "Expect insurance-related delays"

alert:
  level: HIGH
  recipients: agents_in_lee_county
```

## Property Assessment Tool

```typescript
interface InsurancePropertyAssessment {
  input: {
    address: string;
    property_type: "single_family" | "condo" | "townhouse";
    year_built: number;
    roof_age: number;
    roof_type: string;
    construction: string;
    flood_zone: string;
    distance_to_coast_miles: number;
  };

  assessment: {
    difficulty_score: number;  // 1-10
    difficulty_label: string;
    estimated_premium_range: { low: number; high: number };
    carriers_likely_to_quote: number;
    citizens_eligible: boolean;
    days_to_obtain_quotes: number;

    risk_factors: {
      factor: string;
      impact: "major" | "moderate" | "minor";
      mitigation?: string;
    }[];

    recommendations: {
      priority: number;
      action: string;
      benefit: string;
      cost_estimate?: string;
    }[];
  };
}
```

## Agent Talking Points

```typescript
const INSURANCE_TALKING_POINTS = {
  for_buyers: [
    "Florida's insurance market is challenging but manageable with planning",
    "Start your insurance search as soon as you're under contract",
    "Budget for insurance costs of $X-$Y based on property location",
    "Wind mitigation inspections can save 20-40% on premiums",
    "Newer roofs (under 10-15 years) dramatically improve options",
    "We may need to consider an insurance contingency"
  ],

  for_sellers: [
    "Having insurance info ready helps buyers move faster",
    "Wind mitigation report is a valuable selling tool",
    "Roof certification (if applicable) can help close deals",
    "Some buyers may be limited by insurance availability",
    "Price may need to account for insurance costs in your area"
  ],

  market_context: [
    "Florida has lost XX carriers in the past 3 years",
    "Citizens is now the largest insurer with XX policies",
    "Recent reforms aim to stabilize market by 2027-2028",
    "Rates are still rising but pace is slowing"
  ]
};
```

## Output Schema

```typescript
interface InsuranceCrisisOutput {
  success: boolean;
  actionTaken: string;
  result: {
    market_status: string;
    last_updated: string;

    carrier_updates: {
      new_insolvencies: string[];
      rating_changes: { carrier: string; change: string }[];
      market_exits: string[];
      market_entries: string[];
    };

    citizens_status: {
      policy_count: number;
      change_mom: number;
      upcoming_changes: string[];
    };

    rate_trends: {
      average_increase_ytd: number;
      pending_filings: number;
      recent_approvals: { carrier: string; change: number }[];
    };

    county_alerts: {
      county: string;
      status: string;
      change: string;
    }[];

    affected_deals: {
      deal_id: string;
      property: string;
      issue: string;
      recommendation: string;
    }[];

    next_update: string;
  };
  shouldContinue: boolean;
}
```

## Error Handling

| Error | Cause | Response |
|-------|-------|----------|
| `OIR_UNAVAILABLE` | Regulator site down | Use cached data, note staleness |
| `CARRIER_DATA_MISSING` | Can't get carrier status | Flag for manual research |
| `RATE_PARSE_FAILED` | Can't parse rate filing | Alert admin |
| `COUNTY_ASSESSMENT_FAILED` | Can't assess county | Use regional default |

## Quality Checklist

- [x] Monitors all major FL carriers
- [x] Tracks Citizens growth and changes
- [x] Monitors rate filings
- [x] Assesses county-level availability
- [x] Provides property-specific assessments
- [x] Gives actionable agent guidance
- [x] Tracks legislative changes
- [x] Alerts on carrier insolvencies
- [x] Updates premium estimates
- [x] Includes buyer/seller talking points

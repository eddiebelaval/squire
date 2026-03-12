# Skill: Condo Safety Monitor

**Category:** Knowledge/Florida-Specific
**Priority:** P1
**Approval Required:** No

## Purpose

Monitor Florida condo safety law compliance (SB 4-D, SB 154, and related legislation) including structural inspection requirements, reserve study mandates, and milestone inspections. This skill helps agents navigate condo transactions affected by post-Surfside collapse regulations.

## Voice Commands

- "What are the condo safety requirements?"
- "Has this building passed its milestone inspection?"
- "What's the reserve status for [condo]?"
- "Are there any condo compliance issues?"
- "Check condo safety status for [building]"
- "Is this condo financeable?"

## Triggers

### Scheduled
- **Daily:** DBPR updates, condo compliance filings
- **Weekly:** Building inspection status updates
- **Monthly:** Reserve study compliance tracking
- **Quarterly:** Legislation update review

### Event-Based
- New building inspection filed
- Compliance deadline approaching
- Building fails inspection
- Reserve shortfall reported
- Association meeting with major decisions

## Monitored Sources

### Regulatory Sources

| Source | URL | Frequency | Focus |
|--------|-----|-----------|-------|
| FL DBPR Condos | myfloridalicense.com/dbpr/condos | Daily | Condo filings |
| FL Legislature | flsenate.gov | Weekly | New legislation |
| Local Building Depts | Varies by county | Weekly | Inspection status |
| FL Condo Ombudsman | myfloridalicense.com | Weekly | Compliance issues |

### Industry Sources

| Source | Focus | Frequency |
|--------|-------|-----------|
| Community Associations Institute | Best practices | Weekly |
| FL CAI Chapter | FL-specific guidance | Weekly |
| Engineering Firms | Inspection reports | Event-based |
| Condo Association Filings | Annual reports, reserves | Quarterly |

## Condo Compliance Schema

```typescript
interface CondoBuilding {
  building_id: string;
  name: string;
  address: string;
  county: string;

  building_info: {
    stories: number;
    units: number;
    year_built: number;
    construction_type: string;
    coastal: boolean;
    distance_to_coast_miles?: number;
  };

  milestone_inspection: {
    required: boolean;
    due_date?: string;
    status: "not_required" | "pending" | "scheduled" | "completed" | "failed" | "overdue";
    completion_date?: string;
    result?: "passed" | "repairs_required" | "failed";
    reinspection_date?: string;
    engineer_of_record?: string;
  };

  structural_integrity: {
    sirs_required: boolean;      // Structural Integrity Reserve Study
    sirs_completed?: boolean;
    sirs_date?: string;
    next_sirs_due?: string;
    critical_findings?: string[];
  };

  reserves: {
    study_completed: boolean;
    study_date?: string;
    funded_percentage: number;
    meets_new_requirements: boolean;
    special_assessments_pending?: number;
    monthly_reserve_increase?: number;
  };

  financing_status: {
    fannie_approved: boolean;
    freddie_approved: boolean;
    fha_approved: boolean;
    va_approved: boolean;
    known_lenders_declining?: string[];
  };

  compliance_status: {
    overall: "compliant" | "pending" | "non_compliant" | "unknown";
    issues: ComplianceIssue[];
    deadline_alerts: DeadlineAlert[];
  };
}

interface ComplianceIssue {
  type: string;
  description: string;
  severity: "critical" | "major" | "minor";
  deadline?: string;
  impact_on_sales: string;
  remediation_status?: string;
}

interface DeadlineAlert {
  requirement: string;
  deadline: string;
  days_until: number;
  consequence: string;
}
```

## Transaction Impact Schema

```typescript
interface CondoTransactionImpact {
  building_id: string;
  building_name: string;

  transactability: {
    status: "clear" | "caution" | "difficult" | "problematic";
    summary: string;
  };

  financing_impact: {
    conventional_available: boolean;
    fha_available: boolean;
    va_available: boolean;
    cash_only_likely: boolean;
    lender_concerns: string[];
  };

  disclosure_requirements: {
    required_documents: string[];
    inspection_status_disclosure: boolean;
    reserve_disclosure: boolean;
    special_assessment_disclosure: boolean;
  };

  buyer_considerations: {
    special_assessments: {
      current_pending: number;
      future_likely: boolean;
      estimated_amount?: number;
    };
    reserve_contribution: {
      current_monthly: number;
      increasing_to?: number;
      increase_date?: string;
    };
    structural_concerns: string[];
  };

  timeline_impact: {
    additional_due_diligence_days: number;
    lender_questionnaire_delay: number;
    total_expected_delay: number;
  };

  agent_guidance: {
    for_buyers: string[];
    for_sellers: string[];
    deal_risks: string[];
    mitigation_strategies: string[];
  };
}
```

## Execution Flow

```
START
  │
  ├─── 1. Check regulatory updates
  │    │
  │    ├── DBPR condo filings
  │    ├── New legislation
  │    ├── Compliance deadlines
  │    └── Enforcement actions
  │
  ├─── 2. Monitor building compliance
  │    │
  │    ├── Track milestone inspection statuses
  │    ├── Monitor reserve study filings
  │    ├── Check for structural findings
  │    └── Note special assessments
  │
  ├─── 3. Track deadline calendar
  │    │
  │    ├── Milestone inspection deadlines
  │    │   ├── Buildings 30+ years, 3+ stories: Dec 31, 2024
  │    │   ├── Buildings 25+ years (coastal): Dec 31, 2024
  │    │   ├── New buildings reaching 30 years: 30th anniversary
  │    │   └── Coastal buildings reaching 25 years: 25th anniversary
  │    │
  │    ├── Reserve study deadlines
  │    │   ├── SIRS required by Dec 31, 2024
  │    │   ├── Full funding plan by Dec 31, 2025
  │    │   └── Annual reserve disclosures
  │    │
  │    └── Alert on approaching deadlines
  │
  ├─── 4. Assess financing implications
  │    │
  │    ├── Check Fannie/Freddie condo project lists
  │    ├── Monitor lender overlay changes
  │    ├── Track FHA/VA approval status
  │    └── Identify cash-only situations
  │
  ├─── 5. Generate transaction guidance
  │    │
  │    └── PROMPT:
  │        """
  │        You are a Florida condo transaction expert.
  │
  │        BUILDING: {{building.name}}
  │        COMPLIANCE STATUS: {{building.compliance_status}}
  │        RESERVE STATUS: {{building.reserves}}
  │        INSPECTION STATUS: {{building.milestone_inspection}}
  │
  │        Analyze transaction implications:
  │
  │        1. Financing availability:
  │           - Can buyers get conventional loans?
  │           - FHA/VA options?
  │           - Cash-only likely?
  │
  │        2. Buyer cost impacts:
  │           - Current HOA fees
  │           - Expected increases
  │           - Special assessments pending/likely
  │           - Total cost of ownership
  │
  │        3. Due diligence requirements:
  │           - Documents to request
  │           - Questions for association
  │           - Red flags to watch
  │
  │        4. Disclosure obligations:
  │           - What must seller disclose?
  │           - What should agent recommend?
  │
  │        5. Deal structure recommendations:
  │           - Contingency language
  │           - Timeline adjustments
  │           - Price considerations
  │        """
  │
  ├─── 6. Match to active deals
  │    ├── Identify condo transactions
  │    ├── Check building compliance status
  │    └── Generate deal-specific alerts
  │
  └─── 7. Return compliance report
```

## Milestone Inspection Requirements

```typescript
const MILESTONE_INSPECTION_REQUIREMENTS = {
  // Per SB 4-D (2022) and updates

  required_for: {
    stories: 3,  // Buildings 3+ stories
    age_general: 30,  // 30 years from CO
    age_coastal: 25,  // 25 years if within 3 miles of coast
  },

  phases: {
    phase1: {
      description: "Visual examination of structural components",
      scope: [
        "Load-bearing walls and primary structural members",
        "Floor systems",
        "Foundations",
        "Fireproofing",
        "Plumbing",
        "Electrical systems",
        "Waterproofing and exterior painting",
        "Windows and exterior doors"
      ],
      outcome: "Determines if Phase 2 needed"
    },

    phase2: {
      required_when: "Phase 1 finds substantial structural deterioration",
      description: "Extensive testing and analysis",
      scope: [
        "Core samples",
        "Destructive testing",
        "Detailed structural analysis"
      ],
      timeline: "Must begin within 180 days of Phase 1"
    }
  },

  deadlines: {
    existing_buildings_30_plus: "December 31, 2024",
    existing_buildings_25_plus_coastal: "December 31, 2024",
    newly_qualifying: "Within 30 years (or 25 if coastal) of CO"
  },

  consequences: {
    non_compliance: [
      "Potential fines from local government",
      "May affect certificate of occupancy",
      "Financing difficulties",
      "Resale challenges"
    ]
  }
};
```

## Reserve Requirements

```typescript
const RESERVE_REQUIREMENTS = {
  // Per SB 4-D and SB 154

  structural_integrity_reserve_study: {
    required_for: "Buildings 3+ stories",
    first_deadline: "December 31, 2024",
    frequency: "Every 10 years",

    must_include: [
      "Roof",
      "Load-bearing walls",
      "Foundation",
      "Plumbing",
      "Electrical systems",
      "Waterproofing",
      "Windows and exterior doors",
      "Other structural components"
    ]
  },

  funding_requirements: {
    no_waiver_after: "December 31, 2024",
    pooling_allowed: false,  // No more pooled reserves
    full_funding_deadline: "December 31, 2025",

    disclosure_required: [
      "Reserve balance",
      "Percentage funded",
      "Any planned special assessments",
      "Reserve study summary"
    ]
  },

  transaction_implications: {
    buyer_must_receive: [
      "Most recent reserve study",
      "Current reserve funding level",
      "Pending or anticipated special assessments",
      "Budget including reserve contributions"
    ],

    seller_disclosure: "Mandatory within 15 days of request"
  }
};
```

## Alert Examples

### Example 1: Building Fails Milestone Inspection

```yaml
trigger: Phase 1 inspection finds substantial deterioration
building: "Ocean View Towers"
address: "1500 Ocean Drive, Fort Lauderdale"

inspection_result:
  phase: 1
  finding: "Substantial structural deterioration"
  details: |
    - Concrete spalling on parking garage levels 1-3
    - Rebar corrosion in load-bearing columns
    - Water intrusion in foundation
  required_action: "Phase 2 inspection required within 180 days"
  estimated_repair_cost: "$8-12 million"

transaction_impact:
  status: "PROBLEMATIC"
  financing: "Likely cash-only until repairs complete"
  special_assessment: "Expected $40,000-$60,000 per unit"

alert:
  level: CRITICAL
  recipients: agents_with_deals_in_building
  message: |
    CONDO ALERT: Ocean View Towers Failed Phase 1 Inspection

    Phase 1 milestone inspection found substantial structural deterioration.

    IMMEDIATE IMPACTS:
    - Phase 2 inspection required (180 days)
    - Financing likely unavailable
    - Special assessment expected ($40-60K/unit)

    IF YOU HAVE A DEAL IN THIS BUILDING:
    - Discuss findings with buyer immediately
    - Consider termination options
    - Document all disclosures

    [View Full Report] [Contact Support]
```

### Example 2: Reserve Study Reveals Shortfall

```yaml
trigger: SIRS filing shows underfunding
building: "Palm Gardens Condominiums"
county: "Miami-Dade"

reserve_status:
  funded_percentage: 35%
  required_percentage: 100%
  shortfall: "$2.4 million"
  plan: "10-year phase-in with assessment and fee increase"
  monthly_increase: "$350 per unit"
  special_assessment: "$8,000 per unit"

transaction_impact:
  financing: "Available but lender review required"
  buyer_cost_increase: "$4,200/year in reserves + $8,000 assessment"
  disclosure_required: true

agent_guidance:
  for_buyers:
    - "Request reserve study before making offer"
    - "Factor $350/mo increase into affordability"
    - "Budget for $8,000 special assessment"
    - "Negotiate assessment responsibility in contract"

  for_sellers:
    - "Disclose reserve status and planned increases"
    - "Be prepared for price negotiations"
    - "Consider paying assessment to improve marketability"

alert:
  level: HIGH
  include_in: daily_briefing
```

### Example 3: Compliance Deadline Approaching

```yaml
trigger: 60 days until milestone inspection deadline
buildings_affected: 127  # In Homer's coverage area

deadline: "December 31, 2024"
requirement: "Complete Phase 1 Milestone Inspection"

non_compliant_buildings:
  count: 127
  by_county:
    miami_dade: 45
    broward: 38
    palm_beach: 22
    other: 22

transaction_implications:
  after_deadline: |
    Buildings without completed inspections may face:
    - Financing restrictions
    - Local government fines
    - Title insurance issues
    - Buyer reluctance

agent_guidance:
  - "Verify inspection status for any condo listing"
  - "Request proof of compliance before accepting listings"
  - "Disclose deadline to buyers"
  - "Consider compliance status in pricing"

alert:
  level: HIGH
  recipients: all_agents
```

## Condo Due Diligence Checklist

```typescript
const CONDO_DUE_DILIGENCE = {
  documents_to_request: [
    "Milestone inspection report (if applicable)",
    "Structural Integrity Reserve Study",
    "Current reserve balance and funding percentage",
    "Pending or planned special assessments",
    "Past 3 years of meeting minutes",
    "Current year and prior year budget",
    "Most recent financial statements",
    "Insurance certificate (master policy)",
    "HOA rules and regulations",
    "CC&Rs (Declaration of Condominium)",
    "Any pending litigation"
  ],

  questions_for_association: [
    "What is the current reserve funding percentage?",
    "Are there any planned special assessments?",
    "Has the milestone inspection been completed?",
    "Are there any known structural issues?",
    "What is the deferred maintenance backlog?",
    "Have HOA fees increased recently? Plans for increases?",
    "Any pending or threatened litigation?",
    "What is the percentage of owner-occupied units?",
    "Are there any rental restrictions?",
    "What is the delinquency rate?"
  ],

  red_flags: [
    "Milestone inspection not completed (if required)",
    "Reserve funding below 50%",
    "Large special assessments pending",
    "Multiple recent fee increases",
    "Active litigation involving structure",
    "High delinquency rate (>15%)",
    "Deferred maintenance noted in budget",
    "Missing or outdated reserve study",
    "Board meeting minutes mention structural concerns"
  ]
};
```

## Output Schema

```typescript
interface CondoSafetyOutput {
  success: boolean;
  actionTaken: string;
  result: {
    market_status: {
      buildings_tracked: number;
      compliant: number;
      non_compliant: number;
      unknown: number;
    };

    deadline_alerts: {
      milestone_inspections_due: number;
      sirs_due: number;
      reserve_funding_due: number;
    };

    recent_filings: {
      inspections_completed: number;
      inspections_failed: number;
      sirs_filed: number;
    };

    financing_impact: {
      buildings_cash_only: number;
      buildings_limited_financing: number;
    };

    affected_deals: {
      deal_id: string;
      building: string;
      issue: string;
      action: string;
    }[];

    legislative_updates: {
      change: string;
      effective_date: string;
      impact: string;
    }[];

    next_update: string;
  };
  shouldContinue: boolean;
}
```

## Error Handling

| Error | Cause | Response |
|-------|-------|----------|
| `BUILDING_NOT_FOUND` | Building not in database | Add new building, request info |
| `INSPECTION_STATUS_UNKNOWN` | Can't verify inspection | Flag for manual research |
| `RESERVE_DATA_MISSING` | No reserve study available | Note risk, recommend requesting |
| `COUNTY_RECORDS_UNAVAILABLE` | County system down | Use cached data, note date |

## Quality Checklist

- [x] Tracks milestone inspection deadlines
- [x] Monitors reserve study compliance
- [x] Assesses financing implications
- [x] Provides buyer/seller guidance
- [x] Creates due diligence checklists
- [x] Alerts on non-compliant buildings
- [x] Tracks legislative changes
- [x] Matches compliance issues to deals
- [x] Notes special assessment risks
- [x] Includes transaction recommendations

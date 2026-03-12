# Skill: Flood Zone Monitor

**Category:** Knowledge/Florida-Specific
**Priority:** P1
**Approval Required:** No

## Purpose

Monitor FEMA flood zone maps, flood insurance requirements, and zone changes affecting Florida properties. This skill helps agents understand flood risk implications for transactions, insurance requirements, and disclosure obligations.

## Voice Commands

- "What flood zone is this property in?"
- "Does this property require flood insurance?"
- "Are there any flood map changes coming?"
- "Check flood risk for [address]"
- "What's the flood insurance cost for [zone]?"
- "Has this area flooded before?"

## Triggers

### Scheduled
- **Daily:** FEMA map revision notices
- **Weekly:** NFIP rate updates, LOMC filings
- **Monthly:** Flood claim data, zone statistics
- **Annually:** FEMA map update cycle review

### Event-Based
- New FEMA flood map effective
- LOMC (Letter of Map Change) issued
- Major flood event in Florida
- NFIP rate structure change
- Lender flood requirement update

## Monitored Sources

### FEMA/Federal Sources

| Source | URL | Frequency | Focus |
|--------|-----|-----------|-------|
| FEMA Map Service Center | msc.fema.gov | Weekly | Flood maps |
| FEMA LOMC | fema.gov/flood-maps | Weekly | Map changes |
| NFIP | floodsmart.gov | Weekly | Insurance rates |
| FEMA Flood Claims | fema.gov | Monthly | Historical claims |

### Florida Sources

| Source | Focus | Frequency |
|--------|-------|-----------|
| FL Division of Emergency Mgmt | State flood resources | Weekly |
| Water Management Districts | Local flood data | Monthly |
| County Floodplain Managers | Local map changes | Weekly |

### Industry Sources

| Source | Focus | Frequency |
|--------|-------|-----------|
| Flood Insurance Agency | Private flood options | Weekly |
| National Flood Services | Determinations | Daily |
| CoreLogic Flood | Risk analytics | Weekly |

## Flood Zone Schema

```typescript
interface FloodZoneData {
  property: {
    address: string;
    county: string;
    parcel_id?: string;
    coordinates?: { lat: number; lon: number };
  };

  zone_determination: {
    flood_zone: string;          // A, AE, AH, AO, VE, X, etc.
    base_flood_elevation?: number;
    panel_number: string;
    panel_effective_date: string;
    community_number: string;
    community_name: string;
  };

  insurance_requirement: {
    federally_required: boolean;
    lender_required: boolean;
    requirement_reason: string;
  };

  zone_description: {
    risk_level: "high" | "moderate" | "low" | "undetermined";
    description: string;
    flood_frequency: string;
    insurance_details: string;
  };

  historical_data: {
    previous_claims: number;
    last_claim_date?: string;
    repetitive_loss: boolean;
    severe_repetitive_loss: boolean;
  };

  pending_changes: {
    lomc_pending: boolean;
    map_revision_pending: boolean;
    expected_new_zone?: string;
    effective_date?: string;
  };

  insurance_estimate: {
    nfip_annual_range: { low: number; high: number };
    private_available: boolean;
    private_annual_range?: { low: number; high: number };
    factors_affecting_rate: string[];
  };
}
```

## Zone Classifications

```typescript
const FLOOD_ZONES = {
  high_risk: {
    zones: ["A", "AE", "AH", "AO", "AR", "A99", "V", "VE"],
    insurance_required: true,
    description: "Special Flood Hazard Area (SFHA)",
    risk: "High probability of flooding (1% annual chance)",

    details: {
      "A": "No Base Flood Elevation determined",
      "AE": "Base Flood Elevation determined",
      "AH": "Flood depth 1-3 feet (ponding)",
      "AO": "Flood depth 1-3 feet (sheet flow)",
      "AR": "Flood control system restoration needed",
      "A99": "Federal flood control system under construction",
      "V": "Coastal high hazard, no BFE",
      "VE": "Coastal high hazard with BFE and wave action"
    }
  },

  moderate_risk: {
    zones: ["B", "X (shaded)"],
    insurance_required: false,
    description: "Moderate Flood Hazard Area",
    risk: "0.2% annual chance (500-year flood)",
    recommendation: "Flood insurance strongly recommended"
  },

  low_risk: {
    zones: ["C", "X (unshaded)"],
    insurance_required: false,
    description: "Minimal Flood Hazard Area",
    risk: "Lower than 0.2% annual chance",
    recommendation: "Flood insurance available and recommended"
  },

  undetermined: {
    zones: ["D"],
    insurance_required: false,
    description: "Undetermined Risk",
    risk: "Possible but undetermined flood hazards",
    recommendation: "Flood insurance recommended pending study"
  }
};
```

## Execution Flow

```
START
  │
  ├─── 1. Monitor FEMA map changes
  │    │
  │    ├── Check for new Letters of Map Amendment (LOMA)
  │    ├── Check for Letters of Map Revision (LOMR)
  │    ├── Track Preliminary Map updates
  │    └── Note upcoming effective dates
  │
  ├─── 2. Track NFIP changes
  │    │
  │    ├── Rate structure updates (Risk Rating 2.0)
  │    ├── Coverage limit changes
  │    ├── Premium cap changes
  │    └── Grandfathering rule changes
  │
  ├─── 3. Monitor Florida-specific events
  │    │
  │    ├── Post-hurricane remapping
  │    ├── County-level flood studies
  │    ├── Water management district updates
  │    └── Local ordinance changes
  │
  ├─── 4. Property lookup service
  │    │
  │    ├── Accept property address
  │    ├── Query flood zone determination
  │    ├── Check for pending changes
  │    ├── Pull historical claim data
  │    └── Generate insurance estimate
  │
  ├─── 5. Assess transaction impact
  │    │
  │    └── PROMPT:
  │        """
  │        You are a Florida flood risk and insurance expert.
  │
  │        PROPERTY: {{property.address}}
  │        FLOOD ZONE: {{zone}}
  │        INSURANCE REQUIRED: {{required}}
  │        HISTORICAL CLAIMS: {{claims}}
  │
  │        Analyze transaction implications:
  │
  │        1. Insurance Requirements:
  │           - Is flood insurance required?
  │           - NFIP vs. private options
  │           - Estimated annual cost
  │           - Impact on buyer's budget
  │
  │        2. Disclosure Obligations:
  │           - What must be disclosed?
  │           - Form requirements
  │
  │        3. Lending Implications:
  │           - Lender requirements
  │           - Escrow implications
  │           - Closing timing
  │
  │        4. Zone Change Considerations:
  │           - Any pending changes?
  │           - LOMA/LOMR possibilities?
  │           - Appeal options
  │
  │        5. Agent Guidance:
  │           - Talking points for buyers
  │           - Risk context
  │           - Cost mitigation options
  │        """
  │
  ├─── 6. Match to active deals
  │    ├── Check flood zones for pending transactions
  │    ├── Identify insurance requirements
  │    └── Flag potential issues
  │
  └─── 7. Return flood assessment
```

## Insurance Implications

```typescript
interface FloodInsuranceImplications {
  zone: string;

  nfip_coverage: {
    available: boolean;
    building_max: 250000;
    contents_max: 100000;
    waiting_period_days: 30;

    estimated_premium: {
      low: number;
      high: number;
      factors: string[];
    };

    risk_rating_2_0: {
      affects_premium: boolean;
      individual_risk_factors: string[];
    };
  };

  private_flood: {
    available: boolean;
    building_max?: number;
    contents_max?: number;
    premium_comparison: "lower" | "higher" | "comparable";
    benefits?: string[];
    drawbacks?: string[];
  };

  lender_requirements: {
    required: boolean;
    coverage_minimum: "replacement_cost" | "loan_amount";
    escrow_required: boolean;
    proof_deadline: "before_closing";
  };

  elevation_certificate: {
    helpful: boolean;
    reason: string;
    cost_range: { low: 300; high: 600 };
    may_reduce_premium: boolean;
  };
}
```

## Alert Examples

### Example 1: Map Revision Affecting Area

```yaml
trigger: Preliminary Flood Map Update
county: "Brevard County"
effective_date: "2026-06-01"

changes:
  summary: "Coastal zones expanded inland"
  zones_affected:
    expanding:
      - from: "X"
        to: "AE"
        areas: ["Melbourne Beach", "Indian Harbour Beach"]
        properties_affected: ~3500
    contracting:
      - from: "AE"
        to: "X"
        areas: ["West Melbourne highlands"]
        properties_affected: ~800

impact:
  newly_in_sfha:
    count: 3500
    insurance_now_required: true
    estimated_annual_cost: "$1,500-$4,000"

  leaving_sfha:
    count: 800
    insurance_no_longer_required: true
    recommendation: "Keep insurance - still at risk"

transaction_implications:
  for_buyers_in_new_zones:
    - "Flood insurance will be required by lenders"
    - "Budget additional $125-$333/month for insurance"
    - "Obtain elevation certificate for better rates"

  for_sellers_in_new_zones:
    - "Disclosure of zone change may be required"
    - "Price may need adjustment for insurance costs"
    - "Consider obtaining elevation certificate"

appeal_options:
  loma_possible: true
  deadline: "90 days after map effective"
  requirements: "Elevation certificate showing above BFE"

alert:
  level: HIGH
  recipients: agents_in_affected_areas
```

### Example 2: Property Flood Zone Lookup

```yaml
request:
  address: "1234 Bayshore Drive, Tampa, FL 33611"

response:
  zone: "AE"
  base_flood_elevation: 12
  panel: "12057C0235H"
  effective_date: "2021-12-17"

  risk_level: "HIGH"
  insurance_required: true

  historical:
    claims: 0
    repetitive_loss: false

  insurance_estimate:
    nfip:
      range: { low: 1800, high: 3500 }
      factors:
        - "Zone AE with BFE"
        - "Single-family residential"
        - "Pre-FIRM construction"
    private:
      range: { low: 1200, high: 2800 }
      available_carriers: 5

  recommendations:
    - "Obtain elevation certificate (may reduce premium)"
    - "Compare NFIP and private flood quotes"
    - "Factor $150-$290/month into buyer budget"
    - "Verify coverage before closing"

  pending_changes:
    map_revision: false
    lomc: false
```

### Example 3: Post-Hurricane Remapping

```yaml
trigger: FEMA Preliminary Map after Hurricane
hurricane: "Hurricane Milton"
affected_counties: ["Lee", "Charlotte", "Sarasota"]
announced: 2026-02-15

status:
  phase: "Preliminary"
  comment_period_ends: "2026-05-15"
  expected_effective: "2026-12-01"

changes:
  summary: "Significant zone expansions post-Milton"

  highlights:
    - area: "Fort Myers coastal"
      change: "VE zones expanded 500 feet inland"
    - area: "Cape Coral"
      change: "Multiple canals reclassified to AE"
    - area: "Port Charlotte"
      change: "Coastal zones expanded"

transaction_guidance:
  current: "Use current effective maps until new maps adopt"
  disclosure: "Mention pending changes to buyers"
  pricing: "Consider future insurance costs"

agent_action:
  - "Inform buyers of pending changes"
  - "Current insurance quotes may not reflect future costs"
  - "Properties near zone boundaries at higher risk"

alert:
  level: HIGH
  include_in: weekly_digest
```

## Flood Disclosure Requirements

```typescript
const FLORIDA_FLOOD_DISCLOSURE = {
  required_by_law: {
    federal: {
      requirement: "Seller must disclose if property is in SFHA",
      form: "Flood zone disclosure in purchase contract",
      timing: "Before contract execution"
    },

    florida: {
      requirement: "Property in flood zone must be disclosed",
      reference: "Florida Statutes 720.401 (HOA)",
      far_bar_contract: "Paragraph 10(g) flood zone disclosure"
    }
  },

  agent_best_practices: [
    "Always verify flood zone status for listings",
    "Include flood zone in MLS if known",
    "Recommend buyer verify independently",
    "Provide flood zone map resources",
    "Disclose any known flooding history"
  ],

  buyer_rights: [
    "May request elevation certificate from seller",
    "May obtain own flood zone determination",
    "May request LOMA/LOMR information",
    "May negotiate based on flood costs"
  ]
};
```

## Output Schema

```typescript
interface FloodZoneOutput {
  success: boolean;
  actionTaken: string;
  result: {
    // For monitoring
    map_updates: {
      new_effective_maps: number;
      pending_revisions: number;
      lomcs_issued: number;
      counties_affected: string[];
    };

    rate_updates: {
      nfip_changes: string[];
      effective_date?: string;
      average_impact?: string;
    };

    // For property lookup
    property_assessment?: {
      address: string;
      flood_zone: string;
      insurance_required: boolean;
      risk_level: string;
      estimated_premium: { low: number; high: number };
      historical_claims: number;
      pending_changes: boolean;
      recommendations: string[];
    };

    // For deals
    affected_deals: {
      deal_id: string;
      property: string;
      zone: string;
      issue: string;
      action: string;
    }[];

    florida_statistics: {
      nfip_policies_in_force: number;
      claims_paid_ytd: number;
      repetitive_loss_properties: number;
    };

    next_update: string;
  };
  shouldContinue: boolean;
}
```

## Error Handling

| Error | Cause | Response |
|-------|-------|----------|
| `ZONE_LOOKUP_FAILED` | FEMA service unavailable | Use cached data, note date |
| `ADDRESS_NOT_FOUND` | Can't geocode address | Request better address |
| `MAP_DATA_OUTDATED` | Using old map panel | Note pending update |
| `INSURANCE_ESTIMATE_UNAVAILABLE` | Can't calculate estimate | Provide range guidance |

## Quality Checklist

- [x] Monitors FEMA map updates
- [x] Tracks NFIP rate changes
- [x] Provides property-specific lookups
- [x] Calculates insurance estimates
- [x] Identifies pending zone changes
- [x] Notes historical claim data
- [x] Explains disclosure requirements
- [x] Provides agent guidance
- [x] Alerts on significant changes
- [x] Covers all Florida counties

# Skill: Hurricane Watch

**Category:** Knowledge/Florida-Specific
**Priority:** P0 (Critical during hurricane season)
**Approval Required:** No

## Purpose

Monitor Atlantic hurricane activity and Florida-specific tropical weather threats during hurricane season (June 1 - November 30). This skill provides real-time tracking, transaction impact assessment, and proactive guidance for agents managing deals during active weather events.

## Voice Commands

- "Are there any hurricanes coming?"
- "What's the status of [storm name]?"
- "How will this storm affect my deals?"
- "Is it safe to schedule closings this week?"
- "When should we reschedule the inspection?"
- "Hurricane update please"
- "Tropical weather check"

## Triggers

### Scheduled (During Hurricane Season)
- **Every 3 hours:** NHC tropical outlook
- **Hourly:** When any system threatens Florida
- **Every 30 minutes:** When watch/warning issued for Florida
- **Continuous:** During active hurricane landfall

### Event-Based
- Tropical depression forms
- System enters Gulf or Atlantic near Florida
- Watch/warning issued for any Florida county
- Hurricane makes landfall
- Post-storm all-clear

## Monitored Sources

### Primary Weather Sources

| Source | URL | Frequency | Data |
|--------|-----|-----------|------|
| National Hurricane Center | nhc.noaa.gov | Continuous | Official forecasts |
| NWS Miami | weather.gov/mfl | Continuous | South FL alerts |
| NWS Tampa Bay | weather.gov/tbw | Continuous | Tampa Bay alerts |
| NWS Melbourne | weather.gov/mlb | Continuous | Central FL alerts |
| NWS Jacksonville | weather.gov/jax | Continuous | North FL alerts |
| NWS Tallahassee | weather.gov/tae | Continuous | Panhandle alerts |

### Secondary Sources

| Source | Focus | Frequency |
|--------|-------|-----------|
| FL Division of Emergency Mgmt | floridadisaster.org | Event-based |
| Local emergency management | County-specific | Event-based |
| NWS Storm Prediction Center | spc.noaa.gov | Continuous |

## Storm Tracking Schema

```typescript
interface TropicalSystem {
  id: string;
  name: string;
  type: "disturbance" | "depression" | "tropical_storm" | "hurricane";
  category?: 1 | 2 | 3 | 4 | 5;  // Saffir-Simpson scale

  current_position: {
    latitude: number;
    longitude: number;
    timestamp: string;
  };

  intensity: {
    max_winds_mph: number;
    min_pressure_mb: number;
    movement_speed_mph: number;
    movement_direction: string;
  };

  florida_threat: {
    level: "none" | "low" | "moderate" | "high" | "extreme";
    earliest_impacts: string;
    affected_counties: string[];
    confidence: number;
  };

  forecast_track: ForecastPoint[];

  watches_warnings: WatchWarning[];

  nhc_advisory: {
    number: number;
    timestamp: string;
    next_advisory: string;
  };
}

interface ForecastPoint {
  hour: number;        // Hours from now
  position: { lat: number; lon: number };
  intensity: { winds: number; category?: number };
  uncertainty_radius_miles: number;
}

interface WatchWarning {
  type: "watch" | "warning";
  hazard: "hurricane" | "tropical_storm" | "storm_surge" | "tornado";
  areas: string[];     // Counties or coastal segments
  issued: string;
  expires?: string;
}
```

## Transaction Impact Schema

```typescript
interface HurricaneTransactionImpact {
  storm_id: string;
  storm_name: string;

  current_threat_level: "none" | "watch" | "warning" | "active" | "recovery";

  affected_counties: string[];

  transaction_guidance: {
    closings: {
      recommendation: "proceed" | "monitor" | "delay" | "reschedule";
      reason: string;
      safe_window?: { before: string; after: string };
    };

    inspections: {
      recommendation: string;
      reason: string;
    };

    appraisals: {
      recommendation: string;
      reason: string;
    };

    showings: {
      recommendation: string;
      reason: string;
    };
  };

  insurance_implications: {
    binding_suspended: boolean;
    suspension_started?: string;
    suspension_ends?: string;
    existing_policies: string;
  };

  title_company_status: {
    operating: boolean;
    closures?: { company: string; status: string }[];
    wire_availability: boolean;
  };

  utility_status: {
    power_outages: boolean;
    affected_areas?: string[];
    restoration_estimate?: string;
  };

  timeline: {
    conditions_begin: string;
    worst_conditions: string;
    conditions_end: string;
    normal_operations_resume: string;
  };
}
```

## Execution Flow

```
START
  │
  ├─── 1. Check NHC tropical outlook
  │    │
  │    ├── Parse Atlantic basin systems
  │    ├── Check Gulf of Mexico systems
  │    ├── Identify any Florida threats
  │    │
  │    └── IF no active systems:
  │        └── Return routine status, schedule next check
  │
  ├─── 2. FOR EACH system with Florida threat:
  │    │
  │    ├── 2a. Get latest advisory
  │    │   ├── Current position
  │    │   ├── Intensity
  │    │   ├── Track forecast
  │    │   └── Watches/warnings
  │    │
  │    ├── 2b. Assess Florida impact
  │    │   ├── Calculate closest approach
  │    │   ├── Identify affected counties
  │    │   ├── Estimate impact timing
  │    │   └── Determine threat level
  │    │
  │    └── 2c. Generate impact assessment
  │        """
  │        You are a Florida real estate hurricane impact analyst.
  │
  │        STORM: {{storm.name}} ({{storm.type}} {{storm.category}})
  │        CURRENT POSITION: {{storm.position}}
  │        FORECAST: {{storm.forecast_track}}
  │        WATCHES/WARNINGS: {{storm.watches_warnings}}
  │
  │        AFFECTED FLORIDA COUNTIES:
  │        {{affected_counties}}
  │
  │        Analyze transaction impacts:
  │
  │        1. CLOSINGS:
  │           - Safe to proceed when?
  │           - When to reschedule to?
  │           - Title company operating hours
  │           - Wire transfer availability
  │
  │        2. INSPECTIONS:
  │           - Safe window for inspections
  │           - Post-storm re-inspection needed?
  │
  │        3. INSURANCE:
  │           - When will binding be suspended?
  │           - Impact on pending policies
  │
  │        4. TIMELINE:
  │           - When do conditions deteriorate?
  │           - When is all-clear expected?
  │           - When can normal business resume?
  │
  │        Be conservative with safety recommendations.
  │        """
  │
  ├─── 3. Match to active deals
  │    │
  │    ├── Query deals in affected counties
  │    │
  │    ├── FOR EACH affected deal:
  │    │   ├── Check upcoming deadlines
  │    │   ├── Check scheduled activities
  │    │   ├── Assess specific impact
  │    │   └── Generate deal-specific guidance
  │    │
  │    └── Create prioritized alert list
  │
  ├─── 4. Determine alert level
  │    │
  │    ├── LEVEL 4 - EMERGENCY (Active landfall):
  │    │   ├── Push + SMS + Email + Phone
  │    │   ├── All agents in affected area
  │    │   └── Real-time updates
  │    │
  │    ├── LEVEL 3 - WARNING (Warning issued):
  │    │   ├── Push + Email
  │    │   ├── Agents with affected deals
  │    │   └── Updates every 3 hours
  │    │
  │    ├── LEVEL 2 - WATCH (Watch issued):
  │    │   ├── Push + Email
  │    │   ├── Agents with affected deals
  │    │   └── Updates every 6 hours
  │    │
  │    └── LEVEL 1 - MONITOR (System approaching):
  │        ├── Email
  │        └── Daily updates
  │
  ├─── 5. Send notifications
  │    ├── Agent alerts
  │    ├── Deal-specific guidance
  │    └── Update Homer's context
  │
  └─── 6. Return hurricane status
       └── Complete threat assessment
```

## Alert Levels

### Level 4: Emergency (Active Impact)

```markdown
## Subject: EMERGENCY - {{storm.name}} IMPACTING {{area}}

Hurricane {{storm.name}} is currently impacting {{area}}.

### IMMEDIATE ACTIONS REQUIRED

FOR YOUR SAFETY:
- Shelter in place until all-clear issued
- Do not travel for showings or closings
- All real estate activities suspended

YOUR AFFECTED DEALS ({{count}}):
{{#each affected_deals}}
- **{{property_address}}**
  - Scheduled: {{scheduled_activity}} on {{date}}
  - Action: {{required_action}}
{{/each}}

### STATUS
- Title Companies: CLOSED
- Wire Transfers: SUSPENDED
- Insurance Binding: SUSPENDED
- MLS: Limited access

### NEXT UPDATE
Updates every 30 minutes during active conditions.

Homer will notify you when all-clear is issued.

[View Storm Tracker] [Emergency Contacts]
```

### Level 3: Warning Issued

```markdown
## Subject: HURRICANE WARNING - {{storm.name}} - Action Required

A Hurricane Warning is in effect for {{area}}.
{{storm.name}} expected to impact the area {{timing}}.

### YOUR DEALS AFFECTED

{{#each affected_deals}}
**{{property_address}}** ({{stage}})
{{#if closing_scheduled}}
- Closing: {{closing_date}} - RESCHEDULE to {{suggested_date}}
{{/if}}
{{#if inspection_scheduled}}
- Inspection: {{inspection_date}} - RESCHEDULE to {{suggested_date}}
{{/if}}
{{/each}}

### TRANSACTION GUIDANCE

**Closings:**
- Reschedule any closings {{closing_window}}
- Title companies closing {{title_closure_time}}
- Wire cutoff: {{wire_cutoff}}

**Inspections:**
- Cancel all inspections until {{inspection_resume}}
- Post-storm re-inspection recommended

**Insurance:**
- New policy binding SUSPENDED as of {{binding_suspended}}
- Existing policies: Document property condition NOW

### TIMELINE
- Conditions deteriorate: {{deteriorate_time}}
- Worst conditions: {{worst_time}}
- All-clear expected: {{all_clear}}

[Reschedule Closings] [Contact All Parties] [Storm Tracker]
```

### Level 2: Watch Issued

```markdown
## Subject: TROPICAL STORM WATCH - {{storm.name}} - Monitor Situation

A Tropical Storm Watch is in effect for {{area}}.
{{storm.name}} could impact the area {{timing}}.

### POTENTIAL IMPACT

This system could affect {{deals_count}} of your active deals.

**Recommended Actions:**
- Monitor storm updates
- Avoid scheduling new activities {{timeframe}}
- Confirm with parties on existing appointments
- Prepare client communications

### DEALS TO MONITOR

{{#each deals}}
- {{property_address}} ({{county}})
  {{#if has_deadline}}
  - Deadline: {{deadline}} - {{deadline_status}}
  {{/if}}
{{/each}}

### NEXT STEPS

Homer will alert you if the Watch upgrades to a Warning.

Next update: {{next_update_time}}

[Storm Tracker] [View All Deals]
```

## Insurance Binding Rules

```typescript
interface InsuranceBindingRules {
  // Standard rules for Florida
  hurricane_watch: {
    binding_status: "review_required",
    new_policies: "Subject to underwriter approval",
    renewals: "May proceed with caution"
  };

  hurricane_warning: {
    binding_status: "suspended",
    new_policies: "NO new policies bound",
    renewals: "Suspended",
    effective_radius: "All coastal counties in warning zone"
  };

  tropical_storm_warning: {
    binding_status: "limited",
    new_policies: "Case-by-case",
    renewals: "Generally allowed"
  };

  post_storm: {
    binding_resumes: "24-48 hours after all-clear",
    inspection_required: "Before binding new policies",
    claims_impact: "Properties with claims may face issues"
  };
}
```

## Post-Storm Protocol

```typescript
interface PostStormProtocol {
  phases: {
    immediate: {
      duration: "0-24 hours after all-clear";
      actions: [
        "Assess property safety",
        "Document any damage",
        "Contact insurance if needed",
        "Verify utility status"
      ];
      transactions: "Still suspended";
    };

    assessment: {
      duration: "24-72 hours post-storm";
      actions: [
        "Property inspections resume (with caution)",
        "Document property conditions",
        "Begin rescheduling activities"
      ];
      transactions: "Case-by-case";
    };

    recovery: {
      duration: "72+ hours post-storm";
      actions: [
        "Resume normal operations",
        "Complete re-inspections for pending deals",
        "Verify insurance status",
        "Finalize rescheduled closings"
      ];
      transactions: "Resume with documentation";
    };
  };

  re_inspection_requirements: {
    when_required: "Any property in affected area with pending transaction";
    scope: "Exterior and accessible areas";
    documentation: "Photos, written report";
    responsible_party: "Buyer's inspector (buyer expense)";
  };

  contract_implications: {
    force_majeure: "May extend deadlines automatically";
    inspection_period: "Typically extended by disruption period";
    closing_date: "Negotiate extension if needed";
    damage_discovered: "Refer to contract damage provisions";
  };
}
```

## Output Schema

```typescript
interface HurricaneWatchOutput {
  success: boolean;
  actionTaken: string;
  result: {
    season_status: "active" | "inactive";
    current_date: string;

    active_systems: TropicalSystem[];

    florida_threat: {
      level: "none" | "low" | "moderate" | "high" | "extreme";
      systems_threatening: string[];
      counties_at_risk: string[];
      earliest_impact?: string;
    };

    transaction_status: {
      normal_operations: boolean;
      closings: "proceed" | "caution" | "delay" | "suspended";
      inspections: "proceed" | "caution" | "delay" | "suspended";
      insurance_binding: "normal" | "limited" | "suspended";
    };

    affected_deals: {
      count: number;
      deals: {
        deal_id: string;
        property: string;
        county: string;
        impact: string;
        action_required: string;
      }[];
    };

    alerts_sent: number;

    next_update: string;
    next_nhc_advisory: string;
  };
  shouldContinue: boolean;
}
```

## Seasonal Considerations

```typescript
const HURRICANE_SEASON = {
  official: { start: "June 1", end: "November 30" },
  peak: { start: "August 15", end: "October 15" },

  pre_season: {
    actions: [
      "Remind agents of hurricane procedures",
      "Verify emergency contact info",
      "Test alert systems"
    ]
  },

  during_season: {
    monitoring: "Active NHC monitoring",
    briefings: "Weekly tropical outlook",
    readiness: "Transaction contingency plans"
  },

  post_season: {
    actions: [
      "Review season impact",
      "Update procedures if needed",
      "Archive storm data"
    ]
  }
};
```

## Error Handling

| Error | Cause | Response |
|-------|-------|----------|
| `NHC_UNAVAILABLE` | NHC website down | Use cached data, alert admin |
| `POSITION_ERROR` | Can't parse storm position | Use last known, flag issue |
| `COUNTY_MATCH_FAILED` | Can't match counties to alert | Use broad Florida alert |
| `DEAL_LOOKUP_FAILED` | Can't query affected deals | Alert all agents in region |

## Quality Checklist

- [x] Monitors all NHC tropical products
- [x] Tracks Florida-specific impacts
- [x] Provides transaction-specific guidance
- [x] Matches storms to active deals
- [x] Sends appropriate alert levels
- [x] Includes insurance binding status
- [x] Provides timeline estimates
- [x] Handles post-storm protocol
- [x] Updates frequently during active threats
- [x] Covers entire Florida coast

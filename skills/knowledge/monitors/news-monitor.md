# Skill: News Monitor

**Category:** Knowledge/Monitor
**Priority:** P2
**Approval Required:** No

## Purpose

Monitor breaking news and events that affect Florida real estate transactions, including hurricanes and weather events, economic announcements, local developments, and major news that agents need to know about to serve clients effectively and adjust transaction strategies.

## Voice Commands

- "Any news affecting real estate today?"
- "What's happening in [area/city]?"
- "Are there any storms coming?"
- "Check for breaking news"
- "What should I know about today?"
- "Any news affecting my deals?"

## Triggers

### Scheduled
- **Continuous:** Weather alerts (NWS feeds)
- **Hourly:** Breaking news feeds
- **Daily:** Economic news roundup
- **Weekly:** Local development updates

### Event-Based
- Hurricane watch/warning issued
- Major economic announcement
- Local disaster declaration
- Significant development news

## Monitored Sources

### Weather & Hurricanes

| Source | URL/Feed | Frequency | Coverage |
|--------|----------|-----------|----------|
| NWS Miami | weather.gov/mfl | Continuous | South FL |
| NWS Tampa | weather.gov/tbw | Continuous | Tampa Bay |
| NWS Melbourne | weather.gov/mlb | Continuous | Central FL |
| NWS Jacksonville | weather.gov/jax | Continuous | North FL |
| National Hurricane Center | nhc.noaa.gov | Continuous | Atlantic hurricanes |
| FL Division of Emergency Mgmt | floridadisaster.org | Event-based | State alerts |

### Economic News

| Source | URL | Frequency | Focus |
|--------|-----|-----------|-------|
| Bureau of Labor Statistics | bls.gov | Monthly | Employment, CPI |
| Federal Reserve | federalreserve.gov | Event-based | Rate decisions |
| Florida DEO | floridajobs.org | Monthly | FL employment |
| Reuters Business | reuters.com | Continuous | Economic news |

### Local News

| Source | Coverage | Frequency |
|--------|----------|-----------|
| Miami Herald | South FL | Daily |
| Tampa Bay Times | Tampa Bay | Daily |
| Orlando Sentinel | Central FL | Daily |
| Jacksonville Times-Union | North FL | Daily |
| South Florida Business Journal | South FL business | Weekly |
| Tampa Bay Business Journal | Tampa Bay business | Weekly |

### Development News

| Source | Focus | Frequency |
|--------|-------|-----------|
| The Real Deal FL | Development news | Daily |
| GrowthSpotter | Central FL development | Daily |
| RE Business Online | Commercial development | Weekly |
| Local Planning Depts | Zoning, permits | Weekly |

## News Categories

### WEATHER EVENTS

```typescript
interface WeatherEvent {
  event_type: "hurricane" | "tropical_storm" | "flood" | "tornado" | "severe_weather";
  severity: "watch" | "warning" | "emergency";
  affected_areas: string[];  // Counties/cities
  timing: {
    start: string;
    peak: string;
    end: string;
  };
  impacts: {
    transaction_delays: boolean;
    inspection_delays: boolean;
    closing_delays: boolean;
    insurance_implications: boolean;
    evacuation_orders: boolean;
  };
  recommended_actions: string[];
}
```

### ECONOMIC NEWS

```typescript
interface EconomicNews {
  category: "employment" | "inflation" | "fed_policy" | "gdp" | "housing_data";
  headline: string;
  summary: string;
  data_points: {
    metric: string;
    value: number;
    change: number;
    expectation: number;
  }[];
  market_reaction: string;
  real_estate_impact: string;
  agent_talking_points: string[];
}
```

### LOCAL DEVELOPMENTS

```typescript
interface LocalDevelopment {
  location: {
    city: string;
    county: string;
    neighborhood?: string;
  };
  development_type: "residential" | "commercial" | "mixed_use" | "infrastructure";
  headline: string;
  details: string;
  impact_on_area: {
    property_values: "positive" | "negative" | "neutral";
    traffic: "increase" | "decrease" | "neutral";
    amenities: string[];
    timeline: string;
  };
  affected_properties: {
    radius_miles: number;
    estimated_homes: number;
  };
}
```

### BREAKING NEWS

```typescript
interface BreakingNews {
  category: "disaster" | "economic" | "political" | "crime" | "infrastructure";
  urgency: "critical" | "high" | "medium" | "low";
  headline: string;
  summary: string;
  location?: {
    city?: string;
    county?: string;
    statewide?: boolean;
  };
  real_estate_relevance: string;
  transaction_impact?: string;
  duration_estimate?: string;
}
```

## Execution Flow

```
START
  │
  ├─── 1. Check priority sources
  │    │
  │    ├── FIRST: Weather alerts (safety critical)
  │    │   ├── Check NWS feeds
  │    │   ├── Check NHC for hurricane activity
  │    │   └── Check FL emergency management
  │    │
  │    ├── SECOND: Breaking news feeds
  │    │   ├── Major news RSS
  │    │   └── Florida-specific news
  │    │
  │    └── THIRD: Routine sources
  │        ├── Economic calendars
  │        └── Development news
  │
  ├─── 2. Filter for real estate relevance
  │    │
  │    ├── Keywords filter:
  │    │   ├── Direct: "real estate", "housing", "mortgage"
  │    │   ├── Economic: "interest rate", "fed", "inflation"
  │    │   ├── Weather: "hurricane", "flood", "evacuation"
  │    │   ├── Local: "development", "zoning", "construction"
  │    │   └── Disaster: "disaster", "emergency", "damage"
  │    │
  │    └── Location filter: Florida focus
  │
  ├─── 3. Analyze relevance with AI
  │    │
  │    └── PROMPT:
  │        """
  │        You are a Florida real estate news analyst.
  │
  │        NEWS ITEMS:
  │        {{news_items}}
  │
  │        For each item, determine:
  │
  │        1. Real Estate Relevance (1-10):
  │           10 = Directly affects transactions
  │           7-9 = Significant market impact
  │           4-6 = Worth knowing
  │           1-3 = Tangentially relevant
  │
  │        2. Urgency:
  │           CRITICAL = Affects active deals TODAY
  │           HIGH = Affects deals this week
  │           MEDIUM = Important context
  │           LOW = General awareness
  │
  │        3. Affected areas: Which FL regions/markets
  │
  │        4. Transaction impact:
  │           - Delays expected?
  │           - Pricing implications?
  │           - Buyer/seller behavior change?
  │
  │        5. Agent action:
  │           - Contact clients?
  │           - Delay showings?
  │           - Adjust strategy?
  │
  │        6. Talking points for client communication
  │
  │        Return only items with relevance >= 4.
  │        """
  │
  ├─── 4. Prioritize and categorize
  │    │
  │    ├── CRITICAL (immediate alert):
  │    │   ├── Hurricane warning for FL
  │    │   ├── Evacuation orders
  │    │   ├── Major disaster declaration
  │    │   └── Fed rate decision (significant)
  │    │
  │    ├── HIGH (same-day notification):
  │    │   ├── Tropical storm affecting FL
  │    │   ├── Major employment report
  │    │   ├── Significant rate movement
  │    │   └── Major local development
  │    │
  │    ├── MEDIUM (daily briefing):
  │    │   ├── Weather advisories
  │    │   ├── Economic data releases
  │    │   └── Development announcements
  │    │
  │    └── LOW (weekly roundup):
  │        ├── General market news
  │        └── Future developments
  │
  ├─── 5. Match to active deals
  │    │
  │    ├── FOR EACH relevant news item:
  │    │   ├── Get deals in affected area
  │    │   ├── Identify potential impacts
  │    │   └── Flag for agent attention
  │    │
  │    └── Create deal-specific alerts
  │
  ├─── 6. Update Homer's context
  │    ├── Add to current events knowledge
  │    ├── Update area-specific context
  │    └── Refresh talking points
  │
  └─── 7. Return news report
       └── Prioritized news with recommendations
```

## Alert Examples

### Example 1: Hurricane Alert

```yaml
source: National Hurricane Center
detected: 2026-08-15 10:00

event:
  type: hurricane
  name: "Hurricane Elena"
  category: 2 (expected Cat 3 at landfall)
  current_position: "200 miles SE of Miami"
  track: "Expected landfall near West Palm Beach Friday evening"
  affected_areas:
    - Palm Beach County (direct)
    - Broward County (direct)
    - Miami-Dade County (tropical storm conditions)
    - Martin County (direct)

timing:
  watch_issued: "2026-08-15 10:00"
  warning_expected: "2026-08-15 16:00"
  conditions_begin: "2026-08-16 06:00"
  landfall: "2026-08-16 18:00"
  conditions_end: "2026-08-17 12:00"

impact:
  severity: CRITICAL
  transaction_impacts:
    - "All closings in affected counties should be rescheduled"
    - "Inspections cancelled through weekend"
    - "Title companies closing Thursday noon"
    - "Banks may suspend wire transfers"
  insurance_implications:
    - "New policies binding suspended at warning"
    - "Existing policies: document pre-storm condition"

recommended_actions:
  immediate:
    - "Contact all parties in affected area deals"
    - "Reschedule closings scheduled Thu-Mon"
    - "Cancel all showings starting Thursday"
    - "Advise clients on property protection"
  post_storm:
    - "Re-inspect properties before closing"
    - "Check for insurance claims"
    - "Verify utility restoration"

alert:
  level: CRITICAL
  recipients: all_agents_in_affected_areas
  channels: push, sms, email, phone
```

### Example 2: Fed Rate Decision

```yaml
source: Federal Reserve
detected: 2026-01-29 14:00

event:
  type: fed_rate_decision
  decision: "Cut 25 basis points"
  new_rate: "4.00-4.25%"
  previous_rate: "4.25-4.50%"
  market_expectation: "25bp cut (80% probability)"
  surprise_factor: "As expected"

market_reaction:
  mortgage_rates: "Expected to drop 0.125-0.25% over next week"
  stock_market: "Positive reaction"

real_estate_impact:
  summary: "Modest positive for buyers"
  buyer_impact: "Improved affordability, ~$50/mo savings per $100k"
  seller_impact: "May bring buyers off sidelines"
  market_activity: "Expect uptick in showings"

talking_points:
  - "Fed cut rates as expected, mortgage rates should follow"
  - "Good time to revisit pre-approval if rate was a barrier"
  - "Market may get more competitive as buyers return"

alert:
  level: HIGH
  include_in: daily_briefing
```

### Example 3: Local Development News

```yaml
source: Tampa Bay Business Journal
detected: 2026-01-15

development:
  name: "Tampa Innovation District"
  location:
    city: "Tampa"
    neighborhood: "Ybor City"
    address: "1500 E 7th Ave corridor"
  type: "Mixed-use development"
  size: "2.5 million sq ft"
  investment: "$1.2 billion"
  timeline: "Groundbreaking Q2 2026, Phase 1 complete 2028"
  includes:
    - "500,000 sq ft Class A office"
    - "1,200 residential units"
    - "150,000 sq ft retail"
    - "2 hotels (400 rooms total)"
    - "25-acre park"

impact:
  property_values:
    direction: "positive"
    estimate: "+5-15% for properties within 1 mile"
  affected_neighborhoods:
    - "Ybor City"
    - "Channel District"
    - "Tampa Heights"
  employment: "Estimated 8,000 new jobs"

agent_implications:
  buyers: "Consider proximity as selling point"
  sellers: "May want to hold for value increase"
  talking_points:
    - "Major development bringing jobs and amenities"
    - "Early buyers may see appreciation"
    - "Construction disruption 2026-2028"

alert:
  level: MEDIUM
  include_in: weekly_digest
```

## Output Schema

```typescript
interface NewsMonitorOutput {
  success: boolean;
  actionTaken: string;
  result: {
    sources_checked: number;
    items_found: number;
    items_relevant: number;

    critical_alerts: NewsItem[];
    high_priority: NewsItem[];
    medium_priority: NewsItem[];
    low_priority: NewsItem[];

    weather: {
      active_watches: number;
      active_warnings: number;
      tropical_activity: boolean;
      current_threats: WeatherThreat[];
    };

    economic: {
      today_releases: EconomicEvent[];
      upcoming_releases: EconomicEvent[];
    };

    deals_affected: {
      deal_id: string;
      property: string;
      news_item: string;
      impact: string;
    }[];

    next_check: string;
  };
  shouldContinue: boolean;
}

interface NewsItem {
  id: string;
  source: string;
  category: string;
  headline: string;
  summary: string;
  relevance_score: number;
  urgency: string;
  affected_areas: string[];
  transaction_impact?: string;
  agent_action?: string;
  talking_points: string[];
  timestamp: string;
}
```

## Error Handling

| Error | Cause | Response |
|-------|-------|----------|
| `WEATHER_SOURCE_DOWN` | NWS feed unavailable | Use backup source, alert admin |
| `NEWS_OVERLOAD` | Too many items to process | Prioritize by keyword, batch |
| `LOCATION_PARSE_FAILED` | Can't determine affected area | Include with "Florida" tag |
| `RELEVANCE_UNCERTAIN` | AI can't determine relevance | Include with low priority |

## Quality Checklist

- [x] Prioritizes weather/safety alerts
- [x] Monitors all major Florida regions
- [x] Filters for real estate relevance
- [x] Provides transaction-specific impacts
- [x] Includes agent action items
- [x] Generates client talking points
- [x] Matches news to active deals
- [x] Maintains appropriate urgency levels
- [x] Handles breaking news quickly
- [x] Tracks ongoing events (hurricanes)

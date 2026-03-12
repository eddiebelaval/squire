# Skill: Market Monitor

**Category:** Knowledge/Monitor
**Priority:** P1
**Approval Required:** No

## Purpose

Continuously monitor Florida real estate market conditions including interest rates, inventory levels, pricing trends, and days on market. This skill keeps Homer Pro informed of market dynamics that affect buyer/seller strategies, pricing recommendations, and transaction timelines.

## Voice Commands

- "What's the current mortgage rate?"
- "How's the market in [city/area]?"
- "Check market conditions for [zip code]"
- "Are prices going up or down?"
- "What's the inventory like right now?"
- "Give me a market update"

## Triggers

### Scheduled
- **Hourly:** Interest rate feeds (Freddie Mac, Bankrate)
- **Daily:** MLS inventory snapshots, new listings
- **Weekly:** Price trend analysis, DOM calculations
- **Monthly:** Comprehensive market report

### Event-Based
- Fed rate announcement
- Major economic news
- Agent requests market update
- New listing in monitored area

## Monitored Sources

### Interest Rates (Primary)

| Source | URL/Feed | Frequency | Data Points |
|--------|----------|-----------|-------------|
| Freddie Mac PMMS | freddiemac.com/pmms | Weekly | 30yr, 15yr fixed |
| Mortgage News Daily | mortgagenewsdaily.com | Daily | Live rate movements |
| Bankrate | bankrate.com | Daily | Rate comparisons |
| Federal Reserve | federalreserve.gov | Event-based | Fed funds rate |

### Inventory & Pricing (MLS)

| Source | Access | Frequency | Coverage |
|--------|--------|-----------|----------|
| Stellar MLS | API | Daily | Central/East FL |
| Miami MLS | API | Daily | South FL |
| BeachMLS | API | Daily | Gulf Coast |
| Realtor.com | Web | Daily | National aggregation |
| Redfin Data Center | API | Weekly | Market metrics |

### Economic Indicators

| Source | URL | Frequency | Indicators |
|--------|-----|-----------|------------|
| Bureau of Labor Statistics | bls.gov | Monthly | Employment, CPI |
| Census Bureau | census.gov | Monthly | Housing starts |
| NAR Research | nar.realtor/research | Monthly | Existing home sales |
| Florida Realtors | floridarealtors.org | Monthly | FL-specific data |

## Data Categories

### INTEREST RATES

```typescript
interface InterestRateData {
  date: string;
  rates: {
    thirty_year_fixed: number;
    fifteen_year_fixed: number;
    five_one_arm: number;
    fha_thirty_year: number;
    va_thirty_year: number;
    jumbo_thirty_year: number;
  };
  changes: {
    daily: number;
    weekly: number;
    monthly: number;
    yearly: number;
  };
  forecast: {
    direction: "up" | "down" | "stable";
    confidence: number;
    next_fed_meeting: string;
  };
}
```

### INVENTORY

```typescript
interface InventoryData {
  date: string;
  area: {
    market: string;       // "Orlando", "Miami", etc.
    county?: string;
    zip?: string;
  };
  metrics: {
    active_listings: number;
    new_listings_7d: number;
    pending_sales: number;
    sold_last_30d: number;
    months_of_supply: number;
  };
  changes: {
    wow: number;          // Week over week
    mom: number;          // Month over month
    yoy: number;          // Year over year
  };
  market_type: "seller" | "balanced" | "buyer";
}
```

### PRICING

```typescript
interface PricingData {
  date: string;
  area: {
    market: string;
    county?: string;
    zip?: string;
  };
  metrics: {
    median_price: number;
    average_price: number;
    price_per_sqft: number;
    list_to_sale_ratio: number;
  };
  changes: {
    mom: number;
    yoy: number;
  };
  price_bands: {
    under_300k: { count: number; pct_change: number };
    range_300k_500k: { count: number; pct_change: number };
    range_500k_750k: { count: number; pct_change: number };
    range_750k_1m: { count: number; pct_change: number };
    over_1m: { count: number; pct_change: number };
  };
}
```

### DAYS ON MARKET

```typescript
interface DOMData {
  date: string;
  area: {
    market: string;
    county?: string;
    zip?: string;
  };
  metrics: {
    median_dom: number;
    average_dom: number;
    dom_under_7: number;      // % selling in first week
    dom_over_90: number;      // % on market 90+ days
  };
  changes: {
    mom: number;
    yoy: number;
  };
  by_price_band: {
    under_300k: number;
    range_300k_500k: number;
    range_500k_750k: number;
    range_750k_1m: number;
    over_1m: number;
  };
}
```

## Execution Flow

```
START
  │
  ├─── 1. Check monitoring schedule
  │    ├── Identify sources due for check
  │    ├── Load last fetch timestamps
  │    └── Prioritize by schedule urgency
  │
  ├─── 2. FOR EACH data source:
  │    │
  │    ├── 2a. Fetch current data
  │    │   ├── Use appropriate method (API/web/feed)
  │    │   ├── Handle authentication
  │    │   └── Parse response
  │    │
  │    ├── 2b. Validate data quality
  │    │   ├── Check completeness
  │    │   ├── Verify reasonable ranges
  │    │   └── Flag anomalies
  │    │
  │    ├── 2c. Compare to previous data
  │    │   ├── Calculate changes
  │    │   ├── Identify significant movements
  │    │   └── Detect trend changes
  │    │
  │    └── 2d. Store data point
  │        ├── Add to time series
  │        ├── Update current values
  │        └── Maintain history
  │
  ├─── 3. Analyze market conditions
  │    │
  │    └── PROMPT (for significant changes):
  │        """
  │        You are a Florida real estate market analyst.
  │
  │        CURRENT MARKET DATA:
  │        {{current_data}}
  │
  │        PREVIOUS PERIOD DATA:
  │        {{previous_data}}
  │
  │        CHANGES DETECTED:
  │        {{changes}}
  │
  │        Analyze these market changes and determine:
  │
  │        1. Significance level: MAJOR | MODERATE | MINOR
  │        2. Market implications for:
  │           - Buyers (purchasing power, urgency)
  │           - Sellers (pricing strategy, timing)
  │           - Agents (advice to give clients)
  │        3. Affected transaction types:
  │           - First-time buyers
  │           - Move-up buyers
  │           - Investors
  │           - Luxury market
  │        4. Recommended actions for active deals
  │        5. Talking points for client communications
  │
  │        Focus on Florida-specific implications.
  │        """
  │
  ├─── 4. Determine alert level
  │    │
  │    ├── MAJOR (alert immediately):
  │    │   ├── Rate change > 0.25% in a day
  │    │   ├── Inventory shift > 15% in a week
  │    │   ├── Fed rate decision day
  │    │   └── Market type change (seller→balanced)
  │    │
  │    ├── MODERATE (daily briefing):
  │    │   ├── Rate change > 0.125% in a day
  │    │   ├── Inventory shift > 5% in a week
  │    │   ├── Price trend acceleration
  │    │   └── DOM significant change
  │    │
  │    └── MINOR (weekly summary):
  │        └── Routine fluctuations
  │
  ├─── 5. Update Homer's market knowledge
  │    ├── Update current market snapshot
  │    ├── Refresh talking points
  │    └── Update deal recommendations
  │
  └─── 6. Return market report
```

## Alert Examples

### Example 1: Significant Rate Movement

```yaml
trigger: Rate change > 0.25% in single day
detected: 2026-01-15 14:30

data:
  previous_30yr: 6.875%
  current_30yr: 7.125%
  change: +0.25%
  cause: "Strong jobs report exceeded expectations"

analysis:
  significance: MAJOR
  buyer_impact: |
    - Monthly payment increase ~$90 per $100k borrowed
    - Buyers at qualification edge may need to adjust
    - May cool demand slightly
  seller_impact: |
    - Some buyer urgency before further increases
    - Price pressure may build
  agent_action: |
    - Contact buyers on the fence about locking rates
    - Review pre-approvals for affected clients

alert:
  level: MAJOR
  recipients: all_agents
  channels: push, email
  message: |
    📈 RATE ALERT: 30-year fixed jumped to 7.125% (+0.25%)

    Buyer impact: ~$90/mo increase per $100k borrowed.

    Consider reaching out to clients who were on the fence
    about locking rates.

    [View Full Analysis]
```

### Example 2: Inventory Shift

```yaml
trigger: Inventory change > 10% week-over-week
detected: 2026-01-15

data:
  market: "Orlando Metro"
  previous_inventory: 8,450
  current_inventory: 9,350
  change: +10.7%
  months_supply_prev: 2.1
  months_supply_now: 2.4

analysis:
  significance: MODERATE
  market_shift: "Moving slightly toward balance"
  buyer_impact: "More options, slightly less pressure"
  seller_impact: "More competition, pricing important"

alert:
  level: MODERATE
  include_in: daily_briefing
```

### Example 3: Fed Rate Decision

```yaml
trigger: Fed meeting day
date: 2026-01-29

pre_meeting_briefing:
  current_fed_rate: 4.25-4.50%
  market_expectation: "Hold steady (85% probability)"
  potential_outcomes:
    hold: "Rates likely stable, market relief"
    cut_25bp: "Rates may drop 0.125-0.25%, buyer enthusiasm"
    hike_25bp: "Rates may jump 0.25%+, buyer caution"

post_meeting_update:
  decision: "Hold at 4.25-4.50%"
  fed_statement_summary: |
    Fed sees inflation progress but remains cautious.
    Future cuts possible but data-dependent.
  market_reaction: "30yr stable at 6.95%"
  agent_talking_points:
    - "Fed held rates as expected"
    - "No immediate rate relief, but cuts possible later in year"
    - "Good time to lock if you find the right property"
```

## Market Snapshots

### Daily Snapshot (7 AM)

```typescript
interface DailySnapshot {
  date: string;
  rates: {
    thirty_year: number;
    change_24h: number;
    trend: "up" | "down" | "stable";
  };
  florida_markets: {
    [market: string]: {
      active_listings: number;
      new_today: number;
      median_price: number;
      median_dom: number;
    };
  };
  headline: string;
  agent_tip: string;
}
```

### Weekly Summary

```typescript
interface WeeklySummary {
  week_ending: string;
  rate_summary: {
    high: number;
    low: number;
    close: number;
    change: number;
  };
  market_summary: {
    [market: string]: {
      inventory_change: number;
      price_change: number;
      dom_change: number;
      market_type: string;
    };
  };
  trends: string[];
  predictions: string[];
}
```

## Output Schema

```typescript
interface MarketMonitorOutput {
  success: boolean;
  actionTaken: string;
  result: {
    data_points_updated: number;
    sources_checked: number;
    significant_changes: SignificantChange[];

    current_snapshot: {
      rates: InterestRateData;
      florida_markets: Record<string, MarketData>;
      updated_at: string;
    };

    alerts_triggered: Alert[];

    next_scheduled: {
      rate_check: string;
      inventory_update: string;
      weekly_summary: string;
    };
  };
  shouldContinue: boolean;
}

interface MarketData {
  inventory: InventoryData;
  pricing: PricingData;
  dom: DOMData;
}

interface SignificantChange {
  type: "rate" | "inventory" | "price" | "dom";
  market?: string;
  previous: number;
  current: number;
  change_pct: number;
  significance: "major" | "moderate" | "minor";
}
```

## Error Handling

| Error | Cause | Response |
|-------|-------|----------|
| `SOURCE_UNAVAILABLE` | API/website down | Use last known data, flag staleness |
| `RATE_LIMIT` | Too many requests | Backoff, use cached data |
| `DATA_ANOMALY` | Values outside expected range | Flag for review, don't auto-update |
| `MLS_AUTH_FAILED` | API credentials issue | Alert admin, use public sources |

## Quality Checklist

- [x] Monitors all major rate sources
- [x] Tracks Florida-specific MLS data
- [x] Calculates changes accurately
- [x] Identifies significant movements
- [x] Provides agent-ready talking points
- [x] Alerts appropriately by significance
- [x] Maintains historical data
- [x] Handles source failures gracefully
- [x] Updates Homer's market knowledge
- [x] Supports area-specific queries

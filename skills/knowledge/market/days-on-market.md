# Skill: Days on Market Monitor

**Category:** Knowledge/Market
**Priority:** P1
**Approval Required:** No

## Purpose

Track days on market (DOM) metrics across Florida markets to assess listing velocity, market temperature, and pricing effectiveness. This skill helps agents set client expectations, evaluate pricing strategy success, and understand competitive positioning.

## Voice Commands

- "How fast are homes selling in [area]?"
- "What's the average days on market?"
- "How long should I expect my listing to take?"
- "Are homes selling faster or slower now?"
- "DOM check for [zip code]"
- "Velocity report for [market]"

## Triggers

### Scheduled
- **Weekly:** DOM calculations from sold data
- **Monthly:** Comprehensive velocity analysis
- **Quarterly:** Trend analysis and comparisons

### Event-Based
- Significant DOM change (>20% shift)
- Market velocity shift detected
- Seasonal pattern deviation

## Monitored Sources

### Primary Sources

| Source | Coverage | Frequency | Data |
|--------|----------|-----------|------|
| Stellar MLS | Central/East FL | Weekly | CDOM, DOM |
| Miami MLS | South FL | Weekly | CDOM, DOM |
| BeachMLS | Gulf Coast | Weekly | CDOM, DOM |
| My Florida Regional MLS | Statewide | Weekly | Aggregated |

### Metrics Tracked

- **DOM (Days on Market):** Days from listing to contract
- **CDOM (Cumulative DOM):** Total days including relists
- **Days to Close:** Contract to closing
- **Total Market Time:** Listing to close

## DOM Data Schema

```typescript
interface DOMSnapshot {
  timestamp: string;
  market: string;
  submarket?: string;
  zip_code?: string;

  dom_metrics: {
    median_dom: number;
    average_dom: number;
    median_cdom: number;       // Cumulative (includes relists)
    days_to_close: number;     // Contract to closing
    total_market_time: number; // List to close
  };

  distribution: {
    under_7_days: number;      // % of sales
    week_1_2: number;          // 7-14 days
    week_2_4: number;          // 15-30 days
    month_1_2: number;         // 31-60 days
    month_2_3: number;         // 61-90 days
    over_90_days: number;
  };

  changes: {
    wow: number;               // Week over week
    mom: number;               // Month over month
    yoy: number;               // Year over year
  };

  by_property_type: {
    single_family: DOMMetrics;
    condo_townhouse: DOMMetrics;
  };

  by_price_range: {
    under_300k: DOMMetrics;
    range_300k_500k: DOMMetrics;
    range_500k_750k: DOMMetrics;
    range_750k_1m: DOMMetrics;
    over_1m: DOMMetrics;
  };

  correlation: {
    list_price_to_dom: string;  // "Overpriced homes average X more days"
    condition_impact: string;
    photos_impact: string;
  };
}

interface DOMMetrics {
  median_dom: number;
  average_dom: number;
  pct_under_14_days: number;
  pct_over_60_days: number;
}
```

## Market Velocity Classifications

```typescript
const VELOCITY_CLASSIFICATIONS = {
  very_hot: {
    median_dom: { max: 14 },
    characteristics: [
      "Most homes under contract in first 2 weeks",
      "Multiple offers common",
      "Must act immediately",
      "Price often goes above asking"
    ],
    pricing_implication: "Can price at or slightly above market",
    seller_expectation: "Expect offers within days of listing"
  },

  hot: {
    median_dom: { min: 14, max: 30 },
    characteristics: [
      "Homes selling in first month",
      "Competition for desirable listings",
      "Little room for price negotiation",
      "Fast decision-making required"
    ],
    pricing_implication: "Price at market for quick sale",
    seller_expectation: "Expect showings immediately, offers within weeks"
  },

  normal: {
    median_dom: { min: 30, max: 60 },
    characteristics: [
      "Typical market conditions",
      "Room for buyer consideration",
      "Some negotiation expected",
      "Standard transaction timeline"
    ],
    pricing_implication: "Price accurately, minor room for error",
    seller_expectation: "Expect 30-60 days to contract"
  },

  slow: {
    median_dom: { min: 60, max: 90 },
    characteristics: [
      "Buyers taking their time",
      "Price sensitivity high",
      "Negotiation expected",
      "Patience required"
    ],
    pricing_implication: "Must price competitively, may need to reduce",
    seller_expectation: "Expect 60-90 days, prepare for price discussions"
  },

  very_slow: {
    median_dom: { min: 90 },
    characteristics: [
      "Extended selling times",
      "Strong buyer leverage",
      "Multiple price reductions common",
      "Challenging market conditions"
    ],
    pricing_implication: "Price below competition, expect reductions",
    seller_expectation: "90+ days typical, be prepared for extended period"
  }
};
```

## Execution Flow

```
START
  │
  ├─── 1. Fetch sold listing data
  │    │
  │    ├── Query recent closed sales
  │    ├── Extract DOM and CDOM values
  │    ├── Calculate days to close
  │    └── Note list price vs. sold price
  │
  ├─── 2. Calculate DOM metrics
  │    │
  │    ├── Median DOM (primary metric)
  │    ├── Average DOM (with outlier awareness)
  │    ├── Distribution buckets
  │    └── CDOM analysis (relist patterns)
  │
  ├─── 3. Segment analysis
  │    │
  │    ├── By property type
  │    ├── By price range
  │    ├── By submarket/geography
  │    └── By listing characteristics
  │
  ├─── 4. Calculate changes
  │    │
  │    ├── Week over week
  │    ├── Month over month
  │    ├── Year over year
  │    └── Seasonal comparison
  │
  ├─── 5. Classify market velocity
  │    │
  │    ├── Apply threshold classifications
  │    ├── Compare to historical norms
  │    ├── Note recent shifts
  │    └── Identify acceleration/deceleration
  │
  ├─── 6. Analyze correlations
  │    │
  │    └── PROMPT:
  │        """
  │        You are a real estate market velocity analyst.
  │
  │        MARKET: {{market}}
  │        DOM DATA: {{dom_data}}
  │        HISTORICAL COMPARISON: {{historical}}
  │
  │        Analyze days on market data:
  │
  │        1. Velocity Assessment:
  │           - How fast is the market?
  │           - How does this compare to historical?
  │           - Is it accelerating or slowing?
  │
  │        2. Pricing Effectiveness:
  │           - What DOM suggests about pricing?
  │           - What's the DOM penalty for overpricing?
  │           - Optimal pricing strategy?
  │
  │        3. Segment Differences:
  │           - Which segments move fastest?
  │           - Which are slowest?
  │           - Why the differences?
  │
  │        4. Seller Expectations:
  │           - Realistic timeline by price point?
  │           - What to tell listing clients?
  │
  │        5. Buyer Implications:
  │           - How quickly must buyers act?
  │           - Any leverage from slower segments?
  │        """
  │
  ├─── 7. Check for significant changes
  │    │
  │    ├── IF DOM change > 20%:
  │    │   └── Generate alert
  │    │
  │    ├── IF velocity classification change:
  │    │   └── Generate alert
  │    │
  │    └── IF unusual vs. seasonal:
  │        └── Note anomaly
  │
  └─── 8. Return DOM report
```

## Alert Examples

### Example 1: Market Velocity Shift

```yaml
trigger: Market velocity classification changed
market: "Jacksonville"
detected: 2026-01-15

shift:
  from: "Hot (21 days median)"
  to: "Normal (38 days median)"
  change: +81%

metrics:
  current_median_dom: 38
  previous_month: 21
  same_period_last_year: 25
  change_mom: +81%
  change_yoy: +52%

analysis:
  cause: |
    Combination of increased inventory (+15% MoM) and
    seasonal slowdown extending into January.

  is_seasonal: "Partially - but more pronounced than typical"

implications:
  for_sellers:
    - "Expect longer selling timeline than last few months"
    - "Pricing accuracy more critical"
    - "Condition and presentation matter more"
    - "30-45 day timeline is now realistic"

  for_buyers:
    - "Less urgency than recent months"
    - "More time to evaluate options"
    - "Some negotiation room emerging"
    - "Can be more deliberate"

  for_pricing:
    - "Overpriced listings will sit"
    - "First 2 weeks still critical"
    - "Price reductions more common"

alert:
  level: HIGH
  recipients: jacksonville_agents
```

### Example 2: Weekly DOM Report

```yaml
type: weekly_dom_report
market: "Orlando Metro"
week_ending: 2026-01-15

summary:
  median_dom: 28
  average_dom: 35
  median_cdom: 32
  velocity: "Hot"

distribution:
  sold_in_first_week: 22%
  sold_in_2_weeks: 38%
  sold_in_30_days: 62%
  sold_in_60_days: 85%
  over_90_days: 7%

changes:
  vs_last_week: +2 days
  vs_last_month: +5 days
  vs_last_year: -3 days

by_price_range:
  - range: "Under $300K"
    median_dom: 12
    velocity: "Very Hot"
    note: "Extremely competitive"

  - range: "$300K-$500K"
    median_dom: 24
    velocity: "Hot"
    note: "Core market, strong demand"

  - range: "$500K-$750K"
    median_dom: 38
    velocity: "Normal"
    note: "Healthy but more deliberate"

  - range: "$750K-$1M"
    median_dom: 52
    velocity: "Normal-Slow"
    note: "Buyer leverage emerging"

  - range: "Over $1M"
    median_dom: 78
    velocity: "Slow"
    note: "Extended timeline expected"

by_property_type:
  single_family:
    median_dom: 25
    pct_under_14_days: 35%
    note: "Strong demand"

  condo_townhouse:
    median_dom: 38
    pct_under_14_days: 18%
    note: "Slower, insurance concerns"

insights:
  - "Entry-level market (<$300K) remains extremely competitive"
  - "Luxury segment ($1M+) requires patience - 78 day median"
  - "Condos taking 50% longer than single-family"
  - "Well-priced homes still moving quickly"

talking_points:
  for_sellers:
    - "If priced right, expect offers within 2-4 weeks"
    - "Entry-level homes often multiple offers"
    - "Luxury needs more patience"

  for_buyers:
    - "Act quickly on homes under $500K"
    - "More time to consider in higher price ranges"
    - "Condos may offer more negotiation room"
```

### Example 3: Overpricing Impact Analysis

```yaml
type: overpricing_analysis
market: "Tampa Bay"
period: "Last 90 days closed sales"

finding:
  summary: "Overpriced listings take 3x longer to sell"

data:
  priced_at_market:
    definition: "Sold within 3% of original list"
    median_dom: 22
    pct_of_sales: 68%

  priced_5_pct_high:
    definition: "Sold 5-10% below original list"
    median_dom: 48
    pct_of_sales: 18%

  priced_10_pct_high:
    definition: "Sold 10%+ below original list"
    median_dom: 72
    pct_of_sales: 14%

analysis:
  pattern: |
    Homes that ultimately sold close to market value (within 3%)
    sold in a median of 22 days. Those that required 10%+ reduction
    sat for a median of 72 days - more than 3x as long.

  conclusion: |
    Overpricing costs sellers TIME. The extra weeks on market
    often result in lower final prices than correct pricing
    from the start.

  recommendation: |
    Price competitively from day one. The first 2 weeks
    generate the most buyer interest.

agent_guidance:
  for_pricing_discussions:
    - "Overpricing typically costs 50+ days on market"
    - "Stale listings often sell for less than competitive pricing"
    - "First impression is everything - buyers see DOM"
    - "Price reductions can signal desperation"

  for_overpriced_listings:
    - "Every 2 weeks without offer, reassess price"
    - "First reduction should be meaningful (at least 3%)"
    - "Better to reduce once significantly than nibble"
```

## Seller Expectation Tool

```typescript
interface SellerTimeline {
  property: {
    type: string;
    price_range: string;
    market: string;
    condition: "excellent" | "good" | "fair" | "needs_work";
  };

  market_velocity: string;

  expected_timeline: {
    if_priced_at_market: {
      dom_range: { low: number; high: number };
      likelihood_under_30_days: number;
    };
    if_priced_5_pct_high: {
      dom_range: { low: number; high: number };
      likely_price_reduction: boolean;
    };
    if_priced_10_pct_high: {
      dom_range: { low: number; high: number };
      likely_outcome: string;
    };
  };

  days_to_close_after_contract: number;

  total_timeline: {
    optimistic: string;  // e.g., "6 weeks"
    realistic: string;   // e.g., "8-10 weeks"
    if_challenges: string; // e.g., "12-16 weeks"
  };

  factors_that_speed_up: string[];
  factors_that_slow_down: string[];
}
```

## Output Schema

```typescript
interface DaysOnMarketOutput {
  success: boolean;
  actionTaken: string;
  result: {
    snapshot_date: string;

    statewide: {
      median_dom: number;
      change_yoy: number;
      velocity: string;
    };

    by_market: {
      market: string;
      median_dom: number;
      velocity: string;
      change_mom: number;
      change_yoy: number;
    }[];

    velocity_shifts: {
      market: string;
      from: string;
      to: string;
      date: string;
    }[];

    fastest_segments: {
      segment: string;
      market: string;
      median_dom: number;
    }[];

    slowest_segments: {
      segment: string;
      market: string;
      median_dom: number;
    }[];

    insights: string[];
    talking_points: {
      for_sellers: string[];
      for_buyers: string[];
    };

    next_update: string;
  };
  shouldContinue: boolean;
}
```

## Error Handling

| Error | Cause | Response |
|-------|-------|----------|
| `INSUFFICIENT_SALES` | Not enough closed sales | Use larger geography or time |
| `OUTLIER_SKEW` | Extreme DOM skewing average | Use median, filter outliers |
| `DATA_LAG` | Recent sales not yet in MLS | Note data through date |
| `SEGMENT_TOO_SMALL` | Price band with few sales | Combine with adjacent |

## Quality Checklist

- [x] Calculates median and average DOM accurately
- [x] Tracks CDOM for relist patterns
- [x] Provides distribution analysis
- [x] Segments by price and property type
- [x] Classifies market velocity
- [x] Detects velocity shifts
- [x] Analyzes overpricing impact
- [x] Sets realistic seller expectations
- [x] Provides buyer timing guidance
- [x] Supports submarket queries

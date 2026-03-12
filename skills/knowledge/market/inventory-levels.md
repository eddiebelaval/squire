# Skill: Inventory Levels Monitor

**Category:** Knowledge/Market
**Priority:** P1
**Approval Required:** No

## Purpose

Track real estate inventory levels across Florida markets, including active listings, new listings, pending sales, and months of supply. This skill helps agents understand market conditions, advise clients on pricing strategy, and identify market shifts.

## Voice Commands

- "How much inventory is there in [market]?"
- "What's the months of supply in [area]?"
- "Are there more homes on the market now?"
- "How's inventory trending?"
- "Is this a buyer's or seller's market in [area]?"
- "Inventory check for [zip code]"

## Triggers

### Scheduled
- **Daily:** Active listing counts from MLS
- **Weekly:** New listings, pending sales, absorption rate
- **Monthly:** Comprehensive inventory analysis
- **Quarterly:** Market shift analysis

### Event-Based
- Significant inventory change (>10% weekly)
- Market type shift (seller→balanced→buyer)
- Seasonal pattern deviation
- New development impact

## Monitored Sources

### Primary MLS Sources

| Source | Coverage | Frequency | Data |
|--------|----------|-----------|------|
| Stellar MLS | Central/East FL | Daily | Full listing data |
| Miami MLS | South FL | Daily | Full listing data |
| BeachMLS | Gulf Coast | Daily | Full listing data |
| My Florida Regional MLS | Statewide | Daily | Aggregated data |

### Supplementary Sources

| Source | Focus | Frequency |
|--------|-------|-----------|
| Realtor.com | National comparison | Weekly |
| Redfin Data Center | Market metrics | Weekly |
| Zillow Research | Trend analysis | Monthly |
| Florida Realtors | State statistics | Monthly |

## Inventory Data Schema

```typescript
interface InventorySnapshot {
  timestamp: string;
  market: string;           // Metro area
  submarket?: string;       // County or city
  zip_code?: string;

  active_listings: {
    total: number;
    single_family: number;
    condo_townhouse: number;
    multi_family?: number;

    by_price_range: {
      under_300k: number;
      range_300k_500k: number;
      range_500k_750k: number;
      range_750k_1m: number;
      over_1m: number;
    };
  };

  new_listings: {
    last_7_days: number;
    last_30_days: number;
    change_wow: number;      // Week over week
    change_yoy: number;      // Year over year
  };

  pending_sales: {
    total: number;
    last_7_days: number;
    last_30_days: number;
  };

  closed_sales: {
    last_30_days: number;
    change_yoy: number;
  };

  absorption_rate: {
    monthly: number;         // Sales per month
    months_of_supply: number;
    trend: "increasing" | "decreasing" | "stable";
  };

  market_type: "seller" | "balanced" | "buyer";

  price_metrics: {
    median_list_price: number;
    average_list_price: number;
    median_price_change_yoy: number;
  };
}
```

## Market Type Definitions

```typescript
const MARKET_TYPE_THRESHOLDS = {
  seller_market: {
    months_supply: { max: 4 },
    characteristics: [
      "Multiple offers common",
      "Prices rising",
      "Quick sales",
      "Seller leverage"
    ],
    agent_guidance: {
      for_buyers: "Act quickly, be prepared to compete",
      for_sellers: "Price competitively to maximize offers"
    }
  },

  balanced_market: {
    months_supply: { min: 4, max: 6 },
    characteristics: [
      "Negotiations more common",
      "Prices stable",
      "Reasonable time on market",
      "Fair for both parties"
    ],
    agent_guidance: {
      for_buyers: "Room to negotiate, but good homes still move",
      for_sellers: "Price accurately, expect some negotiation"
    }
  },

  buyer_market: {
    months_supply: { min: 6 },
    characteristics: [
      "Price reductions common",
      "Longer days on market",
      "Buyer leverage",
      "Concessions expected"
    ],
    agent_guidance: {
      for_buyers: "Take time, negotiate strongly",
      for_sellers: "Price competitively, consider incentives"
    }
  }
};
```

## Execution Flow

```
START
  │
  ├─── 1. Fetch MLS data
  │    │
  │    ├── Query active listing counts
  │    ├── Query new listings (7 and 30 days)
  │    ├── Query pending sales
  │    ├── Query closed sales
  │    └── Segment by property type and price
  │
  ├─── 2. Calculate metrics
  │    │
  │    ├── Monthly absorption rate:
  │    │   └── closed_sales_30d
  │    │
  │    ├── Months of supply:
  │    │   └── active_listings / monthly_absorption
  │    │
  │    ├── Change calculations:
  │    │   ├── Week over week
  │    │   ├── Month over month
  │    │   └── Year over year
  │    │
  │    └── Trend analysis:
  │        └── Compare to previous 4 weeks
  │
  ├─── 3. Determine market type
  │    │
  │    ├── Apply months of supply thresholds
  │    ├── Consider trend direction
  │    └── Note recent shifts
  │
  ├─── 4. Segment analysis
  │    │
  │    ├── By price range
  │    │   └── Different segments may have different conditions
  │    │
  │    ├── By property type
  │    │   └── SFR vs. condo may differ
  │    │
  │    └── By geography
  │        └── Submarkets may vary
  │
  ├─── 5. Compare to seasonal norms
  │    │
  │    ├── Is inventory typical for this time of year?
  │    ├── Any unusual patterns?
  │    └── Seasonal adjustments
  │
  ├─── 6. Generate insights
  │    │
  │    └── PROMPT:
  │        """
  │        You are a Florida real estate market analyst.
  │
  │        MARKET: {{market}}
  │        CURRENT INVENTORY: {{inventory_data}}
  │        HISTORICAL COMPARISON: {{historical}}
  │        SEASONAL NORMS: {{seasonal}}
  │
  │        Analyze this inventory data:
  │
  │        1. Market Condition Summary:
  │           - Is this a buyer's, seller's, or balanced market?
  │           - How has this changed recently?
  │
  │        2. Trend Analysis:
  │           - Is inventory rising, falling, or stable?
  │           - What's driving the trend?
  │           - Is this seasonal or structural?
  │
  │        3. Price Segment Analysis:
  │           - Which price ranges are tightest?
  │           - Which have more inventory?
  │
  │        4. Agent Implications:
  │           - How should this affect pricing advice?
  │           - What should buyers know?
  │           - What should sellers know?
  │
  │        5. Outlook:
  │           - Where is inventory likely headed?
  │           - Any inflection points expected?
  │        """
  │
  ├─── 7. Check for significant changes
  │    │
  │    ├── IF inventory change > 10% weekly:
  │    │   └── Generate alert
  │    │
  │    ├── IF market type shift:
  │    │   └── Generate alert
  │    │
  │    └── IF unusual vs. seasonal:
  │        └── Note in analysis
  │
  └─── 8. Return inventory report
```

## Alert Examples

### Example 1: Inventory Surge

```yaml
trigger: Inventory +15% week-over-week
market: "Tampa Bay"
detected: 2026-01-15

change:
  previous_week: 8,450
  current: 9,720
  change_pct: +15%
  change_count: +1,270

analysis:
  cause: "Seasonal listing surge + new construction deliveries"
  by_segment:
    under_500k: +8%
    range_500k_750k: +22%
    over_750k: +18%

market_impact:
  months_supply:
    previous: 2.8
    current: 3.4
  market_type: "Still seller's market, but loosening"

agent_implications:
  for_buyers: |
    - More options, especially in $500K+ range
    - Slightly less urgency, but good homes still sell fast
    - May see more negotiation room

  for_sellers: |
    - More competition from other listings
    - Pricing accuracy more important
    - Marketing differentiation matters more

alert:
  level: MEDIUM
  include_in: weekly_digest
```

### Example 2: Market Type Shift

```yaml
trigger: Market shifted from seller's to balanced
market: "Orlando Metro"
detected: 2026-01-15

shift:
  from: "seller's market"
  to: "balanced market"
  cause: "Months of supply crossed 4.0 threshold"

metrics:
  months_supply:
    3_months_ago: 2.5
    1_month_ago: 3.2
    current: 4.2
  trend: "Steadily increasing inventory"

context:
  active_listings: 12,340
  change_yoy: +35%
  new_listings_30d: 4,200
  pending_sales_30d: 2,940

implications:
  market_dynamics: |
    The Orlando market has shifted to balanced conditions.
    This means more negotiation, longer selling times,
    and the need for accurate pricing.

  for_buyers:
    - "Less pressure to waive contingencies"
    - "Room to negotiate on price and terms"
    - "Can take time to find the right home"

  for_sellers:
    - "Price competitively from day one"
    - "Expect 30-45 days on market vs. 15-20"
    - "Be prepared for negotiations"
    - "Consider pre-listing inspections"

  pricing_guidance:
    - "List at or slightly below market value"
    - "Price reductions may be needed if no activity in 2 weeks"
    - "Monitor competition closely"

alert:
  level: HIGH
  recipients: all_orlando_agents
```

### Example 3: Weekly Market Snapshot

```yaml
type: weekly_snapshot
market: "Miami-Dade"
week_ending: 2026-01-15

summary:
  active_listings: 15,670
  change_wow: +3.2%
  change_yoy: +18%
  new_listings_7d: 1,245
  pending_7d: 890
  months_supply: 5.2
  market_type: "Balanced"

by_segment:
  single_family:
    active: 6,890
    months_supply: 4.8
    market_type: "Seller's (tight)"

  condo_townhouse:
    active: 8,780
    months_supply: 6.1
    market_type: "Buyer's"

by_price:
  under_400k:
    active: 2,340
    months_supply: 2.1
    market_type: "Strong seller's"

  range_400k_700k:
    active: 5,670
    months_supply: 4.5
    market_type: "Seller's"

  range_700k_1m:
    active: 3,450
    months_supply: 6.8
    market_type: "Buyer's"

  over_1m:
    active: 4,210
    months_supply: 9.2
    market_type: "Buyer's"

key_insights:
  - "Entry-level market remains very competitive"
  - "Luxury segment continues to favor buyers"
  - "Condo market softer than single-family"
  - "South Beach condo inventory particularly high"

agent_talking_points:
  - "Market varies significantly by price point"
  - "Under $400K - expect competition, act fast"
  - "Over $700K - buyers have more leverage"
  - "Condos softer than single-family overall"
```

## Florida Market Tracking

```typescript
interface FloridaMarkets {
  // Major metros tracked
  markets: [
    "Miami-Fort Lauderdale-Palm Beach",
    "Tampa-St. Petersburg-Clearwater",
    "Orlando-Kissimmee-Sanford",
    "Jacksonville",
    "Cape Coral-Fort Myers",
    "Lakeland-Winter Haven",
    "North Port-Sarasota-Bradenton",
    "Deltona-Daytona Beach-Ormond Beach",
    "Palm Bay-Melbourne-Titusville",
    "Pensacola-Ferry Pass-Brent",
    "Tallahassee",
    "Gainesville",
    "Naples-Marco Island",
    "Ocala"
  ];

  // County-level tracking for each metro
  county_detail: true;

  // Zip code level for major metros
  zip_level: ["Miami-Dade", "Broward", "Palm Beach", "Hillsborough", "Orange"];
}
```

## Output Schema

```typescript
interface InventoryLevelsOutput {
  success: boolean;
  actionTaken: string;
  result: {
    snapshot_date: string;

    statewide: {
      active_listings: number;
      change_yoy: number;
      months_supply: number;
      market_type: string;
    };

    by_market: {
      market: string;
      active_listings: number;
      months_supply: number;
      market_type: string;
      change_wow: number;
      change_yoy: number;
    }[];

    significant_changes: {
      market: string;
      change: string;
      impact: string;
    }[];

    market_shifts: {
      market: string;
      from: string;
      to: string;
      date: string;
    }[];

    insights: string[];

    talking_points: string[];

    next_update: string;
  };
  shouldContinue: boolean;
}
```

## Error Handling

| Error | Cause | Response |
|-------|-------|----------|
| `MLS_UNAVAILABLE` | MLS feed down | Use cached data, note staleness |
| `DATA_INCOMPLETE` | Missing market data | Fill from secondary source |
| `CALCULATION_ERROR` | Division by zero, etc. | Use fallback calculation |
| `HISTORICAL_MISSING` | No historical comparison | Note limited trend analysis |

## Quality Checklist

- [x] Tracks all major Florida markets
- [x] Calculates months of supply accurately
- [x] Identifies market type correctly
- [x] Segments by price and property type
- [x] Compares to seasonal norms
- [x] Detects significant changes
- [x] Alerts on market type shifts
- [x] Provides agent talking points
- [x] Includes year-over-year context
- [x] Supports zip code level queries

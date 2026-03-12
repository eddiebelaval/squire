# Skill: Price Trends Monitor

**Category:** Knowledge/Market
**Priority:** P1
**Approval Required:** No

## Purpose

Track home price trends across Florida markets including median and average prices, price per square foot, list-to-sale ratios, and appreciation rates. This skill helps agents with pricing recommendations, market positioning, and buyer/seller negotiations.

## Voice Commands

- "What are prices doing in [area]?"
- "What's the median price in [market]?"
- "How much have prices changed this year?"
- "Price per square foot in [zip code]?"
- "Are prices still going up?"
- "Price check for [neighborhood]"
- "What's the appreciation rate in [area]?"

## Triggers

### Scheduled
- **Weekly:** Median price calculations from closed sales
- **Monthly:** Comprehensive price trend analysis
- **Quarterly:** Appreciation rate calculations
- **Annually:** Year-over-year comparisons

### Event-Based
- Significant price shift (>5% monthly change)
- Record high/low reached
- Price trend reversal detected
- Seasonal deviation from norm

## Monitored Sources

### Primary Sources

| Source | Coverage | Frequency | Data |
|--------|----------|-----------|------|
| Stellar MLS | Central/East FL | Weekly | Closed sale prices |
| Miami MLS | South FL | Weekly | Closed sale prices |
| BeachMLS | Gulf Coast | Weekly | Closed sale prices |
| Florida Realtors | Statewide | Monthly | Official statistics |

### Supplementary Sources

| Source | Focus | Frequency |
|--------|-------|-----------|
| Case-Shiller Index | Metro trends | Monthly |
| FHFA House Price Index | MSA data | Quarterly |
| Zillow Home Value Index | Neighborhood | Monthly |
| Realtor.com Hotness | Demand indicators | Weekly |

## Price Data Schema

```typescript
interface PriceSnapshot {
  timestamp: string;
  market: string;
  submarket?: string;
  zip_code?: string;

  price_metrics: {
    median_sale_price: number;
    average_sale_price: number;
    median_list_price: number;
    median_price_per_sqft: number;
    average_price_per_sqft: number;
  };

  changes: {
    mom: number;         // Month over month %
    qoq: number;         // Quarter over quarter %
    yoy: number;         // Year over year %
    ytd: number;         // Year to date %
    from_peak: number;   // Change from all-time high
  };

  list_to_sale: {
    ratio: number;       // e.g., 98.5%
    trend: "increasing" | "decreasing" | "stable";
    days_ago_comparison: number;
  };

  appreciation: {
    one_year: number;
    three_year_annualized: number;
    five_year_annualized: number;
    ten_year_annualized?: number;
  };

  by_property_type: {
    single_family: {
      median_price: number;
      change_yoy: number;
      price_per_sqft: number;
    };
    condo_townhouse: {
      median_price: number;
      change_yoy: number;
      price_per_sqft: number;
    };
  };

  by_price_band: PriceBandData[];
}

interface PriceBandData {
  range: string;          // e.g., "$300K-$400K"
  sales_count: number;
  pct_of_market: number;
  change_yoy: number;
  avg_days_on_market: number;
}
```

## Price Trend Analysis

```typescript
interface PriceTrendAnalysis {
  market: string;
  analysis_date: string;

  current_state: {
    median_price: number;
    trend_direction: "appreciating" | "declining" | "stable";
    momentum: "accelerating" | "decelerating" | "steady";
    compared_to_historical: "above_trend" | "at_trend" | "below_trend";
  };

  cycle_position: {
    phase: "expansion" | "peak" | "contraction" | "trough" | "recovery";
    evidence: string[];
    months_in_phase: number;
  };

  affordability: {
    median_price_to_income: number;
    mortgage_payment_pct_of_income: number;
    comparison_to_national: string;
    trend: "improving" | "worsening" | "stable";
  };

  price_forecast: {
    three_month: { low: number; mid: number; high: number };
    six_month: { low: number; mid: number; high: number };
    twelve_month: { low: number; mid: number; high: number };
    confidence: number;
    key_factors: string[];
  };

  segments: {
    hottest: { segment: string; appreciation: number; reason: string };
    coolest: { segment: string; appreciation: number; reason: string };
    best_value: { segment: string; price_per_sqft: number; reason: string };
  };

  agent_guidance: {
    pricing_strategy: string;
    buyer_advice: string;
    seller_advice: string;
    negotiation_context: string;
  };
}
```

## Execution Flow

```
START
  │
  ├─── 1. Fetch closed sale data
  │    │
  │    ├── Query recent closed sales from MLS
  │    ├── Filter by property type
  │    ├── Calculate median and average
  │    └── Calculate price per square foot
  │
  ├─── 2. Calculate changes
  │    │
  │    ├── Month over month:
  │    │   └── Compare to same calculation 30 days ago
  │    │
  │    ├── Quarter over quarter:
  │    │   └── Compare to 90 days ago
  │    │
  │    ├── Year over year:
  │    │   └── Compare to same period last year
  │    │
  │    ├── From peak:
  │    │   └── Compare to all-time high in market
  │    │
  │    └── Year to date:
  │        └── Compare to January 1 baseline
  │
  ├─── 3. Analyze list-to-sale ratio
  │    │
  │    ├── Calculate current ratio
  │    ├── Compare to historical average
  │    ├── Identify trend
  │    └── Context for negotiations
  │
  ├─── 4. Calculate appreciation rates
  │    │
  │    ├── 1-year appreciation
  │    ├── 3-year annualized
  │    ├── 5-year annualized
  │    └── Compare to inflation
  │
  ├─── 5. Segment analysis
  │    │
  │    ├── By property type (SFR vs. condo)
  │    ├── By price band
  │    ├── By geography (submarket)
  │    └── Identify hot and cool segments
  │
  ├─── 6. Generate trend analysis
  │    │
  │    └── PROMPT:
  │        """
  │        You are a Florida real estate pricing expert.
  │
  │        MARKET: {{market}}
  │        CURRENT PRICE DATA: {{price_data}}
  │        HISTORICAL DATA: {{historical}}
  │        ECONOMIC CONTEXT: {{economic_context}}
  │
  │        Analyze price trends:
  │
  │        1. Current State:
  │           - What is the price trend?
  │           - Is it accelerating or decelerating?
  │           - How does it compare to historical norms?
  │
  │        2. Market Cycle:
  │           - Where are we in the cycle?
  │           - Evidence for this assessment?
  │
  │        3. Segment Analysis:
  │           - Which segments are hottest?
  │           - Which are cooling?
  │           - Where is best value?
  │
  │        4. Affordability:
  │           - How does this affect buyers?
  │           - Is affordability improving or worsening?
  │
  │        5. Forecast:
  │           - 3, 6, 12 month price outlook
  │           - Key factors that could change this
  │
  │        6. Agent Guidance:
  │           - Pricing strategy recommendations
  │           - Buyer advice
  │           - Seller advice
  │        """
  │
  ├─── 7. Check for significant changes
  │    │
  │    ├── IF monthly change > 3%:
  │    │   └── Flag for attention
  │    │
  │    ├── IF trend reversal detected:
  │    │   └── Generate alert
  │    │
  │    └── IF record high/low:
  │        └── Note milestone
  │
  └─── 8. Return price report
```

## Alert Examples

### Example 1: Price Trend Shift

```yaml
trigger: Price trend reversal detected
market: "Fort Myers Metro"
detected: 2026-01-15

shift:
  previous_trend: "Declining (6 consecutive months)"
  new_trend: "Stabilizing with uptick"
  evidence:
    - "December median up 1.2% over November"
    - "January showing continued strength"
    - "List-to-sale ratio improved to 97.5%"

metrics:
  current_median: 425000
  vs_peak: -8.5%      # Still below peak
  vs_trough: +2.1%    # Up from recent low
  yoy: -3.2%          # Still negative YoY

analysis:
  interpretation: |
    After 6 months of price declines post-Hurricane Ian,
    the Fort Myers market is showing signs of stabilization.
    This could mark the bottom of the correction.

  caveats:
    - "One month doesn't confirm a trend"
    - "Insurance costs still a headwind"
    - "Seasonal factors may be contributing"

agent_implications:
  for_buyers:
    - "May be good entry point if trend continues"
    - "Prices likely won't return to 2022 levels soon"
    - "Still some negotiation room but less than 3 months ago"

  for_sellers:
    - "Market stabilizing but not fully recovered"
    - "Price competitively - don't reach for 2022 prices"
    - "Well-priced homes are selling"

alert:
  level: HIGH
  include_in: weekly_digest
```

### Example 2: Monthly Price Report

```yaml
type: monthly_report
market: "Tampa Bay Metro"
period: "January 2026"

headline_metrics:
  median_sale_price: 395000
  change_mom: +1.8%
  change_yoy: +4.2%
  median_price_per_sqft: 245
  list_to_sale_ratio: 97.8%

by_property_type:
  single_family:
    median: 445000
    change_yoy: +5.1%
    price_per_sqft: 235
    dom: 28

  condo_townhouse:
    median: 315000
    change_yoy: +2.4%
    price_per_sqft: 268
    dom: 42

by_price_band:
  - range: "Under $300K"
    sales_pct: 22%
    change_yoy: +2.1%
    avg_dom: 18
    note: "Very competitive"

  - range: "$300K-$500K"
    sales_pct: 45%
    change_yoy: +4.8%
    avg_dom: 24
    note: "Most active segment"

  - range: "$500K-$750K"
    sales_pct: 20%
    change_yoy: +3.5%
    avg_dom: 35
    note: "Healthy demand"

  - range: "Over $750K"
    sales_pct: 13%
    change_yoy: +1.2%
    avg_dom: 55
    note: "Slower, more negotiation"

appreciation:
  one_year: +4.2%
  three_year_annualized: +12.8%
  five_year_annualized: +9.4%

context:
  vs_florida_average: "+1.2%"
  vs_national: "+2.4%"
  affordability_index: 72  # (100 = perfectly affordable)

outlook:
  next_quarter: "Expect continued moderate appreciation (2-4%)"
  key_factors:
    - "Strong job growth supporting demand"
    - "Limited inventory maintaining prices"
    - "Insurance costs moderating buyer budgets"

talking_points:
  - "Tampa prices up 4.2% year-over-year"
  - "$300K-$500K range is the sweet spot"
  - "Entry level still very competitive"
  - "Luxury segment has more negotiation room"
```

### Example 3: Price Per Square Foot Analysis

```yaml
type: ppsf_analysis
market: "Miami-Dade"
date: 2026-01-15

overall:
  median_ppsf: 425
  change_yoy: +3.8%

by_submarket:
  - area: "Miami Beach"
    ppsf: 850
    change_yoy: +2.1%
    note: "Premium beachfront"

  - area: "Brickell"
    ppsf: 680
    change_yoy: +5.2%
    note: "Urban core strength"

  - area: "Coral Gables"
    ppsf: 520
    change_yoy: +4.1%
    note: "Established luxury"

  - area: "Kendall"
    ppsf: 320
    change_yoy: +6.8%
    note: "Affordable, strong appreciation"

  - area: "Homestead"
    ppsf: 245
    change_yoy: +8.2%
    note: "Entry level, highest appreciation"

insight:
  pattern: |
    Lower-priced submarkets showing highest appreciation
    as buyers seek affordability. Premium areas stable
    but slower growth.

  for_buyers: |
    Consider emerging areas like Kendall and Homestead
    for better value and stronger appreciation potential.

  for_sellers: |
    Price per square foot is key metric for comparison.
    Know your submarket's typical PPSF for accurate pricing.
```

## Output Schema

```typescript
interface PriceTrendsOutput {
  success: boolean;
  actionTaken: string;
  result: {
    snapshot_date: string;

    statewide: {
      median_price: number;
      change_yoy: number;
      price_per_sqft: number;
      trend: string;
    };

    by_market: {
      market: string;
      median_price: number;
      change_yoy: number;
      price_per_sqft: number;
      list_to_sale: number;
      appreciation_1yr: number;
    }[];

    hottest_markets: {
      market: string;
      appreciation: number;
      reason: string;
    }[];

    cooling_markets: {
      market: string;
      change: number;
      reason: string;
    }[];

    trend_shifts: {
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
| `INSUFFICIENT_DATA` | Not enough sales for calculation | Use larger geography or time period |
| `OUTLIER_DETECTED` | Unusual sale skewing data | Apply outlier filtering |
| `HISTORICAL_MISSING` | No comparison data | Note limited trend analysis |
| `MLS_UNAVAILABLE` | Data source down | Use cached data, note staleness |

## Quality Checklist

- [x] Calculates median and average prices accurately
- [x] Tracks price per square foot
- [x] Calculates all change periods (MoM, YoY, etc.)
- [x] Analyzes list-to-sale ratios
- [x] Computes appreciation rates
- [x] Segments by property type and price band
- [x] Identifies trend shifts
- [x] Provides market cycle context
- [x] Generates actionable agent guidance
- [x] Supports zip code level queries

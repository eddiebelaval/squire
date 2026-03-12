# Skill: Interest Rate Monitor

**Category:** Knowledge/Market
**Priority:** P1
**Approval Required:** No

## Purpose

Monitor mortgage interest rate movements in real-time, including conventional, FHA, VA, and jumbo rates. This skill provides agents with current rate intelligence, trend analysis, and buyer affordability impacts to support client conversations and deal timing decisions.

## Voice Commands

- "What's the current mortgage rate?"
- "How have rates moved this week?"
- "What's the 30-year fixed at?"
- "Rate update please"
- "How do today's rates affect buying power?"
- "What's the forecast for rates?"
- "FHA rate check"

## Triggers

### Scheduled
- **Hourly:** Live rate feeds during market hours (9 AM - 5 PM ET)
- **Daily:** End-of-day rate summary (5 PM ET)
- **Weekly:** Freddie Mac PMMS release (Thursday)
- **Event-Based:** Fed announcements, major economic data

### Event-Based
- Rate moves > 0.125% intraday
- Fed rate decision
- Inflation data release (CPI, PCE)
- Employment report
- 10-year Treasury significant move

## Monitored Sources

### Primary Rate Sources

| Source | Frequency | Data |
|--------|-----------|------|
| Mortgage News Daily | Continuous | Live rate movements |
| Freddie Mac PMMS | Weekly (Thursday) | Official weekly averages |
| Bankrate | Daily | Consumer rate quotes |
| Optimal Blue | Daily | Wholesale rate data |
| MBA Rate Survey | Weekly | Industry average |

### Economic Indicators

| Source | Frequency | Impact on Rates |
|--------|-----------|-----------------|
| Federal Reserve | 8x/year | Fed funds rate decisions |
| Bureau of Labor Statistics | Monthly | CPI, employment |
| Bureau of Economic Analysis | Monthly | PCE inflation |
| Treasury Dept | Daily | 10-year yield |

## Rate Data Schema

```typescript
interface RateSnapshot {
  timestamp: string;
  source: string;

  rates: {
    conventional: {
      thirty_year_fixed: Rate;
      fifteen_year_fixed: Rate;
      twenty_year_fixed?: Rate;
      ten_year_fixed?: Rate;
      seven_one_arm?: Rate;
      five_one_arm?: Rate;
    };

    fha: {
      thirty_year_fixed: Rate;
      fifteen_year_fixed?: Rate;
    };

    va: {
      thirty_year_fixed: Rate;
      fifteen_year_fixed?: Rate;
    };

    usda: {
      thirty_year_fixed: Rate;
    };

    jumbo: {
      thirty_year_fixed: Rate;
      fifteen_year_fixed?: Rate;
      seven_one_arm?: Rate;
    };
  };

  context: {
    ten_year_treasury: number;
    fed_funds_rate: { low: number; high: number };
    mortgage_spread: number;
  };
}

interface Rate {
  rate: number;           // e.g., 6.875
  apr?: number;           // e.g., 6.95
  points?: number;        // e.g., 0.5
  change_daily: number;   // e.g., +0.125
  change_weekly: number;
  change_monthly: number;
  change_yearly: number;
}
```

## Rate Analysis Schema

```typescript
interface RateAnalysis {
  current_snapshot: RateSnapshot;

  trends: {
    direction: "rising" | "falling" | "stable";
    momentum: "accelerating" | "decelerating" | "steady";
    volatility: "high" | "moderate" | "low";

    short_term: {
      period: "7 days";
      change: number;
      description: string;
    };

    medium_term: {
      period: "30 days";
      change: number;
      description: string;
    };

    long_term: {
      period: "1 year";
      change: number;
      description: string;
    };
  };

  comparison: {
    vs_week_ago: number;
    vs_month_ago: number;
    vs_year_ago: number;
    vs_year_low: number;
    vs_year_high: number;
  };

  forecast: {
    source: string;
    outlook: "higher" | "lower" | "stable";
    confidence: number;
    key_factors: string[];
    risks: string[];
  };

  buyer_impact: BuyerImpactAnalysis;

  agent_talking_points: string[];
}

interface BuyerImpactAnalysis {
  purchasing_power: {
    at_current_rate: {
      monthly_payment_per_100k: number;
      max_loan_at_1500_payment: number;
      max_loan_at_2000_payment: number;
      max_loan_at_2500_payment: number;
    };

    change_from_month_ago: {
      payment_change_per_100k: number;
      purchasing_power_change_pct: number;
    };

    change_from_year_ago: {
      payment_change_per_100k: number;
      purchasing_power_change_pct: number;
    };
  };

  affordability_context: {
    median_payment_for_median_home: number;
    income_needed_for_median_home: number;
    comparison_to_historical: string;
  };
}
```

## Execution Flow

```
START
  │
  ├─── 1. Fetch current rates
  │    │
  │    ├── Primary source: Mortgage News Daily (live)
  │    ├── Backup: Bankrate, other sources
  │    ├── Validate data freshness
  │    └── Cross-reference for accuracy
  │
  ├─── 2. Calculate changes
  │    │
  │    ├── Daily change (vs. yesterday close)
  │    ├── Weekly change (vs. 7 days ago)
  │    ├── Monthly change (vs. 30 days ago)
  │    ├── Yearly change (vs. 1 year ago)
  │    └── Compare to recent highs/lows
  │
  ├─── 3. Analyze trends
  │    │
  │    ├── Determine direction (rising/falling/stable)
  │    ├── Assess momentum
  │    ├── Evaluate volatility
  │    └── Identify pattern
  │
  ├─── 4. Calculate buyer impact
  │    │
  │    ├── Monthly payment per $100K borrowed
  │    ├── Purchasing power at common payment levels
  │    ├── Change in affordability
  │    └── Context vs. historical norms
  │
  ├─── 5. Generate forecast context
  │    │
  │    ├── Upcoming Fed meetings
  │    ├── Economic data calendar
  │    ├── Expert forecasts
  │    └── Risk factors
  │
  ├─── 6. Check for significant movements
  │    │
  │    ├── IF intraday move > 0.125%:
  │    │   └── Trigger immediate alert
  │    │
  │    ├── IF Fed decision day:
  │    │   └── Provide pre/post analysis
  │    │
  │    └── IF major economic release:
  │        └── Explain rate reaction
  │
  ├─── 7. Generate talking points
  │    │
  │    ├── Current rate summary
  │    ├── Trend context
  │    ├── Buyer affordability impact
  │    └── Actionable advice
  │
  └─── 8. Return rate update
```

## Payment Calculations

```typescript
const PAYMENT_CALCULATIONS = {
  // Monthly payment per $100,000 borrowed at various rates
  paymentTable: {
    5.0: 536.82,
    5.25: 552.20,
    5.5: 567.79,
    5.75: 583.57,
    6.0: 599.55,
    6.25: 615.72,
    6.5: 632.07,
    6.75: 648.60,
    7.0: 665.30,
    7.25: 682.18,
    7.5: 699.21,
    7.75: 716.41,
    8.0: 733.76,
  },

  // Calculate max loan for given payment
  maxLoanForPayment: (payment: number, rate: number) => {
    const monthlyRate = rate / 100 / 12;
    const n = 360; // 30-year
    return (payment * ((1 - Math.pow(1 + monthlyRate, -n)) / monthlyRate));
  },

  // Purchasing power change
  purchasingPowerChange: (oldRate: number, newRate: number) => {
    const oldPayment = PAYMENT_CALCULATIONS.paymentTable[oldRate];
    const newPayment = PAYMENT_CALCULATIONS.paymentTable[newRate];
    return ((oldPayment - newPayment) / newPayment) * 100;
  }
};
```

## Alert Examples

### Example 1: Significant Rate Movement

```yaml
trigger: Rate moved +0.25% today
detected: 2026-01-15 14:30

current:
  thirty_year_fixed: 7.25%
  previous_close: 7.00%
  change: +0.25%

cause: "Strong jobs report exceeded expectations; 10-year Treasury jumped"

buyer_impact:
  payment_per_100k:
    previous: 665.30
    current: 682.18
    increase: +16.88/month

  purchasing_power:
    at_2000_payment:
      previous: 300,700
      current: 293,200
      decrease: -7,500

agent_talking_points:
  - "Rates jumped 0.25% today on strong economic data"
  - "Monthly payments up about $17 per $100K borrowed"
  - "Buyers may want to lock quickly if still shopping"
  - "This is one day's movement - could stabilize"

alert:
  level: HIGH
  message: |
    RATE ALERT: 30-Year Fixed at 7.25% (+0.25% today)

    Strong jobs report pushed rates higher.

    Buyer Impact:
    - $17/month more per $100K borrowed
    - ~$7,500 less purchasing power at $2,000/month budget

    Consider reaching out to buyers who haven't locked.

    [View Full Analysis] [Rate Calculator]
```

### Example 2: Daily Rate Briefing

```yaml
type: daily_briefing
date: 2026-01-15 17:00

rates:
  conventional_30yr: 6.875%
  conventional_15yr: 6.125%
  fha_30yr: 6.625%
  va_30yr: 6.50%
  jumbo_30yr: 7.125%

changes:
  daily: -0.125%
  weekly: +0.25%
  monthly: +0.375%
  yearly: +0.50%

trend:
  direction: "Volatile but trending higher"
  context: "Rates have bounced in 6.5-7.25% range for 3 months"

buyer_impact:
  payment_at_6.875:
    per_100k: 656.51
    for_400k_loan: 2,626/month
    for_500k_loan: 3,283/month

  vs_6_months_ago:
    rate_then: 6.375%
    payment_then_per_100k: 623.97
    difference: +32.54/month per 100k

economic_calendar:
  upcoming:
    - date: 2026-01-29
      event: "Fed Rate Decision"
      expectation: "Hold at 4.25-4.50%"
    - date: 2026-02-07
      event: "Jobs Report"
      impact: "High impact on rates"

talking_points:
  - "Rates down slightly today at 6.875%"
  - "Still volatile - ranging between 6.5% and 7.25%"
  - "Fed meeting Jan 29 - rates may react"
  - "Good time to lock if you find the right property"
```

### Example 3: Fed Decision Day

```yaml
trigger: Fed rate decision
date: 2026-01-29 14:00

decision:
  action: "Cut 25 basis points"
  new_range: "4.00% - 4.25%"
  expectation_met: true

statement_summary:
  tone: "Cautiously optimistic"
  inflation_view: "Progress continues"
  future_guidance: "Data dependent"

market_reaction:
  ten_year_treasury: -0.08%
  mortgage_rates: "Expected to decline 0.125-0.25% over next week"

forecast:
  next_meeting: "2026-03-19"
  market_expects: "Another 25bp cut (60% probability)"

agent_guidance:
  immediate: |
    The Fed cut rates as expected. Mortgage rates typically
    follow over the next 1-2 weeks.

  for_buyers: |
    - Rates may drop 0.125-0.25% soon
    - Don't wait too long - could reverse
    - Lock when you find the right rate/property combo

  for_fence_sitters: |
    Good opportunity to revisit if rate was a barrier.
    Affordability improved modestly.

alert:
  level: HIGH
  include_in: immediate_push
```

## Output Schema

```typescript
interface InterestRateOutput {
  success: boolean;
  actionTaken: string;
  result: {
    current_rates: {
      conventional_30yr: number;
      conventional_15yr: number;
      fha_30yr: number;
      va_30yr: number;
      jumbo_30yr: number;
      as_of: string;
    };

    changes: {
      daily: number;
      weekly: number;
      monthly: number;
      yearly: number;
    };

    trend: {
      direction: string;
      momentum: string;
      volatility: string;
    };

    buyer_impact: {
      payment_per_100k: number;
      purchasing_power_at_2000: number;
      change_from_month_ago: number;
    };

    forecast: {
      outlook: string;
      key_events: string[];
      confidence: number;
    };

    talking_points: string[];

    alerts_triggered: string[];

    next_update: string;
  };
  shouldContinue: boolean;
}
```

## Error Handling

| Error | Cause | Response |
|-------|-------|----------|
| `RATE_SOURCE_DOWN` | Primary source unavailable | Use backup source |
| `DATA_STALE` | Rates not updated recently | Note staleness, use last known |
| `CALCULATION_ERROR` | Payment calc failed | Use lookup table |
| `FORECAST_UNAVAILABLE` | Can't get forecast data | Omit forecast, note absence |

## Quality Checklist

- [x] Monitors multiple rate sources
- [x] Calculates all rate types (conventional, FHA, VA, jumbo)
- [x] Tracks changes across timeframes
- [x] Analyzes trends accurately
- [x] Calculates buyer affordability impact
- [x] Provides context for movements
- [x] Generates actionable talking points
- [x] Alerts on significant movements
- [x] Covers Fed decision days
- [x] Includes forecast context

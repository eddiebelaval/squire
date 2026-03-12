# Skill: Pattern Recognition

**Category:** Intelligence
**Priority:** P1
**Approval Required:** No

## Purpose

Identify patterns across the agent's deal history and current portfolio to surface insights, predict outcomes, and provide data-driven recommendations. This skill analyzes trends in closings, common failure points, party performance, seasonal patterns, and more to help agents improve their success rate.

## Triggers

### Voice Commands
- "What patterns do you see in my deals?"
- "Why do my deals fall through?"
- "What's my closing rate?"
- "Who are my best lenders?"
- "What areas am I strongest in?"
- "Show me my deal analytics"
- "What can I learn from my past deals?"
- "Any patterns I should know about?"

### Automatic
- Monthly pattern analysis (1st of month)
- After deal closes (compare to patterns)
- After deal falls through (identify pattern match)
- Quarterly portfolio review

### Programmatic
- `GET /agents/:id/patterns`
- `GET /agents/:id/analytics`
- Dashboard insights panel
- Weekly summary generation

## Pattern Categories

### 1. Success/Failure Patterns

```typescript
interface SuccessPattern {
  category: 'success' | 'failure';
  patternType: string;
  frequency: number;           // How often this pattern appears
  significance: number;        // Statistical significance 0-1
  description: string;
  affectedDeals: string[];
  recommendation: string;
}
```

**Common Failure Patterns:**

| Pattern | Detection Criteria | Typical Cause |
|---------|-------------------|---------------|
| `FINANCING_COLLAPSE` | Deal fails after day 25, financing not approved | Poor pre-approval, lender issues |
| `INSPECTION_FALLOUT` | Cancel during/after inspection period | Major issues discovered |
| `APPRAISAL_GAP` | Deal fails after appraisal, price dispute | Overpriced listing |
| `TITLE_ISSUES` | Deal fails due to unresolved title problems | Liens, ownership disputes |
| `COLD_FEET` | Buyer cancels early, no specific reason | Buyer not ready |
| `TIMING_MISMATCH` | Multiple extensions, eventually fails | Parties not aligned |
| `COMMUNICATION_BREAKDOWN` | Fails after long response gaps | Poor engagement |

### 2. Party Performance Patterns

```typescript
interface PartyPattern {
  partyType: PartyRole;
  partyName?: string;          // Specific party if applicable
  metric: string;
  value: number;
  benchmark: number;           // Industry/agent average
  trend: 'ABOVE' | 'BELOW' | 'AT';
  insight: string;
}
```

**Tracked Metrics:**

| Party Type | Metrics Tracked |
|-----------|-----------------|
| **Lenders** | Approval rate, avg days to close, on-time close rate, communication score |
| **Title Companies** | Days to commitment, issue rate, on-time close rate |
| **Inspectors** | Report delivery time, issue discovery rate |
| **Appraisers** | Days to complete, gap rate (below contract price) |
| **Buyer's Agents** | Response time, contract acceptance rate |
| **Seller's Agents** | Response time, negotiation success rate |

### 3. Temporal Patterns

```typescript
interface TemporalPattern {
  patternType: 'seasonal' | 'day_of_week' | 'time_of_month' | 'market_cycle';
  observation: string;
  period: string;
  impact: string;
  recommendation: string;
}
```

**Examples:**
- "Your deals started in Q1 close 15% faster than Q4 deals"
- "Deals that go under contract on Fridays have 20% more extensions"
- "June-August closings have higher appraisal gap rates in your market"

### 4. Geographic Patterns

```typescript
interface GeographicPattern {
  area: string;                // ZIP, neighborhood, city
  metric: string;
  value: number;
  insight: string;
}
```

**Examples:**
- "Miami Beach deals take 12 days longer to close on average"
- "Downtown condo deals have 2x the title issue rate"
- "Deals in 33101 ZIP have 95% close rate vs 82% in 33125"

### 5. Price Range Patterns

```typescript
interface PricePattern {
  priceRange: string;          // e.g., "$300k-500k"
  metric: string;
  value: number;
  insight: string;
}
```

**Examples:**
- "Luxury deals ($1M+) have 30% longer closing times"
- "First-time buyer range ($250k-400k) has highest financing fallout"
- "Cash deals close 18 days faster on average"

## Pattern Detection Algorithms

### Failure Pattern Detection

```typescript
function detectFailurePatterns(closedDeals: Deal[], failedDeals: Deal[]): FailurePattern[] {
  const patterns: FailurePattern[] = [];

  // Financing Collapse Pattern
  const financingFailures = failedDeals.filter(d =>
    d.failureReason?.includes('financing') &&
    d.daysSinceEffective > 25
  );
  if (financingFailures.length >= 3) {
    patterns.push({
      type: 'FINANCING_COLLAPSE',
      frequency: financingFailures.length,
      significance: calculateSignificance(financingFailures.length, failedDeals.length),
      deals: financingFailures.map(d => d.id),
      recommendation: 'Strengthen pre-approval verification. Consider preferred lenders with better track record.'
    });
  }

  // Inspection Fallout Pattern
  const inspectionFailures = failedDeals.filter(d =>
    d.cancelledDuring === 'inspection_period' ||
    d.failureReason?.includes('inspection')
  );
  if (inspectionFailures.length >= 3) {
    // Analyze properties involved
    const avgAge = average(inspectionFailures.map(d => d.propertyAge));
    const avgPrice = average(inspectionFailures.map(d => d.purchasePrice));

    patterns.push({
      type: 'INSPECTION_FALLOUT',
      frequency: inspectionFailures.length,
      significance: calculateSignificance(inspectionFailures.length, failedDeals.length),
      deals: inspectionFailures.map(d => d.id),
      insight: `Average property age: ${avgAge} years, average price: ${formatCurrency(avgPrice)}`,
      recommendation: 'Consider pre-inspections for older properties. Set expectations with buyers about property condition.'
    });
  }

  // Communication Breakdown Pattern
  const commFailures = failedDeals.filter(d => {
    const maxGap = getMaxCommunicationGap(d);
    return maxGap > 7 && d.failureReason !== 'financing';
  });
  if (commFailures.length >= 2) {
    patterns.push({
      type: 'COMMUNICATION_BREAKDOWN',
      frequency: commFailures.length,
      significance: calculateSignificance(commFailures.length, failedDeals.length),
      deals: commFailures.map(d => d.id),
      recommendation: 'Increase contact frequency. Send weekly status updates even when nothing is pending.'
    });
  }

  return patterns;
}
```

### Lender Performance Analysis

```typescript
function analyzeLenderPerformance(deals: Deal[]): LenderAnalysis[] {
  const lenderStats: Record<string, LenderStats> = {};

  for (const deal of deals) {
    const lender = deal.parties.find(p => p.role === 'lender');
    if (!lender) continue;

    if (!lenderStats[lender.name]) {
      lenderStats[lender.name] = {
        name: lender.name,
        totalDeals: 0,
        closedDeals: 0,
        totalDaysToClose: 0,
        onTimeCloses: 0,
        avgResponseTime: 0,
        responseTimeSum: 0
      };
    }

    const stats = lenderStats[lender.name];
    stats.totalDeals++;

    if (deal.status === 'closed') {
      stats.closedDeals++;
      stats.totalDaysToClose += deal.daysToClose;
      if (!deal.closingExtended) stats.onTimeCloses++;
    }

    if (lender.averageResponseTime) {
      stats.responseTimeSum += lender.averageResponseTime;
    }
  }

  return Object.values(lenderStats).map(stats => ({
    name: stats.name,
    closeRate: stats.closedDeals / stats.totalDeals,
    avgDaysToClose: stats.totalDaysToClose / stats.closedDeals,
    onTimeRate: stats.onTimeCloses / stats.closedDeals,
    avgResponseTime: stats.responseTimeSum / stats.totalDeals,
    recommendation: generateLenderRecommendation(stats)
  }));
}
```

## Execution Flow

```
START
  │
  ├─── 1. Load historical deal data
  │    ├── All closed deals (success)
  │    ├── All failed/cancelled deals
  │    ├── All current active deals
  │    ├── Party performance history
  │    └── Communication records
  │
  ├─── 2. Analyze success/failure patterns
  │    │
  │    ├── Calculate overall metrics
  │    │   ├── Close rate
  │    │   ├── Average days to close
  │    │   ├── Extension rate
  │    │   └── Fallthrough rate
  │    │
  │    ├── Detect failure patterns
  │    │   ├── Group failed deals by reason
  │    │   ├── Identify statistically significant patterns
  │    │   └── Generate recommendations
  │    │
  │    └── Detect success patterns
  │        ├── What do successful deals have in common?
  │        └── Identify best practices
  │
  ├─── 3. Analyze party performance
  │    │
  │    ├── FOR EACH party type:
  │    │   ├── Aggregate performance metrics
  │    │   ├── Rank individuals within type
  │    │   ├── Identify top performers
  │    │   └── Identify underperformers
  │    │
  │    └── Generate party recommendations
  │
  ├─── 4. Analyze temporal patterns
  │    ├── Seasonal trends
  │    ├── Day of week effects
  │    ├── Time of month patterns
  │    └── Market cycle correlation
  │
  ├─── 5. Analyze geographic patterns
  │    ├── Group deals by ZIP/neighborhood
  │    ├── Calculate area-specific metrics
  │    └── Identify area strengths/weaknesses
  │
  ├─── 6. Analyze price range patterns
  │    ├── Segment deals by price range
  │    ├── Calculate segment-specific metrics
  │    └── Identify optimal price ranges
  │
  ├─── 7. Apply patterns to current deals
  │    │
  │    ├── FOR EACH active deal:
  │    │   ├── Check against failure patterns
  │    │   ├── Flag if pattern match found
  │    │   └── Generate preventive recommendation
  │    │
  │    └── Prioritize by risk
  │
  ├─── 8. Generate insights summary
  │    ├── Top 5 actionable insights
  │    ├── Key metrics vs benchmarks
  │    └── Trend analysis
  │
  ├─── 9. Store analysis
  │    └── INSERT INTO pattern_analyses
  │
  └─── 10. Return result
```

## Output

```typescript
{
  success: true,
  actionTaken: "Completed pattern analysis for agent portfolio",
  result: {
    agentId: "uuid",
    analysisDate: "2026-01-15",
    dateRange: "2025-01-01 to 2026-01-15",

    overallMetrics: {
      totalDeals: 47,
      closedDeals: 38,
      failedDeals: 9,
      activeDeals: 5,
      closeRate: 0.81,
      avgDaysToClose: 42,
      extensionRate: 0.23,
      onTimeCloseRate: 0.77
    },

    failurePatterns: [
      {
        type: "FINANCING_COLLAPSE",
        frequency: 4,
        percentOfFailures: 44,
        significance: 0.85,
        insight: "4 of 9 failed deals collapsed due to financing after day 25",
        affectedDeals: ["Deal 1", "Deal 2", "Deal 3", "Deal 4"],
        commonFactors: [
          "First-time buyers: 75%",
          "Price range $350k-450k: 100%",
          "Same lender (ABC Mortgage): 50%"
        ],
        recommendation: "Strengthen pre-approval verification, especially for first-time buyers in $350k-450k range. Consider alternative lenders to ABC Mortgage."
      },
      {
        type: "INSPECTION_FALLOUT",
        frequency: 3,
        percentOfFailures: 33,
        significance: 0.72,
        insight: "3 deals failed during inspection, all properties 30+ years old",
        affectedDeals: ["Deal 5", "Deal 6", "Deal 7"],
        commonFactors: [
          "Property age 30+ years: 100%",
          "No pre-inspection: 100%"
        ],
        recommendation: "Recommend pre-inspections for properties over 25 years old. Set buyer expectations about older property conditions."
      }
    ],

    partyPerformance: {
      lenders: [
        {
          name: "First National Bank",
          dealCount: 12,
          closeRate: 0.92,
          avgDaysToClose: 38,
          onTimeRate: 0.82,
          avgResponseTime: 18,
          rating: "EXCELLENT",
          recommendation: "Continue using as preferred lender"
        },
        {
          name: "ABC Mortgage",
          dealCount: 8,
          closeRate: 0.63,
          avgDaysToClose: 52,
          onTimeRate: 0.40,
          avgResponseTime: 48,
          rating: "POOR",
          recommendation: "Consider removing from preferred list. High failure rate and slow responses."
        }
      ],
      titleCompanies: [
        {
          name: "Sunshine Title",
          dealCount: 20,
          avgDaysToCommitment: 12,
          issueRate: 0.15,
          onTimeRate: 0.85,
          rating: "GOOD"
        }
      ]
    },

    temporalPatterns: [
      {
        type: "seasonal",
        observation: "Q1 deals close 15% faster than Q4 deals",
        impact: "Faster closings, fewer extensions",
        recommendation: "Push for Q1 contract dates when possible"
      },
      {
        type: "day_of_week",
        observation: "Deals going under contract on Fridays have 25% more extensions",
        impact: "Weekend timing delays response cycles",
        recommendation: "Target Monday-Wednesday for contract execution"
      }
    ],

    geographicPatterns: [
      {
        area: "Miami Beach",
        metric: "avgDaysToClose",
        value: 54,
        benchmark: 42,
        insight: "Miami Beach deals take 12 days longer due to higher condo ratio and HOA delays"
      },
      {
        area: "Coral Gables",
        metric: "closeRate",
        value: 0.94,
        benchmark: 0.81,
        insight: "Coral Gables is your strongest area with 94% close rate"
      }
    ],

    pricePatterns: [
      {
        range: "$300k-500k",
        closeRate: 0.78,
        avgDaysToClose: 45,
        insight: "First-time buyer segment. Higher financing risk.",
        recommendation: "Extra verification on pre-approvals"
      },
      {
        range: "$500k-800k",
        closeRate: 0.88,
        avgDaysToClose: 40,
        insight: "Your sweet spot. Experienced buyers, strong financials."
      },
      {
        range: "$1M+",
        closeRate: 0.75,
        avgDaysToClose: 58,
        insight: "Luxury segment takes longer. More inspections, negotiations."
      }
    ],

    activeDealsAtRisk: [
      {
        dealId: "uuid",
        address: "456 Oak Lane",
        patternMatch: "FINANCING_COLLAPSE",
        matchReason: "First-time buyer, $380k, ABC Mortgage, day 28",
        riskLevel: "HIGH",
        recommendation: "Verify financing status immediately. This profile matches 4 previous failures."
      }
    ],

    keyInsights: [
      "Your close rate of 81% is above market average of 75%",
      "ABC Mortgage is your weakest lender - consider replacing",
      "Coral Gables is your strongest market - consider focusing there",
      "Older properties (30+ years) need pre-inspections",
      "One active deal matches your failure pattern - needs attention"
    ]
  }
}
```

## Voice Response

### General Pattern Query
> "Here are the key patterns I've found in your 47 deals over the past year:
>
> Your close rate is 81%, which is above market average. Nice work.
>
> However, I've noticed a pattern in your failures: 4 out of 9 failed deals collapsed due to financing late in the process. They were all first-time buyers in the $350k-450k range, and half used ABC Mortgage.
>
> Speaking of lenders - First National Bank has a 92% close rate with you, but ABC Mortgage is only 63%. You might want to reconsider that relationship.
>
> Your strongest area is Coral Gables with a 94% close rate. Miami Beach takes 12 days longer on average because of condo complications.
>
> One more thing: you have an active deal at 456 Oak Lane that matches your financing failure pattern. First-time buyer, ABC Mortgage, day 28. I'd check on that one today.
>
> Want me to dive deeper into any of these patterns?"

### Lender Performance Query
> "Let me break down your lender performance:
>
> First National Bank is your top performer - 92% close rate, 38 days average, and they respond in 18 hours. Keep using them.
>
> Sunshine Mortgage is solid - 85% close rate, 42 days average.
>
> But ABC Mortgage is a problem. Only 63% of deals with them close, they take 52 days on average, and their response time is 48 hours. I'd recommend finding an alternative.
>
> Want me to flag any current deals using ABC Mortgage?"

### Active Deal Pattern Match
> "Alert: 456 Oak Lane matches a pattern I've seen before.
>
> It's a first-time buyer, price is $380k, using ABC Mortgage, and we're at day 28.
>
> This exact profile has led to 4 financing failures in your history.
>
> I'd recommend calling the lender today to verify approval status. If there are any issues, it's better to know now.
>
> Would you like me to set a reminder?"

## Error Handling

| Error | Cause | Response |
|-------|-------|----------|
| `INSUFFICIENT_DATA` | < 10 historical deals | "I need more deal history to identify patterns. I'll have better insights after a few more closings." |
| `NO_FAILURES` | No failed deals to analyze | "Great news - you don't have any failed deals to analyze! Your close rate is 100%." |
| `PATTERN_NOT_SIGNIFICANT` | Low statistical significance | Pattern excluded from results (internal handling) |

## Quality Checklist

- [x] Analyzes both success and failure patterns
- [x] Provides statistically significant insights only
- [x] Ranks party performance objectively
- [x] Identifies temporal and geographic patterns
- [x] Applies patterns to current active deals
- [x] Generates actionable recommendations
- [x] Voice response prioritizes most important insights
- [x] Flags at-risk deals proactively
- [x] Compares agent metrics to benchmarks
- [x] Updates monthly with new data

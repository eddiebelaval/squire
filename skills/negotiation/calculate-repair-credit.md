# Skill: Calculate Repair Credit

**Category:** Negotiation
**Priority:** P0
**Approval Required:** Yes (before presenting credit amounts to client or other party)

## Purpose

Calculate appropriate credit amounts for inspection findings based on Florida contractor pricing, regional adjustments, and strategic negotiation factors. This skill provides defensible cost estimates that can withstand seller scrutiny while maximizing buyer value.

## Triggers

### Voice Commands
- "Calculate repair credits"
- "How much credit should we ask for?"
- "What's the credit for these repairs?"
- "Estimate repair costs"
- "Calculate seller credit"
- "How much for [specific repair]?"
- "Get me contractor pricing for [items]"

### System Events
- Repair priorities approved
- Agent requests credit calculation
- Repair request draft initiated

## Required Inputs

| Input | Type | Required | Source | Description |
|-------|------|----------|--------|-------------|
| `dealId` | string | Yes | context | The deal being negotiated |
| `repairItems` | RepairItem[] | Yes | prioritize-repairs | Items to calculate credits for |

## Optional Inputs

| Input | Type | Default | Source | Description |
|-------|------|---------|--------|-------------|
| `region` | string | deal.county | deal | Florida county for regional pricing |
| `propertyType` | string | 'single_family' | deal | Property type affects pricing |
| `propertyAge` | number | null | deal | Age affects material considerations |
| `squareFootage` | number | null | deal | Used for per-sqft calculations |
| `creditStrategy` | string | 'midpoint' | agent | 'conservative' | 'midpoint' | 'aggressive' |
| `includeContingency` | boolean | true | agent | Add 10-15% contingency buffer |
| `lenderMaxCredit` | number | null | deal | Max credit lender will allow |

## Output Schema

```typescript
{
  success: boolean;
  actionTaken: string;
  result: {
    lineItems: CreditLineItem[];
    totals: {
      lowEstimate: number;
      midEstimate: number;
      highEstimate: number;
      recommendedAsk: number;
      fallbackPosition: number;
      minimumAcceptable: number;
    };
    adjustments: {
      regionalAdjustment: number;  // % adjustment for region
      contingency: number;         // % added for unknowns
      negotiationBuffer: number;   // % buffer for negotiation
    };
    lenderConsiderations: {
      maxAllowedCredit: number;
      percentOfPurchasePrice: number;
      creditFitsGuidelines: boolean;
      warning?: string;
    };
    supportingData: {
      pricingSources: string[];
      lastUpdated: Date;
      regionUsed: string;
      marketCondition: string;
    };
    negotiationNotes: string[];
    nextSteps: string[];
  };
  requiresApproval: true;
  approvalContext: {
    action: "Present credit calculation to client";
    stakes: "high";
    reversible: true;
  };
}

interface CreditLineItem {
  id: string;
  item: string;
  category: string;
  description: string;
  quantity: number;
  unit: string;
  baseCost: { low: number; high: number };
  adjustedCost: { low: number; high: number };
  recommendedCredit: number;
  pricingSource: string;
  notes: string;
  confidence: 'high' | 'medium' | 'low';
}
```

## Execution Flow

```
START
  │
  ├─── 1. Validate inputs
  │    ├── Verify deal exists
  │    ├── Verify repair items provided
  │    └── Load deal context (property details, purchase price)
  │
  ├─── 2. Load pricing database
  │    ├── Florida contractor pricing by category
  │    ├── Regional multipliers by county
  │    ├── Current material costs
  │    └── Last update timestamp
  │
  ├─── 3. For each repair item:
  │    │
  │    ├─── 3a. Look up base cost
  │    │    ├── Match category and repair type
  │    │    ├── Get low/high range
  │    │    └── Note pricing source
  │    │
  │    ├─── 3b. Apply quantity/sizing
  │    │    ├── Per-unit items (each)
  │    │    ├── Linear items (per foot)
  │    │    ├── Area items (per sqft)
  │    │    └── Calculate total base
  │    │
  │    ├─── 3c. Apply regional adjustment
  │    │    ├── South Florida: +15-25%
  │    │    ├── Central Florida: +0-10%
  │    │    ├── North Florida: -5-0%
  │    │    └── Apply multiplier
  │    │
  │    ├─── 3d. Apply property factors
  │    │    ├── Property age adjustments
  │    │    ├── Access difficulty
  │    │    └── Special requirements
  │    │
  │    └─── 3e. Calculate confidence level
  │         ├── High: Standard repair, recent pricing
  │         ├── Medium: Variable scope, older pricing
  │         └── Low: Unusual repair, needs specialist quote
  │
  ├─── 4. Calculate totals
  │    ├── Sum all line items
  │    ├── Add contingency (10-15%)
  │    ├── Calculate low/mid/high ranges
  │    └── Apply negotiation buffer
  │
  ├─── 5. Determine recommended amounts
  │    ├── Recommended ask (high estimate + buffer)
  │    ├── Fallback position (midpoint)
  │    ├── Minimum acceptable (low estimate)
  │    └── Walk-away threshold
  │
  ├─── 6. Check lender guidelines
  │    ├── Calculate % of purchase price
  │    ├── Check against max seller credit limits
  │    ├── FHA/VA specific limits
  │    └── Flag if over limits
  │
  ├─── 7. Generate negotiation notes
  │    ├── Strong justification items
  │    ├── Potential pushback items
  │    ├── Alternative approaches
  │    └── Comparable data points
  │
  ├─── 8. Log action
  │    └── action_type: 'credit_calculated'
  │
  └─── 9. Return calculation (pending approval)
```

## Pricing Database Structure

```typescript
interface PricingEntry {
  category: string;
  item: string;
  unit: 'each' | 'sqft' | 'lf' | 'hour' | 'lump';
  laborCost: { low: number; high: number };
  materialCost: { low: number; high: number };
  totalCost: { low: number; high: number };
  source: string;
  lastUpdated: Date;
  notes?: string;
}
```

### Florida Regional Multipliers

| Region | Counties | Multiplier |
|--------|----------|------------|
| South Florida | Miami-Dade, Broward, Palm Beach | 1.20 - 1.30 |
| Southwest Florida | Collier, Lee, Sarasota | 1.15 - 1.25 |
| Tampa Bay | Hillsborough, Pinellas, Pasco | 1.10 - 1.15 |
| Central Florida | Orange, Seminole, Osceola | 1.05 - 1.10 |
| North Florida | Duval, Alachua, Leon | 1.00 - 1.05 |
| Panhandle | Escambia, Okaloosa | 0.95 - 1.00 |

### Common Repair Pricing (2024 Florida Baseline)

| Category | Item | Unit | Low | High | Notes |
|----------|------|------|-----|------|-------|
| **Electrical** | Panel replacement (200A) | each | $2,000 | $3,500 | Includes permit |
| | Outlet replacement | each | $75 | $150 | GFCI: +$25 |
| | Rewiring (partial) | sqft | $4 | $8 | Varies by access |
| **Plumbing** | Water heater (50gal) | each | $1,200 | $2,000 | Tank style |
| | Tankless water heater | each | $2,500 | $4,500 | Includes gas line if needed |
| | Re-pipe (whole house) | lf | $15 | $35 | Depends on access |
| | Leak repair | each | $150 | $500 | Simple to complex |
| **HVAC** | AC replacement (3 ton) | each | $5,500 | $8,500 | Includes install |
| | AC replacement (4 ton) | each | $6,500 | $10,000 | Includes install |
| | Ductwork repair | lf | $25 | $75 | Sealing to replacement |
| | HVAC service/tuneup | each | $150 | $300 | Standard service |
| **Roof** | Shingle repair (minor) | sqft | $5 | $15 | Per affected area |
| | Shingle replacement | square | $300 | $600 | Per 100 sqft |
| | Full roof replacement | square | $400 | $800 | Shingle, tear-off included |
| | Tile roof repair | each | $50 | $150 | Per tile |
| | Flat roof repair | sqft | $8 | $20 | TPO/Modified |
| **Structural** | Foundation crack repair | lf | $250 | $800 | Epoxy injection |
| | Pier installation | each | $1,000 | $3,000 | Helical/push piers |
| | Beam replacement | lf | $100 | $300 | Varies by size/access |
| **Windows/Doors** | Window replacement | each | $500 | $1,500 | Standard size |
| | Impact window | each | $800 | $2,500 | Hurricane rated |
| | Exterior door | each | $800 | $2,000 | Includes install |
| | Sliding glass door | each | $1,500 | $3,500 | Impact: +50% |
| **Safety** | Smoke detector | each | $75 | $150 | Hardwired |
| | GFCI outlet | each | $100 | $200 | Labor included |
| | Railing install | lf | $50 | $150 | Deck/stair |

## Credit Strategy Options

### Conservative Strategy
- Uses low estimates
- Minimal contingency (5%)
- No negotiation buffer
- **Best for**: Seller's market, weak position, As-Is contracts

### Midpoint Strategy (Default)
- Uses midpoint of range
- Standard contingency (10%)
- Small negotiation buffer (5%)
- **Best for**: Balanced markets, reasonable findings

### Aggressive Strategy
- Uses high estimates
- Full contingency (15%)
- Negotiation buffer (10%)
- **Best for**: Buyer's market, major issues, motivated seller

## Lender Credit Limits

| Loan Type | Max Seller Credit | Notes |
|-----------|-------------------|-------|
| Conventional (<10% down) | 3% of purchase price | Stricter for low down payment |
| Conventional (10-25% down) | 6% of purchase price | More flexibility |
| Conventional (>25% down) | 9% of purchase price | Maximum flexibility |
| FHA | 6% of purchase price | Includes closing costs |
| VA | 4% of purchase price | Plus unlimited closing costs |
| Cash | Unlimited | No lender restrictions |

## Voice Response

**After calculation:**
> "I've calculated the repair credits for the 7 items we prioritized:
>
> **Recommended ask: $14,500**
> This includes:
> - Electrical panel: $3,000
> - Roof repairs: $4,500
> - Water heater: $1,800
> - HVAC service: $250
> - Plumbing repairs: $2,500
> - Plus 10% contingency: $1,200
> - Negotiation buffer: $1,250
>
> **Fallback position: $12,000** if they push back.
> **Minimum acceptable: $9,500** - below this, I'd recommend walking.
>
> This is 3.2% of the purchase price, which is within conventional lending limits. The strongest items are the electrical panel and roof - these are non-negotiable from a safety standpoint.
>
> Want me to prepare the repair request with these amounts?"

**If over lender limits:**
> "Heads up - the recommended credit of $22,000 is 4.8% of purchase price, which exceeds FHA's 6% limit when combined with estimated closing costs. Consider:
> 1. Asking for repairs instead of credit on some items
> 2. Price reduction instead of credit
> 3. Reducing the ask to fit within limits
>
> Which approach would you like to take?"

## Error Handling

| Error | Cause | Response |
|-------|-------|----------|
| `NO_PRICING_DATA` | Item not in pricing database | "I don't have standard pricing for [item]. Would you like me to estimate based on similar repairs, or do you have a contractor quote?" |
| `OUTDATED_PRICING` | Pricing data > 6 months old | "My pricing data for [category] is from [date]. Market conditions may have changed. Consider getting a fresh contractor quote for large items." |
| `OVER_LENDER_LIMIT` | Credit exceeds lending guidelines | See lender limit warning above |
| `LOW_CONFIDENCE` | Multiple uncertain items | "Several of these items have variable scope. I recommend getting contractor quotes for [list] to strengthen your position." |
| `REGIONAL_UNKNOWN` | County not in database | "I don't have specific pricing for [county]. Using Central Florida baseline - actual costs may vary." |

## Approval Gate

**This skill requires human approval before:**
1. Presenting credit amounts to client
2. Using in repair request
3. Sharing with other party

**Approval Dialog:**
```
┌─────────────────────────────────────────────────────────────┐
│ APPROVAL REQUIRED: Credit Calculation                        │
├─────────────────────────────────────────────────────────────┤
│ Calculated repair credits for 123 Main Street:               │
│                                                              │
│ LINE ITEMS:                                                  │
│ • Electrical panel replacement: $2,500 - $3,500             │
│ • Roof leak repairs: $3,500 - $5,500                        │
│ • Water heater replacement: $1,200 - $1,800                 │
│ • Plumbing repairs: $1,800 - $2,800                         │
│                                                              │
│ TOTALS:                                                      │
│ • Low Estimate: $9,000                                       │
│ • Recommended Ask: $14,500 (high + buffer)                  │
│ • As % of price: 3.2%                                       │
│                                                              │
│ ✓ Within FHA/Conventional lending limits                    │
│                                                              │
│ [Approve] [Adjust Amounts] [Get Contractor Quotes] [Cancel] │
└─────────────────────────────────────────────────────────────┘
```

## Integration Points

### Inputs From
- `prioritize-repairs` - Items to calculate credits for
- `analyze-inspection-report` - Original findings with descriptions

### Triggers After
- `draft-repair-request` - Use calculated amounts
- `counter-offer` - When responding to seller counter

### External Data
- Florida contractor pricing database
- County-level regional adjustments
- Material cost index updates
- Lender guideline database

### Database Tables
- `credit_calculations` - Stored calculations
- `pricing_database` - Contractor pricing reference
- `action_log` - Audit entry

## Supporting Documentation

When presenting credits, generate:
1. **Itemized breakdown** with pricing sources
2. **Comparable repair costs** in the area
3. **Contractor quote recommendations** for high-value items
4. **Lender compliance statement**

## Florida-Specific Considerations

1. **Hurricane Season**: Roof and window work may have limited contractor availability Aug-Nov
2. **Licensing Requirements**: Electrical and plumbing require licensed contractors
3. **Permit Costs**: Include in estimates where required
4. **Pool Repairs**: Specialized contractors, higher labor rates
5. **Stucco**: Common in FL, varies significantly by extent of damage
6. **Cast Iron Drains**: Older FL homes often need replacement ($10k-$25k)

## Quality Checklist

- [x] Uses Florida-specific contractor pricing
- [x] Applies regional adjustments accurately
- [x] Calculates ranges (low/mid/high)
- [x] Includes appropriate contingency
- [x] Checks lender credit limits
- [x] Provides negotiation positions (ask/fallback/minimum)
- [x] Flags low-confidence estimates
- [x] Notes pricing sources and dates
- [x] Generates supporting documentation
- [x] Requires approval before presenting
- [x] Integrates with repair request workflow
- [x] Handles various loan types

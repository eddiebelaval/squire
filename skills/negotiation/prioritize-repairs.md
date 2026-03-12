# Skill: Prioritize Repairs

**Category:** Negotiation
**Priority:** P0
**Approval Required:** Yes (before finalizing priorities with client)

## Purpose

Rank and prioritize inspection findings by severity, cost, safety impact, and negotiation leverage. This skill helps agents and clients decide which repairs to request, which to seek credits for, and which to accept as-is. Creates a strategic prioritization that maximizes negotiation outcomes.

## Triggers

### Voice Commands
- "Prioritize the repairs"
- "Rank these inspection items"
- "What should we ask for first?"
- "Which repairs are most important?"
- "Help me decide what to request"
- "Create a repair priority list"
- "What's the negotiation priority?"

### System Events
- Inspection analysis completed
- Agent requests repair strategy
- Approaching inspection deadline (suggest prioritization)

## Required Inputs

| Input | Type | Required | Source | Description |
|-------|------|----------|--------|-------------|
| `dealId` | string | Yes | context | The deal being negotiated |
| `findings` | InspectionFinding[] | Yes | analyze-inspection-report | Parsed inspection findings |

## Optional Inputs

| Input | Type | Default | Source | Description |
|-------|------|---------|--------|-------------|
| `clientPriorities` | string[] | null | agent | Client's stated priorities |
| `budget` | number | null | agent | Max credit/repair amount to request |
| `strategy` | string | 'balanced' | agent | 'aggressive' | 'balanced' | 'conservative' |
| `contractType` | string | deal | 'far_bar' | 'far_bar_as_is' | 'custom' |
| `sellerMotivation` | string | 'unknown' | agent | 'high' | 'medium' | 'low' | 'unknown' |
| `marketConditions` | string | 'balanced' | context | 'buyer' | 'seller' | 'balanced' |
| `purchasePrice` | number | deal.purchasePrice | deal | Purchase price for % calculations |

## Output Schema

```typescript
{
  success: boolean;
  actionTaken: string;
  result: {
    prioritizedList: PrioritizedRepair[];
    tiers: {
      mustRequest: PrioritizedRepair[];
      shouldRequest: PrioritizedRepair[];
      niceToHave: PrioritizedRepair[];
      acceptAsIs: PrioritizedRepair[];
    };
    totals: {
      mustRequestCost: { low: number; high: number };
      shouldRequestCost: { low: number; high: number };
      totalRequestedCost: { low: number; high: number };
      percentOfPurchasePrice: number;
    };
    strategy: {
      recommended: 'repairs' | 'credit' | 'combination' | 'walk_away';
      reasoning: string;
      negotiationStrength: 'strong' | 'moderate' | 'weak';
      expectedOutcome: string;
      riskAssessment: string;
    };
    talkingPoints: string[];
    warnings: string[];
    nextSteps: string[];
  };
  requiresApproval: true;
  approvalContext: {
    action: "Finalize repair priorities with client";
    stakes: "high";
    reversible: true;
  };
}

interface PrioritizedRepair {
  findingId: string;
  rank: number;
  tier: 'must_request' | 'should_request' | 'nice_to_have' | 'accept_as_is';
  issue: string;
  category: string;
  severity: string;
  estimatedCost: { low: number; high: number };
  priorityScore: number;
  requestType: 'repair' | 'credit' | 'either';
  reasoning: string;
  negotiationTip: string;
}
```

## Execution Flow

```
START
  │
  ├─── 1. Validate inputs
  │    ├── Verify deal exists and has inspection findings
  │    ├── Load deal context (contract type, price, dates)
  │    └── Verify inspection period status
  │
  ├─── 2. Load context factors
  │    ├── Contract type (As-Is affects strategy)
  │    ├── Market conditions (buyer's vs seller's market)
  │    ├── Seller motivation if known
  │    ├── Days remaining in inspection period
  │    └── Purchase price for percentage calculations
  │
  ├─── 3. Score each finding
  │    ├── Apply severity weight (critical=100, major=60, minor=20)
  │    ├── Apply safety/code violation bonus (+50)
  │    ├── Apply category weight (structural=1.5x, cosmetic=0.5x)
  │    ├── Apply cost factor (higher cost = higher priority)
  │    ├── Apply client priority bonus if mentioned
  │    └── Calculate final priority score (0-200)
  │
  ├─── 4. Assign to tiers
  │    ├── Must Request: score >= 120 OR safety hazard OR code violation
  │    ├── Should Request: score 70-119 AND cost > $500
  │    ├── Nice to Have: score 30-69 OR cost $100-$500
  │    └── Accept As-Is: score < 30 OR cost < $100 OR cosmetic only
  │
  ├─── 5. Apply strategy adjustments
  │    ├── Aggressive: Promote "should" items to "must"
  │    ├── Conservative: Demote "nice to have" to "accept"
  │    ├── As-Is contract: Focus only on safety/code items
  │    └── Seller's market: Be more selective
  │
  ├─── 6. Rank within tiers
  │    ├── Sort by priority score descending
  │    ├── Assign overall rank 1-N
  │    └── Identify "headline" items for negotiation
  │
  ├─── 7. Calculate totals
  │    ├── Sum costs per tier
  │    ├── Calculate total requested amount
  │    ├── Compare to purchase price (flag if >3%)
  │    └── Assess reasonableness
  │
  ├─── 8. Generate strategy recommendation
  │    ├── Recommend repairs vs credit vs combination
  │    ├── Assess negotiation strength
  │    ├── Predict likely seller response
  │    └── Identify walk-away triggers
  │
  ├─── 9. Create talking points
  │    ├── Key arguments for each must-request item
  │    ├── Counter-arguments seller might raise
  │    └── Compromise positions
  │
  ├─── 10. Log action
  │     └── action_type: 'repairs_prioritized'
  │
  └─── 11. Return prioritized list (pending approval)
```

## Priority Scoring Algorithm

```typescript
function calculatePriorityScore(finding: InspectionFinding, context: DealContext): number {
  let score = 0;

  // Base severity score
  const severityScores = {
    critical: 100,
    major: 60,
    minor: 20,
    informational: 5
  };
  score += severityScores[finding.severity];

  // Safety and code bonuses (non-negotiable)
  if (finding.safetyHazard) score += 50;
  if (finding.codeViolation) score += 40;

  // Category multipliers
  const categoryMultipliers = {
    structural: 1.5,
    foundation: 1.5,
    roof: 1.3,
    electrical: 1.3,
    plumbing: 1.2,
    hvac: 1.2,
    safety: 1.4,
    exterior: 1.0,
    interior: 0.8,
    appliances: 0.7,
    cosmetic: 0.5
  };
  score *= categoryMultipliers[finding.category] || 1.0;

  // Cost impact (higher cost = more important to address)
  const avgCost = (finding.estimatedCost.low + finding.estimatedCost.high) / 2;
  if (avgCost > 5000) score += 30;
  else if (avgCost > 2000) score += 20;
  else if (avgCost > 1000) score += 10;

  // Timeframe urgency
  if (finding.repairTimeframe === 'immediate') score += 25;
  else if (finding.repairTimeframe === 'within_30_days') score += 10;

  // Florida-specific factors
  if (finding.category === 'roof' && context.propertyAge > 15) score += 15;
  if (finding.category === 'hvac' && finding.severity === 'major') score += 15; // FL climate

  return Math.round(score);
}
```

## Tier Assignment Rules

| Tier | Score | Additional Criteria | Typical Items |
|------|-------|---------------------|---------------|
| **Must Request** | >= 120 | OR safety/code violation | Electrical hazards, active roof leaks, structural issues |
| **Should Request** | 70-119 | AND cost > $500 | Aging HVAC, water heater, major plumbing |
| **Nice to Have** | 30-69 | OR cost $100-$500 | Minor repairs, deferred maintenance |
| **Accept As-Is** | < 30 | OR purely cosmetic | Paint, carpet, minor cosmetic issues |

## Strategy Adjustments by Context

### Contract Type Adjustments
| Contract | Adjustment |
|----------|------------|
| FAR/BAR Standard | Full negotiation rights, use all tiers |
| FAR/BAR As-Is | Focus only on Must Request, limited leverage |
| Cash As-Is | Very limited, only safety/code items |

### Market Condition Adjustments
| Market | Adjustment |
|--------|------------|
| Buyer's Market | Be more aggressive, include Nice to Have |
| Balanced Market | Standard tiering |
| Seller's Market | Focus only on Must/Should, be prepared to compromise |

### Seller Motivation Adjustments
| Motivation | Adjustment |
|------------|------------|
| High (needs to sell) | More aggressive, higher success rate |
| Medium | Standard approach |
| Low (no rush) | Conservative, focus on safety only |

## Request Type Recommendations

```typescript
function recommendRequestType(repair: PrioritizedRepair): 'repair' | 'credit' | 'either' {
  // Repairs preferred for:
  if (repair.safetyHazard) return 'repair'; // Must be fixed properly
  if (repair.codeViolation) return 'repair'; // Must meet code
  if (repair.category === 'structural') return 'repair'; // Quality matters

  // Credit preferred for:
  if (repair.category === 'hvac' && repair.severity !== 'critical') return 'credit';
  if (repair.category === 'appliances') return 'credit';
  if (repair.estimatedCost.high > 5000) return 'credit'; // Buyer controls contractor

  // Either works:
  return 'either';
}
```

## Voice Response

**After prioritization:**
> "I've prioritized the 15 inspection findings into four tiers:
>
> **Must Request (3 items, $8,500-$12,000):**
> 1. Electrical panel replacement - this is a safety hazard
> 2. Roof repairs for active leaks - structural concern
> 3. Water heater replacement - at end of life with rust
>
> **Should Request (4 items, $4,000-$6,000):**
> HVAC service and potential replacement, plumbing repairs, and gutter issues.
>
> **Nice to Have (3 items, $1,500-$2,500):**
> Minor cosmetic and maintenance items.
>
> **Accept As-Is (5 items):**
> Cosmetic only, not worth negotiating.
>
> My recommendation: Request repairs for the electrical panel (safety item), then a credit of $8,000-$10,000 for remaining items. This gives you $12,000-$15,000 total, which is about 3% of purchase price - reasonable for this market.
>
> Should I share this with your client for approval?"

## Error Handling

| Error | Cause | Response |
|-------|-------|----------|
| `NO_FINDINGS` | No inspection findings to prioritize | "I need inspection findings first. Would you like me to analyze an inspection report?" |
| `ALREADY_PRIORITIZED` | Priorities already set | "These repairs were already prioritized. Would you like me to re-prioritize with different criteria?" |
| `INSPECTION_EXPIRED` | Past inspection period | "The inspection period has ended. I can still prioritize for your records, but formal requests may not be possible." |
| `BUDGET_EXCEEDED` | Requested amount > reasonable | "The total requested amount exceeds 5% of purchase price. This may face resistance. Consider reducing to strengthen position." |

## Approval Gate

**This skill requires human approval before:**
1. Sharing priorities with client
2. Proceeding to draft repair request
3. Using in negotiation strategy

**Approval Dialog:**
```
┌─────────────────────────────────────────────────────────────┐
│ APPROVAL REQUIRED: Repair Prioritization                     │
├─────────────────────────────────────────────────────────────┤
│ Prioritized 15 inspection findings for 123 Main Street:      │
│                                                              │
│ MUST REQUEST (3 items): $8,500 - $12,000                    │
│ • Electrical panel (safety hazard)                          │
│ • Roof leaks (structural)                                   │
│ • Water heater (end of life)                                │
│                                                              │
│ SHOULD REQUEST (4 items): $4,000 - $6,000                   │
│ NICE TO HAVE (3 items): $1,500 - $2,500                     │
│ ACCEPT AS-IS (5 items): $500 total                          │
│                                                              │
│ Strategy: Repairs + Credit | Strength: Moderate             │
│ Total: $14,000 - $20,500 (3.2% of purchase price)           │
│                                                              │
│ [Approve] [Adjust Priorities] [Change Strategy] [Cancel]    │
└─────────────────────────────────────────────────────────────┘
```

## Talking Points Generated

For each Must Request item, generate:
1. **Why it matters**: Safety, code, structural integrity
2. **Cost justification**: Contractor estimates, market rates
3. **Seller benefit**: Address now vs liability later
4. **Fallback position**: Credit if repair not accepted

Example:
```
Electrical Panel (FPE Stab-Lok)
├── Why: Known fire hazard, insurance companies may not cover
├── Cost: $2,500-$3,500 for replacement
├── Seller benefit: Required for any future sale anyway
└── Fallback: $3,000 credit, buyer handles replacement
```

## Integration Points

### Inputs From
- `analyze-inspection-report` - Parsed inspection findings

### Triggers After
- `calculate-repair-credit` - Calculate credit amounts
- `draft-repair-request` - Generate formal request document

### Database Tables
- `repair_priorities` - Stored prioritization
- `action_log` - Audit entry

## Florida-Specific Considerations

1. **HVAC Priority**: Florida climate makes AC critical - bump severity
2. **Roof Age**: Insurance requirements affect negotiation leverage
3. **Hurricane Straps**: If missing, should be in Must Request
4. **Pool Safety**: Florida law requirements are non-negotiable
5. **Termite/WDO**: Common in FL, may warrant separate negotiation

## Quality Checklist

- [x] Scores findings using multi-factor algorithm
- [x] Assigns to appropriate tiers consistently
- [x] Adjusts for contract type (standard vs As-Is)
- [x] Considers market conditions
- [x] Calculates totals and percentages
- [x] Generates strategic recommendations
- [x] Creates negotiation talking points
- [x] Handles Florida-specific factors
- [x] Requires approval before proceeding
- [x] Integrates with repair request workflow
- [x] Provides clear voice responses
- [x] Creates audit trail

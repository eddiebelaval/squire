# Skill: Closing Cost Negotiation

**Category:** Negotiation
**Priority:** P0
**Approval Required:** Yes (before requesting or agreeing to closing cost credits)

## Purpose

Negotiate seller contributions to buyer's closing costs (seller concessions). This skill calculates allowable credits based on loan type, structures requests strategically, and handles closing cost negotiations throughout the transaction lifecycle.

## Triggers

### Voice Commands
- "Request closing cost credit"
- "Negotiate closing costs"
- "Ask for seller concession"
- "How much closing cost credit can we get?"
- "Seller contribution to closing"
- "Help with closing costs"
- "Add closing cost credit to offer"
- "Counter with closing costs included"

### System Events
- New offer being drafted
- Buyer requests closing cost assistance
- Repair negotiation concluding (combine with credit)
- Lender preapproval shows need for seller contribution

## Required Inputs

| Input | Type | Required | Source | Description |
|-------|------|----------|--------|-------------|
| `dealId` | string | Yes | context | The deal being negotiated |
| `requestedCredit` | number | No | agent | Specific credit amount requested |

## Optional Inputs

| Input | Type | Default | Source | Description |
|-------|------|---------|--------|-------------|
| `purchasePrice` | number | deal.price | deal | Purchase price |
| `loanType` | string | deal.loanType | deal | Conventional, FHA, VA, USDA |
| `loanAmount` | number | null | deal | Loan amount |
| `downPaymentPercent` | number | null | deal | Down payment percentage |
| `estimatedClosingCosts` | number | null | lender | Lender's estimated closing costs |
| `creditPurpose` | string | 'closing_costs' | agent | Purpose for credit |
| `negotiationPhase` | string | 'initial_offer' | context | When in transaction |
| `existingCredits` | Credit[] | [] | deal | Already negotiated credits |
| `marketConditions` | string | 'balanced' | context | Market leverage assessment |

## Output Schema

```typescript
{
  success: boolean;
  actionTaken: string;
  result: {
    creditAnalysis: {
      requestedCredit: number;
      maxAllowedByLoan: number;
      currentTotalCredits: number;
      remainingAllowable: number;
      percentOfPrice: number;
      withinLimits: boolean;
    };
    lenderLimits: {
      loanType: string;
      maxConcession: number;
      maxConcessionPercent: number;
      conditions: string[];
    };
    closingCostBreakdown: {
      lenderFees: number;
      titleInsurance: number;
      prepaidItems: number;
      recordingFees: number;
      otherFees: number;
      totalEstimated: number;
    };
    negotiationStrategy: {
      recommended: string;
      askAmount: number;
      fallbackAmount: number;
      reasoning: string;
      timing: string;
    };
    existingCredits: {
      repairCredits: number;
      otherCredits: number;
      total: number;
    };
    documents: {
      type: string;
      status: string;
    }[];
    warnings: string[];
    nextSteps: string[];
  };
  requiresApproval: true;
  approvalContext: {
    action: "Request closing cost credit";
    stakes: "high";
    reversible: true;
  };
}
```

## Execution Flow

```
START
  │
  ├─── 1. Validate inputs
  │    ├── Verify deal exists
  │    ├── Load contract details
  │    ├── Get loan type and terms
  │    └── Check existing credits
  │
  ├─── 2. Calculate lender limits
  │    │
  │    ├─── Conventional
  │    │    ├── <10% down: Max 3%
  │    │    ├── 10-25% down: Max 6%
  │    │    └── >25% down: Max 9%
  │    │
  │    ├─── FHA
  │    │    └── Max 6% of purchase price
  │    │
  │    ├─── VA
  │    │    └── Max 4% (excludes normal discount points)
  │    │
  │    └─── USDA
  │         └── Max 6% of purchase price
  │
  ├─── 3. Estimate closing costs
  │    ├── Lender fees (origination, underwriting)
  │    ├── Title insurance and title fees
  │    ├── Prepaid items (taxes, insurance, interest)
  │    ├── Recording and transfer fees
  │    ├── Other fees (survey, HOA, etc.)
  │    └── Total estimated costs
  │
  ├─── 4. Calculate available credit
  │    ├── Max allowed - existing credits
  │    ├── Check if request fits
  │    └── Flag if over limit
  │
  ├─── 5. Develop negotiation strategy
  │    │
  │    ├─── Timing-based approach
  │    │    ├── Initial offer: Include upfront
  │    │    ├── Counter-offer: Add as sweetener
  │    │    ├── After inspection: Combine with repairs
  │    │    └── Near closing: Last-minute ask
  │    │
  │    ├─── Market-based approach
  │    │    ├── Buyer's market: Ask for more
  │    │    ├── Balanced: Standard request
  │    │    └── Seller's market: Minimal or none
  │    │
  │    └─── Property-based approach
  │         ├── Days on market
  │         ├── Price reductions
  │         └── Seller motivation
  │
  ├─── 6. Structure the request
  │    ├── Amount to request (ask high)
  │    ├── Fallback position
  │    ├── Minimum acceptable
  │    └── Walking point
  │
  ├─── 7. Prepare documentation
  │    ├── Addendum or offer term
  │    ├── Clear language
  │    └── Lender compliance
  │
  ├─── 8. Log action
  │    └── action_type: 'closing_cost_negotiation'
  │
  └─── 9. Present for approval
```

## Seller Concession Limits by Loan Type

### Conventional Loans

| Down Payment | Max Concession | Example ($400K home) |
|--------------|----------------|----------------------|
| < 10% | 3% | $12,000 |
| 10% - 24.99% | 6% | $24,000 |
| 25%+ | 9% | $36,000 |
| Investment Property | 2% | $8,000 |

### FHA Loans

| Scenario | Max Concession | Notes |
|----------|----------------|-------|
| All purchases | 6% | Includes closing costs |
| Streamline Refi | 6% | Same limits apply |

### VA Loans

| Category | Max Concession | What Counts |
|----------|----------------|-------------|
| Closing Costs | 4% | Seller contributions to buyer costs |
| + Discount Points | Unlimited | Normal discount points don't count |
| + Payoff of Debts | Counts toward 4% | Paying off buyer debt |

### USDA Loans

| Scenario | Max Concession |
|----------|----------------|
| All purchases | 6% |

## Closing Cost Breakdown (Florida Typical)

```typescript
interface ClosingCostEstimate {
  // Lender Fees
  originationFee: number;        // 0.5-1% of loan
  underwritingFee: number;       // $500-$1,000
  appraisalFee: number;          // $400-$700
  creditReportFee: number;       // $50-$100
  floodCertification: number;    // $15-$50

  // Title Fees
  titleInsurance: number;        // Based on purchase price
  titleSearch: number;           // $200-$400
  settlementFee: number;         // $400-$800
  endorsements: number;          // $100-$300

  // Prepaid Items
  homeownersInsurance: number;   // 12 months upfront
  propertyTaxes: number;         // Prorated
  prepaidInterest: number;       // Per diem to first payment
  escrowReserves: number;        // 2-3 months buffer

  // Government Fees
  recordingFees: number;         // $100-$500
  docStamps: number;             // Florida: $0.35/$100 on deed
  intangibleTax: number;         // Florida: 0.2% on new mortgage

  // Other
  surveyFee: number;             // $300-$500
  hoaTransferFee: number;        // $100-$500
  homeWarranty: number;          // $400-$600
}
```

## Florida-Specific Closing Cost Estimates

| Item | Typical Cost | Notes |
|------|--------------|-------|
| Documentary Stamps (Deed) | 0.70% of price | Seller typically pays |
| Documentary Stamps (Note) | 0.35% of loan | Buyer pays |
| Intangible Tax | 0.20% of loan | Buyer pays |
| Title Insurance | ~0.5% of price | Varies by county |
| Recording Fees | $100-$500 | Per document |
| Survey | $300-$500 | If required |
| HOA Estoppel Letter | $100-$500 | If HOA |

## Strategy by Negotiation Phase

### Initial Offer

**Best approach:** Include closing cost request upfront
```
"In addition to the purchase price of $XXX,XXX, Buyer requests Seller
contribute $X,XXX toward Buyer's closing costs, prepaid items, and
loan fees."
```

**Tactics:**
- Make it part of the overall offer package
- Price may be slightly higher to offset
- Seller sees full picture from start

### Counter-Offer Phase

**Best approach:** Add as negotiation lever
```
"Buyer will accept Seller's counter-price of $XXX,XXX provided Seller
contributes $X,XXX toward Buyer's closing costs."
```

**Tactics:**
- Trade credit for price concession
- "I'll pay your price if you cover my costs"
- Creates win-win perception

### Post-Inspection

**Best approach:** Combine with repair credits
```
"Rather than repairs, Buyer requests a total credit of $XX,XXX
at closing to cover repair costs, closing costs, and prepaid items."
```

**Tactics:**
- Simplifies negotiation to one number
- Easier for seller to accept
- More flexible for buyer

### Pre-Closing Issues

**Best approach:** Use as problem solver
```
"To ensure timely closing, Buyer requests Seller contribute $X,XXX
toward closing costs to address [specific issue]."
```

**Tactics:**
- Solves cash-to-close shortfalls
- Keeps deal together
- Last resort option

## Voice Response

**When analyzing options:**
> "Let me analyze your closing cost options for this $425,000 purchase:
>
> **Loan Details:**
> - FHA loan with 3.5% down payment
> - Maximum seller concession: 6% = $25,500
>
> **Estimated Closing Costs:**
> - Lender fees: $4,500
> - Title and closing: $3,200
> - Prepaid items: $5,800
> - Florida taxes/fees: $2,100
> - **Total: approximately $15,600**
>
> **My Recommendation:**
> Request $12,000 in closing cost credits. This covers most of your costs while staying well within FHA limits. We have room for additional repair credits if needed.
>
> Want me to add this to your offer?"

**When over limits:**
> "The combined credits you're requesting total $28,000, but FHA limits seller concessions to 6% of purchase price ($25,500).
>
> Options:
> 1. Reduce the request to $25,500 (within limits)
> 2. Ask for a price reduction instead of additional credit
> 3. Bring additional cash to closing
>
> Which approach would you prefer?"

## Error Handling

| Error | Cause | Response |
|-------|-------|----------|
| `OVER_LENDER_LIMIT` | Credit exceeds loan type maximum | "This credit would exceed the [loan type] maximum of [X]%. I'll need to adjust the request or structure differently." |
| `COMBINED_OVER_LIMIT` | Total credits exceed limit | "Between repair credits ($X) and closing costs ($Y), total credits exceed lender limits. We need to prioritize." |
| `INSUFFICIENT_EQUITY` | Credit impacts loan | "This credit level may affect the loan. Recommend checking with lender before requesting." |
| `CASH_BUYER` | No lender limits for cash | "Cash purchase - no lender limits on seller credits. Full flexibility on negotiation." |
| `UNKNOWN_LOAN_TYPE` | Loan type not specified | "What loan type is the buyer using? This affects how much credit we can request." |

## Approval Gate

**This skill requires human approval before:**
1. Adding closing cost request to offer
2. Requesting credit in counter-offer
3. Agreeing to seller's credit offer
4. Combining credits with repairs

**Approval Dialog:**
```
┌─────────────────────────────────────────────────────────────┐
│ APPROVAL REQUIRED: Closing Cost Credit Request               │
├─────────────────────────────────────────────────────────────┤
│ Property: 123 Main Street                                    │
│ Purchase Price: $425,000                                     │
│                                                              │
│ CREDIT REQUEST:                                              │
│ • Closing costs credit: $12,000                              │
│ • Existing repair credit: $5,000                             │
│ • Total credits: $17,000                                     │
│                                                              │
│ LENDER LIMITS (FHA 6%):                                      │
│ • Maximum allowed: $25,500                                   │
│ • Remaining available: $8,500                                │
│ • Status: ✓ Within limits                                    │
│                                                              │
│ ESTIMATED CLOSING COSTS: $15,600                             │
│ Credit covers: 77% of costs                                  │
│                                                              │
│ [Add to Offer] [Adjust Amount] [Cancel]                      │
└─────────────────────────────────────────────────────────────┘
```

## Credit Language Templates

### For Initial Offer
```
Seller shall contribute ${{amount}} toward Buyer's closing costs, prepaid
items, and loan fees at closing. This contribution shall be reflected on
the Closing Disclosure and shall be applied as permitted by Buyer's lender.
```

### For Counter-Offer
```
Buyer accepts Seller's counter-price of ${{price}} contingent upon Seller
contributing ${{amount}} toward Buyer's closing costs at closing.
```

### For Combined Repair/Closing Credit
```
In lieu of repairs, Seller shall provide Buyer with a credit at closing
in the amount of ${{totalAmount}} to be applied toward closing costs,
prepaid items, and/or repairs at Buyer's discretion, as permitted by
Buyer's lender.
```

### Lender Compliance Note
```
The above credit is subject to Buyer's lender approval and shall not
exceed the maximum seller contribution allowed under Buyer's loan program.
Any excess credit may be applied to reduce the purchase price if agreed
by the parties.
```

## Credit Stacking Rules

When multiple credits exist, verify total stays within limits:

```typescript
function validateTotalCredits(deal: Deal, newCredit: number): ValidationResult {
  const existingCredits = deal.credits.reduce((sum, c) => sum + c.amount, 0);
  const totalCredits = existingCredits + newCredit;
  const maxAllowed = calculateMaxConcession(deal);

  return {
    valid: totalCredits <= maxAllowed,
    totalCredits,
    maxAllowed,
    remaining: maxAllowed - totalCredits,
    overBy: Math.max(0, totalCredits - maxAllowed)
  };
}
```

## Integration Points

### Inputs From
- Deal record - Loan type, price, existing credits
- Lender data - Estimated closing costs
- `calculate-repair-credit` - If combining with repairs

### Triggers After
- Update offer/counter-offer document
- Notify lender of credit structure
- Update deal financials
- Track in closing cost worksheet

### Database Tables
- `credits` - All negotiated credits
- `deals` - Credit total tracking
- `action_log` - Audit trail

## Florida-Specific Considerations

1. **Documentary Stamps**: Seller typically pays on deed, buyer on note
2. **Intangible Tax**: Buyer pays 0.2% on new mortgage
3. **Title Insurance**: Rates regulated by state
4. **HOA Estoppel**: Can be significant ($100-$500+)
5. **Prorated Taxes**: Calculate based on closing date
6. **PACE Liens**: Must be satisfied or assumed

## Quality Checklist

- [x] Calculates lender limits accurately by loan type
- [x] Estimates closing costs using Florida rates
- [x] Tracks existing credits and remaining capacity
- [x] Provides strategic recommendations by phase
- [x] Generates compliant credit language
- [x] Warns when approaching/exceeding limits
- [x] Handles combined repair and closing credits
- [x] Requires approval for all credit requests
- [x] Integrates with offer/counter workflow
- [x] Creates audit trail
- [x] Handles Florida-specific costs
- [x] Considers market conditions

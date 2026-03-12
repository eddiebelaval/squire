# Skill: Appraisal Negotiation

**Category:** Negotiation
**Priority:** P0
**Approval Required:** Yes (before any action on appraisal issues)

## Purpose

Handle low appraisal situations in Florida real estate transactions. This skill guides agents through the options when a property appraises below the contract price, including renegotiation strategies, appraisal dispute processes, and deal structure alternatives.

## Triggers

### Voice Commands
- "The appraisal came in low"
- "Property appraised below contract price"
- "Handle the appraisal gap"
- "Appraisal came in at [amount]"
- "What do we do about the low appraisal?"
- "Dispute the appraisal"
- "Bridge the appraisal gap"
- "Appraisal contingency options"

### System Events
- Appraisal document uploaded
- Appraisal value entered below purchase price
- Agent marks "Appraisal Issue" on deal
- Appraisal contingency deadline approaching

## Required Inputs

| Input | Type | Required | Source | Description |
|-------|------|----------|--------|-------------|
| `dealId` | string | Yes | context | The deal with appraisal issue |
| `appraisedValue` | number | Yes | appraisal | Appraised value of property |

## Optional Inputs

| Input | Type | Default | Source | Description |
|-------|------|---------|--------|-------------|
| `purchasePrice` | number | deal.price | deal | Contract purchase price |
| `loanType` | string | deal.loanType | deal | Conventional, FHA, VA, etc. |
| `loanAmount` | number | null | deal | Loan amount |
| `downPayment` | number | null | deal | Buyer's down payment |
| `appraisalDate` | Date | null | document | Date of appraisal |
| `appraiserName` | string | null | document | Appraiser name |
| `appraisalCompany` | string | null | document | Appraisal company |
| `comparables` | Comparable[] | null | document | Comps used in appraisal |
| `representingParty` | string | context | 'buyer' | 'seller' | Which party agent represents |
| `sellerMotivation` | string | 'medium' | agent | Seller's motivation level |
| `buyerFlexibility` | string | 'medium' | agent | Buyer's cash flexibility |

## Output Schema

```typescript
{
  success: boolean;
  actionTaken: string;
  result: {
    gapAnalysis: {
      purchasePrice: number;
      appraisedValue: number;
      gap: number;
      gapPercent: number;
      ltvAtAppraised: number;
      ltvAtContract: number;
    };
    options: AppraisalOption[];
    recommendation: {
      recommended: string;
      reasoning: string;
      forBuyer: string;
      forSeller: string;
    };
    disputeViability: {
      viable: boolean;
      reasons: string[];
      additionalComps: Comparable[];
      estimatedTimeline: string;
    };
    timeline: {
      contingencyDeadline: Date;
      daysRemaining: number;
      actionDeadline: Date;
    };
    documents: {
      generated: string[];
      needed: string[];
    };
    nextSteps: string[];
  };
  requiresApproval: true;
  approvalContext: {
    action: "Proceed with appraisal negotiation";
    stakes: "high";
    reversible: "varies by option";
  };
}

interface AppraisalOption {
  id: string;
  name: string;
  description: string;
  impact: {
    buyer: string;
    seller: string;
  };
  requirements: string[];
  timeline: string;
  likelihood: 'high' | 'medium' | 'low';
  recommended: boolean;
}

interface Comparable {
  address: string;
  salePrice: number;
  saleDate: Date;
  sqft: number;
  pricePerSqft: number;
  adjustedValue?: number;
  notes?: string;
}
```

## Execution Flow

```
START
  │
  ├─── 1. Validate inputs
  │    ├── Verify deal exists
  │    ├── Load contract details
  │    ├── Verify appraisal value < purchase price
  │    └── Check appraisal contingency status
  │
  ├─── 2. Calculate gap analysis
  │    ├── Purchase price - appraised value = gap
  │    ├── Gap as percentage of price
  │    ├── LTV calculations at both values
  │    └── Impact on loan amount
  │
  ├─── 3. Assess loan implications
  │    │
  │    ├─── Conventional
  │    │    ├── Max LTV at appraised value
  │    │    ├── Additional down payment needed
  │    │    └── PMI implications
  │    │
  │    ├─── FHA
  │    │    ├── 96.5% of appraised value
  │    │    ├── Cash to close increase
  │    │    └── FHA guidelines
  │    │
  │    ├─── VA
  │    │    ├── 100% of appraised value
  │    │    ├── Buyer may need cash for gap
  │    │    └── VA reconsideration option
  │    │
  │    └─── Cash
  │         └── Appraisal is advisory only
  │
  ├─── 4. Generate options
  │    │
  │    ├─── Option A: Seller Reduces Price
  │    │    ├── Price drops to appraised value
  │    │    ├── Seller impact calculation
  │    │    └── Amendment needed
  │    │
  │    ├─── Option B: Buyer Covers Gap
  │    │    ├── Buyer pays cash difference
  │    │    ├── Additional funds needed
  │    │    └── Loan amount unchanged
  │    │
  │    ├─── Option C: Split the Gap
  │    │    ├── Both parties contribute
  │    │    ├── Various split ratios
  │    │    └── Common resolution
  │    │
  │    ├─── Option D: Dispute Appraisal
  │    │    ├── ROV (Reconsideration of Value)
  │    │    ├── Additional comps needed
  │    │    ├── Timeline considerations
  │    │    └── Success probability
  │    │
  │    ├─── Option E: Buyer Walks (Contingency)
  │    │    ├── If within contingency
  │    │    ├── Deposit returned
  │    │    └── Deal terminated
  │    │
  │    └─── Option F: Second Appraisal
  │         ├── New appraisal ordered
  │         ├── Additional cost
  │         └── Timeline impact
  │
  ├─── 5. Evaluate dispute viability
  │    ├── Review comparables used
  │    ├── Search for better comps
  │    ├── Identify appraisal errors
  │    └── Estimate success probability
  │
  ├─── 6. Make recommendation
  │    ├── Based on gap size
  │    ├── Based on party motivation
  │    ├── Based on market conditions
  │    └── Based on timeline
  │
  ├─── 7. Check timeline
  │    ├── Appraisal contingency deadline
  │    ├── Days to closing
  │    └── Action deadlines
  │
  ├─── 8. Prepare documents
  │    ├── Amendment drafts
  │    ├── ROV request template
  │    └── Cancellation notice (if needed)
  │
  ├─── 9. Log action
  │    └── action_type: 'appraisal_negotiation_started'
  │
  └─── 10. Present options for approval
```

## Options Detailed

### Option A: Seller Reduces Price to Appraised Value

**Best for:** Motivated sellers, buyer's market, small gaps

```typescript
{
  name: "Price Reduction",
  sellerImpact: gap, // Full gap
  buyerImpact: 0,
  requirements: [
    "Seller agreement",
    "Contract amendment",
    "Lender notification"
  ],
  likelihood: gap < 0.03 * purchasePrice ? "high" : "medium"
}
```

### Option B: Buyer Covers Gap in Cash

**Best for:** Highly motivated buyers, seller's market, buyer has cash

```typescript
{
  name: "Buyer Gap Coverage",
  sellerImpact: 0,
  buyerImpact: gap, // Full gap as additional down payment
  requirements: [
    "Buyer cash availability",
    "Lender approval of funds source",
    "May affect LTV"
  ],
  likelihood: "medium"
}
```

### Option C: Split the Difference

**Best for:** Both parties motivated, moderate gaps

Common splits:
- 50/50: Each party covers half
- 60/40: Party with more leverage pays less
- Seller credit + buyer cash combination

```typescript
function calculateSplitOptions(gap: number, sellerMotivation: string, buyerMotivation: string) {
  const options = [];

  // 50/50 split
  options.push({
    split: "50/50",
    sellerContribution: gap / 2,
    buyerContribution: gap / 2
  });

  // Seller-heavy (if motivated)
  if (sellerMotivation === 'high') {
    options.push({
      split: "70/30",
      sellerContribution: gap * 0.7,
      buyerContribution: gap * 0.3
    });
  }

  // Buyer-heavy (if motivated)
  if (buyerMotivation === 'high') {
    options.push({
      split: "30/70",
      sellerContribution: gap * 0.3,
      buyerContribution: gap * 0.7
    });
  }

  return options;
}
```

### Option D: Dispute Appraisal (Reconsideration of Value)

**When viable:**
- Appraiser missed relevant comps
- Obvious errors in report
- Recent sales not included
- Incorrect adjustments

**Process:**
1. Gather supporting data (3-6 better comps)
2. Document errors or omissions
3. Submit ROV request through lender
4. Wait 3-7 days for response
5. May or may not change value

```typescript
interface ROVRequest {
  appraisalId: string;
  requestDate: Date;
  issuesIdentified: string[];
  additionalComparables: Comparable[];
  rebuttalArguments: string[];
  requestedValue: number;
  supportingDocuments: string[];
}
```

### Option E: Buyer Cancellation (Using Contingency)

**Requirements:**
- Within appraisal contingency period
- Written notice to seller
- Deposit return process

**Implications:**
- Deal terminated
- Buyer gets deposit back
- Seller back on market

### Option F: Second Appraisal

**When to consider:**
- Clear errors in first appraisal
- Willing to pay for new appraisal ($400-$600)
- Time allows (7-14 days)

**Risks:**
- Could come in same or lower
- Additional cost
- Timeline pressure

## Loan Type Implications

### Conventional Loans

| Gap Size | Impact | Options |
|----------|--------|---------|
| 0-3% | Minor | All options viable |
| 3-5% | Moderate | Split or dispute likely |
| 5%+ | Significant | Price reduction or walk |

### FHA Loans

- Appraisal "sticks" to property for 120 days
- If buyer walks, next FHA buyer sees same value
- Consider VA or conventional if possible
- Seller has strong incentive to negotiate

### VA Loans

- Buyer cannot pay above appraised value (VA rule)
- Seller MUST reduce price or buyer must walk
- Reconsideration process available
- Strong buyer protection

## Voice Response

**When appraisal gap is identified:**
> "The appraisal came in at $435,000, which is $15,000 below the contract price of $450,000. That's a 3.3% gap. Let me walk you through your options:
>
> **For your buyer:**
>
> 1. **Ask seller to reduce price to $435,000** - This keeps your buyer's down payment the same. Seller takes the full hit.
>
> 2. **Buyer covers the gap** - Your buyer would need an additional $15,000 cash. Their total down payment goes from $45,000 to $60,000.
>
> 3. **Split it 50/50** - Seller reduces price by $7,500, buyer brings $7,500 more cash.
>
> 4. **Dispute the appraisal** - I found 2 recent sales the appraiser missed that support a higher value. This takes 5-7 days.
>
> 5. **Cancel under contingency** - Your buyer can walk and get their deposit back. Deadline is January 25th.
>
> Given that your buyer is a strong buyer and the seller has been on market 45 days, I'd recommend starting with a request for seller to cover the full gap, with fallback to 60/40 split.
>
> Which option would you like to pursue?"

**When recommending dispute:**
> "I think we have a strong case to dispute this appraisal. The appraiser used comps from 6 months ago and missed two recent sales within a quarter mile that sold for $450K and $455K.
>
> I can help you prepare a Reconsideration of Value (ROV) request. This typically takes 5-7 days. The success rate for well-documented ROVs is about 40%.
>
> Should I prepare the ROV documentation?"

## Error Handling

| Error | Cause | Response |
|-------|-------|----------|
| `NO_CONTINGENCY` | Appraisal contingency waived | "There's no appraisal contingency. Buyer may be obligated to proceed. Options are limited to negotiation or legal review." |
| `CONTINGENCY_EXPIRED` | Past contingency deadline | "The appraisal contingency has expired. Buyer may have lost right to cancel. Recommend negotiation or legal consultation." |
| `VA_LIMITATION` | VA buyer cannot pay over appraised | "VA rules prohibit buyer from paying above appraised value. Seller must reduce price for deal to proceed." |
| `FHA_STICKY` | FHA appraisal on file | "This FHA appraisal will stay with the property for 120 days. Important for seller to consider before rejecting buyer." |
| `INSUFFICIENT_COMPS` | Can't find better comps | "I couldn't find better comparable sales to support a dispute. The appraisal may be accurate." |

## Approval Gate

**This skill requires human approval before:**
1. Initiating any appraisal negotiation
2. Submitting ROV request
3. Agreeing to gap resolution
4. Canceling under contingency

**Approval Dialog:**
```
┌─────────────────────────────────────────────────────────────┐
│ APPROVAL REQUIRED: Appraisal Negotiation                     │
├─────────────────────────────────────────────────────────────┤
│ Property: 123 Main Street                                    │
│                                                              │
│ GAP ANALYSIS:                                                │
│ • Contract Price: $450,000                                   │
│ • Appraised Value: $435,000                                  │
│ • Gap: $15,000 (3.3%)                                        │
│                                                              │
│ RECOMMENDED ACTION: Request seller price reduction           │
│                                                              │
│ TIMELINE:                                                    │
│ • Contingency expires: Jan 25, 2026 (5 days)                │
│ • Closing date: Feb 15, 2026                                │
│                                                              │
│ [Proceed with Negotiation] [Prepare ROV] [Cancel Deal]      │
└─────────────────────────────────────────────────────────────┘
```

## ROV Request Template

```
RECONSIDERATION OF VALUE REQUEST

Date: {{currentDate}}
Property: {{propertyAddress}}
Appraisal Date: {{appraisalDate}}
Appraised Value: ${{appraisedValue}}
Contract Price: ${{contractPrice}}

We respectfully request reconsideration of value based on the following:

ISSUES IDENTIFIED:
{{#each issues}}
{{@index + 1}}. {{this}}
{{/each}}

ADDITIONAL COMPARABLE SALES:

{{#each additionalComps}}
{{@index + 1}}. {{this.address}}
   Sale Price: ${{this.salePrice}}
   Sale Date: {{this.saleDate}}
   Size: {{this.sqft}} sq ft
   $/Sq Ft: ${{this.pricePerSqft}}
   Relevance: {{this.notes}}

{{/each}}

REQUESTED VALUE: ${{requestedValue}}

SUPPORTING DOCUMENTATION ATTACHED:
- MLS sheets for additional comparables
- Photos showing subject property condition
- Other: {{otherDocs}}

Submitted by:
{{agentName}}
{{agentBrokerage}}
{{agentPhone}}
```

## Integration Points

### Inputs From
- Deal record - Contract terms, parties
- Appraisal document - Values and comps
- MLS data - Additional comparables

### Triggers After
- Contract amendment generation
- ROV submission workflow
- Cancellation notice if exercising contingency
- Timeline adjustments

### Database Tables
- `appraisals` - Appraisal records
- `negotiations` - Negotiation history
- `documents` - Amendments and notices
- `action_log` - Audit trail

## Florida-Specific Considerations

1. **FAR/BAR Appraisal Contingency**: Standard paragraph for contingency
2. **FHA Case Number Transfer**: If buyer switches, may get new appraisal
3. **Homestead Exemption**: Doesn't affect appraisal
4. **Flood Zone**: May impact appraised value
5. **Hurricane Damage**: Recent damage affects value

## Quality Checklist

- [x] Calculates gap and impact accurately
- [x] Presents all viable options
- [x] Handles different loan types correctly
- [x] Assesses dispute viability
- [x] Finds additional comparables
- [x] Tracks contingency deadlines
- [x] Generates ROV documentation
- [x] Generates contract amendments
- [x] Provides clear recommendations
- [x] Requires approval for all actions
- [x] Handles VA/FHA special rules
- [x] Creates audit trail

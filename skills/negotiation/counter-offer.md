# Skill: Counter-Offer

**Category:** Negotiation
**Priority:** P0
**Approval Required:** Yes (party making counter-offer must approve)

## Purpose

Generate strategic counter-offers for various negotiation scenarios including repair requests, price negotiations, closing date changes, and other contract amendments. This skill analyzes the current negotiation position, recommends counter-offer strategies, and creates the formal counter-offer document.

## Triggers

### Voice Commands
- "Counter their offer"
- "Make a counter-offer"
- "Counter with [amount/terms]"
- "Propose a counter"
- "Respond with a counter-offer"
- "Split the difference"
- "What counter should we make?"

### System Events
- Offer/counter-offer received
- Repair request response needed
- Agent clicks "Counter" on received offer
- Negotiation timeout approaching

## Required Inputs

| Input | Type | Required | Source | Description |
|-------|------|----------|--------|-------------|
| `dealId` | string | Yes | context | The deal being negotiated |
| `counterType` | string | Yes | agent | Type of counter-offer (see types below) |
| `originalOfferId` | string | Yes | document | The offer being countered |

## Optional Inputs

| Input | Type | Default | Source | Description |
|-------|------|---------|--------|-------------|
| `proposedTerms` | object | null | agent | Specific terms to propose |
| `strategy` | string | 'balanced' | agent | 'aggressive' | 'balanced' | 'conservative' |
| `walkAwayPoint` | number/terms | null | agent | Point at which to recommend walking away |
| `expirationHours` | number | 24 | agent | Hours until counter expires |
| `includeEscalation` | boolean | false | agent | Include escalation clause |
| `multipleCounters` | boolean | false | agent | Allow multiple counter scenarios |

## Counter-Offer Types

| Type | Context | Common Scenarios |
|------|---------|------------------|
| `repair_response` | Responding to repair request | Credit vs repairs, reduced scope |
| `repair_request_counter` | Buyer countering seller's repair response | Increased credit, additional items |
| `price` | Price negotiation | Purchase price adjustment |
| `closing_date` | Timeline negotiation | Moving closing earlier/later |
| `closing_costs` | Cost allocation | Seller contribution to costs |
| `appraisal_gap` | Low appraisal | Price reduction, gap coverage |
| `earnest_money` | Deposit negotiation | Increased/decreased deposit |
| `contingency` | Contingency terms | Timeline, conditions |
| `general` | Multiple terms | Combined counter |

## Output Schema

```typescript
{
  success: boolean;
  actionTaken: string;
  result: {
    document: {
      id: string;
      name: string;
      type: 'counter_offer';
      pdfUrl: string;
      status: string;
      version: number;
    };
    counterOffer: {
      type: string;
      originalTerms: object;
      proposedTerms: object;
      delta: {
        priceChange?: number;
        creditChange?: number;
        dateChange?: number; // days
        otherChanges?: string[];
      };
      expirationDate: Date;
      counterNumber: number; // 1, 2, 3, etc.
    };
    analysis: {
      negotiationPosition: 'strong' | 'moderate' | 'weak';
      likelyAcceptance: number; // 0-100%
      recommendedNextMove: string;
      fallbackOptions: string[];
      walkAwayRecommendation: boolean;
      marketContext: string;
    };
    history: CounterHistory[];
    nextSteps: string[];
  };
  requiresApproval: true;
  approvalContext: {
    action: "Send counter-offer";
    stakes: "high";
    reversible: false;
  };
}

interface CounterHistory {
  round: number;
  party: 'buyer' | 'seller';
  type: string;
  proposedValue: any;
  date: Date;
  status: 'accepted' | 'countered' | 'rejected' | 'expired';
}
```

## Execution Flow

```
START
  │
  ├─── 1. Validate inputs
  │    ├── Verify deal exists
  │    ├── Load original offer/request
  │    ├── Verify user is appropriate party
  │    └── Check for existing counter-offers
  │
  ├─── 2. Analyze negotiation state
  │    ├── Count negotiation rounds
  │    ├── Track offer history
  │    ├── Calculate concession patterns
  │    └── Identify negotiation gaps
  │
  ├─── 3. Assess negotiation leverage
  │    │
  │    ├─── Buyer factors
  │    │    ├── Financing status
  │    │    ├── Contingencies remaining
  │    │    ├── Days to close
  │    │    └── Backup options
  │    │
  │    └─── Seller factors
  │         ├── Days on market
  │         ├── Motivation level
  │         ├── Other offers
  │         └── Carrying costs
  │
  ├─── 4. Generate counter strategies
  │    │
  │    ├─── Strategy A: Split the Difference
  │    │    ├── Calculate midpoint
  │    │    ├── Adjust for leverage
  │    │    └── Present as fair compromise
  │    │
  │    ├─── Strategy B: Minor Concession
  │    │    ├── Move 10-20% toward other party
  │    │    ├── Hold on key items
  │    │    └── Signal firmness
  │    │
  │    ├─── Strategy C: Package Deal
  │    │    ├── Combine concessions
  │    │    ├── Trade-offs (give X, get Y)
  │    │    └── Creative solutions
  │    │
  │    └─── Strategy D: Final Offer
  │         ├── Last best offer
  │         ├── Clear deadline
  │         └── Escalation to principals
  │
  ├─── 5. If agent specifies strategy:
  │    ├── Apply selected approach
  │    ├── Calculate specific terms
  │    └── Generate language
  │
  ├─── 6. Generate counter-offer document
  │    ├── Reference original offer
  │    ├── Clear statement of changes
  │    ├── All other terms remain
  │    ├── Expiration date/time
  │    └── Signature blocks
  │
  ├─── 7. Calculate acceptance likelihood
  │    ├── Based on history
  │    ├── Market factors
  │    └── Negotiation dynamics
  │
  ├─── 8. Log action
  │    └── action_type: 'counter_offer_drafted'
  │
  └─── 9. Present for approval
```

## Counter-Offer Strategies

### Split the Difference

```typescript
function splitTheDifference(
  currentOffer: number,
  lastCounter: number,
  leverage: 'strong' | 'balanced' | 'weak'
): number {
  const midpoint = (currentOffer + lastCounter) / 2;

  // Adjust based on leverage
  const adjustment = {
    strong: 0.1,    // 10% favorable
    balanced: 0,    // True midpoint
    weak: -0.1      // 10% unfavorable
  };

  const delta = lastCounter - currentOffer;
  return midpoint + (delta * adjustment[leverage]);
}
```

**When to use:**
- Negotiation stalled
- Both parties have moved
- Need to signal willingness to close

### Minor Concession

```typescript
function minorConcession(
  currentPosition: number,
  otherPartyPosition: number,
  concessionPercent: number = 0.15
): number {
  const gap = otherPartyPosition - currentPosition;
  return currentPosition + (gap * concessionPercent);
}
```

**When to use:**
- Strong negotiating position
- Testing other party's flexibility
- Preserving room for further negotiation

### Package Deal

Combine multiple concessions:
- "We'll accept the credit amount if closing moves to [date]"
- "We'll do the repairs if buyer waives [contingency]"
- "We'll reduce price by $X if earnest money increases to $Y"

**When to use:**
- Multiple negotiation points
- Creating win-win scenarios
- Breaking a deadlock

### Final Offer

Signal this is the last offer:
- Clear "final offer" language
- Short expiration (24 hours)
- Prepare for acceptance or walk-away

**When to use:**
- Extended negotiation (3+ rounds)
- Approaching deadlines
- Clear walk-away point reached

## Counter-Offer Document Template

```
COUNTER-OFFER #{{counterNumber}}

Date: {{currentDate | formatDate}}
Property: {{deal.address.full}}
Original Contract Date: {{deal.effectiveDate | formatDate}}

This Counter-Offer is made by:
☐ Buyer(s)  ☑ Seller(s)

in response to:
☐ Original Offer
☑ Counter-Offer #{{previousCounter}} dated {{previousDate}}

================================================================================
PROPOSED CHANGES
================================================================================

{{#if proposedTerms.price}}
PURCHASE PRICE:
Original: ${{originalTerms.price | currency}}
Proposed: ${{proposedTerms.price | currency}}
Change: {{#if delta.priceChange > 0}}+{{/if}}${{delta.priceChange | currency}}
{{/if}}

{{#if proposedTerms.credit}}
SELLER CREDIT:
Original: ${{originalTerms.credit | currency}}
Proposed: ${{proposedTerms.credit | currency}}
Change: {{#if delta.creditChange > 0}}+{{/if}}${{delta.creditChange | currency}}
{{/if}}

{{#if proposedTerms.closingDate}}
CLOSING DATE:
Original: {{originalTerms.closingDate | formatDate}}
Proposed: {{proposedTerms.closingDate | formatDate}}
{{/if}}

{{#if proposedTerms.repairs}}
REPAIRS:
{{#each proposedTerms.repairs}}
- {{this.item}}: {{this.action}}
{{/each}}
{{/if}}

{{#if proposedTerms.otherTerms}}
OTHER TERMS:
{{proposedTerms.otherTerms}}
{{/if}}

================================================================================
TERMS
================================================================================

All other terms and conditions of the Contract remain unchanged and in
full force and effect.

{{#if escalationClause}}
ESCALATION: [Escalation terms if included]
{{/if}}

================================================================================
EXPIRATION
================================================================================

This Counter-Offer shall expire on:

{{expirationDate | formatDate}} at {{expirationTime}} local time

If not accepted by this deadline, this Counter-Offer is automatically
withdrawn and the parties have no further obligation under it.

================================================================================
ACCEPTANCE
================================================================================

To accept this Counter-Offer, the other party must sign below and deliver
a copy to the offering party before the expiration deadline.

================================================================================
SIGNATURES
================================================================================

OFFERING PARTY:

_________________________________    Date: ____________
{{offeringParty.name}}

ACCEPTING PARTY:

_________________________________    Date: ____________
{{acceptingParty.name}}
```

## Voice Response

**When analyzing options:**
> "Let me analyze the negotiation so far:
>
> **Round 1:** Buyer offered $445,000, you countered at $455,000
> **Round 2:** Buyer countered at $448,000
>
> The gap is now $7,000. Based on the buyer's pattern, they're moving about 50% each round. Here are your options:
>
> **Option A: Split the Difference - $451,500**
> This is fair and likely to be accepted (75% probability).
>
> **Option B: Minor Concession - $453,000**
> Move down $2,000, signal firmness. May require another round.
>
> **Option C: Final Offer - $452,000**
> Clear deadline, take it or leave it. Could end negotiation either way.
>
> What approach would you like to take?"

**When draft is ready:**
> "I've drafted Counter-Offer #3 with a proposed price of $451,500 and a 24-hour expiration.
>
> This splits the difference and includes language about all other terms remaining. Based on the negotiation history, I estimate a 75% chance of acceptance.
>
> Ready to send to your client for signature?"

## Error Handling

| Error | Cause | Response |
|-------|-------|----------|
| `EXPIRED_OFFER` | Original offer has expired | "The offer you're countering has expired. Would you like to make a fresh offer instead?" |
| `ALREADY_COUNTERED` | Counter already sent for this offer | "You've already countered this offer. The ball is in the other party's court." |
| `BELOW_WALKAWAY` | Proposed counter below walk-away point | "This counter is below your walk-away point of $X. Are you sure you want to proceed?" |
| `TOO_MANY_ROUNDS` | Extended negotiation (5+ rounds) | "This is counter #5. Consider a 'final offer' approach or escalating to principals." |
| `TERMS_UNCLEAR` | Counter terms not specified | "What specific terms would you like to propose in this counter-offer?" |

## Approval Gate

**This skill requires human approval before:**
1. Sending any counter-offer
2. Committing to terms
3. Setting expiration deadline

**Approval Dialog:**
```
┌─────────────────────────────────────────────────────────────┐
│ APPROVAL REQUIRED: Counter-Offer #3                          │
├─────────────────────────────────────────────────────────────┤
│ Property: 123 Main Street                                    │
│                                                              │
│ PROPOSED TERMS:                                              │
│ Purchase Price: $451,500 (was $448,000)                     │
│ Change: +$3,500 (split the difference)                       │
│                                                              │
│ NEGOTIATION HISTORY:                                         │
│ Round 1: Buyer $445K → Seller $455K                         │
│ Round 2: Buyer $448K → THIS COUNTER                         │
│                                                              │
│ ANALYSIS:                                                    │
│ • Estimated acceptance: 75%                                  │
│ • Position: Balanced                                         │
│ • Walk-away point: Not reached                              │
│                                                              │
│ Expires: Jan 20, 2026 at 5:00 PM (24 hours)                 │
│                                                              │
│ [Send to Client] [Adjust Terms] [Cancel]                    │
└─────────────────────────────────────────────────────────────┘
```

## Negotiation Tracking

Track full negotiation history:

```typescript
interface NegotiationTracker {
  dealId: string;
  negotiationType: string; // price, repairs, etc.
  rounds: NegotiationRound[];
  currentStatus: 'pending' | 'accepted' | 'rejected' | 'expired';
  totalConcessionBuyer: number;
  totalConcessionSeller: number;
  daysInNegotiation: number;
}

interface NegotiationRound {
  round: number;
  party: 'buyer' | 'seller';
  offeredValue: any;
  date: Date;
  expiration: Date;
  response: 'countered' | 'accepted' | 'rejected' | 'expired';
  responseDate?: Date;
}
```

## Escalation Clause Support

For price counter-offers, optionally include escalation:

```
ESCALATION CLAUSE:

Buyer agrees to increase the offer by ${{escalationIncrement}} above any
competing offer, up to a maximum of ${{escalationMax}}.

To activate escalation, Seller must provide a copy of the competing
offer within {{escalationNoticeHours}} hours of acceptance.
```

## Integration Points

### Inputs From
- Original offers/counter-offers
- `respond-to-repair-request` - For repair counter-offers
- Deal record - Party info, contract terms
- Market data - Context for recommendations

### Triggers After
- Send to other party's agent
- Update negotiation timeline
- Create expiration deadline tracking
- If accepted: Update deal terms
- If expired/rejected: Recommend next steps

### Database Tables
- `documents` - Counter-offer document
- `counter_offers` - Counter-offer details
- `negotiations` - Full negotiation history
- `action_log` - Audit entry

## Florida-Specific Considerations

1. **Time is of Essence**: Standard FL contract provision applies
2. **Counter-Offer Creates New Offer**: Original offer is terminated
3. **Earnest Money**: May need adjustment if price changes significantly
4. **Inspection Period**: Cannot extend via counter-offer (separate addendum)
5. **Financing Contingency**: May be affected by price changes

## Quality Checklist

- [x] Supports all negotiation types
- [x] Analyzes negotiation history
- [x] Provides multiple strategy options
- [x] Calculates acceptance probability
- [x] Generates compliant counter-offer document
- [x] Tracks all negotiation rounds
- [x] Sets appropriate expiration
- [x] Supports escalation clauses
- [x] Requires approval before sending
- [x] Integrates with deal timeline
- [x] Creates audit trail
- [x] Handles Florida contract requirements

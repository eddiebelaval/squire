# Skill: Respond to Repair Request

**Category:** Negotiation
**Priority:** P0
**Approval Required:** Yes (seller must approve before sending response)

## Purpose

Help listing agents guide sellers through responding to buyer repair requests. This skill analyzes the repair request, evaluates options, generates response recommendations, and creates the formal response document. Supports full acceptance, partial acceptance, counter-offers, and rejection.

## Triggers

### Voice Commands
- "Respond to the repair request"
- "Help me answer this repair request"
- "What should my seller do about these repairs?"
- "Accept the repair request"
- "Counter the repair request"
- "Reject the repair request"
- "Seller's response to repairs"

### System Events
- Repair request received for seller's deal
- Response deadline approaching (remind listing agent)
- Agent selects "Respond" on repair request

## Required Inputs

| Input | Type | Required | Source | Description |
|-------|------|----------|--------|-------------|
| `dealId` | string | Yes | context | The deal being negotiated |
| `repairRequestId` | string | Yes | document | The repair request to respond to |

## Optional Inputs

| Input | Type | Default | Source | Description |
|-------|------|---------|--------|-------------|
| `responseType` | string | null | agent | 'accept_all' | 'accept_partial' | 'counter' | 'reject' |
| `acceptedItems` | string[] | null | agent | IDs of accepted repair items |
| `rejectedItems` | string[] | null | agent | IDs of rejected items with reasons |
| `counterOffer` | CounterOffer | null | agent | Counter-proposal details |
| `sellerComments` | string | null | agent | Seller's comments/explanation |
| `responseDeadline` | Date | null | agent | Deadline for buyer to respond to counter |

## Output Schema

```typescript
{
  success: boolean;
  actionTaken: string;
  result: {
    document: {
      id: string;
      name: string;
      type: 'seller_repair_response';
      pdfUrl: string;
      status: string;
    };
    response: {
      type: 'accept_all' | 'accept_partial' | 'counter' | 'reject';
      acceptedItems: AcceptedItem[];
      rejectedItems: RejectedItem[];
      counterOffer?: CounterOffer;
      totalAcceptedValue: number;
      totalRejectedValue: number;
      counterValue?: number;
    };
    analysis: {
      originalRequest: {
        totalItems: number;
        totalValue: number;
      };
      responseImpact: {
        acceptedPercent: number;
        sellerCostExposure: number;
        negotiationRoom: number;
      };
      recommendation: string;
      risks: string[];
    };
    docusign?: {
      envelopeId: string;
      signers: Signer[];
    };
    nextSteps: string[];
    deadlines: Deadline[];
  };
  requiresApproval: true;
  approvalContext: {
    action: "Send seller's repair response to buyer";
    stakes: "high";
    reversible: false;
  };
}

interface AcceptedItem {
  itemId: string;
  item: string;
  commitment: 'will_repair' | 'credit_instead' | 'before_closing' | 'at_closing';
  estimatedCost: number;
  contractor?: string;
  notes?: string;
}

interface RejectedItem {
  itemId: string;
  item: string;
  reason: string;
  alternativeOffered?: string;
}

interface CounterOffer {
  type: 'reduced_repairs' | 'reduced_credit' | 'combination' | 'as_is_price_reduction';
  proposedRepairs?: RepairItem[];
  proposedCredit?: number;
  priceReduction?: number;
  conditions?: string[];
  expirationHours: number;
}
```

## Execution Flow

```
START
  │
  ├─── 1. Validate inputs
  │    ├── Verify deal exists and user is listing agent
  │    ├── Load repair request document
  │    ├── Check response deadline
  │    └── Verify response not already sent
  │
  ├─── 2. Analyze repair request
  │    ├── Parse all requested items
  │    ├── Calculate total requested value
  │    ├── Categorize by type (repairs vs credit)
  │    └── Identify priority levels
  │
  ├─── 3. Generate response options
  │    │
  │    ├─── Option A: Accept All
  │    │    ├── Cost to seller
  │    │    ├── Timeline requirements
  │    │    └── Contractor considerations
  │    │
  │    ├─── Option B: Accept Partial
  │    │    ├── Recommended accepts (safety/code)
  │    │    ├── Recommended rejects (cosmetic)
  │    │    └── Resulting cost savings
  │    │
  │    ├─── Option C: Counter Offer
  │    │    ├── Reduced repairs list
  │    │    ├── Reduced credit amount
  │    │    ├── Alternative proposals
  │    │    └── Split-the-difference options
  │    │
  │    └─── Option D: Reject All
  │         ├── Risks (buyer may cancel)
  │         ├── Contract implications
  │         └── Market considerations
  │
  ├─── 4. If agent selects response type:
  │    │
  │    ├─── 4a. Accept All
  │    │    ├── Confirm all items
  │    │    ├── Set completion timeline
  │    │    └── Identify contractor needs
  │    │
  │    ├─── 4b. Accept Partial
  │    │    ├── Mark accepted items
  │    │    ├── Get rejection reasons
  │    │    └── Calculate adjusted value
  │    │
  │    ├─── 4c. Counter Offer
  │    │    ├── Define counter terms
  │    │    ├── Set expiration
  │    │    └── Prepare negotiation notes
  │    │
  │    └─── 4d. Reject All
  │         ├── Confirm understanding of risk
  │         ├── Prepare response language
  │         └── Suggest cancellation prep
  │
  ├─── 5. Generate response document
  │    ├── Apply seller response template
  │    ├── Include all accepted/rejected items
  │    ├── Add counter-offer terms if applicable
  │    └── Set buyer response deadline
  │
  ├─── 6. Calculate impact analysis
  │    ├── Total seller cost exposure
  │    ├── Comparison to original request
  │    ├── Net proceeds impact
  │    └── Risk assessment
  │
  ├─── 7. Generate PDF
  │    ├── Professional formatting
  │    └── Signature blocks
  │
  ├─── 8. Log action
  │    └── action_type: 'repair_response_drafted'
  │
  └─── 9. Present for seller approval
```

## Response Type Analysis

### Accept All
**When to recommend:**
- Total request is < 2% of purchase price
- All items are legitimate safety/code issues
- Strong buyer's market
- Seller is motivated to close

**Implications:**
- Seller commits to completing repairs before closing
- Must use licensed contractors where required
- Provides receipts to buyer
- Fastest path to closing

### Accept Partial
**When to recommend:**
- Some items are legitimate, others are excessive
- Seller willing to address major items
- Room for compromise

**Best practices:**
- Accept safety/code items (non-negotiable)
- Accept major system items (shows good faith)
- Reject cosmetic/optional items
- Provide reasoning for rejections

### Counter Offer
**When to recommend:**
- Request is excessive (> 4% of purchase price)
- Seller has limited funds for repairs
- Some items disputable
- Room for negotiation exists

**Counter strategies:**
1. **Reduced repairs**: Accept critical, reject minor
2. **Credit instead of repairs**: More flexible for buyer
3. **Price reduction**: Instead of credit (rare)
4. **Split the difference**: Meet halfway on costs

### Reject All
**When to recommend:**
- As-Is contract with no obligation
- Request is unreasonable
- Seller willing to risk buyer cancellation
- Other backup offers exist

**Risks:**
- Buyer may exercise cancellation right
- Back to market with inspection stigma
- Delay in sale timeline

## Response Document Template

```
SELLER'S RESPONSE TO BUYER'S REPAIR REQUEST

Date: {{currentDate | formatDate}}
Property Address: {{deal.address.full}}
Contract Date: {{deal.effectiveDate | formatDate}}

In response to Buyer's Inspection Response/Repair Request dated
{{repairRequest.date | formatDate}}, Seller responds as follows:

================================================================================
SELLER'S ELECTION
================================================================================

{{#if responseType === 'accept_all'}}
☑ Seller ACCEPTS all items in Buyer's repair request
☐ Seller accepts SOME items (see below)
☐ Seller makes a COUNTER-OFFER
☐ Seller REJECTS all items
{{/if}}

{{#if responseType === 'accept_partial'}}
☐ Seller ACCEPTS all items in Buyer's repair request
☑ Seller accepts SOME items (see below)
☐ Seller makes a COUNTER-OFFER
☐ Seller REJECTS all items
{{/if}}

{{#if responseType === 'counter'}}
☐ Seller ACCEPTS all items in Buyer's repair request
☐ Seller accepts SOME items (see below)
☑ Seller makes a COUNTER-OFFER
☐ Seller REJECTS all items
{{/if}}

{{#if responseType === 'reject'}}
☐ Seller ACCEPTS all items in Buyer's repair request
☐ Seller accepts SOME items (see below)
☐ Seller makes a COUNTER-OFFER
☑ Seller REJECTS all items
{{/if}}

{{#if acceptedItems.length > 0}}
================================================================================
ACCEPTED ITEMS
================================================================================

Seller agrees to address the following items prior to closing:

{{#each acceptedItems}}
{{@index + 1}}. {{this.item}}
   Commitment: {{this.commitment}}
   {{#if this.notes}}Notes: {{this.notes}}{{/if}}

{{/each}}

Seller shall complete all repairs in a workmanlike manner using licensed
and insured contractors where required by Florida law. Seller shall
provide Buyer with copies of paid receipts and/or lien waivers.
{{/if}}

{{#if rejectedItems.length > 0}}
================================================================================
REJECTED ITEMS
================================================================================

Seller does not agree to address the following items:

{{#each rejectedItems}}
{{@index + 1}}. {{this.item}}
   Reason: {{this.reason}}
   {{#if this.alternativeOffered}}Alternative: {{this.alternativeOffered}}{{/if}}

{{/each}}
{{/if}}

{{#if counterOffer}}
================================================================================
COUNTER-OFFER
================================================================================

Seller makes the following counter-proposal:

{{#if counterOffer.proposedCredit}}
Credit at Closing: ${{counterOffer.proposedCredit | currency}}
{{/if}}

{{#if counterOffer.proposedRepairs}}
Seller will complete the following repairs only:
{{#each counterOffer.proposedRepairs}}
- {{this.item}}
{{/each}}
{{/if}}

{{#if counterOffer.conditions}}
Conditions:
{{#each counterOffer.conditions}}
- {{this}}
{{/each}}
{{/if}}

This counter-offer expires on {{counterOffer.expiration | formatDate}} at
5:00 PM local time. If Buyer does not accept by this deadline, Seller's
counter-offer is withdrawn.
{{/if}}

{{#if sellerComments}}
================================================================================
ADDITIONAL COMMENTS
================================================================================

{{sellerComments}}
{{/if}}

================================================================================
SIGNATURES
================================================================================

SELLER:

_________________________________    Date: ____________
{{sellers.[0].name}}

{{#if sellers.[1]}}
_________________________________    Date: ____________
{{sellers.[1].name}}
{{/if}}
```

## Voice Response

**When presenting options:**
> "The buyer has submitted a repair request with 7 items totaling $14,500. Let me walk you through your options:
>
> **Option 1: Accept All** - Cost: $14,500
> This is the fastest path to closing. The items are mostly legitimate - electrical panel, roof repairs, water heater.
>
> **Option 2: Accept Partial** - Recommended cost: $9,500
> Accept the safety items (electrical, roof) but reject the cosmetic items. This shows good faith while saving $5,000.
>
> **Option 3: Counter Offer** - Suggested: $10,000 credit
> Offer a credit instead of repairs. Gives buyer flexibility and caps your exposure.
>
> **Option 4: Reject All** - Risk: Buyer may cancel
> Only recommend this if you have backup offers or are willing to lose this buyer.
>
> What would your seller like to do?"

**After response is drafted:**
> "I've drafted the seller's response accepting 4 items and offering a $2,500 credit instead of the remaining repairs. Total seller cost: $11,000.
>
> The buyer has until January 28th to accept this counter-offer. If they reject, we can negotiate further or prepare for potential cancellation.
>
> Ready to send this to your seller for signature?"

## Error Handling

| Error | Cause | Response |
|-------|-------|----------|
| `DEADLINE_PASSED` | Response deadline expired | "The response deadline has passed. Buyer may have cancellation rights. I recommend responding immediately with acceptance of key items." |
| `NO_REPAIR_REQUEST` | Can't find repair request | "I don't see a repair request for this deal. Has the buyer submitted one?" |
| `NOT_LISTING_AGENT` | User is not listing agent | "Only the listing agent can respond to repair requests for the seller." |
| `ALREADY_RESPONDED` | Response already sent | "A response has already been sent for this repair request. Would you like to send an amendment?" |
| `COUNTER_INCOMPLETE` | Counter-offer missing details | "The counter-offer needs more details. What credit amount or repairs should I include?" |

## Approval Gate

**This skill requires human approval before:**
1. Sending response to buyer's agent
2. Committing seller to any repairs
3. Making any counter-offer

**Approval Dialog:**
```
┌─────────────────────────────────────────────────────────────┐
│ APPROVAL REQUIRED: Seller's Repair Response                  │
├─────────────────────────────────────────────────────────────┤
│ Property: 123 Main Street                                    │
│ Response Type: ACCEPT PARTIAL + COUNTER                      │
│                                                              │
│ ACCEPTED (3 items, $9,500):                                  │
│ ✓ Electrical panel replacement                              │
│ ✓ Roof leak repairs                                         │
│ ✓ Water heater replacement                                  │
│                                                              │
│ REJECTED (4 items):                                          │
│ ✗ HVAC service (reason: recently serviced)                  │
│ ✗ Cosmetic items (reason: as-is condition)                  │
│                                                              │
│ COUNTER: $2,500 credit for remaining items                  │
│                                                              │
│ TOTAL SELLER COST: $12,000                                  │
│ Counter expires: Jan 28, 2026                               │
│                                                              │
│ [Send to Seller for Signature] [Edit Response] [Cancel]     │
└─────────────────────────────────────────────────────────────┘
```

## Signing Workflow

```
DRAFT
  │
  ├─── Agent approves response
  │
PENDING_SELLER_SIGNATURE
  │
  ├─── Seller(s) sign
  │
SIGNED
  │
  ├─── Auto-send to buyer's agent
  │
DELIVERED
  │
  ├─── If counter: Start buyer response timer
  │
  └─── If accept/reject: Update deal status
```

## Integration Points

### Inputs From
- `draft-repair-request` - Original buyer request
- Deal record - Party info, contract terms
- Market data - Negotiation context

### Triggers After
- Notify buyer's agent
- Update deal timeline
- If counter: Create response deadline
- If accept: Create repair tracking
- If reject: Prepare cancellation workflow

### Database Tables
- `documents` - Response document
- `repair_responses` - Response details
- `negotiations` - Negotiation history
- `action_log` - Audit entry

## Florida-Specific Considerations

1. **As-Is Implications**: Seller has no obligation to repair on As-Is contract
2. **Inspection Period**: Response should be within buyer's inspection period
3. **Licensed Contractors**: Repairs requiring permits need licensed contractors
4. **Time is of Essence**: Standard Florida contract language applies
5. **Good Faith**: Florida law expects good faith negotiation

## Rejection Reason Templates

| Reason | Language |
|--------|----------|
| As-Is Contract | "Property is being sold As-Is and Seller declines repair requests." |
| Cosmetic Only | "Item is cosmetic in nature and does not affect habitability or safety." |
| Buyer Preference | "Item reflects buyer preference rather than defect or deficiency." |
| Normal Wear | "Item reflects normal wear and tear consistent with property age." |
| Recently Addressed | "Item was recently addressed/serviced and is in acceptable condition." |
| Excessive Cost | "Estimated cost is excessive; Seller offers alternative of $X credit." |

## Quality Checklist

- [x] Analyzes repair request and presents options
- [x] Calculates cost impact for each option
- [x] Supports all response types (accept/partial/counter/reject)
- [x] Generates compliant response document
- [x] Provides rejection reason templates
- [x] Tracks counter-offer expiration
- [x] Requires seller approval before sending
- [x] Handles As-Is contract implications
- [x] Creates audit trail
- [x] Integrates with signing workflow
- [x] Notifies buyer's agent
- [x] Updates deal timeline

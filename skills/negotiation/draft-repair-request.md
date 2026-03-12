# Skill: Draft Repair Request

**Category:** Negotiation
**Priority:** P0
**Approval Required:** Yes (buyer must approve before sending to seller)

## Purpose

Generate a formal Buyer's Inspection Response / Repair Request document based on analyzed findings and calculated credits. This creates a legally compliant, professional document ready for buyer signature and delivery to the seller's agent.

## Triggers

### Voice Commands
- "Draft the repair request"
- "Create repair request for [items]"
- "Send repair list to seller"
- "Generate inspection response"
- "Prepare the repair document"
- "Request credit of [amount]"
- "Ask seller to fix [items]"

### System Events
- Credit calculation approved
- Agent clicks "Generate Repair Request" in UI
- Inspection deadline approaching (prompt if analysis complete)

## Required Inputs

| Input | Type | Required | Source | Description |
|-------|------|----------|--------|-------------|
| `dealId` | string | Yes | context | The deal being negotiated |
| `responseType` | string | Yes | agent | 'repairs' | 'credit' | 'combination' | 'as_is_acceptance' |

## Optional Inputs

| Input | Type | Default | Source | Description |
|-------|------|---------|--------|-------------|
| `repairItems` | RepairItem[] | null | prioritize-repairs | Items for repair request |
| `creditAmount` | number | null | calculate-repair-credit | Credit amount requested |
| `creditPurpose` | string | null | agent | Explanation for credit |
| `responseDeadline` | Date | calculated | agent | When seller must respond |
| `additionalTerms` | string | null | agent | Custom terms/conditions |
| `inspectorName` | string | extracted | inspection | Inspector who performed inspection |
| `inspectionDate` | Date | extracted | inspection | Date of inspection |
| `tone` | string | 'professional' | agent | 'professional' | 'firm' | 'friendly' |

## Output Schema

```typescript
{
  success: boolean;
  actionTaken: string;
  result: {
    document: {
      id: string;
      name: string;
      type: 'repair_request';
      version: number;
      pdfUrl: string;
      status: 'draft' | 'pending_buyer_signature' | 'signed' | 'sent';
      createdAt: Date;
    };
    content: {
      responseType: string;
      repairItems: RepairItem[];
      creditAmount: number;
      responseDeadline: Date;
      totalEstimatedCost: number;
    };
    summary: {
      totalItems: number;
      requiredItems: number;
      requestedItems: number;
      estimatedRepairCost: { low: number; high: number };
      creditRequested: number;
    };
    docusign?: {
      envelopeId: string;
      status: string;
      signers: Signer[];
    };
    nextSteps: string[];
    warnings: string[];
  };
  requiresApproval: true;
  approvalContext: {
    action: "Send repair request to buyer for signature";
    stakes: "high";
    reversible: false;
  };
}

interface RepairItem {
  item: string;
  description: string;
  category: string;
  priority: 'required' | 'requested' | 'optional';
  estimatedCost: number;
  requestType: 'repair' | 'credit' | 'either';
}
```

## Execution Flow

```
START
  │
  ├─── 1. Validate inputs
  │    ├── Verify deal exists and is active
  │    ├── Verify inspection period not expired (warn if so)
  │    ├── Verify response type is valid
  │    ├── If repairs: verify items provided
  │    └── If credit: verify amount provided
  │
  ├─── 2. Load deal context
  │    ├── Get property address
  │    ├── Get all parties (buyers, sellers, agents)
  │    ├── Get contract details (effective date, closing date)
  │    ├── Get inspection deadline
  │    └── Calculate response deadline if not provided
  │
  ├─── 3. Load inspection data
  │    ├── Get inspection report metadata
  │    ├── Get prioritized findings
  │    └── Get credit calculations
  │
  ├─── 4. Prepare repair items
  │    ├── Format each item with description
  │    ├── Categorize by priority level
  │    ├── Calculate totals
  │    └── Add estimated costs
  │
  ├─── 5. Calculate response deadline
  │    ├── Default: 3 business days from sending
  │    ├── Cannot exceed inspection period
  │    └── Consider urgency of items
  │
  ├─── 6. Generate document
  │    │
  │    ├─── 6a. Apply document template
  │    │    ├── Header with property info
  │    │    ├── Contract reference
  │    │    ├── Buyer/seller names
  │    │    └── Inspection details
  │    │
  │    ├─── 6b. Insert response type election
  │    │    ├── Checkboxes for type
  │    │    └── Clear selection
  │    │
  │    ├─── 6c. Insert repair items (if applicable)
  │    │    ├── Numbered list
  │    │    ├── Priority indicators
  │    │    ├── Descriptions
  │    │    └── Estimated costs
  │    │
  │    ├─── 6d. Insert credit request (if applicable)
  │    │    ├── Amount in numbers and words
  │    │    ├── Purpose explanation
  │    │    └── Lender disclosure
  │    │
  │    ├─── 6e. Insert additional terms
  │    │
  │    ├─── 6f. Insert response deadline
  │    │
  │    └─── 6g. Insert signature blocks
  │         ├── Buyer signature(s)
  │         └── Listing agent acknowledgment
  │
  ├─── 7. Generate PDF
  │    ├── Apply styling
  │    ├── Add page numbers
  │    └── Store securely
  │
  ├─── 8. Create draft status
  │    ├── Mark as draft/pending approval
  │    └── Store version history
  │
  ├─── 9. Log action
  │    └── action_type: 'repair_request_drafted'
  │
  └─── 10. Present for approval
       ├── Show summary to agent
       ├── Preview document
       └── Request client approval
```

## Document Template

See `/Users/eddiebelaval/Development/homer-pro/skills/document/templates/repair-request.md` for full template.

### Key Sections

1. **Header**: Date, property address, contract reference
2. **Parties**: Buyer and seller names
3. **Inspection Reference**: Date, inspector, report attached
4. **Election Section**: Checkboxes for response type
5. **Repair Items**: Numbered, prioritized, with costs
6. **Credit Request**: Amount, purpose, terms
7. **Additional Terms**: Custom provisions
8. **Response Deadline**: Date and time
9. **Signatures**: Buyer, with listing agent acknowledgment

## Response Deadline Rules

```typescript
function calculateResponseDeadline(deal: Deal, input: Date | null): Date {
  // If specified, validate it
  if (input) {
    const deadline = new Date(input);
    // Cannot exceed inspection period
    if (deadline > deal.inspectionPeriodEnd) {
      return deal.inspectionPeriodEnd;
    }
    return deadline;
  }

  // Default: 3 business days from now, or inspection end, whichever is sooner
  const threeDaysOut = addBusinessDays(new Date(), 3);
  const inspectionEnd = deal.inspectionPeriodEnd;

  return threeDaysOut < inspectionEnd ? threeDaysOut : inspectionEnd;
}
```

## Priority Level Formatting

| Priority | Format | Typical Use |
|----------|--------|-------------|
| **REQUIRED** | Bold, highlighted | Safety hazards, code violations |
| **REQUESTED** | Standard formatting | Major repairs, significant cost |
| **OPTIONAL** | Italicized | Nice to have, low priority |

## Tone Adjustments

### Professional (Default)
```
Buyer requests Seller to complete the repairs listed below prior to
closing. All repairs shall be completed in a workmanlike manner by
licensed and insured contractors where required by law.
```

### Firm
```
Based on the inspection findings, Buyer requires the following repairs
to be completed prior to closing. These items represent significant
deficiencies that must be addressed for the transaction to proceed.
```

### Friendly
```
After reviewing the inspection report, we've identified some items
we'd like to discuss. We've tried to be reasonable and focus on the
most important issues.
```

## Voice Response

**When draft is ready:**
> "I've drafted the repair request for 123 Main Street. Here's a summary:
>
> **Request Type:** Repairs plus $5,000 credit
>
> **Repair Items (3):**
> 1. [REQUIRED] Electrical panel replacement - safety hazard
> 2. [REQUIRED] Roof leak repairs - active water intrusion
> 3. [REQUESTED] Water heater replacement - at end of life
>
> **Credit Requested:** $5,000 for HVAC and plumbing items
>
> **Response Deadline:** January 25th at 5 PM
>
> **Total Estimated Value:** $14,500
>
> The document is ready for your buyer's review and signature. Would you like me to send it to them now, or would you like to review it first?"

**If inspection period is tight:**
> "I've drafted the repair request. Note: The inspection period ends in 2 days, so I've set the response deadline for 24 hours from delivery. This is aggressive but necessary to preserve your buyer's rights. Ready to send for signature?"

## Error Handling

| Error | Cause | Response |
|-------|-------|----------|
| `INSPECTION_EXPIRED` | Past inspection period | "The inspection period has ended. You can still send this, but seller is not obligated to respond. Do you want to proceed?" |
| `NO_ITEMS` | Repair type selected but no items | "You've selected to request repairs but haven't specified any items. What repairs should I include?" |
| `NO_CREDIT_AMOUNT` | Credit type selected but no amount | "You've selected to request a credit but haven't specified an amount. How much credit should I request?" |
| `MISSING_PARTIES` | No buyer/seller info | "I need buyer and seller information to complete this document. Can you add them to the deal first?" |
| `DEADLINE_INVALID` | Response deadline past inspection end | "The response deadline you specified is after the inspection period ends. I'll adjust it to [date]." |

## Approval Gate

**This skill requires human approval before:**
1. Sending document to buyer for signature
2. Changing from draft to pending status
3. Adding to DocuSign envelope

**Approval Dialog:**
```
┌─────────────────────────────────────────────────────────────┐
│ APPROVAL REQUIRED: Repair Request Draft                      │
├─────────────────────────────────────────────────────────────┤
│ Ready to send repair request for 123 Main Street:           │
│                                                              │
│ TYPE: Repairs + Credit                                       │
│                                                              │
│ REPAIR ITEMS:                                                │
│ [REQUIRED] Electrical panel replacement                      │
│ [REQUIRED] Roof leak repairs                                 │
│ [REQUESTED] Water heater replacement                         │
│                                                              │
│ CREDIT: $5,000 (for HVAC and plumbing)                      │
│ TOTAL VALUE: $14,500                                         │
│                                                              │
│ RESPONSE DEADLINE: Jan 25, 2026 at 5:00 PM                  │
│                                                              │
│ [Preview PDF] [Send to Buyer] [Edit] [Cancel]               │
└─────────────────────────────────────────────────────────────┘
```

## Signing Workflow

```
DRAFT
  │
  ├─── Agent approves → Send to Buyer
  │
PENDING_BUYER_SIGNATURE
  │
  ├─── Buyer signs → Mark as signed
  │
SIGNED
  │
  ├─── Auto-forward to Listing Agent for acknowledgment
  │
ACKNOWLEDGED
  │
  ├─── Notify seller/seller's agent
  │
DELIVERED
  │
  └─── Start response timer
```

## Integration Points

### Inputs From
- `analyze-inspection-report` - Finding details
- `prioritize-repairs` - Item priorities
- `calculate-repair-credit` - Credit amounts
- Deal record - Party info, dates

### Triggers After
- DocuSign envelope creation
- Email notification to buyer
- Deadline tracker for response
- Status update in deal timeline

### Database Tables
- `documents` - Generated document record
- `repair_requests` - Specific repair request data
- `action_log` - Audit entry
- `deadlines` - Response deadline tracking

## Florida-Specific Considerations

1. **Contract Form Reference**: Reference FAR/BAR contract paragraph numbers
2. **Inspection Period**: Florida standard is 15 days
3. **As-Is Rights**: Even on As-Is, buyer can still request (seller can refuse)
4. **Licensed Contractors**: Note Florida licensing requirements
5. **Permit Language**: Include permit requirements where applicable
6. **Time is of the Essence**: Standard Florida contract provision

## Document Versioning

Track all versions:
- v1.0: Initial draft
- v1.1: Agent edits before buyer review
- v2.0: After buyer review/edits
- FINAL: Signed version

## Quality Checklist

- [x] Generates Florida-compliant repair request format
- [x] Supports all response types (repairs, credit, combination, as-is)
- [x] Includes prioritized repair items with descriptions
- [x] Calculates and displays estimated costs
- [x] Sets appropriate response deadline
- [x] Includes all required signature blocks
- [x] Integrates with DocuSign workflow
- [x] Tracks document versions
- [x] Requires buyer approval before sending
- [x] Creates deadline for seller response
- [x] Provides clear voice summary
- [x] Handles inspection period timing
- [x] Creates audit trail

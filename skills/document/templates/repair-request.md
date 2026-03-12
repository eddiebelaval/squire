# Skill: Repair Request / Buyer's Inspection Response

**Category:** Document/Template
**Priority:** P0
**Approval Required:** Yes (buyer approval before sending to seller)

## Purpose

Generate a formal repair request or buyer's inspection response based on inspection findings. This document outlines requested repairs, credits, or a combination, and is a critical negotiation tool within the inspection contingency period.

## Triggers

### Voice Commands
- "Create a repair request for [items]"
- "Send repair list to seller"
- "Request credit of [amount] for repairs"
- "Generate inspection response"
- "Ask seller to fix [items]"

### System Events
- Inspection report uploaded and parsed
- Inspection deadline approaching (prompt for response)

## Input

```typescript
{
  dealId: string;
  responseType: 'repairs' | 'credit' | 'combination' | 'as_is_acceptance';
  repairItems?: {
    item: string;
    description: string;
    estimatedCost?: number;
    priority: 'required' | 'requested' | 'optional';
    category: 'structural' | 'mechanical' | 'electrical' | 'plumbing' |
              'hvac' | 'roof' | 'safety' | 'cosmetic' | 'other';
  }[];
  creditAmount?: number;
  creditPurpose?: string;
  inspectionReportDate?: Date;
  inspectorName?: string;
  additionalTerms?: string;
  responseDeadline?: Date;          // When seller must respond
}
```

## Output

```typescript
{
  success: boolean;
  actionTaken: string;
  result: {
    document: {
      id: string;
      name: string;
      type: 'notice';
      pdfUrl: string;
      status: string;
    };
    docusign?: {
      envelopeId: string;
      signers: {
        role: string;
        name: string;
        email: string;
        status: string;
      }[];
    };
    summary: {
      totalItems: number;
      requiredItems: number;
      estimatedRepairCost: number;
      creditRequested: number;
    };
    notificationsSent: string[];
    nextSteps: string[];
  };
}
```

## Document Template

```
BUYER'S INSPECTION RESPONSE / REPAIR REQUEST

Date: {{currentDate | formatDate}}
Property Address: {{deal.address.street}}
                  {{deal.address.city}}, {{deal.address.state}} {{deal.address.zip}}

Contract Date: {{deal.effectiveDate | formatDate}}
Buyer(s): {{#each buyers}}{{this.name}}{{#unless @last}}, {{/unless}}{{/each}}
Seller(s): {{#each sellers}}{{this.name}}{{#unless @last}}, {{/unless}}{{/each}}

Pursuant to the terms of the Contract for Sale and Purchase, Buyer has
conducted inspections of the Property and hereby provides the following
response:

{{#if inspectionReportDate}}
Inspection conducted on: {{inspectionReportDate | formatDate}}
{{#if inspectorName}}Inspector: {{inspectorName}}{{/if}}
{{/if}}

================================================================================
BUYER'S ELECTION
================================================================================

{{#if responseType === 'repairs'}}
☑ Buyer requests Seller to complete the repairs listed below prior to closing.
☐ Buyer requests a credit at closing in lieu of repairs.
☐ Buyer requests repairs AND a credit as detailed below.
☐ Buyer accepts the Property in "As-Is" condition.
{{/if}}

{{#if responseType === 'credit'}}
☐ Buyer requests Seller to complete repairs listed below prior to closing.
☑ Buyer requests a credit at closing in lieu of repairs.
☐ Buyer requests repairs AND a credit as detailed below.
☐ Buyer accepts the Property in "As-Is" condition.
{{/if}}

{{#if responseType === 'combination'}}
☐ Buyer requests Seller to complete repairs listed below prior to closing.
☐ Buyer requests a credit at closing in lieu of repairs.
☑ Buyer requests repairs AND a credit as detailed below.
☐ Buyer accepts the Property in "As-Is" condition.
{{/if}}

{{#if responseType === 'as_is_acceptance'}}
☐ Buyer requests Seller to complete repairs listed below prior to closing.
☐ Buyer requests a credit at closing in lieu of repairs.
☐ Buyer requests repairs AND a credit as detailed below.
☑ Buyer accepts the Property in "As-Is" condition.
{{/if}}

{{#unless responseType === 'as_is_acceptance'}}
================================================================================
{{#if responseType === 'repairs' || responseType === 'combination'}}
REQUESTED REPAIRS
================================================================================

Buyer requests Seller to complete the following repairs prior to closing.
All repairs shall be completed in a workmanlike manner by licensed and
insured contractors where required by law.

{{#each repairItems}}
{{@index + 1}}. [{{this.priority | uppercase}}] {{this.item}}
   Category: {{this.category | capitalize}}
   Description: {{this.description}}
   {{#if this.estimatedCost}}Estimated Cost: ${{this.estimatedCost | currency}}{{/if}}

{{/each}}

{{#if repairItems.length > 0}}
TOTAL ESTIMATED REPAIR COST: ${{totalEstimatedCost | currency}}
{{/if}}

Seller shall provide Buyer with copies of paid receipts and/or lien waivers
for all repairs completed by third-party contractors.

{{/if}}

{{#if responseType === 'credit' || responseType === 'combination'}}
================================================================================
CREDIT REQUEST
================================================================================

Buyer requests a credit at closing in the amount of:

${{creditAmount | currency}} ({{creditAmount | numberToWords}} dollars)

{{#if creditPurpose}}
Purpose: {{creditPurpose}}
{{/if}}

This credit shall appear on the Closing Disclosure and shall be applied
toward Buyer's closing costs and/or purchase price as permitted by Buyer's
lender.
{{/if}}

{{#if additionalTerms}}
================================================================================
ADDITIONAL TERMS
================================================================================

{{additionalTerms}}
{{/if}}

================================================================================
RESPONSE DEADLINE
================================================================================

Seller shall respond to this Repair Request by:

{{responseDeadline | formatDate}} at 5:00 PM local time

If Seller does not respond by the above deadline, Buyer reserves all rights
under the Contract, including but not limited to the right to cancel the
Contract and receive a full refund of the earnest money deposit.
{{/unless}}

{{#if responseType === 'as_is_acceptance'}}
================================================================================
AS-IS ACCEPTANCE
================================================================================

Buyer hereby accepts the Property in its current "As-Is" condition. Buyer
waives the right to request any repairs or credits based on the inspection
findings.

This acceptance is made with full knowledge of the Property's condition as
revealed by inspections conducted by Buyer.

Buyer acknowledges that this acceptance does not affect any existing
disclosure obligations of Seller or any known material defects not yet
disclosed.
{{/if}}

================================================================================
SIGNATURES
================================================================================

BUYER:

_________________________________    Date: ____________
{{buyers.[0].name}}

{{#if buyers.[1]}}
_________________________________    Date: ____________
{{buyers.[1].name}}
{{/if}}


ACKNOWLEDGMENT OF RECEIPT (Listing Agent):

_________________________________    Date: ____________
{{listingAgent.name}}
License #: {{listingAgent.licenseNumber}}


Prepared by: {{agent.name}}
             {{agent.brokerage}}
             {{agent.phone}} | {{agent.email}}
```

## Execution Flow

```
START
  │
  ├─── 1. Validate inputs
  │    ├── Verify deal exists and is active
  │    ├── Verify inspection period not expired
  │    ├── Validate repair items if provided
  │    └── Calculate totals
  │
  ├─── 2. Load deal context
  │    ├── Get all parties
  │    ├── Get inspection deadline
  │    ├── Get agent info
  │    └── Calculate response deadline (if not provided)
  │
  ├─── 3. Process repair items
  │    ├── Categorize by priority
  │    ├── Calculate total estimated cost
  │    └── Format descriptions
  │
  ├─── 4. Generate document
  │    ├── Apply template
  │    ├── Include all conditional sections
  │    └── Generate PDF
  │
  ├─── 5. Configure DocuSign
  │    │
  │    ├── Signers:
  │    │   1. Buyer(s)
  │    │   2. Listing Agent (acknowledgment only)
  │    │
  │    ├── Signature tabs:
  │    │   ├── Buyer signature + date
  │    │   ├── Co-buyer signature + date (if applicable)
  │    │   └── Listing agent acknowledgment + date
  │    │
  │    └── Settings:
  │        ├── Sequential signing: true
  │        └── Expiration: 24 hours (urgent)
  │
  ├─── 6. Send for buyer signature
  │    ├── Create DocuSign envelope
  │    ├── Send to buyer first
  │    └── Upon buyer signature → forward to listing agent
  │
  ├─── 7. Queue seller notification
  │    └── After listing agent acknowledges → full notification to seller
  │
  ├─── 8. Set response tracking
  │    ├── Create pending deadline: "Seller Repair Response Due"
  │    └── Schedule follow-up if no response
  │
  ├─── 9. Log action
  │    └── Create action_log entry
  │
  └─── 10. Return result
```

## Priority Definitions

| Priority | Meaning | Typical Items |
|----------|---------|---------------|
| **Required** | Must be fixed for safety/habitability | Safety hazards, code violations, roof leaks, HVAC failure |
| **Requested** | Significant but negotiable | Aging systems, minor repairs, deferred maintenance |
| **Optional** | Nice to have, low priority | Cosmetic issues, upgrades, preferences |

## Category Guidelines

| Category | Examples | Typical Cost Range |
|----------|----------|-------------------|
| Structural | Foundation cracks, framing issues | $1,000 - $50,000+ |
| Mechanical | HVAC, water heater, appliances | $200 - $10,000 |
| Electrical | Panel, wiring, outlets | $100 - $5,000 |
| Plumbing | Leaks, pipes, fixtures | $100 - $5,000 |
| HVAC | Heating, cooling, ductwork | $200 - $15,000 |
| Roof | Leaks, shingles, flashing | $500 - $20,000+ |
| Safety | Smoke detectors, railings, GFCIs | $50 - $1,000 |
| Cosmetic | Paint, flooring, fixtures | $100 - $5,000 |

## Response Deadline Calculation

Default response deadline if not specified:
- **Within inspection period**: 3 days from request OR inspection deadline, whichever is sooner
- **Custom**: As specified by agent

## Notification Flow

1. **Buyer signs** → Document ready
2. **Listing agent acknowledges** → Formally received
3. **Seller agent notifies seller** → Review and respond
4. **Seller responds** → Accept, counter, or reject
5. **Negotiation** → Back and forth until agreement or cancellation

## Post-Signature Actions

When buyer signs:
1. **Forward to listing agent** for acknowledgment
2. **Start response timer**
3. **Create "Awaiting Seller Response" status**
4. **Schedule follow-up** if no response

## Error Handling

| Error | Cause | Response |
|-------|-------|----------|
| `INSPECTION_EXPIRED` | Past inspection period | Warn agent, may still send but note expiration |
| `NO_ITEMS_PROVIDED` | Repairs type but no items | Require at least one item |
| `DEAL_INACTIVE` | Deal not active | Cannot send on inactive deal |
| `DOCUSIGN_FAILED` | DocuSign error | Retry, then alert agent |

## Florida Notes

- Repair requests are typically sent during the inspection period
- As-Is contracts limit buyer's repair rights but buyer can still cancel
- Response deadlines should be reasonable (2-5 days typical)
- Seller is not obligated to agree to any repairs
- If no agreement, buyer may cancel per contract terms

## Quality Checklist

- [x] Generates Florida-compliant repair request
- [x] Supports all response types (repairs, credit, combination, as-is)
- [x] Categorizes and prioritizes repair items
- [x] Calculates estimated costs
- [x] Sets appropriate response deadline
- [x] Configures DocuSign for buyer signature first
- [x] Tracks seller response deadline
- [x] Creates audit trail
- [x] Handles co-buyers
- [x] Provides clear next steps

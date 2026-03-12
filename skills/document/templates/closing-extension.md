# Skill: Closing Date Extension Addendum

**Category:** Document/Template
**Priority:** P0
**Approval Required:** Yes (requires all party signatures)

## Purpose

Generate a closing date extension addendum when the original closing date cannot be met. This document formally extends the closing date and requires signatures from buyer, seller, and often lender acknowledgment.

## Triggers

### Voice Commands
- "Extend the closing date to [date]"
- "We need to push back closing by [X] days"
- "Generate a closing extension to [date]"
- "Create closing extension addendum"

### System Events
- extend-deadline skill called for CLOSING category
- Lender notifies of delayed clear-to-close
- Title issues requiring more time

## Input

```typescript
{
  dealId: string;
  newClosingDate: Date;
  reason: string;
  requestedBy: 'buyer' | 'seller' | 'lender' | 'title' | 'mutual';
  additionalTerms?: string;
  perDiemAmount?: number;           // Daily charge if applicable
  perDiemPayer?: 'buyer' | 'seller';
  lockExtensionRequired?: boolean;  // Rate lock extension needed?
  requiresLenderApproval?: boolean; // Default: true if financed
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
      type: 'amendment';
      pdfUrl: string;
      status: string;
    };
    docusign: {
      envelopeId: string;
      signers: {
        role: string;
        name: string;
        email: string;
        status: string;
      }[];
    };
    deadlinesUpdated: {
      deadlineId: string;
      name: string;
      previousDate: Date;
      newDate: Date;
    }[];
    perDiem?: {
      dailyRate: number;
      totalDays: number;
      totalAmount: number;
      paidBy: string;
    };
    notificationsSent: string[];
  };
}
```

## Document Template

```
ADDENDUM TO CONTRACT FOR SALE AND PURCHASE
(Extension of Closing Date)

Date: {{currentDate | formatDate}}
Property Address: {{deal.address.street}}
                  {{deal.address.city}}, {{deal.address.state}} {{deal.address.zip}}
                  County: {{deal.address.county}}

Buyer(s): {{#each buyers}}{{this.name}}{{#unless @last}}, {{/unless}}{{/each}}
Seller(s): {{#each sellers}}{{this.name}}{{#unless @last}}, {{/unless}}{{/each}}

This Addendum is made part of the Contract for Sale and Purchase ("Contract")
dated {{deal.effectiveDate | formatDate}} between the above-referenced parties
for the above-referenced property.

The parties agree to modify the Contract as follows:

1. EXTENSION OF CLOSING DATE

   The original Closing Date of {{deal.closingDate | formatDate}} is hereby
   extended to {{newClosingDate | formatDate}}.

   Reason for Extension: {{reason}}

2. EXTENSION REQUESTED BY

   This extension was requested by: {{requestedBy | capitalize}}

{{#if perDiemAmount}}
3. PER DIEM CHARGES

   {{perDiemPayer | capitalize}} agrees to pay a per diem charge of
   ${{perDiemAmount | currency}} per day for each day from the original
   closing date to the new closing date.

   Original Closing Date: {{deal.closingDate | formatDate}}
   New Closing Date: {{newClosingDate | formatDate}}
   Total Days: {{extensionDays}}
   Total Per Diem: ${{totalPerDiem | currency}}

   Per diem shall be {{#if perDiemPayer === 'buyer'}}credited to Seller{{else}}credited to Buyer{{/if}}
   at closing.
{{/if}}

{{#if lockExtensionRequired}}
4. RATE LOCK EXTENSION

   Buyer acknowledges that this closing extension may require extending the
   interest rate lock with their lender. Any costs associated with the rate
   lock extension shall be paid by {{#if requestedBy === 'buyer'}}Buyer{{else}}Seller{{/if}},
   unless otherwise agreed in writing.
{{/if}}

{{#if additionalTerms}}
{{#if perDiemAmount}}5{{else}}{{#if lockExtensionRequired}}5{{else}}3{{/if}}{{/if}}. ADDITIONAL TERMS

   {{additionalTerms}}
{{/if}}

{{#with lastParagraphNumber}}{{this}}{{/with}}. NO OTHER CHANGES

   All other terms and conditions of the Contract remain in full force and
   effect and are hereby ratified and confirmed.

{{#if deal.financingType}}
LENDER ACKNOWLEDGMENT

This extension has been communicated to the lender. Buyer understands that
lender approval may be required and that the loan commitment may be affected
by this extension.

Lender: {{lender.company}}
Loan Officer: {{lender.name}}
Contact: {{lender.email}} | {{lender.phone}}
{{/if}}

SIGNATURES

This Addendum shall be binding upon execution by all parties.

BUYER(S):

_________________________________    Date: ____________
{{buyers.[0].name}}

{{#if buyers.[1]}}
_________________________________    Date: ____________
{{buyers.[1].name}}
{{/if}}


SELLER(S):

_________________________________    Date: ____________
{{sellers.[0].name}}

{{#if sellers.[1]}}
_________________________________    Date: ____________
{{sellers.[1].name}}
{{/if}}


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
  │    ├── Verify new date is after original
  │    ├── Verify new date is in the future
  │    └── Calculate extension days
  │
  ├─── 2. Load deal context
  │    ├── Get all parties (buyers, sellers, agents)
  │    ├── Get lender info if financed
  │    ├── Get original closing date
  │    └── Get current contract terms
  │
  ├─── 3. Calculate per diem (if applicable)
  │    ├── Determine daily rate
  │    ├── Calculate total days
  │    └── Calculate total per diem amount
  │
  ├─── 4. Generate document
  │    ├── Apply template with deal data
  │    ├── Include all conditional sections
  │    └── Generate PDF
  │
  ├─── 5. Configure DocuSign
  │    │
  │    ├── Signers (in order):
  │    │   1. Buyer(s)
  │    │   2. Seller(s)
  │    │
  │    ├── Signature tabs:
  │    │   ├── Buyer signature + date
  │    │   ├── Co-buyer signature + date (if applicable)
  │    │   ├── Seller signature + date
  │    │   └── Co-seller signature + date (if applicable)
  │    │
  │    └── Settings:
  │        ├── Sequential signing: true
  │        └── Expiration: 3 days
  │
  ├─── 6. Send for signatures
  │    ├── Create DocuSign envelope
  │    ├── Send to all signers
  │    └── Track envelope ID
  │
  ├─── 7. Update deal & deadlines
  │    ├── Update deal.closingDate (pending signature)
  │    ├── Recalculate closing-relative deadlines:
  │    │   ├── Final walkthrough (closing - 1 day)
  │    │   ├── Wire instructions (closing - 3 days)
  │    │   ├── Clear to close (closing - 5 days)
  │    │   └── Any custom closing-relative deadlines
  │    └── Flag as "pending extension approval"
  │
  ├─── 8. Notify parties
  │    ├── Title company (email)
  │    ├── Lender (email)
  │    ├── Both agents
  │    └── Insurance agent (if policy affected)
  │
  ├─── 9. Log action
  │    └── Create action_log entry
  │
  └─── 10. Return result
```

## Per Diem Guidelines

| Market | Typical Per Diem | Payer |
|--------|------------------|-------|
| Seller's Market | $100-200/day | Buyer (if buyer caused) |
| Buyer's Market | $0-100/day | Seller (if seller caused) |
| Balanced | $50-150/day | Requesting party |
| Lender Delay | Often waived | Negotiable |
| Title Issue | Often waived | Seller |

## Parties Notified

| Party | Method | Content |
|-------|--------|---------|
| Title Company | Email | New closing date, reschedule request |
| Lender | Email | Extension notice, rate lock question |
| Listing Agent | Email + SMS | Extension details, next steps |
| Buyer's Agent | Email + SMS | Extension details, next steps |
| Insurance Agent | Email | Policy bind date change |

## Post-Signature Actions

When all parties sign:
1. **Update deal.closingDate** to new date (finalize)
2. **Finalize deadline recalculations**
3. **Notify title company** to reschedule closing
4. **Update lender** with confirmed new date
5. **Regenerate closing checklist** with new dates
6. **Send confirmation** to all parties

## Error Handling

| Error | Cause | Response |
|-------|-------|----------|
| `DATE_IN_PAST` | New date already passed | Reject, require future date |
| `DEAL_INACTIVE` | Deal closed/cancelled | Cannot extend inactive deal |
| `NO_BUYERS_FOUND` | Missing buyer data | Alert agent to add parties |
| `DOCUSIGN_FAILED` | DocuSign API error | Retry, then alert agent |

## Florida Compliance Notes

- Closing extensions are common and generally straightforward
- Per diem charges are negotiable and market-dependent
- Rate lock extensions can be costly; communicate early with lender
- All parties must agree to extension for it to be valid
- Document should reference original contract date

## Quality Checklist

- [x] Generates Florida-compliant extension addendum
- [x] Includes per diem calculation when applicable
- [x] Notes rate lock extension requirement
- [x] Configures DocuSign with all required signers
- [x] Sets appropriate signing order
- [x] Recalculates all closing-relative deadlines
- [x] Notifies all affected parties (title, lender, agents)
- [x] Creates complete audit trail
- [x] Handles co-buyers and co-sellers
- [x] Updates deal record upon full execution

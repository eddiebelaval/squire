# Skill: Price Reduction Addendum

**Category:** Document/Template
**Priority:** P0
**Approval Required:** No

## Purpose

Generate a Florida-compliant addendum to reduce the purchase price on a real estate contract. This addendum is commonly used after appraisal shortfalls, inspection findings, or negotiated price adjustments.

## Triggers

### Voice Commands
- "Reduce price by [amount]"
- "Lower the purchase price to [amount]"
- "Price reduction of [amount] for [address]"
- "Change price from [old] to [new]"
- "Appraisal came in low, reduce to [amount]"
- "Adjust price to [amount]"

### Programmatic
- `POST /deals/:dealId/documents/addendum/price-reduction`
- `POST /deals/:dealId/documents/generate` with `templateId: price_reduction`
- Follow-up to appraisal contingency

## Required Inputs

| Input | Type | Required | Source | Default |
|-------|------|----------|--------|---------|
| `dealId` | UUID | Yes | context | - |
| `newPrice` | number | Yes* | voice | - |
| `reductionAmount` | number | Yes* | voice | - |

*Either `newPrice` OR `reductionAmount` required

## Optional Inputs

| Input | Type | Default | Source | Description |
|-------|------|---------|--------|-------------|
| `reason` | string | null | voice | Reason for reduction |
| `appraisedValue` | number | null | manual | If due to appraisal |
| `adjustEscrow` | boolean | false | manual | Adjust escrow deposit |
| `newEscrowAmount` | number | null | manual | New escrow if adjusted |
| `affectLoanAmount` | boolean | true | manual | Note loan impact |
| `sendForSignature` | boolean | true | config | Auto-send to DocuSign |
| `signers` | Signer[] | from deal | config | Override signers |

## Execution Flow

```
START
  │
  ├─── 1. Load deal context
  │    ├── Get deal by ID
  │    ├── Get current purchase price
  │    ├── Get escrow amount
  │    ├── Get buyer and seller
  │    └── Get financing details
  │
  ├─── 2. Calculate price change
  │    │
  │    ├── IF newPrice provided:
  │    │   └── reductionAmount = currentPrice - newPrice
  │    │
  │    ├── IF reductionAmount provided:
  │    │   └── newPrice = currentPrice - reductionAmount
  │    │
  │    └── Calculate:
  │        ├── Percentage reduction
  │        ├── Impact on down payment
  │        └── Impact on loan amount
  │
  ├─── 3. Validate reduction
  │    ├── New price must be positive
  │    ├── Reduction should be reasonable
  │    ├── Check if matches appraisal (if applicable)
  │    └── Warn if significant (> 10%)
  │
  ├─── 4. Calculate escrow adjustment (if requested)
  │    └── Proportional reduction or specific amount
  │
  ├─── 5. Fill template
  │    ├── Property address
  │    ├── Buyer name(s)
  │    ├── Seller name(s)
  │    ├── Original price
  │    ├── New price
  │    ├── Reduction amount
  │    ├── Reason
  │    ├── Appraisal value (if applicable)
  │    └── Escrow changes (if any)
  │
  ├─── 6. Generate PDF
  │    └── Create PDF from filled template
  │
  ├─── 7. Create document record
  │    ├── type: 'addendum'
  │    ├── template_id: 'price_reduction'
  │    ├── status: 'draft' or 'sent'
  │    └── Store PDF URL
  │
  ├─── 8. IF sendForSignature:
  │    ├── Create signers (buyer and seller)
  │    ├── INVOKE: send-for-signature skill
  │    └── Update document status to 'sent'
  │
  ├─── 9. Queue deal updates (pending signature)
  │    └── Store new price to apply when signed
  │
  ├─── 10. Log action
  │     └── action_type: 'document_generated'
  │
  └─── 11. Return result
```

## Template Content

```
ADDENDUM TO RESIDENTIAL CONTRACT FOR SALE AND PURCHASE
PURCHASE PRICE REDUCTION

Date: {{current_date}}

Property Address: {{deal.property_address.street}}
                  {{deal.property_address.city}}, {{deal.property_address.state}} {{deal.property_address.zip}}

Buyer(s): {{#each buyers}}{{this.name}}{{#unless @last}}, {{/unless}}{{/each}}
Seller(s): {{#each sellers}}{{this.name}}{{#unless @last}}, {{/unless}}{{/each}}

Effective Date of Original Contract: {{deal.effective_date}}

This Addendum is made a part of the above-referenced Contract for Sale and
Purchase ("Contract").

================================================================================
PURCHASE PRICE MODIFICATION
================================================================================

The parties agree to modify the Purchase Price as follows:

1. PRICE REDUCTION

   Original Purchase Price:     ${{originalPrice | currency}}
   Reduction Amount:           (${{reductionAmount | currency}})
                               ─────────────────────
   NEW PURCHASE PRICE:          ${{newPrice | currency}}

   The new Purchase Price of ${{newPrice | currency}} ({{newPrice | numberToWords}}
   dollars) shall replace the original Purchase Price stated in the Contract.

{{#if reason}}
2. REASON FOR REDUCTION

   {{reason}}
{{/if}}

{{#if appraisedValue}}
3. APPRAISAL REFERENCE

   This price reduction is made in connection with an appraisal of the Property
   that determined the market value to be ${{appraisedValue | currency}}.

   The parties acknowledge this adjustment and agree to proceed with the
   transaction at the new Purchase Price.
{{/if}}

{{#if adjustEscrow}}
4. ESCROW DEPOSIT ADJUSTMENT

   The Escrow Deposit shall be adjusted as follows:

   Original Escrow Amount:      ${{originalEscrow | currency}}
   {{#if escrowRefund}}
   Refund to Buyer:            (${{escrowRefund | currency}})
   New Escrow Amount:           ${{newEscrowAmount | currency}}
   {{else}}
   New Escrow Amount:           ${{newEscrowAmount | currency}}
   {{/if}}

   Any refund of escrow shall be processed within 5 business days of full
   execution of this Addendum.
{{else}}
4. ESCROW DEPOSIT

   The Escrow Deposit previously made shall remain unchanged and shall be
   applied toward the new Purchase Price.
{{/if}}

{{#if affectLoanAmount}}
5. FINANCING IMPACT

   Buyer acknowledges that this price reduction may affect:
   • Loan amount
   • Down payment requirements
   • Loan-to-value ratio
   • Monthly payment

   Buyer is responsible for coordinating with their lender regarding any
   changes to the financing as a result of this price reduction.
{{/if}}

6. EFFECT ON CONTRACT

   Except as modified by this Addendum, all terms and conditions of the
   Contract shall remain unchanged and in full force and effect.

   All references to the "Purchase Price" in the Contract shall mean the
   new Purchase Price stated herein.

================================================================================
SIGNATURES
================================================================================

BUYER:                                    DATE:
_________________________________        _______________
{{buyers.[0].name}}

{{#if buyers.[1]}}
_________________________________        _______________
{{buyers.[1].name}}
{{/if}}

SELLER:                                   DATE:
_________________________________        _______________
{{sellers.[0].name}}

{{#if sellers.[1]}}
_________________________________        _______________
{{sellers.[1].name}}
{{/if}}
```

## DocuSign Configuration

```typescript
const docusignConfig = {
  emailSubject: "Purchase Price Reduction - {{property_address}}",
  emailBlurb: "Please sign the attached Purchase Price Reduction Addendum for {{property_address}}. The purchase price is being reduced from ${{originalPrice | currency}} to ${{newPrice | currency}}.",
  signers: [
    {
      role: "buyer",
      routingOrder: 1,
      tabs: {
        signHere: { anchorString: "BUYER:", anchorYOffset: 20 },
        dateSigned: { anchorString: "DATE:", anchorYOffset: 20, anchorXOffset: -100 }
      }
    },
    {
      role: "seller",
      routingOrder: 2,
      tabs: {
        signHere: { anchorString: "SELLER:", anchorYOffset: 20 },
        dateSigned: { anchorString: "DATE:", anchorYOffset: 20, anchorXOffset: -100 }
      }
    }
  ]
};
```

## Output

```typescript
{
  success: true,
  actionTaken: "Created price reduction addendum for 123 Main St",
  result: {
    document: {
      id: "uuid",
      name: "Purchase Price Reduction Addendum",
      type: "addendum",
      templateId: "price_reduction",
      status: "sent",
      pdfUrl: "https://...",
      docusignEnvelopeId: "env-123"
    },
    priceChange: {
      originalPrice: 450000,
      newPrice: 435000,
      reductionAmount: 15000,
      reductionPercent: 3.33
    },
    escrowChange: {
      originalEscrow: 10000,
      newEscrow: 10000,
      adjusted: false
    },
    financingImpact: {
      originalLoanAmount: 360000,
      estimatedNewLoanAmount: 348000,
      downPaymentImpact: "May decrease by ~$12,000"
    },
    signers: [
      { name: "John Smith", email: "john@email.com", status: "sent" },
      { name: "Jane Doe", email: "jane@email.com", status: "sent" }
    ],
    nextSteps: [
      "Document sent for signature",
      "Notify lender of price change",
      "New appraisal may not be needed if reducing to appraised value",
      "Update title company on new price"
    ]
  }
}
```

## Voice Response

**Standard price reduction:**
> "Created a price reduction addendum for 123 Main Street.
>
> The price is reduced from $450,000 to $435,000 — that's $15,000 less.
>
> I've sent it to both parties for signature. Remember to update the lender once it's signed."

**Appraisal-related reduction:**
> "Created a price reduction based on the appraisal.
>
> The price drops from $450,000 to $435,000 to match the appraised value.
>
> This should satisfy the appraisal contingency. I've sent it out for signatures."

## Post-Signature Actions

When all parties sign:

1. Update document status to 'completed'
2. Update deal:
   - `purchasePrice` = new price
   - `originalPrice` = old price (for records)
3. Process escrow refund if applicable
4. Notify lender of price change
5. Notify title company
6. Log action

## Error Handling

| Error | Cause | Response |
|-------|-------|----------|
| `INVALID_PRICE` | Price <= 0 | "The new price must be greater than zero." |
| `PRICE_INCREASE` | New price > current | "This would be a price increase. Use a different addendum or confirm." |
| `EXCESSIVE_REDUCTION` | > 20% reduction | "That's a significant reduction (X%). Are you sure?" |
| `DEAL_NOT_ACTIVE` | Deal closed/cancelled | "This deal is no longer active." |
| `NO_PARTIES` | Missing buyer/seller | "I need both parties' information." |

## Common Reasons for Price Reduction

| Reason | Typical Reduction |
|--------|-------------------|
| Appraisal shortfall | To appraised value |
| Inspection findings | Repair cost estimate |
| Market adjustment | Negotiated amount |
| Seller motivation | Varies |
| Repair issues discovered | Cost of repairs |
| Condition disclosure | Varies |

## Quality Checklist

- [x] Calculates reduction from either new price or amount
- [x] Shows clear before/after comparison
- [x] Supports appraisal-related reductions
- [x] Optionally adjusts escrow
- [x] Notes financing impact
- [x] Florida-compliant language
- [x] Auto-sends for signature
- [x] Updates deal when signed
- [x] Notifies relevant parties
- [x] Handles multiple buyers/sellers
- [x] Creates complete audit trail
- [x] Clear voice response

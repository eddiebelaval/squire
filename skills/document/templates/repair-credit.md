# Skill: Repair Credit Addendum

**Category:** Document/Template
**Priority:** P0
**Approval Required:** No

## Purpose

Generate a Florida-compliant addendum for seller credit in lieu of repairs. This addendum is used when buyer and seller agree that the seller will provide a credit at closing instead of completing physical repairs to the property.

## Triggers

### Voice Commands
- "Create a repair credit for [amount]"
- "Seller credit of [amount] for repairs"
- "Add [amount] repair credit to [deal]"
- "Credit instead of repairs, [amount]"
- "Closing credit for [purpose]"
- "Seller contribution for repairs"

### Programmatic
- `POST /deals/:dealId/documents/addendum/repair-credit`
- `POST /deals/:dealId/documents/generate` with `templateId: repair_credit`
- Follow-up to repair request negotiation

## Required Inputs

| Input | Type | Required | Source | Default |
|-------|------|----------|--------|---------|
| `dealId` | UUID | Yes | context | - |
| `creditAmount` | number | Yes | voice | - |

## Optional Inputs

| Input | Type | Default | Source | Description |
|-------|------|---------|--------|-------------|
| `creditPurpose` | string | "repairs and improvements" | voice | What credit is for |
| `repairItems` | RepairItem[] | [] | manual | Specific items credit covers |
| `creditType` | string | 'closing_costs' | manual | How credit is applied |
| `lenderApproval` | boolean | false | manual | Credit requires lender OK |
| `maxCreditPercent` | number | null | manual | Lender limit on credits |
| `inspectionReference` | string | null | manual | Reference to inspection |
| `sendForSignature` | boolean | true | config | Auto-send to DocuSign |
| `signers` | Signer[] | from deal | config | Override signers |

## Credit Types

| Type | Description | Lender Considerations |
|------|-------------|----------------------|
| `closing_costs` | Applied to buyer's closing costs | Most common, lender limits apply |
| `price_reduction` | Reduces purchase price | Affects loan amount, appraisal |
| `escrow_credit` | Held in escrow for repairs | May require completion proof |
| `direct_credit` | Paid directly to buyer | Rare, may have issues |

## Execution Flow

```
START
  │
  ├─── 1. Load deal context
  │    ├── Get deal by ID
  │    ├── Get purchase price
  │    ├── Get buyer and seller from parties
  │    ├── Get financing type
  │    └── Check for existing credits
  │
  ├─── 2. Validate credit amount
  │    │
  │    ├── Check lender credit limits:
  │    │   ├── Conventional: typically 3-6% of price
  │    │   ├── FHA: up to 6%
  │    │   ├── VA: up to 4% (seller concessions)
  │    │   └── Cash: no limit
  │    │
  │    ├── Calculate total credits (existing + new)
  │    │
  │    ├── IF exceeds limit:
  │    │   └── Warn agent about lender limits
  │    │
  │    └── Check reasonableness vs purchase price
  │
  ├─── 3. Calculate impact
  │    ├── New effective price (if price reduction)
  │    ├── Seller net proceeds impact
  │    └── Buyer closing cost reduction
  │
  ├─── 4. Fill template
  │    ├── Property address
  │    ├── Buyer name(s)
  │    ├── Seller name(s)
  │    ├── Credit amount (number and words)
  │    ├── Credit purpose
  │    ├── Specific repair items
  │    ├── Credit application method
  │    └── Lender approval clause if needed
  │
  ├─── 5. Generate PDF
  │    └── Create PDF from filled template
  │
  ├─── 6. Create document record
  │    ├── type: 'addendum'
  │    ├── template_id: 'repair_credit'
  │    ├── status: 'draft' or 'sent'
  │    └── Store PDF URL
  │
  ├─── 7. IF sendForSignature:
  │    ├── Create signers
  │    │   ├── Buyer (required)
  │    │   └── Seller (required)
  │    │
  │    ├── INVOKE: send-for-signature skill
  │    │
  │    └── Update document status to 'sent'
  │
  ├─── 8. Queue deal updates (pending signature)
  │    └── Store credit to add when signed
  │
  ├─── 9. Log action
  │    └── action_type: 'document_generated'
  │
  └─── 10. Return result
```

## Template Content

```
ADDENDUM TO RESIDENTIAL CONTRACT FOR SALE AND PURCHASE
SELLER CREDIT FOR REPAIRS

Date: {{current_date}}

Property Address: {{deal.property_address.street}}
                  {{deal.property_address.city}}, {{deal.property_address.state}} {{deal.property_address.zip}}

Buyer(s): {{#each buyers}}{{this.name}}{{#unless @last}}, {{/unless}}{{/each}}
Seller(s): {{#each sellers}}{{this.name}}{{#unless @last}}, {{/unless}}{{/each}}

Effective Date of Original Contract: {{deal.effective_date}}

This Addendum is made a part of the above-referenced Contract for Sale and
Purchase ("Contract").

================================================================================
SELLER CREDIT IN LIEU OF REPAIRS
================================================================================

The parties agree to the following modification to the Contract:

1. CREDIT AMOUNT

   Seller agrees to provide Buyer with a credit at closing in the amount of:

   ${{creditAmount | currency}} ({{creditAmount | numberToWords}} dollars)

2. PURPOSE OF CREDIT

   This credit is provided in lieu of repairs and is specifically for:

   {{creditPurpose}}

{{#if repairItems.length > 0}}
3. ITEMS COVERED BY CREDIT

   The credit is provided in connection with the following items identified
   during Buyer's inspections:

   {{#each repairItems}}
   • {{this.item}}
     {{#if this.estimatedCost}}(Estimated cost: ${{this.estimatedCost | currency}}){{/if}}
   {{/each}}
{{/if}}

{{#if creditType === 'closing_costs'}}
4. APPLICATION OF CREDIT

   This credit shall be applied to Buyer's closing costs and/or prepaid items
   as reflected on the Closing Disclosure. Any unused portion of the credit
   shall remain with Seller.

   This credit is subject to lender approval and Buyer's lender's maximum
   allowable seller contributions.
{{/if}}

{{#if creditType === 'price_reduction'}}
4. APPLICATION OF CREDIT

   The Purchase Price stated in the Contract is hereby reduced by the credit
   amount. The new Purchase Price shall be:

   Original Purchase Price: ${{deal.purchasePrice | currency}}
   Less Credit:            (${{creditAmount | currency}})
   New Purchase Price:      ${{newPurchasePrice | currency}}
{{/if}}

{{#if creditType === 'escrow_credit'}}
4. APPLICATION OF CREDIT

   The credit amount shall be held in escrow by the closing agent and released
   to Buyer upon closing for the purpose of completing the specified repairs.

   Buyer acknowledges responsibility for completion of repairs after closing.
{{/if}}

5. PROPERTY CONDITION

   Buyer agrees to accept the Property in its present "AS-IS" condition with
   respect to the items covered by this credit. Seller shall have no further
   obligation to repair, replace, or remedy these items.

   This acceptance does not waive Buyer's rights regarding any defects not
   covered by this credit or any material defects not previously disclosed.

{{#if lenderApproval}}
6. LENDER APPROVAL

   This credit is contingent upon approval by Buyer's lender. If the lender
   does not approve the credit in whole or in part, the parties agree to
   negotiate in good faith regarding an alternative arrangement.
{{/if}}

7. EFFECT ON CONTRACT

   Except as modified by this Addendum, all terms and conditions of the
   Contract shall remain unchanged and in full force and effect.

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
  emailSubject: "Repair Credit Addendum - {{property_address}}",
  emailBlurb: "Please sign the attached Repair Credit Addendum for {{property_address}}. Seller agrees to a ${{creditAmount | currency}} credit at closing.",
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
  actionTaken: "Created $5,000 repair credit addendum for 123 Main St",
  result: {
    document: {
      id: "uuid",
      name: "Repair Credit Addendum",
      type: "addendum",
      templateId: "repair_credit",
      status: "sent",
      pdfUrl: "https://...",
      docusignEnvelopeId: "env-123"
    },
    credit: {
      amount: 5000,
      purpose: "HVAC repairs and roof maintenance",
      type: "closing_costs",
      items: [
        { item: "HVAC compressor replacement", estimatedCost: 3500 },
        { item: "Roof flashing repair", estimatedCost: 1200 }
      ]
    },
    lenderConsiderations: {
      financingType: "Conventional",
      maxAllowedCredit: 27000,  // 6% of $450,000
      totalCredits: 5000,
      withinLimits: true
    },
    signers: [
      { name: "John Smith", email: "john@email.com", status: "sent" },
      { name: "Jane Doe", email: "jane@email.com", status: "sent" }
    ],
    nextSteps: [
      "Document sent for signature",
      "Credit will be added to deal when signed",
      "Notify lender/title of seller credit"
    ]
  }
}
```

## Voice Response

> "Created a $5,000 repair credit addendum for 123 Main Street.
>
> The credit covers the HVAC and roof issues from the inspection. It'll be applied to closing costs.
>
> With a conventional loan, you can have up to $27,000 in seller credits — you're well within that limit.
>
> I've sent it to both parties for signature. Anything else for this deal?"

## Post-Signature Actions

When all parties sign:

1. Update document status to 'completed'
2. Add credit to deal:
   - Create credit record
   - Update deal financials
3. Notify title company
4. Alert lender if financing involved
5. Log action

## Error Handling

| Error | Cause | Response |
|-------|-------|----------|
| `EXCEEDS_LIMIT` | Credit > lender limit | "That credit exceeds the [X]% limit for [loan type]. Max is $[amount]." |
| `DEAL_NOT_ACTIVE` | Deal closed/cancelled | "This deal is no longer active." |
| `NO_BUYER` | Buyer missing | "I need the buyer's info to send for signature." |
| `NO_SELLER` | Seller missing | "I need the seller's info to send for signature." |
| `INVALID_AMOUNT` | Amount <= 0 | "The credit amount needs to be a positive number." |

## Lender Credit Limits

| Loan Type | Owner Occupied | Investment | Down Payment Factor |
|-----------|---------------|------------|---------------------|
| Conventional | 3-6% | 2% | Higher down = higher limit |
| FHA | 6% | N/A | All purchases |
| VA | 4% | N/A | Seller concessions |
| USDA | 6% | N/A | All purchases |
| Cash | Unlimited | Unlimited | N/A |

## Quality Checklist

- [x] Validates credit against lender limits
- [x] Supports multiple credit types
- [x] Includes specific repair items
- [x] Calculates impact on deal
- [x] Florida-compliant language
- [x] Auto-sends for signature
- [x] Updates deal financials when signed
- [x] Handles multiple buyers/sellers
- [x] Creates audit trail
- [x] Warns about lender approval needs
- [x] Clear voice response

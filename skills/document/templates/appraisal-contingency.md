# Skill: Appraisal Contingency Addendum

**Category:** Document/Template
**Priority:** P0
**Approval Required:** No

## Purpose

Generate Florida-compliant addenda related to appraisal contingencies. This skill handles appraisal shortfall responses, contingency modifications, appraisal gap coverage agreements, and contingency waivers.

## Triggers

### Voice Commands
- "Create appraisal addendum"
- "Appraisal came in at [amount]"
- "Handle appraisal shortfall of [amount]"
- "Buyer will cover the appraisal gap"
- "Waive appraisal contingency"
- "Modify appraisal terms"
- "Appraisal gap coverage of [amount]"

### Programmatic
- `POST /deals/:dealId/documents/addendum/appraisal-contingency`
- `POST /deals/:dealId/documents/generate` with `templateId: appraisal_contingency`
- Triggered after appraisal report received

## Required Inputs

| Input | Type | Required | Source | Default |
|-------|------|----------|--------|---------|
| `dealId` | UUID | Yes | context | - |
| `addendumSubtype` | string | Yes | voice/manual | See subtypes below |

## Addendum Subtypes

| Subtype | Description | Common Use |
|---------|-------------|------------|
| `shortfall_response` | Respond to low appraisal | Buyer elects option |
| `gap_coverage` | Buyer covers appraisal gap | Competitive offers |
| `waiver` | Remove appraisal contingency | Cash/strong buyers |
| `price_adjustment` | Reduce to appraised value | Negotiation result |
| `extension` | More time for new appraisal | Disputed appraisal |

## Optional Inputs

| Input | Type | Default | Source | Description |
|-------|------|---------|--------|-------------|
| `appraisedValue` | number | null | manual | Appraised value |
| `gapAmount` | number | calculated | manual | Difference from price |
| `buyerCoverageAmount` | number | null | manual | Amount buyer will cover |
| `maxGapCoverage` | number | null | manual | Buyer's max gap coverage |
| `newPrice` | number | null | manual | If reducing price |
| `buyerElection` | string | null | voice | terminate/proceed/negotiate |
| `reappraisalRequested` | boolean | false | manual | Request new appraisal |
| `sendForSignature` | boolean | true | config | Auto-send |

## Execution Flow

```
START
  │
  ├─── 1. Load deal context
  │    ├── Get deal by ID
  │    ├── Get purchase price
  │    ├── Get financing details
  │    ├── Get buyer and seller
  │    └── Check appraisal contingency status
  │
  ├─── 2. Process based on subtype
  │    │
  │    ├── IF shortfall_response:
  │    │   ├── Calculate gap (price - appraisal)
  │    │   ├── Determine buyer options
  │    │   └── Document buyer's election
  │    │
  │    ├── IF gap_coverage:
  │    │   ├── Validate coverage amount
  │    │   ├── Calculate max exposure
  │    │   └── Structure coverage agreement
  │    │
  │    ├── IF waiver:
  │    │   ├── Confirm buyer understands risk
  │    │   └── Remove contingency protection
  │    │
  │    ├── IF price_adjustment:
  │    │   ├── Calculate new price
  │    │   └── INVOKE: price-reduction template
  │    │
  │    └── IF extension:
  │        ├── Set new deadline
  │        └── Document reason
  │
  ├─── 3. Validate inputs
  │    ├── Appraised value is reasonable
  │    ├── Coverage amount is valid
  │    └── Elections are clear
  │
  ├─── 4. Fill appropriate template
  │    └── Based on subtype selected
  │
  ├─── 5. Generate PDF
  │    └── Create PDF from template
  │
  ├─── 6. Create document record
  │    ├── type: 'addendum'
  │    ├── template_id: 'appraisal_contingency'
  │    ├── subtype: addendumSubtype
  │    └── Store PDF URL
  │
  ├─── 7. IF sendForSignature:
  │    ├── Create signers
  │    ├── INVOKE: send-for-signature skill
  │    └── Update status
  │
  ├─── 8. Queue appropriate updates
  │    └── Based on subtype and elections
  │
  ├─── 9. Log action
  │
  └─── 10. Return result
```

## Template Content - Shortfall Response

```
ADDENDUM TO RESIDENTIAL CONTRACT FOR SALE AND PURCHASE
APPRAISAL CONTINGENCY - BUYER'S RESPONSE TO SHORTFALL

Date: {{current_date}}

Property Address: {{deal.property_address.street}}
                  {{deal.property_address.city}}, {{deal.property_address.state}} {{deal.property_address.zip}}

Buyer(s): {{#each buyers}}{{this.name}}{{#unless @last}}, {{/unless}}{{/each}}
Seller(s): {{#each sellers}}{{this.name}}{{#unless @last}}, {{/unless}}{{/each}}

Contract Effective Date: {{deal.effective_date}}

================================================================================
APPRAISAL RESULTS
================================================================================

The Property has been appraised as follows:

Contract Purchase Price:    ${{purchasePrice | currency}}
Appraised Value:           ${{appraisedValue | currency}}
Shortfall Amount:          ${{gapAmount | currency}}

================================================================================
BUYER'S ELECTION
================================================================================

Pursuant to the appraisal contingency provisions of the Contract, Buyer hereby
elects the following option:

{{#if buyerElection === 'terminate'}}
☑ OPTION 1: TERMINATE CONTRACT

  Buyer elects to terminate the Contract based on the appraisal shortfall.
  Buyer is entitled to a full refund of the earnest money deposit.

  Buyer waives any further claims against Seller arising from the appraisal
  or this transaction.
{{/if}}

{{#if buyerElection === 'proceed'}}
☑ OPTION 2: PROCEED AT CONTRACT PRICE

  Buyer elects to proceed with the purchase at the original Contract price
  of ${{purchasePrice | currency}}, notwithstanding the lower appraised value.

  Buyer acknowledges:
  • Additional cash may be required at closing
  • Loan-to-value ratio will be affected
  • Lender approval of revised terms may be required

  Buyer agrees to increase down payment by approximately ${{gapAmount | currency}}
  or as required by lender.
{{/if}}

{{#if buyerElection === 'negotiate'}}
☑ OPTION 3: NEGOTIATE NEW TERMS

  Buyer proposes to proceed with the purchase under modified terms:

  {{#if newPrice}}
  Proposed New Purchase Price: ${{newPrice | currency}}
  {{/if}}

  {{#if buyerCoverageAmount}}
  Buyer will cover gap up to: ${{buyerCoverageAmount | currency}}
  Seller to reduce price by: ${{sellerReduction | currency}}
  {{/if}}

  This proposal is subject to Seller's acceptance. If Seller does not accept
  within {{responseDays}} days, Buyer reserves the right to terminate per the
  Contract terms.
{{/if}}

{{#if buyerElection === 'reappraisal'}}
☑ OPTION 4: REQUEST REAPPRAISAL

  Buyer disputes the appraisal findings and requests:

  ☐ Reconsideration of Value (same appraiser)
  ☐ Second appraisal (different appraiser)

  Buyer understands additional costs may apply and timing may extend.
{{/if}}

================================================================================
ACKNOWLEDGMENTS
================================================================================

Buyer acknowledges and understands:

1. The appraised value is an opinion of value, not a guarantee of worth
2. Buyer has reviewed the appraisal report
3. This election is binding once signed by all parties
4. Time is of the essence regarding the appraisal contingency deadline

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

{{#if buyerElection === 'negotiate'}}
SELLER'S RESPONSE TO PROPOSAL:

☐ ACCEPTED - Seller agrees to the proposed terms
☐ REJECTED - Seller declines; Buyer may terminate
☐ COUNTER - Seller proposes: _____________________________

SELLER:                                   DATE:
_________________________________        _______________
{{sellers.[0].name}}

{{#if sellers.[1]}}
_________________________________        _______________
{{sellers.[1].name}}
{{/if}}
{{/if}}
```

## Template Content - Gap Coverage

```
ADDENDUM TO RESIDENTIAL CONTRACT FOR SALE AND PURCHASE
APPRAISAL GAP COVERAGE AGREEMENT

Date: {{current_date}}

Property Address: {{deal.property_address.street}}
                  {{deal.property_address.city}}, {{deal.property_address.state}} {{deal.property_address.zip}}

Buyer(s): {{#each buyers}}{{this.name}}{{#unless @last}}, {{/unless}}{{/each}}
Seller(s): {{#each sellers}}{{this.name}}{{#unless @last}}, {{/unless}}{{/each}}

Contract Effective Date: {{deal.effective_date}}

================================================================================
APPRAISAL GAP COVERAGE
================================================================================

1. BUYER'S COMMITMENT

   Buyer agrees to cover any appraisal shortfall up to a maximum of:

   ${{maxGapCoverage | currency}} ({{maxGapCoverage | numberToWords}} dollars)

   This means if the Property appraises for less than the Purchase Price,
   Buyer will pay the difference (up to the maximum stated above) in addition
   to Buyer's down payment.

2. CALCULATION EXAMPLE

   Purchase Price:              ${{purchasePrice | currency}}
   If Appraisal comes in at:    $(appraised value)
   Shortfall/Gap:               $(purchase price - appraised value)

   If Shortfall ≤ ${{maxGapCoverage | currency}}: Buyer covers full gap
   If Shortfall > ${{maxGapCoverage | currency}}: Parties to negotiate

3. SOURCE OF FUNDS

   Buyer represents that Buyer has sufficient funds to cover the potential
   gap amount in addition to the required down payment and closing costs.

   {{#if proofOfFunds}}
   Buyer has provided proof of funds demonstrating ability to cover gap.
   {{/if}}

4. CONTINGENCY MODIFICATION

   {{#if waivesContingency}}
   Buyer WAIVES the appraisal contingency entirely and agrees to proceed
   regardless of appraised value.
   {{else}}
   The appraisal contingency remains in effect for any shortfall exceeding
   the maximum gap coverage amount stated above.
   {{/if}}

5. LENDER REQUIREMENTS

   Buyer acknowledges that lender approval may still be required and that
   lender's loan-to-value requirements must be satisfied.

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

## Output

```typescript
{
  success: true,
  actionTaken: "Created appraisal shortfall response for 123 Main St",
  result: {
    document: {
      id: "uuid",
      name: "Appraisal Contingency - Buyer Response",
      type: "addendum",
      templateId: "appraisal_contingency",
      subtype: "shortfall_response",
      status: "sent",
      pdfUrl: "https://...",
      docusignEnvelopeId: "env-123"
    },
    appraisal: {
      purchasePrice: 450000,
      appraisedValue: 435000,
      shortfall: 15000
    },
    buyerElection: {
      election: "proceed",
      additionalCashNeeded: 15000,
      requiresLenderApproval: true
    },
    signers: [
      { name: "John Smith", email: "john@email.com", status: "sent" },
      { name: "Jane Doe", email: "jane@email.com", status: "sent" }
    ],
    nextSteps: [
      "Document sent for signature",
      "Buyer will need approximately $15,000 additional at closing",
      "Notify lender of buyer's election to proceed",
      "Verify buyer has funds for increased down payment"
    ]
  }
}
```

## Voice Response

**Shortfall - Proceed:**
> "I've documented that the buyer will proceed despite the $15,000 appraisal shortfall.
>
> John will need about $15,000 more at closing to cover the gap. Make sure he has the funds and that the lender is aware.
>
> Sent to both parties for signature."

**Gap Coverage:**
> "Created an appraisal gap coverage addendum for 123 Main Street.
>
> The buyer agrees to cover up to $20,000 if the appraisal comes in low. This strengthens the offer.
>
> Sent for signature."

**Waiver:**
> "Created an appraisal contingency waiver.
>
> The buyer is removing appraisal protection entirely - they'll proceed at contract price regardless of appraisal.
>
> Make sure they understand the risk. Sent for signature."

## Error Handling

| Error | Cause | Response |
|-------|-------|----------|
| `NO_APPRAISAL_CONTINGENCY` | Contingency already waived | "There's no appraisal contingency to address." |
| `INVALID_VALUE` | Appraised value unreasonable | "That appraised value seems off. Can you confirm?" |
| `EXCESSIVE_GAP` | Gap > 20% of price | "That's a significant shortfall. Are you sure about the values?" |
| `MISSING_ELECTION` | No buyer choice specified | "What does the buyer want to do - proceed, terminate, or negotiate?" |
| `DEAL_NOT_ACTIVE` | Deal closed/cancelled | "This deal is no longer active." |

## Florida-Specific Notes

- FAR/BAR contracts typically include appraisal contingencies for financed purchases
- Buyers generally have right to terminate if appraisal < purchase price
- Gap coverage is becoming common in competitive markets
- Lender still must approve modified terms
- Cash buyers may not have appraisal contingency

## Quality Checklist

- [x] Handles all appraisal scenarios
- [x] Calculates gap/shortfall correctly
- [x] Documents buyer's election clearly
- [x] Supports gap coverage agreements
- [x] Allows contingency waiver
- [x] Routes to price reduction when needed
- [x] Florida-compliant language
- [x] Auto-sends for signature
- [x] Updates deal when signed
- [x] Clear voice responses
- [x] Complete audit trail

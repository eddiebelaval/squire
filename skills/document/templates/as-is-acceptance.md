# Skill: As-Is Acceptance Addendum

**Category:** Document/Template
**Priority:** P0
**Approval Required:** No

## Purpose

Generate a Florida-compliant addendum documenting buyer's acceptance of the property in its current "as-is" condition. This is used when the buyer elects to waive repair requests after inspection and proceed with the purchase without requiring the seller to make repairs or provide credits.

## Triggers

### Voice Commands
- "Accept property as-is"
- "Waive repairs for [address]"
- "Buyer accepts as-is"
- "No repairs requested"
- "Accept inspection findings"
- "Proceed without repairs"
- "Clear inspection contingency"

### Programmatic
- `POST /deals/:dealId/documents/addendum/as-is-acceptance`
- `POST /deals/:dealId/documents/generate` with `templateId: as_is_acceptance`
- Follow-up to inspection period expiration

## Required Inputs

| Input | Type | Required | Source | Default |
|-------|------|----------|--------|---------|
| `dealId` | UUID | Yes | context | - |

## Optional Inputs

| Input | Type | Default | Source | Description |
|-------|------|---------|--------|-------------|
| `inspectionDate` | Date | null | manual | When inspection occurred |
| `inspectorName` | string | null | manual | Inspector name |
| `acknowledgedIssues` | string[] | [] | manual | Known issues accepted |
| `excludedItems` | string[] | [] | manual | Items NOT accepted as-is |
| `sellerDisclosures` | boolean | true | manual | Seller disclosed items |
| `walkthrough` | boolean | false | manual | Include final walkthrough |
| `sendForSignature` | boolean | true | config | Auto-send to DocuSign |
| `signers` | Signer[] | from deal | config | Override signers |

## Execution Flow

```
START
  │
  ├─── 1. Load deal context
  │    ├── Get deal by ID
  │    ├── Verify deal is active
  │    ├── Check inspection period status
  │    ├── Get buyer and seller parties
  │    └── Get inspection-related documents
  │
  ├─── 2. Validate timing
  │    │
  │    ├── IF within inspection period:
  │    │   └── Proceed (buyer exercising right)
  │    │
  │    ├── IF after inspection period:
  │    │   ├── Note: May already be as-is by default
  │    │   └── Document formalizes acceptance
  │    │
  │    └── Check for pending repair requests
  │        └── IF pending → warn about superseding
  │
  ├─── 3. Process acknowledged issues
  │    ├── Format known issues list
  │    ├── Ensure buyer understands scope
  │    └── Document what buyer accepts
  │
  ├─── 4. Handle exclusions (if any)
  │    └── Items buyer does NOT accept as-is
  │        (seller must still address these)
  │
  ├─── 5. Fill template
  │    ├── Property address
  │    ├── Buyer name(s)
  │    ├── Seller name(s)
  │    ├── Inspection details
  │    ├── Acknowledged issues
  │    ├── Exclusions
  │    └── Walkthrough language
  │
  ├─── 6. Generate PDF
  │    └── Create PDF from template
  │
  ├─── 7. Create document record
  │    ├── type: 'addendum'
  │    ├── template_id: 'as_is_acceptance'
  │    ├── status: 'draft' or 'sent'
  │    └── Store PDF URL
  │
  ├─── 8. IF sendForSignature:
  │    ├── Create signers
  │    │   ├── Buyer (required - acknowledging)
  │    │   └── Seller (optional - acknowledgment)
  │    │
  │    ├── INVOKE: send-for-signature skill
  │    └── Update status
  │
  ├─── 9. Update deal status
  │    ├── Mark inspection contingency satisfied
  │    └── Cancel any pending repair requests
  │
  ├─── 10. Log action
  │     └── action_type: 'document_generated'
  │
  └─── 11. Return result
```

## Template Content

```
ADDENDUM TO RESIDENTIAL CONTRACT FOR SALE AND PURCHASE
BUYER'S AS-IS ACCEPTANCE

Date: {{current_date}}

Property Address: {{deal.property_address.street}}
                  {{deal.property_address.city}}, {{deal.property_address.state}} {{deal.property_address.zip}}

Buyer(s): {{#each buyers}}{{this.name}}{{#unless @last}}, {{/unless}}{{/each}}
Seller(s): {{#each sellers}}{{this.name}}{{#unless @last}}, {{/unless}}{{/each}}

Contract Effective Date: {{deal.effective_date}}

This Addendum is made a part of the above-referenced Contract for Sale and
Purchase ("Contract").

================================================================================
AS-IS ACCEPTANCE
================================================================================

1. BUYER'S ACCEPTANCE

   Buyer hereby accepts the Property in its present "AS-IS" condition with
   respect to all physical components, fixtures, and systems.

   Buyer has had the opportunity to conduct inspections and investigations
   of the Property and is satisfied with the condition of the Property.

{{#if inspectionDate}}
2. INSPECTIONS CONDUCTED

   Buyer conducted or had the opportunity to conduct the following inspections:

   Date of Inspection: {{inspectionDate | formatDate}}
   {{#if inspectorName}}
   Inspector: {{inspectorName}}
   {{/if}}

   Buyer has reviewed the inspection report(s) and understands the findings.
{{/if}}

{{#if acknowledgedIssues.length > 0}}
3. ACKNOWLEDGED CONDITIONS

   Buyer specifically acknowledges awareness of the following conditions and
   accepts the Property notwithstanding these items:

   {{#each acknowledgedIssues}}
   • {{this}}
   {{/each}}

   Buyer agrees that Seller shall have no obligation to repair, replace, or
   remedy any of the above-listed items.
{{else}}
3. GENERAL ACCEPTANCE

   Buyer accepts the Property in its current condition without requiring
   Seller to repair, replace, or remedy any items.
{{/if}}

{{#if excludedItems.length > 0}}
4. EXCLUSIONS FROM AS-IS ACCEPTANCE

   The following items are NOT included in this As-Is acceptance and remain
   subject to repair or resolution by Seller:

   {{#each excludedItems}}
   • {{this}}
   {{/each}}

   Seller agrees to address the above items prior to closing.
{{/if}}

5. WAIVER OF REPAIR RIGHTS

   By executing this Addendum, Buyer waives any right to request repairs or
   credits under the inspection contingency provisions of the Contract.

   Buyer acknowledges that this waiver is voluntary and made with full
   knowledge of the Property's condition.

6. SELLER'S DISCLOSURE OBLIGATIONS

   This As-Is acceptance does not relieve Seller of:

   • Disclosure obligations under Florida law
   • Responsibility for known material defects not previously disclosed
   • Any express warranties made in the Contract
   • Obligations regarding items specifically excluded above

{{#if sellerDisclosures}}
   Buyer acknowledges receipt and review of Seller's Property Disclosure
   Statement.
{{/if}}

7. PROPERTY CONDITION AT CLOSING

   Seller agrees to maintain the Property in its present condition through
   closing, subject to ordinary wear and tear.

   Seller shall not remove any fixtures or items included in the sale.

{{#if walkthrough}}
8. FINAL WALKTHROUGH

   Buyer reserves the right to conduct a final walkthrough inspection prior
   to closing to verify:

   • The Property is in substantially the same condition as of the date of
     this acceptance
   • All items included in the sale remain on the Property
   • No new damage has occurred
   • Any excluded items have been addressed by Seller

   This walkthrough right is not waived by this As-Is acceptance.
{{/if}}

9. EFFECT ON CONTRACT

   Except as modified by this Addendum, all terms and conditions of the
   Contract shall remain unchanged and in full force and effect.

   This Addendum satisfies Buyer's inspection contingency obligations under
   the Contract.

================================================================================
ACKNOWLEDGMENT
================================================================================

By signing below, Buyer acknowledges and confirms:

☐ Buyer has had adequate opportunity to inspect the Property
☐ Buyer understands the condition of the Property
☐ Buyer is not relying on Seller to make any repairs
☐ Buyer is accepting the Property voluntarily in As-Is condition
☐ Buyer has read and understands this Addendum

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

SELLER ACKNOWLEDGMENT (Optional):

Seller acknowledges receipt of Buyer's As-Is Acceptance.

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
  emailSubject: "As-Is Property Acceptance - {{property_address}}",
  emailBlurb: "Buyer has accepted the property at {{property_address}} in As-Is condition. Please review and acknowledge.",
  signers: [
    {
      role: "buyer",
      routingOrder: 1,
      required: true,
      tabs: {
        signHere: { anchorString: "BUYER:", anchorYOffset: 20 },
        dateSigned: { anchorString: "DATE:", anchorYOffset: 20, anchorXOffset: -100 },
        checkboxes: [
          { anchorString: "☐ Buyer has had", required: true },
          { anchorString: "☐ Buyer understands", required: true },
          { anchorString: "☐ Buyer is not", required: true },
          { anchorString: "☐ Buyer is accepting", required: true },
          { anchorString: "☐ Buyer has read", required: true }
        ]
      }
    },
    {
      role: "seller",
      routingOrder: 2,
      required: false,  // Optional acknowledgment
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
  actionTaken: "Created as-is acceptance for 123 Main St",
  result: {
    document: {
      id: "uuid",
      name: "As-Is Property Acceptance",
      type: "addendum",
      templateId: "as_is_acceptance",
      status: "sent",
      pdfUrl: "https://...",
      docusignEnvelopeId: "env-123"
    },
    acceptance: {
      fullAsIs: true,
      acknowledgedIssues: [
        "HVAC system is 15 years old",
        "Roof has 5-7 years remaining life",
        "Minor settling cracks in garage"
      ],
      exclusions: []
    },
    inspection: {
      date: "2026-01-10",
      inspector: "ABC Home Inspections"
    },
    contingencyStatus: {
      inspection: "satisfied",
      previousRepairRequests: "superseded"
    },
    signers: [
      { name: "John Smith", email: "john@email.com", role: "buyer", status: "sent" },
      { name: "Jane Doe", email: "jane@email.com", role: "seller", status: "optional" }
    ],
    nextSteps: [
      "Sent to buyer for signature",
      "Seller acknowledgment is optional",
      "Inspection contingency will be satisfied when signed",
      "Transaction can proceed to next phase"
    ]
  }
}
```

## Voice Response

**Full as-is acceptance:**
> "I've created an as-is acceptance for 123 Main Street.
>
> The buyer is accepting the property without requiring any repairs. I've listed the major inspection findings so they're on record.
>
> Sent to John Smith for signature. The seller acknowledgment is optional but recommended.
>
> Once signed, we're clear on inspection. Ready to move forward!"

**Partial acceptance (with exclusions):**
> "Created an as-is acceptance with one exception.
>
> The buyer accepts everything except the water heater issue — the seller still needs to address that.
>
> Sent for signatures. Make sure the seller understands that exclusion."

## Post-Signature Actions

When buyer signs:

1. Update document status to 'completed'
2. Update deal:
   - Inspection contingency → 'satisfied'
   - Close any pending repair requests
3. Update deadline status
4. Notify seller/listing agent
5. Log action

## Error Handling

| Error | Cause | Response |
|-------|-------|----------|
| `INSPECTION_EXPIRED` | Past inspection deadline | "The inspection period has passed. This acceptance may be moot, but we can document it." |
| `PENDING_REPAIR_REQUEST` | Repair request outstanding | "There's a pending repair request. This as-is acceptance will supersede it. Confirm?" |
| `DEAL_NOT_ACTIVE` | Deal closed/cancelled | "This deal is no longer active." |
| `NO_BUYER` | Buyer info missing | "I need the buyer's contact info to send for signature." |
| `ALREADY_AS_IS` | Contract is already as-is | "This contract is already as-is. Do you want to document the inspection acceptance anyway?" |

## When to Use As-Is Acceptance

| Scenario | Use As-Is? | Notes |
|----------|-----------|-------|
| Buyer satisfied with condition | Yes | Clean acceptance |
| Minor issues found | Yes | Document acknowledged issues |
| Major issues, no repairs wanted | Yes | Document for record |
| Some issues accepted, some not | Partial | Use exclusions |
| Want repairs/credit | No | Use repair request instead |
| Contract already as-is | Optional | Can still document acceptance |

## Florida-Specific Notes

- FAR/BAR "As-Is" contracts already limit repair obligations
- This addendum formalizes buyer's acceptance after inspection
- Seller still liable for undisclosed material defects
- Document acknowledgment protects both parties
- Final walkthrough rights should be preserved

## Quality Checklist

- [x] Documents buyer's informed acceptance
- [x] Lists acknowledged issues
- [x] Supports partial acceptance with exclusions
- [x] Preserves seller disclosure obligations
- [x] Includes optional seller acknowledgment
- [x] Preserves walkthrough rights
- [x] Florida-compliant language
- [x] Satisfies inspection contingency
- [x] Supersedes pending repair requests
- [x] Handles co-buyers
- [x] Clear voice response
- [x] Complete audit trail

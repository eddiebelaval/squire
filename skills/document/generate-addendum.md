# Skill: Generate Addendum

**Category:** Document
**Priority:** P0
**Approval Required:** No (draft) / Yes (send for signature)

## Purpose

Generate a Florida-compliant addendum to modify any aspect of an existing real estate contract. This is the master addendum generator that can create custom addenda or route to specific templates based on the modification type.

## Triggers

### Voice Commands
- "Create an addendum for [deal/address]"
- "Add addendum to [address]"
- "I need an addendum for [modification type]"
- "Generate addendum for [purpose]"
- "Draft addendum to change [term]"

### Programmatic
- `POST /deals/:dealId/documents/addendum`
- Agent dashboard "New Addendum" button
- Other skills invoking addendum generation

## Required Inputs

| Input | Type | Required | Source | Description |
|-------|------|----------|--------|-------------|
| `dealId` | UUID | Yes | context | Active deal identifier |
| `addendumType` | string | Yes | voice/manual | Type of addendum (see types below) |

## Optional Inputs

| Input | Type | Default | Source | Description |
|-------|------|---------|--------|-------------|
| `modifications` | Modification[] | [] | voice/manual | List of changes to make |
| `effectiveDate` | Date | today | manual | When addendum takes effect |
| `reason` | string | null | voice | Explanation for the changes |
| `customTerms` | string | null | manual | Free-form additional terms |
| `sendForSignature` | boolean | true | config | Auto-send to DocuSign |
| `signers` | Signer[] | from deal | config | Override default signers |
| `urgency` | string | 'normal' | voice | 'urgent', 'normal', 'low' |

## Addendum Types

| Type | Description | Routes To |
|------|-------------|-----------|
| `inspection_extension` | Extend inspection period | templates/inspection-extension |
| `closing_extension` | Extend closing date | templates/closing-extension |
| `financing_extension` | Extend financing contingency | templates/financing-extension |
| `price_reduction` | Reduce purchase price | templates/price-reduction |
| `price_increase` | Increase purchase price | custom generation |
| `repair_credit` | Credit for repairs | templates/repair-credit |
| `appraisal_contingency` | Modify appraisal terms | templates/appraisal-contingency |
| `escrow_modification` | Change escrow terms | custom generation |
| `closing_cost_credit` | Seller credit to buyer | custom generation |
| `possession_change` | Change possession date/terms | custom generation |
| `contingency_waiver` | Waive a contingency | custom generation |
| `contingency_addition` | Add a contingency | custom generation |
| `party_change` | Add/remove buyer/seller | custom generation |
| `custom` | Free-form addendum | custom generation |

## Execution Flow

```
START
  │
  ├─── 1. Validate deal context
  │    ├── Verify deal exists and is active
  │    ├── Load all deal data
  │    ├── Get all parties with contact info
  │    └── Check for pending addenda on same topic
  │
  ├─── 2. Determine addendum type
  │    │
  │    ├── IF specific template exists:
  │    │   └── INVOKE: specific template skill
  │    │       └── Return result from template
  │    │
  │    └── IF custom addendum needed:
  │        └── Continue to step 3
  │
  ├─── 3. Parse modifications
  │    ├── Extract what's being changed
  │    ├── Get current value from deal
  │    ├── Get new value from input
  │    └── Format as "FROM X TO Y" statements
  │
  ├─── 4. Build addendum content
  │    ├── Standard header (date, parties, property)
  │    ├── Reference to original contract
  │    ├── Numbered list of modifications
  │    ├── Reason (if provided)
  │    ├── Additional terms
  │    └── Standard footer (other terms unchanged)
  │
  ├─── 5. Generate document
  │    ├── Apply template
  │    ├── Generate PDF
  │    └── Store in document storage
  │
  ├─── 6. Create document record
  │    ├── type: 'addendum'
  │    ├── subtype: addendumType
  │    ├── status: 'draft'
  │    ├── Store all modifications
  │    └── Link to deal
  │
  ├─── 7. IF sendForSignature:
  │    ├── Configure signers (all parties typically)
  │    ├── Set urgency-based expiration
  │    ├── INVOKE: send-for-signature skill
  │    └── Update status to 'pending_signature'
  │
  ├─── 8. Queue pending updates
  │    └── Store what should change when signed
  │        (deadlines, prices, terms, etc.)
  │
  ├─── 9. Log action
  │    └── action_type: 'addendum_generated'
  │
  └─── 10. Return result
```

## Template Content (Custom Addendum)

```
ADDENDUM TO CONTRACT FOR SALE AND PURCHASE

Date: {{currentDate | formatDate}}

Property Address: {{deal.address.street}}
                  {{deal.address.city}}, {{deal.address.state}} {{deal.address.zip}}

Buyer(s): {{#each buyers}}{{this.name}}{{#unless @last}}, {{/unless}}{{/each}}
Seller(s): {{#each sellers}}{{this.name}}{{#unless @last}}, {{/unless}}{{/each}}

Original Contract Effective Date: {{deal.effectiveDate | formatDate}}

This Addendum is made a part of the above-referenced Contract for Sale and
Purchase ("Contract") and shall supersede any conflicting provisions therein.

================================================================================
MODIFICATIONS
================================================================================

The parties agree to modify the Contract as follows:

{{#each modifications}}
{{@index + 1}}. {{this.description}}
   {{#if this.from}}FROM: {{this.from}}{{/if}}
   {{#if this.to}}TO: {{this.to}}{{/if}}
   {{#if this.details}}
   Details: {{this.details}}
   {{/if}}

{{/each}}

{{#if reason}}
================================================================================
REASON FOR MODIFICATION
================================================================================

{{reason}}
{{/if}}

{{#if customTerms}}
================================================================================
ADDITIONAL TERMS
================================================================================

{{customTerms}}
{{/if}}

================================================================================
GENERAL PROVISIONS
================================================================================

1. All other terms and conditions of the Contract not modified by this Addendum
   shall remain unchanged and in full force and effect.

2. In the event of any conflict between this Addendum and the original Contract,
   the terms of this Addendum shall control.

3. Time remains of the essence for all provisions of the Contract.

4. This Addendum shall be effective as of {{effectiveDate | formatDate}}.

================================================================================
SIGNATURES
================================================================================

By signing below, the parties acknowledge and agree to the modifications
set forth in this Addendum.

BUYER:
_________________________________    Date: ____________
{{buyers.[0].name}}

{{#if buyers.[1]}}
_________________________________    Date: ____________
{{buyers.[1].name}}
{{/if}}

SELLER:
_________________________________    Date: ____________
{{sellers.[0].name}}

{{#if sellers.[1]}}
_________________________________    Date: ____________
{{sellers.[1].name}}
{{/if}}
```

## DocuSign Configuration

```typescript
const docusignConfig = {
  emailSubject: "Addendum to Contract - {{property_address}}",
  emailBlurb: "Please review and sign the attached Addendum to the Contract for {{property_address}}.",
  urgencySettings: {
    urgent: { expirationDays: 1, reminderDays: 0 },
    normal: { expirationDays: 3, reminderDays: 1 },
    low: { expirationDays: 7, reminderDays: 3 }
  },
  signers: [
    {
      role: "buyer",
      routingOrder: 1,
      tabs: {
        signHere: { anchorString: "BUYER:", anchorYOffset: 20 },
        dateSigned: { anchorString: "Date:", anchorYOffset: 0, anchorXOffset: 100 }
      }
    },
    {
      role: "seller",
      routingOrder: 2,
      tabs: {
        signHere: { anchorString: "SELLER:", anchorYOffset: 20 },
        dateSigned: { anchorString: "Date:", anchorYOffset: 0, anchorXOffset: 100 }
      }
    }
  ]
};
```

## Output

```typescript
{
  success: true,
  actionTaken: "Generated addendum to modify purchase price for 123 Main St",
  result: {
    document: {
      id: "uuid",
      name: "Contract Addendum - Price Modification",
      type: "addendum",
      subtype: "price_reduction",
      status: "pending_signature",
      pdfUrl: "https://...",
      docusignEnvelopeId: "env-123"
    },
    modifications: [
      {
        field: "purchasePrice",
        from: "$450,000",
        to: "$440,000",
        description: "Purchase price reduced by $10,000"
      }
    ],
    signers: [
      { name: "John Smith", email: "john@email.com", role: "buyer", status: "sent" },
      { name: "Jane Doe", email: "jane@email.com", role: "seller", status: "pending" }
    ],
    pendingUpdates: [
      { field: "purchasePrice", newValue: 440000 }
    ],
    nextSteps: [
      "Addendum sent to John Smith (buyer) for signature",
      "After buyer signs, it will be sent to Jane Doe (seller)",
      "Deal will be updated automatically when both parties sign"
    ]
  }
}
```

## Voice Response

**Standard addendum:**
> "I've created an addendum to reduce the purchase price from $450,000 to $440,000.
>
> I've sent it to John Smith for signature. Once he signs, it'll go to Jane Doe.
>
> The deal will update automatically when both parties sign. Anything else?"

**Template-routed addendum:**
> "Creating an inspection extension addendum..."
> [Returns response from templates/inspection-extension skill]

## Post-Signature Actions

When all parties sign (via DocuSign webhook):

1. Update document status to 'completed'
2. Apply all pending updates to the deal:
   - Update modified fields
   - Recalculate deadlines if dates changed
   - Adjust related values
3. Store signed PDF
4. Notify agent: "Addendum signed. [Field] updated to [value]"
5. Log action with all changes made
6. If deadline was extended, reschedule alerts

## Error Handling

| Error | Cause | Response |
|-------|-------|----------|
| `DEAL_NOT_ACTIVE` | Deal is closed/cancelled | "This deal is no longer active. Cannot create addendum." |
| `MISSING_PARTIES` | Buyer or seller missing | "I need [buyer/seller] contact info to send for signature." |
| `CONFLICTING_ADDENDUM` | Pending addendum on same topic | "There's already a pending addendum for [topic]. Sign or void that first?" |
| `INVALID_MODIFICATION` | Invalid field or value | "I can't modify [field]. Did you mean [suggestion]?" |
| `PAST_CLOSING` | New date would be past closing | "That would extend past the closing date. Extend closing first?" |

## Integration Points

### Invokes
- `send-for-signature` - DocuSign workflow
- Specific template skills when applicable

### Invoked By
- Voice commands
- Dashboard actions
- Other document workflows

### Database Tables
- `documents` - Addendum record
- `document_modifications` - Tracked changes
- `signature_requests` - DocuSign tracking
- `action_log` - Audit entry

## Quality Checklist

- [x] Routes to specific templates when appropriate
- [x] Handles custom addenda with any modifications
- [x] Tracks FROM/TO values for all changes
- [x] Supports multiple simultaneous modifications
- [x] Florida-compliant language
- [x] Configures DocuSign with proper signing order
- [x] Queues deal updates for post-signature
- [x] Handles multiple buyers/sellers
- [x] Supports urgency levels
- [x] Creates complete audit trail
- [x] Clear voice responses
- [x] Prevents conflicting pending addenda

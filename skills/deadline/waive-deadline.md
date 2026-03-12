# Skill: Waive Deadline (Contingency Waiver)

**Category:** Deadline
**Priority:** P0
**Approval Required:** Yes (for contract contingencies)

## Purpose

Process the waiver of a contract contingency deadline. When a buyer decides to waive a contingency (inspection, financing, appraisal, etc.), this skill handles the documentation, notifications, and deal status updates. Waiving a contingency is a significant legal action that removes the buyer's ability to cancel the contract under that contingency.

## Florida Legal Context

**Contingency Waiver in Florida FAR/BAR Contracts:**
> When a buyer waives a contingency, they surrender their right to terminate the contract based on that contingency. The buyer's earnest money deposit typically becomes non-refundable (or more at risk) once contingencies are waived.

**Key Contingencies That Can Be Waived:**
- Inspection Contingency
- Financing Contingency
- Appraisal Contingency
- HOA/Condo Document Review
- Sale of Buyer's Property Contingency

**Waiver Methods:**
1. **Explicit Waiver**: Buyer signs a written waiver/release
2. **Implicit Waiver**: Deadline passes without buyer exercising the contingency
3. **Partial Waiver**: Buyer waives specific items but retains others

## Triggers

### Voice Commands
- "Waive the inspection contingency for [property]"
- "Buyer is waiving financing"
- "[Buyer name] wants to waive the appraisal contingency"
- "Process contingency waiver for [deadline]"
- "Remove the [contingency type] contingency"
- "Buyer accepts property as-is"
- "Waive all remaining contingencies"

### System Events
- Buyer signs waiver document in DocuSign
- Agent marks contingency as waived in UI
- Deadline passes with no buyer action (implicit waiver)

### Programmatic
- `POST /deadlines/:id/waive`
- `POST /deals/:id/contingencies/waive`

## Required Inputs

| Input | Type | Required | Source | Description |
|-------|------|----------|--------|-------------|
| `dealId` | UUID | Yes | context | Deal containing the contingency |
| `deadlineId` or `contingencyType` | UUID/string | Yes | voice/UI | Which contingency to waive |

## Optional Inputs

| Input | Type | Default | Source | Description |
|-------|------|---------|--------|-------------|
| `waiverType` | string | 'explicit' | system | 'explicit', 'implicit', 'partial' |
| `waivedBy` | string | null | voice | Party waiving (typically buyer) |
| `reason` | string | null | voice | Why contingency is being waived |
| `retainedItems` | string[] | null | voice | For partial waiver - what's still protected |
| `effectiveDate` | Date | now | voice | When waiver takes effect |
| `buyerAcknowledgement` | boolean | false | required | Buyer understands consequences |
| `skipDocument` | boolean | false | agent | Skip document generation |

## Contingency Types and Consequences

| Contingency | What's Waived | Consequence of Waiver |
|-------------|--------------|----------------------|
| `inspection` | Right to cancel based on property condition | Buyer accepts property "as-is" |
| `financing` | Right to cancel if loan not approved | Deposit at risk if can't get loan |
| `appraisal` | Right to cancel if appraisal is low | Must cover difference or lose deposit |
| `hoa_review` | Right to cancel based on HOA docs | Bound regardless of HOA issues |
| `sale_of_property` | Right to cancel if buyer's home doesn't sell | Must close regardless of sale status |

## Execution Flow

```
START
  │
  ├─── 1. Validate inputs and find contingency
  │    ├── Find deal by ID
  │    ├── Verify deal is active
  │    ├── Find deadline by ID or contingency type
  │    ├── Verify deadline is waivable contingency
  │    └── Verify deadline not already completed/waived
  │
  ├─── 2. Check authorization
  │    │
  │    ├── Verify requesting agent is buyer's agent
  │    │   └── OR has explicit authorization
  │    │
  │    └── IF not authorized:
  │        └── RETURN error: "Only buyer's agent can waive contingencies"
  │
  ├─── 3. Assess waiver type
  │    │
  │    ├── IF explicit waiver:
  │    │   └── Proceed to confirmation
  │    │
  │    ├── IF implicit waiver (deadline passed):
  │    │   ├── Calculate days since deadline
  │    │   ├── Log as automatic waiver
  │    │   └── Note: "Contingency waived by passage of time"
  │    │
  │    └── IF partial waiver:
  │        ├── Document retained protections
  │        └── Validate retained items are valid
  │
  ├─── 4. Request confirmation (approval gate)
  │    │
  │    ├── Display consequence warning:
  │    │   │
  │    │   │   "WAIVER CONFIRMATION REQUIRED"
  │    │   │
  │    │   │   Contingency: {{contingency.name}}
  │    │   │   Property: {{deal.address}}
  │    │   │   Buyer: {{buyer.name}}
  │    │   │
  │    │   │   By waiving this contingency:
  │    │   │   {{consequence_details}}
  │    │   │
  │    │   │   This action cannot be easily undone.
  │    │   │
  │    │   └── Confirm? [Yes / No / More Info]
  │    │
  │    ├── IF not confirmed:
  │    │   └── RETURN: Waiver cancelled
  │    │
  │    └── IF confirmed:
  │        └── CONTINUE
  │
  ├─── 5. Generate waiver document (if explicit)
  │    │
  │    ├── SELECT template based on contingency type:
  │    │   ├── inspection → inspection-waiver.md
  │    │   ├── financing → financing-waiver.md
  │    │   ├── appraisal → appraisal-waiver.md
  │    │   └── general → contingency-waiver.md
  │    │
  │    ├── Populate template:
  │    │   ├── Property address
  │    │   ├── Contract date
  │    │   ├── Buyer name(s)
  │    │   ├── Contingency being waived
  │    │   ├── Waiver effective date
  │    │   ├── Acknowledgement of consequences
  │    │   └── Signature blocks
  │    │
  │    └── Queue for DocuSign:
  │        ├── Buyer signature required
  │        ├── Optional: Buyer's agent acknowledgement
  │        └── CC: Seller, Listing agent, Title company
  │
  ├─── 6. Update deadline record
  │    │
  │    │   UPDATE deadlines SET
  │    │     status = 'waived',
  │    │     waived_at = NOW(),
  │    │     waived_by = {{waivedBy}},
  │    │     waiver_type = {{waiverType}},
  │    │     waiver_reason = {{reason}},
  │    │     waiver_document_id = {{documentId}}
  │    │   WHERE id = {{deadlineId}}
  │    │
  │    └── IF partial waiver:
  │        └── Store retained_items in metadata
  │
  ├─── 7. Update deal status
  │    │
  │    ├── Update contingencies array:
  │    │   └── deal.contingencies.{{type}}.status = 'waived'
  │    │
  │    ├── IF all contingencies waived:
  │    │   └── Update deal.contractStatus = 'contingencies_cleared'
  │    │
  │    └── Recalculate deal risk score
  │
  ├─── 8. Cancel pending alerts for this deadline
  │    └── Remove from alert queue
  │
  ├─── 9. Notify all parties
  │    │
  │    ├── Buyer (confirmation):
  │    │   └── "You have waived the {{contingency}} contingency"
  │    │
  │    ├── Buyer's Agent:
  │    │   └── "{{contingency}} contingency waived for {{address}}"
  │    │
  │    ├── Seller:
  │    │   └── "Good news: Buyer has waived {{contingency}}"
  │    │
  │    ├── Listing Agent:
  │    │   └── Detailed notification with next steps
  │    │
  │    ├── Title Company:
  │    │   └── Contract status update
  │    │
  │    └── Lender (if financing-related):
  │        └── Contingency status update
  │
  ├─── 10. Log action
  │     ├── action_type: 'contingency_waived'
  │     ├── Store all details for audit
  │     └── Include consequence acknowledgement
  │
  └─── 11. Return result
```

## Waiver Document Templates

### Inspection Waiver

```
WAIVER OF INSPECTION CONTINGENCY

Property: {{property_address}}
Contract Date: {{contract_date}}
Buyer(s): {{buyer_names}}

The undersigned Buyer(s) hereby waive(s) the inspection contingency
provided for in the Contract for Sale and Purchase.

By signing below, Buyer acknowledges and agrees:

1. Buyer has had the opportunity to conduct inspections of the Property
2. Buyer accepts the Property in its current "as-is" condition
3. Buyer waives the right to terminate the Contract based on any
   inspection findings or property condition issues
4. Buyer's earnest money deposit remains at risk if Buyer fails to close

{{#if retained_items}}
EXCEPTION: Buyer retains the right to request repairs for the following
specific items already documented:
{{#each retained_items}}
- {{this}}
{{/each}}
{{/if}}

This waiver is effective as of {{effective_date}}.

_______________________________     _______________
Buyer Signature                     Date

_______________________________     _______________
Buyer Signature                     Date
```

### Financing Waiver

```
WAIVER OF FINANCING CONTINGENCY

Property: {{property_address}}
Contract Date: {{contract_date}}
Buyer(s): {{buyer_names}}

The undersigned Buyer(s) hereby waive(s) the financing contingency
provided for in the Contract for Sale and Purchase.

By signing below, Buyer acknowledges and agrees:

1. Buyer is waiving the right to terminate based on inability to
   obtain financing
2. If Buyer cannot secure a mortgage loan, Buyer is still obligated
   to close or may be in breach of contract
3. Buyer's earnest money deposit (currently ${{escrow_amount}})
   is at risk if Buyer cannot close due to financing issues
4. Buyer has {{financing_status}} regarding their loan application

[ ] Buyer confirms loan has been formally approved
[ ] Buyer is proceeding at own risk before formal approval

This waiver is effective as of {{effective_date}}.

_______________________________     _______________
Buyer Signature                     Date

_______________________________     _______________
Buyer Signature                     Date
```

### Appraisal Waiver

```
WAIVER OF APPRAISAL CONTINGENCY

Property: {{property_address}}
Contract Date: {{contract_date}}
Purchase Price: ${{purchase_price}}
Buyer(s): {{buyer_names}}

The undersigned Buyer(s) hereby waive(s) the appraisal contingency
provided for in the Contract for Sale and Purchase.

By signing below, Buyer acknowledges and agrees:

1. Buyer is waiving the right to terminate if the property appraises
   below the purchase price of ${{purchase_price}}
2. If the appraisal comes in low, Buyer agrees to:
   [ ] Pay the difference in cash
   [ ] Renegotiate with Seller
   [ ] Accept the risk and proceed regardless
3. Buyer understands that lender financing is typically based on
   the lower of purchase price or appraised value
4. Buyer has adequate funds to cover any appraisal gap

This waiver is effective as of {{effective_date}}.

_______________________________     _______________
Buyer Signature                     Date

_______________________________     _______________
Buyer Signature                     Date
```

## Output

```typescript
{
  success: true,
  actionTaken: "Waived inspection contingency for 123 Main St",
  result: {
    waiver: {
      id: "waiver-uuid",
      deadlineId: "deadline-uuid",
      contingencyType: "inspection",
      waiverType: "explicit",
      effectiveDate: "2026-01-15",
      waivedAt: "2026-01-15T14:30:00Z",
      waivedBy: "John Smith (Buyer)"
    },
    deadline: {
      id: "deadline-uuid",
      name: "Inspection Period Ends",
      previousStatus: "upcoming",
      newStatus: "waived",
      originalDueDate: "2026-01-20",
      waivedBeforeDeadline: true,
      daysEarly: 5
    },
    document: {
      id: "doc-uuid",
      type: "inspection_waiver",
      status: "pending_signatures",
      docusignEnvelopeId: "envelope-uuid",
      signers: [
        { name: "John Smith", role: "buyer", status: "pending" }
      ]
    },
    consequences: {
      description: "Buyer accepts property in as-is condition",
      depositAtRisk: true,
      remainingContingencies: ["financing", "appraisal"],
      allContingenciesCleared: false
    },
    notifications: [
      { party: "Buyer", channel: "email", status: "sent" },
      { party: "Seller", channel: "email", status: "sent" },
      { party: "Listing Agent", channel: "email", status: "sent" },
      { party: "Title Company", channel: "email", status: "sent" }
    ],
    nextSteps: [
      "Buyer to sign waiver document via DocuSign",
      "Monitor remaining contingencies: Financing (Jan 30), Appraisal (Jan 25)",
      "Update buyer on next deadline: Appraisal due in 10 days"
    ]
  },
  requiresApproval: false, // Already approved during execution
  shouldContinue: true
}
```

## Voice Responses

### Confirmation Request
> "You're asking to waive the inspection contingency for 123 Main Street.
>
> Just to be clear: Once waived, the buyer John Smith will accept the property as-is and cannot cancel based on any inspection issues. The $10,000 deposit becomes more at risk.
>
> The inspection period was set to end on January 20th, so this is 5 days early.
>
> Should I proceed with the waiver? I'll send a waiver document for the buyer to sign."

### After Waiver Processed
> "Done. I've processed the inspection contingency waiver for 123 Main Street.
>
> I've sent a waiver document to John Smith for signature via DocuSign. Once signed, copies will go to all parties.
>
> There are 2 remaining contingencies:
> - Appraisal due January 25th
> - Financing due January 30th
>
> Want me to check on the status of those?"

### Implicit Waiver (Deadline Passed)
> "The inspection deadline for 456 Oak Avenue passed yesterday without the buyer taking action.
>
> Under Florida contract rules, this means the inspection contingency has been automatically waived. The buyer is now deemed to have accepted the property as-is.
>
> Should I:
> 1. Document this implicit waiver for the file
> 2. Notify all parties of the waiver
> 3. Both
>
> What would you like me to do?"

### Partial Waiver
> "Got it. The buyer wants to waive the inspection contingency but keep the right to request repair of the roof issues found during inspection.
>
> I'll prepare a partial waiver document that:
> - Waives general inspection objections
> - Retains the right to address: 'Roof leak over master bedroom' and 'Missing shingles on south side'
>
> This protects the buyer on those specific items. Ready to proceed?"

## Approval Flow

```
WAIVER REQUEST
     │
     ├── Low Stakes (Administrative deadlines):
     │   └── Auto-approve with logging
     │
     └── High Stakes (Contract contingencies):
         │
         ├── Voice request:
         │   ├── Explain consequences
         │   ├── Request verbal confirmation
         │   └── Require "yes, waive it" or similar
         │
         └── UI request:
             ├── Show confirmation modal
             ├── Require checkbox: "I understand..."
             └── Two-step confirmation for critical ones
```

## Error Handling

| Error | Cause | Response |
|-------|-------|----------|
| `NOT_WAIVABLE` | Deadline is not a contingency | "This deadline isn't a waivable contingency. It's [type]." |
| `ALREADY_WAIVED` | Contingency already waived | "The inspection contingency was already waived on [date]." |
| `DEADLINE_PASSED` | Trying to waive after implicit waiver | "This contingency was automatically waived when the deadline passed on [date]." |
| `NOT_AUTHORIZED` | Listing agent trying to waive | "Only the buyer's agent can waive buyer contingencies." |
| `DEAL_INACTIVE` | Deal is closed/cancelled | "This deal is no longer active. Cannot process waiver." |
| `MISSING_BUYER_INFO` | Can't identify buyer for document | "I need the buyer's name and email to send the waiver document." |

## Waiver Reversal

**Waivers are generally NOT reversible**, but in rare cases:

```
IF waiver needs to be reversed:
  │
  ├── Check if document was signed:
  │   ├── If NOT signed → Cancel document, revert status
  │   └── If signed → Cannot reverse without mutual agreement
  │
  ├── If reversal approved by all parties:
  │   ├── Generate reversal addendum
  │   ├── Require all signatures
  │   └── Update deadline status back to 'upcoming' (if time remains)
  │
  └── Log reversal with full audit trail
```

## Quality Checklist

- [x] Validates contingency is waivable
- [x] Checks authorization (buyer's agent only)
- [x] Explains consequences before confirmation
- [x] Generates appropriate waiver document
- [x] Handles explicit, implicit, and partial waivers
- [x] Updates deadline and deal status correctly
- [x] Cancels pending alerts for waived deadline
- [x] Notifies all relevant parties
- [x] Tracks remaining contingencies
- [x] Creates complete audit trail
- [x] Handles voice commands naturally
- [x] Provides clear next steps
- [x] Documents cannot be generated without buyer acknowledgement
- [x] Supports document-free logging for implicit waivers

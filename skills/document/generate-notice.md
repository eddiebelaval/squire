# Skill: Generate Notice

**Category:** Document
**Priority:** P0
**Approval Required:** Varies by notice type

## Purpose

Generate Florida-compliant notices for real estate transactions. Notices are formal communications required by contract or law to inform parties of actions, elections, or demands within specified timeframes.

## Triggers

### Voice Commands
- "Send notice to [party] about [topic]"
- "Create [type] notice for [address]"
- "I need to notify the seller of [action]"
- "Generate cancellation notice"
- "Send termination notice"
- "Notify lender of [issue]"

### Programmatic
- `POST /deals/:dealId/documents/notice`
- Deadline-triggered automatic notices
- System event notices

## Required Inputs

| Input | Type | Required | Source | Description |
|-------|------|----------|--------|-------------|
| `dealId` | UUID | Yes | context | Active deal identifier |
| `noticeType` | string | Yes | voice/manual | Type of notice (see types) |
| `recipient` | string | Yes | voice/manual | Who receives the notice |

## Optional Inputs

| Input | Type | Default | Source | Description |
|-------|------|---------|--------|-------------|
| `reason` | string | null | voice | Reason for notice |
| `effectiveDate` | Date | today | manual | When notice takes effect |
| `responseDeadline` | Date | calculated | manual | When response is due |
| `deliveryMethod` | string[] | ['email', 'mail'] | config | How to deliver |
| `certifiedMail` | boolean | false | config | Send via certified mail |
| `returnReceipt` | boolean | false | config | Request return receipt |
| `attachments` | Document[] | [] | manual | Supporting documents |
| `sendImmediately` | boolean | false | voice | Send without preview |
| `copyParties` | string[] | [] | manual | Additional recipients |

## Notice Types

### Contract Notices
| Type | Description | Typical Sender | Deadline Sensitive |
|------|-------------|----------------|-------------------|
| `inspection_termination` | Cancel based on inspection | Buyer | Yes - within period |
| `financing_denial` | Loan not approved | Buyer | Yes - within period |
| `appraisal_shortfall` | Appraisal below price | Buyer | Yes - within period |
| `title_objection` | Title issues found | Buyer | Yes - per contract |
| `survey_objection` | Survey issues found | Buyer | Yes - per contract |
| `hoa_objection` | HOA document issues | Buyer | Yes - 3 days |
| `walkthrough_deficiency` | Issues found at walkthrough | Buyer | Before closing |

### Deadline Notices
| Type | Description | Typical Sender | Purpose |
|------|-------------|----------------|---------|
| `cure_demand` | Demand to cure default | Either | Formal warning |
| `extension_request` | Request deadline extension | Either | Seek more time |
| `contingency_release` | Remove contingency | Either | Move forward |
| `closing_ready` | Ready to close | Either | Confirm readiness |

### Termination Notices
| Type | Description | Approval Required |
|------|-------------|-------------------|
| `mutual_cancellation` | Both parties agree to cancel | No |
| `unilateral_termination` | One party exercising right | Yes |
| `default_notice` | Notice of contract default | Yes |
| `breach_notice` | Formal breach notification | Yes |

### Informational Notices
| Type | Description |
|------|-------------|
| `party_contact_change` | Updated contact information |
| `representative_change` | New agent/attorney |
| `lender_change` | Different lender |
| `closing_location` | Closing venue details |
| `possession_notice` | Move-in/move-out details |

## Execution Flow

```
START
  │
  ├─── 1. Validate notice request
  │    ├── Verify deal exists and is active
  │    ├── Check notice type is valid
  │    ├── Verify sender has authority
  │    └── Check timing (is notice timely?)
  │
  ├─── 2. Load deal context
  │    ├── Get all parties
  │    ├── Get relevant deadlines
  │    ├── Get contract terms
  │    └── Identify recipient(s)
  │
  ├─── 3. Validate timing
  │    │
  │    ├── IF deadline-sensitive notice:
  │    │   ├── Check deadline hasn't passed
  │    │   ├── Calculate days remaining
  │    │   └── Warn if cutting close
  │    │
  │    └── IF time-barred:
  │        └── WARN: "This notice may be late"
  │
  ├─── 4. Determine notice requirements
  │    ├── Check contract for delivery requirements
  │    ├── Identify required delivery methods
  │    ├── Determine if certified mail needed
  │    └── Calculate response deadline
  │
  ├─── 5. Build notice content
  │    ├── Formal header
  │    ├── Clear statement of notice type
  │    ├── Contract references
  │    ├── Specific grounds/reasons
  │    ├── Required actions (if any)
  │    ├── Response deadline (if applicable)
  │    └── Delivery certification
  │
  ├─── 6. Generate PDF
  │    └── Apply appropriate template
  │
  ├─── 7. Create document record
  │    ├── type: 'notice'
  │    ├── noticeType: specific type
  │    ├── status: 'draft' or 'sent'
  │    ├── timeSensitive: boolean
  │    └── Link to deal
  │
  ├─── 8. IF requires approval:
  │    ├── Set status to 'pending_approval'
  │    ├── Notify approving party
  │    └── Wait for approval before sending
  │
  ├─── 9. Deliver notice
  │    │
  │    ├── Email delivery:
  │    │   └── Send with read receipt request
  │    │
  │    ├── IF certifiedMail:
  │    │   ├── Queue for certified mailing
  │    │   └── Track delivery status
  │    │
  │    └── Log all delivery attempts
  │
  ├─── 10. Track notice effects
  │     │
  │     ├── IF termination notice:
  │     │   └── Queue deal status change
  │     │
  │     ├── IF deadline notice:
  │     │   └── Track response deadline
  │     │
  │     └── Create follow-up reminders
  │
  ├─── 11. Log action
  │     └── action_type: 'notice_sent'
  │
  └─── 12. Return result
```

## Template Content

```
NOTICE

Date: {{currentDate | formatDate}}
Time: {{currentTime}}

================================================================================
NOTICE IDENTIFICATION
================================================================================

Notice Type: {{noticeType | formatNoticeType}}
Property Address: {{deal.address.street}}
                  {{deal.address.city}}, {{deal.address.state}} {{deal.address.zip}}
Contract Date: {{deal.effectiveDate | formatDate}}

================================================================================
PARTIES
================================================================================

FROM (Sending Party):
{{sender.name}}
{{sender.address}}
{{sender.email}}
{{sender.phone}}

TO (Receiving Party):
{{recipient.name}}
{{recipient.address}}
{{recipient.email}}
{{recipient.phone}}

{{#if copyParties.length > 0}}
CC:
{{#each copyParties}}
  {{this.name}} - {{this.role}}
{{/each}}
{{/if}}

================================================================================
NOTICE
================================================================================

{{#if noticeType === 'inspection_termination'}}
NOTICE OF TERMINATION BASED ON INSPECTION

Pursuant to the inspection contingency provisions of the Contract for Sale and
Purchase dated {{deal.effectiveDate | formatDate}}, Buyer hereby provides notice
of termination of the Contract.

The Inspection Period expires on: {{inspectionDeadline | formatDate}}
This notice is delivered on: {{currentDate | formatDate}}

{{#if reason}}
Reason: {{reason}}
{{else}}
Buyer has elected to terminate the Contract within the inspection period as
permitted by the Contract terms.
{{/if}}

Buyer hereby demands the return of the earnest money deposit in the amount of
${{deal.escrowAmount | currency}} held by {{deal.escrowAgent}}.

{{/if}}

{{#if noticeType === 'financing_denial'}}
NOTICE OF FINANCING DENIAL / INABILITY TO OBTAIN FINANCING

Pursuant to the financing contingency provisions of the Contract for Sale and
Purchase dated {{deal.effectiveDate | formatDate}}, Buyer hereby provides notice
that Buyer has been unable to obtain financing as specified in the Contract.

Financing Contingency Deadline: {{financingDeadline | formatDate}}
This notice is delivered on: {{currentDate | formatDate}}

{{#if lenderDenialAttached}}
A copy of the lender's denial letter is attached hereto.
{{/if}}

{{#if reason}}
Details: {{reason}}
{{/if}}

Buyer hereby requests:
☑ Return of earnest money deposit: ${{deal.escrowAmount | currency}}
☐ Extension of financing contingency (if applicable)

{{/if}}

{{#if noticeType === 'appraisal_shortfall'}}
NOTICE OF APPRAISAL SHORTFALL

The Property has been appraised at a value less than the Contract purchase price.

Contract Purchase Price: ${{deal.purchasePrice | currency}}
Appraised Value: ${{appraisedValue | currency}}
Shortfall Amount: ${{shortfall | currency}}

Pursuant to the Contract terms, Buyer hereby provides notice and elects to:

{{#if buyerElection === 'terminate'}}
☑ Terminate the Contract and receive return of earnest money
☐ Proceed with the transaction as-is
☐ Negotiate with Seller regarding the price
{{/if}}

{{#if buyerElection === 'proceed'}}
☐ Terminate the Contract and receive return of earnest money
☑ Proceed with the transaction as-is
☐ Negotiate with Seller regarding the price
{{/if}}

{{#if buyerElection === 'negotiate'}}
☐ Terminate the Contract and receive return of earnest money
☐ Proceed with the transaction as-is
☑ Negotiate with Seller regarding the price
{{/if}}

{{/if}}

{{#if noticeType === 'cure_demand'}}
NOTICE AND DEMAND TO CURE DEFAULT

This Notice is to inform you that you are in DEFAULT of the Contract for Sale
and Purchase dated {{deal.effectiveDate | formatDate}}.

Nature of Default:
{{reason}}

Pursuant to the Contract terms, you have {{curePeriod}} days from receipt of
this Notice to cure the above-referenced default.

CURE DEADLINE: {{cureDeadline | formatDate}}

If the default is not cured by the above deadline, the non-defaulting party
reserves all rights and remedies available under the Contract and applicable
law, including but not limited to:

• Termination of the Contract
• Retention or recovery of earnest money deposit
• Specific performance
• Damages

{{/if}}

{{#if noticeType === 'contingency_release'}}
NOTICE OF CONTINGENCY RELEASE

{{sender.role | capitalize}} hereby releases and waives the following
contingency from the Contract:

Contingency Being Released: {{contingencyType}}
Original Deadline: {{contingencyDeadline | formatDate}}

By releasing this contingency, {{sender.role | capitalize}} acknowledges:

1. This release is voluntary and irrevocable.
2. The transaction shall proceed without this contingency.
3. {{sender.role | capitalize}} accepts the associated risk.

This release is effective as of {{effectiveDate | formatDate}}.

{{/if}}

{{#if noticeType === 'closing_ready'}}
NOTICE OF READINESS TO CLOSE

{{sender.role | capitalize}} hereby provides notice that {{sender.role}} is
ready, willing, and able to close the transaction in accordance with the
Contract terms.

Closing Date: {{deal.closingDate | formatDate}}
Closing Location: {{closingLocation}}
Closing Time: {{closingTime}}

{{sender.role | capitalize}} has completed all requirements for closing,
including:
{{#each completedRequirements}}
☑ {{this}}
{{/each}}

Please confirm your readiness to close by {{confirmationDeadline | formatDate}}.

{{/if}}

================================================================================
DELIVERY CERTIFICATION
================================================================================

This Notice is being delivered by the following method(s):
{{#each deliveryMethods}}
☑ {{this}}
{{/each}}

{{#if responseRequired}}
================================================================================
RESPONSE REQUIRED
================================================================================

A response to this Notice is required by:
{{responseDeadline | formatDate}} at 5:00 PM local time

Failure to respond by the above deadline may result in:
{{responseConsequence}}
{{/if}}

================================================================================
SIGNATURE
================================================================================

{{sender.name}}
{{sender.role | capitalize}}

Date: {{currentDate | formatDate}}

Prepared by:
{{agent.name}}
{{agent.brokerage}}
{{agent.phone}} | {{agent.email}}
```

## DocuSign Configuration (When Signature Required)

```typescript
const docusignConfig = {
  emailSubject: "{{noticeType | formatNoticeType}} - {{property_address}}",
  emailBlurb: "Please review the attached notice regarding your transaction at {{property_address}}.",
  signers: [
    {
      role: "sender",
      routingOrder: 1,
      required: true
    },
    {
      role: "recipient",
      routingOrder: 2,
      required: noticeRequiresAcknowledgment
    }
  ]
};
```

## Output

```typescript
{
  success: true,
  actionTaken: "Sent inspection termination notice for 123 Main St",
  result: {
    document: {
      id: "uuid",
      name: "Notice of Termination - Inspection",
      type: "notice",
      noticeType: "inspection_termination",
      status: "sent",
      pdfUrl: "https://...",
    },
    delivery: {
      methods: ["email", "certified_mail"],
      emailSentTo: ["seller@email.com", "listing.agent@email.com"],
      certifiedMailTracking: "9400111899223456789012",
      timestamp: "2026-01-15T14:30:00Z"
    },
    timing: {
      deadlineDate: "2026-01-20",
      daysBeforeDeadline: 5,
      isTimely: true
    },
    effects: [
      "Contract termination pending",
      "Escrow release request queued"
    ],
    nextSteps: [
      "Notice delivered to seller and listing agent",
      "Escrow agent will receive release request",
      "Await confirmation of earnest money return"
    ]
  }
}
```

## Voice Response

**Termination notice:**
> "I've sent an inspection termination notice for 123 Main Street.
>
> The notice went to Jane Doe, the seller, and their listing agent via email. I've also queued a certified mail copy.
>
> You're within the inspection period - 5 days before the deadline. I've requested return of the $5,000 earnest money.
>
> Need me to follow up on anything?"

**Cure demand:**
> "I've drafted a cure demand notice. Given the serious nature of this notice, please review it before I send.
>
> This gives the seller 3 days to cure the default. Would you like me to send it now or would you like to review first?"

## Error Handling

| Error | Cause | Response |
|-------|-------|----------|
| `DEADLINE_PASSED` | Notice sent after deadline | "The inspection period ended on [date]. This notice may not be effective." |
| `MISSING_RECIPIENT` | No recipient contact info | "I need the seller's contact information to send this notice." |
| `UNAUTHORIZED` | Sender can't send this notice | "This notice must come from the [buyer/seller]." |
| `INVALID_NOTICE_TYPE` | Unknown notice type | "I don't recognize that notice type. What do you need to notify them about?" |
| `INSUFFICIENT_GROUNDS` | Missing required info | "I need more details about why you're terminating. What did the inspection reveal?" |

## Florida-Specific Notes

- FAR/BAR contracts specify delivery methods for notices
- Time is of the essence - late notices may not be effective
- Certified mail creates rebuttable presumption of delivery
- Email notice effectiveness depends on contract terms
- Some notices require specific contract clause references
- Earnest money release requires mutual agreement or court order

## Delivery Method Requirements

| Notice Type | Email | Certified Mail | In Person |
|-------------|-------|----------------|-----------|
| Inspection termination | Yes | Recommended | Optional |
| Financing denial | Yes | Recommended | Optional |
| Cure demand | Required | Required | Optional |
| Default notice | Required | Required | Recommended |
| Termination | Required | Required | Optional |
| Informational | Yes | Optional | Optional |

## Quality Checklist

- [x] Validates timing before sending
- [x] Warns when notice may be late
- [x] Uses contract-compliant language
- [x] Includes all required contract references
- [x] Tracks delivery method requirements
- [x] Supports certified mail tracking
- [x] Queues appropriate follow-up actions
- [x] Handles escrow release requests
- [x] Creates complete audit trail
- [x] Florida-specific requirements met
- [x] Clear voice responses
- [x] Approval workflow for serious notices

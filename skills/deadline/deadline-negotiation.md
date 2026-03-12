# Skill: Deadline Negotiation

**Category:** Deadline
**Priority:** P0
**Approval Required:** Yes (all extension requests require agent approval)

## Purpose

Facilitate the negotiation of deadline extensions with the counterparty. This skill handles the complete workflow of requesting a deadline extension from the other party, including crafting the request, tracking the negotiation, processing counteroffers, and finalizing agreements. It's designed to maximize the chance of approval while protecting the requesting party's interests.

## Florida Context

**Extension Requests in Florida Real Estate:**
> Unlike unilateral deadline adjustments, extension requests require counterparty agreement. In Florida, this is typically documented through an Extension Addendum that modifies the original contract.

**Key Principles:**
1. **Extensions are not automatic** - The other party has no obligation to agree
2. **Written agreement required** - Verbal agreements should be documented
3. **Consideration may be needed** - Counterparty may request something in return
4. **Time-sensitive** - Request should be made BEFORE deadline passes when possible

## Triggers

### Voice Commands
- "Request an extension on the inspection deadline"
- "Ask for more time on financing"
- "We need to push back closing"
- "Negotiate a 5-day extension for [deadline]"
- "Send extension request to [listing agent/buyer's agent]"
- "I need to extend the [contingency] deadline"
- "Can we get more time for the appraisal?"

### System Events
- Agent clicks "Request Extension" in UI
- Deadline alert with agent response "request extension"
- Approaching deadline with identified completion risk

### Programmatic
- `POST /deadlines/:id/negotiate-extension`
- Integration trigger from lender/title company delay notification

## Required Inputs

| Input | Type | Required | Source | Description |
|-------|------|----------|--------|-------------|
| `dealId` | UUID | Yes | context | Deal containing the deadline |
| `deadlineId` | UUID | Yes | voice/UI | Deadline to extend |
| `extensionDays` | number | Yes* | voice | Days of extension requested |
| `newDueDate` | Date | Yes* | voice | New proposed deadline date |

*Either extensionDays or newDueDate required

## Optional Inputs

| Input | Type | Default | Source | Description |
|-------|------|---------|--------|-------------|
| `reason` | string | null | voice | Why extension is needed |
| `offerConcession` | boolean | false | voice | Willing to offer something |
| `concessionDetails` | string | null | voice | What's being offered |
| `urgency` | string | 'normal' | context | 'normal', 'urgent', 'critical' |
| `counterpartyContact` | string | null | context | Who to send request to |
| `preferredChannel` | string | 'email' | voice | 'email', 'phone', 'text' |
| `followUpHours` | number | 24 | config | Hours before follow-up |

## Negotiation Strategy Framework

### Request Strength Factors

| Factor | Impact on Approval | Notes |
|--------|-------------------|-------|
| Request made before deadline | +30% | Shows professionalism |
| Clear, legitimate reason | +25% | Third-party delays work best |
| Short extension (3-5 days) | +20% | More likely approved |
| Offer concession | +15% | Shows good faith |
| Good relationship history | +10% | Prior cooperation matters |
| Strong market position | Variable | Buyer's market vs seller's market |

### Common Reasons by Deadline Type

| Deadline | Strong Reasons | Weak Reasons |
|----------|---------------|--------------|
| Inspection | Specialist unavailable, weather delay, complex property | "Need more time to decide" |
| Financing | Lender backlog, document verification, underwriting delay | "Haven't applied yet" |
| Appraisal | Appraiser scheduling, comparable research, FHA/VA process | "Don't like the value" |
| Closing | Title issues, lender delay, document preparation | "Not ready" |

### Concession Options

| Concession Type | When to Use | Example |
|-----------------|-------------|---------|
| Increased deposit | High-value deal, seller skeptical | Add $5,000 to escrow |
| Cover seller costs | Closing extension | Pay seller's rate lock extension |
| Waive future right | Get immediate approval | Agree to accept as-is on minor items |
| Shortened extension | Seller wants minimal delay | Ask for 5 days, accept 3 |
| Non-refundable deposit | Show commitment | Make portion non-refundable |

## Execution Flow

```
START
  │
  ├─── 1. Validate request
  │    ├── Find deadline by ID
  │    ├── Verify deadline not already completed/waived
  │    ├── Verify deal is active
  │    ├── Check current deadline status (how much time remains)
  │    └── Verify agent has authority to request
  │
  ├─── 2. Calculate new deadline date
  │    │
  │    ├── IF extensionDays provided:
  │    │   ├── newDate = currentDueDate + extensionDays
  │    │   └── Apply weekend/holiday adjustment
  │    │
  │    ├── IF newDueDate provided:
  │    │   ├── Validate date is in future
  │    │   ├── Calculate extensionDays = newDueDate - currentDueDate
  │    │   └── Apply weekend/holiday adjustment
  │    │
  │    └── Validate:
  │        ├── New date doesn't exceed closing date (unless closing extension)
  │        └── Extension is reasonable for deadline type
  │
  ├─── 3. Analyze negotiation context
  │    │
  │    ├── Assess current position:
  │    │   ├── Days until deadline
  │    │   ├── Is deadline already passed?
  │    │   ├── Previous extensions on this deadline
  │    │   └── Overall deal health
  │    │
  │    ├── Assess counterparty factors:
  │    │   ├── Market conditions (buyer's vs seller's market)
  │    │   ├── Days on market (motivation indicator)
  │    │   ├── Previous responsiveness
  │    │   └── Known concerns or priorities
  │    │
  │    └── Calculate approval probability:
  │        └── Base 50% + strength factors - risk factors
  │
  ├─── 4. Craft extension request
  │    │
  │    ├── Select tone based on situation:
  │    │   ├── Collaborative: "We'd like to request..."
  │    │   ├── Explanatory: "Due to circumstances beyond..."
  │    │   └── Urgent: "We need your immediate consideration..."
  │    │
  │    ├── Structure request:
  │    │   ├── Current deadline date
  │    │   ├── Proposed new date
  │    │   ├── Reason for extension
  │    │   ├── Concession offer (if any)
  │    │   └── Request for response timeline
  │    │
  │    ├── Prepare Extension Addendum:
  │    │   ├── Pre-fill with deal details
  │    │   ├── Include new deadline date
  │    │   └── Add signature blocks
  │    │
  │    └── Set response deadline:
  │        └── Typically 24-48 hours for response
  │
  ├─── 5. Request agent approval
  │    │
  │    ├── Show request preview:
  │    │   ├── Request summary
  │    │   ├── Extension addendum preview
  │    │   └── Approval probability estimate
  │    │
  │    ├── IF not approved:
  │    │   └── RETURN: Request cancelled
  │    │
  │    └── IF approved:
  │        └── CONTINUE
  │
  ├─── 6. Send extension request
  │    │
  │    ├── Identify recipients:
  │    │   ├── Primary: Counterparty's agent
  │    │   ├── CC: Counterparty (if appropriate)
  │    │   └── CC: Title company (for closing extensions)
  │    │
  │    ├── Send via preferred channel:
  │    │   ├── Email: Full formal request + addendum attached
  │    │   ├── Text: Brief notification + link to full request
  │    │   └── Phone: Verbal request + follow-up email
  │    │
  │    └── Log communication:
  │        ├── Timestamp
  │        ├── Recipients
  │        ├── Content
  │        └── Delivery status
  │
  ├─── 7. Create negotiation tracker
  │    │
  │    │   INSERT INTO deadline_negotiations:
  │    │     deal_id: {{dealId}}
  │    │     deadline_id: {{deadlineId}}
  │    │     status: 'pending'
  │    │     original_due_date: {{originalDate}}
  │    │     proposed_due_date: {{proposedDate}}
  │    │     extension_days: {{days}}
  │    │     reason: {{reason}}
  │    │     concession_offered: {{concession}}
  │    │     requested_at: NOW()
  │    │     response_deadline: NOW() + 24 hours
  │    │
  │    └── Link to deal and deadline
  │
  ├─── 8. Schedule follow-ups
  │    │
  │    ├── Reminder at 50% of response window:
  │    │   └── "Extension request pending - no response yet"
  │    │
  │    ├── Alert at response deadline:
  │    │   └── "Response deadline reached - may need to follow up"
  │    │
  │    └── Escalation if no response:
  │        └── "Suggest phone follow-up to counterparty agent"
  │
  └─── 9. Return result and await response
```

## Response Handling Flow

```
RESPONSE RECEIVED
     │
     ├─── Parse response type:
     │    ├── APPROVED → Go to Approval Flow
     │    ├── DENIED → Go to Denial Flow
     │    ├── COUNTEROFFER → Go to Counter Flow
     │    └── NEEDS_INFO → Go to Clarification Flow
     │
     ├─── APPROVAL FLOW:
     │    ├── Update negotiation: status = 'approved'
     │    ├── INVOKE: extend-deadline skill
     │    │   ├── Apply new deadline date
     │    │   ├── Generate signed addendum
     │    │   └── Notify all parties
     │    └── Return success
     │
     ├─── DENIAL FLOW:
     │    ├── Update negotiation: status = 'denied'
     │    ├── Log denial reason
     │    ├── Assess options:
     │    │   ├── Suggest shorter extension
     │    │   ├── Suggest adding concession
     │    │   └── Accept denial and proceed
     │    ├── Notify agent of denial
     │    └── Prompt for next action
     │
     ├─── COUNTER FLOW:
     │    ├── Update negotiation: status = 'counter_received'
     │    ├── Parse counteroffer:
     │    │   ├── New proposed date
     │    │   ├── Requested concession
     │    │   └── Conditions
     │    ├── Present to agent:
     │    │   ├── Counter details
     │    │   ├── Recommendation
     │    │   └── Accept/Counter/Decline options
     │    └── Await agent decision
     │
     └─── CLARIFICATION FLOW:
          ├── Update negotiation: status = 'needs_info'
          ├── Identify what's needed
          ├── Gather information
          └── Resubmit request
```

## Extension Request Templates

### Standard Request Email

```
Subject: Extension Request - {{deadline.name}} - {{deal.address}}

Dear {{counterparty_agent.name}},

I hope this message finds you well. On behalf of {{our_party}}, I am
writing to request an extension of the {{deadline.name}} deadline.

**Current Deadline:** {{current_due_date}}
**Requested New Deadline:** {{proposed_due_date}}
**Extension Period:** {{extension_days}} days

**Reason for Request:**
{{reason}}

{{#if concession}}
**As consideration for this extension, {{our_party}} offers:**
{{concession_details}}
{{/if}}

I have attached an Extension Addendum for your review. If agreeable,
please have your client sign and return at your earliest convenience.

We would appreciate a response by {{response_deadline}} so we can
plan accordingly.

Please don't hesitate to call me if you'd like to discuss.

Best regards,

{{our_agent.name}}
{{our_agent.company}}
{{our_agent.phone}}
{{our_agent.email}}

---
Attachment: Extension_Addendum_{{deal.address}}.pdf
```

### Urgent Request (Deadline Imminent)

```
Subject: URGENT: Extension Request - {{deadline.name}} Due {{current_due_date}}

Dear {{counterparty_agent.name}},

I'm reaching out urgently regarding the {{deadline.name}} deadline
for {{deal.address}}, which is due {{time_until_deadline}}.

{{our_party}} is requesting a {{extension_days}}-day extension due to:
{{reason}}

This is not a reflection of any issues with the transaction - we
remain committed to closing. {{#if is_third_party_cause}}The delay
is due to {{third_party}} and is beyond our control.{{/if}}

Can we schedule a quick call to discuss? I'm available at {{phone}}
and would like to resolve this within the next few hours.

Extension Addendum attached for efficiency if you can approve.

Thank you for your understanding.

{{our_agent.name}}
{{our_agent.phone}}
```

### Post-Deadline Request (Already Missed)

```
Subject: Extension Request - {{deadline.name}} - Cure Pending

Dear {{counterparty_agent.name}},

I am writing regarding the {{deadline.name}} deadline that passed on
{{original_due_date}}. I want to address this directly and
transparently.

**Situation:** The deadline was missed due to {{reason}}.

**Our Request:** We are requesting an extension to {{proposed_due_date}}
to allow time to {{action_needed}}.

**Our Commitment:**
{{#if concession}}
- {{concession_details}}
{{/if}}
- We will {{commitment_1}}
- We will {{commitment_2}}

We understand this puts us in a position where we're asking for your
client's goodwill. We believe the transaction remains strong and in
everyone's interest to complete.

Please let me know if you'd like to discuss by phone. I'm available
at {{phone}}.

Sincerely,

{{our_agent.name}}
```

## Extension Addendum Template

```
EXTENSION ADDENDUM TO CONTRACT FOR SALE AND PURCHASE

Property Address: {{deal.address}}
Original Contract Date: {{deal.contract_date}}
Buyer: {{buyer.names}}
Seller: {{seller.names}}

The parties agree to modify the Contract as follows:

1. DEADLINE EXTENSION

   The {{deadline.name}} deadline is hereby extended from:

   Original Date: {{original_due_date}}
   New Date: {{proposed_due_date}}

   All other terms and conditions of the Contract remain unchanged
   and in full force and effect.

{{#if affects_other_deadlines}}
2. RELATED ADJUSTMENTS

   The following deadlines are also adjusted accordingly:
   {{#each related_deadlines}}
   - {{this.name}}: From {{this.original}} to {{this.new}}
   {{/each}}
{{/if}}

{{#if concession}}
3. CONSIDERATION

   {{concession_details}}
{{/if}}

This Addendum is effective upon execution by all parties.

BUYER(S):

_______________________________     _______________
{{buyer_1.name}}                    Date

_______________________________     _______________
{{buyer_2.name}}                    Date


SELLER(S):

_______________________________     _______________
{{seller_1.name}}                   Date

_______________________________     _______________
{{seller_2.name}}                   Date
```

## Output

```typescript
{
  success: true,
  actionTaken: "Sent extension request for Inspection Period",
  result: {
    negotiation: {
      id: "neg-uuid",
      status: "pending",
      requestedAt: "2026-01-18T10:30:00Z",
      responseDeadline: "2026-01-19T10:30:00Z"
    },

    request: {
      deadline: {
        id: "deadline-uuid",
        name: "Inspection Period Ends",
        currentDueDate: "2026-01-20",
        currentDueTime: "17:00"
      },
      extension: {
        proposedDueDate: "2026-01-25",
        extensionDays: 5,
        reason: "Specialist roof inspection required after initial findings"
      },
      concession: null
    },

    communication: {
      sentTo: "Bob Johnson (Listing Agent)",
      sentVia: "email",
      sentAt: "2026-01-18T10:32:00Z",
      deliveryStatus: "delivered",
      documentAttached: "extension_addendum_123_main_st.pdf"
    },

    analysis: {
      approvalProbability: 0.72,
      factors: [
        { factor: "Request before deadline", impact: "+15%" },
        { factor: "Legitimate reason (inspection findings)", impact: "+20%" },
        { factor: "Reasonable duration (5 days)", impact: "+10%" },
        { factor: "First extension request", impact: "+5%" },
        { factor: "Seller's market", impact: "-8%" }
      ],
      recommendation: "Good chance of approval. Follow up by phone if no response in 12 hours."
    },

    followUps: [
      { type: "reminder", scheduledFor: "2026-01-18T22:30:00Z" },
      { type: "alert", scheduledFor: "2026-01-19T10:30:00Z" },
      { type: "escalation", scheduledFor: "2026-01-19T14:00:00Z" }
    ],

    nextSteps: [
      "Await response from listing agent",
      "Follow up by phone if no response by tonight",
      "Current inspection deadline still 5 PM on January 20th until extension approved"
    ]
  },
  requiresApproval: false, // Already approved during execution
  shouldContinue: true
}
```

## Voice Responses

### Initiating Request
> "I'll prepare an extension request for the inspection deadline. Right now it's due January 20th at 5 PM.
>
> You're asking for 5 more days, which would move it to January 25th - wait, that's a Saturday, so it would actually be January 27th, Monday.
>
> What's the reason for the extension? This will help me craft a stronger request."

### After Sending
> "Done. I've sent the extension request to Bob Johnson at ABC Realty.
>
> Here's what went out:
> - Requested new deadline: January 27th
> - Reason: Specialist roof inspection needed after initial findings
> - Extension addendum attached and ready for signatures
>
> I gave them 24 hours to respond. Based on the circumstances, I'd estimate about a 70% chance of approval - you're asking before the deadline, have a legitimate reason, and it's a reasonable timeframe.
>
> I'll ping you when we get a response, or in 12 hours if we haven't heard back. Want me to call the listing agent to give them a heads up?"

### Counter Received
> "We got a response on the inspection extension request. It's a counteroffer:
>
> They're willing to extend, but only for 3 days instead of 5, which would be January 23rd.
>
> They also asked that the buyer commit to a decision by then - no further extensions.
>
> That gives you the weekend plus an extra day for the roof specialist. Is that enough time?
>
> Your options:
> 1. Accept the 3-day extension
> 2. Counter back asking for 4 days
> 3. Decline and proceed with original deadline
>
> What would you like to do?"

### Denial Received
> "The extension request was denied. The listing agent said the seller wants to stick with the original deadline.
>
> Here's where we stand: The inspection deadline is still January 20th at 5 PM - that's 2 days from now.
>
> Options:
> 1. **Proceed without the specialist** - Make a decision with current inspection results
> 2. **Try a different approach** - Perhaps a shorter extension or offer something in return
> 3. **Prepare to exercise the contingency** - Cancel if needed before deadline
>
> The roof issue is significant. What's the buyer's priority here?"

## Error Handling

| Error | Cause | Response |
|-------|-------|----------|
| `DEADLINE_COMPLETED` | Can't extend completed deadline | "This deadline was already completed on {{date}}. No extension needed." |
| `DEADLINE_WAIVED` | Contingency was waived | "This contingency was waived. Cannot request extension on waived deadlines." |
| `INVALID_EXTENSION` | New date before current | "The new date must be after the current deadline of {{date}}." |
| `EXCEEDS_CLOSING` | Extension past closing | "This extension would go past the closing date. Should I include a closing extension too?" |
| `NO_COUNTERPARTY` | Missing counterparty info | "I don't have contact info for the other party's agent. Can you provide that?" |
| `NEGOTIATION_ACTIVE` | Already negotiating this deadline | "There's already an active extension request for this deadline. Status: {{status}}" |

## Negotiation Status States

| Status | Description | Next Actions |
|--------|-------------|--------------|
| `pending` | Request sent, awaiting response | Wait, follow up if needed |
| `approved` | Extension granted | Apply extension, get signatures |
| `denied` | Extension refused | Consider alternatives |
| `counter_received` | Counteroffer received | Evaluate, accept/counter/decline |
| `counter_sent` | We sent a counteroffer | Await response |
| `expired` | No response, deadline passed | Assess missed deadline protocol |
| `withdrawn` | We withdrew the request | Close negotiation |
| `completed` | Extension fully executed | Deadline updated |

## Quality Checklist

- [x] Validates deadline is extendable
- [x] Calculates new date with weekend/holiday adjustment
- [x] Analyzes negotiation context and probability
- [x] Crafts appropriate request based on situation
- [x] Requires agent approval before sending
- [x] Attaches pre-filled extension addendum
- [x] Tracks negotiation status through lifecycle
- [x] Handles counteroffers and denials
- [x] Schedules appropriate follow-ups
- [x] Voice responses guide agent through process
- [x] Supports multiple communication channels
- [x] Documents all communications
- [x] Integrates with extend-deadline skill on approval
- [x] Handles urgent and post-deadline scenarios
- [x] Provides probability estimates with reasoning

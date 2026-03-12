# Skill: Deadline Missed Protocol

**Category:** Deadline
**Priority:** P0
**Approval Required:** Conditional (based on severity and remediation options)

## Purpose

Handle the situation when a deadline has been missed. This skill assesses the legal and practical consequences, determines available remediation options, guides the agent through next steps, and documents everything for potential dispute resolution. Missing a deadline in Florida real estate can have serious consequences ranging from minor inconveniences to contract termination or deposit forfeiture.

## Florida Legal Context

**Time is of the Essence:**
> Florida FAR/BAR contracts typically include a "Time is of the Essence" clause, meaning deadlines are legally binding and missing them can have material consequences.

**Common Missed Deadline Scenarios:**
1. **Escrow Not Deposited** - Seller may be able to void contract
2. **Inspection Period Lapsed** - Buyer deemed to accept property as-is
3. **Financing Not Secured** - Deposit may be at risk
4. **Closing Date Missed** - Either party may claim breach

**Cure Periods:**
Some contracts include automatic cure periods (e.g., 3 days to deliver escrow after notice). Homer tracks these and alerts accordingly.

## Triggers

### Automatic
- Deadline status changes to 'overdue' (due_date < TODAY)
- Scheduled job runs at 6:00 PM daily to catch deadlines that passed at 5 PM
- Real-time check when deal status is queried

### Voice Commands
- "What happens now that we missed the [deadline]?"
- "We missed the escrow deadline - what do we do?"
- "The inspection period ended and we didn't respond"
- "Financing fell through after the deadline"
- "Handle missed deadline for [property]"
- "Deadline passed - what are our options?"

### System Events
- Alert system escalation (deadline not resolved)
- Party inquiry about missed deadline
- Counterparty claim of default

### Programmatic
- `POST /deadlines/:id/missed-protocol`
- Automatic trigger when deadline becomes overdue

## Required Inputs

| Input | Type | Required | Source | Description |
|-------|------|----------|--------|-------------|
| `dealId` | UUID | Yes | context | Deal with missed deadline |
| `deadlineId` | UUID | Yes | system/voice | The missed deadline |

## Optional Inputs

| Input | Type | Default | Source | Description |
|-------|------|---------|--------|-------------|
| `discoveredAt` | Date | now | system | When the miss was discovered |
| `reason` | string | null | voice | Why deadline was missed |
| `counterpartyAware` | boolean | unknown | voice | Does other side know? |
| `cureAttempted` | boolean | false | voice | Has cure been attempted? |
| `partyAtFault` | string | null | analysis | buyer, seller, third_party, none |

## Consequence Matrix by Deadline Type

| Deadline | Immediate Consequence | Risk Level | Cure Available | Typical Cure |
|----------|----------------------|------------|----------------|--------------|
| Escrow Deposit | Seller may void contract | CRITICAL | Usually 3 days | Deliver funds + late notice |
| Inspection Period | Buyer accepts as-is | HIGH | Rarely | Seller's goodwill only |
| Financing Contingency | Deposit at risk | CRITICAL | Sometimes | Extension request |
| Appraisal Contingency | Must close at price or forfeit | HIGH | Sometimes | Renegotiate or pay gap |
| Loan Commitment | May delay closing | MEDIUM | Usually | Lender coordination |
| Title Commitment | May delay closing | LOW | Usually | Title company follow-up |
| Closing Date | Breach of contract possible | CRITICAL | Sometimes | Extension addendum |
| HOA Documents | Buyer loses cancellation right | MEDIUM | Rarely | Seller's goodwill |

## Execution Flow

```
START
  │
  ├─── 1. Load deadline and deal data
  │    ├── Get deadline by ID
  │    ├── Verify deadline is actually missed (due_date < now)
  │    ├── Get deal details
  │    ├── Get all parties info
  │    └── Load contract terms for this deadline type
  │
  ├─── 2. Calculate miss severity
  │    │
  │    ├── Time factors:
  │    │   ├── daysOverdue = today - dueDate
  │    │   ├── hoursSinceMiss = now - (dueDate at 5 PM)
  │    │   └── businessDaysOverdue = excludeWeekends(daysOverdue)
  │    │
  │    ├── Deadline category severity:
  │    │   ├── CRITICAL: escrow, financing, closing
  │    │   ├── HIGH: inspection, appraisal
  │    │   ├── MEDIUM: hoa, title, loan_commitment
  │    │   └── LOW: survey, walkthrough
  │    │
  │    └── Combined risk score:
  │        ├── Base severity + time factor
  │        ├── Escalate if counterparty aware
  │        └── Escalate if cure period expired
  │
  ├─── 3. Analyze contract for cure provisions
  │    │
  │    ├── Check for automatic cure period:
  │    │   ├── Escrow: Check Paragraph 2(a) for cure days
  │    │   ├── Financing: Check Paragraph 8 provisions
  │    │   └── Closing: Check default provisions
  │    │
  │    ├── Check if cure period still active:
  │    │   ├── Calculate cure deadline
  │    │   └── Determine time remaining
  │    │
  │    └── Document applicable contract provisions
  │
  ├─── 4. Determine responsible party
  │    │
  │    ├── Analyze cause of miss:
  │    │   │
  │    │   ├── Buyer-caused:
  │    │   │   ├── Didn't submit funds
  │    │   │   ├── Didn't provide documents
  │    │   │   └── Didn't respond in time
  │    │   │
  │    │   ├── Seller-caused:
  │    │   │   ├── Didn't provide access
  │    │   │   ├── Didn't deliver documents
  │    │   │   └── Title issues not resolved
  │    │   │
  │    │   ├── Third-party-caused:
  │    │   │   ├── Lender delays
  │    │   │   ├── Title company issues
  │    │   │   ├── Appraiser delays
  │    │   │   └── Inspector unavailable
  │    │   │
  │    │   └── Force majeure:
  │    │       ├── Natural disaster
  │    │       ├── Government action
  │    │       └── Other extraordinary circumstances
  │    │
  │    └── Assign fault for record (affects remediation strategy)
  │
  ├─── 5. Generate remediation options
  │    │
  │    ├── FOR EACH potential remedy:
  │    │   ├── Assess feasibility
  │    │   ├── Calculate success probability
  │    │   ├── Determine required actions
  │    │   └── Estimate time to implement
  │    │
  │    ├── Typical options by deadline type:
  │    │   │
  │    │   ├── ESCROW MISSED:
  │    │   │   ├── Option A: Deliver funds immediately + notice to seller
  │    │   │   ├── Option B: Request formal cure period
  │    │   │   └── Option C: Negotiate new terms
  │    │   │
  │    │   ├── INSPECTION MISSED:
  │    │   │   ├── Option A: Accept property as-is (automatic)
  │    │   │   ├── Option B: Request goodwill extension from seller
  │    │   │   └── Option C: Proceed with transaction
  │    │   │
  │    │   ├── FINANCING MISSED:
  │    │   │   ├── Option A: Provide proof of financing
  │    │   │   ├── Option B: Request extension
  │    │   │   ├── Option C: Waive contingency if loan assured
  │    │   │   └── Option D: Cancel and negotiate deposit release
  │    │   │
  │    │   └── CLOSING MISSED:
  │    │       ├── Option A: Close ASAP + cure notice
  │    │       ├── Option B: Formal extension addendum
  │    │       ├── Option C: Negotiate new closing date
  │    │       └── Option D: Terminate and negotiate deposit
  │    │
  │    └── Rank options by:
  │        ├── Likelihood of acceptance
  │        ├── Protection of deposit
  │        └── Speed of resolution
  │
  ├─── 6. Assess counterparty likely response
  │    │
  │    ├── If counterparty already notified:
  │    │   └── Factor their communication into strategy
  │    │
  │    ├── Predict likely response:
  │    │   ├── Cooperative: Likely to grant extension
  │    │   ├── Neutral: May require concessions
  │    │   ├── Adversarial: May claim breach/default
  │    │   └── Unknown: Proceed cautiously
  │    │
  │    └── Identify leverage points:
  │        ├── Market conditions (buyer's vs seller's market)
  │        ├── Days on market
  │        ├── Motivated party indicators
  │        └── Relationship history
  │
  ├─── 7. Generate recommended action plan
  │    │
  │    ├── Immediate actions (next 24 hours):
  │    │   ├── Notify affected parties
  │    │   ├── Document current status
  │    │   ├── Begin cure if applicable
  │    │   └── Prepare extension request if needed
  │    │
  │    ├── Short-term actions (next 72 hours):
  │    │   ├── Follow up on cure/extension
  │    │   ├── Prepare backup plan
  │    │   └── Monitor counterparty response
  │    │
  │    └── Contingency actions:
  │        ├── If extension denied: [plan]
  │        ├── If breach claimed: [plan]
  │        └── If deposit disputed: [plan]
  │
  ├─── 8. Prepare communication templates
  │    │
  │    ├── Generate appropriate notices:
  │    │   ├── Cure notice (if applicable)
  │    │   ├── Extension request
  │    │   ├── Explanation letter
  │    │   └── Acknowledgement of status
  │    │
  │    └── Customize for situation
  │
  ├─── 9. Update records
  │    │
  │    ├── Update deadline:
  │    │   ├── status = 'missed'
  │    │   ├── missed_at = dueDate + 1
  │    │   ├── missed_protocol_initiated = now
  │    │   └── remediation_status = 'in_progress'
  │    │
  │    ├── Update deal:
  │    │   ├── Add risk flag
  │    │   └── Log incident
  │    │
  │    └── Create action log entry:
  │        └── action_type: 'missed_deadline_protocol'
  │
  ├─── 10. Set up monitoring
  │     │
  │     ├── Schedule follow-up checks:
  │     │   ├── 24 hours: Check cure status
  │     │   ├── 48 hours: Check extension response
  │     │   └── 72 hours: Escalation if unresolved
  │     │
  │     └── Set alerts for counterparty response
  │
  └─── 11. Return protocol result
```

## Protocol by Deadline Type

### Escrow Deposit Missed

```
ESCROW MISSED
     │
     ├── Day 1 (Immediately):
     │   ├── Contact buyer: Get funds TODAY
     │   ├── Prepare funds for immediate delivery
     │   └── Document any legitimate reason
     │
     ├── Day 1-3 (Cure Period, if in contract):
     │   ├── Deliver funds to escrow holder
     │   ├── Send notice to seller: "Funds delivered, curing default"
     │   └── Document delivery with receipt
     │
     ├── If Seller Issues Default Notice:
     │   ├── Cure immediately if possible
     │   ├── Request additional time in writing
     │   └── Consult attorney if termination threatened
     │
     └── Worst Case (Seller Voids):
         ├── Document all cure attempts
         ├── May have claim if seller acts in bad faith
         └── Consult attorney for deposit recovery
```

### Inspection Period Missed

```
INSPECTION MISSED (No action taken by buyer)
     │
     ├── Automatic Effect:
     │   └── Buyer is deemed to have accepted property AS-IS
     │
     ├── Options:
     │   ├── Option A: Proceed with purchase (most common)
     │   │   └── No further inspection objections permitted
     │   │
     │   ├── Option B: Request seller goodwill
     │   │   ├── Ask seller to address known issues anyway
     │   │   └── No contractual obligation, but often granted
     │   │
     │   └── Option C: Try to terminate (difficult)
     │       ├── Must use another contingency (financing, appraisal)
     │       └── Or negotiate mutual release
     │
     └── Document:
         └── Log that inspection period expired without objection
```

### Financing Contingency Missed

```
FINANCING MISSED (Loan not approved by deadline)
     │
     ├── Assess Loan Status:
     │   ├── IF loan approved but not documented:
     │   │   ├── Get approval in writing immediately
     │   │   └── May be able to waive contingency now
     │   │
     │   ├── IF loan nearly approved:
     │   │   ├── Request extension (2-7 days typical)
     │   │   └── Provide lender timeline letter
     │   │
     │   ├── IF loan denied:
     │   │   ├── May have right to cancel (but deadline passed)
     │   │   ├── Deposit at significant risk
     │   │   └── Negotiate deposit release with seller
     │   │
     │   └── IF loan status unknown:
     │       ├── Contact lender immediately
     │       └── Request expedited decision
     │
     ├── Seller Response Options:
     │   ├── Grant extension: Best outcome
     │   ├── Demand performance: Must close or forfeit
     │   └── Terminate: May claim deposit
     │
     └── Deposit Protection:
         ├── Document all good-faith efforts
         ├── Keep all lender communications
         └── May need escrow dispute resolution
```

### Closing Date Missed

```
CLOSING MISSED
     │
     ├── Determine Cause:
     │   ├── Lender not ready: Common, usually extension granted
     │   ├── Title issues: May not be buyer's fault
     │   ├── Funds not available: Buyer default risk
     │   └── Seller won't vacate: Seller default
     │
     ├── Immediate Actions:
     │   ├── Communicate with all parties
     │   ├── Identify resolution timeline
     │   └── Prepare closing extension addendum
     │
     ├── If Extension Needed:
     │   ├── Propose new closing date
     │   ├── Both parties must sign addendum
     │   └── Update all dependent deadlines
     │
     ├── If Party Claims Breach:
     │   ├── Document your position
     │   ├── Attempt to cure immediately
     │   └── Consult attorney
     │
     └── Protect Interests:
         ├── Rate lock may expire (buyer cost)
         ├── Seller carrying costs (may demand compensation)
         └── Document everything
```

## Output

```typescript
{
  success: true,
  actionTaken: "Initiated missed deadline protocol for Escrow Deposit",
  result: {
    deadline: {
      id: "uuid",
      name: "Escrow Deposit Due",
      category: "escrow",
      dueDate: "2026-01-13",
      daysOverdue: 2,
      hoursSinceMiss: 50
    },

    severity: {
      level: "CRITICAL",
      score: 95,
      factors: [
        "Contract contingency deadline",
        "2 days overdue",
        "Seller may have termination right"
      ]
    },

    cause: {
      partyAtFault: "buyer",
      reason: "Wire transfer delayed by bank",
      documented: true
    },

    contractProvisions: {
      curePeriodExists: true,
      curePeriodDays: 3,
      curePeriodExpires: "2026-01-16",
      cureTimeRemaining: "1 day, 4 hours",
      relevantParagraph: "Paragraph 2(a): Escrow deposit cure"
    },

    remediationOptions: [
      {
        id: "option_a",
        name: "Immediate Cure",
        description: "Deliver escrow funds today with cure notice",
        feasibility: "high",
        successProbability: 0.85,
        actions: [
          "Wire $10,000 to ABC Title Company immediately",
          "Send Cure Notice to seller/listing agent",
          "Request written confirmation of cure"
        ],
        timeToImplement: "2-4 hours",
        risk: "Low - if funds delivered within cure period",
        recommended: true
      },
      {
        id: "option_b",
        name: "Request Extension",
        description: "Ask seller for additional time",
        feasibility: "medium",
        successProbability: 0.60,
        actions: [
          "Contact listing agent to explain situation",
          "Prepare Extension Addendum",
          "Offer to increase deposit as goodwill"
        ],
        timeToImplement: "24-48 hours",
        risk: "Medium - seller may decline or demand concessions"
      },
      {
        id: "option_c",
        name: "Terminate Transaction",
        description: "Cancel contract if buyer unable to perform",
        feasibility: "low",
        successProbability: 0.30,
        actions: [
          "Negotiate deposit release with seller",
          "Prepare mutual release",
          "May lose deposit or portion"
        ],
        timeToImplement: "3-7 days",
        risk: "High - deposit at risk"
      }
    ],

    recommendedPlan: {
      immediate: [
        {
          action: "Confirm funds available for wire",
          responsible: "Buyer's Agent",
          deadline: "Today, 12:00 PM"
        },
        {
          action: "Initiate wire transfer to ABC Title",
          responsible: "Buyer",
          deadline: "Today, 2:00 PM"
        },
        {
          action: "Send Cure Notice to listing agent",
          responsible: "Homer (automated)",
          deadline: "Upon wire confirmation"
        }
      ],
      shortTerm: [
        {
          action: "Confirm receipt of funds with title company",
          responsible: "Buyer's Agent",
          deadline: "Tomorrow, 10:00 AM"
        },
        {
          action: "Get written confirmation of cure from seller",
          responsible: "Listing Agent",
          deadline: "Tomorrow, 5:00 PM"
        }
      ],
      contingency: [
        {
          trigger: "Seller threatens termination",
          response: "Consult attorney, document all cure efforts"
        },
        {
          trigger: "Wire delayed again",
          response: "Offer cashier's check or alternate delivery"
        }
      ]
    },

    communicationTemplates: {
      cureNotice: {
        type: "cure_notice",
        to: "Listing Agent",
        subject: "Notice of Cure - Escrow Deposit",
        ready: true,
        preview: "Please be advised that the escrow deposit..."
      },
      extensionRequest: {
        type: "extension_request",
        to: "Listing Agent",
        subject: "Request for Escrow Deadline Extension",
        ready: true
      }
    },

    dealImpact: {
      riskLevel: "elevated",
      depositAtRisk: true,
      depositAmount: 10000,
      transactionViability: "at risk until cured",
      sellerLikelyResponse: "cooperative" // based on transaction history
    },

    monitoring: {
      nextCheckIn: "2026-01-15T12:00:00Z",
      alerts: [
        "Cure period expires in 28 hours",
        "Check wire status every 2 hours"
      ],
      escalationTrigger: "Cure period expires without resolution"
    }
  },
  requiresApproval: true,
  approvalMessage: "Confirm recommended cure action?",
  shouldContinue: true
}
```

## Voice Responses

### Critical Deadline Missed
> "The escrow deposit deadline was missed 2 days ago - this is a critical situation. Here's what I know:
>
> The deposit was due January 13th. Today is January 15th, so we're 2 days overdue.
>
> **Good news:** The contract has a 3-day cure period, so we still have until tomorrow at 5 PM to fix this.
>
> **Here's what we need to do:**
> 1. Get the $10,000 wire sent TODAY
> 2. I'll send a cure notice to the listing agent
> 3. Get written confirmation once the title company receives the funds
>
> The buyer said the delay was due to a bank wire issue. Has that been resolved?
>
> If we cure by tomorrow, we should be fine. If we can't, the seller may have the right to void the contract.
>
> What would you like me to do first?"

### Inspection Period Missed
> "The inspection period for 456 Oak Avenue ended yesterday at 5 PM without the buyer submitting any repair requests or cancellation notice.
>
> **What this means:** Under Florida law, the buyer is now deemed to have accepted the property as-is. They cannot request repairs or cancel based on inspection findings.
>
> **The options are:**
> 1. **Proceed as planned** - Most common. The buyer accepted the property.
> 2. **Ask the seller for goodwill repairs** - No obligation, but sometimes sellers agree
> 3. **Use another contingency** - If they have financing or appraisal contingency remaining
>
> Was this intentional, or did the buyer mean to submit something?"

### Providing Options
> "Okay, the financing contingency deadline passed and the loan isn't fully approved yet. Here are the options I see:
>
> **Option A: Request a 5-day extension**
> - Success rate: About 60% in current market
> - I can draft the extension request right now
> - May need to offer something (cover seller's rate lock extension cost, for example)
>
> **Option B: Waive contingency if loan is close**
> - Only if the lender is 90%+ sure of approval
> - Risky if anything falls through
>
> **Option C: Try to terminate and negotiate deposit release**
> - Hardest path since deadline passed
> - May lose part or all of $15,000 deposit
>
> My recommendation is Option A - request the extension. The listing agent has been cooperative so far.
>
> Which approach would you like to take?"

## Communication Templates

### Cure Notice

```
NOTICE OF CURE

Date: {{current_date}}
Property: {{property_address}}
Contract Date: {{contract_date}}

Dear {{listing_agent_name}} and {{seller_name}}:

This notice is to advise that the {{deadline_name}} has been cured as follows:

Original Deadline: {{original_due_date}}
Cure Delivered: {{cure_date}}
Cure Period: Per Contract Paragraph {{paragraph_reference}}

{{#if escrow}}
The escrow deposit of ${{escrow_amount}} was delivered to {{escrow_holder}}
on {{delivery_date}} at {{delivery_time}} via {{delivery_method}}.

Wire/Check Reference: {{reference_number}}
{{/if}}

Please confirm receipt of this cure notice and acknowledgement that the
contract remains in full force and effect.

Sincerely,

{{buyers_agent_name}}
{{buyers_agent_company}}
{{buyers_agent_phone}}
```

### Extension Request

```
REQUEST FOR EXTENSION

Date: {{current_date}}
Property: {{property_address}}

Dear {{listing_agent_name}}:

On behalf of the Buyer, we respectfully request an extension of the
{{deadline_name}} deadline.

Original Deadline: {{original_due_date}}
Requested New Deadline: {{requested_new_date}}
Extension Period: {{extension_days}} days

Reason for Request:
{{extension_reason}}

{{#if concession_offered}}
As consideration for this extension, Buyer offers:
{{concession_details}}
{{/if}}

Please respond at your earliest convenience. An Extension Addendum
is attached for signatures if this request is approved.

Thank you for your consideration.

{{buyers_agent_name}}
```

## Error Handling

| Error | Cause | Response |
|-------|-------|----------|
| `DEADLINE_NOT_MISSED` | Deadline is still in the future | "This deadline isn't missed yet - it's due {{daysUntil}} days from now. Want me to set a reminder?" |
| `ALREADY_HANDLED` | Protocol already initiated | "This missed deadline was already handled on {{date}}. Status: {{status}}" |
| `NO_CURE_AVAILABLE` | Some deadlines have no cure | "This deadline type doesn't have a standard cure provision. Your options are: [list]" |
| `DEAL_TERMINATED` | Deal already cancelled | "This deal was terminated on {{date}}. The missed deadline protocol doesn't apply." |

## Quality Checklist

- [x] Correctly identifies when deadline is truly missed
- [x] Calculates precise time overdue (hours and days)
- [x] Assesses severity based on deadline type and time factors
- [x] Checks contract for cure provisions
- [x] Determines responsible party fairly
- [x] Generates multiple remediation options
- [x] Ranks options by feasibility and success probability
- [x] Provides specific action steps with timelines
- [x] Creates ready-to-use communication templates
- [x] Sets up monitoring and follow-up checks
- [x] Voice responses explain consequences clearly
- [x] Documents everything for potential disputes
- [x] Handles all major deadline types with specific protocols
- [x] Protects deposit when possible
- [x] Recommends attorney consultation when appropriate

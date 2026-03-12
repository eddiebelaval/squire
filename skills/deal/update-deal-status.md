# Skill: Update Deal Status

**Category:** Deal
**Priority:** P0
**Approval Required:** Conditional (see approval matrix)

## Purpose

Progress a real estate transaction through its lifecycle stages. This skill manages status transitions from draft through closing, ensuring proper validation, notifications, and audit logging at each stage.

## Triggers

### Voice Commands
- "Mark deal as active"
- "The [address] deal is now pending"
- "We closed on [address]"
- "Move [address] to [status]"
- "Activate the deal for [address]"
- "Deal fell through at [address]"
- "[Address] is under contract"

### Programmatic
- Contract execution confirmed
- Inspection period completed
- Financing approved
- All contingencies cleared
- Closing completed in title system
- API call to `/deals/{id}/status`

## Required Inputs

| Input | Type | Required | Source | Description |
|-------|------|----------|--------|-------------|
| `dealId` | UUID | Yes* | context/manual | Deal to update |
| `propertyAddress` | string | Yes* | voice | Can identify deal by address |
| `newStatus` | string | Yes | voice/manual | Target status |

*One of dealId or propertyAddress required

## Optional Inputs

| Input | Type | Default | Source | Description |
|-------|------|---------|--------|-------------|
| `reason` | string | null | voice/manual | Reason for status change |
| `effectiveDate` | Date | now | manual | When status change occurred |
| `notes` | string | null | voice | Additional context |
| `notifyParties` | boolean | true | config | Send notifications |
| `skipValidation` | boolean | false | manual | Bypass pre-checks (admin only) |

## Deal Status Lifecycle

```
                                    ┌─────────────┐
                                    │   DRAFT     │
                                    │ (initial)   │
                                    └──────┬──────┘
                                           │
                           Contract executed/effective date set
                                           │
                                    ┌──────▼──────┐
                   ┌────────────────│   ACTIVE    │────────────────┐
                   │                │(under contract)              │
                   │                └──────┬──────┘                │
                   │                       │                       │
               Deal falls through     All contingencies      Buyer/seller
               (any reason)           cleared                 backs out
                   │                       │                       │
                   │                ┌──────▼──────┐                │
                   │                │   PENDING   │                │
                   │                │(clear to close)              │
                   │                └──────┬──────┘                │
                   │                       │                       │
                   │                  Closing completed            │
                   │                       │                       │
                   │                ┌──────▼──────┐                │
                   ├───────────────>│  CANCELLED  │<───────────────┤
                   │                │ (fell through)               │
                   │                └─────────────┘                │
                   │                                               │
                   │                ┌─────────────┐                │
                   │                │   CLOSED    │<───────────────┘
                   │                │ (completed) │
                   │                └──────┬──────┘
                   │                       │
                   │                  30 days later
                   │                       │
                   │                ┌──────▼──────┐
                   └───────────────>│  ARCHIVED   │
                                    │ (historical)│
                                    └─────────────┘
```

## Status Definitions

| Status | Description | Deadlines Active | Can Edit |
|--------|-------------|------------------|----------|
| `draft` | Deal created but not yet under contract | No | Full |
| `active` | Under contract, working toward closing | Yes | Limited |
| `pending` | All contingencies cleared, awaiting closing | Yes | Minimal |
| `closed` | Transaction successfully completed | No (historical) | Read-only |
| `cancelled` | Deal fell through or terminated | No | Read-only |
| `archived` | Historical record after 30 days | No | Read-only |

## Execution Flow

```
START
  │
  ├─── 1. Identify deal
  │    ├── If dealId provided → load deal
  │    ├── If propertyAddress provided → find deal by address
  │    └── Verify deal exists and user has access
  │
  ├─── 2. Validate status transition
  │    ├── Check transition is allowed (see matrix)
  │    ├── If not allowed → return error with explanation
  │    └── If skipValidation=true and user is admin → bypass
  │
  ├─── 3. Pre-transition requirements check
  │    │
  │    ├── DRAFT → ACTIVE requires:
  │    │   ├── Effective date set
  │    │   ├── Contract uploaded or parsed
  │    │   ├── At least one buyer and seller
  │    │   └── Purchase price set
  │    │
  │    ├── ACTIVE → PENDING requires:
  │    │   ├── Inspection contingency cleared or expired
  │    │   ├── Financing contingency cleared or expired
  │    │   ├── Appraisal completed (if applicable)
  │    │   ├── HOA approval received (if applicable)
  │    │   └── All deposits received
  │    │
  │    ├── PENDING → CLOSED requires:
  │    │   ├── Closing date reached
  │    │   ├── Clear to close issued (recommended)
  │    │   ├── All parties present/signed
  │    │   └── Funds disbursed (recommended)
  │    │
  │    └── Any → CANCELLED requires:
  │        └── Reason provided
  │
  ├─── 4. Check approval requirements
  │    ├── DRAFT → ACTIVE: No approval needed
  │    ├── ACTIVE → PENDING: No approval needed
  │    ├── PENDING → CLOSED: Confirm with agent
  │    ├── Any → CANCELLED: Confirm reason
  │    └── If approval needed → request and wait
  │
  ├─── 5. Update deal record
  │    ├── Set new status
  │    ├── Set status_changed_at timestamp
  │    ├── Store previous status for audit
  │    ├── Update notes if provided
  │    └── Set status_changed_by (current user)
  │
  ├─── 6. Trigger status-specific actions
  │    │
  │    ├── On ACTIVE:
  │    │   ├── INVOKE: calculate-deadlines (if not done)
  │    │   ├── Start deadline notifications
  │    │   └── Add to active deals dashboard
  │    │
  │    ├── On PENDING:
  │    │   ├── Mark remaining deadlines as "contingent"
  │    │   ├── Highlight closing date
  │    │   └── Trigger clear-to-close checklist
  │    │
  │    ├── On CLOSED:
  │    │   ├── INVOKE: archive-deal (scheduled for 30 days)
  │    │   ├── Mark all deadlines complete
  │    │   ├── Generate closing summary
  │    │   └── Update agent stats
  │    │
  │    └── On CANCELLED:
  │        ├── Mark all deadlines cancelled
  │        ├── Store cancellation reason
  │        ├── Update agent stats
  │        └── INVOKE: cancel-deal for cleanup
  │
  ├─── 7. Send notifications (if notifyParties=true)
  │    ├── Agent notification
  │    ├── Transaction coordinator notification
  │    ├── Relevant party notifications
  │    └── Email/SMS based on preferences
  │
  ├─── 8. Log status change
  │    └── action_type: 'deal_status_updated'
  │
  └── RETURN updated deal
```

## Status Transition Matrix

| From ↓ / To → | draft | active | pending | closed | cancelled | archived |
|---------------|-------|--------|---------|--------|-----------|----------|
| draft | - | Yes | No | No | Yes | No |
| active | Yes* | - | Yes | No | Yes | No |
| pending | No | Yes* | - | Yes | Yes | No |
| closed | No | No | No | - | No | Yes |
| cancelled | No | No | No | No | - | Yes |
| archived | No | No | No | No | No | - |

*Backward transitions require explicit reason

## Approval Requirements

| Transition | Approval | Reason |
|------------|----------|--------|
| draft → active | None | Low risk, reversible |
| active → pending | None | Progress toward closing |
| pending → closed | Confirm | Irreversible, high stakes |
| any → cancelled | Reason required | Need to document why |
| closed → archived | None | Automatic after 30 days |

## Output

```typescript
{
  success: true,
  actionTaken: "Updated 123 Main St deal status from ACTIVE to PENDING",
  result: {
    deal: {
      id: "uuid",
      propertyAddress: "123 Main St, Miami FL 33101",
      previousStatus: "active",
      currentStatus: "pending",
      statusChangedAt: "2026-02-15T14:30:00Z",
      statusChangedBy: "agent@brokerage.com"
    },

    actionsTriggered: [
      "Marked 3 deadline contingencies as cleared",
      "Updated dashboard to show pending status",
      "Highlighted closing date: March 12, 2026"
    ],

    notifications: [
      { to: "agent@brokerage.com", method: "push", sent: true },
      { to: "tc@brokerage.com", method: "email", sent: true }
    ],

    nextSteps: [
      "Confirm closing date and time with title company",
      "Schedule final walkthrough",
      "Ensure clear to close is issued",
      "Confirm wire instructions with buyer"
    ],

    remainingDeadlines: [
      { name: "Closing", date: "2026-03-12", daysRemaining: 25 }
    ]
  }
}
```

## Voice Response

**Activating a Deal:**
> "Got it, I've activated the deal for 123 Main Street.
>
> The effective date is set to January 15th, and I've generated all your deadlines. The inspection period ends January 30th, financing contingency February 14th, and closing is March 12th.
>
> I'll start sending reminders 5 days before each deadline. Anything else you need on this one?"

**Moving to Pending:**
> "Perfect, I've moved 123 Main Street to pending status. All contingencies are cleared.
>
> Closing is in 25 days on March 12th. Here's what's left to do:
> - Confirm closing time with ABC Title
> - Schedule the final walkthrough
> - Make sure clear to close is issued
>
> Want me to create tasks for these?"

**Closing a Deal:**
> "Congratulations! I've marked 123 Main Street as closed.
>
> Purchase price was $450,000, closed on March 12th. That's your 3rd closing this month.
>
> I'll automatically archive this deal in 30 days. Need anything else?"

**Cancelling a Deal:**
> "I've cancelled the deal for 123 Main Street. Recorded the reason as 'Buyer failed to secure financing.'
>
> All deadlines have been cleared from your calendar. Sorry this one didn't work out. Want to discuss what happened or move on to the next deal?"

## Error Handling

| Error | Cause | Response |
|-------|-------|----------|
| `DEAL_NOT_FOUND` | Invalid dealId or address | "I can't find a deal for that address. Can you check the address or deal ID?" |
| `INVALID_TRANSITION` | Status change not allowed | "I can't move this deal from [current] to [target]. [Explanation of allowed transitions]" |
| `MISSING_REQUIREMENTS` | Pre-conditions not met | "Before I can mark this as [status], I need: [list missing items]" |
| `APPROVAL_REQUIRED` | User must confirm | "Just to confirm - you want to mark 123 Main Street as closed? This is permanent. Yes or no?" |
| `REASON_REQUIRED` | Cancellation needs reason | "I need to know why the deal is being cancelled. What happened?" |
| `ALREADY_IN_STATUS` | Deal is already in target status | "The deal for 123 Main Street is already [status]. Did you mean something else?" |

## Integration Points

### Triggers After Status Change
| New Status | Triggered Actions |
|------------|-------------------|
| active | calculate-deadlines, start-notifications |
| pending | clear-to-close checklist, highlight closing |
| closed | archive-deal (30 day delay), update-stats |
| cancelled | cancel-deal, cleanup-deadlines |

### Database Tables
- `deals` - Status field update
- `deal_status_history` - Full transition history
- `deadlines` - Status-dependent updates
- `action_log` - Audit entry

### External Notifications
- Push notifications to Homer Pro app
- Email via SendGrid/SES
- SMS via Twilio (if enabled)
- Slack/Teams integration (if configured)

## Example Usage

### Voice Status Update
```
Agent: "Hey Homer, we're under contract on the Oak Street property"

Homer: "Great news! I'll activate the deal for 456 Oak Street.

        Before I do, I just need to confirm:
        - Effective date: January 15, 2026 ✓
        - Contract uploaded: Yes ✓
        - Buyer: John Smith ✓
        - Seller: Jane Doe ✓
        - Purchase price: $385,000 ✓

        Everything looks good. Deal is now ACTIVE. I've set up
        10 deadlines and will start sending reminders.

        Inspection period ends January 30th. Anything else?"
```

### Closing Confirmation
```
Agent: "We closed on Main Street today"

Homer: "Congratulations! Just to confirm - you want me to mark
        123 Main Street as CLOSED? This is permanent and will
        archive the deal after 30 days.

        Did everything go smoothly at closing?"

Agent: "Yes, all good"

Homer: "Perfect! I've marked the deal as closed.

        Final details:
        - Property: 123 Main St, Miami FL 33101
        - Buyer: John Smith
        - Seller: Jane Doe
        - Purchase Price: $450,000
        - Closed: January 15, 2026

        This will be archived on February 15th. Need anything else?"
```

### Cancellation with Reason
```
Agent: "The deal on Pine Avenue fell through"

Homer: "Sorry to hear that. I'll mark 789 Pine Avenue as cancelled.

        What was the reason? I need to log this for your records."

Agent: "Buyer couldn't get financing approved"

Homer: "Got it. I've cancelled the deal with reason: 'Buyer failed
        to secure financing.'

        All deadlines have been removed from your calendar. The
        inspection was completed and the appraisal came back at
        $395,000 - do you want me to save any notes for future
        reference on this property?"
```

## Quality Checklist

- [x] Handles voice input naturally
- [x] Validates status transitions
- [x] Checks pre-conditions for each status
- [x] Requires approval for irreversible actions
- [x] Logs all status changes with full audit trail
- [x] Sends appropriate notifications
- [x] Triggers downstream actions (deadlines, archive, etc.)
- [x] Handles backward transitions with reason
- [x] Provides clear next steps at each stage
- [x] Stores cancellation reasons
- [x] Updates agent statistics
- [x] Handles errors gracefully
- [x] Florida-specific compliance considered

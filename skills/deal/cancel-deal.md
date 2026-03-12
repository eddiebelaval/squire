# Skill: Cancel Deal

**Category:** Deal
**Priority:** P1
**Approval Required:** Yes (reason required)

## Purpose

Handle the cancellation of a real estate transaction with proper documentation, notifications, and cleanup. This skill ensures all parties are notified, deadlines are cleared, and proper records are maintained for legal and compliance purposes.

## Triggers

### Voice Commands
- "Cancel the deal at [address]"
- "The [address] transaction fell through"
- "Buyer backed out on [address]"
- "Terminate contract for [address]"
- "Deal is dead at [address]"
- "Kill the deal at [address]"

### Programmatic
- Cancellation form received
- Mutual release signed
- Default notice processed
- API call to `/deals/{id}/cancel`
- Status update to 'cancelled' (invokes this skill)

## Required Inputs

| Input | Type | Required | Source | Description |
|-------|------|----------|--------|-------------|
| `dealId` | UUID | Yes* | context/manual | Deal to cancel |
| `propertyAddress` | string | Yes* | voice | Can identify deal by address |
| `cancellationReason` | string | Yes | voice/form | Why deal is being cancelled |

*One of dealId or propertyAddress required

## Optional Inputs

| Input | Type | Default | Source | Description |
|-------|------|---------|--------|-------------|
| `cancellationType` | string | 'mutual' | form | See cancellation types below |
| `initiatingParty` | string | null | form | buyer/seller/mutual |
| `cancellationDate` | Date | now | form | Effective date of cancellation |
| `escrowDisposition` | string | null | form | What happens to escrow deposit |
| `mutualReleaseUrl` | URL | null | upload | Signed mutual release document |
| `notifyParties` | boolean | true | config | Send cancellation notifications |
| `notes` | string | null | voice | Additional context |

## Cancellation Types

| Type | Description | Escrow Handling |
|------|-------------|-----------------|
| `mutual` | Both parties agree to cancel | Per mutual release agreement |
| `buyer_default` | Buyer failed to perform | Seller may claim escrow |
| `seller_default` | Seller failed to perform | Buyer entitled to return |
| `contingency_not_met` | Legitimate contingency exit | Buyer escrow returned |
| `inspection_termination` | Buyer exercised inspection right | Buyer escrow returned |
| `financing_failed` | Buyer couldn't secure financing | Buyer escrow returned (usually) |
| `appraisal_gap` | Property didn't appraise | Depends on contract terms |
| `hoa_denial` | HOA/Condo rejected buyer | Buyer escrow returned |
| `title_defect` | Unmarketable title | Buyer escrow returned |
| `other` | Other reason | Varies |

## Execution Flow

```
START
  │
  ├─── 1. Identify deal
  │    ├── If dealId provided → load deal
  │    ├── If propertyAddress provided → find active deal
  │    ├── Verify deal exists and is cancellable
  │    └── Check current status (must be draft, active, or pending)
  │
  ├─── 2. Request required information
  │    ├── Confirm cancellation reason
  │    ├── Identify initiating party (if not provided)
  │    ├── Classify cancellation type
  │    └── Capture any additional notes
  │
  ├─── 3. Validate cancellation is allowed
  │    ├── Check deal status allows cancellation
  │    ├── Verify user has permission to cancel
  │    └── Check for any blocking conditions
  │
  ├─── 4. Request confirmation
  │    ├── Show deal summary
  │    ├── Show cancellation details
  │    ├── Confirm this is irreversible
  │    └── Wait for explicit confirmation
  │
  ├─── 5. Update deal record
  │    ├── Set status = 'cancelled'
  │    ├── Set cancellation_reason
  │    ├── Set cancellation_type
  │    ├── Set cancelled_at timestamp
  │    ├── Set cancelled_by (current user)
  │    ├── Store initiating_party
  │    └── Store escrow_disposition
  │
  ├─── 6. Cancel all active deadlines
  │    ├── Mark all deadlines as 'cancelled'
  │    ├── Clear from calendar/reminders
  │    └── Store deadline state at cancellation
  │
  ├─── 7. Handle escrow tracking
  │    ├── If escrow_disposition known → record decision
  │    ├── If not → create task for escrow resolution
  │    └── Flag for title company notification
  │
  ├─── 8. Generate cancellation summary
  │    ├── Timeline of key events
  │    ├── Days under contract
  │    ├── Escrow amounts involved
  │    └── Document references
  │
  ├─── 9. Store cancellation documents
  │    ├── Mutual release (if uploaded)
  │    ├── Cancellation notice
  │    └── Any termination letters
  │
  ├─── 10. Send notifications (if notifyParties=true)
  │     ├── Agent notification
  │     ├── Transaction coordinator
  │     ├── Title company (escrow holder)
  │     ├── Lender (if applicable)
  │     └── Other parties as appropriate
  │
  ├─── 11. Update statistics
  │     ├── Update agent deal stats
  │     ├── Track cancellation reason analytics
  │     └── Record time-to-cancellation
  │
  ├─── 12. Log cancellation
  │     └── action_type: 'deal_cancelled'
  │
  └── RETURN cancellation confirmation
```

## Output

```typescript
{
  success: true,
  actionTaken: "Cancelled deal for 123 Main St, Miami FL 33101",
  result: {
    deal: {
      id: "uuid",
      propertyAddress: "123 Main St, Miami FL 33101",
      previousStatus: "active",
      currentStatus: "cancelled",
      cancelledAt: "2026-02-01T10:30:00Z",
      cancelledBy: "agent@brokerage.com"
    },

    cancellation: {
      reason: "Buyer failed to secure financing within contingency period",
      type: "financing_failed",
      initiatingParty: "buyer",
      escrowDisposition: "pending_resolution",
      daysUnderContract: 32,
      effectiveDate: "2026-01-15",
      cancellationDate: "2026-02-01"
    },

    escrow: {
      amount: 10000,
      holder: "ABC Title Company",
      status: "held_pending_release",
      expectedDisposition: "return_to_buyer",
      releaseFormNeeded: true
    },

    deadlinesCancelled: [
      { name: "Inspection Period", originalDate: "2026-01-30", status: "cancelled" },
      { name: "Financing Contingency", originalDate: "2026-02-14", status: "cancelled" },
      { name: "Closing", originalDate: "2026-03-12", status: "cancelled" }
    ],

    notifications: [
      { to: "listing_agent@brokerage.com", method: "email", sent: true },
      { to: "buyer_agent@other.com", method: "email", sent: true },
      { to: "title@abctitle.com", method: "email", sent: true },
      { to: "lender@mortgage.com", method: "email", sent: true }
    ],

    tasksCreated: [
      {
        task: "Escrow Release Decision",
        assignedTo: "transaction_coordinator",
        dueDate: "2026-02-08",
        description: "Obtain mutual release for escrow funds"
      }
    ],

    summary: {
      propertyAddress: "123 Main St, Miami FL 33101",
      purchasePrice: 450000,
      buyers: ["John Smith"],
      sellers: ["Jane Doe"],
      effectiveDate: "2026-01-15",
      cancellationDate: "2026-02-01",
      daysUnderContract: 17,
      reason: "Financing contingency - buyer loan denied"
    }
  }
}
```

## Voice Response

**Standard Cancellation:**
> "I've cancelled the deal for 123 Main Street. Sorry this one didn't work out.
>
> Reason recorded: Buyer couldn't secure financing within the contingency period.
>
> The deal was under contract for 17 days. Here's what I've done:
> - Cleared all deadlines from your calendar
> - Notified the listing agent, buyer's agent, title company, and lender
> - Created a task for escrow release - the $10,000 deposit should go back to the buyer
>
> The mutual release form will need signatures from both parties. Want me to send the escrow release form to the title company?"

**Buyer Default:**
> "I've cancelled the deal for 456 Oak Avenue. Recorded as buyer default - buyer failed to provide escrow deposit on time.
>
> Important: Because this is a buyer default, the seller may be entitled to claim the escrow deposit as liquidated damages. I've flagged this for the title company.
>
> All deadlines cleared. The seller is now free to put the property back on the market. Need anything else?"

**Inspection Termination:**
> "Got it, I've cancelled the deal for 789 Pine Lane. The buyer exercised their right to terminate during the inspection period - that's a clean exit.
>
> The $15,000 escrow deposit should be returned to the buyer in full. I've notified ABC Title to release the funds.
>
> This was day 12 of the inspection period, so the timing is within their rights. Anything you want me to note about the inspection findings for future reference?"

## Error Handling

| Error | Cause | Response |
|-------|-------|----------|
| `DEAL_NOT_FOUND` | Invalid dealId or no active deal at address | "I can't find an active deal for that address. Can you verify?" |
| `DEAL_NOT_CANCELLABLE` | Deal is closed or already cancelled | "This deal is already [closed/cancelled]. I can't cancel it again." |
| `REASON_REQUIRED` | No cancellation reason provided | "I need to know why the deal is being cancelled. What happened?" |
| `CONFIRMATION_DECLINED` | User didn't confirm | "Okay, I won't cancel the deal. Let me know if you change your mind." |
| `PERMISSION_DENIED` | User can't cancel this deal | "You don't have permission to cancel this deal. Please contact the listing agent." |

## Integration Points

### Triggers After Cancellation
- Clear all scheduled reminders
- Update MLS status (if integrated)
- Archive deal for 30 days
- Update agent dashboard statistics

### Database Tables
- `deals` - Status and cancellation fields
- `deal_cancellations` - Detailed cancellation record
- `deadlines` - Mark all as cancelled
- `escrow_tracking` - Update disposition
- `action_log` - Audit entry
- `notifications` - Record sent notices

### External Services
- Title company notification (email)
- Lender notification (if financed deal)
- MLS integration (if available)
- Email service for party notifications

## Florida-Specific Considerations

### Escrow Deposit Rules
Florida law governs escrow dispute resolution:

| Scenario | Typical Resolution |
|----------|-------------------|
| Mutual agreement | Per mutual release terms |
| Buyer contingency exit | Full refund to buyer |
| Buyer default | Seller claims (per contract terms) |
| Seller default | Full refund to buyer |
| Disputed | Escrow interpleader (court) or FREC mediation |

### Required Documentation
- **Mutual Release Form**: FAR/BAR standard form for agreed cancellation
- **Cancellation Notice**: Written notice to all parties
- **Escrow Release**: Signed authorization for fund disbursement

### Timeframes
- Escrow holder must disburse within 30 days of proper demand
- If disputed, holder may initiate interpleader within 30 days
- FREC provides mediation services for escrow disputes

## Example Usage

### Voice Cancellation Flow
```
Agent: "Homer, the deal on Main Street fell through"

Homer: "Sorry to hear that. I'll cancel the deal for 123 Main Street.

        I need a bit more information:
        - What's the reason for the cancellation?"

Agent: "The buyer's financing fell through"

Homer: "Got it. So the buyer couldn't secure financing within the
        contingency period. Is that right?"

Agent: "Yes"

Homer: "One more thing - what's happening with the $10,000 escrow
        deposit? Should it go back to the buyer?"

Agent: "Yes, full refund"

Homer: "Okay, just to confirm before I cancel:

        - Property: 123 Main Street, Miami
        - Reason: Buyer financing failed
        - Escrow: $10,000 returned to buyer

        This will clear all deadlines and notify all parties.
        Proceed with cancellation?"

Agent: "Yes"

Homer: "Done. Deal cancelled. I've notified ABC Title about the
        escrow release and cleared your calendar. Sorry this one
        didn't work out. Ready for the next one?"
```

### Disputed Escrow Situation
```
Agent: "Cancel the Oak Street deal - buyer defaulted"

Homer: "I'll cancel the deal for 456 Oak Street as a buyer default.

        I see the escrow deposit is $25,000. In a buyer default,
        the seller may be entitled to claim this as liquidated
        damages. But both parties will need to sign a release.

        What's the escrow disposition?
        1. Seller claims the deposit
        2. Return to buyer anyway
        3. Disputed - let the parties work it out"

Agent: "The seller wants to claim it"

Homer: "Got it. I've noted that the seller is claiming the escrow
        deposit due to buyer default. The title company will need:

        1. Written demand from seller
        2. 15-day waiting period
        3. If buyer doesn't object, funds release to seller

        If the buyer disputes, it may go to mediation or court.
        I've created a task for the TC to follow up with the title
        company.

        Deal is cancelled. All deadlines cleared."
```

## Quality Checklist

- [x] Handles voice input naturally
- [x] Requires explicit reason for cancellation
- [x] Classifies cancellation type correctly
- [x] Confirms before irreversible action
- [x] Clears all deadlines and reminders
- [x] Tracks escrow disposition
- [x] Notifies all relevant parties
- [x] Creates follow-up tasks for escrow
- [x] Generates cancellation summary
- [x] Stores cancellation documents
- [x] Updates agent statistics
- [x] Creates comprehensive audit log
- [x] Handles escrow disputes properly
- [x] Florida-specific escrow rules applied
- [x] Handles errors gracefully

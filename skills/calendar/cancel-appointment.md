# Skill: Cancel Appointment

**Category:** Calendar
**Priority:** P0
**Approval Required:** No (P1 for high-stakes like closing)

## Purpose

Cancel an existing appointment and notify all affected parties. Handles proper communication, calendar cleanup, and any downstream implications (linked appointments, deadline impacts). Ensures professional handling of cancellations with appropriate notice and clear messaging.

## Triggers

### Voice Commands
- "Cancel the [appointment type] for [address]"
- "Cancel the inspection"
- "We need to cancel the closing"
- "Cancel my [time] appointment"
- "Remove the showing at [address]"
- "Cancel [confirmation number]"
- "The buyer cancelled, cancel the inspection"
- "Cancel everything for [address]"
- "Pull the plug on the [appointment]"

### Programmatic
- `DELETE /appointments/:id`
- `POST /appointments/:id/cancel`
- External cancellation notification (ShowingTime, etc.)
- Deal cancelled (cascade cancellation)

### Automatic
- Deal marked as cancelled
- Party requests cancellation via portal
- Inspection period ends (auto-cancel pending inspections)

## Required Inputs

| Input | Type | Required | Source | Description |
|-------|------|----------|--------|-------------|
| `appointmentId` | UUID | Yes* | context | Appointment to cancel |
| `confirmationNumber` | string | Yes* | voice | Appointment confirmation number |
| `appointmentType` | string | Yes* | voice | Type + address to identify |

*One identifier required to locate the appointment.

## Optional Inputs

| Input | Type | Default | Source | Description |
|-------|------|---------|--------|-------------|
| `reason` | string | null | voice | Reason for cancellation |
| `notifyParties` | boolean | true | default | Send cancellation notices |
| `updateCalendars` | boolean | true | default | Remove from synced calendars |
| `cancelLinked` | boolean | false | voice | Cancel linked appointments too |
| `refundExpected` | boolean | null | context | Note about any fees/refunds |
| `rescheduleIntent` | boolean | null | voice | Planning to reschedule later |
| `cancellationSource` | string | 'agent' | context | Who initiated: agent, buyer, seller, inspector |
| `notes` | string | null | voice | Additional notes |

## Appointment Type Cancellation Rules

| Type | Notice | Special Handling |
|------|--------|------------------|
| Inspection | None required | May need inspector fee discussion |
| Walkthrough | None required | Consider rescheduling instead |
| Closing | 24-48 hrs preferred | Title company, lender notification critical |
| Showing | Per listing terms | ShowingTime cancellation |
| Appraisal | 24 hrs | May incur fee |

## Cancellation Impact by Source

| Source | Likely Reason | Downstream Actions |
|--------|---------------|-------------------|
| Buyer | Cold feet, competing offer, financing issues | Review deal status |
| Seller | Accepted backup offer, changed mind | May be contract breach |
| Inspector | Emergency, scheduling conflict | Offer rescheduling immediately |
| Title Company | Title issues, document problems | Investigate, may need extension |
| Lender | Financing fell through, CD issues | Deal may be at risk |
| Agent | Strategic timing, coordination | Standard handling |

## Execution Flow

```
START
  |
  +--- 1. Identify appointment
  |    +-- If appointmentId: load directly
  |    +-- If confirmationNumber: look up
  |    +-- If type + context: find matching
  |    +-- Validate appointment exists and is cancellable
  |
  +--- 2. Load appointment context
  |    +-- Original date, time, attendees
  |    +-- Linked appointments
  |    +-- Deal context
  |    +-- Calendar invites sent
  |    +-- Notification history
  |
  +--- 3. Check for implications
  |    +-- Is this a high-stakes cancellation? (closing)
  |    +-- Are there linked appointments?
  |    +-- Are there deadline implications?
  |    +-- Are there fee implications?
  |    +-- Is the deal still active?
  |
  +--- 4. Request confirmation (if high-stakes)
  |    +-- For closing: require explicit confirmation
  |    +-- For same-day: note urgency
  |    +-- For inspector/appraiser: note possible fees
  |
  +--- 5. Update appointment record
  |    +-- Set status = 'cancelled'
  |    +-- Record cancellation reason
  |    +-- Record cancellation source
  |    +-- Record cancelled_by
  |    +-- Set cancelled_at timestamp
  |
  +--- 6. Update external systems
  |    +-- If inspection: notify inspector system
  |    +-- If showing: cancel in ShowingTime
  |    +-- If closing: notify title company
  |    +-- If appraisal: notify lender
  |
  +--- 7. Update calendars (if enabled)
  |    +-- Remove from Google Calendar
  |    +-- Remove from Outlook
  |    +-- Mark as cancelled (some prefer this over delete)
  |
  +--- 8. Send notifications (if enabled)
  |    +-- INVOKE: send-email (cancellation notice)
  |    +-- Include:
  |        +-- What was cancelled
  |        +-- Original date/time
  |        +-- Reason (if provided)
  |        +-- Whether rescheduling is planned
  |    |
  |    +-- If same-day:
  |        +-- INVOKE: send-sms (urgent notification)
  |
  +--- 9. Cancel reminder jobs
  |    +-- Remove all scheduled reminders
  |    +-- Cancel any pre-appointment notifications
  |
  +--- 10. Handle linked appointments
  |     +-- If cancelLinked = true: cancel all linked
  |     +-- If cancelLinked = false: warn about orphans
  |     |   +-- E.g., "Walkthrough still scheduled but closing cancelled"
  |     +-- Suggest appropriate action
  |
  +--- 11. Update deal (if applicable)
  |     +-- Clear scheduled flags
  |     +-- Update timeline
  |     +-- Note if this affects deadlines
  |
  +--- 12. Log action
  |     +-- action_type: 'appointment_cancelled'
  |     +-- Include reason and source
  |
  +-- RETURN cancellation confirmation
```

## Output

```typescript
{
  success: true,
  actionTaken: "Cancelled inspection at 123 Main St scheduled for Jan 20, 2026",
  result: {
    appointment: {
      id: "uuid",
      type: "inspection",
      confirmationNumber: "INS-2026-0120-001",
      scheduledFor: {
        date: "2026-01-20",
        time: "09:00"
      },
      status: "cancelled",
      cancelledAt: "2026-01-18T14:30:00Z",
      cancelledBy: "agent",
      reason: "Buyer decided not to proceed with inspection"
    },
    attendeesNotified: [
      { role: "inspector", name: "John Smith", method: ["email", "sms"] },
      { role: "buyer", name: "Jane Buyer", method: ["email"] },
      { role: "buyer_agent", name: "Agent Name", method: ["email"] }
    ],
    calendarUpdates: {
      googleEventsRemoved: 3,
      outlookEventsRemoved: 0
    },
    linkedAppointments: null,
    fees: {
      applicable: false,
      note: "Cancelled with more than 24 hours notice - no fee expected"
    },
    dealImpact: {
      inspectionPeriodEnds: "2026-01-30",
      status: "Buyer forgoing inspection",
      recommendation: "Confirm buyer waives inspection contingency or reschedule"
    },
    nextSteps: [
      "Inspector notified of cancellation",
      "Confirm with buyer if they're waiving inspection or want to reschedule",
      "Inspection period ends in 12 days"
    ]
  }
}
```

## Voice Response

**Standard cancellation:**
> "I've cancelled the inspection at 123 Main Street that was scheduled for Monday at 9 AM.
>
> I've notified John Smith Inspections, Jane, and updated everyone's calendars. The inspector confirmed receipt.
>
> The inspection period ends January 30th. Is Jane waiving the inspection, or would you like to reschedule with a different inspector?"

**Same-day cancellation:**
> "I've cancelled the walkthrough that was scheduled for 2 hours from now.
>
> Since this is short notice, I'm texting everyone in addition to email:
> - Jane Buyer - notified
> - Seller - notified they don't need to vacate
> - Listing agent - notified
>
> The closing is still on for 2 PM. Are we moving the walkthrough to after closing, or cancelling it entirely?"

**Closing cancellation (high-stakes):**
> "Just to confirm - you want to cancel the closing scheduled for Thursday at First Title?
>
> This is a significant action. Here's what will happen:
> - Title company and lender will be notified
> - All parties will receive cancellation notices
> - Any wire in progress would need to be recalled
>
> What's the reason for the cancellation? This will help me communicate appropriately with the other parties."

**With linked appointments:**
> "I've cancelled the closing at First Title scheduled for Thursday at 2 PM.
>
> I notice you also have a walkthrough scheduled for Thursday at 9 AM. Would you like me to cancel that as well?
>
> If the closing is being rescheduled, we should move both together."

**With fee implications:**
> "I can cancel the appraisal scheduled for tomorrow, but note that the appraiser typically charges a $150 cancellation fee for less than 24-hour notice.
>
> Would you like me to proceed with the cancellation?"

## Error Handling

| Error | Cause | Response |
|-------|-------|----------|
| `APPOINTMENT_NOT_FOUND` | Can't find appointment | "I couldn't find that appointment. Can you give me more details like the confirmation number or the type and address?" |
| `ALREADY_CANCELLED` | Already cancelled | "That appointment was already cancelled on [date]. Is there something else you need?" |
| `ALREADY_COMPLETED` | Already happened | "That appointment already took place on [date]. It can't be cancelled." |
| `CANCELLATION_BLOCKED` | Policy prevents | "This appointment can't be cancelled via Homer Pro - it requires direct contact with [party]. Would you like me to send them a message?" |
| `HIGH_STAKES_NO_CONFIRM` | Closing without confirmation | "Cancelling the closing is a significant action. Can you confirm this is what you want to do and tell me the reason?" |
| `LINKED_WARNING` | Related appointments exist | "This [type] has a linked [other type] scheduled. Would you like me to cancel both, or just this one?" |
| `FEE_WARNING` | Cancellation fee applies | "The [provider] may charge a cancellation fee since we're within [X] hours. Proceed anyway?" |

## Cascading Cancellations

When cancelling, these relationships should be considered:

```
Deal Cancelled:
  +-- Cancel all scheduled inspections
  +-- Cancel walkthrough
  +-- Cancel closing
  +-- Cancel all pending showings

Closing Cancelled:
  +-- Warn about walkthrough (suggest cancel or keep tentative)
  +-- Notify lender
  +-- Notify title company

Inspection Cancelled:
  +-- Note deadline implications
  +-- Suggest waiver or rescheduling
```

## Integration Points

### External Systems Updated
- ShowingTime / BrokerBay
- Inspector scheduling systems
- Title company systems
- Lender notifications
- Google Calendar
- Outlook Calendar

### Related Skills
- `reschedule` - If intent is to move, not cancel
- `send-email` - Cancellation notifications
- `send-sms` - Urgent notifications
- `send-calendar-invite` - Calendar cancellations

### Database Tables
- `appointments` - Update status to cancelled
- `scheduled_jobs` - Remove associated jobs
- `communications` - Record cancellation notices
- `action_log` - Audit entry

## Example Usage

### From Voice - Simple
```
Agent: "Cancel the inspection for 123 Main Street"

Homer: "Cancelling the inspection scheduled for Monday, January
        20th at 9 AM at 123 Main Street.

        Done. I've notified:
        - John Smith Inspections (confirmed)
        - Jane Buyer
        - Calendars updated

        Is Jane waiving the inspection, or would you like me
        to schedule a different inspector?"

Agent: "She's waiving."

Homer: "Got it. I'll note that the buyer is waiving the
        inspection. The inspection contingency period still
        ends January 30th - would you like me to draft a
        waiver of inspection contingency addendum?"
```

### From Voice - Closing
```
Agent: "We need to cancel the closing"

Homer: "I want to make sure I understand - you want to cancel
        the closing for 123 Main Street scheduled for Thursday
        at 2 PM at First Title?

        This will notify the title company, lender, and all
        parties. What's the reason for the cancellation?"

Agent: "The lender can't get clear to close in time. We need
        to push it back a week."

Homer: "Understood - the lender needs more time. Instead of
        cancelling, would you like me to reschedule to next
        Thursday, February 6th?

        That way we keep everything coordinated and just move
        the date rather than cancelling and rebooking.

        The contract closing date is February 10th, so
        February 6th would still work without an extension."

Agent: "Yes, reschedule to February 6th."

Homer: "Rescheduling to Thursday, February 6th at 2 PM.
        I'll notify everyone of the new date and include
        that we're waiting on lender clear to close.

        Want me to also move the walkthrough to February 6th
        morning?"
```

### From Voice - With Fee Warning
```
Agent: "Cancel tomorrow's appraisal"

Homer: "The appraisal is scheduled for tomorrow at 10 AM with
        ABC Appraisals.

        Since this is less than 24 hours notice, they typically
        charge a $150 cancellation fee. The fee would go to
        the buyer.

        Do you want me to proceed with the cancellation?"

Agent: "Yes, proceed."

Homer: "Cancelled. I've notified ABC Appraisals and they
        confirmed. They'll invoice the $150 fee separately.

        I've also notified the lender that the appraisal
        was cancelled. Would you like to reschedule with
        the same appraiser or find another?"
```

## Quality Checklist

- [x] Handles voice input naturally with multiple phrasings
- [x] Identifies appointments by ID, confirmation, or context
- [x] Confirms high-stakes cancellations (closing)
- [x] Warns about fee implications
- [x] Handles linked appointments appropriately
- [x] Updates external systems (ShowingTime, etc.)
- [x] Removes calendar events properly
- [x] Sends appropriate notifications to all parties
- [x] Uses SMS for urgent/same-day cancellations
- [x] Removes scheduled reminders
- [x] Offers rescheduling as alternative when appropriate
- [x] Tracks cancellation in audit log
- [x] Handles deal-level implications
- [x] Returns clear confirmation
- [x] Provides actionable next steps
- [x] Handles errors gracefully

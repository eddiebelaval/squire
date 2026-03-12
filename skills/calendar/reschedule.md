# Skill: Reschedule Appointment

**Category:** Calendar
**Priority:** P0
**Approval Required:** No

## Purpose

Change the date, time, or other details of an existing appointment. Handles all appointment types (inspections, walkthroughs, closings, showings) with appropriate notifications to all affected parties. Manages the complexity of finding new times that work for everyone while maintaining proper notice requirements.

## Triggers

### Voice Commands
- "Reschedule [appointment type] for [address]"
- "Move the inspection to [new date/time]"
- "Change the closing to [new date/time]"
- "Push back the walkthrough by [duration]"
- "Can we move the [appointment] to [day]?"
- "The [party] can't make it, reschedule for [time]"
- "Reschedule [confirmation number]"
- "Move my 2 o'clock to 3"
- "Change the showing from [time] to [time]"

### Programmatic
- `PUT /appointments/:id/reschedule`
- `PATCH /appointments/:id`
- Calendar integration webhook (external change)
- Party cancellation notification

### Automatic
- Party declines calendar invite
- Conflict detected in calendar sync
- Weather/emergency alerts

## Required Inputs

| Input | Type | Required | Source | Description |
|-------|------|----------|--------|-------------|
| `appointmentId` | UUID | Yes* | context | Appointment to reschedule |
| `confirmationNumber` | string | Yes* | voice | Appointment confirmation number |
| `appointmentType` | string | Yes* | voice | Type + address to identify |

*One identifier required to locate the appointment.

| Input | Type | Required | Source | Description |
|-------|------|----------|--------|-------------|
| `newDate` | Date | Yes* | voice/manual | New date for appointment |
| `newTime` | Time | Yes* | voice/manual | New time for appointment |

*At least one of newDate or newTime required.

## Optional Inputs

| Input | Type | Default | Source | Description |
|-------|------|---------|--------|-------------|
| `reason` | string | null | voice | Reason for reschedule |
| `notifyParties` | boolean | true | default | Send notifications |
| `checkAvailability` | boolean | true | default | Verify new time works |
| `updateCalendars` | boolean | true | default | Update synced calendars |
| `suggestAlternatives` | boolean | true | default | Offer options if conflict |
| `keepDuration` | boolean | true | default | Maintain original duration |
| `newDuration` | number | null | voice | New duration if changing |
| `newLocation` | string | null | voice | New location if changing |
| `maintainSequence` | boolean | true | default | Keep linked appointments in order |
| `notes` | string | null | voice | Updated notes |

## Appointment Type Considerations

| Type | Special Handling |
|------|------------------|
| Inspection | Must stay within inspection period, may need inspector approval |
| Walkthrough | Should remain before closing, linked to closing appointment |
| Closing | May require title company confirmation, 3-day CD rule for financed |
| Showing | Needs listing approval if seller-occupied, ShowingTime update |
| Appraisal | Lender may need notification |

## Execution Flow

```
START
  |
  +--- 1. Identify appointment
  |    +-- If appointmentId: load directly
  |    +-- If confirmationNumber: look up
  |    +-- If type + context: find matching appointment
  |    +-- Validate appointment exists and is active
  |
  +--- 2. Load appointment context
  |    +-- Original date, time, duration, location
  |    +-- All attendees and their contact info
  |    +-- Linked appointments (e.g., walkthrough -> closing)
  |    +-- Calendar invites sent
  |    +-- Deal context
  |
  +--- 3. Validate new time
  |    +-- Is new date/time in the future?
  |    +-- Does it respect required notice periods?
  |    +-- Does it fit within any deadlines?
  |    |   +-- Inspection: within inspection period
  |    |   +-- Walkthrough: before closing
  |    |   +-- Closing: respect CD 3-day rule
  |    |
  |    +-- If validation fails: explain and offer alternatives
  |
  +--- 4. Check availability (if enabled)
  |    +-- INVOKE: check-availability
  |    +-- Verify all parties available at new time
  |    +-- If conflict detected:
  |    |   +-- Identify who has conflict
  |    |   +-- Find alternative times that work
  |    |   +-- Present options
  |    |
  |    +-- If all clear: proceed
  |
  +--- 5. Check linked appointments
  |    +-- If walkthrough: ensure still before closing
  |    +-- If closing: adjust walkthrough recommendation
  |    +-- If part of showing tour: recalculate route
  |    +-- Warn about sequencing issues
  |
  +--- 6. Update appointment record
  |    +-- Store previous date/time
  |    +-- Set new date/time
  |    +-- Update duration if changed
  |    +-- Update location if changed
  |    +-- Add reschedule reason to notes
  |    +-- Increment reschedule_count
  |    +-- Update updated_at
  |
  +--- 7. Update external systems
  |    +-- If inspection: notify inspector
  |    +-- If showing: update ShowingTime
  |    +-- If closing: update title company
  |    +-- Update MLS showing system if applicable
  |
  +--- 8. Update calendars
  |    +-- Update all synced calendar events
  |    +-- Google Calendar API
  |    +-- Outlook Graph API
  |    +-- Remove old event, create new (some systems)
  |
  +--- 9. Send notifications (if enabled)
  |    +-- INVOKE: send-calendar-invite (updated event)
  |    +-- INVOKE: send-email (change notification)
  |    +-- INVOKE: send-sms (urgent if same-day change)
  |    |
  |    +-- Include:
  |        +-- Old date/time
  |        +-- New date/time
  |        +-- Reason (if provided)
  |        +-- Updated access instructions
  |
  +--- 10. Reschedule reminders
  |     +-- Cancel old reminder jobs
  |     +-- Schedule new reminder jobs
  |     +-- Adjust timing based on new appointment
  |
  +--- 11. Handle linked appointments
  |     +-- If maintainSequence enabled:
  |         +-- Suggest moving linked appointments
  |         +-- E.g., if closing moved, suggest new walkthrough time
  |
  +--- 12. Log action
  |     +-- action_type: 'appointment_rescheduled'
  |     +-- Include previous_state and new_state
  |
  +-- RETURN reschedule confirmation
```

## Output

```typescript
{
  success: true,
  actionTaken: "Rescheduled inspection from Jan 20 9:00 AM to Jan 22 10:00 AM",
  result: {
    appointment: {
      id: "uuid",
      type: "inspection",
      confirmationNumber: "INS-2026-0120-001",
      previous: {
        date: "2026-01-20",
        time: "09:00",
        duration: 180
      },
      updated: {
        date: "2026-01-22",
        time: "10:00",
        duration: 180,
        endTime: "13:00"
      },
      location: {
        address: "123 Main St, Miami FL 33101"
      },
      status: "rescheduled",
      rescheduleCount: 1,
      reason: "Inspector had emergency, needed to move"
    },
    attendees: [
      { role: "inspector", name: "John Smith", notified: true },
      { role: "buyer", name: "Jane Buyer", notified: true },
      { role: "buyer_agent", name: "Agent Name", notified: true }
    ],
    notifications: {
      calendarUpdates: 3,
      emailsSent: 3,
      smsSent: 2
    },
    linkedAppointments: null,
    deadlineImpact: {
      inspectionPeriodEnds: "2026-01-30",
      daysRemainingAfterInspection: 8,
      status: "OK"
    },
    nextSteps: [
      "All parties notified of the change",
      "New calendar invites sent",
      "Inspector confirmed the new time"
    ]
  }
}
```

## Voice Response

**Simple reschedule:**
> "Done. I've moved the inspection from Monday at 9 AM to Wednesday at 10 AM.
>
> I've updated everyone's calendar and sent notifications to the inspector, Jane, and yourself.
>
> The inspection period ends January 30th, so you'll still have 8 days after the inspection for review.
>
> Anything else?"

**When availability check finds conflict:**
> "The inspector isn't available on Wednesday at 10 AM - they have another inspection then.
>
> Here are times that work for everyone:
> - Wednesday at 2 PM
> - Thursday at 9 AM
> - Thursday at 1 PM
>
> Which would you prefer?"

**When linked appointment affected:**
> "I've moved the closing from Thursday 2 PM to Friday 11 AM.
>
> I noticed your walkthrough was scheduled for Thursday at 9 AM. Since closing is now Friday, would you like me to move the walkthrough to Friday morning as well?
>
> I'd suggest 8 AM on Friday - that gives you 3 hours before closing to address any issues."

**Same-day change:**
> "I've moved the walkthrough from 9 AM to 11 AM today.
>
> Since this is a same-day change, I've texted everyone in addition to updating calendars:
> - Jane Buyer (buyer) - confirmed she can do 11
> - John Seller (seller) - notified of new time
> - You've got the update
>
> The closing is still at 2 PM, so you have 3 hours buffer.
>
> All set?"

**When deadline constraint:**
> "I can't move the inspection to February 1st because the inspection period ends January 30th.
>
> If you need a February date, you'll need an inspection extension first. Want me to:
> 1. Schedule for January 29th instead (latest possible date)?
> 2. Draft an inspection extension request for 5 more days?
>
> What would you like to do?"

## Error Handling

| Error | Cause | Response |
|-------|-------|----------|
| `APPOINTMENT_NOT_FOUND` | Can't find appointment | "I couldn't find that appointment. Can you give me the confirmation number or tell me more details - like the type and address?" |
| `APPOINTMENT_CANCELLED` | Already cancelled | "That appointment was already cancelled on [date]. Would you like to create a new one instead?" |
| `APPOINTMENT_COMPLETED` | Already happened | "That appointment already occurred on [date]. It can't be rescheduled. Do you need to schedule a new one?" |
| `PAST_DATE` | New date is in past | "That date has already passed. When would you like to reschedule to?" |
| `OUTSIDE_DEADLINE` | Violates deadline | "Moving to [date] would be after the [deadline]. Would you like to request an extension first, or pick an earlier date?" |
| `PARTY_UNAVAILABLE` | Key party can't make new time | "[Party] isn't available at [new time]. They're free at [alternatives]. Which works?" |
| `TITLE_COMPANY_CLOSED` | Title company not open | "First Title isn't open on Sundays. Their next available closing time is Monday at 9 AM. Want me to schedule that?" |
| `THREE_DAY_RULE` | CD needs 3 days | "If we move closing to [date], we need the closing disclosure delivered by [CD deadline]. Has it been sent yet?" |
| `INSPECTOR_DECLINED` | Inspector can't do new time | "The inspector declined the new time. Here are their available slots: [list]" |
| `TOO_MANY_RESCHEDULES` | Excessive rescheduling | "This is the 4th time rescheduling this inspection. The listing agent has asked to be notified of future changes. Should I proceed?" |

## Integration Points

### External Systems Updated
- Google Calendar API
- Outlook/Microsoft Graph
- ShowingTime
- Inspector scheduling systems
- Title company systems

### Related Skills
- `check-availability` - Find new available times
- `send-calendar-invite` - Send updated invites
- `cancel-appointment` - If reschedule becomes cancellation
- `extend-deadline` - If reschedule requires extension

### Database Tables
- `appointments` - Update appointment record
- `scheduled_jobs` - Reschedule reminders
- `communications` - Notification records
- `action_log` - Audit entry with state change

## Example Usage

### From Voice - Simple
```
Agent: "Move the inspection to Thursday at 10"

Homer: "Moving the inspection at 123 Main Street from
        Monday 9 AM to Thursday 10 AM.

        Let me check everyone's availability... All clear.

        Done! I've notified John Smith Inspections, Jane Buyer,
        and updated everyone's calendars.

        The inspector confirmed the new time via text."
```

### From Voice - With Conflict
```
Agent: "Reschedule the closing to Friday afternoon"

Homer: "Checking availability for Friday afternoon...

        The title company can do 2 PM or 4 PM. However,
        the seller has a flight at 5 PM, so 4 PM would be tight.

        I'd recommend 2 PM to give everyone buffer time.

        Also, your walkthrough is currently Thursday morning.
        Would you like me to move it to Friday morning since
        closing is now Friday?"

Agent: "Yes, do 2 PM and move walkthrough to Friday at 10"

Homer: "Done. Here's the updated schedule for Friday:
        - 10:00 AM: Walkthrough at the property
        - 2:00 PM: Closing at First Title

        I've notified all parties and updated calendars.
        The seller's flight should be fine with the 2 PM closing.

        Anything else?"
```

### From Voice - Emergency Same-Day
```
Agent: "The inspector just called - he has an emergency.
        We need to reschedule today's inspection"

Homer: "I'm sorry to hear that. The inspection was scheduled
        for 9 AM today - that's in 2 hours.

        Let me check John Smith's next availability and
        find a time that works for Jane too...

        The earliest he can do is:
        - Tomorrow (Tuesday) at 9 AM
        - Tomorrow at 2 PM
        - Thursday at 10 AM

        The inspection period ends January 30th, so any of
        these work timing-wise.

        I'll text Jane now to see what works for her.
        Which time should I propose?"

Agent: "Tomorrow at 9"

Homer: "I'm texting Jane now about tomorrow at 9 AM.
        I'll let you know as soon as she confirms.

        In the meantime, I've marked today's appointment as
        rescheduled and will update the calendars once
        we have Jane's confirmation."
```

## Quality Checklist

- [x] Handles voice input naturally with multiple phrasings
- [x] Identifies appointments by ID, confirmation, or context
- [x] Validates new time respects deadlines
- [x] Checks availability before confirming
- [x] Handles linked appointments (walkthrough + closing)
- [x] Updates external calendar systems
- [x] Sends appropriate notifications to all parties
- [x] Uses SMS for same-day changes
- [x] Reschedules associated reminders
- [x] Tracks reschedule history
- [x] Logs state changes for audit
- [x] Handles conflicts gracefully with alternatives
- [x] Returns clear confirmation
- [x] Provides actionable next steps
- [x] Handles errors gracefully
- [x] Florida-specific deadline awareness

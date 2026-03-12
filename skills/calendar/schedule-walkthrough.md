# Skill: Schedule Walkthrough

**Category:** Calendar
**Priority:** P0
**Approval Required:** No

## Purpose

Schedule the final walkthrough (final walk) before closing. This is the buyer's last opportunity to verify the property condition before taking ownership. Coordinates timing with the closing appointment, ensures all parties are available, and confirms property access.

## Triggers

### Voice Commands
- "Schedule final walkthrough for [address]"
- "Book the final walk for [deal]"
- "Set up walkthrough before closing at [address]"
- "Schedule walk-through for [date/time]"
- "Final walk for [address] on closing day"
- "I need a walkthrough for [address] before we close"
- "Book buyer walkthrough for [address]"

### Programmatic
- `POST /deals/:id/appointments/walkthrough`
- Closing date set or updated (auto-suggest scheduling)
- Closing appointment scheduled (suggest walkthrough 2-24 hours before)

### Automatic
- 3 days before closing: prompt if walkthrough not scheduled
- Closing scheduled: auto-suggest walkthrough time

## Required Inputs

| Input | Type | Required | Source | Description |
|-------|------|----------|--------|-------------|
| `dealId` | UUID | Yes | context | Deal to schedule walkthrough for |
| `walkthroughDate` | Date | Yes | voice/manual | Date of walkthrough |
| `walkthroughTime` | Time | Yes | voice/manual | Time of walkthrough |

## Optional Inputs

| Input | Type | Default | Source | Description |
|-------|------|---------|--------|-------------|
| `duration` | number | 30 | deal | Expected duration in minutes |
| `attendees` | PartyRole[] | ['buyer', 'buyer_agent'] | voice | Who should attend |
| `sellerPresent` | boolean | false | voice | Whether seller will be present |
| `includeListingAgent` | boolean | false | voice | Whether listing agent attends |
| `accessInstructions` | string | null | deal | How to access property |
| `checklistItems` | string[] | null | template | Items to verify during walk |
| `followsClosing` | boolean | false | context | If walkthrough is after closing same day |
| `closingAppointmentId` | UUID | null | context | Linked closing appointment |
| `notes` | string | null | voice | Special instructions |
| `repairsToVerify` | string[] | null | deal | Specific repairs to check |

## Walkthrough Timing Best Practices

| Scenario | Recommended Timing | Rationale |
|----------|-------------------|-----------|
| Standard closing | 2-4 hours before | Time to address issues before closing |
| Seller still moving | Day before closing | Verify removal complete |
| Morning closing | Day before, evening | Can't do same day before |
| Remote buyer | 24-48 hours before | Agent represents, buyer reviews video |
| Repairs completed | Day before + closing day | Verify repairs, then final check |
| New construction | Multiple walks required | Each stage verification |

## Execution Flow

```
START
  |
  +--- 1. Validate inputs
  |    +-- Deal exists and is active/pending_closing
  |    +-- Closing date is set
  |    +-- Walkthrough date is before or on closing date
  |    +-- Time is reasonable
  |
  +--- 2. Load deal context
  |    +-- Property address
  |    +-- Closing date and time
  |    +-- All parties (buyer, agents)
  |    +-- Repair agreements (what to verify)
  |    +-- Property condition notes
  |    +-- Access information
  |
  +--- 3. Validate timing vs closing
  |    +-- If closing scheduled:
  |    |   +-- Verify walkthrough is before closing
  |    |   +-- Recommend 2-4 hour buffer
  |    |   +-- Warn if too close (< 1 hour before)
  |    |
  |    +-- If closing not scheduled:
  |        +-- Note walkthrough is tentative
  |        +-- Will reconfirm when closing scheduled
  |
  +--- 4. Check attendee availability
  |    +-- Buyer (primary attendee)
  |    +-- Buyer's agent
  |    +-- If requested: listing agent
  |    +-- If synced calendars: check conflicts
  |
  +--- 5. Verify property access
  |    +-- Confirm seller has vacated (if applicable)
  |    +-- Get current lockbox/access code
  |    +-- Confirm utilities still on
  |    +-- Note any move-out status
  |
  +--- 6. Prepare walkthrough checklist
  |    +-- Standard walkthrough items
  |    +-- Property-specific items (pool, sprinklers, etc.)
  |    +-- Agreed-upon repairs to verify
  |    +-- Items from inspection report
  |    +-- Personal property inclusions/exclusions
  |
  +--- 7. Create appointment record
  |    +-- appointment_type: 'walkthrough'
  |    +-- date, time, duration
  |    +-- location: property address
  |    +-- attendees: [buyer, buyer_agent, ...]
  |    +-- linked_appointment: closing (if exists)
  |    +-- status: 'scheduled'
  |    +-- checklist: prepared items
  |
  +--- 8. Send notifications
  |    +-- INVOKE: send-calendar-invite (to buyer)
  |    +-- INVOKE: send-calendar-invite (to buyer_agent)
  |    +-- INVOKE: send-email (to buyer - checklist)
  |    |
  |    +-- If seller-occupied:
  |    |   +-- INVOKE: send-sms (to seller - vacate reminder)
  |    |   +-- INVOKE: send-email (to listing_agent)
  |    |
  |    +-- If repairs to verify:
  |        +-- INVOKE: send-email (to listing_agent - repair verification)
  |
  +--- 9. Schedule reminders
  |    +-- 24 hours before: reminder to all attendees
  |    +-- Day before to seller: "Buyer walkthrough tomorrow"
  |    +-- 1 hour before: access info reminder
  |
  +--- 10. Update deal
  |     +-- Mark walkthrough_scheduled
  |     +-- Link to closing if applicable
  |     +-- Update timeline
  |
  +--- 11. Log action
  |     +-- action_type: 'walkthrough_scheduled'
  |
  +-- RETURN appointment confirmation
```

## Standard Walkthrough Checklist

```typescript
const standardChecklist = [
  // Exterior
  { category: "exterior", item: "Landscaping condition", description: "Compare to contract condition" },
  { category: "exterior", item: "Exterior damage", description: "Check for new damage since inspection" },
  { category: "exterior", item: "Pool/spa condition", description: "Equipment running, water clear" },

  // Systems
  { category: "systems", item: "HVAC functioning", description: "Turn on heat and AC" },
  { category: "systems", item: "Water heater", description: "Hot water working" },
  { category: "systems", item: "Electrical", description: "Lights and outlets work" },
  { category: "systems", item: "Plumbing", description: "Faucets, toilets, drains" },

  // Appliances
  { category: "appliances", item: "Kitchen appliances", description: "All included appliances present and working" },
  { category: "appliances", item: "Washer/dryer", description: "If included in sale" },
  { category: "appliances", item: "Garage door opener", description: "Remotes provided" },

  // Property Condition
  { category: "condition", item: "Walls and ceilings", description: "No new damage, holes filled" },
  { category: "condition", item: "Flooring", description: "No damage from move-out" },
  { category: "condition", item: "Windows and doors", description: "All locks working" },

  // Seller Obligations
  { category: "seller", item: "Personal property removed", description: "All seller belongings gone" },
  { category: "seller", item: "Debris/trash removed", description: "Property is broom clean" },
  { category: "seller", item: "Keys and remotes", description: "All keys, remotes, codes provided" },
  { category: "seller", item: "Included items present", description: "Per contract inclusions" },

  // Repairs (if applicable)
  { category: "repairs", item: "Agreed repairs completed", description: "Per repair addendum" },
  { category: "repairs", item: "Repair receipts/permits", description: "Documentation available" }
];
```

## Output

```typescript
{
  success: true,
  actionTaken: "Scheduled final walkthrough for 123 Main St on Jan 30, 2026 at 9:00 AM",
  result: {
    appointment: {
      id: "uuid",
      type: "walkthrough",
      date: "2026-01-30",
      time: "09:00",
      duration: 30,
      endTime: "09:30",
      location: {
        address: "123 Main St, Miami FL 33101",
        accessInstructions: "Lockbox on front door",
        lockboxCode: "1234"
      },
      attendees: [
        { role: "buyer", name: "Jane Buyer", confirmed: false },
        { role: "buyer_agent", name: "Agent Name", confirmed: true }
      ],
      status: "scheduled",
      confirmationNumber: "WLK-2026-0130-001"
    },
    closingContext: {
      closingDate: "2026-01-30",
      closingTime: "14:00",
      hoursBeforeClosing: 5,
      closingLocation: "First Title Company, 100 Law St, Miami FL"
    },
    checklist: {
      totalItems: 18,
      repairItems: 2,
      customItems: 0
    },
    notifications: {
      calendarInvitesSent: 2,
      emailsSent: 2,
      smsSent: 1
    },
    nextSteps: [
      "Buyer to confirm attendance",
      "Verify seller has vacated before walkthrough",
      "Bring checklist and previous inspection report",
      "Closing at 2:00 PM - allow time to address any issues"
    ]
  }
}
```

## Voice Response

**Standard scheduling:**
> "I've scheduled the final walkthrough for 123 Main Street on Thursday, January 30th at 9 AM.
>
> Your closing is at 2 PM the same day, so you'll have 5 hours to address anything that comes up.
>
> I've sent Jane the calendar invite with the walkthrough checklist. There are 2 repairs from the repair addendum to verify - the HVAC fix and the roof patch.
>
> I'll remind everyone tomorrow and send the seller a note that the property needs to be completely vacated by tonight.
>
> Is there anything specific you want me to add to the checklist?"

**When timing is tight:**
> "I can schedule the walkthrough for 1 PM, but closing is at 2 PM. That only gives you an hour if there are issues.
>
> Would you prefer to do the walkthrough the evening before? That way if repairs are incomplete or there's debris left, the seller has overnight to address it.
>
> I'd suggest January 29th at 6 PM - want me to schedule that instead?"

**When repairs to verify:**
> "I've scheduled the final walkthrough for 9 AM on January 30th.
>
> Based on the repair addendum, I'm adding these items to the verification checklist:
> - HVAC repair by Cool Air Inc - receipt should be available
> - Roof patch by ABC Roofing - they pulled a permit, verify completion
> - Replacement of broken window in master bedroom
>
> I've notified the listing agent that we'll be verifying these repairs. Do you have the receipts, or should I request them?"

## Error Handling

| Error | Cause | Response |
|-------|-------|----------|
| `NO_CLOSING_DATE` | Closing date not set | "The closing date hasn't been set yet. Once we have a closing date, I'll help schedule the walkthrough for 2-4 hours before." |
| `WALKTHROUGH_AFTER_CLOSING` | Date is after closing | "The walkthrough needs to be before or on the closing date. Closing is [date]. Would you like to schedule for [day before] or the morning of closing?" |
| `INSUFFICIENT_BUFFER` | Too close to closing | "That's only [X] minutes before closing. I'd recommend at least 2 hours buffer to address any issues. How about [earlier time]?" |
| `BUYER_UNAVAILABLE` | Buyer can't make walkthrough | "Jane isn't available at that time. Would you like to do the walkthrough on her behalf, or find an alternate time? She could also join by video call." |
| `PROPERTY_NOT_VACANT` | Seller hasn't moved out | "The seller is still in the property. For an effective walkthrough, the property should be vacated. Want me to confirm the move-out schedule with the listing agent?" |
| `DUPLICATE_WALKTHROUGH` | Walkthrough already scheduled | "There's already a walkthrough scheduled for [date/time]. Would you like to reschedule it?" |

## Florida-Specific Considerations

### Walkthrough Rights
- FAR/BAR contract provides buyer right to final walkthrough
- Typically within 24 hours before closing
- Seller must allow reasonable access
- Property should be in contracted condition

### Common Florida Issues to Check
- Hurricane shutters (all panels present)
- Pool equipment (Florida requirement for safety barriers)
- AC function (critical in Florida climate)
- Sprinkler system (lawn maintenance)
- Termite damage (WDO issues)

### Seller Obligations at Walkthrough
- Property broom clean
- All debris removed
- Personal property removed (unless included)
- All systems functional
- Agreed repairs completed

## Integration Points

### Triggers After Scheduling
- Update deal timeline
- Link to closing appointment
- Create walkthrough checklist document

### Related Skills
- `schedule-closing` - Often scheduled together
- `reschedule` - If timing changes
- `send-calendar-invite` - For notifications
- `coordinate-multiple-parties` - Complex scheduling

### Database Tables
- `appointments` - Main appointment record
- `scheduled_jobs` - Reminder jobs
- `communications` - Notifications sent
- `documents` - Walkthrough checklist
- `action_log` - Audit entry

## Example Usage

### From Voice - Simple
```
Agent: "Schedule final walkthrough for 123 Main Street
        the morning of closing"

Homer: "Closing is January 30th at 2 PM at First Title Company.

        I'll schedule the walkthrough for 9 AM that morning,
        giving you 5 hours before closing.

        I've sent Jane and you the calendar invite with the
        walkthrough checklist. There are 18 items to verify
        including the 2 repairs from the repair addendum.

        I'll remind the seller to have the property vacated
        and ready by 9 AM. Sound good?"

Agent: "Perfect."

Homer: "All set. I'll remind everyone on Wednesday."
```

### From Voice - Remote Buyer
```
Agent: "My buyer is in New York and can't make it for the
        walkthrough. What should we do?"

Homer: "No problem. Here are your options:

        1. You do the walkthrough on Jane's behalf and video
           call her during so she can see everything

        2. I can schedule it a day early and send her a
           detailed video walkthrough with checklist

        3. She authorizes you in writing to represent her

        Most common is option 1 - the video call. That way
        she can point out anything she wants you to check
        more closely.

        Which approach would you like?"

Agent: "Let's do the video call option."

Homer: "I'll schedule the walkthrough for January 30th at 9 AM.
        I'll send Jane instructions to be available for a
        video call at that time. I'll also prepare the
        checklist so you can go through it systematically
        on camera. Want me to include a written authorization
        just to document her consent?"
```

## Quality Checklist

- [x] Handles voice input naturally with multiple phrasings
- [x] Validates timing relative to closing
- [x] Recommends appropriate buffer time
- [x] Generates comprehensive walkthrough checklist
- [x] Includes repair verification items
- [x] Sends appropriate notifications to all parties
- [x] Handles seller-occupied properties
- [x] Supports remote buyer scenarios
- [x] Links to closing appointment
- [x] Schedules automatic reminders
- [x] Creates audit log entry
- [x] Returns actionable next steps
- [x] Provides clear voice response
- [x] Handles errors gracefully
- [x] Florida-specific considerations included

# Skill: Schedule Inspection

**Category:** Calendar
**Priority:** P0
**Approval Required:** No

## Purpose

Schedule a home inspection appointment for a real estate transaction. Coordinates between the inspector, buyer, buyer's agent, and sometimes seller/listing agent. Handles the complexity of finding a mutually available time, ensuring the property is accessible, and sending confirmation to all parties.

## Triggers

### Voice Commands
- "Schedule inspection for [address]"
- "Book a home inspection for [deal]"
- "Get the inspector out to [address]"
- "Set up inspection with [inspector name] for [address]"
- "Schedule [inspection type] inspection for [address]"
- "I need an inspection at [address] this week"
- "Book [inspector] for [date] at [address]"

### Programmatic
- `POST /deals/:id/appointments/inspection`
- API call from external scheduling system
- Deadline alert trigger (inspection period ending soon)

### Automatic
- Deal created with inspection period defined
- Inspection deadline approaching (5 days out, no inspection scheduled)

## Required Inputs

| Input | Type | Required | Source | Description |
|-------|------|----------|--------|-------------|
| `dealId` | UUID | Yes | context | Deal to schedule inspection for |
| `inspectorId` | UUID | No* | voice/manual | Inspector to use (required if not selecting from list) |
| `inspectionDate` | Date | Yes | voice/manual | Preferred inspection date |
| `inspectionTime` | Time | Yes | voice/manual | Preferred inspection time |

*If `inspectorId` not provided, will prompt with available inspectors or use deal's assigned inspector.

## Optional Inputs

| Input | Type | Default | Source | Description |
|-------|------|---------|--------|-------------|
| `inspectionType` | string | 'general' | voice | Type: general, 4-point, wind mitigation, WDO, pool, roof |
| `duration` | number | 180 | calculated | Expected duration in minutes |
| `alternateDate1` | Date | null | voice | First backup date option |
| `alternateTime1` | Time | null | voice | First backup time option |
| `alternateDate2` | Date | null | voice | Second backup date option |
| `alternateTime2` | Time | null | voice | Second backup time option |
| `attendees` | PartyRole[] | ['buyer', 'buyer_agent'] | voice | Who should attend |
| `accessInstructions` | string | null | deal/voice | How to access the property |
| `lockboxCode` | string | null | deal | Lockbox code if applicable |
| `gateCode` | string | null | deal | Gate/community code if applicable |
| `sellerVacateRequired` | boolean | true | deal | Whether seller must leave during inspection |
| `utilityCheck` | boolean | true | default | Remind to ensure utilities are on |
| `notes` | string | null | voice | Special instructions for inspector |

## Inspection Types

| Type | Typical Duration | Description |
|------|-----------------|-------------|
| `general` | 3-4 hours | Full home inspection |
| `4_point` | 1 hour | HVAC, electrical, plumbing, roof (insurance) |
| `wind_mitigation` | 1 hour | Hurricane resistance features (insurance discount) |
| `wdo` | 30 min | Wood destroying organisms (termite) |
| `pool_spa` | 1 hour | Pool and spa equipment inspection |
| `roof` | 1-2 hours | Detailed roof inspection |
| `septic` | 2 hours | Septic system inspection |
| `well` | 2 hours | Well water testing |
| `mold` | 2 hours | Mold testing and inspection |
| `radon` | 48 hours | Radon testing (detector left on-site) |

## Execution Flow

```
START
  |
  +--- 1. Validate inputs
  |    +-- Deal exists and is active
  |    +-- Date is within inspection period
  |    +-- Inspector exists (if provided)
  |    +-- Time is reasonable (business hours)
  |
  +--- 2. Load deal context
  |    +-- Property address
  |    +-- All parties (buyer, agents, seller)
  |    +-- Inspection period end date
  |    +-- Access information from deal
  |    +-- Previous inspection attempts (if any)
  |
  +--- 3. Resolve inspector
  |    +-- If inspectorId provided: use it
  |    +-- If deal has assigned inspector: suggest using them
  |    +-- Else: show available inspectors in area
  |        +-- Filter by inspection type capability
  |        +-- Filter by availability on requested date
  |        +-- Sort by agent preference/past usage
  |
  +--- 4. Check inspector availability
  |    +-- Query inspector's calendar
  |    +-- If available: proceed
  |    +-- If not available:
  |        +-- Try alternate dates if provided
  |        +-- Suggest next available times
  |        +-- Return with options to user
  |
  +--- 5. Verify property access
  |    +-- If seller occupied: request seller availability
  |    +-- If vacant: confirm lockbox/access available
  |    +-- If tenant: coordinate with tenant
  |    +-- Note any access restrictions
  |
  +--- 6. Check buyer availability (optional)
  |    +-- If buyer wants to attend
  |    +-- Check buyer's calendar if synced
  |
  +--- 7. Create appointment record
  |    +-- appointment_type: 'inspection'
  |    +-- inspection_type: [type]
  |    +-- date, time, duration
  |    +-- location: property address
  |    +-- attendees: [inspector, buyer, buyer_agent]
  |    +-- status: 'scheduled'
  |    +-- access_instructions
  |
  +--- 8. Send notifications
  |    +-- INVOKE: send-calendar-invite (to inspector)
  |    +-- INVOKE: send-calendar-invite (to buyer)
  |    +-- INVOKE: send-calendar-invite (to buyer_agent)
  |    +-- INVOKE: send-sms (to inspector - confirmation)
  |    +-- INVOKE: send-email (to inspector - details + access)
  |    |
  |    +-- If seller occupied:
  |        +-- INVOKE: send-sms (to seller - vacate reminder)
  |        +-- INVOKE: send-email (to listing_agent - notification)
  |
  +--- 9. Schedule reminders
  |    +-- 24 hours before: reminder to all attendees
  |    +-- 2 hours before: reminder to inspector with access info
  |    +-- Day before: utility check reminder to seller/listing agent
  |
  +--- 10. Update deal
  |     +-- Add inspection appointment to deal
  |     +-- Link inspector as party (if not already)
  |     +-- Update inspection_scheduled flag
  |
  +--- 11. Log action
  |     +-- action_type: 'inspection_scheduled'
  |     +-- Include all details
  |
  +-- RETURN appointment confirmation
```

## Output

```typescript
{
  success: true,
  actionTaken: "Scheduled general inspection for 123 Main St on Jan 20, 2026 at 9:00 AM",
  result: {
    appointment: {
      id: "uuid",
      type: "inspection",
      inspectionType: "general",
      date: "2026-01-20",
      time: "09:00",
      duration: 180,
      endTime: "12:00",
      location: {
        address: "123 Main St, Miami FL 33101",
        accessInstructions: "Lockbox on front door",
        lockboxCode: "1234"
      },
      attendees: [
        { role: "inspector", name: "John Smith Inspections", confirmed: true },
        { role: "buyer", name: "Jane Buyer", confirmed: false },
        { role: "buyer_agent", name: "Agent Name", confirmed: true }
      ],
      status: "scheduled",
      confirmationNumber: "INS-2026-0120-001"
    },
    notifications: {
      calendarInvitesSent: 3,
      emailsSent: 2,
      smsSent: 2
    },
    reminders: [
      { type: "24_hour", scheduledFor: "2026-01-19T09:00:00" },
      { type: "2_hour", scheduledFor: "2026-01-20T07:00:00" }
    ],
    inspectionPeriodContext: {
      endsOn: "2026-01-30",
      daysRemaining: 10,
      daysAfterInspection: 10
    },
    nextSteps: [
      "Confirm buyer can attend",
      "Ensure utilities are on before inspection",
      "Review inspection report when available"
    ]
  }
}
```

## Voice Response

**Standard scheduling:**
> "I've scheduled a general home inspection for 123 Main Street on Monday, January 20th at 9 AM with John Smith Inspections.
>
> The inspection should take about 3 hours, wrapping up around noon.
>
> I've sent calendar invites to the inspector, your buyer Jane, and yourself. I also texted the inspector the lockbox code and access instructions.
>
> The inspection period ends January 30th, so you'll have 10 days after the inspection to complete your review. I'll remind everyone the day before.
>
> Would you like me to also schedule the 4-point and wind mitigation while the inspector is there?"

**When inspector unavailable:**
> "John Smith Inspections isn't available on January 20th. They have openings on:
> - January 21st at 9 AM
> - January 21st at 1 PM
> - January 22nd at 10 AM
>
> Or I can check with ABC Inspections who are also available in Miami-Dade.
>
> Which would you prefer?"

**When approaching deadline:**
> "I've scheduled the inspection, but I should mention the inspection period ends in 5 days on January 25th. That's tight for getting the report, reviewing it, and submitting any repair requests.
>
> Would you like me to draft an inspection extension request just in case?"

## Error Handling

| Error | Cause | Response |
|-------|-------|----------|
| `NO_INSPECTOR` | No inspector assigned or selected | "Which inspector would you like to use? I have John Smith Inspections and ABC Home Inspectors available in this area." |
| `OUTSIDE_INSPECTION_PERIOD` | Date after inspection period ends | "That date is after the inspection period ends on [date]. Would you like me to schedule it anyway, or should we request an inspection extension first?" |
| `INSPECTOR_UNAVAILABLE` | Inspector not available at requested time | "John Smith Inspections isn't available then. [Offer alternatives]" |
| `PROPERTY_ACCESS_ISSUE` | Can't confirm property access | "I couldn't confirm property access. Is the property vacant with a lockbox, or do we need to coordinate with the seller?" |
| `SELLER_OCCUPIED_NO_NOTICE` | Seller occupied, insufficient notice | "The property is seller-occupied. Florida requires reasonable notice. I'd recommend scheduling at least 24 hours out to give the seller time to vacate." |
| `DUPLICATE_INSPECTION` | Inspection already scheduled | "There's already an inspection scheduled for this property on [date]. Would you like to reschedule it instead?" |
| `INSPECTION_TYPE_NOT_OFFERED` | Inspector doesn't do this type | "John Smith Inspections doesn't offer pool inspections. Would you like me to find a pool inspector?" |

## Florida-Specific Considerations

### Access and Notice
- Seller-occupied: Buyer has right to inspect, but must give reasonable notice (typically 24-48 hours)
- FAR/BAR contract gives buyer right to inspections during inspection period
- Seller cannot unreasonably deny access during inspection period

### Common Florida Inspection Add-ons
- 4-Point Inspection (required by many insurers for homes 20+ years)
- Wind Mitigation (can reduce insurance 20-40%)
- WDO/Termite (often required by lender)
- Pool/Spa (common in Florida)
- Septic (if not on sewer)

### Timing Considerations
- Schedule early in inspection period to allow time for re-inspection
- Allow 2-3 business days for report delivery
- Budget 3-5 days after report for repair request negotiations

## Integration Points

### Triggers After Scheduling
- Create inspection deadline if not exists
- Update deal inspection_status
- Add inspector as party to deal (if new)

### External Integrations
- Inspector scheduling systems (Spectora, HomeGauge, etc.)
- Google Calendar / Outlook Calendar
- SMS provider for confirmations
- Email for detailed access instructions

### Database Tables
- `appointments` - Main appointment record (new table needed)
- `parties` - Inspector as party
- `scheduled_jobs` - Reminder jobs
- `communications` - Notifications sent
- `action_log` - Audit entry

## Example Usage

### From Voice - Simple
```
Agent: "Hey Homer, schedule an inspection for 456 Oak Avenue
        with ABC Inspections this Thursday at 10 AM"

Homer: "Scheduling inspection for 456 Oak Avenue on Thursday,
        January 23rd at 10 AM with ABC Inspections.

        This is a general home inspection - should I also add
        the 4-point and wind mitigation? ABC offers a package
        discount if we do all three at once."

Agent: "Yes, add those."

Homer: "Done. ABC Inspections will perform the general inspection,
        4-point, and wind mitigation on Thursday at 10 AM.
        They'll need about 4 hours total.

        I've sent the calendar invite and access instructions.
        The lockbox code is 1234. Is the buyer planning to attend?"

Agent: "Yes, invite her."

Homer: "I've added Jane Buyer to the calendar invite and sent her
        the details. Everyone will get a reminder tomorrow morning.

        The inspection period ends January 30th, so you'll have
        a week after the inspection to review everything."
```

### From Voice - Complex Coordination
```
Agent: "I need to schedule an inspection for the condo at
        789 Beach Blvd. The buyer wants to attend and the
        seller needs advance notice."

Homer: "Got it. I see this is a condo at 789 Beach Boulevard.
        The inspection period ends February 5th.

        For a condo, I'd recommend the general inspection plus
        a 4-point for insurance. Since it's a high-rise, we may
        need building management approval.

        Your preferred inspector John Smith has availability:
        - Tuesday Jan 21 at 9 AM
        - Wednesday Jan 22 at 1 PM
        - Thursday Jan 23 at 10 AM

        Which works best?"

Agent: "Tuesday at 9."

Homer: "I'll schedule for Tuesday, January 21st at 9 AM.

        I'm sending the seller 48 hours notice as requested.
        I'll also notify the condo association about the inspection.

        Do you have the building access procedures, or should I
        contact the management company?"
```

## Quality Checklist

- [x] Handles voice input naturally with multiple phrasings
- [x] Validates date is within inspection period
- [x] Suggests inspector if not specified
- [x] Handles inspector availability conflicts
- [x] Coordinates multi-party availability
- [x] Sends appropriate notifications to all parties
- [x] Includes access instructions in communications
- [x] Schedules automatic reminders
- [x] Handles Florida-specific inspection types
- [x] Warns about tight deadlines
- [x] Creates audit log entry
- [x] Returns actionable next steps
- [x] Provides clear voice response
- [x] Handles errors gracefully
- [x] Supports seller-occupied properties
- [x] Handles condo-specific requirements

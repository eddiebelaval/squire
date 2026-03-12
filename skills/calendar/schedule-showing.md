# Skill: Schedule Showing

**Category:** Calendar
**Priority:** P1
**Approval Required:** No

## Purpose

Schedule property showing appointments for buyers to view a property. Handles coordination between buyer, buyer's agent, listing agent, and seller (if occupied). Supports single showings, back-to-back showings, open houses, and various property access scenarios.

## Triggers

### Voice Commands
- "Schedule showing for [address]"
- "Book a showing at [address] for [buyer name]"
- "I want to show [address] on [date]"
- "Set up a showing with the [buyer name] for [address]"
- "Can we see [address] tomorrow at [time]?"
- "Schedule tour of [address]"
- "Add [address] to the showing list for [date]"
- "Request showing at [MLS number]"

### Programmatic
- `POST /showings`
- ShowingTime integration
- Buyer portal showing request
- MLS showing request system

### Automatic
- Buyer expresses interest in property
- New listing matches buyer criteria

## Required Inputs

| Input | Type | Required | Source | Description |
|-------|------|----------|--------|-------------|
| `propertyAddress` | Address | Yes* | voice/MLS | Property to show |
| `mlsNumber` | string | Yes* | voice/MLS | MLS listing number |
| `showingDate` | Date | Yes | voice/manual | Requested showing date |
| `showingTime` | Time | Yes | voice/manual | Requested showing time |
| `buyerName` | string | Yes | voice/context | Buyer attending |

*Either propertyAddress or mlsNumber required.

## Optional Inputs

| Input | Type | Default | Source | Description |
|-------|------|---------|--------|-------------|
| `dealId` | UUID | null | context | Associated deal if exists |
| `duration` | number | 30 | default | Showing duration in minutes |
| `buyerAgentId` | UUID | current | context | Agent showing property |
| `buyerPhone` | string | null | voice | Buyer's phone for access |
| `numberOfBuyers` | number | 2 | voice | How many people attending |
| `showingType` | string | 'private' | voice | private, second_showing, open_house |
| `alternateTime1` | Time | null | voice | Backup time option |
| `alternateTime2` | Time | null | voice | Second backup time option |
| `specialRequests` | string | null | voice | Accessibility, pets, etc. |
| `virtualOption` | boolean | false | voice | Offer virtual showing if declined |
| `isExclusive` | boolean | false | context | Buyer has exclusive agreement |
| `preapproved` | boolean | null | voice | Buyer has preapproval |
| `notes` | string | null | voice | Notes for listing agent |

## Showing Types

| Type | Description | Typical Duration |
|------|-------------|------------------|
| `first_showing` | Initial property viewing | 15-30 minutes |
| `second_showing` | Follow-up detailed viewing | 30-45 minutes |
| `contractor_walkthrough` | Buyer with contractor | 45-60 minutes |
| `family_showing` | Buyer with family members | 30-45 minutes |
| `final_look` | Pre-offer last viewing | 15-30 minutes |
| `open_house` | Public showing | 2-4 hours |
| `broker_open` | Agents only preview | 2-3 hours |
| `virtual_showing` | Video tour | 15-30 minutes |

## Property Access Types

| Access | Description | Handling |
|--------|-------------|----------|
| `lockbox_supra` | Supra electronic lockbox | Agent accesses directly |
| `lockbox_combo` | Combination lockbox | Code provided by LA |
| `appointment_only` | Must confirm with seller | Request through system |
| `accompanied` | Listing agent must attend | Coordinate LA schedule |
| `call_first` | Call before showing | Contact seller/LA first |
| `tenant_occupied` | Tenant must approve | 24-hour notice required |
| `vacant_land` | No structure, open access | Note boundaries |
| `new_construction` | Builder sales office | Coordinate with builder |

## Execution Flow

```
START
  |
  +--- 1. Validate inputs
  |    +-- Property exists (MLS or address lookup)
  |    +-- Property is active listing
  |    +-- Date/time is reasonable
  |    +-- Buyer info provided
  |
  +--- 2. Load property context
  |    +-- Property details from MLS
  |    +-- Listing agent contact info
  |    +-- Showing instructions
  |    +-- Access type and codes
  |    +-- Occupancy status
  |    +-- Pet information
  |    +-- Previous showings by this buyer
  |
  +--- 3. Check showing restrictions
  |    +-- No showings during certain hours?
  |    +-- Minimum notice required?
  |    +-- Blackout dates?
  |    +-- Tenant notification requirements?
  |    +-- HOA showing rules (condos)
  |
  +--- 4. Submit showing request
  |    +-- If instant approval: confirm immediately
  |    +-- If requires confirmation:
  |    |   +-- Send request to ShowingTime/LA
  |    |   +-- Note pending status
  |    |   +-- Set follow-up reminder
  |    |
  |    +-- If accompanied required:
  |        +-- Check listing agent availability
  |        +-- Offer alternative times if needed
  |
  +--- 5. Handle response
  |    +-- If approved:
  |    |   +-- Get access instructions
  |    |   +-- Get lockbox code (if applicable)
  |    |   +-- Confirm any special instructions
  |    |
  |    +-- If declined:
  |    |   +-- Get reason if available
  |    |   +-- Suggest alternative times
  |    |   +-- Offer virtual option
  |    |
  |    +-- If no response (after threshold):
  |        +-- Follow up with listing agent
  |        +-- Escalate if needed
  |
  +--- 6. Create showing appointment
  |    +-- appointment_type: 'showing'
  |    +-- showing_type: [type]
  |    +-- property details
  |    +-- attendees: [buyer, buyer_agent]
  |    +-- access_info: instructions/codes
  |    +-- status: confirmed/pending
  |
  +--- 7. Send notifications
  |    +-- INVOKE: send-calendar-invite (to buyer)
  |    +-- INVOKE: send-calendar-invite (to buyer_agent)
  |    +-- INVOKE: send-sms (to buyer - confirmation)
  |    +-- INVOKE: send-email (to buyer - property details)
  |    |
  |    +-- If seller occupied:
  |        +-- Notification to seller via ShowingTime
  |
  +--- 8. Schedule reminders
  |    +-- 1 hour before: remind buyer
  |    +-- 30 min before: send access info to agent
  |
  +--- 9. Add to showing route (if multiple)
  |    +-- Check for other showings same day
  |    +-- Optimize route if applicable
  |    +-- Adjust timing for travel
  |
  +--- 10. Log action
  |     +-- action_type: 'showing_scheduled'
  |     +-- Track for analytics
  |
  +-- RETURN showing confirmation
```

## Output

```typescript
{
  success: true,
  actionTaken: "Scheduled showing at 456 Oak Ave for Jane Buyer on Jan 18, 2026 at 10:00 AM",
  result: {
    showing: {
      id: "uuid",
      confirmationNumber: "SHW-2026-0118-001",
      status: "confirmed",
      property: {
        address: "456 Oak Avenue, Miami FL 33101",
        mlsNumber: "A12345678",
        listPrice: 525000,
        bedrooms: 3,
        bathrooms: 2,
        sqft: 1850,
        listingAgent: "Mike Listing",
        listingAgentPhone: "(305) 555-0200"
      },
      schedule: {
        date: "2026-01-18",
        time: "10:00",
        duration: 30,
        endTime: "10:30"
      },
      access: {
        type: "lockbox_supra",
        instructions: "Supra lockbox on front door. Ring doorbell, no one home.",
        petInfo: null,
        alarmCode: null,
        notes: "Please remove shoes - seller request"
      },
      attendees: [
        { role: "buyer", name: "Jane Buyer", phone: "(305) 555-1234" },
        { role: "buyer_agent", name: "Your Name" }
      ]
    },
    otherShowings: {
      sameDay: [
        { time: "11:00", address: "789 Beach Blvd", status: "pending" }
      ],
      routeOptimized: true,
      travelTime: "15 minutes between showings"
    },
    notifications: {
      calendarInvitesSent: 2,
      smsSent: 1,
      showingSystemConfirmed: true
    },
    nextSteps: [
      "Showing confirmed - access via Supra lockbox",
      "Remind buyer to bring pre-approval letter if making offer",
      "Next showing at 789 Beach Blvd at 11:00 AM"
    ]
  }
}
```

## Voice Response

**Confirmed showing:**
> "I've scheduled a showing at 456 Oak Avenue for Jane tomorrow at 10 AM.
>
> It's a 3-bedroom, 2-bath listed at $525,000. Mike is the listing agent.
>
> Access is via Supra lockbox on the front door. The property is vacant, so you can go in whenever you're ready. The seller asks that you remove shoes.
>
> I've sent Jane a calendar invite with the property details and photos.
>
> I see you have another showing at 11 AM at 789 Beach Blvd - that's about 15 minutes away, so the timing works well."

**Pending confirmation:**
> "I've requested a showing at 456 Oak Avenue for tomorrow at 10 AM.
>
> This property requires seller confirmation - it's owner-occupied. They usually respond within a few hours.
>
> I'll text you as soon as it's confirmed. If they can't do 10 AM, would 11 AM or 2 PM work as backups?
>
> In the meantime, I've added it to your calendar as tentative."

**Declined with alternatives:**
> "The seller at 456 Oak Avenue can't accommodate tomorrow at 10 AM.
>
> They're available:
> - Today at 4 PM
> - Tomorrow at 2 PM
> - Saturday at 11 AM
>
> Or I can set up a virtual video tour - the listing agent has one recorded.
>
> Which would work for Jane?"

## Error Handling

| Error | Cause | Response |
|-------|-------|----------|
| `PROPERTY_NOT_FOUND` | Invalid MLS or address | "I couldn't find that property. Can you give me the MLS number or the full address?" |
| `PROPERTY_NOT_ACTIVE` | Listing is pending/sold | "This property is already under contract. It went pending on [date]. Would you like me to find similar properties?" |
| `SHOWING_BLOCKED` | Time not available | "Showings aren't available at that time. The listing notes [restriction]. How about [alternative]?" |
| `INSUFFICIENT_NOTICE` | Too short notice | "This property requires 24-hour notice for showings. The earliest I can request is [time]. Want me to submit for then?" |
| `DUPLICATE_SHOWING` | Already scheduled | "You already have a showing at this property scheduled for [date/time]. Would you like to reschedule it?" |
| `BUYER_OVERLAP` | Buyer has conflicting appointment | "Jane already has a showing at 10 AM at 789 Beach Blvd. Want me to schedule 456 Oak Avenue for 10:30 or 11:00 instead?" |
| `TENANT_RIGHTS` | Tenant occupied complications | "This is a tenant-occupied property. Florida law requires 24-hour notice. I'll coordinate with the tenant through the listing agent." |
| `ACCOMPANIED_ONLY` | LA must be present | "This property requires the listing agent to be present for showings. Mike is available at [times]. Which works?" |

## ShowingTime Integration

```typescript
// ShowingTime API integration for showing requests
interface ShowingTimeRequest {
  listingId: string;
  showingDate: string;
  showingTime: string;
  duration: number;
  buyerAgent: {
    name: string;
    phone: string;
    email: string;
    license: string;
  };
  buyerInfo: {
    name: string;
    phone?: string;
    preapproved?: boolean;
  };
  message?: string;
  alternativeTimes?: string[];
}

interface ShowingTimeResponse {
  status: 'confirmed' | 'pending' | 'declined';
  confirmationNumber?: string;
  accessInfo?: {
    type: string;
    code?: string;
    instructions?: string;
  };
  declineReason?: string;
  alternativeTimes?: string[];
}
```

## Integration Points

### External Systems
- ShowingTime / BrokerBay
- MLS data feed
- Supra lockbox system
- Google Maps for routing
- SMS for notifications

### Related Skills
- `check-availability` - Verify buyer availability
- `coordinate-multiple-parties` - Complex scheduling
- `send-calendar-invite` - Calendar invites
- `reschedule` - Change showing time

### Database Tables
- `showings` - Showing appointments (new or use appointments)
- `showing_feedback` - Post-showing feedback
- `communications` - Notifications
- `action_log` - Audit entry

## Example Usage

### From Voice - Single Showing
```
Agent: "Schedule a showing at 456 Oak Avenue for Jane
        tomorrow at 10 AM"

Homer: "Checking availability for 456 Oak Avenue...

        Confirmed! The showing is set for tomorrow, January 18th
        at 10 AM. It's a 3-bed, 2-bath listed at $525,000.

        Access is via Supra lockbox on the front door. The
        property is vacant with no pets.

        I've sent Jane a calendar invite with the property
        photos and details. I'll remind you both an hour before.

        Would you like to see any other properties while
        you're in the area?"

Agent: "What else is available?"

Homer: "In that neighborhood I have 3 active listings that
        match Jane's criteria:

        1. 789 Beach Blvd - 3/2, $495,000
        2. 321 Palm Drive - 4/2, $550,000
        3. 555 Coral Way - 3/2.5, $515,000

        I can schedule them at 10:30, 11:00, and 11:30 to
        make a morning tour. Want me to add any of these?"
```

### From Voice - Multiple Showings
```
Agent: "I need to set up showings for Jane on Saturday.
        We want to see 456 Oak, 789 Beach, and 321 Palm."

Homer: "Setting up a showing tour for Saturday for Jane.
        Let me check availability and optimize the route...

        Here's the best schedule:
        - 10:00 AM: 321 Palm Drive (start here, northernmost)
        - 10:45 AM: 456 Oak Avenue (15 min drive)
        - 11:30 AM: 789 Beach Blvd (20 min drive)

        Two are confirmed via Supra access. 789 Beach Blvd
        needs seller confirmation - I've submitted the request.

        Total tour time: about 2.5 hours including drive time.

        I've sent Jane the tour itinerary with directions
        and property details for each stop. Sound good?"
```

## Quality Checklist

- [x] Handles voice input naturally with multiple phrasings
- [x] Integrates with ShowingTime/MLS systems
- [x] Validates property is active
- [x] Handles all access types (lockbox, accompanied, tenant, etc.)
- [x] Provides property details in response
- [x] Supports multiple showings/tour optimization
- [x] Sends appropriate notifications
- [x] Handles pending confirmations gracefully
- [x] Provides alternatives when declined
- [x] Schedules automatic reminders
- [x] Includes travel time for multiple showings
- [x] Respects tenant notification requirements
- [x] Creates audit log entry
- [x] Returns actionable next steps
- [x] Provides clear voice response
- [x] Handles errors gracefully

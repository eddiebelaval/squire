# Skill: Schedule Closing

**Category:** Calendar
**Priority:** P0
**Approval Required:** No

## Purpose

Coordinate and schedule the closing appointment for a real estate transaction. This involves multiple parties (buyer, seller, agents, title company, lender representative, attorneys), finding a mutually available time, and ensuring all pre-closing requirements are met. The closing is the culmination of the transaction where ownership transfers.

## Triggers

### Voice Commands
- "Schedule closing for [address]"
- "Book the closing for [deal]"
- "Set up closing at [title company] for [date]"
- "When can we close on [address]?"
- "Closing for [address] on [date] at [time]"
- "Schedule closing with [title company]"
- "I need to set the closing date for [address]"
- "Close [address] on [date]"

### Programmatic
- `POST /deals/:id/appointments/closing`
- Lender clear to close received
- All contingencies satisfied

### Automatic
- All deadlines completed, closing date approaching
- Clear to close received (prompt to schedule)
- 5 days before contracted closing (if not scheduled)

## Required Inputs

| Input | Type | Required | Source | Description |
|-------|------|----------|--------|-------------|
| `dealId` | UUID | Yes | context | Deal to schedule closing for |
| `closingDate` | Date | Yes | voice/manual | Closing date |
| `closingTime` | Time | Yes | voice/manual | Closing time |

## Optional Inputs

| Input | Type | Default | Source | Description |
|-------|------|---------|--------|-------------|
| `titleCompanyId` | UUID | null | deal | Title company handling closing |
| `closingLocation` | string | null | voice/deal | Where closing will occur |
| `duration` | number | 90 | default | Expected duration in minutes |
| `attendees` | PartyRole[] | [all parties] | auto | Who should attend |
| `buyerRemote` | boolean | false | voice | Buyer signing remotely |
| `sellerRemote` | boolean | false | voice | Seller signing remotely |
| `mailAway` | boolean | false | voice | All parties remote |
| `dryClosing` | boolean | false | context | FL wet closing vs dry closing |
| `closerName` | string | null | voice | Specific closer at title company |
| `splitClosing` | boolean | false | voice | Buyer and seller at different times |
| `lenderRepRequired` | boolean | false | lender | Lender requires representative |
| `fundsWireTime` | Time | null | lender | When funds will wire |
| `notes` | string | null | voice | Special instructions |

## Florida Closing Types

| Type | Description | Common Use |
|------|-------------|------------|
| Traditional | All parties at same table | Standard transaction |
| Split Closing | Buyer/seller sign at different times | Conflict avoidance, convenience |
| Mail Away | Remote signing, docs mailed | Out of state buyer/seller |
| Mobile Notary | Notary travels to signer | Convenience, medical, scheduling |
| RON (Remote Online Notary) | Video notarization | Fully remote closings |
| Wet Closing | Funds disbursed same day | Florida standard |
| Dry Closing | Funds disbursed after recording | Some lenders require |

## Execution Flow

```
START
  |
  +--- 1. Validate inputs
  |    +-- Deal exists and is active/pending_closing
  |    +-- Date is on or before contract closing date
  |    +-- All contingencies satisfied (or waived)
  |    +-- Title company assigned
  |
  +--- 2. Load deal context
  |    +-- Property address
  |    +-- All parties and contact info
  |    +-- Title company details
  |    +-- Lender information (if financed)
  |    +-- Purchase price and amounts
  |    +-- Outstanding requirements
  |
  +--- 3. Check clear to close status
  |    +-- If financed:
  |    |   +-- Verify lender clear to close received
  |    |   +-- Confirm closing disclosure sent (3-day rule)
  |    |   +-- Note any lender requirements
  |    |
  |    +-- If cash:
  |        +-- Verify proof of funds confirmed
  |        +-- Wire instructions prepared
  |
  +--- 4. Verify title company availability
  |    +-- Query title company calendar
  |    +-- Check for specific closer if requested
  |    +-- Confirm closing room availability
  |    +-- If not available: offer alternatives
  |
  +--- 5. Check party availability
  |    +-- Buyer (required if in-person)
  |    +-- Seller (required if in-person)
  |    +-- Buyer's agent
  |    +-- Listing agent
  |    +-- Lender representative (if required)
  |    +-- Attorney (if applicable)
  |
  +--- 6. Handle remote closing logistics
  |    +-- If buyerRemote or sellerRemote:
  |    |   +-- Coordinate mobile notary OR
  |    |   +-- Set up RON session
  |    |   +-- Calculate document shipping time
  |    |
  |    +-- If mailAway:
  |        +-- Ensure enough time for shipping
  |        +-- Plan notarization method
  |        +-- Coordinate return shipping
  |
  +--- 7. Prepare closing timeline
  |    +-- Funds wire deadline (morning of closing)
  |    +-- Document review window
  |    +-- Walkthrough timing (suggest if not scheduled)
  |    +-- Key handoff planning
  |
  +--- 8. Create appointment record
  |    +-- appointment_type: 'closing'
  |    +-- date, time, duration
  |    +-- location: title company or other
  |    +-- attendees: all parties
  |    +-- closing_type: traditional/split/mail_away/ron
  |    +-- status: 'scheduled'
  |
  +--- 9. Send notifications
  |    +-- INVOKE: send-calendar-invite (all in-person attendees)
  |    +-- INVOKE: send-email (title company - confirmation)
  |    +-- INVOKE: send-email (buyer - what to bring)
  |    +-- INVOKE: send-email (seller - what to bring)
  |    +-- INVOKE: send-email (lender - closing scheduled)
  |    |
  |    +-- If split or remote:
  |        +-- INVOKE: send-email (with specific logistics)
  |
  +--- 10. Schedule pre-closing reminders
  |     +-- 3 days: confirm wire instructions received
  |     +-- 2 days: final document review
  |     +-- 1 day: what to bring reminder
  |     +-- Morning of: wire confirmation check
  |
  +--- 11. Update deal
  |     +-- Set closing_date (if not set)
  |     +-- Update deal status to 'pending_closing'
  |     +-- Link closing appointment
  |
  +--- 12. Suggest walkthrough
  |     +-- If no walkthrough scheduled:
  |         +-- INVOKE: schedule-walkthrough (suggest time)
  |
  +--- 13. Log action
  |     +-- action_type: 'closing_scheduled'
  |
  +-- RETURN closing confirmation
```

## What to Bring - Buyer

```typescript
const buyerChecklistFinanced = [
  "Valid government-issued photo ID (2 forms recommended)",
  "Certified/cashier's check or wire confirmation for closing costs",
  "Proof of homeowner's insurance",
  "Checkbook for minor adjustments",
  "Any outstanding documents requested by lender",
  "Power of Attorney (if applicable, must be pre-approved)"
];

const buyerChecklistCash = [
  "Valid government-issued photo ID (2 forms recommended)",
  "Wire confirmation for full purchase amount",
  "Proof of homeowner's insurance",
  "Checkbook for minor adjustments"
];
```

## What to Bring - Seller

```typescript
const sellerChecklist = [
  "Valid government-issued photo ID",
  "All keys, garage remotes, gate codes",
  "HOA documents and transfer info",
  "Home warranty info (if providing)",
  "Forwarding address for mail and final bills",
  "Utility account information for transfer"
];
```

## Output

```typescript
{
  success: true,
  actionTaken: "Scheduled closing for 123 Main St on Jan 30, 2026 at 2:00 PM",
  result: {
    appointment: {
      id: "uuid",
      type: "closing",
      closingType: "traditional",
      date: "2026-01-30",
      time: "14:00",
      duration: 90,
      endTime: "15:30",
      location: {
        name: "First Title Company",
        address: "100 Law Street, Suite 200, Miami FL 33101",
        closerName: "Sarah Johnson",
        phone: "(305) 555-0100"
      },
      attendees: [
        { role: "buyer", name: "Jane Buyer", remote: false },
        { role: "seller", name: "John Seller", remote: false },
        { role: "buyer_agent", name: "Your Name", remote: false },
        { role: "listing_agent", name: "Other Agent", remote: false },
        { role: "closing_agent", name: "Sarah Johnson", remote: false }
      ],
      status: "scheduled",
      confirmationNumber: "CLS-2026-0130-001"
    },
    financials: {
      purchasePrice: 450000,
      buyerCashDue: 127500,
      sellerProceeds: 285000,
      wireDeadline: "2026-01-30T10:00:00"
    },
    timeline: {
      closingDisclosureReceived: "2026-01-27",
      threeDayRuleSatisfied: true,
      walkthrough: {
        scheduled: true,
        date: "2026-01-30",
        time: "09:00"
      },
      fundsWireBy: "10:00 AM",
      closingAt: "2:00 PM",
      keysHandoffBy: "4:00 PM"
    },
    notifications: {
      calendarInvitesSent: 4,
      emailsSent: 6,
      confirmationsSent: ["title_company", "lender"]
    },
    documentsRequired: [
      { party: "buyer", document: "Photo ID", status: "pending" },
      { party: "buyer", document: "Insurance binder", status: "received" },
      { party: "seller", document: "Photo ID", status: "pending" }
    ],
    nextSteps: [
      "Confirm buyer has wire instructions",
      "Verify seller will bring all keys/remotes",
      "Walkthrough scheduled for 9:00 AM",
      "Buyer to wire funds by 10:00 AM"
    ]
  }
}
```

## Voice Response

**Standard scheduling:**
> "I've scheduled the closing for 123 Main Street on Thursday, January 30th at 2 PM at First Title Company.
>
> Sarah Johnson will be your closer. Everyone should plan for about 90 minutes.
>
> Here's the timeline for closing day:
> - 9 AM: Final walkthrough at the property
> - 10 AM: Buyer's funds must be wired
> - 2 PM: Closing at First Title
> - 4 PM: Keys should be handed over
>
> I've sent calendar invites to both agents, and emails to the buyer and seller with what to bring. I also confirmed with the lender.
>
> The 3-day closing disclosure rule is satisfied - it was delivered on January 27th.
>
> Anything else you need me to coordinate?"

**When not clear to close:**
> "I can tentatively schedule closing for January 30th, but I should mention we haven't received clear to close from the lender yet.
>
> The closing disclosure hasn't been sent, and it needs to be delivered at least 3 business days before closing.
>
> Would you like me to:
> 1. Schedule tentatively and reach out to the lender for an update?
> 2. Wait until we have clear to close to schedule?
>
> If we schedule now, we might need to push it back."

**Split closing:**
> "I've set up a split closing for 123 Main Street on January 30th:
>
> - Seller signs at 10 AM
> - Buyer signs at 2 PM
>
> This way they don't cross paths. Both are at First Title Company.
>
> I'll coordinate the document flow so everything is ready for the buyer's signing after the seller finishes. The seller's proceeds will wire once we have all signatures and recording confirmation."

**Remote/Mail Away:**
> "For the mail away closing on January 30th, here's the plan:
>
> The seller in California will receive documents by January 27th via FedEx. They'll need to sign with a mobile notary - I can coordinate that, or they can find a local notary.
>
> Documents must be returned by January 29th for closing to happen on the 30th.
>
> The buyer will sign in person at First Title at 2 PM on January 30th.
>
> Do you want me to arrange the mobile notary for the seller, or will they handle that?"

## Error Handling

| Error | Cause | Response |
|-------|-------|----------|
| `NO_TITLE_COMPANY` | No title company assigned | "Which title company will be handling the closing? I have First Title and ABC Title as options in this area." |
| `BEFORE_CONTRACT_DATE` | Date after contracted closing | "The contract closing date is January 25th. January 30th would require a closing extension. Want me to draft that addendum?" |
| `NO_CLEAR_TO_CLOSE` | Lender hasn't cleared | "I don't see a clear to close from the lender yet. Want me to schedule tentatively, or should I contact the lender first?" |
| `THREE_DAY_RULE` | CD not delivered in time | "The closing disclosure needs to be delivered at least 3 business days before closing. For a January 30th closing, it needed to be sent by January 27th. Current status shows it hasn't been sent yet." |
| `TITLE_UNAVAILABLE` | Title company can't do that time | "First Title doesn't have availability at 2 PM. They have openings at 10 AM and 4 PM. Would either of those work?" |
| `PARTY_UNAVAILABLE` | Key party can't attend | "The seller can't make 2 PM. Would 10 AM work, or should we do a split closing?" |
| `WIRE_TIMING` | Not enough time for wire | "A 9 AM closing doesn't leave enough time for wire confirmation. I'd recommend at least 2 PM to ensure funds are verified. Or we could schedule the wire for the day before." |
| `CONTINGENCIES_OPEN` | Not all contingencies cleared | "There are still open contingencies: [list]. Do you want to schedule closing contingent on these being resolved, or wait until they're cleared?" |

## Florida-Specific Considerations

### Wet Closing State
- Florida is a "wet" closing state - funds disburse same day
- Title company typically requires funds wired by 10-11 AM
- Recording happens after signing, usually same day
- Keys released after recording confirmation

### Documentary Stamp Tax
- Due at closing on the deed
- Calculated on purchase price (varies by county)
- Typically seller responsibility

### Title Insurance
- Owner's policy typically buyer expense in South Florida
- Lender's policy (if financed) buyer expense
- Title search/exam fees may be negotiable

### Survey Requirements
- Some lenders require current survey
- If survey older than 6 months, update may be needed

## Integration Points

### Pre-Requisites
- Clear to close (if financed)
- Closing disclosure delivered (3-day rule)
- Title commitment received
- All contingencies satisfied

### Triggers After Scheduling
- Suggest final walkthrough
- Request what-to-bring confirmations
- Schedule wire reminder
- Update deal status

### Related Skills
- `schedule-walkthrough` - Usually 2-4 hours before
- `send-calendar-invite` - For all attendees
- `coordinate-multiple-parties` - Complex scheduling

### Database Tables
- `appointments` - Closing appointment
- `deals` - Update closing_date and status
- `scheduled_jobs` - Reminders
- `communications` - All notifications
- `action_log` - Audit entry

## Example Usage

### From Voice - Simple
```
Agent: "Schedule closing for 123 Main Street on January 30th
        at 2 PM at First Title"

Homer: "Scheduling closing for 123 Main Street on Thursday,
        January 30th at 2 PM at First Title Company.

        I see the lender sent clear to close yesterday, and
        the closing disclosure was delivered on the 27th, so
        we're good on the 3-day rule.

        I'm sending calendar invites to:
        - Jane Buyer
        - John Seller
        - You
        - The listing agent Mike

        I'll send everyone the what-to-bring list and
        remind the buyer about the wire instructions.

        Want me to schedule the final walkthrough for that
        morning, say 9 AM?"

Agent: "Yes, schedule the walkthrough too."

Homer: "Done. Walkthrough at 9 AM, closing at 2 PM.
        I'll remind everyone on Wednesday."
```

### From Voice - Complex Coordination
```
Agent: "The seller is in California and the buyer wants to
        close next week. How do we handle this?"

Homer: "For an out-of-state seller, we have a few options:

        1. Mail Away: We FedEx documents to the seller, they
           sign with a local notary and return them

        2. Remote Online Notary (RON): They sign via video
           conference with a Florida-licensed RON

        3. Mobile Notary: We send a notary to them in California

        Given the tight timeline, I'd recommend RON. It's
        fastest and Florida recognizes it. First Title
        offers this service.

        For a closing next week, when were you thinking?
        The 3-day closing disclosure rule means we need
        the CD delivered by Tuesday for a Friday closing."

Agent: "Let's do Friday with RON for the seller."

Homer: "I'll schedule:
        - Friday, January 31st at 2 PM closing
        - Seller RON session at 10 AM Friday (their 7 AM Pacific)
        - Buyer in-person at First Title at 2 PM

        I'm confirming the lender can deliver the CD by Tuesday,
        and I'll coordinate the RON setup with the title company.

        I'll also schedule the walkthrough for Friday morning.
        Anything else?"
```

## Quality Checklist

- [x] Handles voice input naturally with multiple phrasings
- [x] Validates clear to close status
- [x] Enforces 3-day closing disclosure rule
- [x] Coordinates multiple parties' availability
- [x] Supports all closing types (traditional, split, remote, mail away, RON)
- [x] Generates what-to-bring checklists
- [x] Creates comprehensive closing timeline
- [x] Sends appropriate notifications to all parties
- [x] Schedules wire reminders
- [x] Suggests walkthrough if not scheduled
- [x] Links walkthrough and closing appointments
- [x] Updates deal status appropriately
- [x] Handles Florida-specific requirements
- [x] Creates audit log entry
- [x] Returns actionable next steps
- [x] Provides clear voice response
- [x] Handles errors gracefully

# Skill: Check Availability

**Category:** Calendar
**Priority:** P1
**Approval Required:** No

## Purpose

Check calendar availability for one or more parties involved in a real estate transaction. Used to find open time slots for scheduling appointments, coordinate multiple party calendars, and suggest optimal meeting times. Integrates with external calendar systems (Google, Outlook) and internal appointment records.

## Triggers

### Voice Commands
- "When is [party name] available?"
- "Check [inspector name]'s availability"
- "What times work for the buyer?"
- "Is the title company available Friday?"
- "Find an open time for [party list]"
- "When can we all meet?"
- "Check my calendar for [date/time]"
- "Is the seller free on [date]?"

### Programmatic
- `GET /parties/:id/availability`
- `POST /availability/check`
- Called by scheduling skills (pre-check)
- Calendar sync webhooks

### Automatic
- Before any scheduling action (internal check)
- When coordinating multiple parties

## Required Inputs

| Input | Type | Required | Source | Description |
|-------|------|----------|--------|-------------|
| `partyIds` | UUID[] | Yes* | context | Parties to check |
| `partyNames` | string[] | Yes* | voice | Party names to look up |
| `dateRange` | DateRange | Yes | voice/default | Start and end date to check |

*Either partyIds or partyNames required.

## Optional Inputs

| Input | Type | Default | Source | Description |
|-------|------|---------|--------|-------------|
| `dealId` | UUID | null | context | Deal context for party lookup |
| `timeRange` | TimeRange | 9am-5pm | voice | Business hours to consider |
| `duration` | number | 60 | voice | Required meeting duration in minutes |
| `timezone` | string | agent's tz | context | Timezone for results |
| `excludeWeekends` | boolean | true | default | Skip Saturday/Sunday |
| `preferredDays` | string[] | null | voice | Preferred days of week |
| `preferredTimes` | string[] | null | voice | Preferred time slots |
| `bufferMinutes` | number | 15 | default | Buffer between appointments |
| `calendarType` | string | 'all' | context | google, outlook, internal, all |

## Party Calendar Sources

| Source | Description | Access Method |
|--------|-------------|---------------|
| `internal` | Homer Pro appointments | Database query |
| `google` | Google Calendar | OAuth integration |
| `outlook` | Microsoft 365/Outlook | Graph API |
| `calendly` | Calendly booking | API |
| `manual` | No sync, ask directly | Communication |
| `showingtime` | ShowingTime calendar | API |

## Execution Flow

```
START
  |
  +--- 1. Resolve parties
  |    +-- If partyIds: load directly
  |    +-- If partyNames: fuzzy match in deal context
  |    +-- Validate all parties found
  |    +-- Get calendar integration status for each
  |
  +--- 2. Determine date/time range
  |    +-- Parse date range from input
  |    +-- Default: next 7 days if not specified
  |    +-- Apply business hours filter
  |    +-- Apply weekend exclusion
  |    +-- Consider timezone differences
  |
  +--- 3. Query each party's calendar
  |    |
  |    +-- FOR EACH party:
  |    |   +-- If Google synced:
  |    |   |   +-- Query Google Calendar API
  |    |   |   +-- Get busy times
  |    |   |
  |    |   +-- If Outlook synced:
  |    |   |   +-- Query Graph API
  |    |   |   +-- Get busy times
  |    |   |
  |    |   +-- If internal only:
  |    |   |   +-- Query Homer Pro appointments
  |    |   |
  |    |   +-- If no calendar:
  |    |       +-- Note: availability unknown
  |    |       +-- Return all times as "needs confirmation"
  |    |
  |    +-- Aggregate busy times
  |
  +--- 4. Calculate available slots
  |    +-- Find gaps in combined busy times
  |    +-- Filter by minimum duration
  |    +-- Apply buffer between slots
  |    +-- Group by day
  |    +-- Rank by preference match
  |
  +--- 5. Apply preferences
  |    +-- Weight preferred days higher
  |    +-- Weight preferred times higher
  |    +-- Consider historical patterns
  |    +-- Avoid lunch hours (12-1) if possible
  |
  +--- 6. Format results
  |    +-- Sort by date/time
  |    +-- Group by day for clarity
  |    +-- Note confirmation requirements
  |    +-- Include all party availability status
  |
  +--- 7. Log query (no action log, just metrics)
  |
  +-- RETURN availability results
```

## Output

```typescript
{
  success: true,
  actionTaken: "Checked availability for 3 parties over next 7 days",
  result: {
    parties: [
      {
        id: "uuid",
        name: "John Smith Inspections",
        role: "inspector",
        calendarSource: "google",
        calendarSynced: true
      },
      {
        id: "uuid",
        name: "Jane Buyer",
        role: "buyer",
        calendarSource: "internal",
        calendarSynced: false,
        note: "Availability based on Homer Pro appointments only"
      },
      {
        id: "uuid",
        name: "Agent Name",
        role: "buyer_agent",
        calendarSource: "google",
        calendarSynced: true
      }
    ],
    dateRange: {
      start: "2026-01-18",
      end: "2026-01-25"
    },
    availableSlots: [
      {
        date: "2026-01-20",
        dayOfWeek: "Monday",
        slots: [
          {
            start: "09:00",
            end: "11:00",
            duration: 120,
            allPartiesConfirmed: true,
            notes: null
          },
          {
            start: "14:00",
            end: "17:00",
            duration: 180,
            allPartiesConfirmed: false,
            notes: "Buyer availability needs confirmation"
          }
        ]
      },
      {
        date: "2026-01-21",
        dayOfWeek: "Tuesday",
        slots: [
          {
            start: "10:00",
            end: "12:00",
            duration: 120,
            allPartiesConfirmed: true,
            notes: null
          }
        ]
      }
    ],
    busyTimes: [
      {
        party: "John Smith Inspections",
        date: "2026-01-20",
        busy: [
          { start: "11:00", end: "14:00", reason: "Other inspection" }
        ]
      }
    ],
    summary: {
      totalSlots: 5,
      confirmedSlots: 3,
      needsConfirmation: 2,
      bestSlot: {
        date: "2026-01-20",
        time: "09:00",
        reason: "All parties confirmed available, earliest option"
      }
    },
    recommendations: [
      "Monday Jan 20 at 9 AM works for everyone",
      "If that doesn't work, Tuesday Jan 21 at 10 AM is also open",
      "Buyer's availability after 2 PM needs confirmation - their calendar isn't synced"
    ]
  }
}
```

## Voice Response

**Single party availability:**
> "John Smith Inspections is available on:
>
> - Monday at 9 AM and 3 PM
> - Tuesday all day
> - Wednesday morning before noon
>
> He's booked Thursday and Friday for other inspections.
>
> Would you like me to schedule one of these times?"

**Multiple party coordination:**
> "I checked availability for the inspector, buyer, and yourself for next week.
>
> Everyone is available:
> - Monday, January 20th at 9 AM
> - Tuesday, January 21st at 10 AM
>
> Monday at 9 is your best bet since you're all confirmed free.
>
> Note: Jane's calendar isn't synced, so her afternoon availability isn't certain. If you need afternoon times, I should confirm with her directly.
>
> Should I schedule the inspection for Monday at 9?"

**Limited availability:**
> "It's tough to find a time that works for everyone next week.
>
> The inspector is only available Monday and Thursday. The title company has closings both those days in the afternoon.
>
> Your only window is Monday between 9 and 11 AM. Does that work for the buyer?
>
> Otherwise, we'd need to look at the following week, where there are more options."

**No synced calendar:**
> "I don't have access to the seller's calendar - they haven't connected it to Homer Pro.
>
> Based on the deal notes, they prefer weekday evenings after 5 PM or weekends.
>
> Would you like me to:
> 1. Send them a message asking for their availability?
> 2. Use a scheduling link they can fill out?
> 3. Just propose a few times and see what works?"

## Error Handling

| Error | Cause | Response |
|-------|-------|----------|
| `PARTY_NOT_FOUND` | Can't find specified party | "I couldn't find [name] in this deal. Did you mean [similar name], or should I add them as a new party?" |
| `NO_CALENDAR_ACCESS` | Party hasn't synced calendar | "I don't have access to [party]'s calendar. I can only check their Homer Pro appointments. Want me to reach out to them for their availability?" |
| `CALENDAR_SYNC_ERROR` | API error with calendar | "I'm having trouble connecting to [party]'s Google Calendar. I'll use their last known availability and confirm with them." |
| `NO_AVAILABLE_SLOTS` | No common availability | "There's no time that works for everyone in that date range. Would you like me to check the following week, or prioritize certain people?" |
| `INVALID_DATE_RANGE` | Past dates or too far out | "I can only check availability for future dates, up to 30 days out. What date range would you like me to check?" |
| `TOO_MANY_PARTIES` | Coordinating too many people | "Coordinating 6+ calendars is tricky. Can we do this in groups - maybe schedule the inspection separately from the closing?" |

## Calendar Integration Details

### Google Calendar

```typescript
interface GoogleCalendarQuery {
  calendarId: string;
  timeMin: string; // ISO datetime
  timeMax: string; // ISO datetime
  singleEvents: true;
  orderBy: 'startTime';
}

// Returns busy times, respects free/busy sharing settings
```

### Microsoft Graph (Outlook)

```typescript
interface OutlookAvailabilityQuery {
  schedules: string[]; // email addresses
  startTime: { dateTime: string; timeZone: string };
  endTime: { dateTime: string; timeZone: string };
  availabilityViewInterval: number; // minutes
}
```

### ShowingTime

```typescript
interface ShowingTimeAvailability {
  agentId: string;
  dateRange: { start: string; end: string };
  // Returns confirmed showings and blocked times
}
```

## Integration Points

### Used By
- `schedule-inspection` - Check inspector and buyer availability
- `schedule-walkthrough` - Check party availability
- `schedule-closing` - Check all parties for closing
- `schedule-showing` - Check agent and buyer availability
- `coordinate-multiple-parties` - Core availability lookup
- `reschedule` - Find alternative times

### External Integrations
- Google Calendar API
- Microsoft Graph API
- ShowingTime API
- Calendly API

### Database Tables
- `appointments` - Internal appointments
- `parties` - Party calendar preferences
- `calendar_syncs` - OAuth tokens and sync status

## Example Usage

### From Voice - Simple Check
```
Agent: "When is the inspector available this week?"

Homer: "Let me check John Smith Inspections' calendar...

        He has openings:
        - Tomorrow (Thursday) at 9 AM and 2 PM
        - Friday at 10 AM

        He's booked solid Monday through Wednesday with
        back-to-back inspections.

        Want me to check if any of these work for your buyer?"

Agent: "Check if Jane can do Thursday at 9"

Homer: "Jane's calendar isn't synced, but she doesn't have
        any appointments in Homer Pro on Thursday morning.

        I can text her to confirm, or we can book it and
        let her know. What's your preference?"
```

### From Voice - Coordination
```
Agent: "I need to find a time for closing that works for
        the buyer, seller, both agents, and title company"

Homer: "That's a lot of calendars to coordinate. Let me check...

        Looking at next week, the only time everyone shows
        as available is:
        - Thursday at 2 PM

        Here's the breakdown:
        - You: Free all week
        - Buyer: Works from home Thursdays, flexible
        - Seller: Only available after 1 PM (works mornings)
        - Listing agent: Has showings Monday-Wednesday afternoons
        - First Title: Morning closings Mon-Wed, afternoons open Thu-Fri

        Thursday at 2 PM is your best bet. Second choice
        would be Friday at 2 PM, but the buyer's calendar
        shows 'maybe' for that time.

        Should I book Thursday at 2 PM?"
```

### From Voice - Date Range
```
Agent: "What's the buyer's availability over the next two weeks?"

Homer: "Based on Jane's synced Google Calendar, here's her
        availability for the next two weeks:

        This Week:
        - Thursday: 9-11 AM, after 4 PM
        - Friday: All day

        Next Week:
        - Monday: After 2 PM
        - Tuesday: 10 AM - 3 PM
        - Wednesday: Morning only
        - Thursday: All day
        - Friday: 9 AM - 1 PM

        She has a recurring meeting Wednesdays at 3 PM and
        seems to block mornings on Mondays.

        What are you trying to schedule? I can find the
        best match."
```

## Quality Checklist

- [x] Handles voice input naturally with multiple phrasings
- [x] Integrates with Google Calendar
- [x] Integrates with Outlook/Microsoft 365
- [x] Integrates with ShowingTime
- [x] Falls back gracefully when calendars not synced
- [x] Handles timezone differences
- [x] Respects business hours
- [x] Calculates required duration slots
- [x] Provides clear availability summary
- [x] Recommends best available slot
- [x] Notes which parties need confirmation
- [x] Handles complex multi-party coordination
- [x] Returns actionable next steps
- [x] Provides clear voice response
- [x] Handles errors gracefully
- [x] Suggests alternatives when no slots available

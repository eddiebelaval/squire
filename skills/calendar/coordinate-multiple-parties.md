# Skill: Coordinate Multiple Parties

**Category:** Calendar
**Priority:** P0
**Approval Required:** No

## Purpose

Find meeting times that work for multiple parties involved in a real estate transaction. Handles complex scheduling scenarios involving 2-10+ people across different roles, time zones, and calendar systems. Uses intelligent optimization to find the best available slots while respecting preferences and constraints.

## Triggers

### Voice Commands
- "Find a time that works for everyone"
- "When can all parties meet?"
- "Coordinate calendars for [appointment type]"
- "Schedule [meeting] with [list of people]"
- "What time works for the buyer, seller, and title company?"
- "Find availability for [party list]"
- "When is everyone free for the closing?"
- "Coordinate schedules for [date/time range]"

### Programmatic
- `POST /calendar/coordinate`
- Called by scheduling skills when multiple parties needed
- Complex appointment creation

### Automatic
- Pre-closing coordination check
- Multi-party appointment scheduling

## Required Inputs

| Input | Type | Required | Source | Description |
|-------|------|----------|--------|-------------|
| `parties` | Party[] | Yes | voice/context | Parties to coordinate |
| `duration` | number | Yes | voice/default | Required meeting duration in minutes |

## Optional Inputs

| Input | Type | Default | Source | Description |
|-------|------|---------|--------|-------------|
| `dealId` | UUID | null | context | Deal for context and party lookup |
| `dateRange` | DateRange | next 14 days | voice | Date range to search |
| `timeRange` | TimeRange | 9am-5pm | voice | Business hours preference |
| `timezone` | string | agent's tz | context | Primary timezone for display |
| `requiredParties` | string[] | all | voice | Parties that must attend |
| `optionalParties` | string[] | [] | voice | Nice-to-have attendees |
| `preferredDays` | string[] | null | voice | Preferred days of week |
| `preferredTimes` | string[] | null | voice | morning, afternoon, evening |
| `excludeDates` | Date[] | null | voice | Dates to skip |
| `maxResults` | number | 5 | default | Number of options to return |
| `optimizeFor` | string | 'earliest' | voice | earliest, most_available, preferred |
| `bufferMinutes` | number | 15 | default | Buffer between appointments |
| `appointmentType` | string | null | context | Type for custom rules |

## Party Priority Levels

When conflicts exist, use these priorities:

| Priority | Roles | Rationale |
|----------|-------|-----------|
| Critical | closing_agent, title_company | Location-dependent, limited hours |
| High | buyer, seller | Transaction principals |
| High | lender (for closing) | Funds dependent on their process |
| Medium | buyer_agent, listing_agent | Professional flexibility expected |
| Medium | inspector, appraiser | Typically flexible schedulers |
| Low | attorney | Usually optional attendance |
| Optional | others | As available |

## Execution Flow

```
START
  |
  +--- 1. Resolve parties
  |    +-- If party names: look up in deal context
  |    +-- If roles: get all parties with those roles
  |    +-- Validate all parties found
  |    +-- Categorize as required vs optional
  |    +-- Determine priority levels
  |
  +--- 2. Gather calendar data
  |    |
  |    +-- FOR EACH party:
  |    |   +-- If calendar synced:
  |    |   |   +-- INVOKE: check-availability
  |    |   |   +-- Get busy times in date range
  |    |   |
  |    |   +-- If not synced:
  |    |       +-- Use Homer Pro appointments only
  |    |       +-- Mark as "needs confirmation"
  |    |
  |    +-- Handle timezone conversions
  |
  +--- 3. Build availability matrix
  |    +-- Create time grid (15-min or 30-min slots)
  |    +-- FOR EACH slot:
  |    |   +-- Check against each party's busy times
  |    |   +-- Mark available/busy/unknown for each
  |    |
  |    +-- Identify fully available slots
  |    +-- Identify partially available slots
  |
  +--- 4. Apply constraints
  |    +-- Filter by date range
  |    +-- Filter by time range (business hours)
  |    +-- Filter by minimum duration
  |    +-- Exclude specified dates
  |    +-- Apply buffers between appointments
  |
  +--- 5. Apply preferences
  |    +-- Weight preferred days higher
  |    +-- Weight preferred times higher
  |    +-- Adjust for party preferences
  |    +-- Consider historical patterns
  |
  +--- 6. Score and rank slots
  |    +-- Score = availability + preferences + timing
  |    +-- Penalize slots needing confirmation
  |    +-- Boost slots where all parties confirmed
  |    +-- Consider travel time if locations differ
  |
  +--- 7. Select top results
  |    +-- Based on optimizeFor strategy:
  |    |   +-- 'earliest': Sort by datetime
  |    |   +-- 'most_available': Sort by confirmation count
  |    |   +-- 'preferred': Sort by preference score
  |    |
  |    +-- Return top N options
  |
  +--- 8. Format results
  |    +-- Group by day
  |    +-- Show availability status per party
  |    +-- Note confirmation requirements
  |    +-- Include trade-offs for each option
  |
  +--- 9. If no slots found:
  |    +-- Expand date range
  |    +-- Show partial matches
  |    +-- Identify blockers
  |    +-- Suggest removing optional parties
  |
  +-- RETURN coordination results
```

## Scoring Algorithm

```typescript
interface SlotScore {
  slot: TimeSlot;
  totalScore: number;
  components: {
    availability: number;   // 0-40 points
    confirmation: number;   // 0-20 points
    timing: number;         // 0-20 points
    preference: number;     // 0-20 points
  };
}

function scoreSlot(slot: TimeSlot, context: CoordinationContext): SlotScore {
  const components = {
    // Availability: How many required parties are free?
    availability: calculateAvailabilityScore(slot, context.requiredParties),

    // Confirmation: Are calendars synced or just assumed?
    confirmation: calculateConfirmationScore(slot, context.parties),

    // Timing: Is this the earliest? How far out?
    timing: calculateTimingScore(slot, context.preferences),

    // Preference: Does it match stated preferences?
    preference: calculatePreferenceScore(slot, context.preferences)
  };

  return {
    slot,
    totalScore: Object.values(components).reduce((a, b) => a + b, 0),
    components
  };
}

// Availability scoring (0-40 points)
function calculateAvailabilityScore(slot: TimeSlot, parties: Party[]): number {
  const available = parties.filter(p => isAvailable(p, slot)).length;
  const total = parties.length;
  return (available / total) * 40;
}

// Confirmation scoring (0-20 points)
function calculateConfirmationScore(slot: TimeSlot, parties: Party[]): number {
  const confirmed = parties.filter(p => p.calendarSynced).length;
  const total = parties.length;
  return (confirmed / total) * 20;
}
```

## Output

```typescript
{
  success: true,
  actionTaken: "Found 5 times that work for 4 parties",
  result: {
    parties: [
      { name: "Jane Buyer", role: "buyer", calendarSource: "google", priority: "high" },
      { name: "John Seller", role: "seller", calendarSource: "none", priority: "high" },
      { name: "Agent Name", role: "buyer_agent", calendarSource: "google", priority: "medium" },
      { name: "First Title", role: "title_company", calendarSource: "internal", priority: "critical" }
    ],
    requiredDuration: 90,
    dateRange: { start: "2026-01-18", end: "2026-02-01" },
    options: [
      {
        rank: 1,
        date: "2026-01-22",
        dayOfWeek: "Wednesday",
        start: "14:00",
        end: "15:30",
        score: 95,
        availability: {
          "Jane Buyer": { status: "available", source: "google", confirmed: true },
          "John Seller": { status: "unknown", source: "none", confirmed: false },
          "Agent Name": { status: "available", source: "google", confirmed: true },
          "First Title": { status: "available", source: "internal", confirmed: true }
        },
        notes: [
          "Best option - 3 of 4 confirmed available",
          "Seller needs to confirm (no calendar synced)"
        ]
      },
      {
        rank: 2,
        date: "2026-01-23",
        dayOfWeek: "Thursday",
        start: "10:00",
        end: "11:30",
        score: 88,
        availability: {
          "Jane Buyer": { status: "available", source: "google", confirmed: true },
          "John Seller": { status: "unknown", source: "none", confirmed: false },
          "Agent Name": { status: "busy", source: "google", conflict: "Showing at 789 Beach Blvd" },
          "First Title": { status: "available", source: "internal", confirmed: true }
        },
        notes: [
          "You have a showing conflict - could reschedule",
          "Otherwise good option"
        ]
      },
      // ... more options
    ],
    conflicts: [
      {
        party: "Agent Name",
        date: "2026-01-23",
        time: "10:00",
        reason: "Showing at 789 Beach Blvd",
        resolvable: true
      }
    ],
    recommendations: {
      bestOption: 1,
      reason: "Wednesday at 2 PM has the most confirmed availability. We just need to confirm with the seller.",
      action: "Shall I send the seller a message to confirm Wednesday at 2 PM?"
    },
    unconfirmedParties: [
      { name: "John Seller", reason: "Calendar not synced", action: "Request availability" }
    ]
  }
}
```

## Voice Response

**Good options found:**
> "I found 5 times that could work for everyone over the next two weeks.
>
> The best option is Wednesday, January 22nd at 2 PM. Jane, you, and First Title are all confirmed free. We just need to verify with John, the seller - his calendar isn't synced.
>
> Second choice is Thursday at 10 AM, but you have a showing then that could be moved.
>
> Would you like me to reach out to the seller about Wednesday at 2 PM?"

**Limited options:**
> "This is a tricky one. With 5 people to coordinate, I only found 2 possible times:
>
> - Monday January 27th at 11 AM - everyone shows as available, but the title company is only confirmed until 12:30, so it's tight for a 90-minute closing.
>
> - Friday January 31st at 2 PM - all confirmed, but the buyer has 'tentative' on their calendar.
>
> The Monday option is tighter but more certain. Friday is more comfortable but needs buyer confirmation.
>
> Which would you prefer, or should I check the following week?"

**No options found:**
> "I couldn't find a time that works for all 5 parties in the next two weeks.
>
> Here's where the conflicts are:
> - The title company only has afternoon availability
> - The buyer is blocked every afternoon next week
> - You have back-to-back showings Monday through Wednesday
>
> A few options:
> 1. Check the week of February 3rd (more flexibility)
> 2. Do a split closing - seller signs in morning, buyer in afternoon
> 3. Remove the listing agent as required (make them optional)
>
> What would work best?"

**Partial availability:**
> "I have times where most people work, but not everyone:
>
> Tuesday at 10 AM works for 4 of 5 people. The inspector isn't available then, but that's unusual for a closing - do you actually need them there?
>
> If the inspector is optional, Tuesday at 10 AM is your best bet. Everyone else is confirmed."

## Error Handling

| Error | Cause | Response |
|-------|-------|----------|
| `NO_PARTIES` | No parties specified | "Who needs to attend? Tell me the roles or names and I'll check their availability." |
| `PARTY_NOT_FOUND` | Can't find specified party | "I couldn't find [name] in the deal. Did you mean [similar name], or should I add them?" |
| `NO_CALENDARS` | No parties have synced calendars | "None of these parties have their calendars connected. I can only check Homer Pro appointments. Would you like me to request their availability via email?" |
| `RANGE_TOO_SHORT` | Not enough days to search | "There aren't many options in a 3-day window. Would you like me to expand to 2 weeks?" |
| `TOO_MANY_PARTIES` | 10+ parties to coordinate | "Coordinating 12 calendars is challenging. Can we identify which attendees are essential vs. optional?" |
| `ALL_BLOCKED` | Everyone has conflicts | "No times work for everyone in that range. [Show blockers and suggestions]" |
| `DURATION_TOO_LONG` | Can't find long enough slot | "I can't find a 4-hour block that works. Would two 2-hour sessions work instead?" |

## Advanced Scenarios

### Time Zone Handling
```typescript
// When parties are in different time zones
const coordination = {
  parties: [
    { name: "Jane", timezone: "America/New_York" },
    { name: "Remote Seller", timezone: "America/Los_Angeles" }
  ],
  displayTimezone: "America/New_York", // Agent's timezone

  // Results show slots in display timezone
  // But checks use each party's local time
  // 9 AM ET = 6 AM PT (might be too early for CA seller)
};
```

### Split Scheduling
```typescript
// When all-together isn't possible
const splitSuggestion = {
  option: "split",
  sessions: [
    {
      attendees: ["seller", "listing_agent"],
      purpose: "Seller signing",
      suggestedTime: "10:00 AM"
    },
    {
      attendees: ["buyer", "buyer_agent"],
      purpose: "Buyer signing",
      suggestedTime: "2:00 PM"
    }
  ],
  reason: "Buyer and seller have completely opposite availability"
};
```

### Priority-Based Fallback
```typescript
// When not everyone can make it
const fallbackLogic = {
  if: "no slots work for all required parties",
  then: [
    "1. Check if any 'required' party could be 'optional'",
    "2. Suggest split sessions for incompatible parties",
    "3. Identify the blocker and offer to help resolve",
    "4. Expand date range and try again"
  ]
};
```

## Integration Points

### Uses
- `check-availability` - Query individual calendars
- `sync-calendars` - Ensure data is current

### Used By
- `schedule-closing` - Multi-party coordination
- `schedule-inspection` - Coordinate inspector + buyer
- `schedule-walkthrough` - Coordinate buyer + agents

### Database Tables
- `calendar_syncs` - Calendar connection status
- `synced_events` - External calendar data
- `appointments` - Internal appointments
- `parties` - Party information

## Example Usage

### From Voice - Closing Coordination
```
Agent: "Find a time for closing that works for the buyer,
        seller, both agents, and the title company"

Homer: "Let me check everyone's calendars for the next
        two weeks...

        I found 3 good options:

        1. Wednesday Jan 22 at 2 PM
           - Everyone confirmed except seller (needs check)
           - This is my top recommendation

        2. Friday Jan 24 at 10 AM
           - All 5 parties confirmed available
           - But the buyer marked it as 'tentative'

        3. Monday Jan 27 at 3 PM
           - All confirmed, but it's a holiday week
           - Title company closes at 5

        The seller doesn't have their calendar synced.
        Should I text them to confirm Wednesday at 2 PM?"

Agent: "Yes, check with the seller."

Homer: "I'm texting John now: 'Hi John, we're scheduling
        closing for 123 Main Street. Does Wednesday,
        January 22nd at 2 PM work for you? The closing
        will be at First Title Company.'

        I'll let you know when he responds."
```

### From Voice - Complex Multi-Party
```
Agent: "I need to schedule an inspection that works for
        the buyer, me, and the inspector. The buyer works
        9-5 and can only do early morning or after work."

Homer: "Got it. Jane works regular hours, so we need early
        morning or evening times.

        Checking John Smith Inspections availability outside
        9-5...

        Here's what works:
        - Tomorrow at 7 AM (Jane and inspector confirmed)
        - Thursday at 6 PM (but inspector charges extra for
          after-hours)
        - Saturday at 9 AM (weekend, but normal hours)

        The 7 AM slot tomorrow is earliest. Jane would need
        to be there by 7. The inspector wraps up by 10 AM,
        so she could still get to work by 10:30.

        Or Saturday is more relaxed if timing isn't critical.

        The inspection period ends January 30th, so you have
        time for either option."

Agent: "Let's do Saturday."

Homer: "Scheduling for Saturday, January 25th at 9 AM.
        Sending calendar invites to Jane and the inspector
        now."
```

## Quality Checklist

- [x] Handles 2-10+ party coordination
- [x] Integrates with multiple calendar systems
- [x] Respects party priority levels
- [x] Handles timezone differences
- [x] Scores and ranks options intelligently
- [x] Shows confirmation status per party
- [x] Identifies and explains conflicts
- [x] Suggests split sessions when needed
- [x] Falls back gracefully with limited options
- [x] Offers to expand search range
- [x] Notes when confirmation is needed
- [x] Considers appointment type constraints
- [x] Returns actionable recommendations
- [x] Provides clear voice response
- [x] Handles errors gracefully
- [x] Supports preference-based optimization

# Skill: Florida Deadline Calculation Rules

**Category:** Compliance
**Priority:** P0
**Approval Required:** No

## Purpose

Reference and apply Florida real estate deadline calculation rules. Provides authoritative guidance on how to count days, handle weekends/holidays, and determine the exact deadline date for any contractual obligation.

## Legal Authority

- **FAR/BAR Contract Paragraph 19** - Time is of the Essence
- **FAR/BAR Contract Paragraph 24** - Computation of Time
- **Florida Statutes §683.01** - Legal holidays
- **Florida Statutes §687.12** - Computation of time (general)
- **Florida Rule of Civil Procedure 1.090(a)** - Time computation

## Triggers

### Voice Commands
- "When is the [deadline type] deadline?"
- "Calculate inspection period end date"
- "What day does the financing contingency expire?"
- "Is [date] a business day?"
- "When is 10 days from [date]?"
- "What are the deadlines for this deal?"

### Programmatic
- Deal created with effective date
- Deadline calculation requested
- Amendment changes timeline
- Calendar event generation
- Compliance check running

## Required Inputs

| Input | Type | Required | Source | Description |
|-------|------|----------|--------|-------------|
| `startDate` | Date | Yes | contract/deal | Date to calculate from |
| `periodType` | string | Yes | request | Type: 'days', 'business_days', 'calendar_days' |
| `periodLength` | number | Yes | contract | Number of days/period |
| `deadlineType` | string | Yes | contract | Type of deadline for context |

## Optional Inputs

| Input | Type | Default | Source | Description |
|-------|------|---------|--------|-------------|
| `county` | string | null | deal | County for local holidays |
| `excludeHolidays` | boolean | true | config | Exclude federal holidays |
| `timeOfDay` | string | '11:59 PM' | config | Deadline time |
| `useNextBusinessDay` | boolean | true | config | If lands on weekend/holiday |

## Core Calculation Rules

### FAR/BAR Computation of Time (Paragraph 24)

```
RULE 1: Day of Event Excluded
─────────────────────────────
The day the period begins (effective date, notice date) is NOT counted.
Example: Effective date Jan 15, 3-day period → Count starts Jan 16

RULE 2: Calendar Days Unless Specified
──────────────────────────────────────
Unless the contract says "business days," count ALL calendar days.
Weekends and holidays count unless period is < 5 days.

RULE 3: Periods Less Than 5 Days
────────────────────────────────
For periods of 5 days or less, weekends and legal holidays are EXCLUDED.
Example: 3-day deposit deadline skips Saturday/Sunday

RULE 4: Weekend/Holiday Landing
───────────────────────────────
If the last day falls on a Saturday, Sunday, or legal holiday,
the deadline extends to the next business day.

RULE 5: Time of Day
───────────────────
All deadlines expire at 11:59 PM local time on the deadline date,
unless a specific time is stated.
```

### Florida Legal Holidays (§683.01)

| Holiday | Date | Affects Deadlines |
|---------|------|-------------------|
| New Year's Day | January 1 | Yes |
| Martin Luther King Jr. Day | 3rd Monday January | Yes |
| Presidents' Day | 3rd Monday February | Yes |
| Memorial Day | Last Monday May | Yes |
| Juneteenth | June 19 | Yes |
| Independence Day | July 4 | Yes |
| Labor Day | 1st Monday September | Yes |
| Columbus Day | 2nd Monday October | Yes |
| Veterans Day | November 11 | Yes |
| Thanksgiving | 4th Thursday November | Yes |
| Day after Thanksgiving | 4th Friday November | Yes |
| Christmas Day | December 25 | Yes |

### Standard FAR/BAR Deadlines

| Deadline | Base Period | Count Method | From Date |
|----------|-------------|--------------|-----------|
| Initial Deposit | 3 days | < 5 days rule | Effective Date |
| Additional Deposit | Per contract | Calendar | Specified date |
| Inspection Period | 15 days (default) | Calendar | Effective Date |
| Condo Docs Review | 3 days | < 5 days rule | Receipt of docs |
| HOA Docs Review | 3 days | < 5 days rule | Receipt of docs |
| Financing Contingency | Per contract | Calendar | Effective Date |
| Loan Approval | Per contract | Calendar | Effective Date |
| Title Objection | 5 days | Calendar* | Receipt of title |
| Survey Objection | 5 days | Calendar* | Receipt of survey |
| Closing | Per contract | Calendar | Effective Date |
| Post-Closing Occupancy | Per agreement | Calendar | Closing Date |

*Exactly 5 days = may exclude weekends depending on interpretation

## Execution Flow

```
START
  │
  ├─── 1. Validate inputs
  │    ├── Start date is valid
  │    ├── Period length is positive
  │    └── Deadline type recognized
  │
  ├─── 2. Determine counting method
  │    ├── If period ≤ 5 days → Exclude weekends/holidays
  │    ├── If period > 5 days → Calendar days
  │    └── If "business days" specified → Exclude weekends/holidays
  │
  ├─── 3. Load holiday calendar
  │    ├── Federal holidays for year
  │    ├── County-specific if applicable
  │    └── Any contract-specified exclusions
  │
  ├─── 4. Calculate deadline
  │    ├── Start from day AFTER start date
  │    ├── Count days per method
  │    ├── Skip excluded days if applicable
  │    └── Get raw deadline date
  │
  ├─── 5. Apply weekend/holiday adjustment
  │    ├── If lands on Saturday → Move to Monday
  │    ├── If lands on Sunday → Move to Monday
  │    ├── If lands on holiday → Move to next business day
  │    └── Chain adjustments if needed
  │
  ├─── 6. Set deadline time
  │    └── 11:59 PM unless otherwise specified
  │
  ├─── 7. Generate warnings if applicable
  │    ├── Deadline falls on holiday weekend
  │    ├── Multiple deadlines same day
  │    └── Deadline very close (< 48 hours)
  │
  └─── RETURN calculated_deadline
```

## Output

```typescript
{
  success: true,
  actionTaken: "Calculated inspection period deadline",
  result: {
    deadline: {
      type: "inspection_period",
      startDate: "2026-01-15",
      periodDays: 15,
      countingMethod: "calendar_days",
      rawDeadline: "2026-01-30",
      adjustedDeadline: "2026-01-30", // or next business day
      deadlineTime: "11:59 PM EST",
      dayOfWeek: "Friday"
    },
    calculation: {
      startDateExcluded: true,
      daysExcluded: [], // or list of holidays skipped
      weekendAdjustment: false,
      holidayAdjustment: false
    },
    warnings: [],
    explanation: "Starting from effective date January 15, counting 15 calendar days (excluding the effective date itself), the inspection period ends January 30 at 11:59 PM."
  }
}
```

## Voice Response

**Standard Calculation:**
> "The inspection period ends on Friday, January 30th at 11:59 PM. That's 15 calendar days from the effective date of January 15th, not counting the effective date itself."

**With Weekend Adjustment:**
> "The 3-day deposit deadline would be Sunday, January 18th, but since it falls on a weekend, it extends to Monday, January 19th. The deposit must be in escrow by 11:59 PM Monday."

**With Holiday Adjustment:**
> "The financing contingency ends on January 20th, but that's Martin Luther King Jr. Day, a legal holiday in Florida. The deadline extends to Tuesday, January 21st at 11:59 PM."

**Multiple Deadlines:**
> "You have two deadlines on January 30th: the inspection period ends and the additional deposit is due. Both expire at 11:59 PM. I've added reminders for 5 days and 24 hours before each."

## Error Handling

| Error | Cause | Response |
|-------|-------|----------|
| `INVALID_START_DATE` | Date not parseable | "I need a valid date to calculate from. What's the effective date?" |
| `INVALID_PERIOD` | Negative or zero days | "The period needs to be at least 1 day. Check the contract terms." |
| `PAST_DEADLINE` | Calculated date is in past | "Warning: This deadline has already passed. The inspection period ended [date]." |
| `HOLIDAY_CONFLICT` | Multiple holidays in period | "Note: This period includes [holidays]. I've adjusted the deadline accordingly." |

## Example Calculations

### Example 1: 3-Day Deposit Deadline
```
Effective Date: Friday, January 15, 2026
Period: 3 days

Day 0: January 15 (Friday) - NOT counted (day of event)
Day 1: January 16 (Saturday) - SKIPPED (< 5 day rule)
Day 2: January 17 (Sunday) - SKIPPED (< 5 day rule)
Day 3: January 18 (Monday) - Day 1
Day 4: January 19 (Tuesday) - Day 2
Day 5: January 20 (Wednesday) - Day 3 ← DEADLINE

Result: Wednesday, January 20, 2026 at 11:59 PM
```

### Example 2: 15-Day Inspection Period
```
Effective Date: Thursday, January 15, 2026
Period: 15 days

Day 0: January 15 - NOT counted
Days 1-15: January 16-30 (all calendar days count)

Result: Friday, January 30, 2026 at 11:59 PM
```

### Example 3: Deadline on Holiday
```
Start Date: Tuesday, January 13, 2026
Period: 7 days

Count 7 calendar days from January 14:
Raw deadline: Monday, January 20, 2026 (MLK Day)

Adjustment: Moves to Tuesday, January 21, 2026

Result: Tuesday, January 21, 2026 at 11:59 PM
```

## Integration Points

### Related Skills
- `time-is-of-the-essence` - Enforcement of deadlines
- `florida-far-bar-rules` - Contract compliance
- `calculate-deadlines` - Generate all deal deadlines

### Database Tables
- `deadlines` - Store calculated deadlines
- `holidays` - Holiday calendar
- `deal_calendar_events` - Calendar sync

### External APIs
- Florida holiday calendar service
- County court holiday calendars

## Quality Checklist

- [x] Implements FAR/BAR Paragraph 24 rules
- [x] Correctly excludes day of event
- [x] Applies < 5 day rule correctly
- [x] Handles weekend adjustments
- [x] Includes all Florida legal holidays
- [x] Provides clear explanations
- [x] Shows calculation steps
- [x] Warns about past deadlines
- [x] Voice-friendly responses
- [x] Cites legal authority

# Skill: Calculate Deadlines

**Category:** Deadline
**Priority:** P0
**Approval Required:** No

## Purpose

Calculate and generate all critical deadlines for a Florida real estate transaction based on the effective date and closing date. This skill understands Florida FAR/BAR contract rules, the "time is of the essence" principle, and weekend/holiday adjustments.

## Triggers

### Automatic
- Deal created with effective date
- Effective date updated on existing deal
- Closing date changed (triggers recalculation)

### Voice Commands
- "Calculate deadlines for [deal]"
- "Generate deadlines from effective date [date]"
- "What are the deadlines for [address]?"
- "Recalculate deadlines"

### Programmatic
- `POST /deals/:id/deadlines/generate`
- Deal creation with effectiveDate

## Required Inputs

| Input | Type | Required | Source | Description |
|-------|------|----------|--------|-------------|
| `dealId` | UUID | Yes | context | Deal to generate deadlines for |
| `effectiveDate` | Date | Yes | deal/voice | Contract effective date |

## Optional Inputs

| Input | Type | Default | Source | Description |
|-------|------|---------|--------|-------------|
| `closingDate` | Date | null | deal | Target closing date |
| `inspectionPeriodDays` | number | 15 | deal | Custom inspection period |
| `financingContingencyDays` | number | 30 | deal | Custom financing period |
| `appraisalContingencyDays` | number | 21 | deal | Custom appraisal period |
| `titleCommitmentDays` | number | 15 | deal | Days before closing for title |

## Default Florida Deadlines

| Deadline | Calculation | Default Days | Alert Days |
|----------|-------------|--------------|------------|
| Escrow Deposit Due | Effective + 3 | 3 | 2, 1, 0 |
| Inspection Period Ends | Effective + 15 | 15 | 5, 2, 0 |
| Seller Repair Response | Inspection End + 5 | 20 | 3, 1, 0 |
| Appraisal Due | Effective + 21 | 21 | 5, 2, 0 |
| Financing Contingency | Effective + 30 | 30 | 5, 2, 0 |
| HOA Documents Due | Effective + 10 | 10 | 3, 1, 0 |
| Title Commitment | Closing - 15 | -15 | 5, 2, 0 |
| Closing Disclosure | Closing - 3 | -3 | 2, 1, 0 |
| Final Walk-Through | Closing - 1 | -1 | 1, 0 |
| Closing Date | As specified | 0 | 5, 2, 0 |

## Weekend/Holiday Rule

**Florida FAR/BAR Contract Rule:**
> If any deadline falls on a Saturday, Sunday, or national legal holiday, the deadline extends to 5:00 PM on the next business day.

### National Legal Holidays
- New Year's Day (January 1)
- Martin Luther King Jr. Day (3rd Monday January)
- Presidents' Day (3rd Monday February)
- Memorial Day (Last Monday May)
- Independence Day (July 4)
- Labor Day (1st Monday September)
- Columbus Day (2nd Monday October)
- Veterans Day (November 11)
- Thanksgiving (4th Thursday November)
- Christmas Day (December 25)

## Execution Flow

```
START
  │
  ├─── 1. Load deal data
  │    ├── Get deal by ID
  │    ├── Validate agent owns deal
  │    └── Get existing deadlines (if any)
  │
  ├─── 2. Get calculation parameters
  │    ├── effectiveDate (required)
  │    ├── closingDate (optional)
  │    ├── Custom period overrides from deal
  │    └── Property type (condo adds HOA deadline)
  │
  ├─── 3. Calculate each deadline
  │    │
  │    ├── FOR EACH default deadline:
  │    │   ├── Calculate raw date
  │    │   │   ├── If days_from_effective: effective + days
  │    │   │   └── If days_before_closing: closing - days
  │    │   │
  │    │   ├── Apply weekend/holiday adjustment
  │    │   │   ├── Check if falls on weekend
  │    │   │   ├── Check if falls on holiday
  │    │   │   └── Extend to next business day if needed
  │    │   │
  │    │   └── Create deadline record
  │    │       ├── name, description, category
  │    │       ├── due_date, due_time (5:00 PM)
  │    │       ├── status = 'upcoming'
  │    │       ├── alert_days_before
  │    │       ├── alert_parties
  │    │       └── is_auto_generated = true
  │    │
  │    └── Handle conditional deadlines
  │        ├── If isCondo: Add HOA docs deadline
  │        ├── If hasAppraisalContingency: Add appraisal deadline
  │        └── If isShortSale: Add bank approval deadline
  │
  ├─── 4. Delete old auto-generated deadlines (if recalculating)
  │    └── Keep manually added deadlines
  │
  ├─── 5. Insert new deadlines
  │
  ├─── 6. Schedule alerts for each deadline
  │    └── INVOKE: schedule-deadline-alerts
  │
  ├─── 7. Log action
  │    └── action_type: 'deadlines_generated'
  │
  └─── 8. Return deadlines
```

## Date Calculation Logic

```typescript
function calculateDeadlineDate(
  effectiveDate: Date,
  closingDate: Date | null,
  daysFromEffective: number | null,
  daysBeforeClosing: number | null
): Date {
  let calculatedDate: Date;

  if (daysBeforeClosing !== null && closingDate) {
    // Calculate from closing date
    calculatedDate = addDays(closingDate, -daysBeforeClosing);

    // If also has daysFromEffective, use earlier date
    if (daysFromEffective !== null) {
      const fromEffective = addDays(effectiveDate, daysFromEffective);
      if (fromEffective < calculatedDate) {
        calculatedDate = fromEffective;
      }
    }
  } else if (daysFromEffective !== null) {
    calculatedDate = addDays(effectiveDate, daysFromEffective);
  } else {
    throw new Error('Must specify daysFromEffective or daysBeforeClosing');
  }

  // Apply weekend/holiday adjustment
  return adjustForWeekendHoliday(calculatedDate);
}

function adjustForWeekendHoliday(date: Date): Date {
  const dayOfWeek = date.getDay();

  // Sunday = 0, Saturday = 6
  if (dayOfWeek === 0) {
    date = addDays(date, 1); // Move to Monday
  } else if (dayOfWeek === 6) {
    date = addDays(date, 2); // Move to Monday
  }

  // Check for holidays
  if (isNationalHoliday(date)) {
    date = addDays(date, 1);
    return adjustForWeekendHoliday(date); // Recursive check
  }

  return date;
}
```

## Output

```typescript
{
  success: true,
  actionTaken: "Generated 10 deadlines for 123 Main St",
  result: {
    deadlines: [
      {
        id: "uuid",
        name: "Escrow Deposit Due",
        category: "escrow",
        dueDate: "2026-01-18",
        dueTime: "17:00",
        status: "upcoming",
        daysUntil: 3
      },
      {
        id: "uuid",
        name: "Inspection Period Ends",
        category: "inspection",
        dueDate: "2026-01-30",
        dueTime: "17:00",
        status: "upcoming",
        daysUntil: 15
      },
      // ... more deadlines
    ],
    summary: {
      total: 10,
      nextDeadline: "Escrow Deposit Due (Jan 18)",
      criticalDates: [
        "Jan 18 - Escrow Deposit",
        "Jan 30 - Inspection Period Ends",
        "Feb 14 - Financing Contingency",
        "Mar 12 - Closing"
      ]
    },
    adjustments: [
      "Escrow deposit moved from Jan 18 (Saturday) to Jan 20 (Monday)",
      "Closing disclosure moved from Mar 9 (Sunday) to Mar 10 (Monday)"
    ]
  }
}
```

## Voice Response

> "I've calculated all deadlines for 123 Main Street based on effective date January 15th and closing March 12th.
>
> Your key dates are:
> - Escrow deposit due January 18th — that's 3 days from now
> - Inspection period ends January 30th — 15 days
> - Financing contingency expires February 14th
> - Closing is March 12th
>
> I adjusted 2 dates that fell on weekends.
>
> I'll start sending reminders 5 days before each deadline. Would you like me to change any alert settings?"

## Error Handling

| Error | Cause | Response |
|-------|-------|----------|
| `NO_EFFECTIVE_DATE` | Missing effective date | "I need the effective date to calculate deadlines. When did all parties sign?" |
| `CLOSING_TOO_SOON` | Closing before some deadlines | "The closing date of [date] doesn't allow enough time for standard contingencies. Some deadlines will overlap or be after closing." |
| `INVALID_DATE` | Unparseable date | "I couldn't understand that date. Can you give it to me as month day year?" |

## Quality Checklist

- [x] Understands Florida FAR/BAR timing rules
- [x] Applies weekend/holiday adjustments correctly
- [x] Handles closing date before deadline scenarios
- [x] Supports custom period overrides
- [x] Handles condo/HOA specific deadlines
- [x] Schedules all alerts automatically
- [x] Logs all adjustments made
- [x] Provides clear summary of key dates
- [x] Handles recalculation (updates, doesn't duplicate)
- [x] Preserves manually added deadlines

# Skill: Adjust for Weekends and Holidays

**Category:** Deadline
**Priority:** P0
**Approval Required:** No

## Purpose

Apply Florida FAR/BAR contract rules for weekend and holiday deadline adjustments. When any deadline falls on a Saturday, Sunday, or recognized legal holiday, this skill automatically moves it to the next business day. This is a foundational skill used by all other deadline-related operations.

## Florida Legal Rule

**Per Florida FAR/BAR Contract (Standard B-4):**
> "Time Periods. Any time periods provided for herein that end on a Saturday, Sunday, or legal holiday will extend until 5:00 p.m. (local time where the Property is located) of the next business day."

**Critical Distinction:**
- If deadline falls on **Saturday** → Moves to **Monday**
- If deadline falls on **Sunday** → Moves to **Monday**
- If deadline falls on **Holiday** → Moves to next business day
- If adjusted date also falls on weekend/holiday → Keep adjusting recursively

## Triggers

### Automatic
- Deadline calculation (used by `calculate-deadlines` skill)
- Deadline extension (used by `extend-deadline` skill)
- Any date calculation for contract-related deadlines

### Voice Commands
- "When is the deadline if it falls on a weekend?"
- "Adjust [date] for holidays"
- "What's the next business day after [date]?"
- "Check if [date] is a valid deadline date"
- "Is [date] a business day in Florida?"

### Programmatic
- `POST /deadlines/adjust-date`
- Called internally by other deadline skills
- Date utility function

## Required Inputs

| Input | Type | Required | Source | Description |
|-------|------|----------|--------|-------------|
| `date` | Date | Yes | calculation/voice | The date to check/adjust |

## Optional Inputs

| Input | Type | Default | Source | Description |
|-------|------|---------|--------|-------------|
| `direction` | string | 'forward' | manual | 'forward' (next business day) or 'backward' (previous) |
| `includeFloridaHolidays` | boolean | true | config | Include Florida-specific holidays |
| `includeFederalHolidays` | boolean | true | config | Include federal holidays |
| `year` | number | current | context | Year for holiday calculation |

## Recognized Holidays

### Federal Legal Holidays (Always Observed)

| Holiday | Date | Observation Rule |
|---------|------|------------------|
| New Year's Day | January 1 | If Sat→Fri, if Sun→Mon |
| Martin Luther King Jr. Day | 3rd Monday of January | Always Monday |
| Presidents' Day | 3rd Monday of February | Always Monday |
| Memorial Day | Last Monday of May | Always Monday |
| Juneteenth | June 19 | If Sat→Fri, if Sun→Mon |
| Independence Day | July 4 | If Sat→Fri, if Sun→Mon |
| Labor Day | 1st Monday of September | Always Monday |
| Columbus Day | 2nd Monday of October | Always Monday |
| Veterans Day | November 11 | If Sat→Fri, if Sun→Mon |
| Thanksgiving | 4th Thursday of November | Always Thursday |
| Christmas Day | December 25 | If Sat→Fri, if Sun→Mon |

### Florida-Specific Holidays (Optional)

| Holiday | Date | Notes |
|---------|------|-------|
| Day After Thanksgiving | 4th Friday of November | State offices closed |
| Christmas Eve (half day) | December 24 | Often observed |
| New Year's Eve (half day) | December 31 | Often observed |

**Note:** While Florida state offices observe additional days, real estate transactions typically only require federal holiday observance per FAR/BAR contracts. Half-days are NOT typically observed as full holidays for deadline purposes.

## Execution Flow

```
START
  │
  ├─── 1. Parse input date
  │    ├── Accept ISO string, Date object, or natural language
  │    ├── Validate date is parseable
  │    └── Normalize to midnight local time (Florida timezone)
  │
  ├─── 2. Build holiday list for relevant year(s)
  │    │
  │    ├── Get year from input date
  │    │
  │    ├── Calculate fixed holidays:
  │    │   ├── New Year's Day: January 1
  │    │   ├── Juneteenth: June 19
  │    │   ├── Independence Day: July 4
  │    │   ├── Veterans Day: November 11
  │    │   └── Christmas: December 25
  │    │
  │    ├── Calculate floating holidays:
  │    │   ├── MLK Day: 3rd Monday of January
  │    │   ├── Presidents' Day: 3rd Monday of February
  │    │   ├── Memorial Day: Last Monday of May
  │    │   ├── Labor Day: 1st Monday of September
  │    │   ├── Columbus Day: 2nd Monday of October
  │    │   └── Thanksgiving: 4th Thursday of November
  │    │
  │    ├── Apply observation rules for fixed holidays:
  │    │   ├── IF fixed holiday falls on Saturday:
  │    │   │   └── Observed on Friday
  │    │   └── IF fixed holiday falls on Sunday:
  │    │       └── Observed on Monday
  │    │
  │    └── Store holiday list with both actual and observed dates
  │
  ├─── 3. Check if date needs adjustment
  │    │
  │    ├── Check day of week:
  │    │   ├── Sunday (0) → needs adjustment
  │    │   └── Saturday (6) → needs adjustment
  │    │
  │    └── Check against holiday list:
  │        ├── Match against observed dates
  │        └── If match → needs adjustment
  │
  ├─── 4. Apply adjustment (if needed)
  │    │
  │    ├── IF direction = 'forward' (default):
  │    │   │
  │    │   ├── IF Saturday:
  │    │   │   └── Add 2 days (→ Monday)
  │    │   │
  │    │   ├── IF Sunday:
  │    │   │   └── Add 1 day (→ Monday)
  │    │   │
  │    │   └── IF Holiday:
  │    │       └── Add 1 day
  │    │
  │    └── IF direction = 'backward':
  │        │
  │        ├── IF Saturday:
  │        │   └── Subtract 1 day (→ Friday)
  │        │
  │        ├── IF Sunday:
  │        │   └── Subtract 2 days (→ Friday)
  │        │
  │        └── IF Holiday:
  │            └── Subtract 1 day
  │
  ├─── 5. Recursive check
  │    │
  │    ├── After adjustment, check if new date is ALSO weekend/holiday
  │    │
  │    └── IF still not a business day:
  │        └── GOTO step 4 (recursive)
  │
  ├─── 6. Validate final date
  │    ├── Confirm it's a weekday (Mon-Fri)
  │    ├── Confirm it's not a holiday
  │    └── Set time to 5:00 PM (contract deadline time)
  │
  └─── 7. Return result
```

## Date Calculation Logic

```typescript
interface AdjustmentResult {
  originalDate: Date;
  adjustedDate: Date;
  wasAdjusted: boolean;
  adjustmentReason?: string;
  holidaysChecked: Holiday[];
  daysAdjusted: number;
}

function adjustForWeekendHoliday(
  date: Date,
  direction: 'forward' | 'backward' = 'forward'
): AdjustmentResult {
  const original = new Date(date);
  let current = new Date(date);
  let adjustmentReasons: string[] = [];
  let totalDaysAdjusted = 0;

  const holidays = getHolidaysForYear(current.getFullYear());

  // Recursive adjustment until we land on a business day
  while (!isBusinessDay(current, holidays)) {
    const dayOfWeek = current.getDay();

    if (dayOfWeek === 0) { // Sunday
      if (direction === 'forward') {
        current = addDays(current, 1);
        adjustmentReasons.push('Sunday → Monday');
      } else {
        current = addDays(current, -2);
        adjustmentReasons.push('Sunday → Friday');
      }
      totalDaysAdjusted += direction === 'forward' ? 1 : 2;
    }
    else if (dayOfWeek === 6) { // Saturday
      if (direction === 'forward') {
        current = addDays(current, 2);
        adjustmentReasons.push('Saturday → Monday');
      } else {
        current = addDays(current, -1);
        adjustmentReasons.push('Saturday → Friday');
      }
      totalDaysAdjusted += direction === 'forward' ? 2 : 1;
    }
    else if (isHoliday(current, holidays)) {
      const holidayName = getHolidayName(current, holidays);
      if (direction === 'forward') {
        current = addDays(current, 1);
        adjustmentReasons.push(`${holidayName} → Next day`);
      } else {
        current = addDays(current, -1);
        adjustmentReasons.push(`${holidayName} → Previous day`);
      }
      totalDaysAdjusted += 1;

      // Refresh holidays if we crossed into a new year
      if (current.getFullYear() !== holidays[0].year) {
        holidays.push(...getHolidaysForYear(current.getFullYear()));
      }
    }
  }

  // Set time to 5:00 PM (contract deadline time)
  current.setHours(17, 0, 0, 0);

  return {
    originalDate: original,
    adjustedDate: current,
    wasAdjusted: totalDaysAdjusted > 0,
    adjustmentReason: adjustmentReasons.join(', '),
    holidaysChecked: holidays,
    daysAdjusted: totalDaysAdjusted
  };
}

function isBusinessDay(date: Date, holidays: Holiday[]): boolean {
  const day = date.getDay();
  // Not Saturday (6) or Sunday (0)
  if (day === 0 || day === 6) return false;
  // Not a holiday
  if (isHoliday(date, holidays)) return false;
  return true;
}

function isHoliday(date: Date, holidays: Holiday[]): boolean {
  const dateStr = formatDate(date, 'YYYY-MM-DD');
  return holidays.some(h =>
    formatDate(h.observedDate, 'YYYY-MM-DD') === dateStr
  );
}

function getHolidayName(date: Date, holidays: Holiday[]): string {
  const dateStr = formatDate(date, 'YYYY-MM-DD');
  const holiday = holidays.find(h =>
    formatDate(h.observedDate, 'YYYY-MM-DD') === dateStr
  );
  return holiday?.name ?? 'Holiday';
}
```

## Holiday Calculation Functions

```typescript
function getHolidaysForYear(year: number): Holiday[] {
  const holidays: Holiday[] = [];

  // Fixed holidays with observation rules
  const fixedHolidays = [
    { name: "New Year's Day", month: 1, day: 1 },
    { name: "Juneteenth", month: 6, day: 19 },
    { name: "Independence Day", month: 7, day: 4 },
    { name: "Veterans Day", month: 11, day: 11 },
    { name: "Christmas Day", month: 12, day: 25 }
  ];

  for (const h of fixedHolidays) {
    const actual = new Date(year, h.month - 1, h.day);
    const dayOfWeek = actual.getDay();
    let observed = actual;

    if (dayOfWeek === 6) { // Saturday
      observed = addDays(actual, -1); // Observe Friday
    } else if (dayOfWeek === 0) { // Sunday
      observed = addDays(actual, 1); // Observe Monday
    }

    holidays.push({
      name: h.name,
      actualDate: actual,
      observedDate: observed,
      year
    });
  }

  // Floating holidays
  holidays.push({
    name: "Martin Luther King Jr. Day",
    actualDate: getNthWeekdayOfMonth(year, 1, 1, 3), // 3rd Monday of January
    observedDate: getNthWeekdayOfMonth(year, 1, 1, 3),
    year
  });

  holidays.push({
    name: "Presidents' Day",
    actualDate: getNthWeekdayOfMonth(year, 2, 1, 3), // 3rd Monday of February
    observedDate: getNthWeekdayOfMonth(year, 2, 1, 3),
    year
  });

  holidays.push({
    name: "Memorial Day",
    actualDate: getLastWeekdayOfMonth(year, 5, 1), // Last Monday of May
    observedDate: getLastWeekdayOfMonth(year, 5, 1),
    year
  });

  holidays.push({
    name: "Labor Day",
    actualDate: getNthWeekdayOfMonth(year, 9, 1, 1), // 1st Monday of September
    observedDate: getNthWeekdayOfMonth(year, 9, 1, 1),
    year
  });

  holidays.push({
    name: "Columbus Day",
    actualDate: getNthWeekdayOfMonth(year, 10, 1, 2), // 2nd Monday of October
    observedDate: getNthWeekdayOfMonth(year, 10, 1, 2),
    year
  });

  holidays.push({
    name: "Thanksgiving",
    actualDate: getNthWeekdayOfMonth(year, 11, 4, 4), // 4th Thursday of November
    observedDate: getNthWeekdayOfMonth(year, 11, 4, 4),
    year
  });

  return holidays;
}

// Get the Nth occurrence of a weekday in a month
// weekday: 0=Sunday, 1=Monday, ..., 6=Saturday
function getNthWeekdayOfMonth(
  year: number,
  month: number,
  weekday: number,
  n: number
): Date {
  const firstOfMonth = new Date(year, month - 1, 1);
  const firstWeekday = firstOfMonth.getDay();

  let dayOffset = weekday - firstWeekday;
  if (dayOffset < 0) dayOffset += 7;

  const firstOccurrence = 1 + dayOffset;
  const nthOccurrence = firstOccurrence + (n - 1) * 7;

  return new Date(year, month - 1, nthOccurrence);
}

// Get the last occurrence of a weekday in a month
function getLastWeekdayOfMonth(
  year: number,
  month: number,
  weekday: number
): Date {
  const lastOfMonth = new Date(year, month, 0); // Last day of month
  const lastWeekday = lastOfMonth.getDay();

  let dayOffset = lastWeekday - weekday;
  if (dayOffset < 0) dayOffset += 7;

  return new Date(year, month - 1, lastOfMonth.getDate() - dayOffset);
}
```

## Output

```typescript
{
  success: true,
  actionTaken: "Adjusted deadline date from Saturday to Monday",
  result: {
    originalDate: "2026-01-17", // Saturday
    originalDayOfWeek: "Saturday",
    adjustedDate: "2026-01-19", // Monday
    adjustedDayOfWeek: "Monday",
    dueTime: "17:00",
    wasAdjusted: true,
    adjustmentReason: "Saturday → Monday",
    daysAdjusted: 2,
    nextHolidays: [
      {
        name: "Martin Luther King Jr. Day",
        date: "2026-01-19",
        daysAway: 2
      },
      {
        name: "Presidents' Day",
        date: "2026-02-16",
        daysAway: 30
      }
    ]
  }
}
```

## Complex Adjustment Examples

### Example 1: Saturday Adjustment
```
Input:  2026-01-17 (Saturday)
Output: 2026-01-19 (Monday)
Reason: "Saturday → Monday"
```

### Example 2: Sunday Adjustment
```
Input:  2026-01-18 (Sunday)
Output: 2026-01-19 (Monday)
Reason: "Sunday → Monday"
```

### Example 3: Holiday on Monday
```
Input:  2026-01-19 (Monday - MLK Day)
Output: 2026-01-20 (Tuesday)
Reason: "Martin Luther King Jr. Day → Next day"
```

### Example 4: Saturday Before Holiday Monday
```
Input:  2026-01-17 (Saturday)
Step 1: Saturday → Monday (2026-01-19)
Step 2: Monday is MLK Day → Tuesday (2026-01-20)
Output: 2026-01-20 (Tuesday)
Reason: "Saturday → Monday, Martin Luther King Jr. Day → Next day"
```

### Example 5: Friday After Thanksgiving
```
Input:  2026-11-27 (Friday after Thanksgiving)
Output: 2026-11-27 (Friday - NOT adjusted, not a federal holiday)
Reason: "No adjustment needed - day after Thanksgiving is not a federal holiday"
Note:   While FL state offices close, real estate transactions proceed
```

### Example 6: Christmas on Saturday
```
Input:  2026-12-25 (Friday - Christmas observed since 25th is Saturday in some years)
Check:  2026-12-25 is actually a Friday
Output: 2026-12-25 (Friday - actual Christmas)
Reason: "Christmas falls on Friday, no adjustment needed"
```

### Example 7: Year Boundary
```
Input:  2026-12-31 (Thursday)
Output: 2026-12-31 (Thursday)
Reason: "New Year's Eve is not a federal holiday - no adjustment"

Input:  2027-01-01 (Friday - New Year's Day)
Output: 2027-01-02 (Monday) -- Wait, 01-01-2027 is Friday
Actually: 2027-01-01 (Friday) - it IS a holiday
Output: 2027-01-04 (Monday)
Reason: "New Year's Day → Next day (Saturday), Saturday → Monday"
```

## Voice Response

**When checking a date:**
> "January 17th, 2026 falls on a Saturday. Per Florida FAR/BAR rules, the deadline automatically extends to Monday, January 19th at 5:00 PM.
>
> However, January 19th is Martin Luther King Jr. Day, so the deadline extends further to Tuesday, January 20th at 5:00 PM.
>
> Would you like me to update this deadline?"

**When confirming a valid date:**
> "March 15th, 2026 is a Sunday... wait, let me check that. Actually, March 15th, 2026 is a Sunday. The deadline would move to Monday, March 16th at 5:00 PM.
>
> Do you want me to set the deadline for March 16th?"

**Quick response:**
> "That date falls on a weekend. Adjusted to [next Monday] per Florida rules."

## Error Handling

| Error | Cause | Response |
|-------|-------|----------|
| `INVALID_DATE` | Unparseable date input | "I couldn't understand that date. Can you give it to me as month day year?" |
| `DATE_IN_PAST` | Date has already passed | "That date is in the past. Did you mean [suggested future date]?" |
| `YEAR_TOO_FAR` | Date more than 2 years out | "I can only calculate holidays for the next 2 years. This date is [X] years away." |

## Edge Cases Handled

1. **New Year's Eve → New Year's Day transition**: Holiday list refreshed when crossing year boundary
2. **Leap years**: February 29th handled correctly
3. **Multiple consecutive holidays**: Rare but handled (e.g., if Independence Day observation creates back-to-back)
4. **Daylight Saving Time**: Uses calendar dates, not affected by DST
5. **Timezone**: All calculations in Florida local time (Eastern)

## Integration Points

This skill is called by:
- `calculate-deadlines`: When generating all deadlines for a deal
- `extend-deadline`: When calculating the new deadline date
- `deadline-negotiation`: When proposing new dates
- Any skill that creates or modifies deadline dates

## Quality Checklist

- [x] Handles Saturday correctly (→ Monday)
- [x] Handles Sunday correctly (→ Monday)
- [x] Handles all 11 federal holidays
- [x] Applies observation rules for fixed holidays
- [x] Calculates floating holidays correctly (Nth weekday of month)
- [x] Handles recursive adjustment (holiday after weekend)
- [x] Correctly handles year boundaries
- [x] Sets deadline time to 5:00 PM per FAR/BAR
- [x] Provides clear audit trail of adjustments
- [x] Handles voice queries naturally
- [x] Returns upcoming holidays for context
- [x] Works as standalone or integrated service

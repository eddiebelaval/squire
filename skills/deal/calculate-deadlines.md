# Skill: Calculate Deadlines

**Category:** Deal
**Priority:** P0
**Approval Required:** No

## Purpose

Automatically generate all critical deadlines for a Florida real estate transaction based on the effective date and contract terms. This skill applies Florida-specific rules, holiday calendars, and contract provisions to create an accurate deadline schedule.

## Triggers

### Voice Commands
- "Calculate deadlines for [address]"
- "Generate deadlines from effective date [date]"
- "What are the deadlines for [address]?"
- "Set up timeline for [address]"
- "When are the deadlines for [address]?"
- "Recalculate deadlines for [address]"

### Programmatic
- Effective date set on deal (auto-trigger)
- Contract parsed with effective date
- Amendment changes dates (recalculate)
- API call to `/deals/{id}/calculate-deadlines`
- Extension processed

## Required Inputs

| Input | Type | Required | Source | Description |
|-------|------|----------|--------|-------------|
| `dealId` | UUID | Yes* | context | Deal to calculate for |
| `effectiveDate` | Date | Yes | contract/voice | Contract effective date |

*If dealId provided, can load contract terms from deal

## Optional Inputs

| Input | Type | Default | Source | Description |
|-------|------|---------|--------|-------------|
| `closingDate` | Date | null | contract | If specified in contract |
| `inspectionPeriodDays` | number | 15 | contract | Days for inspection |
| `financingContingencyDays` | number | 30 | contract | Days for financing |
| `escrowDueDays` | number | 3 | contract | Days until escrow due |
| `additionalDepositDays` | number | 10 | contract | Days until additional deposit |
| `hoaApprovalDays` | number | 30 | contract | Days for HOA approval |
| `condoDocReviewDays` | number | 3 | contract | Days to review condo docs |
| `walkThroughDays` | number | -1 | contract | Days before closing for walkthrough |
| `financingType` | string | 'conventional' | contract | Affects loan deadlines |
| `isNewConstruction` | boolean | false | contract | Affects deadline types |
| `contractType` | string | 'far_bar_as_is' | contract | Standard vs AS-IS |
| `includeBusinessDaysOnly` | boolean | false | config | Calculate business days only |
| `timezone` | string | 'America/New_York' | config | Timezone for calculations |

## Florida Deadline Types

### Standard FAR/BAR Deadlines

| Deadline | Default Days | From | Business Days | Critical |
|----------|--------------|------|---------------|----------|
| Escrow Deposit | 3 | Effective | Yes (banks) | Yes |
| Additional Deposit | 10 | Effective | No | Yes |
| Inspection Period | 15 | Effective | No | Yes |
| Seller Disclosure | 3 | Effective | No | No |
| Financing Contingency | 30 | Effective | No | Yes |
| Appraisal | N/A | Lender sets | N/A | Yes |
| HOA Approval | 30 | Effective | No | Yes (if HOA) |
| Condo Doc Review | 3 | Receipt | No | Yes (if condo) |
| Loan Approval | 7 | Before closing | No | Yes |
| Clear to Close | 5 | Before closing | No | Yes |
| Final Walkthrough | 1 | Before closing | No | No |
| Closing | Contract | N/A | No | Yes |

### AS-IS Specific
- Inspection period is "informational only"
- Buyer cannot request repairs
- Deadline remains same, purpose different

## Execution Flow

```
START
  │
  ├─── 1. Validate inputs
  │    ├── Effective date is valid
  │    ├── Closing date (if provided) is after effective
  │    └── Day counts are reasonable (positive, < 365)
  │
  ├─── 2. Load deal data (if dealId provided)
  │    ├── Get existing deadline configuration
  │    ├── Get property details (HOA, condo status)
  │    ├── Get financing type
  │    └── Get contract type
  │
  ├─── 3. Load calendar data
  │    ├── Florida bank holidays
  │    ├── Federal holidays
  │    ├── Weekend days
  │    └── Any custom non-business days
  │
  ├─── 4. Calculate core deadlines
  │    │
  │    ├── ESCROW DEPOSIT
  │    │   ├── Base: effectiveDate + escrowDueDays
  │    │   ├── If weekend/holiday → next business day
  │    │   └── Note: Banks must be open
  │    │
  │    ├── ADDITIONAL DEPOSIT (if applicable)
  │    │   ├── Base: effectiveDate + additionalDepositDays
  │    │   └── Calendar days
  │    │
  │    ├── INSPECTION PERIOD
  │    │   ├── Base: effectiveDate + inspectionPeriodDays
  │    │   ├── Calendar days (exclude effective date)
  │    │   └── Mark as AS-IS if contract type = as_is
  │    │
  │    ├── FINANCING CONTINGENCY
  │    │   ├── Base: effectiveDate + financingContingencyDays
  │    │   ├── Calendar days
  │    │   └── Skip if cash transaction
  │    │
  │    └── CLOSING DATE
  │        ├── Use provided closingDate if set
  │        ├── Or estimate: effectiveDate + 45 days (typical)
  │        └── Warn if weekend (title may be closed)
  │
  ├─── 5. Calculate conditional deadlines
  │    │
  │    ├── If HOA property:
  │    │   └── HOA_APPROVAL: effectiveDate + hoaApprovalDays
  │    │
  │    ├── If Condo:
  │    │   └── CONDO_DOC_REVIEW: condoDocsReceived + condoDocReviewDays
  │    │       (or set as TBD with trigger)
  │    │
  │    └── If New Construction:
  │        └── Add construction-specific milestones
  │
  ├─── 6. Calculate closing-relative deadlines
  │    │
  │    ├── LOAN_APPROVAL: closingDate - 7 days
  │    ├── CLEAR_TO_CLOSE: closingDate - 5 days
  │    ├── FINAL_WALKTHROUGH: closingDate - 1 day
  │    └── WIRE_INSTRUCTIONS: closingDate - 3 days
  │
  ├─── 7. Calculate financing-specific deadlines
  │    │
  │    ├── If FHA:
  │    │   └── Add FHA-specific timelines
  │    │
  │    ├── If VA:
  │    │   └── Add VA-specific timelines
  │    │
  │    └── If Conventional:
  │        └── Standard timeline
  │
  ├─── 8. Apply reminder schedules
  │    ├── 7 days before: First reminder
  │    ├── 3 days before: Second reminder
  │    ├── 1 day before: Urgent reminder
  │    └── Day of: Final reminder
  │
  ├─── 9. Validate deadline logic
  │    ├── All deadlines before or on closing
  │    ├── No deadline conflicts
  │    ├── Reasonable timeline (warn if tight)
  │    └── Flag any issues
  │
  ├─── 10. Store deadlines (if dealId provided)
  │     ├── Create/update deadline records
  │     ├── Set up reminder notifications
  │     ├── Link to deal
  │     └── Mark any existing as superseded
  │
  ├─── 11. Log calculation
  │     └── action_type: 'deadlines_calculated'
  │
  └── RETURN deadline schedule
```

## Output

```typescript
{
  success: true,
  actionTaken: "Calculated 12 deadlines for 123 Main St from effective date January 15, 2026",
  result: {
    deal: {
      id: "uuid",
      propertyAddress: "123 Main St, Miami FL 33101",
      effectiveDate: "2026-01-15",
      closingDate: "2026-03-12"
    },

    summary: {
      totalDeadlines: 12,
      criticalDeadlines: 7,
      daysToClose: 56,
      firstDeadline: {
        name: "Escrow Deposit",
        date: "2026-01-18",
        daysFromNow: 3
      },
      lastDeadline: {
        name: "Closing",
        date: "2026-03-12",
        daysFromNow: 56
      }
    },

    deadlines: [
      {
        id: "dl_001",
        name: "Escrow Deposit",
        description: "Initial earnest money deposit due to escrow holder",
        date: "2026-01-18",
        daysFromEffective: 3,
        calculationMethod: "effective_date + 3 business days",
        isCritical: true,
        isContingency: false,
        category: "financial",
        owner: "buyer",
        reminderSchedule: ["2026-01-17", "2026-01-18"],
        originalDays: 3,
        adjustedForHoliday: false,
        holidayNote: null
      },
      {
        id: "dl_002",
        name: "Additional Deposit",
        description: "Additional deposit due if specified in contract",
        date: "2026-01-25",
        daysFromEffective: 10,
        calculationMethod: "effective_date + 10 calendar days",
        isCritical: true,
        isContingency: false,
        category: "financial",
        owner: "buyer",
        reminderSchedule: ["2026-01-22", "2026-01-24", "2026-01-25"],
        originalDays: 10,
        adjustedForHoliday: false,
        holidayNote: null
      },
      {
        id: "dl_003",
        name: "Inspection Period",
        description: "Period for buyer to conduct inspections (AS-IS: informational only)",
        date: "2026-01-30",
        daysFromEffective: 15,
        calculationMethod: "effective_date + 15 calendar days (exclusive of effective date)",
        isCritical: true,
        isContingency: true,
        contingencyType: "inspection",
        category: "contingency",
        owner: "buyer",
        reminderSchedule: ["2026-01-23", "2026-01-27", "2026-01-29", "2026-01-30"],
        originalDays: 15,
        adjustedForHoliday: false,
        holidayNote: null,
        asIsNote: "Contract is AS-IS. Inspection is for informational purposes only."
      },
      {
        id: "dl_004",
        name: "HOA Approval",
        description: "Deadline for HOA/Community Association approval of buyer",
        date: "2026-02-14",
        daysFromEffective: 30,
        calculationMethod: "effective_date + 30 calendar days",
        isCritical: true,
        isContingency: true,
        contingencyType: "hoa_approval",
        category: "contingency",
        owner: "buyer",
        reminderSchedule: ["2026-02-07", "2026-02-11", "2026-02-13", "2026-02-14"],
        originalDays: 30,
        adjustedForHoliday: false,
        holidayNote: null,
        conditionalNote: "Only applies if property has HOA"
      },
      {
        id: "dl_005",
        name: "Financing Contingency",
        description: "Deadline for buyer to obtain loan approval",
        date: "2026-02-14",
        daysFromEffective: 30,
        calculationMethod: "effective_date + 30 calendar days",
        isCritical: true,
        isContingency: true,
        contingencyType: "financing",
        category: "contingency",
        owner: "buyer",
        reminderSchedule: ["2026-02-07", "2026-02-11", "2026-02-13", "2026-02-14"],
        originalDays: 30,
        adjustedForHoliday: false,
        holidayNote: null
      },
      {
        id: "dl_006",
        name: "Loan Approval",
        description: "Final loan approval should be received by this date",
        date: "2026-03-05",
        daysFromClosing: -7,
        calculationMethod: "closing_date - 7 calendar days",
        isCritical: true,
        isContingency: false,
        category: "financing",
        owner: "lender",
        reminderSchedule: ["2026-03-01", "2026-03-03", "2026-03-04", "2026-03-05"],
        originalDays: null,
        adjustedForHoliday: false,
        holidayNote: null
      },
      {
        id: "dl_007",
        name: "Clear to Close",
        description: "Title and lender confirm ready to close",
        date: "2026-03-07",
        daysFromClosing: -5,
        calculationMethod: "closing_date - 5 calendar days",
        isCritical: true,
        isContingency: false,
        category: "closing",
        owner: "title_company",
        reminderSchedule: ["2026-03-04", "2026-03-06", "2026-03-07"],
        originalDays: null,
        adjustedForHoliday: false,
        holidayNote: null
      },
      {
        id: "dl_008",
        name: "Wire Instructions",
        description: "Buyer should have verified wire instructions from title company",
        date: "2026-03-09",
        daysFromClosing: -3,
        calculationMethod: "closing_date - 3 calendar days",
        isCritical: true,
        isContingency: false,
        category: "financial",
        owner: "buyer",
        reminderSchedule: ["2026-03-07", "2026-03-08", "2026-03-09"],
        originalDays: null,
        adjustedForHoliday: false,
        holidayNote: null,
        wireFraudNote: "Always verify wire instructions by phone using known number"
      },
      {
        id: "dl_009",
        name: "Final Walkthrough",
        description: "Buyer's final inspection of property before closing",
        date: "2026-03-11",
        daysFromClosing: -1,
        calculationMethod: "closing_date - 1 calendar day",
        isCritical: false,
        isContingency: false,
        category: "closing",
        owner: "buyer",
        reminderSchedule: ["2026-03-09", "2026-03-10", "2026-03-11"],
        originalDays: null,
        adjustedForHoliday: false,
        holidayNote: null
      },
      {
        id: "dl_010",
        name: "Closing",
        description: "Transaction closing date",
        date: "2026-03-12",
        daysFromEffective: 56,
        calculationMethod: "specified in contract",
        isCritical: true,
        isContingency: false,
        category: "closing",
        owner: "all_parties",
        reminderSchedule: ["2026-03-05", "2026-03-09", "2026-03-11", "2026-03-12"],
        originalDays: null,
        adjustedForHoliday: false,
        holidayNote: null
      }
    ],

    timeline: {
      weeks: [
        {
          weekOf: "2026-01-13",
          deadlines: ["Escrow Deposit"]
        },
        {
          weekOf: "2026-01-20",
          deadlines: ["Additional Deposit", "Inspection Period"]
        },
        {
          weekOf: "2026-02-10",
          deadlines: ["HOA Approval", "Financing Contingency"]
        },
        {
          weekOf: "2026-03-02",
          deadlines: ["Loan Approval", "Clear to Close"]
        },
        {
          weekOf: "2026-03-09",
          deadlines: ["Wire Instructions", "Final Walkthrough", "Closing"]
        }
      ]
    },

    warnings: [
      {
        type: "weekend_closing",
        message: "Closing date (March 12) is a Thursday - title companies are typically available",
        severity: "info"
      }
    ],

    calendar: {
      icsUrl: "/deals/uuid/calendar.ics",
      googleCalendarUrl: "https://calendar.google.com/...",
      outlookUrl: "https://outlook.live.com/..."
    },

    floridaSpecific: {
      holidaysConsidered: [
        { date: "2026-01-20", name: "Martin Luther King Jr. Day" },
        { date: "2026-02-17", name: "Presidents Day" }
      ],
      calculationMethod: "Florida standard - calendar days from effective date (exclusive)",
      escrowBusinessDays: true
    }
  }
}
```

## Voice Response

**Initial Deadline Calculation:**
> "I've calculated all the deadlines for 123 Main Street based on the effective date of January 15th.
>
> Here are your key dates:
> - Escrow deposit due: Saturday the 18th - that's 3 days
> - Inspection period ends: January 30th - 15 days
> - Financing contingency: February 14th - 30 days
> - Closing: March 12th - 56 days from now
>
> I've set up reminders for 7 days, 3 days, and 1 day before each deadline.
>
> One note: this is an AS-IS contract, so the inspection is for information only - the buyer can't request repairs.
>
> Want me to add these to your calendar?"

**Recalculating After Extension:**
> "Got it, I've recalculated the deadlines for 456 Oak Avenue with the new closing date of April 15th.
>
> Here's what changed:
> - Closing: Now April 15th (was March 30th)
> - Loan approval target: Now April 8th (was March 23rd)
> - Clear to close: Now April 10th (was March 25th)
> - Final walkthrough: Now April 14th (was March 29th)
>
> All the contingency deadlines stay the same since they were calculated from the effective date.
>
> I've updated all the reminders. Anything else?"

**Quick Deadline Check:**
> "The key deadlines for 123 Main Street are:
>
> Coming up this week:
> - Escrow deposit: January 18th (2 days)
>
> Next 2 weeks:
> - Inspection ends: January 30th (14 days)
> - Additional deposit: January 25th (9 days)
>
> Closing is March 12th, which is 56 days out.
>
> Everything is on track. Any questions about specific deadlines?"

## Error Handling

| Error | Cause | Response |
|-------|-------|----------|
| `MISSING_EFFECTIVE_DATE` | No effective date provided | "I need the effective date to calculate deadlines. When does the contract become effective?" |
| `INVALID_DATE` | Unparseable date | "I couldn't understand that date. Can you say it again like 'January 15th, 2026'?" |
| `CLOSING_BEFORE_EFFECTIVE` | Closing date is before effective | "The closing date can't be before the effective date. Can you check those dates?" |
| `UNREASONABLE_TIMELINE` | Very short or long timeline | "That's a very [short/long] timeline. Typically closings are 30-60 days. Is that correct?" |
| `DEAL_NOT_FOUND` | Invalid dealId | "I can't find that deal. Can you verify the address or deal ID?" |

## Florida Calculation Rules

### Calendar Days
- Florida contracts use calendar days (not business days) for most contingencies
- Days are counted starting the day after the effective date (effective date is Day 0)
- Example: 15-day inspection with Jan 15 effective = ends Jan 30

### Business Days (for Escrow)
- Escrow deposit typically due within 3 business days
- Excludes weekends and bank holidays
- If landing on non-business day, due next business day

### Florida Bank Holidays (2026)

| Date | Holiday |
|------|---------|
| Jan 1 | New Year's Day |
| Jan 20 | Martin Luther King Jr. Day |
| Feb 17 | Presidents Day |
| May 25 | Memorial Day |
| Jul 4 | Independence Day (observed Jul 3) |
| Sep 7 | Labor Day |
| Oct 12 | Columbus Day |
| Nov 11 | Veterans Day |
| Nov 26 | Thanksgiving Day |
| Dec 25 | Christmas Day |

### FAR/BAR Time Computation
Per FAR/BAR contract language:
- Time periods end at 11:59 PM local time on the last day
- If deadline falls on Saturday, Sunday, or national legal holiday, extended to next business day (for performance obligations)
- Written notice deadlines computed differently (specific delivery requirements)

## Example Usage

### Voice Deadline Setup
```
Agent: "Homer, calculate deadlines for the new deal at 789 Pine Lane,
        effective date January 20th, closing March 30th"

Homer: "Got it. Calculating deadlines for 789 Pine Lane:

        From effective date January 20th:
        • Escrow deposit: January 23rd (3 business days)
        • Additional deposit: January 30th (10 days)
        • Inspection period: February 4th (15 days)
        • Financing contingency: February 19th (30 days)

        Before closing March 30th:
        • Loan approval: March 23rd
        • Clear to close: March 25th
        • Final walkthrough: March 29th

        Total: 69 days from effective to closing.

        I noticed January 20th is MLK Day - should the effective
        date actually be January 21st?"

Agent: "Yes, make it the 21st"

Homer: "Updated. Effective date is now January 21st. All deadlines
        shifted by one day. Want me to add these to your calendar?"
```

### Handling Short Timeline
```
Agent: "Calculate deadlines for Oak Street, effective today,
        closing in 3 weeks"

Homer: "I can calculate that, but 21 days is a tight timeline.

        Here's the issue:
        - Standard inspection period is 15 days
        - Standard financing contingency is 30 days
        - That's more than 21 days to closing

        Options:
        1. Shorter contingency periods (risky for buyer)
        2. Cash transaction (no financing contingency)
        3. Extend closing date

        What are the contract terms?"

Agent: "It's a cash deal with 10 day inspection"

Homer: "That works better. With cash and 10-day inspection:

        • Escrow deposit: [3 business days]
        • Inspection period: [10 days]
        • Closing: [21 days]

        Timeline is tight but doable. I've flagged this deal
        as accelerated so I'll send reminders earlier than usual."
```

### Extension Request
```
Agent: "We need to extend closing on Main Street by 2 weeks"

Homer: "I'll recalculate deadlines for 123 Main Street with closing
        extended by 2 weeks.

        Current closing: March 12th
        New closing: March 26th

        Updated closing-relative deadlines:
        • Loan approval: March 19th (was March 5th)
        • Clear to close: March 21st (was March 7th)
        • Wire instructions: March 23rd (was March 9th)
        • Final walkthrough: March 25th (was March 11th)

        Contingency deadlines don't change since they're from
        the effective date.

        Should I update the deal with these new dates?"
```

## Quality Checklist

- [x] Handles voice input naturally
- [x] Calculates all standard Florida deadlines
- [x] Supports custom day counts from contract
- [x] Handles business day calculations for escrow
- [x] Accounts for Florida bank holidays
- [x] Warns about weekend closings
- [x] Supports conditional deadlines (HOA, condo)
- [x] Calculates closing-relative deadlines
- [x] Sets up reminder schedules
- [x] Validates timeline logic
- [x] Supports deadline recalculation
- [x] Exports to calendar formats
- [x] Handles AS-IS contract notation
- [x] Creates comprehensive audit log
- [x] Florida-specific calculation rules applied
- [x] Handles errors gracefully

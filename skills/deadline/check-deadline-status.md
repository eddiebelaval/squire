# Skill: Check Deadline Status

**Category:** Deadline
**Priority:** P0
**Approval Required:** No

## Purpose

Provide a comprehensive view of deadline status across one or all deals. This skill answers questions like "What's coming up?", "What's overdue?", and "What do I need to focus on today?" It serves as the central deadline intelligence hub for agents.

## Triggers

### Voice Commands
- "What deadlines are coming up?"
- "Show me all overdue deadlines"
- "What's due this week?"
- "Deadline status for [address]"
- "What do I need to handle today?"
- "Are there any urgent deadlines?"
- "What's my deadline situation?"
- "Check on the [deal/property] deadlines"
- "Give me a deadline summary"
- "Any deadlines I should worry about?"

### Automatic
- Morning briefing (8:00 AM daily summary)
- Dashboard load (fetch current status)
- After deal status change

### Programmatic
- `GET /deadlines/status`
- `GET /deals/:id/deadlines/status`
- Dashboard widget refresh

## Required Inputs

| Input | Type | Required | Source | Description |
|-------|------|----------|--------|-------------|
| `agentId` | UUID | Yes | context | Agent requesting the status |

## Optional Inputs

| Input | Type | Default | Source | Description |
|-------|------|---------|--------|-------------|
| `dealId` | UUID | null | voice/context | Filter to specific deal |
| `propertyAddress` | string | null | voice | Find deal by address |
| `dateRange` | object | 7 days | voice | { start: Date, end: Date } |
| `status` | string[] | all | voice | Filter: 'upcoming', 'overdue', 'today', 'completed' |
| `category` | string[] | all | voice | Filter by deadline category |
| `severity` | string[] | all | voice | Filter: 'critical', 'high', 'medium', 'low' |
| `limit` | number | 20 | config | Max deadlines to return |
| `groupBy` | string | 'deal' | voice | 'deal', 'date', 'category', 'status' |

## Deadline Status Definitions

| Status | Definition | Visual |
|--------|------------|--------|
| `overdue` | Due date has passed, not completed | Red |
| `due_today` | Due date is today | Orange |
| `urgent` | Due within 2 days | Yellow |
| `upcoming` | Due within 7 days | Blue |
| `scheduled` | Due more than 7 days out | Gray |
| `completed` | Marked complete | Green |
| `waived` | Contingency waived | Purple |
| `extended` | Recently extended | Teal |

## Severity Classification

| Category | Base Severity | If Overdue |
|----------|--------------|------------|
| `inspection` | CRITICAL | CRITICAL+ |
| `financing` | CRITICAL | CRITICAL+ |
| `closing` | CRITICAL | CRITICAL+ |
| `escrow` | HIGH | CRITICAL |
| `appraisal` | HIGH | CRITICAL |
| `title` | MEDIUM | HIGH |
| `hoa` | MEDIUM | HIGH |
| `insurance` | MEDIUM | HIGH |
| `survey` | LOW | MEDIUM |
| `walkthrough` | LOW | MEDIUM |

## Execution Flow

```
START
  │
  ├─── 1. Parse query parameters
  │    ├── Extract dealId or propertyAddress
  │    ├── Parse date range from voice
  │    │   ├── "this week" → Mon-Sun
  │    │   ├── "next 5 days" → today + 5
  │    │   ├── "today" → today only
  │    │   └── Default: next 7 days
  │    ├── Parse status filters
  │    └── Parse category filters
  │
  ├─── 2. Build query
  │    │
  │    ├── Base query:
  │    │   SELECT d.*, deal.property_address, deal.status as deal_status
  │    │   FROM deadlines d
  │    │   JOIN deals deal ON d.deal_id = deal.id
  │    │   WHERE deal.agent_id = {{agentId}}
  │    │     AND deal.status IN ('active', 'pending', 'under_contract')
  │    │
  │    ├── IF dealId provided:
  │    │   └── AND d.deal_id = {{dealId}}
  │    │
  │    ├── IF status filters:
  │    │   ├── 'overdue': AND d.due_date < TODAY AND d.status NOT IN ('completed', 'waived')
  │    │   ├── 'today': AND d.due_date = TODAY AND d.status NOT IN ('completed', 'waived')
  │    │   ├── 'upcoming': AND d.due_date BETWEEN TODAY AND {{endDate}}
  │    │   └── 'completed': AND d.status = 'completed'
  │    │
  │    └── ORDER BY:
  │        ├── Overdue first
  │        ├── Then by due_date ASC
  │        └── Then by severity DESC
  │
  ├─── 3. Execute query and fetch deadlines
  │
  ├─── 4. Calculate dynamic status for each deadline
  │    │
  │    ├── FOR EACH deadline:
  │    │   │
  │    │   ├── Calculate days until/since due:
  │    │   │   └── daysUntil = differenceInDays(dueDate, today)
  │    │   │
  │    │   ├── Determine current status:
  │    │   │   ├── IF completed/waived → keep status
  │    │   │   ├── IF daysUntil < 0 → 'overdue'
  │    │   │   ├── IF daysUntil = 0 → 'due_today'
  │    │   │   ├── IF daysUntil <= 2 → 'urgent'
  │    │   │   ├── IF daysUntil <= 7 → 'upcoming'
  │    │   │   └── ELSE → 'scheduled'
  │    │   │
  │    │   ├── Calculate severity:
  │    │   │   ├── Get base severity from category
  │    │   │   ├── IF overdue → escalate severity
  │    │   │   └── IF due_today AND critical category → maximum
  │    │   │
  │    │   └── Add consequence text if applicable
  │    │
  │    └── Sort by urgency
  │
  ├─── 5. Group results (if requested)
  │    │
  │    ├── IF groupBy = 'deal':
  │    │   └── Group deadlines by property address
  │    │
  │    ├── IF groupBy = 'date':
  │    │   └── Group by due date (overdue, today, tomorrow, this week, etc.)
  │    │
  │    ├── IF groupBy = 'category':
  │    │   └── Group by deadline category
  │    │
  │    └── IF groupBy = 'status':
  │        └── Group by current status
  │
  ├─── 6. Generate summary statistics
  │    │
  │    ├── Total deadlines by status:
  │    │   ├── overdue: X
  │    │   ├── due_today: X
  │    │   ├── urgent: X
  │    │   ├── upcoming: X
  │    │   └── completed (this week): X
  │    │
  │    ├── By deal:
  │    │   └── { dealId: { total, overdue, upcoming } }
  │    │
  │    └── Risk assessment:
  │        ├── criticalDeadlines: count
  │        ├── dealsAtRisk: count
  │        └── actionRequired: boolean
  │
  ├─── 7. Generate action recommendations
  │    │
  │    ├── IF overdue > 0:
  │    │   └── "You have {{count}} overdue deadline(s). These need immediate attention."
  │    │
  │    ├── IF due_today > 0:
  │    │   └── "{{count}} deadline(s) due TODAY by 5 PM."
  │    │
  │    └── IF urgent critical deadlines:
  │        └── "The {{deadline}} for {{property}} is critical - {{consequence}}"
  │
  └─── 8. Return results
```

## Query Examples by Voice Input

| Voice Input | Parsed Query |
|-------------|--------------|
| "What's overdue?" | status: ['overdue'] |
| "Deadlines this week" | dateRange: { start: today, end: endOfWeek } |
| "What's due for 123 Main St?" | propertyAddress: "123 Main St" |
| "Show inspection deadlines" | category: ['inspection'] |
| "Critical deadlines only" | severity: ['critical'] |
| "What did we complete this week?" | status: ['completed'], dateRange: thisWeek |
| "Financing deadlines across all deals" | category: ['financing'] |

## Output

```typescript
{
  success: true,
  actionTaken: "Retrieved deadline status for 5 active deals",
  result: {
    summary: {
      total: 23,
      overdue: 1,
      dueToday: 2,
      urgent: 3,
      upcoming: 12,
      scheduled: 5,
      completedThisWeek: 4,
      actionRequired: true,
      riskLevel: "high" // low, medium, high, critical
    },

    overdue: [
      {
        id: "uuid-1",
        name: "Escrow Deposit Due",
        category: "escrow",
        dueDate: "2026-01-13",
        dueTime: "17:00",
        daysOverdue: 2,
        severity: "CRITICAL",
        consequence: "Seller may void contract",
        deal: {
          id: "deal-uuid",
          address: "123 Main St, Miami, FL",
          buyerName: "John Smith"
        },
        suggestedAction: "Contact buyer immediately - escrow deposit is 2 days overdue"
      }
    ],

    dueToday: [
      {
        id: "uuid-2",
        name: "Inspection Period Ends",
        category: "inspection",
        dueDate: "2026-01-15",
        dueTime: "17:00",
        hoursRemaining: 7,
        severity: "CRITICAL",
        consequence: "Buyer loses right to cancel after 5 PM",
        deal: {
          id: "deal-uuid-2",
          address: "456 Oak Ave, Tampa, FL",
          buyerName: "Jane Doe"
        },
        suggestedAction: "Confirm buyer's decision - accept, cancel, or request repairs"
      },
      {
        id: "uuid-3",
        name: "Title Commitment Due",
        category: "title",
        dueDate: "2026-01-15",
        dueTime: "17:00",
        hoursRemaining: 7,
        severity: "MEDIUM",
        deal: {
          id: "deal-uuid-3",
          address: "789 Pine Rd, Orlando, FL",
          buyerName: "Bob Wilson"
        },
        suggestedAction: "Follow up with title company"
      }
    ],

    urgent: [
      {
        id: "uuid-4",
        name: "Financing Contingency",
        category: "financing",
        dueDate: "2026-01-17",
        dueTime: "17:00",
        daysUntil: 2,
        severity: "HIGH",
        deal: {
          id: "deal-uuid-2",
          address: "456 Oak Ave, Tampa, FL"
        },
        suggestedAction: "Check loan status with lender"
      }
      // ... more urgent deadlines
    ],

    upcoming: [
      // Next 7 days deadlines
    ],

    byDeal: {
      "123 Main St, Miami": {
        dealId: "deal-uuid",
        status: "at_risk",
        overdueCount: 1,
        upcomingCount: 3,
        nextDeadline: {
          name: "Appraisal Due",
          dueDate: "2026-01-20",
          daysUntil: 5
        }
      },
      "456 Oak Ave, Tampa": {
        dealId: "deal-uuid-2",
        status: "action_needed",
        overdueCount: 0,
        upcomingCount: 4,
        nextDeadline: {
          name: "Inspection Period Ends",
          dueDate: "2026-01-15",
          daysUntil: 0
        }
      }
      // ... more deals
    },

    recommendations: [
      {
        priority: 1,
        type: "overdue",
        message: "Escrow deposit for 123 Main St is 2 days overdue. Contact buyer John Smith immediately.",
        action: "call_buyer",
        deadlineId: "uuid-1"
      },
      {
        priority: 2,
        type: "due_today",
        message: "Inspection period for 456 Oak Ave ends TODAY at 5 PM. Confirm buyer's decision.",
        action: "confirm_inspection_decision",
        deadlineId: "uuid-2"
      },
      {
        priority: 3,
        type: "urgent",
        message: "Financing contingency for 456 Oak Ave expires in 2 days. Check loan status.",
        action: "check_loan_status",
        deadlineId: "uuid-4"
      }
    ]
  }
}
```

## Voice Response Examples

### Morning Briefing
> "Good morning! Here's your deadline situation:
>
> You have **1 overdue deadline** that needs immediate attention - the escrow deposit for 123 Main Street is 2 days past due. I'd recommend calling the buyer right away.
>
> **2 deadlines are due TODAY** by 5 PM:
> - Inspection period ends for 456 Oak Avenue
> - Title commitment due for 789 Pine Road
>
> Looking ahead, you have 3 more deadlines in the next 2 days, including a financing contingency.
>
> Would you like me to go through these in detail?"

### Quick Status Check
> "Across your 5 active deals, you have:
> - 1 overdue
> - 2 due today
> - 3 urgent in the next 2 days
> - 12 upcoming this week
>
> The most critical is the inspection deadline ending today for 456 Oak Ave. What would you like to tackle first?"

### Single Deal Status
> "For 123 Main Street:
>
> The escrow deposit deadline passed 2 days ago - that's overdue and needs action.
>
> Coming up:
> - Appraisal due January 20th - 5 days
> - Financing contingency January 25th - 10 days
> - Closing scheduled February 15th - 31 days
>
> The appraisal was ordered on the 10th, so we should have results soon. Want me to follow up with the appraiser?"

### All Clear Response
> "Great news! You're all caught up.
>
> No overdue deadlines, nothing due today. Your next deadline is the HOA documents for 789 Pine Road, due in 4 days.
>
> All 5 of your active deals are on track."

## Notification Triggers

This skill can trigger alerts when status changes are detected:

| Condition | Trigger |
|-----------|---------|
| New overdue deadline | Immediate alert to agent |
| Deadline becomes due_today | Morning alert (8 AM) |
| Critical deadline in 2 days | Urgent notification |
| Multiple overdue across deals | Escalation summary |
| Deal has 3+ overdue | High-risk deal flag |

## Dashboard Widget Format

For UI integration, provides widget-ready data:

```typescript
{
  widget: {
    type: "deadline-status",
    data: {
      donut: {
        overdue: 1,
        today: 2,
        urgent: 3,
        upcoming: 12,
        onTrack: 5
      },
      topPriority: {
        title: "Escrow Deposit - 123 Main St",
        status: "overdue",
        daysOverdue: 2,
        action: "Call buyer"
      },
      upNext: [
        { title: "Inspection Ends", deal: "456 Oak", time: "Today 5 PM" },
        { title: "Title Due", deal: "789 Pine", time: "Today 5 PM" },
        { title: "Financing", deal: "456 Oak", time: "2 days" }
      ]
    }
  }
}
```

## Error Handling

| Error | Cause | Response |
|-------|-------|----------|
| `NO_ACTIVE_DEALS` | Agent has no active deals | "You don't have any active deals right now. Would you like to create one?" |
| `DEAL_NOT_FOUND` | Property address not matched | "I couldn't find a deal for [address]. Your active deals are: [list]" |
| `INVALID_DATE_RANGE` | Unparseable date range | "I didn't understand that date range. Try 'this week', 'next 5 days', or a specific date." |

## Filters for Power Users

### Complex Query Examples

```typescript
// "Show me critical deadlines for financing that are overdue or due this week"
{
  category: ['financing'],
  severity: ['critical'],
  status: ['overdue', 'due_today', 'urgent', 'upcoming'],
  dateRange: { start: today, end: endOfWeek }
}

// "What inspection and appraisal deadlines are coming up for Tampa deals?"
{
  category: ['inspection', 'appraisal'],
  status: ['upcoming', 'urgent'],
  propertySearch: 'Tampa'
}

// "Show completed deadlines from last week"
{
  status: ['completed'],
  dateRange: { start: startOfLastWeek, end: endOfLastWeek }
}
```

## Quality Checklist

- [x] Handles single deal and all deals queries
- [x] Correctly calculates days until/overdue
- [x] Assigns appropriate severity levels
- [x] Groups results by deal, date, category, or status
- [x] Provides actionable recommendations
- [x] Voice responses are natural and prioritized
- [x] Identifies at-risk deals
- [x] Surfaces consequences for critical deadlines
- [x] Supports date range queries
- [x] Handles "no deadlines" gracefully
- [x] Provides dashboard-ready widget data
- [x] Includes suggested next actions
- [x] Triggers appropriate follow-up alerts

# Skill: Deal Health Check

**Category:** Deal
**Priority:** P1
**Approval Required:** No

## Purpose

Assess the current health of a real estate transaction by analyzing deadlines, task completion, communication patterns, and potential risks. This skill provides an at-a-glance status and identifies issues before they become problems.

## Triggers

### Voice Commands
- "How is the [address] deal doing?"
- "Deal health check on [address]"
- "Is [address] on track?"
- "Any issues with [address]?"
- "Check status of [address]"
- "Risk assessment for [address]"
- "What's the deal situation at [address]?"

### Programmatic
- Daily scheduled check for all active deals
- Pre-meeting deal review
- API call to `/deals/{id}/health`
- Dashboard "Health Check" button
- Weekly digest generation

## Required Inputs

| Input | Type | Required | Source | Description |
|-------|------|----------|--------|-------------|
| `dealId` | UUID | Yes* | context/manual | Deal to assess |
| `propertyAddress` | string | Yes* | voice | Can identify deal by address |

*One of dealId or propertyAddress required

## Optional Inputs

| Input | Type | Default | Source | Description |
|-------|------|---------|--------|-------------|
| `includeRecommendations` | boolean | true | config | Include action recommendations |
| `includeTimeline` | boolean | true | config | Include visual timeline |
| `compareToTypical` | boolean | true | config | Compare to typical deal pace |
| `checkCommunications` | boolean | true | config | Analyze communication patterns |
| `riskThreshold` | string | 'medium' | config | Sensitivity level (low/medium/high) |

## Health Score Components

| Component | Weight | Description |
|-----------|--------|-------------|
| Deadline Status | 30% | On-time vs. overdue/at-risk |
| Task Completion | 20% | Required tasks completed |
| Document Status | 15% | Required documents received |
| Communication | 15% | Response times, engagement |
| Financial Status | 10% | Deposits, financing progress |
| Party Engagement | 10% | All parties responsive |

## Risk Categories

| Level | Score | Description | Color |
|-------|-------|-------------|-------|
| Excellent | 90-100 | On track, no issues | Green |
| Good | 75-89 | Minor concerns, manageable | Light Green |
| Fair | 60-74 | Attention needed on some items | Yellow |
| At Risk | 40-59 | Significant issues, intervention needed | Orange |
| Critical | 0-39 | Major problems, deal may fail | Red |

## Execution Flow

```
START
  │
  ├─── 1. Identify deal
  │    ├── If dealId provided → load deal
  │    ├── If propertyAddress provided → find active deal
  │    └── Verify deal exists and is active/pending
  │
  ├─── 2. Gather deal data
  │    ├── Load all deadlines
  │    ├── Load all tasks
  │    ├── Load all documents
  │    ├── Load all parties
  │    ├── Load financial records
  │    ├── Load communication log
  │    └── Load action history
  │
  ├─── 3. Assess deadline status (30% weight)
  │    ├── Count total deadlines
  │    ├── Count completed on time
  │    ├── Count overdue
  │    ├── Count at risk (< 3 days remaining)
  │    ├── Calculate days to next deadline
  │    └── Score: (on_time + upcoming) / total * 100
  │
  ├─── 4. Assess task completion (20% weight)
  │    ├── Count required tasks
  │    ├── Count completed tasks
  │    ├── Count overdue tasks
  │    ├── Identify blocking tasks
  │    └── Score: completed / required * 100
  │
  ├─── 5. Assess document status (15% weight)
  │    ├── List required documents for stage
  │    ├── Count received documents
  │    ├── Count missing critical documents
  │    ├── Check document expiration
  │    └── Score: received / required * 100
  │
  ├─── 6. Assess communication (15% weight)
  │    ├── Check last contact with each party
  │    ├── Calculate average response time
  │    ├── Identify unresponsive parties
  │    ├── Check for extended silence
  │    └── Score: based on recency and responsiveness
  │
  ├─── 7. Assess financial status (10% weight)
  │    ├── Escrow deposit received?
  │    ├── Additional deposit on time?
  │    ├── Loan approval status
  │    ├── Appraisal status
  │    └── Score: milestones_hit / expected * 100
  │
  ├─── 8. Assess party engagement (10% weight)
  │    ├── All key parties identified?
  │    ├── Contact info complete?
  │    ├── Recent activity from each?
  │    ├── Any escalations/complaints?
  │    └── Score: active_parties / total_parties * 100
  │
  ├─── 9. Calculate overall health score
  │    ├── Apply weights to component scores
  │    ├── Calculate weighted average
  │    ├── Determine risk category
  │    └── Set health status color
  │
  ├─── 10. Identify specific risks
  │     ├── List all at-risk items
  │     ├── Categorize by severity
  │     ├── Identify root causes
  │     └── Prioritize by impact
  │
  ├─── 11. Compare to typical (if compareToTypical=true)
  │     ├── Compare to similar deals
  │     ├── Note if ahead/behind typical pace
  │     └── Flag anomalies
  │
  ├─── 12. Generate recommendations (if includeRecommendations)
  │     ├── Prioritize by impact
  │     ├── Assign owners
  │     └── Suggest deadlines
  │
  ├─── 13. Log health check
  │     └── action_type: 'deal_health_check'
  │
  └── RETURN health report
```

## Output

```typescript
{
  success: true,
  actionTaken: "Completed health check for 123 Main St, Miami FL 33101",
  result: {
    deal: {
      id: "uuid",
      propertyAddress: "123 Main St, Miami FL 33101",
      status: "active",
      effectiveDate: "2026-01-15",
      closingDate: "2026-03-12",
      daysUntilClosing: 45,
      daysUnderContract: 12
    },

    healthScore: 78,
    riskCategory: "good",
    statusColor: "light_green",

    summary: "Deal is mostly on track with a few items needing attention. The inspection period ends in 3 days and no report has been received yet. All other deadlines are current.",

    components: {
      deadlines: {
        score: 85,
        weight: 30,
        total: 8,
        completed: 2,
        onTrack: 5,
        atRisk: 1,
        overdue: 0,
        nextDeadline: {
          name: "Inspection Period",
          date: "2026-01-30",
          daysRemaining: 3
        }
      },

      tasks: {
        score: 70,
        weight: 20,
        total: 12,
        completed: 7,
        pending: 4,
        overdue: 1,
        overdueTask: "Upload signed disclosure"
      },

      documents: {
        score: 75,
        weight: 15,
        required: 8,
        received: 6,
        missing: ["Inspection Report", "HOA Estoppel"],
        expiringSoon: []
      },

      communication: {
        score: 80,
        weight: 15,
        lastBuyerContact: "2 days ago",
        lastSellerContact: "1 day ago",
        lastLenderContact: "5 days ago",
        unresponsive: [],
        averageResponseTime: "4 hours"
      },

      financial: {
        score: 100,
        weight: 10,
        escrowReceived: true,
        escrowAmount: 10000,
        additionalDepositDue: "2026-01-25",
        additionalDepositReceived: false,
        loanStatus: "in_underwriting",
        appraisalStatus: "scheduled"
      },

      partyEngagement: {
        score: 85,
        weight: 10,
        totalParties: 6,
        activeParties: 5,
        inactiveParty: "Lender - no update in 5 days"
      }
    },

    risks: [
      {
        severity: "high",
        category: "deadline",
        item: "Inspection Period",
        issue: "Ends in 3 days but no inspection report received",
        impact: "May lose inspection contingency rights",
        recommendation: "Immediately contact inspector for report status"
      },
      {
        severity: "medium",
        category: "communication",
        item: "Lender contact",
        issue: "No communication from lender in 5 days",
        impact: "May delay financing approval",
        recommendation: "Follow up with lender on loan status"
      },
      {
        severity: "low",
        category: "task",
        item: "Signed disclosure upload",
        issue: "Task overdue by 2 days",
        impact: "Minor compliance issue",
        recommendation: "Obtain and upload signed disclosure"
      }
    ],

    positives: [
      "Escrow deposit received on time",
      "All parties responsive",
      "On track for closing date",
      "Contract fully executed"
    ],

    timeline: {
      position: 0.27, // 27% through deal lifecycle
      milestones: [
        { name: "Contract Executed", date: "2026-01-15", status: "completed" },
        { name: "Escrow Deposited", date: "2026-01-18", status: "completed" },
        { name: "Inspection Period", date: "2026-01-30", status: "at_risk" },
        { name: "Financing Contingency", date: "2026-02-14", status: "upcoming" },
        { name: "Clear to Close", date: "2026-03-05", status: "upcoming" },
        { name: "Closing", date: "2026-03-12", status: "upcoming" }
      ]
    },

    comparedToTypical: {
      pace: "on_track",
      percentile: 65,
      note: "This deal is progressing at an average pace compared to similar transactions"
    },

    recommendations: [
      {
        priority: 1,
        action: "Get inspection report status",
        reason: "Inspection period ends in 3 days",
        owner: "buyer_agent",
        deadline: "today"
      },
      {
        priority: 2,
        action: "Follow up with lender",
        reason: "No update in 5 days",
        owner: "buyer_agent",
        deadline: "tomorrow"
      },
      {
        priority: 3,
        action: "Upload signed disclosure",
        reason: "Task overdue",
        owner: "listing_agent",
        deadline: "tomorrow"
      }
    ]
  }
}
```

## Voice Response

**Healthy Deal:**
> "The deal at 123 Main Street is looking great - health score of 92.
>
> You're 27% through the timeline with 45 days until closing. All deadlines are on track, escrow is in, and everyone's been responsive.
>
> The only thing to watch is the inspection period ends in 10 days. Make sure the inspector is scheduled.
>
> Overall, this deal is in excellent shape. Anything specific you want me to check?"

**Deal Needing Attention:**
> "I'm a bit concerned about 123 Main Street. Health score is 78 - that's 'good' but there are items needing attention.
>
> Here's what's going on:
>
> HIGH priority: The inspection period ends in 3 days and I haven't seen an inspection report yet. This needs immediate attention or the buyer may lose their contingency rights.
>
> MEDIUM priority: The lender hasn't responded in 5 days. Should follow up on the loan status.
>
> LOW priority: There's an overdue task to upload the signed disclosure - minor but should get done.
>
> The good news: escrow is in, all parties are engaged, and you're on track for the March 12th closing.
>
> Want me to create tasks for these items?"

**At-Risk Deal:**
> "Red flags on 456 Oak Avenue. Health score is 52 - this deal is at risk.
>
> Critical issues:
> 1. Inspection period expired 2 days ago with no report or extension
> 2. Additional deposit was due yesterday and hasn't been received
> 3. Haven't heard from the buyer or buyer's agent in 8 days
>
> These are serious problems. The buyer may be getting cold feet, or there could be communication issues.
>
> I'd recommend calling the buyer's agent right now to get a status. Want me to draft a message or set up a reminder?"

**Critical Deal:**
> "We have a problem with 789 Pine Lane. Health score is 31 - this deal is in critical condition.
>
> Here's what's failing:
> - Financing contingency expired with no loan approval
> - No communication from buyer, buyer's agent, or lender in 12 days
> - 3 critical deadlines are overdue
> - Escrow still hasn't received the additional deposit
>
> Honestly, this deal may not survive. I'd recommend a serious conversation with the buyer's agent today about whether to proceed or start termination.
>
> How do you want to handle this?"

## Error Handling

| Error | Cause | Response |
|-------|-------|----------|
| `DEAL_NOT_FOUND` | Invalid dealId or address | "I can't find an active deal for that address. Can you verify?" |
| `DEAL_NOT_ACTIVE` | Deal is closed/cancelled/archived | "That deal is [status]. Health checks are only for active deals. Want to see the deal summary instead?" |
| `INSUFFICIENT_DATA` | Deal just created, no history | "This deal was just created so there's not much to assess yet. The main thing is to set the effective date and add parties." |

## Integration Points

### Scheduled Checks
- Daily at 8 AM: Check all active deals
- Generate alerts for at-risk deals
- Weekly summary email to agents

### Database Tables
- `deals` - Core deal data
- `deadlines` - Deadline status
- `tasks` - Task completion
- `documents` - Document status
- `communications` - Message history
- `health_checks` - Historical health scores

### External Data
- Lender status API (if integrated)
- Title company updates (if integrated)
- Email/communication system

## Risk Thresholds

### Deadline Risk Assessment
| Days Remaining | Risk Level |
|----------------|------------|
| > 7 days | Low |
| 3-7 days | Medium |
| 1-2 days | High |
| 0 or overdue | Critical |

### Communication Gaps
| Days Silent | Risk Level |
|-------------|------------|
| 0-3 days | Normal |
| 4-7 days | Medium |
| 8-14 days | High |
| 15+ days | Critical |

### Financial Milestones
| Milestone | Risk if Missing |
|-----------|-----------------|
| Initial escrow (3 days) | High |
| Additional deposit | High |
| Loan approval (by contingency) | Critical |
| Clear to close (7 days before) | High |

## Example Usage

### Morning Deal Review
```
Agent: "Homer, give me a health check on all my active deals"

Homer: "You have 4 active deals. Here's the rundown:

        GREEN (Excellent):
        • 123 Main St - Score: 94, closing in 45 days

        LIGHT GREEN (Good):
        • 456 Oak Ave - Score: 82, closing in 30 days
          (Note: Follow up with lender this week)

        YELLOW (Fair):
        • 789 Pine Ln - Score: 68, closing in 21 days
          (Action needed: Inspection report overdue)

        ORANGE (At Risk):
        • 101 Elm Dr - Score: 48, closing in 14 days
          (Urgent: Financing not approved, buyer unresponsive)

        Want details on any of these?"
```

### Deep Dive on Specific Deal
```
Agent: "What's the situation with Elm Drive?"

Homer: "101 Elm Drive is in trouble. Here's the breakdown:

        HEALTH SCORE: 48 (At Risk)

        Critical Issues:
        1. Financing contingency expired yesterday - no loan approval yet
        2. Buyer's agent hasn't responded in 9 days
        3. Appraisal came in $15,000 low

        Timeline: You're 60% through the deal with only 14 days
        to closing. At this pace, closing will likely be delayed
        or the deal may fall through.

        Recommended Actions:
        1. Call buyer's agent NOW - get status on loan
        2. If loan approved, discuss appraisal gap
        3. If loan not approved, consider extension or cancellation

        This needs personal attention today. Want me to draft
        a message to the buyer's agent?"
```

## Quality Checklist

- [x] Handles voice input naturally
- [x] Calculates comprehensive health score
- [x] Assesses all deal components (deadlines, tasks, docs, etc.)
- [x] Identifies and prioritizes risks
- [x] Provides actionable recommendations
- [x] Compares to typical deal pace
- [x] Supports scheduled daily checks
- [x] Categorizes risk levels clearly
- [x] Provides both summary and detailed views
- [x] Highlights positives, not just negatives
- [x] Creates visual timeline representation
- [x] Tracks communication patterns
- [x] Creates audit log entry
- [x] Handles errors gracefully
- [x] Florida-specific considerations (where applicable)

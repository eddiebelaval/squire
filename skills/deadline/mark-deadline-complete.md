# Skill: Mark Deadline Complete

**Category:** Deadline
**Priority:** P0
**Approval Required:** No

## Purpose

Mark a deadline as completed, recording completion details, notifying relevant parties, and triggering any follow-up actions or dependent workflows.

## Triggers

### Voice Commands
- "Mark the inspection deadline complete"
- "We received the escrow deposit"
- "Title commitment is done"
- "Financing is approved"
- "Close out the [deadline name]"
- "The [deadline] has been completed"

### System Events
- DocuSign document completed (auto-mark related deadline)
- Lender API: loan status change
- Email parsed: confirmation received

### Manual
- Agent clicks "Mark Complete" in UI
- API call from integration

## Input

```typescript
{
  dealId: string;
  deadlineId?: string;              // Specific deadline, or...
  deadlineCategory?: DeadlineCategory; // Find by category, or...
  deadlineName?: string;            // Find by name match
  completedBy?: string;             // Who completed it
  completionNotes?: string;         // Optional notes
  completionDate?: Date;            // Default: now
  attachmentUrl?: string;           // Supporting document
  notifyParties?: boolean;          // Default: true
}
```

## Output

```typescript
{
  success: boolean;
  actionTaken: string;
  result: {
    deadline: {
      id: string;
      name: string;
      category: string;
      originalDueDate: Date;
      completedAt: Date;
      completedBy: string;
      completionNotes?: string;
      daysEarly: number;            // Positive = early, negative = late
      wasOverdue: boolean;
    };
    followUpActions: {
      action: string;
      status: 'triggered' | 'queued' | 'skipped';
      details?: string;
    }[];
    notificationsSent: {
      party: string;
      channel: string;
      status: string;
    }[];
    relatedDeadlinesUpdated: {
      deadlineId: string;
      name: string;
      update: string;
    }[];
    dealProgress: {
      completedDeadlines: number;
      totalDeadlines: number;
      percentComplete: number;
      nextDeadline?: {
        name: string;
        dueDate: Date;
        daysUntil: number;
      };
    };
  };
}
```

## Execution Flow

```
START
  │
  ├─── 1. Find and validate deadline
  │    ├── Search by ID, category, or name match
  │    ├── Verify deadline exists
  │    ├── Verify deadline not already completed
  │    └── Verify deal is active
  │
  ├─── 2. Calculate completion metrics
  │    ├── Compare completion date to due date
  │    ├── Calculate days early/late
  │    └── Flag if was overdue
  │
  ├─── 3. Update deadline record
  │    │
  │    │   UPDATE deadlines SET
  │    │     status = 'completed',
  │    │     completed_at = {{completionDate}},
  │    │     completed_by = {{completedBy}},
  │    │     completion_notes = {{completionNotes}}
  │    │   WHERE id = {{deadlineId}}
  │
  ├─── 4. Cancel pending alerts
  │    ├── Remove from alert queue
  │    └── Mark scheduled notifications as cancelled
  │
  ├─── 5. Trigger follow-up actions
  │    │
  │    ├── IF deadline.category = INSPECTION:
  │    │   ├── IF completionNotes contains "repairs requested":
  │    │   │   └── Queue repair-negotiation workflow
  │    │   └── IF completionNotes contains "as-is accepted":
  │    │       └── Log buyer acceptance
  │    │
  │    ├── IF deadline.category = FINANCING:
  │    │   ├── Update deal.financingStatus = 'approved'
  │    │   └── Notify title company
  │    │
  │    ├── IF deadline.category = ESCROW:
  │    │   ├── Update deal.escrowReceived = true
  │    │   └── Confirm with title company
  │    │
  │    ├── IF deadline.category = APPRAISAL:
  │    │   └── Log appraised value if provided
  │    │
  │    ├── IF deadline.category = TITLE:
  │    │   └── Mark title clear if no exceptions noted
  │    │
  │    └── IF deadline.category = CLOSING:
  │        └── Trigger post-closing workflow
  │
  ├─── 6. Update dependent deadlines
  │    │
  │    ├── IF deadline was blocking others:
  │    │   └── Activate dependent deadlines
  │    │
  │    └── Recalculate any relative deadlines
  │
  ├─── 7. Send completion notifications
  │    │
  │    ├── IF notifyParties = true:
  │    │   ├── Notify agent (always)
  │    │   ├── Notify parties based on deadline type
  │    │   └── Use completion template
  │    │
  │    └── IF was overdue:
  │        └── Include late completion note
  │
  ├─── 8. Calculate deal progress
  │    ├── Count completed vs total deadlines
  │    ├── Calculate percentage
  │    └── Identify next upcoming deadline
  │
  ├─── 9. Log action
  │    ├── Create action_log entry
  │    └── Store completion details
  │
  └─── 10. Return result
```

## Follow-Up Actions by Category

| Category | Completion Trigger | Follow-Up Action |
|----------|-------------------|------------------|
| ESCROW | Deposit received | Confirm with title, update deal record |
| INSPECTION | Period ended | Check if repairs requested, queue response |
| FINANCING | Loan approved | Notify all parties, update deal status |
| APPRAISAL | Value received | Compare to price, flag if low |
| TITLE | Commitment received | Review for exceptions, flag issues |
| HOA | Review complete | Log buyer decision |
| INSURANCE | Policy bound | Send binder to lender |
| CLOSING | Deal closed | Trigger post-closing workflow |

## Notification Templates

### Standard Completion
```
Subject: ✅ {{deadline.name}} Complete - {{deal.address.street}}

{{agent.name}},

**{{deadline.name}}** has been marked complete.

{{#if completionNotes}}
Notes: {{completionNotes}}
{{/if}}

{{#if daysEarly > 0}}
Completed {{daysEarly}} days ahead of schedule! 🎉
{{/if}}

**Deal Progress:** {{dealProgress.percentComplete}}% complete ({{dealProgress.completedDeadlines}}/{{dealProgress.totalDeadlines}} deadlines)

{{#if nextDeadline}}
**Next Deadline:** {{nextDeadline.name}} due {{nextDeadline.dueDate | formatDate}} ({{nextDeadline.daysUntil}} days)
{{/if}}

— Homer Pro
```

### Overdue Completion
```
Subject: ⚠️ {{deadline.name}} Completed (Late) - {{deal.address.street}}

{{agent.name}},

**{{deadline.name}}** has been completed, {{Math.abs(daysEarly)}} days past the deadline.

Original Due Date: {{deadline.originalDueDate | formatDate}}
Completed: {{deadline.completedAt | formatDate}}

{{#if completionNotes}}
Notes: {{completionNotes}}
{{/if}}

Please review if any follow-up actions are needed due to the delay.

— Homer Pro
```

### Progress Update (to Buyer/Seller)
```
Subject: Transaction Update - {{deal.address.street}}

Hi {{party.name}},

Good news! The **{{deadline.name}}** milestone has been completed for your property transaction.

We're now {{dealProgress.percentComplete}}% through the process.

{{#if nextMilestone}}
What's next: {{nextMilestone}}
{{/if}}

If you have any questions, please don't hesitate to reach out.

Best regards,
{{agent.name}}
```

## Voice Command Processing

| Voice Input | Parsed Action |
|-------------|---------------|
| "Mark the inspection complete" | category: INSPECTION |
| "We got the escrow deposit" | category: ESCROW |
| "Financing is approved" | category: FINANCING |
| "Close out the title deadline" | category: TITLE |
| "The HOA docs are done" | category: HOA |
| "Mark [deadline name] as done" | name match |

## Error Handling

| Error | Cause | Response |
|-------|-------|----------|
| `DEADLINE_NOT_FOUND` | No matching deadline | List active deadlines for deal |
| `ALREADY_COMPLETED` | Deadline already done | Return existing completion info |
| `AMBIGUOUS_MATCH` | Multiple deadlines match | Ask for clarification |
| `DEAL_INACTIVE` | Deal not active | Cannot complete on inactive deal |

## Quality Checklist

- [x] Finds deadline by ID, category, or name
- [x] Records accurate completion timestamp
- [x] Calculates early/late metrics
- [x] Cancels pending alerts
- [x] Triggers appropriate follow-up actions
- [x] Updates dependent deadlines
- [x] Sends completion notifications
- [x] Provides deal progress summary
- [x] Handles voice commands naturally
- [x] Creates complete audit trail

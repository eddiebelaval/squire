# Skill: 5-Day Deadline Alert

**Category:** Deadline/Alert
**Priority:** P0
**Approval Required:** No (notifications only)

## Purpose

Send proactive 5-day advance warnings for upcoming deadlines, giving all parties adequate time to prepare, gather required items, and complete tasks before they become urgent.

## Triggers

### Scheduled
- **Daily at 8:00 AM (agent timezone)**: Check all active deals for 5-day deadlines

### System Events
- New deadline created with due date 5 days out
- Deadline extended, new date now 5 days out

## Input

```typescript
{
  // Usually called with no params (scans all deals)
  agentId?: string;        // Optional: specific agent only
  dealId?: string;         // Optional: specific deal only
  includeCategories?: DeadlineCategory[];
}
```

## Output

```typescript
{
  success: boolean;
  actionTaken: string;
  result: {
    deadlinesAlerted: number;
    alerts: {
      dealId: string;
      dealAddress: string;
      deadline: {
        id: string;
        name: string;
        category: string;
        dueDate: Date;
      };
      notificationsSent: {
        party: string;
        channel: string;
        status: string;
      }[];
      preparationChecklist: string[];
    }[];
    skipped: {
      deadlineId: string;
      reason: string;
    }[];
  };
}
```

## Execution Flow

```
START
  │
  ├─── 1. Calculate 5-day window
  │    ├── Get current date in agent timezone
  │    ├── Calculate target date (today + 5 days)
  │    └── Account for weekends if business days mode
  │
  ├─── 2. Query upcoming deadlines
  │    │
  │    │   SELECT d.*, deal.*, agent.*
  │    │   FROM deadlines d
  │    │   JOIN deals deal ON d.deal_id = deal.id
  │    │   JOIN agents agent ON deal.agent_id = agent.id
  │    │   WHERE d.due_date = target_date
  │    │     AND d.status NOT IN ('completed', 'waived')
  │    │     AND deal.status = 'active'
  │    │     AND '5_day' NOT IN (d.alerts_sent)
  │    │   ORDER BY d.due_date ASC
  │
  ├─── 3. FOR EACH deadline:
  │    │
  │    ├─── 3a. Get preparation checklist
  │    │    └── Call get_preparation_items(deadline.category)
  │    │
  │    ├─── 3b. Determine recipients
  │    │    ├── Always: Agent
  │    │    ├── Based on category: Buyer/Seller/Both
  │    │    ├── Based on deadline.alertParties
  │    │    └── Apply notification preferences
  │    │
  │    ├─── 3c. Generate personalized messages
  │    │    │
  │    │    ├── FOR agent:
  │    │    │   └── Detailed checklist + action items
  │    │    │
  │    │    ├── FOR buyer/seller:
  │    │    │   └── Simplified reminder + what they need to do
  │    │    │
  │    │    └── FOR other parties:
  │    │        └── Status update + any requests
  │    │
  │    ├─── 3d. Send notifications
  │    │    ├── Email (primary)
  │    │    ├── SMS (if enabled and high priority)
  │    │    └── Push notification
  │    │
  │    └─── 3e. Mark alert sent
  │         └── UPDATE deadlines SET alerts_sent = alerts_sent || {'5_day': now()}
  │
  └─── 4. Return summary
```

## Preparation Checklists by Category

### INSPECTION
```markdown
5 Days Until Inspection Period Ends:
□ Confirm all inspections are scheduled
□ General home inspection completed?
□ Specialty inspections scheduled (pool, roof, HVAC)?
□ Review inspection reports received
□ Compile repair request list
□ Prepare repair addendum if needed
□ Decide: Accept as-is, negotiate repairs, or cancel
```

### FINANCING
```markdown
5 Days Until Financing Contingency Expires:
□ Check loan status with lender
□ Appraisal completed?
□ Underwriting conditions cleared?
□ Loan commitment letter received?
□ Verify buyer can waive contingency
□ Prepare waiver or extension request
```

### APPRAISAL
```markdown
5 Days Until Appraisal Contingency Expires:
□ Appraisal report received?
□ Appraised value meets contract price?
□ If low: Negotiate price reduction or challenge?
□ Prepare buyer's response
```

### ESCROW
```markdown
5 Days Until Escrow Deposit Due:
□ Confirm deposit amount: ${{escrowAmount}}
□ Verify wire instructions with title company
□ Remind buyer to initiate wire transfer
□ DO NOT send wire info via email (fraud risk)
□ Confirm receipt once deposited
```

### TITLE
```markdown
5 Days Until Title Commitment Due:
□ Title commitment received?
□ Review for liens, encumbrances, exceptions
□ Identify items requiring seller to cure
□ Ensure title insurance ordered
□ Review survey if required
```

### HOA
```markdown
5 Days Until HOA Document Review Ends:
□ All HOA documents received?
□ Financials reviewed (reserves, special assessments)?
□ Rules and restrictions acceptable to buyer?
□ Pending litigation disclosed?
□ Buyer decision: Accept or cancel
```

### CLOSING
```markdown
5 Days Until Closing:
□ Clear to close received from lender?
□ Final closing disclosure reviewed?
□ Wire instructions verified (call title company)
□ Final walkthrough scheduled
□ Utility transfer arrangements made
□ All contingencies cleared/waived
□ Confirm closing time and location
```

### INSURANCE
```markdown
5 Days Until Insurance Binding Due:
□ Insurance quotes obtained?
□ Coverage meets lender requirements?
□ Policy ready to bind?
□ Binder to be sent to lender/title
```

## Message Templates

### Agent Email (Detailed)
```
Subject: ⏰ 5-Day Alert: {{deadline.name}} - {{deal.address.street}}

{{agent.name}},

You have a deadline coming up in 5 days:

**{{deadline.name}}**
Due: {{deadline.dueDate | formatDate}} at {{deadline.dueTime}}
Property: {{deal.address.street}}, {{deal.address.city}}

**Preparation Checklist:**
{{#each preparationItems}}
- [ ] {{this}}
{{/each}}

**Current Status:**
{{#if statusNotes}}
{{statusNotes}}
{{else}}
No status updates logged for this deadline.
{{/if}}

**Quick Actions:**
- [Mark Complete]({{markCompleteUrl}})
- [Request Extension]({{requestExtensionUrl}})
- [View Deal]({{dealUrl}})

— Homer Pro
```

### Buyer/Seller Email (Simplified)
```
Subject: Reminder: {{deadline.name}} Due {{deadline.dueDate | formatDate}}

Hi {{party.name}},

This is a friendly reminder that the **{{deadline.name}}** for your property at {{deal.address.street}} is due in 5 days.

**Due Date:** {{deadline.dueDate | formatDate}}

{{#if buyerAction}}
**What you need to do:**
{{buyerAction}}
{{/if}}

If you have any questions, please contact {{agent.name}} at {{agent.phone}} or {{agent.email}}.

Best regards,
{{agent.name}}
{{agent.brokerage}}

---
Sent via Homer Pro
```

### SMS Alert
```
⏰ 5-Day Alert: {{deadline.name}} due {{deadline.dueDate | formatShortDate}} for {{deal.address.street}}. Check email for details.
```

## Notification Rules

| Category | Notify Agent | Notify Buyer | Notify Seller | Notify Lender |
|----------|-------------|--------------|---------------|---------------|
| INSPECTION | ✓ | ✓ | - | - |
| FINANCING | ✓ | ✓ | - | ✓ |
| APPRAISAL | ✓ | ✓ | - | - |
| ESCROW | ✓ | ✓ | - | - |
| TITLE | ✓ | - | - | - |
| HOA | ✓ | ✓ | - | - |
| CLOSING | ✓ | ✓ | ✓ | ✓ |
| INSURANCE | ✓ | ✓ | - | - |

## Skip Conditions

Alert will be skipped if:
- Deadline already completed or waived
- 5-day alert already sent for this deadline
- Party has disabled notifications
- Deal is not active
- Agent working hours: Don't send before 8 AM or after 8 PM

## Error Handling

| Error | Cause | Response |
|-------|-------|----------|
| `EMAIL_FAILED` | Delivery failed | Retry 3x, then log warning |
| `SMS_FAILED` | SMS delivery failed | Log warning, don't block |
| `PARTY_NO_CONTACT` | Missing email/phone | Log warning, alert agent |

## Quality Checklist

- [x] Identifies all 5-day deadlines accurately
- [x] Applies timezone correctly
- [x] Generates category-specific checklists
- [x] Personalizes messages by recipient role
- [x] Respects notification preferences
- [x] Prevents duplicate alerts
- [x] Handles delivery failures gracefully
- [x] Logs all sent notifications
- [x] Provides actionable preparation items

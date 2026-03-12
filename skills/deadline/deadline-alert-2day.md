# Skill: 2-Day Deadline Alert

**Category:** Deadline/Alert
**Priority:** P0
**Approval Required:** No (notifications only)

## Purpose

Send urgent 2-day warnings for approaching deadlines. This is the "last chance" alert before same-day urgency, prompting immediate action on items that risk being missed.

## Triggers

### Scheduled
- **Daily at 8:00 AM (agent timezone)**: Check all active deals for 2-day deadlines
- **Daily at 2:00 PM (agent timezone)**: Second check for afternoon awareness

### System Events
- Deadline extended, new date now 2 days out
- 5-day alert was missed, catching up

## Input

```typescript
{
  agentId?: string;
  dealId?: string;
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
        daysRemaining: 2;
      };
      urgencyLevel: 'high';
      actionRequired: string;
      notificationsSent: {
        party: string;
        channel: string;
        status: string;
      }[];
      escalated: boolean;
    }[];
  };
}
```

## Execution Flow

```
START
  │
  ├─── 1. Calculate 2-day window
  │    ├── Get current date in agent timezone
  │    └── Calculate target date (today + 2 days)
  │
  ├─── 2. Query approaching deadlines
  │    │
  │    │   SELECT d.*, deal.*, agent.*
  │    │   FROM deadlines d
  │    │   JOIN deals deal ON d.deal_id = deal.id
  │    │   JOIN agents agent ON deal.agent_id = agent.id
  │    │   WHERE d.due_date = target_date
  │    │     AND d.status NOT IN ('completed', 'waived')
  │    │     AND deal.status = 'active'
  │    │     AND '2_day' NOT IN (d.alerts_sent)
  │    │   ORDER BY d.due_date ASC
  │
  ├─── 3. FOR EACH deadline:
  │    │
  │    ├─── 3a. Assess completion risk
  │    │    ├── Check if prerequisites are done
  │    │    ├── Check party response history
  │    │    └── Flag if high risk of missing
  │    │
  │    ├─── 3b. Generate urgent action item
  │    │    └── Single, clear action needed NOW
  │    │
  │    ├─── 3c. Determine notification intensity
  │    │    ├── Always: Email + SMS to agent
  │    │    ├── Contract deadlines: SMS to buyer/seller
  │    │    └── High risk: Phone call queue
  │    │
  │    ├─── 3d. Send notifications
  │    │    ├── Email (urgent template)
  │    │    ├── SMS (always for 2-day)
  │    │    └── Push notification
  │    │
  │    ├─── 3e. Escalate if needed
  │    │    ├── IF high risk AND no response to 5-day:
  │    │    │   └── Queue for agent phone call
  │    │    └── IF contract deadline:
  │    │        └── CC broker if configured
  │    │
  │    └─── 3f. Mark alert sent
  │         └── UPDATE deadlines SET alerts_sent = alerts_sent || {'2_day': now()}
  │
  └─── 4. Return summary
```

## Urgent Action Items by Category

### INSPECTION
```
⚠️ ACTION REQUIRED: Inspection period ends in 2 days ({{dueDate}}).
→ You must submit repair requests or waive inspection contingency by deadline.
→ If not submitted: Buyer loses negotiation leverage.
```

### FINANCING
```
⚠️ ACTION REQUIRED: Financing contingency expires in 2 days ({{dueDate}}).
→ Confirm loan approval status with lender TODAY.
→ If not approved: Request extension or buyer must proceed without protection.
```

### APPRAISAL
```
⚠️ ACTION REQUIRED: Appraisal contingency expires in 2 days ({{dueDate}}).
→ Appraisal value confirmed? If low, negotiate NOW.
→ If unresolved: Buyer loses right to cancel based on appraisal.
```

### ESCROW
```
⚠️ ACTION REQUIRED: Escrow deposit due in 2 days ({{dueDate}}).
→ Amount: ${{escrowAmount}}
→ Buyer must wire TODAY to ensure funds arrive on time.
→ If late: Potential contract breach.
```

### TITLE
```
⚠️ ACTION REQUIRED: Title commitment deadline in 2 days ({{dueDate}}).
→ Verify commitment received and reviewed.
→ If issues found: Must be addressed before closing.
```

### HOA
```
⚠️ ACTION REQUIRED: HOA review period ends in 2 days ({{dueDate}}).
→ Buyer must confirm acceptance or exercise cancellation right.
→ After deadline: Buyer accepts all HOA terms.
```

### CLOSING
```
🚨 CRITICAL: Closing in 2 days ({{dueDate}}).
→ Confirm: Clear to close, walkthrough scheduled, wire ready.
→ Any issues must be resolved IMMEDIATELY.
```

### INSURANCE
```
⚠️ ACTION REQUIRED: Insurance must be bound in 2 days ({{dueDate}}).
→ Policy selected and ready?
→ Lender requires proof of insurance before closing.
```

## Message Templates

### Agent Email (Urgent)
```
Subject: ⚠️ 2 DAYS: {{deadline.name}} - {{deal.address.street}} - ACTION NEEDED

{{agent.name}},

**URGENT: {{deadline.name}}**
Due in 2 days: {{deadline.dueDate | formatDate}} at {{deadline.dueTime}}

{{urgentAction}}

**Current Status:** {{currentStatus}}

{{#if riskFlag}}
⚠️ HIGH RISK: {{riskReason}}
{{/if}}

**Immediate Actions:**
1. [Mark Complete]({{markCompleteUrl}}) - If already done
2. [Request Extension]({{requestExtensionUrl}}) - If need more time
3. [Contact Party]({{contactUrl}}) - {{primaryContact}}

Don't let this deadline slip!

— Homer Pro
```

### Agent SMS (Always sent at 2-day)
```
⚠️ 2 DAYS: {{deadline.name}} due {{deadline.dueDate | formatShortDate}} for {{deal.address.street}}. {{urgentActionShort}} Reply DONE when complete.
```

### Buyer/Seller SMS
```
Hi {{party.firstName}}, reminder: {{deadline.name}} for {{deal.address.street}} is due in 2 days ({{deadline.dueDate | formatShortDate}}). Please {{actionRequired}}. Questions? Call {{agent.phone}}
```

## Escalation Rules

| Condition | Escalation Action |
|-----------|------------------|
| No response to 5-day alert | Phone call queue |
| Contract deadline + first-time buyer | Extra SMS reminder |
| Escrow deadline + no wire confirmation | Call buyer directly |
| Closing deadline | Alert all parties |
| High-value deal (>$500K) | CC broker |
| Multiple missed deadlines on deal | Schedule agent call |

## Notification Intensity

| Category | Agent Email | Agent SMS | Agent Push | Client Email | Client SMS |
|----------|-------------|-----------|------------|--------------|------------|
| INSPECTION | ✓ | ✓ | ✓ | ✓ | ✓ |
| FINANCING | ✓ | ✓ | ✓ | ✓ | ✓ |
| APPRAISAL | ✓ | ✓ | ✓ | ✓ | ✓ |
| ESCROW | ✓ | ✓ | ✓ | ✓ | ✓ |
| TITLE | ✓ | ✓ | ✓ | - | - |
| HOA | ✓ | ✓ | ✓ | ✓ | - |
| CLOSING | ✓ | ✓ | ✓ | ✓ | ✓ |
| INSURANCE | ✓ | ✓ | ✓ | ✓ | - |

## Skip Conditions

- Deadline already completed or waived
- 2-day alert already sent
- Deal is not active
- Party explicitly opted out of SMS
- Outside agent's notification hours (unless CLOSING)

## Quality Checklist

- [x] Identifies all 2-day deadlines accurately
- [x] Applies timezone correctly
- [x] Always sends SMS to agent (higher urgency than 5-day)
- [x] Generates single, clear action item
- [x] Assesses completion risk
- [x] Escalates appropriately
- [x] Respects opt-out preferences (except critical)
- [x] Prevents duplicate alerts
- [x] Logs all notifications
- [x] Provides direct action links

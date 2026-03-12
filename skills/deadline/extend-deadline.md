# Skill: Extend Deadline

**Category:** Deadline
**Priority:** P0
**Approval Required:** Conditional (based on deadline type and extension length)

## Purpose

Extend a deadline to a new date, automatically handling weekend/holiday adjustments, updating all related parties, and generating appropriate extension addendums if required by contract.

## Triggers

### Voice Commands
- "Extend the inspection deadline to [date]"
- "Push back the financing contingency by [X] days"
- "Move the closing date to [date]"
- "Need more time for [deadline type]"
- "Request extension for [deadline]"

### System Events
- Extension request from buyer/seller agent
- Lender delays requiring closing extension
- Failed inspection requiring more time

## Input

```typescript
{
  dealId: string;
  deadlineId?: string;              // Specific deadline, or...
  deadlineCategory?: DeadlineCategory; // Find by category
  newDueDate?: Date;                // Specific new date, or...
  extensionDays?: number;           // Days to add
  reason: string;                   // Required for audit
  requiresCounterpartyApproval?: boolean; // Default: true for contract deadlines
  notifyParties?: PartyRole[];      // Who to notify
}
```

## Output

```typescript
{
  success: boolean;
  actionTaken: string;
  result: {
    deadline: Deadline;
    previousDueDate: Date;
    newDueDate: Date;
    extensionDays: number;
    extensionCount: number;         // Total extensions for this deadline
    documentGenerated?: {
      documentId: string;
      type: string;                 // 'extension_addendum'
      status: string;               // 'pending_signatures' | 'sent'
    };
    approvalRequired: boolean;
    approvalStatus?: string;
    notificationsSent: {
      party: string;
      channel: string;
      status: string;
    }[];
  };
  requiresApproval: boolean;
  approvalMessage?: string;
  nextSteps: string[];
}
```

## Execution Flow

```
START
  │
  ├─── 1. Validate inputs
  │    ├── Verify deal exists and is active
  │    ├── Find deadline (by ID or category)
  │    ├── Verify deadline not already completed/waived
  │    └── Calculate new due date if not provided
  │
  ├─── 2. Apply Florida weekend/holiday rules
  │    ├── If new date falls on Saturday → move to Friday
  │    ├── If new date falls on Sunday → move to Monday
  │    ├── Check Florida/federal holiday list
  │    └── Adjust if falls on holiday
  │
  ├─── 3. Assess approval requirements
  │    │
  │    ├── IF deadline.category IN [INSPECTION, FINANCING, APPRAISAL]:
  │    │   └── Contract deadline - requires counterparty signature
  │    │
  │    ├── IF deadline.category = CLOSING:
  │    │   └── Requires all parties + lender approval
  │    │
  │    ├── IF deadline.category IN [TITLE, INSURANCE, HOA]:
  │    │   └── Administrative - can extend with notice only
  │    │
  │    └── IF extensionDays > 14:
  │        └── Flag for agent review regardless of type
  │
  ├─── 4. Check approval gates
  │    │
  │    ├── IF requires agent approval AND NOT pre-approved:
  │    │   ├── Create approval request
  │    │   ├── Return with requiresApproval: true
  │    │   └── PAUSE (await approval callback)
  │    │
  │    └── IF approved OR no approval needed:
  │        └── CONTINUE
  │
  ├─── 5. Update deadline
  │    ├── Store previous due date
  │    ├── Set new due date
  │    ├── Increment extension_count
  │    ├── Update status to 'extended'
  │    └── Log change in audit trail
  │
  ├─── 6. Generate extension document (if contract deadline)
  │    │
  │    ├── IF requires written addendum:
  │    │   │
  │    │   ├── SELECT template based on deadline type:
  │    │   │   ├── INSPECTION → inspection-extension.md
  │    │   │   ├── FINANCING → financing-extension.md
  │    │   │   ├── CLOSING → closing-extension.md
  │    │   │   └── OTHER → general-extension.md
  │    │   │
  │    │   ├── Generate document with:
  │    │   │   ├── Original deadline date
  │    │   │   ├── New deadline date
  │    │   │   ├── Extension reason
  │    │   │   └── Required signatures
  │    │   │
  │    │   └── Queue for DocuSign
  │    │
  │    └── IF no addendum needed:
  │        └── Skip document generation
  │
  ├─── 7. Recalculate dependent deadlines
  │    │
  │    ├── IF deadline is CLOSING:
  │    │   ├── Recalculate all closing-relative deadlines
  │    │   │   ├── Final walkthrough (typically closing - 1 day)
  │    │   │   ├── Wire instructions due (typically closing - 3 days)
  │    │   │   ├── Clear to close (typically closing - 5 days)
  │    │   │   └── Any custom closing-relative deadlines
  │    │   └── Update deal.closingDate
  │    │
  │    └── IF deadline affects others:
  │        └── Cascade update as needed
  │
  ├─── 8. Send notifications
  │    │
  │    ├── Notify all relevant parties:
  │    │   ├── Buyer/Seller (always)
  │    │   ├── Both agents (always)
  │    │   ├── Title company (if closing extended)
  │    │   ├── Lender (if financing or closing extended)
  │    │   └── Custom notification list
  │    │
  │    └── Use appropriate template:
  │        ├── contract_deadline_extended (for contract deadlines)
  │        └── admin_deadline_updated (for administrative)
  │
  ├─── 9. Log action
  │    ├── Create action_log entry
  │    ├── Store previous/new state
  │    └── Link to generated document if any
  │
  └─── 10. Return result
```

## Extension Rules by Category

| Deadline Type | Addendum Required | Signatures Needed | Can Auto-Approve |
|--------------|-------------------|-------------------|------------------|
| Inspection Period | Yes | Buyer + Seller | No |
| Financing Contingency | Yes | Buyer + Seller | No |
| Appraisal Contingency | Yes | Buyer + Seller | No |
| Closing Date | Yes | All parties + Lender | No |
| Title Commitment | No | None | Yes (≤7 days) |
| Survey | No | None | Yes (≤7 days) |
| Insurance | No | None | Yes (≤7 days) |
| HOA Docs | No | None | Yes (≤7 days) |

## Notification Templates

### Contract Deadline Extended
```
Subject: 📅 Extension Notice - {{deadline.name}} - {{deal.address.street}}

{{agent.name}},

The {{deadline.name}} has been extended:

Previous Due Date: {{previousDueDate | formatDate}}
New Due Date: {{newDueDate | formatDate}}
Extension: {{extensionDays}} days

Reason: {{reason}}

{{#if documentGenerated}}
An extension addendum has been prepared and sent to all parties for signature via DocuSign.
{{/if}}

{{#if dependentDeadlinesUpdated}}
The following deadlines have been automatically adjusted:
{{#each dependentDeadlines}}
- {{this.name}}: Now due {{this.newDueDate | formatDate}}
{{/each}}
{{/if}}

— Homer Pro
```

### Administrative Deadline Updated
```
Subject: 📋 Deadline Updated - {{deadline.name}}

The {{deadline.name}} deadline has been updated to {{newDueDate | formatDate}}.

This is an administrative update. No signatures required.

— Homer Pro
```

## Approval Conditions

Homer will auto-approve extensions when ALL conditions are met:
- Deadline category is administrative (not contract contingency)
- Extension is 7 days or fewer
- Agent has enabled auto-approve for this deadline type
- No previous extensions exceed configured limits

Homer will request approval when ANY condition is met:
- Deadline is a contract contingency (inspection, financing, appraisal)
- Extension is more than 14 days
- This is the 3rd or more extension for this deadline
- Agent has disabled auto-approve for deadline type
- Extension would push past contract closing date

## Error Handling

| Error | Cause | Response |
|-------|-------|----------|
| `DEADLINE_NOT_FOUND` | Invalid deadline ID | Return error, suggest available deadlines |
| `DEADLINE_COMPLETED` | Deadline already done | Cannot extend completed deadlines |
| `INVALID_DATE` | New date in past | Reject, require future date |
| `DEAL_INACTIVE` | Deal not active | Cannot modify inactive deals |
| `PAST_CLOSING` | Extension would go past closing | Warn, suggest also extending closing |
| `TOO_MANY_EXTENSIONS` | Exceeds policy limit | Require explicit agent override |

## Example Usage

### Voice: "Extend the inspection deadline by 5 days"
```typescript
// Input parsed from voice
{
  dealId: "uuid-123",
  deadlineCategory: "INSPECTION",
  extensionDays: 5,
  reason: "Buyer needs more time for specialist inspections"
}

// Output
{
  success: true,
  actionTaken: "Extended inspection period by 5 days",
  result: {
    deadline: { /* updated deadline object */ },
    previousDueDate: "2026-01-20",
    newDueDate: "2026-01-27", // Adjusted from Saturday 25th to Monday 27th
    extensionDays: 5,
    extensionCount: 1,
    documentGenerated: {
      documentId: "uuid-doc",
      type: "inspection_extension_addendum",
      status: "sent"
    },
    approvalRequired: false,
    notificationsSent: [
      { party: "Buyer", channel: "email", status: "sent" },
      { party: "Seller", channel: "email", status: "sent" },
      { party: "Listing Agent", channel: "email", status: "sent" }
    ]
  },
  requiresApproval: false,
  nextSteps: [
    "Extension addendum sent for signatures",
    "Monitor for signature completion",
    "New deadline: January 27, 2026"
  ]
}
```

## Quality Checklist

- [x] Validates deadline exists and is extendable
- [x] Applies Florida weekend/holiday rules
- [x] Determines correct approval requirements
- [x] Generates appropriate extension addendum
- [x] Updates dependent deadlines (especially for closing)
- [x] Notifies all relevant parties
- [x] Creates complete audit trail
- [x] Handles all error cases gracefully
- [x] Returns clear next steps
- [x] Supports both voice and API triggers

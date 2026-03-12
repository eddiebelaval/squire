# Skill: Same-Day Deadline Alert

**Category:** Deadline
**Priority:** P0
**Approval Required:** No

## Purpose

Send critical same-day alerts to all relevant parties when a deadline is due TODAY. This is the highest-priority alert in the system. Missing a deadline in Florida real estate can void contracts, forfeit deposits, or waive contingency rights.

## Triggers

### Automatic (Primary)
- Scheduled job runs at 8:00 AM on deadline day
- Runs for every deadline with `due_date = TODAY` and `status != completed/waived`

### Manual
- Agent requests: "Send deadline alert for [deadline]"
- Escalation from overdue check

### Programmatic
- `POST /deadlines/:id/alert`
- Escalation system trigger

## Required Inputs

| Input | Type | Required | Source | Description |
|-------|------|----------|--------|-------------|
| `deadlineId` | UUID | Yes | scheduler/context | Deadline to alert on |

## Optional Inputs

| Input | Type | Default | Source | Description |
|-------|------|---------|--------|-------------|
| `channels` | string[] | ['email', 'sms', 'push'] | config | Alert channels to use |
| `additionalRecipients` | string[] | [] | manual | Extra people to notify |
| `customMessage` | string | null | manual | Custom alert message |

## Severity Classification

| Deadline Category | Severity | Consequence if Missed |
|-------------------|----------|----------------------|
| `inspection` | CRITICAL | Buyer loses right to cancel, accepts property as-is |
| `financing` | CRITICAL | Buyer may forfeit deposit |
| `escrow` | HIGH | Contract may become voidable |
| `appraisal` | HIGH | Contingency waived |
| `title` | MEDIUM | May delay closing |
| `closing` | CRITICAL | Breach of contract |
| `other` | MEDIUM | Varies |

## Alert Content by Severity

### CRITICAL Alert Template

```
🚨 CRITICAL DEADLINE TODAY 🚨

Property: {{deal.property_address}}
Deadline: {{deadline.name}}
Due: {{deadline.due_time}} TODAY ({{deadline.due_date}})

⚠️ CONSEQUENCE IF MISSED:
{{consequence_text}}

ACTION REQUIRED:
{{action_required}}

Reply DONE when complete.
Questions? Call {{agent.phone}}

---
Homer Pro | {{agent.name}}
```

### HIGH Alert Template

```
⚠️ DEADLINE TODAY

Property: {{deal.property_address}}
Deadline: {{deadline.name}}
Due: {{deadline.due_time}} TODAY

{{action_required}}

Reply DONE when complete or call {{agent.phone}}.

---
Homer Pro | {{agent.name}}
```

## Execution Flow

```
START
  │
  ├─── 1. Load deadline and deal data
  │    ├── Get deadline by ID
  │    ├── Verify deadline is due today
  │    ├── Check not already completed/waived
  │    ├── Get deal details
  │    └── Get all parties for this deal
  │
  ├─── 2. Determine severity and consequence
  │    ├── Map category to severity level
  │    ├── Get consequence text for this deadline type
  │    └── Get required action text
  │
  ├─── 3. Identify recipients
  │    ├── Get parties from deadline.alert_parties
  │    ├── Get contact info for each party
  │    ├── Always include listing agent
  │    └── Add any additional recipients
  │
  ├─── 4. Compose alert messages
  │    │
  │    ├── FOR EACH channel (email, SMS, push):
  │    │   ├── Select template based on severity
  │    │   ├── Fill template with deal/deadline data
  │    │   └── Adjust format for channel
  │    │       ├── Email: Full HTML with formatting
  │    │       ├── SMS: Concise, under 160 chars if possible
  │    │       └── Push: Title + short body
  │    │
  │    └── Create channel-specific versions
  │
  ├─── 5. Send alerts
  │    │
  │    ├── FOR EACH recipient:
  │    │   ├── FOR EACH enabled channel:
  │    │   │   ├── Send via appropriate service
  │    │   │   │   ├── Email: SendGrid
  │    │   │   │   ├── SMS: Twilio
  │    │   │   │   └── Push: Firebase/APNs
  │    │   │   ├── Create communication record
  │    │   │   └── Log delivery status
  │    │   │
  │    │   └── Update party.last_contacted_at
  │    │
  │    └── Update deadline.alerts_sent["0"] = timestamp
  │
  ├─── 6. Schedule follow-up check
  │    └── Schedule job for 2:00 PM to check if marked complete
  │
  ├─── 7. Log action
  │    └── action_type: 'deadline_alert_sent'
  │
  └─── 8. Return result
```

## Alert Messages by Deadline Type

### Inspection Period Ends

**Consequence:**
> After 5:00 PM today, the buyer loses the right to cancel the contract based on inspections or for any reason. The buyer will be deemed to have accepted the property in its current condition.

**Action Required:**
> Buyer must either:
> 1. Deliver written cancellation notice before 5:00 PM
> 2. Request repairs (must be done during inspection period)
> 3. Accept property as-is (no action needed)

### Financing Contingency Ends

**Consequence:**
> After 5:00 PM today, if the buyer cannot close due to financing issues, they may forfeit their escrow deposit.

**Action Required:**
> Confirm loan approval status with lender. If not approved:
> - Request extension from seller
> - Or cancel contract to protect deposit

### Escrow Deposit Due

**Consequence:**
> Failure to deliver the escrow deposit may allow the seller to void the contract.

**Action Required:**
> Buyer must deliver ${{escrow_amount}} to {{escrow_holder}} by 5:00 PM.

### Closing Date

**Consequence:**
> Failure to close on the scheduled date may constitute breach of contract.

**Action Required:**
> Confirm all parties and funds are ready for closing at {{closing_time}}.

## SMS Message Format

Due to 160-character limit, SMS is condensed:

```
🚨 DEADLINE TODAY: Inspection period ends 5PM.
123 Main St, Miami.
Buyer must cancel or accept by deadline.
Reply DONE when handled.
```

## Escalation Protocol

If deadline not marked complete by follow-up check:

```
2:00 PM CHECK
     │
     ├── If status = completed → END
     │
     └── If status != completed:
         │
         ├── Send escalation alert
         │   └── "Deadline in 3 hours - still not resolved"
         │
         ├── Alert agent directly
         │   └── SMS + Push notification
         │
         └── Schedule 4:00 PM final check
              │
              └── If still not complete:
                  ├── Call responsible party (if voice enabled)
                  └── Maximum escalation to agent
```

## Output

```typescript
{
  success: true,
  actionTaken: "Sent same-day deadline alert for Inspection Period Ends",
  result: {
    deadline: {
      id: "uuid",
      name: "Inspection Period Ends",
      dueDate: "2026-01-30",
      dueTime: "17:00"
    },
    alerts_sent: [
      {
        recipient: "John Smith (Buyer)",
        channels: ["email", "sms"],
        status: "delivered"
      },
      {
        recipient: "Bob Agent (Buyer's Agent)",
        channels: ["email", "sms", "push"],
        status: "delivered"
      },
      {
        recipient: "Gus Agent (Listing Agent)",
        channels: ["email", "push"],
        status: "delivered"
      }
    ],
    follow_up_scheduled: "2026-01-30T14:00:00Z",
    severity: "CRITICAL"
  }
}
```

## Voice Response (if manually triggered)

> "I've sent critical deadline alerts for the inspection period ending today at 5 PM.
>
> Alerts sent to:
> - John Smith, the buyer, via email and text
> - Bob, the buyer's agent, via email, text, and push
> - You'll get a push notification too
>
> I've scheduled a follow-up check at 2 PM. If it's not marked complete by then, I'll escalate.
>
> Do you want me to call the buyer directly?"

## Error Handling

| Error | Cause | Response |
|-------|-------|----------|
| `ALREADY_SENT` | Alert already sent today | "Same-day alert already sent at [time]. Send again anyway?" |
| `MISSING_CONTACT` | Party has no email/phone | "Can't reach [party] - no contact info. Please add their email or phone." |
| `DELIVERY_FAILED` | SMS/email failed | "Alert to [party] failed. Retrying... [result]" |
| `DEADLINE_PASSED` | It's after 5 PM | "This deadline has already passed. Should I send anyway?" |

## Quality Checklist

- [x] Runs automatically at 8 AM on deadline day
- [x] Classifies severity correctly by deadline type
- [x] Sends via all appropriate channels
- [x] Includes specific consequence for each deadline type
- [x] Includes clear action required
- [x] Schedules follow-up check
- [x] Escalates if not resolved
- [x] Creates audit trail
- [x] Handles delivery failures gracefully
- [x] Respects party notification preferences
- [x] Concise SMS within character limits
- [x] Agent always notified

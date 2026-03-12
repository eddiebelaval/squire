# Skill: Send SMS

**Category:** Communication
**Priority:** P0
**Approval Required:** Conditional (based on recipient and content)

## Purpose

Send SMS text messages to parties involved in transactions for time-sensitive communications, quick confirmations, and urgent alerts. SMS is reserved for high-priority, brief communications.

## Triggers

### Voice Commands
- "Text [party] about [topic]"
- "Send a text to the buyer"
- "SMS the seller that [message]"
- "Quick text to [name]"

### System Events
- Same-day deadline alerts
- Urgent document signing reminders
- Closing day confirmations
- Time-sensitive responses needed

## Input

```typescript
{
  dealId?: string;
  recipient: {
    type: 'party' | 'phone';
    partyRole?: PartyRole;
    partyId?: string;
    phone?: string;
    name?: string;
  };
  messageType:
    | 'deadline_urgent'
    | 'document_urgent'
    | 'confirmation_request'
    | 'status_brief'
    | 'custom';
  templateId?: string;
  body?: string;                     // Required if custom (max 160 chars for single SMS)
  templateData?: Record<string, any>;
  priority?: 'urgent' | 'normal';
  scheduledFor?: Date;
  requiresResponse?: boolean;        // Track if response expected
}
```

## Output

```typescript
{
  success: boolean;
  actionTaken: string;
  result: {
    messageId: string;
    status: 'sent' | 'queued' | 'scheduled' | 'delivered';
    recipient: {
      phone: string;
      name: string;
    };
    body: string;
    segments: number;                // SMS segments used
    sentAt?: Date;
    scheduledFor?: Date;
  };
  requiresApproval: boolean;
  approvalMessage?: string;
}
```

## Execution Flow

```
START
  │
  ├─── 1. Resolve recipient
  │    │
  │    ├── IF type = 'party':
  │    │   ├── Look up party in deal
  │    │   ├── Get phone and name
  │    │   ├── Verify phone exists
  │    │   └── Check SMS opt-in status
  │    │
  │    └── IF type = 'phone':
  │        ├── Validate phone format
  │        └── Format to E.164 (+1XXXXXXXXXX)
  │
  ├─── 2. Check SMS consent
  │    │
  │    ├── IF party has opted out:
  │    │   └── Return error, cannot send
  │    │
  │    └── IF no explicit opt-in:
  │        └── Flag for agent review
  │
  ├─── 3. Determine approval requirement
  │    │
  │    ├── AUTO-APPROVE:
  │    │   ├── System urgent alerts (deadlines, documents)
  │    │   ├── Confirmation requests for pending items
  │    │   └── Agent pre-approved message types
  │    │
  │    └── REQUIRES APPROVAL:
  │        ├── Custom messages
  │        ├── First SMS to a party
  │        ├── Messages outside business hours
  │        └── Messages to opposing parties
  │
  ├─── 4. Generate message
  │    │
  │    ├── IF messageType = template type:
  │    │   ├── Select appropriate template
  │    │   └── Apply templateData
  │    │
  │    └── IF messageType = 'custom':
  │        └── Use provided body
  │
  ├─── 5. Format message
  │    │
  │    ├── Ensure proper length:
  │    │   ├── Single SMS: 160 characters
  │    │   ├── Max length: 320 characters (2 segments)
  │    │   └── Warn if approaching limit
  │    │
  │    └── Add sender identification:
  │        └── "{{agent.firstName}} @ {{agent.brokerage | abbreviate}}: {{message}}"
  │
  ├─── 6. Check sending hours
  │    │
  │    ├── IF outside 8 AM - 9 PM recipient local time:
  │    │   │
  │    │   ├── IF priority = 'urgent':
  │    │   │   └── Send with warning logged
  │    │   │
  │    │   └── ELSE:
  │    │       └── Queue for next appropriate time
  │
  ├─── 7. Send or schedule
  │    │
  │    ├── IF scheduledFor is set:
  │    │   └── Queue for future send
  │    │
  │    └── ELSE:
  │        └── Send via Twilio
  │
  ├─── 8. Log communication
  │    │
  │    │   INSERT INTO communications (
  │    │     deal_id, type, direction, channel = 'sms',
  │    │     from_party_id, to_party_ids,
  │    │     body, external_id, sent_at
  │    │   )
  │
  └─── 9. Set up response tracking (if expected)
       ├── Create pending response record
       └── Set follow-up if no response in X hours
```

## SMS Templates

### Deadline Urgent
```
{{agent.firstName}}: ⚠️ URGENT - {{deadline.name}} due TODAY ({{deadline.dueDate | formatShortDate}}) for {{deal.address.street | abbreviateAddress}}. Please confirm status. Reply DONE if complete.
```
*~155 characters*

### Document Urgent
```
{{agent.firstName}}: 📄 Please sign {{document.name}} for {{deal.address.street | abbreviateAddress}}. Check email for DocuSign link. Due: {{deadline | formatShortDate}}
```
*~140 characters*

### Confirmation Request
```
{{agent.firstName}}: Quick confirmation needed for {{deal.address.street | abbreviateAddress}}: {{confirmationQuestion}} Reply YES or NO.
```
*~120 characters*

### Status Brief
```
{{agent.firstName}}: Update on {{deal.address.street | abbreviateAddress}}: {{statusMessage}}. Questions? Call me at {{agent.phone}}.
```
*~130 characters*

### Wire Fraud Warning
```
⚠️ WIRE FRAUD ALERT: NEVER send $ based on email instructions. ALWAYS call {{titleCompany.phone}} to verify wire info. -{{agent.firstName}}
```
*~140 characters*

## Approval Rules

| Scenario | Auto-Approve | Requires Approval |
|----------|--------------|-------------------|
| Same-day deadline alert | ✓ | - |
| Document signing reminder | ✓ | - |
| Wire fraud warning | ✓ | - |
| Closing day confirmation | ✓ | - |
| Custom message to client | - | ✓ |
| Message to opposing party | - | ✓ |
| First SMS to any party | - | ✓ |
| Outside business hours | - | ✓ |

## Time Restrictions

- **Normal messages**: 8 AM - 9 PM recipient local time
- **Urgent messages**: Can bypass with warning
- **Never send**: 10 PM - 7 AM unless explicit emergency

## Response Handling

When `requiresResponse: true`:
1. Track outbound message
2. Monitor for inbound response
3. Parse response (YES/NO/DONE/custom)
4. Update related records based on response
5. Alert agent if no response within expected time

### Response Keywords
| Keyword | Action |
|---------|--------|
| YES, Y, CONFIRM | Mark confirmed |
| NO, N | Mark declined, alert agent |
| DONE, COMPLETE | Mark task complete |
| STOP, UNSUBSCRIBE | Opt-out of SMS |
| ? or HELP | Send help message |

## Error Handling

| Error | Cause | Response |
|-------|-------|----------|
| `INVALID_PHONE` | Bad phone format | Return error, request correction |
| `PARTY_NO_PHONE` | Party missing phone | Alert agent |
| `OPTED_OUT` | Party opted out of SMS | Cannot send, use email |
| `TWILIO_FAILED` | API error | Retry 3x, then queue |
| `CARRIER_BLOCKED` | Carrier rejection | Log, try alternate method |

## Compliance Notes

- **TCPA Compliance**: Must have consent for marketing SMS
- **Transaction SMS**: Generally permitted for transaction-related messages
- **Opt-out**: Must honor STOP requests immediately
- **Identification**: Always identify sender in message
- **Hours**: Respect quiet hours (state-specific)

## Quality Checklist

- [x] Resolves party to phone number
- [x] Validates E.164 phone format
- [x] Checks SMS consent/opt-out status
- [x] Applies appropriate approval gates
- [x] Uses concise templates (≤160 chars ideal)
- [x] Identifies sender in message
- [x] Respects sending hours
- [x] Supports scheduled sending
- [x] Tracks expected responses
- [x] Handles opt-out keywords
- [x] Logs all SMS communications

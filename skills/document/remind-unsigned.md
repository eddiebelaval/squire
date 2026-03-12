# Skill: Remind Unsigned

**Category:** Document
**Priority:** P1
**Approval Required:** No (standard reminder) / Yes (escalated)

## Purpose

Send follow-up reminders to signers who haven't completed their signature on pending documents. Supports multiple reminder channels, escalation paths, and intelligent timing to maximize signature completion rates without annoying recipients.

## Triggers

### Voice Commands
- "Remind [person] to sign [document]"
- "Send reminder for [document/deal]"
- "Follow up on unsigned documents"
- "Nudge [name] about the [document]"
- "Send signature reminder"

### Programmatic
- `POST /documents/:documentId/remind`
- Scheduled reminder queue
- Overdue threshold trigger
- Agent-initiated bulk remind

### Automatic Triggers
- Document viewed but not signed after 24 hours
- Configured reminder interval elapsed
- Approaching expiration date
- Escalation threshold reached

## Required Inputs

| Input | Type | Required | Source | Description |
|-------|------|----------|--------|-------------|
| `documentId` | UUID | Yes* | context | Document needing reminder |
| `signerId` | string | Yes* | context | Specific signer to remind |
| `envelopeId` | string | Yes* | docusign | Direct envelope reference |

*At least one identifier required; signerId optional to remind all

## Optional Inputs

| Input | Type | Default | Source | Description |
|-------|------|---------|--------|-------------|
| `channel` | string | 'email' | voice/config | 'email', 'sms', 'both' |
| `message` | string | auto | voice | Custom reminder message |
| `urgency` | string | 'normal' | voice | 'gentle', 'normal', 'urgent' |
| `includeDeadline` | boolean | true | config | Mention deadline in message |
| `fromAgent` | boolean | false | voice | Send from agent vs DocuSign |
| `escalate` | boolean | false | voice | Escalate to broker/attorney |
| `suppressUntil` | Date | null | manual | Don't remind before date |

## Execution Flow

```
START
  │
  ├─── 1. Load reminder context
  │    ├── Get document and envelope status
  │    ├── Identify pending signers
  │    ├── Get reminder history
  │    └── Check suppression settings
  │
  ├─── 2. Validate reminder appropriateness
  │    │
  │    ├── Check last reminder time
  │    │   └── IF < 24 hours ago → suggest waiting
  │    │
  │    ├── Check reminder count
  │    │   └── IF > 3 reminders → suggest escalation
  │    │
  │    ├── Check business hours
  │    │   └── IF outside 8am-8pm → queue for later
  │    │
  │    └── Check signer preferences
  │        └── IF opted out of reminders → warn agent
  │
  ├─── 3. Determine reminder strategy
  │    │
  │    ├── IF first reminder:
  │    │   └── Use gentle tone
  │    │
  │    ├── IF second reminder:
  │    │   └── Use normal tone, mention deadline
  │    │
  │    ├── IF third+ reminder:
  │    │   └── Use urgent tone, offer alternatives
  │    │
  │    └── IF near expiration:
  │        └── Use urgent tone, emphasize expiration
  │
  ├─── 4. Select channel
  │    │
  │    ├── IF email (default):
  │    │   └── Send via DocuSign or direct email
  │    │
  │    ├── IF sms:
  │    │   ├── Check phone number available
  │    │   └── Send SMS with signing link
  │    │
  │    └── IF both:
  │        └── Send email + SMS
  │
  ├─── 5. Compose reminder message
  │    │
  │    ├── Use appropriate template for urgency
  │    ├── Personalize with signer name
  │    ├── Include document name
  │    ├── Include property address
  │    ├── Include deadline if applicable
  │    ├── Include direct signing link
  │    └── Add agent contact for questions
  │
  ├─── 6. Send reminder
  │    │
  │    ├── IF via DocuSign:
  │    │   └── POST /envelopes/{id}/recipients/{id}/remind
  │    │
  │    ├── IF direct email:
  │    │   └── INVOKE: send-email skill
  │    │
  │    └── IF SMS:
  │        └── INVOKE: send-sms skill
  │
  ├─── 7. Update tracking
  │    ├── Log reminder sent
  │    ├── Increment reminder count
  │    ├── Set next reminder time
  │    └── Update document record
  │
  ├─── 8. IF escalate requested:
  │    ├── Identify escalation recipient
  │    ├── Send escalation notice
  │    └── Log escalation
  │
  ├─── 9. Log action
  │    └── action_type: 'signature_reminder_sent'
  │
  └─── 10. Return result
```

## Reminder Templates

### Gentle (First Reminder)
```
Subject: Friendly reminder: Signature needed for {{property_address}}

Hi {{signer.firstName}},

Just a friendly reminder that the {{document.name}} for {{property_address}}
is waiting for your signature.

You can sign it in just a few minutes:
{{signingLink}}

If you have any questions, I'm happy to help.

Best,
{{agent.name}}
{{agent.phone}}
```

### Normal (Second Reminder)
```
Subject: Signature needed: {{document.name}} - {{property_address}}

Hi {{signer.firstName}},

I wanted to follow up on the {{document.name}} for {{property_address}}.

Your signature is needed to keep the transaction moving forward.
{{#if deadline}}
The deadline for this document is {{deadline | formatDate}}.
{{/if}}

Please sign when you have a moment:
{{signingLink}}

Let me know if you have any questions or concerns.

{{agent.name}}
{{agent.phone}}
```

### Urgent (Third+ or Near Expiration)
```
Subject: URGENT: Signature required today - {{property_address}}

Hi {{signer.firstName}},

This is an urgent reminder that the {{document.name}} for {{property_address}}
requires your immediate attention.

{{#if expiresAt}}
⚠️ This document expires on {{expiresAt | formatDate}}.
{{/if}}

{{#if deadline}}
⚠️ The deadline is {{deadline | formatDate}}.
{{/if}}

Please sign now to avoid delays:
{{signingLink}}

If you're having trouble signing or have questions, please call me
immediately at {{agent.phone}}.

{{agent.name}}
```

### SMS Template
```
{{signer.firstName}}, please sign {{document.name}} for {{property_address}}.
{{#if deadline}}Due: {{deadline | shortDate}}.{{/if}}
Sign here: {{shortLink}}
Questions? {{agent.phone}}
```

## Reminder Schedule

| Reminder # | Default Timing | Tone | Channel |
|------------|---------------|------|---------|
| Auto-1 | DocuSign default (2 days) | Gentle | Email |
| Agent-1 | On request | Gentle | Email |
| Agent-2 | 24h+ after first | Normal | Email |
| Agent-3 | 24h+ after second | Urgent | Email + SMS |
| Agent-4+ | Consider escalation | Urgent | Email + call |

## Output

```typescript
{
  success: true,
  actionTaken: "Sent signature reminder to Jane Doe",
  result: {
    reminder: {
      documentId: "doc-uuid",
      documentName: "Inspection Extension Addendum",
      property: "123 Main St, Miami FL 33101"
    },
    recipient: {
      name: "Jane Doe",
      email: "jane@email.com",
      phone: "+13055551234",
      role: "seller"
    },
    delivery: {
      channels: ["email", "sms"],
      emailSentAt: "2026-01-15T14:30:00Z",
      smsSentAt: "2026-01-15T14:30:05Z",
      signingLink: "https://docusign.com/sign/..."
    },
    history: {
      reminderNumber: 2,
      previousReminders: [
        { date: "2026-01-13T10:00:00Z", channel: "email" }
      ]
    },
    status: {
      documentSentAt: "2026-01-12T09:00:00Z",
      viewedAt: "2026-01-12T11:30:00Z",
      daysWaiting: 3,
      expiresAt: "2026-01-19T09:00:00Z"
    },
    nextSteps: [
      "Reminder sent via email and SMS",
      "Jane has viewed the document - may be hesitant",
      "If no response by tomorrow, consider calling"
    ]
  }
}
```

## Voice Response

**Standard reminder:**
> "I've sent Jane Doe a reminder about the inspection extension.
>
> This is her second reminder - I sent it via email and text.
>
> She viewed the document 3 days ago but hasn't signed. You might want to call her if she doesn't respond today."

**First reminder:**
> "Sent a friendly reminder to John Smith about the closing extension.
>
> This is the first follow-up. He should get the email shortly with a direct link to sign."

**Suggesting escalation:**
> "I've sent 3 reminders to Bob Johnson with no response. At this point, you might want to:
>
> Call him directly, have the listing agent reach out, or consider if there's an issue we need to address.
>
> Want me to set up a call reminder for you?"

## Escalation Flow

When escalation is needed:

```typescript
const escalationPath = {
  // First escalation: to other agent
  level1: {
    trigger: "3 reminders, no response",
    action: "Notify other party's agent",
    message: "We need help getting [party] to sign"
  },

  // Second escalation: to broker
  level2: {
    trigger: "5 days overdue, level 1 failed",
    action: "Notify broker",
    message: "Signature deadline at risk"
  },

  // Third escalation: formal notice
  level3: {
    trigger: "At deadline, no signature",
    action: "Generate formal notice",
    message: "Contract deadline notice required"
  }
};
```

## Error Handling

| Error | Cause | Response |
|-------|-------|----------|
| `ALREADY_SIGNED` | Signer completed | "Good news - Jane actually signed about an hour ago!" |
| `ENVELOPE_COMPLETED` | All signed | "This document is already fully signed." |
| `TOO_SOON` | Recent reminder | "I sent a reminder 4 hours ago. Want to wait until tomorrow?" |
| `NO_CONTACT` | Missing email/phone | "I don't have Jane's phone number for SMS. Send email only?" |
| `OPTED_OUT` | Signer blocked | "This signer has opted out of DocuSign emails. Try calling directly." |
| `ENVELOPE_EXPIRED` | Past expiration | "This envelope has expired. I'll need to resend the document." |

## Smart Timing

```typescript
// Optimal reminder timing
const reminderTiming = {
  // Best times to send reminders
  optimalHours: [9, 10, 14, 15], // 9-10am and 2-3pm

  // Avoid
  avoidHours: [0, 1, 2, 3, 4, 5, 6, 7, 21, 22, 23], // Night
  avoidDays: [0, 6], // Weekend (unless urgent)

  // If requested outside optimal time
  queueForOptimal: true,

  // Unless marked urgent
  urgentOverridesSchedule: true
};
```

## Bulk Reminders

```typescript
// Remind all pending signers
{
  scope: "all_pending",
  filters: {
    daysWaiting: { min: 2 },
    reminderCount: { max: 2 },
    excludeViewed: false // Include those who viewed
  },
  message: "Batch signature follow-up",
  channel: "email"
}
```

## Integration Points

### Invokes
- DocuSign Resend API
- `send-email` - Direct email reminders
- `send-sms` - Text message reminders

### Invoked By
- `track-signatures` - When overdue detected
- Scheduled reminder queue
- Agent voice command
- Dashboard action

### Webhook Events
- Uses reminder delivery confirmation
- Updates on signer action after reminder

## Quality Checklist

- [x] Respects reminder frequency limits
- [x] Adapts tone based on reminder count
- [x] Supports multiple channels
- [x] Includes direct signing link
- [x] Tracks reminder history
- [x] Suggests escalation when appropriate
- [x] Respects business hours
- [x] Handles opted-out signers
- [x] Works with bulk reminders
- [x] Natural voice responses
- [x] Complete audit trail
- [x] Smart timing optimization

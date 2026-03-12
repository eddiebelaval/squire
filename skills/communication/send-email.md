# Skill: Send Email

**Category:** Communication
**Priority:** P0
**Approval Required:** Conditional (based on recipient and content type)

## Purpose

Compose and send emails on behalf of the agent to parties involved in transactions. Handles templated communications, custom messages, and maintains proper email threading for deal correspondence.

## Triggers

### Voice Commands
- "Email [party] about [topic]"
- "Send an update to the buyer"
- "Notify the seller about [issue]"
- "Email the lender requesting [item]"
- "Send a status update on [property]"

### System Events
- Deadline alerts (skill calls send-email)
- Document completion notifications
- Status change notifications

## Input

```typescript
{
  dealId?: string;                   // Link to deal (optional for general emails)
  recipients: {
    to: {
      type: 'party' | 'email';
      partyRole?: PartyRole;         // If type = 'party'
      partyId?: string;              // Specific party ID
      email?: string;                // If type = 'email'
      name?: string;
    }[];
    cc?: { /* same structure */ }[];
    bcc?: { /* same structure */ }[];
  };
  emailType:
    | 'status_update'
    | 'deadline_reminder'
    | 'document_request'
    | 'document_sent'
    | 'meeting_request'
    | 'custom'
    | 'template';
  templateId?: string;               // If emailType = 'template'
  subject?: string;                  // Required if custom
  body?: string;                     // Required if custom
  templateData?: Record<string, any>; // For template substitution
  attachments?: {
    documentId?: string;             // From documents table
    url?: string;                    // External URL
    filename: string;
  }[];
  priority?: 'high' | 'normal' | 'low';
  scheduledFor?: Date;               // Send later
  replyToMessageId?: string;         // Thread with existing email
  trackOpens?: boolean;              // Default: true
  trackClicks?: boolean;             // Default: true
}
```

## Output

```typescript
{
  success: boolean;
  actionTaken: string;
  result: {
    messageId: string;
    status: 'sent' | 'queued' | 'scheduled';
    recipients: {
      email: string;
      name: string;
      status: string;
    }[];
    subject: string;
    sentAt?: Date;
    scheduledFor?: Date;
    threadId?: string;
    trackingId?: string;
  };
  requiresApproval: boolean;
  approvalMessage?: string;
}
```

## Execution Flow

```
START
  │
  ├─── 1. Resolve recipients
  │    │
  │    ├── FOR EACH recipient:
  │    │   │
  │    │   ├── IF type = 'party':
  │    │   │   ├── Look up party in deal
  │    │   │   ├── Get email and name
  │    │   │   └── Verify email exists
  │    │   │
  │    │   └── IF type = 'email':
  │    │       ├── Validate email format
  │    │       └── Use provided name or extract from email
  │    │
  │    └── Deduplicate recipients across to/cc/bcc
  │
  ├─── 2. Determine approval requirement
  │    │
  │    ├── AUTO-APPROVE (no approval needed):
  │    │   ├── System-generated notifications
  │    │   ├── Deadline reminders
  │    │   ├── Document sent confirmations
  │    │   └── Agent explicitly pre-approved
  │    │
  │    ├── REQUIRES APPROVAL:
  │    │   ├── Custom emails to clients
  │    │   ├── Emails to opposing parties
  │    │   ├── First contact with any party
  │    │   ├── Emails with attachments
  │    │   └── High priority emails
  │    │
  │    └── IF requires approval AND NOT approved:
  │        ├── Present email preview to agent
  │        ├── Return with requiresApproval: true
  │        └── PAUSE (await approval)
  │
  ├─── 3. Generate email content
  │    │
  │    ├── IF emailType = 'template':
  │    │   ├── Load template from communication_templates
  │    │   ├── Apply templateData substitutions
  │    │   └── Generate subject and body
  │    │
  │    ├── IF emailType = 'custom':
  │    │   └── Use provided subject and body
  │    │
  │    └── IF emailType = system type:
  │        ├── Select appropriate system template
  │        └── Apply deal context
  │
  ├─── 4. Apply agent signature
  │    │
  │    │   {{body}}
  │    │
  │    │   Best regards,
  │    │   {{agent.name}}
  │    │   {{agent.brokerage}}
  │    │   {{agent.phone}} | {{agent.email}}
  │    │   {{#if agent.licenseNumber}}License #{{agent.licenseNumber}}{{/if}}
  │    │
  │    │   ---
  │    │   Sent via Homer Pro
  │
  ├─── 5. Process attachments
  │    │
  │    ├── FOR EACH attachment:
  │    │   ├── IF documentId: Fetch from documents table
  │    │   ├── IF url: Validate accessible
  │    │   └── Attach to email
  │    │
  │    └── Verify total size < 25MB
  │
  ├─── 6. Send or schedule
  │    │
  │    ├── IF scheduledFor is set:
  │    │   ├── Queue for future send
  │    │   └── Create scheduled_jobs entry
  │    │
  │    └── ELSE:
  │        └── Send immediately via SendGrid
  │
  ├─── 7. Log communication
  │    │
  │    │   INSERT INTO communications (
  │    │     deal_id, type, direction, channel,
  │    │     from_party_id, to_party_ids,
  │    │     subject, body, attachments,
  │    │     external_id, sent_at
  │    │   )
  │
  ├─── 8. Set up tracking
  │    ├── IF trackOpens: Enable open tracking
  │    └── IF trackClicks: Enable click tracking
  │
  └─── 9. Return result
```

## Email Templates

### Status Update
```
Subject: Transaction Update - {{deal.address.street}}

Hi {{recipient.firstName}},

Here's a quick update on your transaction at {{deal.address.street}}:

**Current Status:** {{deal.status | formatStatus}}
**Progress:** {{dealProgress.percentComplete}}% complete

{{#if recentMilestones}}
**Recently Completed:**
{{#each recentMilestones}}
✓ {{this.name}} - {{this.completedAt | formatDate}}
{{/each}}
{{/if}}

{{#if upcomingDeadlines}}
**Upcoming Deadlines:**
{{#each upcomingDeadlines}}
• {{this.name}} - Due {{this.dueDate | formatDate}}
{{/each}}
{{/if}}

{{#if customMessage}}
{{customMessage}}
{{/if}}

Please let me know if you have any questions.

{{signature}}
```

### Deadline Reminder
```
Subject: {{#if urgent}}⚠️ {{/if}}Reminder: {{deadline.name}} Due {{deadline.dueDate | formatDate}}

Hi {{recipient.firstName}},

This is a reminder about an upcoming deadline for {{deal.address.street}}:

**{{deadline.name}}**
Due: {{deadline.dueDate | formatDate}} {{#if deadline.dueTime}}at {{deadline.dueTime}}{{/if}}

{{#if actionRequired}}
**Action Required:** {{actionRequired}}
{{/if}}

{{#if preparationItems}}
**To prepare:**
{{#each preparationItems}}
• {{this}}
{{/each}}
{{/if}}

Please let me know if you have any questions or need assistance.

{{signature}}
```

### Document Request
```
Subject: Document Request - {{deal.address.street}}

Hi {{recipient.firstName}},

I need the following document(s) for your transaction at {{deal.address.street}}:

{{#each requestedDocuments}}
• **{{this.name}}**{{#if this.description}} - {{this.description}}{{/if}}
{{/each}}

{{#if deadline}}
Please provide by: {{deadline | formatDate}}
{{/if}}

You can reply to this email with the documents attached, or upload them directly through our secure portal.

Thank you for your prompt attention to this request.

{{signature}}
```

### Document Sent
```
Subject: Document for Your Signature - {{document.name}}

Hi {{recipient.firstName}},

A document requires your signature for the transaction at {{deal.address.street}}:

**Document:** {{document.name}}
**Sent via:** DocuSign

You should receive a separate email from DocuSign with instructions to review and sign the document electronically.

{{#if deadline}}
Please sign by: {{deadline | formatDate}}
{{/if}}

If you have any questions about the document before signing, please don't hesitate to reach out.

{{signature}}
```

## Approval Rules

| Scenario | Auto-Approve | Requires Approval |
|----------|--------------|-------------------|
| System deadline alert | ✓ | - |
| Document sent notification | ✓ | - |
| Status update to own client | ✓ | - |
| Custom email to own client | - | ✓ |
| Any email to opposing party | - | ✓ |
| Email with attachments | - | ✓ |
| First contact with party | - | ✓ |
| High priority email | - | ✓ |

## Error Handling

| Error | Cause | Response |
|-------|-------|----------|
| `INVALID_EMAIL` | Bad email format | Return error, ask for correction |
| `PARTY_NO_EMAIL` | Party missing email | Alert agent, request email |
| `ATTACHMENT_TOO_LARGE` | > 25MB total | Suggest splitting or using links |
| `SENDGRID_FAILED` | API error | Retry 3x, then queue for later |
| `TEMPLATE_NOT_FOUND` | Invalid template ID | Fall back to custom or error |

## Tracking Webhooks

Handle SendGrid webhook events:
- `delivered` → Update communication status
- `opened` → Log open event with timestamp
- `clicked` → Log click event with link
- `bounced` → Alert agent, mark email invalid
- `spam_report` → Remove from future sends

## Quality Checklist

- [x] Resolves party roles to actual email addresses
- [x] Applies appropriate approval gates
- [x] Uses correct template for email type
- [x] Includes proper agent signature
- [x] Handles attachments securely
- [x] Supports scheduled sending
- [x] Maintains email threading
- [x] Logs all communications
- [x] Tracks opens and clicks
- [x] Handles delivery failures gracefully

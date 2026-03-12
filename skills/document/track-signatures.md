# Skill: Track Signatures

**Category:** Document
**Priority:** P1
**Approval Required:** No

## Purpose

Monitor the signature status of documents sent via DocuSign. Provides real-time status updates, identifies bottlenecks, and enables proactive follow-up on pending signatures.

## Triggers

### Voice Commands
- "What's the signature status on [document/deal]?"
- "Who hasn't signed [document]?"
- "Check on signatures for [address]"
- "Where are we with the [document type]?"
- "Signature status update"
- "Any pending signatures?"

### Programmatic
- `GET /documents/:documentId/signature-status`
- `GET /deals/:dealId/signatures`
- Dashboard refresh
- Scheduled status checks

## Required Inputs

| Input | Type | Required | Source | Description |
|-------|------|----------|--------|-------------|
| `documentId` | UUID | Yes* | context | Specific document to check |
| `dealId` | UUID | Yes* | context | All docs for a deal |
| `envelopeId` | string | Yes* | docusign | Direct envelope lookup |

*At least one identifier required

## Optional Inputs

| Input | Type | Default | Source | Description |
|-------|------|---------|--------|-------------|
| `includeHistory` | boolean | false | manual | Include signature history |
| `includeTimeline` | boolean | true | config | Show timeline view |
| `sinceDays` | number | 30 | config | Look back period |
| `status` | string[] | all | manual | Filter by status |

## Execution Flow

```
START
  │
  ├─── 1. Determine scope
  │    │
  │    ├── IF documentId:
  │    │   └── Get single document signature status
  │    │
  │    ├── IF dealId:
  │    │   └── Get all documents for deal with pending/recent signatures
  │    │
  │    └── IF neither (general query):
  │        └── Get all pending signatures for agent
  │
  ├─── 2. Fetch DocuSign status
  │    │
  │    ├── FOR EACH envelope:
  │    │   ├── GET /envelopes/{envelopeId}
  │    │   ├── GET /envelopes/{envelopeId}/recipients
  │    │   └── GET /envelopes/{envelopeId}/audit_events (if history)
  │    │
  │    └── Handle API rate limits gracefully
  │
  ├─── 3. Process recipient status
  │    │
  │    ├── FOR EACH recipient:
  │    │   ├── Map DocuSign status to readable status
  │    │   ├── Calculate time since sent
  │    │   ├── Calculate time waiting
  │    │   ├── Identify if overdue
  │    │   └── Determine if blocking others
  │    │
  │    └── Status mapping:
  │        ├── 'created' → 'Waiting'
  │        ├── 'sent' → 'Sent'
  │        ├── 'delivered' → 'Viewed'
  │        ├── 'signed' → 'Signed'
  │        ├── 'completed' → 'Complete'
  │        ├── 'declined' → 'Declined'
  │        └── 'autoresponded' → 'Out of Office'
  │
  ├─── 4. Calculate metrics
  │    ├── Total documents pending
  │    ├── Average time to signature
  │    ├── Bottleneck identification
  │    ├── Documents at risk (nearing expiration)
  │    └── Completion rate
  │
  ├─── 5. Build timeline (if requested)
  │    ├── Created → Sent → Viewed → Signed → Complete
  │    ├── Include timestamps for each stage
  │    └── Highlight current stage
  │
  ├─── 6. Identify action items
  │    ├── Overdue signatures (needs reminder)
  │    ├── Viewed but not signed (engagement opportunity)
  │    ├── Expiring soon (urgent action)
  │    └── Declined (requires attention)
  │
  ├─── 7. Update local records
  │    ├── Sync status with database
  │    ├── Update last_checked timestamp
  │    └── Flag any status changes
  │
  ├─── 8. Log action
  │    └── action_type: 'signature_status_checked'
  │
  └─── 9. Return result
```

## Status Definitions

| Status | Description | Icon | Action Needed |
|--------|-------------|------|---------------|
| `waiting` | In queue, waiting for prior signer | ⏳ | None - sequential |
| `sent` | Email sent, not opened | 📤 | Maybe remind |
| `delivered` | Email opened, doc not viewed | 📬 | Maybe remind |
| `viewed` | Document viewed, not signed | 👀 | Consider reminder |
| `signed` | This recipient signed | ✅ | None |
| `declined` | Recipient declined | ❌ | Action required |
| `completed` | All parties signed | 🎉 | Process complete |
| `voided` | Envelope cancelled | 🚫 | Resend if needed |
| `expired` | Envelope expired | ⌛ | Resend |

## Output

```typescript
{
  success: true,
  actionTaken: "Retrieved signature status for 3 documents",
  result: {
    summary: {
      total: 3,
      pending: 2,
      completed: 1,
      overdue: 1,
      atRisk: 0
    },
    documents: [
      {
        document: {
          id: "doc-1",
          name: "Inspection Extension Addendum",
          type: "addendum",
          deal: {
            id: "deal-uuid",
            address: "123 Main St, Miami FL 33101"
          }
        },
        envelope: {
          id: "env-abc123",
          status: "sent",
          createdAt: "2026-01-14T10:00:00Z",
          expiresAt: "2026-01-21T10:00:00Z",
          daysRemaining: 6
        },
        signers: [
          {
            name: "John Smith",
            email: "john@email.com",
            role: "buyer",
            status: "signed",
            statusDisplay: "Signed",
            signedAt: "2026-01-14T15:30:00Z",
            timeline: {
              sent: "2026-01-14T10:00:00Z",
              delivered: "2026-01-14T10:05:00Z",
              viewed: "2026-01-14T15:25:00Z",
              signed: "2026-01-14T15:30:00Z"
            }
          },
          {
            name: "Jane Doe",
            email: "jane@email.com",
            role: "seller",
            status: "delivered",
            statusDisplay: "Viewed",
            sentAt: "2026-01-14T15:31:00Z",
            viewedAt: "2026-01-15T09:00:00Z",
            hoursWaiting: 5,
            isOverdue: false,
            isBlocking: false
          }
        ],
        completionPercentage: 50,
        estimatedCompletion: "2026-01-15",
        needsAttention: false
      },
      {
        document: {
          id: "doc-2",
          name: "Repair Credit Addendum",
          type: "addendum",
          deal: {
            id: "deal-uuid-2",
            address: "456 Oak Ave, Miami FL 33102"
          }
        },
        envelope: {
          id: "env-def456",
          status: "sent",
          createdAt: "2026-01-10T14:00:00Z",
          expiresAt: "2026-01-17T14:00:00Z",
          daysRemaining: 2
        },
        signers: [
          {
            name: "Bob Johnson",
            email: "bob@email.com",
            role: "buyer",
            status: "sent",
            statusDisplay: "Sent - Not Opened",
            sentAt: "2026-01-10T14:00:00Z",
            hoursWaiting: 120,  // 5 days
            isOverdue: true,
            isBlocking: true
          },
          {
            name: "Alice Williams",
            email: "alice@email.com",
            role: "seller",
            status: "waiting",
            statusDisplay: "Waiting for Bob",
            isBlocking: false
          }
        ],
        completionPercentage: 0,
        needsAttention: true,
        attentionReason: "Buyer has not opened document in 5 days"
      }
    ],
    actionItems: [
      {
        type: "overdue",
        document: "doc-2",
        signer: "Bob Johnson",
        message: "Bob Johnson hasn't opened the Repair Credit Addendum in 5 days",
        suggestedAction: "Send reminder or call",
        priority: "high"
      }
    ],
    nextSteps: [
      "Jane Doe has viewed the Inspection Extension - waiting for signature",
      "Bob Johnson is overdue - consider sending a reminder or calling",
      "One document completed today"
    ]
  }
}
```

## Voice Response

**Single document query:**
> "The inspection extension is waiting on Jane Doe. She viewed it this morning but hasn't signed yet.
>
> John Smith signed yesterday afternoon. Once Jane signs, I'll update the deadline automatically.
>
> Want me to send her a reminder?"

**Deal overview:**
> "You have 3 documents pending signatures for 123 Main Street:
>
> The inspection extension is almost done - just waiting on the seller.
>
> The repair credit hasn't been opened by the buyer in 5 days - that's overdue.
>
> The closing extension was completed this morning.
>
> Want me to send a reminder for the repair credit?"

**General status:**
> "You have 8 documents pending signatures across 5 deals.
>
> 3 are on track, 2 need attention - buyers haven't opened them in over 3 days.
>
> Would you like details on the overdue ones?"

## Bottleneck Analysis

```typescript
// Identify who's holding things up
const bottleneckAnalysis = {
  // Most common blockers
  frequentBlockers: [
    { name: "John Smith", overdueCount: 3, avgDelayDays: 4.2 }
  ],

  // Stage where things get stuck
  stuckStages: {
    sent: 5,      // Sent but not opened
    viewed: 3,    // Viewed but not signed
    waiting: 2    // Waiting for prior signer
  },

  // Document types with slowest completion
  slowDocuments: [
    { type: "amendment", avgDays: 5.3 },
    { type: "addendum", avgDays: 2.1 }
  ]
};
```

## Error Handling

| Error | Cause | Response |
|-------|-------|----------|
| `DOCUMENT_NOT_FOUND` | Invalid documentId | "I can't find that document. Which one are you asking about?" |
| `NO_SIGNATURE_REQUEST` | Doc not sent for signature | "This document hasn't been sent for signature yet." |
| `DOCUSIGN_API_ERROR` | API issue | "Having trouble reaching DocuSign. Status may be slightly delayed." |
| `ENVELOPE_NOT_FOUND` | Envelope deleted | "This signature request may have been voided or deleted." |

## Proactive Monitoring

### Scheduled Checks
- Every 15 minutes: Check for completed signatures
- Every hour: Update all pending signature status
- Daily morning: Generate signature summary for agent

### Automatic Alerts
| Trigger | Alert |
|---------|-------|
| Document signed | "John Smith signed the inspection extension" |
| All signed | "Inspection extension fully executed! Updating deal..." |
| Viewed but 24h+ no action | "Jane viewed the addendum yesterday but hasn't signed" |
| 48h+ not opened | "Bob hasn't opened the repair credit in 2 days" |
| Nearing expiration | "Closing extension expires tomorrow" |
| Declined | "ALERT: Jane Doe declined the addendum" |

## Integration Points

### Invokes
- DocuSign API (Envelopes, Recipients)
- `remind-unsigned` - When overdue detected
- `void-document` - When user requests

### Invoked By
- Voice queries
- Dashboard refresh
- Scheduled tasks
- Webhook events (status sync)

### Database Updates
- `signature_requests` - Status updates
- `documents` - Completion status
- `deals` - When all signatures complete

## Quality Checklist

- [x] Real-time DocuSign status sync
- [x] Clear status mapping to readable terms
- [x] Timeline view for each signer
- [x] Bottleneck identification
- [x] Overdue detection
- [x] Expiration warnings
- [x] Action item generation
- [x] Completion percentage
- [x] Deal-level aggregation
- [x] Agent-level dashboard
- [x] Natural voice responses
- [x] Proactive alerting

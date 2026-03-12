# Skill: Void Document

**Category:** Document
**Priority:** P1
**Approval Required:** Yes (always)

## Purpose

Cancel a document's signature request in DocuSign, preventing further signatures and invalidating any signatures already collected. This is a critical skill for handling mistakes, changed circumstances, or superseded documents.

## Triggers

### Voice Commands
- "Void the [document] for [address]"
- "Cancel the signature request for [document]"
- "Stop the [document type] from being signed"
- "Withdraw the [document]"
- "Kill the [envelope/document]"

### Programmatic
- `POST /documents/:documentId/void`
- Dashboard "Void Document" action
- Superseded document auto-void

## Required Inputs

| Input | Type | Required | Source | Description |
|-------|------|----------|--------|-------------|
| `documentId` | UUID | Yes* | context | Document to void |
| `envelopeId` | string | Yes* | docusign | Direct envelope ID |
| `reason` | string | Yes | voice/manual | Why voiding (required) |

*Either `documentId` OR `envelopeId` required

## Optional Inputs

| Input | Type | Default | Source | Description |
|-------|------|---------|--------|-------------|
| `notifySigners` | boolean | true | config | Notify signers of void |
| `voidMessage` | string | auto | manual | Custom message to signers |
| `supersededBy` | UUID | null | system | New document replacing this |
| `confirmVoid` | boolean | false | voice | User confirmed void |

## Execution Flow

```
START
  │
  ├─── 1. Validate void request
  │    ├── Verify document exists
  │    ├── Get envelope status from DocuSign
  │    ├── Verify envelope is voidable
  │    │   └── Cannot void: completed, already voided
  │    └── Require reason
  │
  ├─── 2. Check void implications
  │    │
  │    ├── IF partially signed:
  │    │   └── Warn: "John already signed. This will invalidate their signature."
  │    │
  │    ├── IF near deadline:
  │    │   └── Warn: "This deadline is tomorrow. Are you resending?"
  │    │
  │    └── IF linked to deal updates:
  │        └── Note: "The [pending change] will not be applied."
  │
  ├─── 3. Request confirmation (if not confirmed)
  │    └── "Are you sure you want to void the [document]? [implications]"
  │
  ├─── 4. Execute void in DocuSign
  │    ├── PUT /envelopes/{envelopeId}
  │    │   status: "voided"
  │    │   voidedReason: reason
  │    └── Handle API response
  │
  ├─── 5. Update local records
  │    ├── Document status: 'voided'
  │    ├── Store void reason
  │    ├── Store void timestamp
  │    ├── Clear pending deal updates
  │    └── Link to superseding document if applicable
  │
  ├─── 6. Notify relevant parties
  │    │
  │    ├── IF notifySigners:
  │    │   └── DocuSign sends automatic notification
  │    │
  │    ├── Notify agent (confirmation)
  │    │
  │    └── IF other agent involved:
  │        └── Notify other agent
  │
  ├─── 7. Handle related items
  │    │
  │    ├── Cancel scheduled reminders
  │    ├── Remove from pending signature queue
  │    │
  │    ├── IF deadline was being extended:
  │    │   └── Restore original deadline alert
  │    │
  │    └── IF supersededBy provided:
  │        └── Link documents for reference
  │
  ├─── 8. Log action
  │    └── action_type: 'document_voided'
  │        reason: provided reason
  │        partialSignatures: list of who had signed
  │
  └─── 9. Return result
```

## Void Reasons (Suggested)

| Reason | When to Use |
|--------|-------------|
| `error_in_document` | Typo, wrong info, mistake |
| `terms_changed` | Parties agreed to different terms |
| `superseded` | New document replaces this one |
| `deal_cancelled` | Transaction fell through |
| `wrong_parties` | Sent to wrong people |
| `duplicate` | Accidentally sent twice |
| `no_longer_needed` | Circumstances changed |
| `expired_resending` | Will resend with new deadline |
| `party_request` | Signer asked to void |

## Output

```typescript
{
  success: true,
  actionTaken: "Voided inspection extension addendum for 123 Main St",
  result: {
    document: {
      id: "doc-uuid",
      name: "Inspection Extension Addendum",
      previousStatus: "pending_signature",
      newStatus: "voided",
      voidedAt: "2026-01-15T14:30:00Z"
    },
    envelope: {
      id: "env-abc123",
      status: "voided",
      voidedReason: "Terms changed - new extension date negotiated"
    },
    signaturesInvalidated: [
      {
        name: "John Smith",
        role: "buyer",
        signedAt: "2026-01-14T15:30:00Z",
        notified: true
      }
    ],
    pendingSigners: [
      {
        name: "Jane Doe",
        role: "seller",
        notified: true
      }
    ],
    relatedActions: [
      "Cancelled 2 scheduled reminders",
      "Removed from pending signature queue",
      "Restored original inspection deadline"
    ],
    nextSteps: [
      "All parties have been notified",
      "John Smith's signature has been invalidated",
      "Create new document if needed"
    ]
  }
}
```

## Voice Response

**Standard void:**
> "I've voided the inspection extension addendum.
>
> John Smith had already signed - his signature has been invalidated and he's been notified.
>
> Jane Doe was notified that the document has been cancelled.
>
> Do you want me to create a new one with updated terms?"

**Void with superseding document:**
> "I've voided the old inspection extension. The new one with the February 10th deadline is already out for signature.
>
> Both parties know the old document is cancelled."

## Confirmation Dialog

```typescript
// When confirmation required
{
  requiresConfirmation: true,
  message: "Are you sure you want to void the Inspection Extension Addendum?",
  implications: [
    "John Smith has already signed - his signature will be invalidated",
    "Both parties will be notified",
    "The extension to February 4th will NOT take effect"
  ],
  options: [
    { label: "Yes, void it", action: "confirm_void" },
    { label: "No, keep it", action: "cancel" }
  ]
}
```

## Error Handling

| Error | Cause | Response |
|-------|-------|----------|
| `ENVELOPE_COMPLETED` | Already fully signed | "This document is already fully signed. It can't be voided." |
| `ALREADY_VOIDED` | Already voided | "This document was already voided on [date]." |
| `ENVELOPE_NOT_FOUND` | Invalid envelope | "I can't find this signature request in DocuSign." |
| `REASON_REQUIRED` | No reason given | "I need a reason for voiding. What happened?" |
| `DOCUSIGN_ERROR` | API failure | "DocuSign returned an error. Let me try again." |
| `UNAUTHORIZED` | No permission | "You don't have permission to void this document." |

## Auto-Void Scenarios

Automatic voiding when:

```typescript
const autoVoidTriggers = {
  // New document of same type created
  supersededDocument: {
    trigger: "New document with same type and deal",
    action: "Prompt to void old or keep both",
    autoVoid: false // Always ask
  },

  // Deal cancelled
  dealCancelled: {
    trigger: "Deal status → cancelled",
    action: "Offer to void all pending documents",
    autoVoid: false // Always ask
  },

  // Envelope expired
  envelopeExpired: {
    trigger: "DocuSign envelope expired",
    action: "Update status, notify agent",
    autoVoid: true // Auto-update status
  }
};
```

## Partial Signature Handling

When voiding a partially signed document:

1. **Invalidate existing signatures** - DocuSign handles this
2. **Notify signed parties** - Let them know their signature is void
3. **Log invalidated signatures** - Audit trail
4. **Warn agent** - Make clear the implications

```typescript
// Response when partially signed
{
  warning: "This document has partial signatures",
  signedBy: ["John Smith (buyer)"],
  awaitingSignature: ["Jane Doe (seller)"],
  impact: "John Smith's signature will be invalidated. He will need to sign again on any replacement document."
}
```

## Integration Points

### Invokes
- DocuSign Void API
- Notification system

### Invoked By
- Agent voice command
- Dashboard action
- Deal cancellation workflow
- Document supersession

### Database Updates
- `documents` - Status to 'voided'
- `signature_requests` - Mark voided
- `scheduled_reminders` - Cancel
- `action_log` - Void entry

## Quality Checklist

- [x] Always requires reason
- [x] Always requires confirmation
- [x] Handles partial signatures gracefully
- [x] Notifies all relevant parties
- [x] Cancels scheduled reminders
- [x] Cleans up pending deal updates
- [x] Links to superseding documents
- [x] Creates complete audit trail
- [x] Cannot void completed documents
- [x] Clear voice responses with implications
- [x] Supports auto-void scenarios
- [x] Handles DocuSign errors gracefully

# Skill: Compliance Audit Trail

**Category:** Compliance
**Priority:** P0
**Approval Required:** No

## Purpose

Maintain comprehensive audit trails for all compliance-related actions in Florida real estate transactions. Ensures regulatory compliance, provides legal protection, and enables reconstruction of transaction history when disputes arise.

## Legal Authority

- **FREC Rule 61J2-14.012** - Record retention requirements
- **Florida Statutes §475.5015** - Broker record keeping
- **Florida Statutes §119** - Public records (if applicable)
- **RESPA** - Settlement procedure documentation
- **TILA** - Truth in Lending documentation
- **E-SIGN Act** - Electronic signature records
- **Florida Statutes §668.50** - UETA (electronic records)

## Triggers

### Voice Commands
- "Show me the audit trail"
- "What happened on this deal?"
- "When was [action] taken?"
- "Who sent what when?"
- "Pull the transaction history"
- "Document this conversation"

### Programmatic
- Any compliance action completed
- Document uploaded/signed
- Deadline passed or met
- Party added or changed
- Status changed
- Communication sent
- Dispute initiated

## Required Inputs

| Input | Type | Required | Source | Description |
|-------|------|----------|--------|-------------|
| `dealId` | UUID | Yes | context | Deal to audit |
| `actionType` | string | Yes | action | Type of action logged |
| `timestamp` | DateTime | Yes | system | When action occurred |

## Optional Inputs

| Input | Type | Default | Source | Description |
|-------|------|---------|--------|-------------|
| `actor` | string | null | context | Who performed action |
| `details` | object | {} | action | Action-specific data |
| `documentId` | UUID | null | action | Related document |
| `ipAddress` | string | null | system | Origin IP |
| `userAgent` | string | null | system | Browser/client info |

## Audit Event Types

### Transaction Events

| Event Type | Description | Required Fields |
|------------|-------------|-----------------|
| `deal_created` | New deal initiated | address, agent, source |
| `deal_updated` | Deal info changed | field_changed, old_value, new_value |
| `status_changed` | Deal status changed | old_status, new_status, reason |
| `party_added` | Party added to deal | party_name, role, contact |
| `party_updated` | Party info changed | party_id, field_changed |
| `party_removed` | Party removed | party_id, reason |

### Document Events

| Event Type | Description | Required Fields |
|------------|-------------|-----------------|
| `document_uploaded` | Doc added to deal | doc_type, filename, uploader |
| `document_viewed` | Doc accessed | doc_id, viewer |
| `document_signed` | Signature obtained | doc_id, signer, method |
| `document_sent` | Doc sent to party | doc_id, recipient, method |
| `document_deleted` | Doc removed | doc_id, reason, deleter |

### Deadline Events

| Event Type | Description | Required Fields |
|------------|-------------|-----------------|
| `deadline_created` | Deadline set | type, date, responsible |
| `deadline_modified` | Deadline changed | old_date, new_date, reason |
| `deadline_reminder_sent` | Reminder sent | deadline_id, recipient |
| `deadline_met` | Deadline completed | deadline_id, completion_date |
| `deadline_missed` | Deadline passed | deadline_id, consequence |

### Compliance Events

| Event Type | Description | Required Fields |
|------------|-------------|-----------------|
| `disclosure_provided` | Disclosure given | disclosure_type, recipient |
| `disclosure_signed` | Disclosure signed | disclosure_type, signer |
| `escrow_received` | Deposit received | amount, holder, method |
| `escrow_released` | Deposit disbursed | amount, recipient, reason |
| `escrow_disputed` | Dispute initiated | amount, claimants |
| `compliance_check_run` | Compliance verified | check_type, result |
| `cancellation_notice` | Cancel notice sent | party, reason, method |

### Communication Events

| Event Type | Description | Required Fields |
|------------|-------------|-----------------|
| `email_sent` | Email sent | recipient, subject, body_preview |
| `email_received` | Email received | sender, subject |
| `sms_sent` | Text sent | recipient, content |
| `call_logged` | Phone call noted | party, duration, notes |
| `voicemail_left` | VM left | recipient, transcript |
| `meeting_held` | Meeting occurred | attendees, notes |

## Record Retention Requirements

### FREC Requirements (§475.5015)

```
RETENTION PERIOD: 5 YEARS
─────────────────────────
All transaction records must be retained for 5 years
from the date of closing OR from the date the listing
or agency agreement expires, whichever is later.

RECORDS REQUIRED:
- Listing agreements
- Purchase contracts
- Addenda and amendments
- Closing statements
- Correspondence
- Trust account records
- Commission disbursements
```

### Recommended Retention by Document Type

| Document Type | Minimum Retention | Reason |
|---------------|-------------------|--------|
| Purchase Contract | 5 years | FREC requirement |
| Disclosures | 5 years | FREC requirement |
| Closing Documents | 7 years | Tax records |
| Escrow Records | 5 years | FREC requirement |
| Correspondence | 5 years | FREC requirement |
| Audit Logs | 7 years | Legal protection |
| Electronic Signatures | 5 years | E-SIGN/UETA |

## Audit Log Schema

```typescript
interface AuditLogEntry {
  // Identity
  id: UUID;
  dealId: UUID;

  // Event
  eventType: string;
  eventCategory: 'transaction' | 'document' | 'deadline' | 'compliance' | 'communication';
  description: string;

  // Timing
  timestamp: DateTime;
  timezone: string;

  // Actor
  actorId: UUID | null;
  actorType: 'user' | 'agent' | 'system' | 'party';
  actorName: string;
  actorEmail: string | null;

  // Context
  ipAddress: string | null;
  userAgent: string | null;
  sessionId: string | null;

  // Details
  details: {
    [key: string]: any;
  };

  // Related Records
  relatedDocumentId: UUID | null;
  relatedPartyId: UUID | null;
  relatedDeadlineId: UUID | null;

  // Integrity
  previousLogId: UUID | null;  // Chain to previous entry
  checksum: string;            // SHA-256 of entry

  // Metadata
  createdAt: DateTime;
  source: 'web' | 'mobile' | 'voice' | 'api' | 'system';
}
```

## Execution Flow

```
START
  │
  ├─── For LOGGING an action:
  │    │
  │    ├── 1. Capture event data
  │    │    ├── Event type and category
  │    │    ├── Timestamp (server time, UTC)
  │    │    ├── Actor information
  │    │    └── Action-specific details
  │    │
  │    ├── 2. Add integrity fields
  │    │    ├── Link to previous log entry
  │    │    ├── Calculate checksum
  │    │    └── Add source and session info
  │    │
  │    ├── 3. Store immutably
  │    │    ├── Insert to audit_log table
  │    │    ├── No updates allowed
  │    │    └── Deletions create correction entry
  │    │
  │    └── 4. Return confirmation
  │
  ├─── For RETRIEVING audit trail:
  │    │
  │    ├── 1. Query parameters
  │    │    ├── Deal ID
  │    │    ├── Date range
  │    │    ├── Event types
  │    │    └── Actor filter
  │    │
  │    ├── 2. Fetch and verify
  │    │    ├── Get log entries
  │    │    ├── Verify checksum chain
  │    │    └── Flag any gaps
  │    │
  │    ├── 3. Format for display
  │    │    ├── Chronological order
  │    │    ├── Group by date
  │    │    └── Human-readable descriptions
  │    │
  │    └── 4. Return audit trail
  │
  └─── END
```

## Output

### Logging an Action

```typescript
{
  success: true,
  actionTaken: "Logged audit entry",
  result: {
    logId: "log_abc123",
    dealId: "deal_456",
    eventType: "document_signed",
    timestamp: "2026-01-25T14:32:15.000Z",
    description: "FAR/BAR Contract signed by John Smith (Buyer)",
    checksumValid: true
  }
}
```

### Retrieving Audit Trail

```typescript
{
  success: true,
  actionTaken: "Retrieved audit trail for 123 Main St",
  result: {
    dealId: "deal_456",
    totalEntries: 47,
    dateRange: {
      from: "2026-01-15",
      to: "2026-01-25"
    },
    integrityCheck: {
      verified: true,
      gaps: 0,
      invalidChecksums: 0
    },
    timeline: [
      {
        date: "2026-01-25",
        entries: [
          {
            time: "14:32:15",
            eventType: "document_signed",
            actor: "John Smith",
            description: "Signed FAR/BAR Contract",
            details: {
              documentId: "doc_789",
              signatureMethod: "electronic",
              ipAddress: "192.168.1.100"
            }
          },
          {
            time: "10:15:22",
            actor: "Homer Pro",
            eventType: "reminder_sent",
            description: "Sent deposit deadline reminder to buyer",
            details: {
              recipient: "john.smith@email.com",
              deadlineDate: "2026-01-27"
            }
          }
        ]
      },
      {
        date: "2026-01-20",
        entries: [
          {
            time: "09:00:00",
            actor: "System",
            eventType: "escrow_received",
            description: "Initial deposit received by ABC Title",
            details: {
              amount: 10000,
              holder: "ABC Title Company",
              method: "wire_transfer"
            }
          }
        ]
      }
    ],
    exportFormats: ["pdf", "csv", "json"]
  }
}
```

## Voice Response

**Logging:**
> "Logged. I've recorded that John Smith signed the contract at 2:32 PM today. This is now part of the permanent transaction record."

**Retrieving:**
> "Here's the audit trail for 123 Main Street. There have been 47 actions since January 15th. Most recent: the contract was signed today at 2:32 PM. Before that, escrow was received on January 20th. Want me to email you the full timeline?"

**Compliance Check:**
> "I've verified the audit trail integrity. All 47 entries have valid checksums with no gaps. This record would hold up to FREC audit requirements. The retention period extends until 2031."

## Immutability Rules

### What Cannot Be Changed

```
IMMUTABLE FIELDS:
─────────────────
- Log ID
- Deal ID
- Timestamp
- Event type
- Actor information
- IP address
- Checksum
- Previous log reference

CORRECTION PROCEDURE:
─────────────────────
If an entry needs correction:
1. Create NEW entry with eventType "correction"
2. Reference original entry in details
3. Explain what was wrong
4. Provide corrected information

Original entry remains in chain unchanged.
```

### Tampering Detection

```
CHECKSUM CHAIN:
──────────────
Each entry's checksum includes:
- Previous entry's checksum
- Current entry data
- Timestamp
- Deal ID

If any entry is modified, the chain breaks.
System detects gap or invalid checksum.
```

## Error Handling

| Error | Cause | Response |
|-------|-------|----------|
| `LOG_WRITE_FAILED` | Database error | "Failed to log action. Retrying... If persists, action recorded offline." |
| `CHAIN_BROKEN` | Tampering or corruption | "Warning: Audit trail integrity issue detected. Investigating..." |
| `DEAL_NOT_FOUND` | Invalid deal ID | "I can't find that deal. Can you verify the address or deal ID?" |
| `DATE_RANGE_INVALID` | Bad date parameters | "That date range isn't valid. What dates are you looking for?" |

## Integration Points

### Automatic Logging Triggers

Every skill should call audit logging:
- Before: Log intention/request
- After: Log result/outcome

Example from other skills:
```typescript
// At start of action
await auditLog({
  dealId,
  eventType: 'escrow_check_started',
  actor: currentUser,
  details: { reason: 'compliance_check' }
});

// After action completes
await auditLog({
  dealId,
  eventType: 'escrow_verified',
  actor: 'system',
  details: { amount: 10000, status: 'received' }
});
```

### Database Tables

- `audit_log` - Main audit trail (append-only)
- `audit_log_archive` - Archived entries (> 2 years)
- `audit_integrity` - Chain verification status

### Export Capabilities

- PDF report (formatted timeline)
- CSV export (for analysis)
- JSON export (for system integration)
- FREC-compliant package (all docs + timeline)

## Quality Checklist

- [x] Logs all compliance-relevant actions
- [x] Captures actor and timestamp
- [x] Maintains immutable chain
- [x] Detects tampering
- [x] Meets FREC 5-year retention
- [x] Supports multiple export formats
- [x] Voice-friendly retrieval
- [x] Links to related documents
- [x] Provides integrity verification
- [x] Enables dispute reconstruction

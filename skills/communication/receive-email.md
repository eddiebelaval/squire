# Skill: Receive Email

**Category:** Communication
**Priority:** P0
**Approval Required:** No (processing is automatic; actions may require approval)

## Purpose

Parse and process incoming emails from parties involved in transactions. Extract intent, attachments, and context to route appropriately, update deal status, and trigger follow-up actions. Acts as the intelligent email inbox manager for the agent.

## Triggers

### System Events
- Incoming email to agent's monitored inbox
- Email forwarded to Homer Pro processing address
- Reply to Homer-sent email (via Message-ID/References)

### Integration Points
- SendGrid Inbound Parse webhook
- Gmail API push notifications
- Outlook Graph API subscriptions

## Input

```typescript
{
  rawEmail: {
    messageId: string;
    from: {
      email: string;
      name?: string;
    };
    to: { email: string; name?: string }[];
    cc?: { email: string; name?: string }[];
    replyTo?: string;
    subject: string;
    textBody?: string;
    htmlBody?: string;
    headers: Record<string, string>;
    inReplyTo?: string;                 // Threading reference
    references?: string[];               // Thread chain
    receivedAt: Date;
  };
  attachments?: {
    filename: string;
    contentType: string;
    size: number;
    content: Buffer | string;           // Base64 or buffer
  }[];
  spamScore?: number;
  authenticated?: {
    spf: 'pass' | 'fail' | 'none';
    dkim: 'pass' | 'fail' | 'none';
    dmarc: 'pass' | 'fail' | 'none';
  };
}
```

## Output

```typescript
{
  success: boolean;
  actionTaken: string;
  result: {
    emailId: string;                    // Internal reference
    classification: {
      intent: EmailIntent;
      confidence: number;
      dealId?: string;                  // Matched deal
      partyId?: string;                 // Matched sender
      priority: 'urgent' | 'high' | 'normal' | 'low';
      category: EmailCategory;
    };
    extractedData: {
      dates?: Date[];                   // Mentioned dates
      amounts?: number[];               // Dollar amounts
      addresses?: string[];             // Property addresses
      documentReferences?: string[];    // Referenced documents
      questions?: string[];             // Questions to answer
      requestedActions?: string[];      // What sender wants
    };
    attachmentResults?: {
      filename: string;
      documentId?: string;              // If stored
      classification?: string;          // Document type
      extracted?: Record<string, any>;  // Extracted data
    }[];
    actionsTriggered: {
      action: string;
      status: 'completed' | 'pending_approval' | 'queued';
    }[];
    responseNeeded: boolean;
    suggestedResponse?: {
      subject: string;
      body: string;
      requiresApproval: boolean;
    };
  };
  shouldContinue: boolean;
}
```

## Type Definitions

```typescript
type EmailIntent =
  | 'question'                          // Asking for information
  | 'document_submission'               // Sending documents
  | 'status_request'                    // Asking for update
  | 'confirmation'                      // Confirming something
  | 'scheduling'                        // About appointments
  | 'issue_report'                      // Reporting a problem
  | 'negotiation'                       // Offer/counteroffer
  | 'approval'                          // Approving something
  | 'rejection'                         // Declining something
  | 'information'                       // Providing information
  | 'introduction'                      // New party introduction
  | 'forward'                           // Forwarded for awareness
  | 'spam'                              // Junk/irrelevant
  | 'unknown';

type EmailCategory =
  | 'transaction_critical'              // Affects deal progress
  | 'transaction_routine'               // Normal deal communication
  | 'scheduling'                        // Appointments/showings
  | 'marketing'                         // Newsletters, promotions
  | 'personal'                          // Non-transaction related
  | 'automated'                         // Auto-replies, notifications
  | 'spam';
```

## Execution Flow

```
START
  |
  +--- 1. Validate email
  |    |
  |    +-- Check spam score (reject if > threshold)
  |    +-- Verify authentication (SPF/DKIM/DMARC)
  |    +-- Check if from blocked sender
  |    +-- Sanitize HTML content
  |
  +--- 2. Identify sender
  |    |
  |    +-- Search parties by email:
  |    |   |
  |    |   +-- FOUND:
  |    |   |   +-- Get party details
  |    |   |   +-- Get associated deals
  |    |   |   +-- Set context from party role
  |    |   |
  |    |   +-- NOT FOUND:
  |    |       +-- Check if known domain (title, lender, etc.)
  |    |       +-- Flag as potential new party
  |    |       +-- Extract name from email signature
  |    |
  |    +-- Check if reply to existing thread:
  |        +-- Link to original communication
  |        +-- Inherit deal context
  |
  +--- 3. Match to deal
  |    |
  |    +-- IF sender linked to deal:
  |    |   +-- Use that deal
  |    |
  |    +-- IF multiple deals:
  |    |   +-- Analyze content for property reference
  |    |   +-- Match by address mention
  |    |   +-- Match by MLS number
  |    |   +-- Match by recent activity
  |    |
  |    +-- IF no deal match:
  |        +-- Check if new deal inquiry
  |        +-- Route to agent for classification
  |
  +--- 4. Classify intent
  |    |
  |    +-- Analyze subject line
  |    +-- Analyze body content
  |    +-- Consider sender role context
  |    +-- Check for urgency indicators:
  |    |   +-- Keywords: urgent, asap, today, immediately
  |    |   +-- Punctuation: !!!, ???
  |    |   +-- All caps
  |    |
  |    +-- Assign intent with confidence score
  |    +-- Determine priority level
  |
  +--- 5. Extract structured data
  |    |
  |    +-- Dates (parse various formats)
  |    +-- Dollar amounts
  |    +-- Property addresses
  |    +-- Document names
  |    +-- Question sentences
  |    +-- Action requests
  |    +-- Phone numbers
  |
  +--- 6. Process attachments
  |    |
  |    +-- FOR EACH attachment:
  |    |   |
  |    |   +-- Validate file type (reject dangerous)
  |    |   +-- Check size limits
  |    |   +-- Scan for malware
  |    |   |
  |    |   +-- Classify document type:
  |    |   |   +-- Contract, amendment, disclosure
  |    |   |   +-- Financial (pre-approval, proof of funds)
  |    |   |   +-- ID documents
  |    |   |   +-- Inspection report
  |    |   |   +-- Other
  |    |   |
  |    |   +-- Store in documents table
  |    |   +-- Link to deal
  |    |   +-- Extract relevant data from document
  |    |
  |    +-- Update deal document checklist
  |
  +--- 7. Trigger automated actions
  |    |
  |    +-- BASED ON INTENT:
  |    |
  |    +-- document_submission:
  |    |   +-- File documents
  |    |   +-- Update checklist
  |    |   +-- Send receipt confirmation
  |    |
  |    +-- status_request:
  |    |   +-- Generate status update
  |    |   +-- Queue for send (or auto-send if simple)
  |    |
  |    +-- scheduling:
  |    |   +-- Check calendar availability
  |    |   +-- Propose times or confirm
  |    |
  |    +-- confirmation:
  |    |   +-- Update related task/deadline
  |    |   +-- Log confirmation
  |    |
  |    +-- issue_report:
  |    |   +-- Create task for agent
  |    |   +-- Escalate if urgent
  |    |
  |    +-- negotiation:
  |    |   +-- Alert agent immediately
  |    |   +-- Do not auto-respond
  |
  +--- 8. Generate response suggestion
  |    |
  |    +-- IF response warranted:
  |    |   +-- Draft appropriate response
  |    |   +-- Apply agent's tone/style
  |    |   +-- Include relevant deal context
  |    |   +-- Flag for approval if needed
  |    |
  |    +-- IF auto-response appropriate:
  |        +-- Send acknowledgment
  |        +-- "Thank you, we've received..."
  |
  +--- 9. Log communication
  |    |
  |    |   INSERT INTO communications (
  |    |     deal_id, type, direction = 'inbound', channel = 'email',
  |    |     from_party_id, to_party_ids,
  |    |     subject, body, attachments,
  |    |     external_id = messageId,
  |    |     metadata = { classification, extractedData }
  |    |   )
  |
  +--- 10. Notify agent if needed
  |    |
  |    +-- IF priority = 'urgent':
  |    |   +-- Push notification
  |    |   +-- SMS alert
  |    |
  |    +-- IF requires human judgment:
  |    |   +-- Add to agent task queue
  |    |
  |    +-- IF routine:
  |        +-- Include in daily digest
  |
  +--- 11. Return result
```

## Intent Classification Rules

| Indicators | Intent | Confidence Boost |
|------------|--------|------------------|
| "?" in subject or body | question | +0.3 |
| Attachment present | document_submission | +0.4 |
| "status", "update", "where are we" | status_request | +0.4 |
| "confirm", "yes", "approved" | confirmation | +0.4 |
| "schedule", "available", "meeting" | scheduling | +0.4 |
| "problem", "issue", "concern" | issue_report | +0.4 |
| "offer", "counter", "negotiate" | negotiation | +0.5 |
| No-reply sender | automated | +0.6 |
| Known spam patterns | spam | +0.7 |

## Priority Determination

| Factor | Priority Impact |
|--------|-----------------|
| Sender is buyer/seller client | +1 level |
| Deal closing within 7 days | +1 level |
| Urgency keywords present | +1 level |
| Negotiation content | Set to urgent |
| Issue/problem reported | +1 level |
| Automated/marketing email | Set to low |

## Auto-Response Rules

| Scenario | Action |
|----------|--------|
| Document received | Send "Received, thank you" |
| After hours + simple question | "I'll respond tomorrow" |
| Status request + deal active | Send automated status |
| Out of office detected | Acknowledge, set expectation |
| Spam detected | Ignore, log |

## Attachment Handling

### Allowed File Types
- Documents: .pdf, .doc, .docx, .xls, .xlsx
- Images: .jpg, .jpeg, .png, .gif, .tiff
- Archives: .zip (scan contents)

### Blocked File Types
- Executables: .exe, .bat, .sh, .cmd
- Scripts: .js, .vbs, .ps1
- Unknown/suspicious types

### Size Limits
- Single attachment: 25 MB
- Total attachments: 50 MB
- Oversized handling: Notify sender, request cloud link

## Thread Management

- Link replies via In-Reply-To header
- Maintain thread in communications table
- Surface full thread context for responses
- Track thread participants

## Error Handling

| Error | Cause | Response |
|-------|-------|----------|
| `PARSE_FAILED` | Malformed email | Log, alert admin |
| `ATTACHMENT_VIRUS` | Malware detected | Quarantine, alert agent |
| `ATTACHMENT_TOO_LARGE` | Exceeds limits | Auto-reply requesting smaller |
| `UNKNOWN_SENDER` | No party match | Queue for agent classification |
| `MULTI_DEAL_AMBIGUOUS` | Can't match deal | Ask agent to classify |
| `CLASSIFICATION_LOW_CONFIDENCE` | Unclear intent | Queue for human review |

## Quality Checklist

- [x] Validates email authenticity (SPF/DKIM/DMARC)
- [x] Identifies sender and links to party
- [x] Matches email to correct deal
- [x] Classifies intent with confidence score
- [x] Extracts structured data (dates, amounts, etc.)
- [x] Processes and classifies attachments
- [x] Scans attachments for security
- [x] Triggers appropriate automated actions
- [x] Generates response suggestions
- [x] Maintains email threading
- [x] Logs all inbound communications
- [x] Notifies agent appropriately by priority
- [x] Handles errors gracefully

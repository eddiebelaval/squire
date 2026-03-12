# Skill: Receive SMS

**Category:** Communication
**Priority:** P0
**Approval Required:** No (processing is automatic; responses may require approval)

## Purpose

Parse and process incoming SMS text messages from parties involved in transactions. Handle quick responses, confirmations, opt-outs, and route appropriately based on content and context. SMS responses are typically brief and time-sensitive.

## Triggers

### System Events
- Incoming SMS to Twilio number
- Reply to outbound SMS
- Keyword-triggered inbound message

### Integration Points
- Twilio webhook (incoming message)
- Messaging service callbacks

## Input

```typescript
{
  messageId: string;                    // Twilio SID
  from: string;                         // E.164 phone number
  to: string;                           // Your Twilio number
  body: string;                         // Message content
  numMedia?: number;                    // Number of MMS attachments
  mediaUrls?: string[];                 // MMS media URLs
  mediaContentTypes?: string[];         // MIME types
  receivedAt: Date;
  accountSid: string;
  messagingServiceSid?: string;
}
```

## Output

```typescript
{
  success: boolean;
  actionTaken: string;
  result: {
    smsId: string;                      // Internal reference
    classification: {
      intent: SmsIntent;
      confidence: number;
      dealId?: string;
      partyId?: string;
      priority: 'urgent' | 'high' | 'normal' | 'low';
      relatedOutboundId?: string;       // Reply to which message
    };
    parsedResponse?: {
      type: 'affirmative' | 'negative' | 'question' | 'information' | 'opt_out' | 'unknown';
      normalizedValue?: string;         // YES/NO/STOP etc.
    };
    extractedData?: {
      dates?: Date[];
      times?: string[];
      confirmations?: string[];
    };
    mediaResults?: {
      url: string;
      type: string;
      documentId?: string;              // If stored
    }[];
    actionsTriggered: {
      action: string;
      status: 'completed' | 'pending_approval' | 'queued';
    }[];
    autoResponse?: {
      sent: boolean;
      body?: string;
    };
  };
  shouldContinue: boolean;
}
```

## Type Definitions

```typescript
type SmsIntent =
  | 'confirmation'                      // YES, CONFIRM, OK
  | 'denial'                            // NO, DECLINE
  | 'completion'                        // DONE, COMPLETE
  | 'question'                          // Asking something
  | 'status_request'                    // Asking for update
  | 'opt_out'                           // STOP, UNSUBSCRIBE
  | 'help_request'                      // HELP, ?
  | 'callback_request'                  // CALL ME
  | 'information'                       // Providing info
  | 'media_submission'                  // Sending photo/doc
  | 'unknown';
```

## Execution Flow

```
START
  |
  +--- 1. Validate message
  |    |
  |    +-- Verify Twilio signature
  |    +-- Check for spam patterns
  |    +-- Normalize phone number (E.164)
  |
  +--- 2. Identify sender
  |    |
  |    +-- Search parties by phone:
  |    |   |
  |    |   +-- FOUND:
  |    |   |   +-- Get party details
  |    |   |   +-- Get associated deals
  |    |   |   +-- Load conversation context
  |    |   |
  |    |   +-- NOT FOUND:
  |    |       +-- Check if known number pattern
  |    |       +-- Flag as unknown sender
  |    |       +-- Log for agent review
  |    |
  |    +-- Find recent outbound SMS to this number:
  |        +-- If found, link as reply
  |        +-- Inherit context from outbound
  |
  +--- 3. Parse response type
  |    |
  |    +-- Normalize message body:
  |    |   +-- Trim whitespace
  |    |   +-- Convert to uppercase for matching
  |    |   +-- Remove punctuation for comparison
  |    |
  |    +-- Match against response patterns:
  |    |
  |    |   AFFIRMATIVE: YES, Y, YEP, YEAH, OK, OKAY,
  |    |                CONFIRM, CONFIRMED, APPROVED,
  |    |                GOOD, SOUNDS GOOD, WORKS
  |    |
  |    |   NEGATIVE: NO, N, NOPE, DECLINE, DECLINED,
  |    |             CANCEL, NOT, CANT, CAN'T
  |    |
  |    |   COMPLETION: DONE, COMPLETE, COMPLETED,
  |    |               FINISHED, SIGNED, SUBMITTED
  |    |
  |    |   OPT_OUT: STOP, UNSUBSCRIBE, CANCEL,
  |    |            QUIT, END, OPTOUT
  |    |
  |    |   HELP: HELP, ?, INFO, COMMANDS
  |    |
  |    |   CALLBACK: CALL, CALL ME, CALLBACK,
  |    |             CALL BACK, RING ME
  |    |
  |    +-- If no pattern match:
  |        +-- Classify as question or information
  |        +-- Use NLP for intent detection
  |
  +--- 4. Match to deal context
  |    |
  |    +-- IF linked to recent outbound:
  |    |   +-- Use that deal context
  |    |   +-- Reference specific request
  |    |
  |    +-- IF multiple active deals:
  |    |   +-- Check message for property reference
  |    |   +-- Use most recent activity
  |    |   +-- Flag if ambiguous
  |    |
  |    +-- IF no deal context:
  |        +-- Treat as general inquiry
  |        +-- Route to agent
  |
  +--- 5. Process MMS media (if present)
  |    |
  |    +-- FOR EACH media attachment:
  |    |   |
  |    |   +-- Download from Twilio URL
  |    |   +-- Validate file type
  |    |   +-- Scan for security
  |    |   |
  |    |   +-- IF image:
  |    |   |   +-- Check if document photo
  |    |   |   +-- OCR if document-like
  |    |   |   +-- Store in documents
  |    |   |
  |    |   +-- IF document:
  |    |       +-- Process as attachment
  |    |       +-- Classify document type
  |    |       +-- Link to deal
  |
  +--- 6. Execute automated actions
  |    |
  |    +-- BASED ON INTENT AND CONTEXT:
  |    |
  |    +-- confirmation + pending_confirmation:
  |    |   +-- Mark confirmation received
  |    |   +-- Update related task
  |    |   +-- Send acknowledgment
  |    |
  |    +-- denial + pending_confirmation:
  |    |   +-- Mark declined
  |    |   +-- Alert agent
  |    |   +-- Acknowledge receipt
  |    |
  |    +-- completion + pending_task:
  |    |   +-- Mark task complete
  |    |   +-- Send thank you
  |    |
  |    +-- opt_out:
  |    |   +-- IMMEDIATELY set opt_out flag
  |    |   +-- Send required opt-out confirmation
  |    |   +-- Log compliance action
  |    |
  |    +-- help_request:
  |    |   +-- Send help message with commands
  |    |
  |    +-- callback_request:
  |    |   +-- Create callback task for agent
  |    |   +-- Acknowledge and set expectation
  |    |
  |    +-- question:
  |    |   +-- Queue for agent response
  |    |   +-- Acknowledge receipt
  |
  +--- 7. Generate auto-response
  |    |
  |    +-- IF opt_out:
  |    |   +-- MUST send: "You've been unsubscribed.
  |    |              Reply START to resubscribe."
  |    |
  |    +-- IF help_request:
  |    |   +-- Send commands list
  |    |
  |    +-- IF action completed:
  |    |   +-- Send brief acknowledgment
  |    |
  |    +-- IF unknown/complex:
  |        +-- Send "Got it, we'll get back to you"
  |        +-- Queue for agent
  |
  +--- 8. Log communication
  |    |
  |    |   INSERT INTO communications (
  |    |     deal_id, type, direction = 'inbound', channel = 'sms',
  |    |     from_party_id, to_party_ids,
  |    |     body, attachments,
  |    |     external_id = messageId,
  |    |     metadata = { classification, relatedOutboundId }
  |    |   )
  |
  +--- 9. Notify agent if needed
  |    |
  |    +-- IF negative response:
  |    |   +-- Alert immediately
  |    |
  |    +-- IF question/complex:
  |    |   +-- Add to response queue
  |    |
  |    +-- IF callback requested:
  |    |   +-- Create urgent task
  |    |
  |    +-- IF routine confirmation:
  |        +-- Include in activity log
  |
  +--- 10. Return result
```

## Response Pattern Matching

### Affirmative Responses
```typescript
const AFFIRMATIVE = [
  'YES', 'Y', 'YEP', 'YEAH', 'YA', 'YUP',
  'OK', 'OKAY', 'K', 'KK',
  'CONFIRM', 'CONFIRMED', 'CONFIRMING',
  'APPROVED', 'APPROVE',
  'GOOD', 'SOUNDS GOOD', 'LOOKS GOOD',
  'WORKS', 'WORKS FOR ME', 'THAT WORKS',
  'SURE', 'ABSOLUTELY', 'DEFINITELY',
  'CORRECT', 'RIGHT', 'TRUE', 'AGREED',
  'ACCEPT', 'ACCEPTED', 'I ACCEPT',
  'THUMBS UP', '1' // Common for "press 1 to confirm"
];
```

### Negative Responses
```typescript
const NEGATIVE = [
  'NO', 'N', 'NOPE', 'NAH',
  'DECLINE', 'DECLINED', 'DECLINING',
  'REJECT', 'REJECTED',
  'CANCEL', 'CANCELLED',
  'NOT', 'DONT', 'DON\'T', 'CANT', 'CAN\'T',
  'WONT', 'WON\'T', 'UNABLE',
  'PASS', 'SKIP',
  'DISAGREE', 'INCORRECT',
  '0' // Common for "press 0 to decline"
];
```

### Opt-Out (Compliance Critical)
```typescript
const OPT_OUT = [
  'STOP', 'STOPALL', 'STOP ALL',
  'UNSUBSCRIBE', 'UNSUB',
  'CANCEL', 'END', 'QUIT',
  'OPTOUT', 'OPT OUT', 'OPT-OUT',
  'REMOVE', 'REMOVE ME'
];
```

## Auto-Response Templates

### Confirmation Acknowledgment
```
Got it! We've noted your confirmation. Thanks!
```

### Decline Acknowledgment
```
Understood. {{agent.firstName}} will follow up with you shortly.
```

### Completion Acknowledgment
```
Thanks for letting us know it's complete. We'll update your file.
```

### Opt-Out Confirmation (REQUIRED)
```
You've been unsubscribed from {{agent.brokerage}} texts. Reply START to resubscribe. Questions? Call {{agent.phone}}.
```

### Help Response
```
Commands: Reply YES to confirm, NO to decline, DONE when complete, STOP to opt out, CALL for callback. Questions? {{agent.phone}}
```

### Callback Acknowledgment
```
Got it! {{agent.firstName}} will call you back shortly.
```

### General Acknowledgment
```
Thanks for your message! We'll get back to you soon.
```

## MMS Media Handling

### Supported Media Types
- Images: image/jpeg, image/png, image/gif
- Documents: application/pdf
- Size limit: 5 MB per attachment

### Media Processing
1. Download from Twilio media URL
2. Validate content type
3. Store in secure storage
4. If document-like image:
   - Run OCR
   - Classify document type
5. Link to deal and party

## Error Handling

| Error | Cause | Response |
|-------|-------|----------|
| `UNKNOWN_SENDER` | Phone not in system | Log, acknowledge, route to agent |
| `INVALID_SIGNATURE` | Twilio auth failed | Reject, log security event |
| `MEDIA_DOWNLOAD_FAILED` | Can't get MMS | Retry, then notify sender |
| `MEDIA_TOO_LARGE` | > 5 MB | Acknowledge, request email instead |
| `NO_CONTEXT` | Can't match to deal | Route to agent for classification |
| `AMBIGUOUS_RESPONSE` | Multiple interpretations | Ask for clarification |

## Compliance Requirements

### TCPA Compliance
- Honor STOP immediately (within seconds)
- Send confirmation of opt-out
- Log all opt-out actions
- Never send to opted-out numbers

### Required Opt-Out Language
Every promotional SMS must include opt-out instructions.
Transaction SMS: opt-out honored but not required in message.

### Response Time SLA
- Opt-out processing: < 30 seconds
- Auto-responses: < 60 seconds
- Agent routing: < 5 minutes

## Quality Checklist

- [x] Validates Twilio webhook signature
- [x] Identifies sender by phone number
- [x] Links replies to outbound messages
- [x] Parses response types accurately
- [x] Handles all standard SMS keywords
- [x] Processes MMS media attachments
- [x] Executes automated actions on confirmations
- [x] Immediately honors opt-out requests
- [x] Sends appropriate auto-responses
- [x] Logs all inbound SMS communications
- [x] Routes complex messages to agent
- [x] Maintains conversation context
- [x] Compliant with TCPA requirements

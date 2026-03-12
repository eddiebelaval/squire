# Skill: Receive Call

**Category:** Communication
**Priority:** P0
**Approval Required:** No (handling is automatic; escalations follow protocol)

## Purpose

Handle inbound voice calls to the agent's virtual number using AI voice technology. Provide intelligent call routing, answer common questions, take messages, and escalate to the human agent when needed. Ensures no call goes unanswered while respecting agent availability.

## Triggers

### System Events
- Incoming call to Twilio virtual number
- Call forwarded from agent's primary line
- After-hours call routing

### Integration Points
- Twilio Voice webhooks
- Call routing rules
- Agent availability status

## Input

```typescript
{
  callSid: string;                      // Twilio call ID
  from: string;                         // Caller phone (E.164)
  to: string;                           // Called number (E.164)
  direction: 'inbound';
  callerName?: string;                  // CNAM lookup result
  forwardedFrom?: string;               // If forwarded
  callStatus: 'ringing' | 'in-progress';
  timestamp: Date;
}
```

## Output

```typescript
{
  success: boolean;
  actionTaken: string;
  result: {
    callId: string;
    status: 'answered' | 'voicemail' | 'transferred' | 'completed';
    duration: number;
    caller: {
      phone: string;
      name?: string;
      partyId?: string;
      dealId?: string;
    };
    handling: {
      answeredBy: 'ai' | 'agent' | 'voicemail';
      intent?: CallIntent;
      transferred: boolean;
      transferredTo?: string;
    };
    conversation?: {
      transcript: string;
      summary: string;
      questionsAsked: string[];
      informationProvided: string[];
      actionItems: string[];
    };
    voicemailMessage?: {
      duration: number;
      transcript: string;
      audioUrl: string;
    };
    callbackScheduled?: Date;
    followUpNeeded: boolean;
    followUpReason?: string;
  };
  shouldContinue: boolean;
}
```

## Type Definitions

```typescript
type CallIntent =
  | 'status_inquiry'                    // Asking about deal status
  | 'scheduling'                        // Schedule showing/meeting
  | 'document_question'                 // Question about documents
  | 'urgent_issue'                      // Time-sensitive problem
  | 'general_question'                  // General inquiry
  | 'callback_request'                  // Wants agent callback
  | 'new_business'                      // New lead/inquiry
  | 'wrong_number'                      // Misdial
  | 'spam'                              // Robocall/spam
  | 'unknown';

type AgentAvailability =
  | 'available'                         // Can take call now
  | 'busy'                              // On another call/meeting
  | 'do_not_disturb'                    // No interruptions
  | 'after_hours'                       // Outside business hours
  | 'unavailable';                      // General unavailable
```

## Execution Flow

```
START - Incoming Call
  |
  +--- 1. Initial call handling
  |    |
  |    +-- Answer call
  |    +-- Play brief hold tone (optional)
  |    +-- Begin recording (with disclosure)
  |
  +--- 2. Identify caller
  |    |
  |    +-- CNAM lookup for name
  |    +-- Search parties by phone:
  |    |   |
  |    |   +-- FOUND:
  |    |   |   +-- "Hi {{party.firstName}}, thank you for calling."
  |    |   |   +-- Load deal context
  |    |   |   +-- Set personalized handling
  |    |   |
  |    |   +-- NOT FOUND:
  |    |       +-- "Thank you for calling {{agent.brokerage}}."
  |    |       +-- "May I have your name please?"
  |    |       +-- Capture and store name
  |    |
  |    +-- Greet caller appropriately
  |
  +--- 3. Check agent availability
  |    |
  |    +-- Get agent current status
  |    |
  |    +-- IF available:
  |    |   +-- Offer immediate transfer
  |    |   +-- "Let me connect you with {{agent.firstName}}"
  |    |   +-- GOTO Step 7 (Transfer)
  |    |
  |    +-- IF busy/in_meeting:
  |    |   +-- "{{agent.firstName}} is currently with another client."
  |    |   +-- Offer AI assistance or callback
  |    |
  |    +-- IF after_hours:
  |    |   +-- Note after-hours status
  |    |   +-- Continue with AI handling
  |    |
  |    +-- IF do_not_disturb:
  |        +-- Do not mention DND
  |        +-- "{{agent.firstName}} is currently unavailable."
  |        +-- Offer AI assistance
  |
  +--- 4. Determine call intent
  |    |
  |    +-- Ask: "How may I help you today?"
  |    +-- Listen for response
  |    |
  |    +-- Classify intent:
  |    |   +-- Keywords for status: "update", "status", "progress"
  |    |   +-- Keywords for scheduling: "appointment", "showing", "meet"
  |    |   +-- Keywords for urgent: "urgent", "problem", "emergency"
  |    |   +-- Keywords for documents: "paperwork", "sign", "document"
  |    |
  |    +-- IF spam detected:
  |    |   +-- "I'm sorry, I don't understand. Goodbye."
  |    |   +-- End call
  |    |
  |    +-- IF wrong number:
  |        +-- Politely redirect
  |        +-- End call
  |
  +--- 5. Handle based on intent
  |    |
  |    +-- status_inquiry:
  |    |   +-- IF deal context available:
  |    |   |   +-- Provide status summary
  |    |   |   +-- Mention next steps
  |    |   |   +-- Answer follow-up questions
  |    |   +-- ELSE:
  |    |       +-- "Which property is this regarding?"
  |    |       +-- Match to deal
  |    |
  |    +-- scheduling:
  |    |   +-- Check calendar availability
  |    |   +-- Propose times
  |    |   +-- Confirm and book
  |    |
  |    +-- document_question:
  |    |   +-- Answer general document questions
  |    |   +-- For specifics: offer callback
  |    |
  |    +-- urgent_issue:
  |    |   +-- Capture issue details
  |    |   +-- "Let me see if I can reach {{agent.firstName}} now"
  |    |   +-- Attempt priority transfer
  |    |   +-- If unsuccessful: immediate callback commitment
  |    |
  |    +-- general_question:
  |    |   +-- Answer within knowledge base
  |    |   +-- Offer callback for complex questions
  |    |
  |    +-- new_business:
  |        +-- Capture lead information
  |        +-- Set high priority callback
  |        +-- Thank and confirm follow-up
  |
  +--- 6. Offer transfer or callback
  |    |
  |    +-- IF query fully handled:
  |    |   +-- "Is there anything else I can help with?"
  |    |   +-- IF no: End gracefully
  |    |
  |    +-- IF needs agent:
  |    |   +-- Check availability again
  |    |   +-- IF available: "Let me transfer you now"
  |    |   +-- IF unavailable: "When would be a good time for a callback?"
  |    |
  |    +-- Schedule callback if needed:
  |        +-- Capture preferred time
  |        +-- Confirm callback scheduled
  |        +-- Create task for agent
  |
  +--- 7. Transfer to agent (if applicable)
  |    |
  |    +-- Notify agent of incoming transfer:
  |    |   +-- Caller name/number
  |    |   +-- Deal context
  |    |   +-- Call intent/summary
  |    |
  |    +-- Initiate warm transfer:
  |    |   +-- Brief agent on call
  |    |   +-- Connect parties
  |    |
  |    +-- IF agent doesn't answer:
  |    |   +-- Return to caller
  |    |   +-- Apologize
  |    |   +-- Offer voicemail or callback
  |    |
  |    +-- IF transfer successful:
  |        +-- Log handoff
  |        +-- Exit AI handling
  |
  +--- 8. Handle voicemail (if chosen)
  |    |
  |    +-- IF caller opts for voicemail:
  |    |   +-- "Please leave a message after the tone.
  |    |        Press any key when finished."
  |    |   +-- Record message
  |    |   +-- Transcribe
  |    |   +-- Send to agent
  |
  +--- 9. End call
  |    |
  |    +-- Summarize any commitments made
  |    +-- Confirm next steps
  |    +-- Thank caller
  |    +-- End recording
  |
  +--- 10. Post-call processing
  |    |
  |    +-- Generate transcript
  |    +-- Create call summary
  |    +-- Extract action items
  |    +-- Log communication
  |    +-- Send summary to agent
  |    +-- Create follow-up tasks
  |
  +--- 11. Log communication
  |    |
  |    |   INSERT INTO communications (
  |    |     deal_id, type, direction = 'inbound', channel = 'voice',
  |    |     from_party_id, to_party_ids,
  |    |     body = transcript, duration,
  |    |     recording_url, external_id = callSid,
  |    |     metadata = { summary, intent, actionItems }
  |    |   )
  |
  +--- 12. Return result
```

## Call Scripts

### Greeting (Known Caller)
```
"Hi {{party.firstName}}, thank you for calling {{agent.brokerage}}.
This is {{voiceName}}, {{agent.firstName}}'s AI assistant.
How may I help you today?"
```

### Greeting (Unknown Caller)
```
"Thank you for calling {{agent.brokerage}}.
This is {{voiceName}}, {{agent.firstName}}'s AI assistant.
May I have your name please?"
```

### Agent Unavailable
```
"{{agent.firstName}} is currently {{unavailabilityReason}}.
I can help with many questions, or I can schedule a callback.
What works best for you?"
```

### Status Update Response
```
"I have your information here for {{deal.address.street}}.
Your transaction is currently in the {{deal.stage}} stage.
{{statusSummary}}
Is there anything specific you'd like to know?"
```

### Transfer Introduction
```
"I'm connecting you with {{agent.firstName}} now.
One moment please while I transfer your call."
```

### Callback Scheduling
```
"I've scheduled a callback for {{callbackTime}}.
{{agent.firstName}} will call you at {{caller.phone}}.
Is there anything you'd like me to pass along?"
```

### Voicemail Prompt
```
"You've reached {{agent.name}} at {{agent.brokerage}}.
Please leave a message after the tone, and we'll return your call
as soon as possible. For urgent matters, please also send a text
to this number. Thank you."
```

## Agent Notification

When transferring or scheduling callback:

### SMS to Agent
```
Incoming: {{caller.name}} ({{caller.phone}})
Re: {{deal.address.street | abbreviateAddress}}
Intent: {{callIntent}}
{{#if transferred}}Transferring now{{else}}Callback scheduled: {{callbackTime}}{{/if}}
```

### Push Notification
- Title: "Call from {{caller.name}}"
- Body: "{{callIntent}} - {{deal.address.street}}"
- Action: Accept/Decline transfer

## Availability-Based Routing

| Agent Status | Caller Type | Action |
|--------------|-------------|--------|
| Available | Any | Offer immediate transfer |
| Busy | Active client | Brief AI assist, offer callback |
| Busy | Unknown | AI assist, schedule callback |
| After Hours | Active client (urgent) | Attempt transfer anyway |
| After Hours | Other | AI assist + next day callback |
| DND | Any (non-emergency) | AI only, no transfer option |
| DND | Emergency | Attempt transfer with warning |

## Error Handling

| Error | Cause | Response |
|-------|-------|----------|
| `CALLER_HANG_UP` | Early disconnect | Log partial call |
| `TRANSFER_FAILED` | Agent didn't answer | Return to caller, offer voicemail |
| `SPEECH_NOT_UNDERSTOOD` | Poor audio/accent | Repeat request, offer transfer |
| `TWILIO_ERROR` | API failure | Attempt callback via SMS |
| `RECORDING_FAILED` | Storage issue | Continue without recording, log |
| `CALLER_UNCOOPERATIVE` | Hostile/confused | End call politely |

## Recording Compliance

### Disclosure (Required)
```
"This call may be recorded for quality and training purposes."
```

### Two-Party Consent States
- California, Florida, etc.: Must disclose recording
- Disclosure played automatically at call start

### Recording Storage
- Encrypted at rest
- Retained per state requirements
- Accessible only to agent and authorized staff

## Quality Checklist

- [x] Answers calls promptly (< 3 rings)
- [x] Identifies caller by phone number
- [x] Personalizes greeting for known parties
- [x] Checks agent availability before transfer
- [x] Classifies call intent accurately
- [x] Provides helpful AI assistance when agent unavailable
- [x] Handles transfers smoothly with context
- [x] Offers voicemail and callback options
- [x] Records calls with proper disclosure
- [x] Generates accurate transcripts
- [x] Creates post-call summaries
- [x] Notifies agent of important calls
- [x] Logs all inbound call communications
- [x] Handles errors gracefully
- [x] Complies with recording laws

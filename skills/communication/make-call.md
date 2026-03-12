# Skill: Make Call

**Category:** Communication
**Priority:** P0
**Approval Required:** Conditional (based on recipient, time, and call purpose)

## Purpose

Initiate outbound voice calls using AI voice technology to parties involved in transactions. Handles appointment confirmations, deadline reminders, status updates, and warm handoffs to agents. Voice AI provides natural conversation while maintaining transaction context.

## Triggers

### Voice Commands
- "Call [party] about [topic]"
- "Phone the buyer to confirm closing"
- "Make a call to the lender"
- "Ring [name] about [issue]"
- "Set up a call with the title company"

### System Events
- Same-day deadline with no response
- Critical document pending signature
- Closing day confirmations
- Failed email/SMS delivery escalation

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
  callType:
    | 'deadline_reminder'
    | 'document_follow_up'
    | 'closing_confirmation'
    | 'status_update'
    | 'appointment_confirmation'
    | 'introduction'
    | 'custom';
  purpose: string;                      // Brief description of call objective
  script?: {
    opening: string;                    // How to greet
    keyPoints: string[];                // Main topics to cover
    closingAction?: string;             // What to request/confirm
  };
  voiceProfile?: 'professional' | 'warm' | 'urgent';
  maxDuration?: number;                 // Max call length in seconds (default: 180)
  scheduledFor?: Date;                  // Schedule for later
  callbackOnNoAnswer?: boolean;         // Retry if no answer
  handoffToAgent?: {                    // Option to transfer to human
    enabled: boolean;
    triggerPhrases?: string[];          // Phrases that trigger handoff
  };
  recordCall?: boolean;                 // Default: true for compliance
}
```

## Output

```typescript
{
  success: boolean;
  actionTaken: string;
  result: {
    callId: string;
    status: 'initiated' | 'ringing' | 'answered' | 'completed' | 'voicemail' | 'no_answer' | 'busy' | 'failed';
    recipient: {
      phone: string;
      name: string;
    };
    duration?: number;                  // Call duration in seconds
    outcome?: {
      answered: boolean;
      reachedVoicemail: boolean;
      leftMessage: boolean;
      handoffTriggered: boolean;
      keyConfirmations: string[];       // What was confirmed
      followUpNeeded: boolean;
      followUpReason?: string;
    };
    transcript?: string;                // Call transcript
    recording?: {
      url: string;
      duration: number;
    };
    scheduledCallback?: Date;
  };
  requiresApproval: boolean;
  approvalMessage?: string;
}
```

## Execution Flow

```
START
  |
  +--- 1. Resolve recipient
  |    |
  |    +-- IF type = 'party':
  |    |   +-- Look up party in deal
  |    |   +-- Get phone and name
  |    |   +-- Verify phone exists
  |    |   +-- Check call preferences
  |    |
  |    +-- IF type = 'phone':
  |        +-- Validate phone format
  |        +-- Format to E.164 (+1XXXXXXXXXX)
  |
  +--- 2. Check calling hours
  |    |
  |    +-- Get recipient timezone
  |    |
  |    +-- IF outside 9 AM - 8 PM local:
  |    |   |
  |    |   +-- IF callType = urgent:
  |    |   |   +-- Proceed with warning logged
  |    |   |
  |    |   +-- ELSE:
  |    |       +-- Schedule for next appropriate time
  |    |       +-- Return with scheduled status
  |    |
  |    +-- IF weekend:
  |        +-- Require explicit approval unless urgent
  |
  +--- 3. Determine approval requirement
  |    |
  |    +-- AUTO-APPROVE:
  |    |   +-- Closing day confirmations
  |    |   +-- Same-day deadline follow-ups
  |    |   +-- Appointment confirmations
  |    |   +-- Agent pre-approved call types
  |    |
  |    +-- REQUIRES APPROVAL:
  |        +-- First call to any party
  |        +-- Calls to opposing parties
  |        +-- Custom/unscripted calls
  |        +-- Calls outside business hours
  |        +-- Weekend calls
  |
  +--- 4. Prepare call script
  |    |
  |    +-- IF callType = standard type:
  |    |   +-- Load template script
  |    |   +-- Apply deal context
  |    |   +-- Personalize with party info
  |    |
  |    +-- IF callType = 'custom':
  |        +-- Use provided script
  |        +-- Validate all required fields
  |
  +--- 5. Configure voice AI
  |    |
  |    +-- Set voice profile
  |    |   +-- professional: Formal, businesslike
  |    |   +-- warm: Friendly, conversational
  |    |   +-- urgent: Direct, time-sensitive
  |    |
  |    +-- Configure speech parameters:
  |        +-- Speaking rate
  |        +-- Pause duration
  |        +-- Interruption handling
  |
  +--- 6. Initiate call
  |    |
  |    +-- IF scheduledFor is set:
  |    |   +-- Queue for scheduled time
  |    |   +-- Return scheduled status
  |    |
  |    +-- ELSE:
  |        +-- Initiate via Twilio Voice
  |        +-- Enable recording if configured
  |        +-- Start real-time transcription
  |
  +--- 7. Handle call progression
  |    |
  |    +-- ON ANSWER:
  |    |   +-- Deliver opening script
  |    |   +-- Listen and respond contextually
  |    |   +-- Cover key points
  |    |   +-- Handle questions with deal context
  |    |   +-- Request closing action
  |    |   +-- Monitor for handoff triggers
  |    |
  |    +-- ON VOICEMAIL:
  |    |   +-- Leave pre-configured message
  |    |   +-- Keep under 30 seconds
  |    |   +-- Include callback info
  |    |
  |    +-- ON NO ANSWER:
  |    |   +-- IF callbackOnNoAnswer:
  |    |   |   +-- Schedule retry in 2 hours
  |    |   |   +-- Max 3 attempts
  |    |   +-- Log attempt
  |    |
  |    +-- ON HANDOFF TRIGGER:
  |        +-- Notify agent
  |        +-- Transfer if agent available
  |        +-- Else schedule callback
  |
  +--- 8. Process call outcome
  |    |
  |    +-- Generate transcript
  |    +-- Extract key confirmations
  |    +-- Identify follow-up needs
  |    +-- Update deal status if applicable
  |
  +--- 9. Log communication
  |    |
  |    |   INSERT INTO communications (
  |    |     deal_id, type, direction, channel = 'voice',
  |    |     from_party_id, to_party_ids,
  |    |     subject, body = transcript,
  |    |     external_id, duration, recording_url,
  |    |     metadata = { outcome, keyPoints }
  |    |   )
  |
  +--- 10. Return result
```

## Call Scripts

### Deadline Reminder
```
Opening: "Hi, this is {{voiceName}} calling on behalf of {{agent.name}} from {{agent.brokerage}} regarding your property at {{deal.address.street}}."

Key Points:
- "I'm calling about an important deadline coming up."
- "The {{deadline.name}} is due {{deadline.dueDate | formatDate}}."
- "{{agent.firstName}} wanted to make sure you're aware and prepared."

Closing: "Do you have any questions about this deadline? Would you like me to have {{agent.firstName}} call you back?"
```

### Closing Confirmation
```
Opening: "Hi, this is {{voiceName}} calling on behalf of {{agent.name}}. I'm confirming details for your closing on {{deal.closingDate | formatDate}}."

Key Points:
- "Your closing is scheduled for {{closingTime}} at {{closingLocation}}."
- "Please bring a valid photo ID."
- "{{#if wireAmount}}The wire amount is {{wireAmount | formatCurrency}}. Please verify wire instructions by calling the title company directly.{{/if}}"

Closing: "Can you confirm you'll be there? Any questions for {{agent.firstName}}?"
```

### Document Follow-up
```
Opening: "Hi, this is {{voiceName}} calling on behalf of {{agent.name}} about your transaction at {{deal.address.street}}."

Key Points:
- "We're following up on {{document.name}} that requires your attention."
- "It was sent to your email on {{document.sentDate | formatDate}}."
- "{{#if deadline}}It's needed by {{deadline | formatDate}}.{{/if}}"

Closing: "Have you been able to review it? Should I have {{agent.firstName}} walk you through it?"
```

### Appointment Confirmation
```
Opening: "Hi, this is {{voiceName}} calling from {{agent.brokerage}} to confirm your appointment."

Key Points:
- "You have a {{appointmentType}} scheduled for {{appointmentDate | formatDateTime}}."
- "The address is {{appointmentLocation}}."

Closing: "Can you confirm you'll be there? Reply with any questions."
```

## Voice AI Configuration

### Interruption Handling
- Listen for interruptions during pauses
- Acknowledge interruptions: "Of course, go ahead..."
- Resume context after handling question
- Track interruption topics for follow-up

### Question Handling
- Answer within deal context
- Route complex questions to agent callback
- Never guess on legal/financial specifics
- Example: "That's a great question. Let me have {{agent.firstName}} call you back with specifics on that."

### Sentiment Detection
- Monitor for frustration or confusion
- Adjust tone accordingly
- Trigger handoff if sentiment negative

## Approval Rules

| Scenario | Auto-Approve | Requires Approval |
|----------|--------------|-------------------|
| Closing day confirmation | Yes | - |
| Same-day deadline follow-up | Yes | - |
| Appointment confirmation | Yes | - |
| Document signing reminder | Yes | - |
| First call to party | - | Yes |
| Call to opposing party | - | Yes |
| Custom scripted call | - | Yes |
| Outside business hours | - | Yes |
| Weekend call | - | Yes |

## Time Restrictions

- **Normal calls**: 9 AM - 8 PM recipient local time
- **Urgent calls**: Can bypass with warning
- **Never call**: 9 PM - 8 AM unless explicit emergency
- **Weekends**: Require approval except closing-related

## Voicemail Handling

When reaching voicemail:
1. Keep message under 30 seconds
2. State caller identity clearly
3. Reference property address
4. State brief purpose
5. Provide callback number
6. Repeat callback number

### Voicemail Template
```
"Hi {{recipient.firstName}}, this is {{voiceName}} calling on behalf of {{agent.name}} regarding your property at {{deal.address.street | abbreviateAddress}}. {{briefPurpose}}. Please call {{agent.firstName}} back at {{agent.phone}}. Again, that's {{agent.phone | spellPhoneNumber}}. Thank you."
```

## Error Handling

| Error | Cause | Response |
|-------|-------|----------|
| `INVALID_PHONE` | Bad phone format | Return error, request correction |
| `PARTY_NO_PHONE` | Party missing phone | Alert agent, suggest alternative |
| `NO_ANSWER_MAX` | All retry attempts failed | Alert agent, suggest email/SMS |
| `TWILIO_FAILED` | API error | Retry, then queue for later |
| `CARRIER_BLOCKED` | Number blocked | Log, notify agent |
| `CALL_DROPPED` | Connection lost | Attempt callback if brief |
| `RECIPIENT_HANG_UP` | Early termination | Log outcome, flag for follow-up |

## Compliance Notes

- **Recording Consent**: Announce recording at call start (one-party/two-party consent varies by state)
- **TCPA Compliance**: Transaction calls generally permitted; never cold call
- **Do Not Call**: Honor DNC requests immediately
- **Time Restrictions**: Follow state-specific calling hour laws
- **Identification**: Always identify caller and purpose clearly

## Quality Checklist

- [x] Resolves party to phone number
- [x] Validates E.164 phone format
- [x] Checks calling hours and timezone
- [x] Applies appropriate approval gates
- [x] Uses natural voice AI scripts
- [x] Handles voicemail gracefully
- [x] Implements callback retry logic
- [x] Supports agent handoff
- [x] Records calls for compliance
- [x] Generates accurate transcripts
- [x] Logs all call communications
- [x] Tracks call outcomes and confirmations

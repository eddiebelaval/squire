# Skill: Follow Up

**Category:** Communication
**Priority:** P1
**Approval Required:** Conditional (based on follow-up type and escalation level)

## Purpose

Execute the no-response follow-up protocol when parties don't respond to initial outreach. Implements a multi-channel, escalating approach to ensure critical communications are acknowledged while respecting recipient preferences and avoiding over-communication.

## Triggers

### Voice Commands
- "Follow up with [party]"
- "Check if [name] responded"
- "Send another reminder to [party]"
- "Any response from the buyer?"

### System Events
- Outbound communication with no response after threshold
- Pending confirmation past due
- Document signature reminder needed
- Deadline approaching with pending action

## Input

```typescript
{
  dealId: string;
  party: {
    partyId: string;
    name: string;
    role: PartyRole;
    phone?: string;
    email?: string;
    preferredChannel?: 'email' | 'sms' | 'phone';
  };
  originalCommunication: {
    communicationId: string;
    channel: 'email' | 'sms' | 'phone';
    subject?: string;
    sentAt: Date;
    purpose: string;
    requiredAction?: string;
  };
  followUpReason:
    | 'no_response'
    | 'no_confirmation'
    | 'document_unsigned'
    | 'deadline_approaching'
    | 'information_needed'
    | 'callback_requested';
  currentAttempt: number;                // 1, 2, 3, etc.
  maxAttempts?: number;                  // Default: 3
  escalationLevel?: 'gentle' | 'standard' | 'urgent';
  customMessage?: string;
  deadline?: Date;
}
```

## Output

```typescript
{
  success: boolean;
  actionTaken: string;
  result: {
    followUpId: string;
    attempt: number;
    channel: 'email' | 'sms' | 'phone';
    status: 'sent' | 'scheduled' | 'escalated' | 'max_attempts_reached';
    message?: {
      communicationId: string;
      sentAt: Date;
    };
    nextFollowUp?: {
      scheduledFor: Date;
      channel: string;
      escalationLevel: string;
    };
    requiresAgentReview: boolean;
    agentNotification?: string;
  };
  shouldContinue: boolean;
}
```

## Execution Flow

```
START
  |
  +--- 1. Check response status
  |    |
  |    +-- Query for any response since original:
  |    |   +-- Incoming email from party
  |    |   +-- Incoming SMS from party
  |    |   +-- Incoming call from party
  |    |   +-- Document signature
  |    |   +-- Task completion
  |    |
  |    +-- IF response found:
  |    |   +-- Cancel follow-up
  |    |   +-- Return success (no action needed)
  |    |
  |    +-- IF no response:
  |        +-- Continue with follow-up
  |
  +--- 2. Determine attempt parameters
  |    |
  |    +-- Get current attempt number
  |    +-- Check max attempts allowed
  |    +-- Determine escalation level:
  |    |
  |    |   Attempt 1: gentle
  |    |   Attempt 2: standard
  |    |   Attempt 3: urgent
  |    |
  |    +-- IF deadline within 24 hours:
  |        +-- Force urgent level
  |        +-- Add deadline context
  |
  +--- 3. Select channel
  |    |
  |    +-- Follow channel escalation pattern:
  |    |
  |    |   Original: Email
  |    |   ├── Attempt 1: Email (same channel)
  |    |   ├── Attempt 2: SMS
  |    |   └── Attempt 3: Phone call
  |    |
  |    |   Original: SMS
  |    |   ├── Attempt 1: SMS (same channel)
  |    |   ├── Attempt 2: Phone call
  |    |   └── Attempt 3: Email + SMS
  |    |
  |    |   Original: Phone
  |    |   ├── Attempt 1: SMS
  |    |   ├── Attempt 2: Email + SMS
  |    |   └── Attempt 3: Multi-channel + agent alert
  |    |
  |    +-- Respect party preferences when possible
  |    +-- Skip unavailable channels (no phone, etc.)
  |
  +--- 4. Check timing appropriateness
  |    |
  |    +-- Verify minimum time between follow-ups:
  |    |   +-- Attempt 1: 24 hours after original
  |    |   +-- Attempt 2: 24 hours after attempt 1
  |    |   +-- Attempt 3: 12 hours after attempt 2
  |    |   +-- Urgent: 4-hour minimum
  |    |
  |    +-- Check business hours for phone/SMS
  |    +-- Schedule if too early
  |
  +--- 5. Prepare follow-up message
  |    |
  |    +-- Select template based on:
  |    |   +-- Follow-up reason
  |    |   +-- Attempt number
  |    |   +-- Escalation level
  |    |   +-- Channel
  |    |
  |    +-- Personalize with:
  |    |   +-- Party name
  |    |   +-- Deal context
  |    |   +-- Original request
  |    |   +-- Deadline (if applicable)
  |    |
  |    +-- IF custom message provided:
  |        +-- Use as basis, add urgency markers
  |
  +--- 6. Determine approval requirement
  |    |
  |    +-- AUTO-APPROVE:
  |    |   +-- System-triggered follow-ups
  |    |   +-- Deadline-based reminders
  |    |   +-- Document signature reminders
  |    |   +-- Attempts 1-2 (gentle/standard)
  |    |
  |    +-- REQUIRES APPROVAL:
  |    |   +-- Attempt 3+ (avoid over-communication)
  |    |   +-- Custom messages
  |    |   +-- Follow-ups to opposing parties
  |    |
  |    +-- IF requires approval:
  |        +-- Submit to agent
  |        +-- Return pending status
  |
  +--- 7. Execute follow-up
  |    |
  |    +-- Send via appropriate skill:
  |    |   +-- Email: Invoke send-email
  |    |   +-- SMS: Invoke send-sms
  |    |   +-- Phone: Invoke make-call
  |    |
  |    +-- Link to original communication thread
  |    +-- Set tracking for response
  |
  +--- 8. Schedule next follow-up
  |    |
  |    +-- IF current attempt < max attempts:
  |    |   +-- Calculate next follow-up time
  |    |   +-- Determine next channel
  |    |   +-- Create scheduled job
  |    |
  |    +-- IF max attempts reached:
  |    |   +-- No more automatic follow-ups
  |    |   +-- Alert agent
  |    |   +-- Create manual task
  |
  +--- 9. Log follow-up
  |    |
  |    |   INSERT INTO follow_ups (
  |    |     deal_id, party_id,
  |    |     original_communication_id,
  |    |     attempt_number, channel,
  |    |     escalation_level, reason,
  |    |     communication_id,
  |    |     next_follow_up_at,
  |    |     status
  |    |   )
  |
  +--- 10. Notify agent if needed
  |    |
  |    +-- IF max attempts reached:
  |    |   +-- Alert: "No response after {{attempts}} follow-ups"
  |    |   +-- Include context and options
  |    |
  |    +-- IF deadline imminent + no response:
  |    |   +-- Urgent alert
  |    |   +-- Recommend personal outreach
  |    |
  |    +-- IF routine:
  |        +-- Log in activity feed
  |
  +--- 11. Return result
```

## Follow-Up Templates

### Email - Gentle (Attempt 1)
```
Subject: Following up - {{originalSubject}}

Hi {{party.firstName}},

I wanted to follow up on my previous message regarding {{deal.address.street}}.

{{originalPurpose | summarize}}

{{#if requiredAction}}
When you have a moment, {{requiredAction}}.
{{/if}}

Please let me know if you have any questions or need anything from me.

{{signature}}

---
Original message sent: {{originalDate | formatDate}}
```

### Email - Standard (Attempt 2)
```
Subject: Checking in - {{originalSubject}}

Hi {{party.firstName}},

I haven't heard back yet regarding {{deal.address.street}}, and wanted to make sure my previous messages came through.

{{#if deadline}}
As a reminder, we need {{requiredAction}} by {{deadline | formatDate}}.
{{else}}
{{originalPurpose | summarize}}
{{/if}}

Could you please let me know your status on this?

{{signature}}
```

### Email - Urgent (Attempt 3)
```
Subject: Urgent: Action Needed - {{deal.address.street}}

Hi {{party.firstName}},

I've reached out a few times regarding {{deal.address.street}} and haven't been able to connect with you.

{{#if deadline}}
**Important:** We need {{requiredAction}} by {{deadline | formatDate}} to keep your transaction on track.
{{else}}
This requires your attention: {{requiredAction}}
{{/if}}

Please call or text me at {{agent.phone}} or reply to this email as soon as possible.

{{signature}}
```

### SMS - Gentle
```
Hi {{party.firstName}}, following up on {{deal.address.street | abbreviateAddress}}. {{briefPurpose}}. Any update? -{{agent.firstName}}
```

### SMS - Standard
```
{{party.firstName}}, checking in on {{deal.address.street | abbreviateAddress}}. {{briefPurpose}}. Please reply or call {{agent.phone}}. -{{agent.firstName}}
```

### SMS - Urgent
```
{{party.firstName}}, time-sensitive: {{briefPurpose}} for {{deal.address.street | abbreviateAddress}}. {{#if deadline}}Due {{deadline | formatShortDate}}.{{/if}} Call {{agent.phone}} asap. -{{agent.firstName}}
```

### Phone Script - Urgent
```
Opening: "Hi {{party.firstName}}, this is {{voiceName}} calling on behalf of
{{agent.name}} about your property at {{deal.address.street}}."

Key Point: "I've been trying to reach you regarding {{purpose}}.
{{#if deadline}}This needs to be addressed by {{deadline | formatDate}}.{{/if}}"

Ask: "Is there anything preventing you from {{requiredAction}}?
Would you like me to have {{agent.firstName}} call you directly?"
```

## Channel Escalation Matrix

| Original | Attempt 1 | Attempt 2 | Attempt 3 |
|----------|-----------|-----------|-----------|
| Email | Email | SMS | Phone |
| SMS | SMS | Phone | Email + SMS |
| Phone | SMS | Email + SMS | Multi + Agent |

## Timing Rules

### Minimum Intervals
| Urgency | Between Attempts |
|---------|-----------------|
| Gentle | 24 hours |
| Standard | 24 hours |
| Urgent | 4-12 hours |
| Deadline <24h | 4 hours |

### Business Hours
- Email: Anytime
- SMS: 8 AM - 9 PM local
- Phone: 9 AM - 8 PM local

### Best Times
- Email: 9-10 AM, 2-3 PM
- SMS: 10-11 AM
- Phone: 10-11 AM, 3-4 PM

## Agent Notification Templates

### Max Attempts Reached
```
Title: No response from {{party.name}}
Body: {{attempts}} follow-ups sent regarding {{purpose}}.
No response since {{originalDate | formatDate}}.

Options:
- [Call Personally] - Direct agent outreach
- [Try Different Contact] - Update contact info
- [Mark Unresponsive] - Flag for tracking
- [Archive] - Stop follow-ups
```

### Deadline Risk
```
[URGENT] {{party.name}} unresponsive

{{purpose}} due {{deadline | formatDate}}
{{attempts}} follow-ups with no response

Recommend immediate personal call to {{party.phone}}
```

## Approval Rules

| Scenario | Auto-Approve | Requires Approval |
|----------|--------------|-------------------|
| Attempt 1-2 to own client | Yes | - |
| Deadline reminder | Yes | - |
| Document signature follow-up | Yes | - |
| Attempt 3+ | - | Yes |
| Follow-up to opposing party | - | Yes |
| Custom message content | - | Yes |
| Multiple same-day follow-ups | - | Yes |

## Error Handling

| Error | Cause | Response |
|-------|-------|----------|
| `CONTACT_INFO_MISSING` | No phone/email | Alert agent, request update |
| `OPTED_OUT` | Party unsubscribed | Skip channel, try alternative |
| `INVALID_CONTACT` | Bad email/phone | Alert agent |
| `OVER_LIMIT` | Too many attempts | Stop, require agent decision |
| `TIMING_ERROR` | Too soon after previous | Reschedule appropriately |

## Quality Checklist

- [x] Verifies no response before sending
- [x] Respects minimum time between attempts
- [x] Escalates channel appropriately
- [x] Adjusts tone based on attempt number
- [x] Includes deadline context when applicable
- [x] Respects business hours for phone/SMS
- [x] Links follow-ups to original communication
- [x] Schedules next follow-up automatically
- [x] Alerts agent at max attempts
- [x] Logs all follow-up activity
- [x] Stops on any response received
- [x] Handles opt-outs correctly

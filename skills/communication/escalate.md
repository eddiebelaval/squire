# Skill: Escalate

**Category:** Communication
**Priority:** P0
**Approval Required:** No (escalation is automatic; actions are logged)

## Purpose

Escalate communications and issues to the human agent when AI assistance is insufficient, when high-stakes decisions are involved, or when a party explicitly requests human contact. Ensures seamless handoff with full context and appropriate urgency.

## Triggers

### Voice Commands
- "Get me a human"
- "I need to speak with [agent]"
- "This is urgent"
- "Escalate to [name]"

### System Events
- Sentiment detection indicates frustration
- Request exceeds AI capability threshold
- High-stakes decision required
- Multiple failed resolution attempts
- Explicit human request detected
- VIP party contact

### Detection Keywords
- "frustrated", "angry", "upset", "disappointed"
- "speak to someone", "real person", "human"
- "manager", "supervisor", "your boss"
- "lawyer", "attorney", "legal"
- "not working", "keeps failing", "broken"

## Input

```typescript
{
  source: {
    channel: 'voice' | 'email' | 'sms' | 'chat';
    communicationId: string;
    context: {
      transcript?: string;
      recentMessages?: Message[];
      callDuration?: number;
    };
  };
  party: {
    partyId: string;
    name: string;
    role: PartyRole;
    phone?: string;
    email?: string;
  };
  dealId?: string;
  escalationType:
    | 'human_request'                   // Party asked for human
    | 'sentiment'                       // Negative sentiment detected
    | 'capability'                      // AI can't handle
    | 'high_stakes'                     // Decision requires human
    | 'vip'                             // Important party
    | 'repeated_failure'                // Multiple failed attempts
    | 'legal'                           // Legal implications
    | 'emergency';                      // Time-critical issue
  urgency: 'immediate' | 'high' | 'normal';
  issueDescription: string;
  attemptedResolutions?: string[];
  sentiment?: {
    score: number;                      // -1 to 1
    indicators: string[];
  };
}
```

## Output

```typescript
{
  success: boolean;
  actionTaken: string;
  result: {
    escalationId: string;
    status: 'transferred' | 'scheduled' | 'queued' | 'acknowledged';
    agentNotified: boolean;
    notificationMethods: string[];
    expectedResponseTime: string;
    partyAcknowledgment: string;        // What we told the party
    handoffComplete: boolean;
    escalationDetails: {
      type: string;
      urgency: string;
      context: string;
      suggestedAction?: string;
    };
    callback?: {
      scheduled: boolean;
      time?: Date;
    };
  };
  shouldContinue: boolean;
}
```

## Execution Flow

```
START
  |
  +--- 1. Acknowledge escalation request
  |    |
  |    +-- IF voice:
  |    |   +-- "I understand. Let me connect you with {{agent.firstName}}."
  |    |
  |    +-- IF email/sms:
  |    |   +-- Queue for immediate response
  |    |
  |    +-- IF negative sentiment:
  |        +-- "I'm sorry you're experiencing frustration.
  |             Let me get {{agent.firstName}} involved."
  |
  +--- 2. Assess urgency
  |    |
  |    +-- IMMEDIATE (attempt live transfer):
  |    |   +-- Emergency situations
  |    |   +-- Hostile/very upset party
  |    |   +-- Legal mentions
  |    |   +-- Active call with frustrated party
  |    |
  |    +-- HIGH (15-minute response):
  |    |   +-- Human request during business hours
  |    |   +-- VIP party
  |    |   +-- High-stakes decision
  |    |
  |    +-- NORMAL (1-hour response):
  |        +-- General capability escalation
  |        +-- Routine human preference
  |
  +--- 3. Check agent availability
  |    |
  |    +-- Get current agent status
  |    |
  |    +-- IF available + immediate urgency:
  |    |   +-- Attempt live transfer/interrupt
  |    |   +-- Provide context packet to agent
  |    |
  |    +-- IF busy + immediate urgency:
  |    |   +-- Check interrupt preferences
  |    |   +-- IF interruptible: Notify with context
  |    |   +-- IF not: Queue with priority flag
  |    |
  |    +-- IF unavailable:
  |        +-- Queue escalation
  |        +-- Set callback expectation
  |        +-- Notify via available channels
  |
  +--- 4. Prepare context packet
  |    |
  |    +-- Generate escalation summary:
  |    |   +-- Party name and role
  |    |   +-- Deal context (if applicable)
  |    |   +-- Issue description
  |    |   +-- Attempted resolutions
  |    |   +-- Conversation transcript/history
  |    |   +-- Sentiment indicators
  |    |   +-- Suggested action
  |    |
  |    +-- Format for agent consumption:
  |        +-- Brief (for notification)
  |        +-- Detailed (for review)
  |
  +--- 5. Notify agent
  |    |
  |    +-- IMMEDIATE urgency:
  |    |   +-- Phone call to agent
  |    |   +-- SMS with URGENT flag
  |    |   +-- Push notification
  |    |   +-- All channels simultaneously
  |    |
  |    +-- HIGH urgency:
  |    |   +-- SMS + Push notification
  |    |   +-- Email with priority flag
  |    |
  |    +-- NORMAL urgency:
  |        +-- Push notification
  |        +-- Add to agent task queue
  |        +-- Email summary
  |
  +--- 6. Execute handoff
  |    |
  |    +-- IF voice call + agent available:
  |    |   |
  |    |   +-- Warm transfer:
  |    |   |   +-- "{{party.firstName}}, I'm connecting you now."
  |    |   |   +-- Brief agent: "Incoming from {{party.name}},
  |    |   |        {{escalationType}}, regarding {{issue}}"
  |    |   |   +-- Connect
  |    |   |
  |    |   +-- IF transfer fails:
  |    |       +-- Return to caller
  |    |       +-- Schedule immediate callback
  |    |       +-- "I'm sorry, {{agent.firstName}} will call you
  |    |            within {{responseTime}}."
  |    |
  |    +-- IF voice call + agent unavailable:
  |    |   +-- Offer options:
  |    |   |   +-- Wait on hold (if short expected wait)
  |    |   |   +-- Callback within X minutes
  |    |   |   +-- Leave voicemail
  |    |   +-- Confirm choice and execute
  |    |
  |    +-- IF email/SMS:
  |        +-- Send acknowledgment to party
  |        +-- Queue for agent response
  |        +-- Set response timer
  |
  +--- 7. Set expectations with party
  |    |
  |    +-- Confirm escalation received
  |    +-- Provide realistic response time
  |    +-- Explain next steps
  |    +-- Offer interim assistance
  |    |
  |    +-- Response time commitments:
  |        +-- Immediate: "Right now" / "Within 5 minutes"
  |        +-- High: "Within 15 minutes"
  |        +-- Normal: "Within 1 hour" / "By end of day"
  |
  +--- 8. Log escalation
  |    |
  |    |   INSERT INTO escalations (
  |    |     deal_id, party_id,
  |    |     escalation_type, urgency,
  |    |     source_channel, source_communication_id,
  |    |     issue_description, context_summary,
  |    |     sentiment_score, sentiment_indicators,
  |    |     attempted_resolutions,
  |    |     agent_notified_at, notification_methods,
  |    |     expected_response_time,
  |    |     status = 'pending',
  |    |     created_at
  |    |   )
  |
  +--- 9. Create follow-up safeguard
  |    |
  |    +-- Set escalation timer based on urgency
  |    +-- IF not resolved within expected time:
  |    |   +-- Re-notify agent
  |    |   +-- Escalate to backup (if configured)
  |    |   +-- Update party on delay
  |    |
  |    +-- Track until resolved
  |
  +--- 10. Return result
```

## Escalation Types and Handling

### Human Request
Party explicitly asks for human contact.
```
AI: "Absolutely. Let me connect you with {{agent.firstName}} right away."
```

### Sentiment Escalation
Negative sentiment detected during interaction.
```
AI: "I can tell this is frustrating, and I want to make sure you get
the help you need. Let me have {{agent.firstName}} call you directly."
```

### Capability Escalation
Request exceeds AI knowledge or authority.
```
AI: "That's a great question that {{agent.firstName}} is better equipped
to answer. Let me get them involved."
```

### High-Stakes Escalation
Decision with significant consequences.
```
AI: "This is an important decision. {{agent.firstName}} will want to
walk you through this personally. Let me set that up."
```

### VIP Escalation
Important party (repeat client, referral source, etc.)
```
AI: "Thank you for calling, {{party.firstName}}. Let me connect you
with {{agent.firstName}} right away."
```

### Legal Escalation
Legal questions or mentions of attorneys.
```
AI: "For anything involving legal matters, {{agent.firstName}} will
handle this personally. I'm connecting you now."
```

### Emergency Escalation
Time-critical or safety issues.
```
AI: "I understand this is urgent. I'm reaching {{agent.firstName}}
immediately. Please stay on the line."
```

## Agent Notification Templates

### Immediate - Phone Script
```
"Urgent escalation from {{party.name}} regarding {{deal.address.street | abbreviateAddress}}.
{{escalationType}}. {{briefIssue}}. They're on the line now."
```

### High - SMS
```
[PRIORITY] {{party.name}} needs you
Re: {{deal.address.street | abbreviateAddress}}
{{escalationType}}: {{briefIssue}}
Call/text back within 15 min
{{party.phone}}
```

### Normal - Push Notification
```
Title: Escalation from {{party.name}}
Body: {{escalationType}} - {{briefIssue}}
Actions: [Call Now] [View Details] [Snooze]
```

### Email Summary
```
Subject: Escalation - {{party.name}} - {{escalationType | titleCase}}

Party: {{party.name}} ({{party.role}})
Contact: {{party.phone}} / {{party.email}}
Deal: {{deal.address.street}}
Urgency: {{urgency | uppercase}}

Issue: {{issueDescription}}

Conversation Summary:
{{transcript | summarize}}

Attempted Resolutions:
{{#each attemptedResolutions}}
- {{this}}
{{/each}}

{{#if sentiment}}
Sentiment: {{sentiment.score}} ({{sentiment.indicators | join ', '}})
{{/if}}

Suggested Action: {{suggestedAction}}

[Respond Now] [Schedule Callback] [View Full Context]
```

## Escalation Timer SLAs

| Urgency | Initial Response | Resolution | Re-Escalate After |
|---------|-----------------|------------|-------------------|
| Immediate | 5 minutes | 30 minutes | 10 minutes |
| High | 15 minutes | 2 hours | 30 minutes |
| Normal | 1 hour | 8 hours | 2 hours |

## Error Handling

| Error | Cause | Response |
|-------|-------|----------|
| `AGENT_UNREACHABLE` | All notification methods failed | Escalate to backup, notify party of delay |
| `TRANSFER_FAILED` | Live transfer didn't connect | Schedule callback, apologize to party |
| `CONTEXT_MISSING` | Can't load deal/party info | Proceed with available info, note gap |
| `TIMEOUT` | Expected response time exceeded | Re-notify agent, update party |

## Backup Escalation

If primary agent doesn't respond within SLA:

1. **Check backup agent** (if configured)
   - Team member
   - Broker/manager

2. **Notify party of delay**
   - Apologize
   - Provide new expected time
   - Offer alternative contact

3. **Log escalation failure**
   - Track for quality review
   - Update response time metrics

## Quality Checklist

- [x] Acknowledges escalation request promptly
- [x] Assesses urgency accurately
- [x] Checks agent availability before transfer
- [x] Prepares comprehensive context packet
- [x] Notifies agent via appropriate channels
- [x] Executes warm transfer when possible
- [x] Sets realistic expectations with party
- [x] Logs all escalation details
- [x] Implements follow-up safeguards
- [x] Handles backup escalation when needed
- [x] Tracks escalation resolution
- [x] De-escalates tension appropriately

# Skill: Draft Response

**Category:** Communication
**Priority:** P1
**Approval Required:** Yes (all drafts require agent review before sending)

## Purpose

Generate draft message responses for agent review before sending. Analyzes incoming communication context, applies agent's tone and style, and creates appropriate responses that the agent can approve, edit, or reject. Ensures all outbound communication maintains agent's voice.

## Triggers

### Voice Commands
- "Draft a response to [party]"
- "Help me reply to [email/message]"
- "Write a response about [topic]"
- "Prepare a reply for the [party]"

### System Events
- Incoming message with response needed flag
- Agent clicks "Draft Response" on communication
- Scheduled response generation

## Input

```typescript
{
  incomingCommunication: {
    communicationId: string;
    channel: 'email' | 'sms' | 'phone';
    from: {
      partyId: string;
      name: string;
      role: PartyRole;
    };
    subject?: string;
    body: string;
    receivedAt: Date;
    dealId?: string;
    threadId?: string;
    attachments?: string[];
  };
  draftType:
    | 'reply'                           // Direct response
    | 'forward'                         // Forward with context
    | 'follow_up'                       // Delayed response
    | 'acknowledgment';                 // Simple receipt
  responseChannel?: 'email' | 'sms';    // Default: match incoming
  tone?: 'formal' | 'professional' | 'friendly' | 'urgent';
  includePoints?: string[];             // Specific points to address
  agentGuidance?: string;               // Agent's instructions for draft
  useTemplate?: string;                 // Specific template ID
  contextOverride?: {
    dealStatus?: string;
    additionalInfo?: string;
  };
}
```

## Output

```typescript
{
  success: boolean;
  actionTaken: string;
  result: {
    draftId: string;
    draft: {
      channel: 'email' | 'sms';
      to: {
        email?: string;
        phone?: string;
        name: string;
      };
      cc?: { email: string; name: string }[];
      subject?: string;                 // For email
      body: string;
      replyToMessageId?: string;
      attachmentSuggestions?: string[]; // Recommended attachments
    };
    analysis: {
      incomingIntent: string;
      questionsIdentified: string[];
      requestsIdentified: string[];
      sentimentDetected: string;
      suggestedTone: string;
    };
    alternatives?: {
      version: string;
      body: string;
      description: string;
    }[];
    confidenceScore: number;            // 0-1 how confident in draft
    reviewNotes?: string;               // Notes for agent
  };
  requiresApproval: true;               // Always true for drafts
  approvalMessage: string;
}
```

## Execution Flow

```
START
  |
  +--- 1. Load incoming communication
  |    |
  |    +-- Retrieve full message content
  |    +-- Load thread history (if exists)
  |    +-- Get sender party details
  |    +-- Load deal context
  |
  +--- 2. Analyze incoming message
  |    |
  |    +-- Detect primary intent:
  |    |   +-- Question(s) being asked
  |    |   +-- Request(s) being made
  |    |   +-- Information being provided
  |    |   +-- Concern being expressed
  |    |   +-- Confirmation being given
  |    |
  |    +-- Extract specific elements:
  |    |   +-- Questions to answer
  |    |   +-- Requests to address
  |    |   +-- Dates/times mentioned
  |    |   +-- Documents referenced
  |    |
  |    +-- Assess sentiment:
  |    |   +-- Positive: enthusiastic, satisfied
  |    |   +-- Neutral: informational, procedural
  |    |   +-- Negative: frustrated, concerned
  |    |   +-- Urgent: time-sensitive, demanding
  |    |
  |    +-- Determine appropriate response tone
  |
  +--- 3. Gather response context
  |    |
  |    +-- Load deal status and details:
  |    |   +-- Current stage
  |    |   +-- Recent activity
  |    |   +-- Upcoming deadlines
  |    |   +-- Pending items
  |    |
  |    +-- Check for relevant information:
  |    |   +-- Documents that answer questions
  |    |   +-- Status updates to share
  |    |   +-- Scheduling availability
  |    |
  |    +-- Load agent preferences:
  |        +-- Communication style
  |        +-- Common phrases
  |        +-- Signature format
  |
  +--- 4. Load agent's style profile
  |    |
  |    +-- Analyze previous agent communications:
  |    |   +-- Greeting style
  |    |   +-- Closing style
  |    |   +-- Common phrases used
  |    |   +-- Response length preference
  |    |   +-- Formality level
  |    |
  |    +-- Apply style parameters to draft
  |
  +--- 5. Determine response structure
  |    |
  |    +-- IF simple acknowledgment:
  |    |   +-- Short, confirmatory
  |    |
  |    +-- IF answering questions:
  |    |   +-- Address each question
  |    |   +-- Provide complete answers
  |    |   +-- Offer additional context
  |    |
  |    +-- IF addressing concerns:
  |    |   +-- Acknowledge concern
  |    |   +-- Provide explanation
  |    |   +-- Offer solution/next steps
  |    |
  |    +-- IF providing information:
  |    |   +-- Clear, organized format
  |    |   +-- Highlight key points
  |    |   +-- Call out action items
  |    |
  |    +-- Include:
  |        +-- Greeting appropriate to relationship
  |        +-- Response to each point raised
  |        +-- Proactive helpful information
  |        +-- Clear next steps if applicable
  |        +-- Professional closing
  |
  +--- 6. Generate draft
  |    |
  |    +-- Compose response following structure
  |    +-- Apply agent's style and tone
  |    +-- Ensure all questions addressed
  |    +-- Add relevant deal context
  |    +-- Include signature
  |    |
  |    +-- IF email:
  |    |   +-- Create subject line (if new) or use Re:
  |    |   +-- Format for readability
  |    |   +-- Suggest attachments if relevant
  |    |
  |    +-- IF SMS:
  |        +-- Keep concise (<160 chars if possible)
  |        +-- Focus on key point
  |        +-- Include callback option for complex topics
  |
  +--- 7. Generate alternatives (optional)
  |    |
  |    +-- IF confidence < 0.8:
  |    |   +-- Generate 2-3 alternative versions
  |    |   +-- Vary tone: more formal, more casual
  |    |   +-- Vary length: shorter, more detailed
  |    |
  |    +-- Provide description of each alternative
  |
  +--- 8. Add review notes
  |    |
  |    +-- Flag uncertain areas
  |    +-- Note assumptions made
  |    +-- Suggest agent verification points
  |    +-- Highlight if deal info might be outdated
  |
  +--- 9. Save draft
  |    |
  |    |   INSERT INTO communication_drafts (
  |    |     incoming_communication_id,
  |    |     deal_id, party_id,
  |    |     channel, subject, body,
  |    |     analysis, alternatives,
  |    |     status = 'pending_review',
  |    |     created_at
  |    |   )
  |
  +--- 10. Present for approval
  |    |
  |    +-- Show draft to agent
  |    +-- Display incoming message for reference
  |    +-- Show analysis of incoming
  |    +-- Offer alternatives
  |    +-- Provide edit capability
  |    |
  |    +-- Agent options:
  |        +-- Approve and send
  |        +-- Edit and send
  |        +-- Choose alternative
  |        +-- Reject (write own)
  |        +-- Save for later
  |
  +--- 11. Return result
```

## Response Templates by Intent

### Answering Questions
```
Hi {{party.firstName}},

{{#if multipleQuestions}}
Great questions! Let me address each one:
{{/if}}

{{#each questions}}
{{#if ../multipleQuestions}}**{{this.question}}**
{{/if}}
{{this.answer}}

{{/each}}

{{#if additionalContext}}
{{additionalContext}}
{{/if}}

Let me know if you have any other questions.

{{signature}}
```

### Addressing Concerns
```
Hi {{party.firstName}},

Thank you for reaching out about {{concernTopic}}. I completely understand your concern.

{{explanation}}

{{resolution}}

{{#if nextSteps}}
Here's what happens next:
{{#each nextSteps}}
- {{this}}
{{/each}}
{{/if}}

Please don't hesitate to call me if you'd like to discuss this further.

{{signature}}
```

### Providing Information
```
Hi {{party.firstName}},

{{#if requestedInfo}}
Here's the information you requested:

{{requestedInfo}}
{{/if}}

{{#if statusUpdate}}
**Current Status:** {{statusUpdate}}
{{/if}}

{{#if upcomingItems}}
**Coming Up:**
{{#each upcomingItems}}
- {{this.item}} - {{this.date | formatDate}}
{{/each}}
{{/if}}

Let me know if you need anything else.

{{signature}}
```

### Simple Acknowledgment
```
Hi {{party.firstName}},

Got it, thank you for {{acknowledgmentReason}}. {{#if nextStep}}I'll {{nextStep}}.{{/if}}

{{signature}}
```

### Urgent Response
```
Hi {{party.firstName}},

I just saw your message and wanted to respond right away.

{{urgentContent}}

{{#if needsCall}}
I'm available to discuss this by phone{{#if availability}} {{availability}}{{/if}}.
Please call me at {{agent.phone}} or let me know a good time to reach you.
{{/if}}

{{signature}}
```

## Style Matching

### Tone Parameters
| Tone | Greeting | Language | Closing |
|------|----------|----------|---------|
| Formal | "Dear {{name}}" | No contractions | "Sincerely" |
| Professional | "Hi {{name}}" | Standard business | "Best regards" |
| Friendly | "Hey {{name}}" | Conversational | "Thanks!" |
| Urgent | "{{name}} -" | Direct, concise | "ASAP" |

### Agent Style Learning
Learn from agent's historical communications:
- Average response length
- Greeting patterns
- Favorite phrases
- Emoji usage (yes/no)
- Signature preferences

## Confidence Scoring

| Factor | Impact |
|--------|--------|
| Clear single intent | +0.2 |
| Multiple complex questions | -0.2 |
| Deal context available | +0.2 |
| Negative sentiment detected | -0.1 |
| Legal/financial topics | -0.3 |
| Similar past response exists | +0.2 |
| Negotiation content | -0.4 |

**Thresholds:**
- 0.8+: High confidence, suggest approve
- 0.6-0.8: Good draft, review recommended
- <0.6: Multiple alternatives, close review needed

## Error Handling

| Error | Cause | Response |
|-------|-------|----------|
| `NO_CONTEXT` | Deal/party info missing | Draft with caveats, flag for review |
| `COMPLEX_INTENT` | Can't determine intent | Present options, ask agent to clarify |
| `LEGAL_CONTENT` | Legal terms detected | Refuse to draft, recommend attorney |
| `SENSITIVE_TOPIC` | Compensation, complaints | Draft cautiously, require review |

## Draft States

| State | Description |
|-------|-------------|
| `pending_review` | Awaiting agent review |
| `approved` | Agent approved, ready to send |
| `edited` | Agent made changes |
| `rejected` | Agent will write own |
| `sent` | Response has been sent |
| `expired` | Too old, may be outdated |

## Quality Checklist

- [x] Analyzes incoming message thoroughly
- [x] Identifies all questions and requests
- [x] Assesses sender sentiment
- [x] Loads relevant deal context
- [x] Matches agent's communication style
- [x] Addresses all points raised
- [x] Maintains appropriate tone
- [x] Generates alternatives when uncertain
- [x] Flags areas needing verification
- [x] Always requires agent approval
- [x] Supports agent editing
- [x] Tracks draft through to send

# Skill: Summarize Thread

**Category:** Communication
**Priority:** P1
**Approval Required:** No

## Purpose

Generate concise, actionable summaries of email chains and conversation threads. Helps agents quickly understand communication history, identify action items, and prepare for client interactions without reading through entire threads.

## Triggers

### Voice Commands
- "Summarize the email thread with [party]"
- "What's the history with [name]?"
- "Give me a recap of the [topic] conversation"
- "What did [party] say about [subject]?"
- "Catch me up on [deal/party] communications"

### System Events
- Long email thread detected (5+ messages)
- Agent opens thread after 48+ hours
- Deal handoff preparation
- Escalation context preparation

## Input

```typescript
{
  threadId?: string;                    // Specific thread ID
  dealId?: string;                      // All communications for deal
  partyId?: string;                     // All communications with party
  communicationIds?: string[];          // Specific message IDs
  filters?: {
    channel?: ('email' | 'sms' | 'phone')[];
    dateRange?: {
      start: Date;
      end: Date;
    };
    includeInternal?: boolean;          // Include agent-to-agent
  };
  summaryType:
    | 'brief'                           // 2-3 sentences
    | 'standard'                        // Paragraph with key points
    | 'detailed'                        // Full analysis
    | 'action_items'                    // Just action items
    | 'timeline';                       // Chronological events
  focusArea?: string;                   // Specific topic to focus on
  includeQuotes?: boolean;              // Include key quotes
}
```

## Output

```typescript
{
  success: boolean;
  actionTaken: string;
  result: {
    summaryId: string;
    threadInfo: {
      messageCount: number;
      participants: {
        name: string;
        role: string;
        messageCount: number;
      }[];
      dateRange: {
        first: Date;
        last: Date;
      };
      channels: string[];
    };
    summary: {
      type: string;
      content: string;
      keyPoints?: string[];
      actionItems?: {
        item: string;
        owner: string;
        dueDate?: Date;
        status: 'pending' | 'mentioned' | 'completed';
      }[];
      decisions?: string[];
      openQuestions?: string[];
      sentiment?: {
        overall: 'positive' | 'neutral' | 'negative' | 'mixed';
        trend: 'improving' | 'stable' | 'declining';
      };
      keyQuotes?: {
        quote: string;
        from: string;
        date: Date;
        context: string;
      }[];
      timeline?: {
        date: Date;
        event: string;
        significance: 'high' | 'medium' | 'low';
      }[];
    };
    relatedDeals?: string[];
    suggestedNextSteps?: string[];
  };
  shouldContinue: boolean;
}
```

## Execution Flow

```
START
  |
  +--- 1. Gather communications
  |    |
  |    +-- IF threadId provided:
  |    |   +-- Load thread by ID
  |    |   +-- Get all messages in thread
  |    |
  |    +-- IF dealId provided:
  |    |   +-- Query all communications for deal
  |    |   +-- Apply filters (channel, date, etc.)
  |    |
  |    +-- IF partyId provided:
  |    |   +-- Query all communications with party
  |    |   +-- Across all deals
  |    |
  |    +-- IF communicationIds provided:
  |        +-- Load specific messages
  |        +-- Order chronologically
  |
  +--- 2. Parse and structure messages
  |    |
  |    +-- FOR EACH message:
  |    |   +-- Extract sender and recipients
  |    |   +-- Parse body (remove signatures, disclaimers)
  |    |   +-- Handle quoted content (show context, avoid duplication)
  |    |   +-- Extract any mentioned dates/deadlines
  |    |   +-- Identify questions and requests
  |    |
  |    +-- Build conversation structure:
  |        +-- Who said what when
  |        +-- What was replied to what
  |        +-- Topic transitions
  |
  +--- 3. Identify participants
  |    |
  |    +-- List all unique participants
  |    +-- Determine roles (buyer, seller, agent, lender, etc.)
  |    +-- Count messages per participant
  |    +-- Note primary conversation drivers
  |
  +--- 4. Analyze content
  |    |
  |    +-- Extract key topics discussed
  |    +-- Identify decisions made
  |    +-- Find action items (explicit and implied)
  |    +-- Detect questions (answered and unanswered)
  |    +-- Note commitments and deadlines
  |    |
  |    +-- IF focusArea specified:
  |        +-- Filter analysis to relevant content
  |        +-- Highlight focus area mentions
  |
  +--- 5. Assess sentiment
  |    |
  |    +-- Analyze tone of messages:
  |    |   +-- Positive indicators: thanks, great, excited
  |    |   +-- Negative indicators: frustrated, concerned, disappointed
  |    |   +-- Neutral: informational, procedural
  |    |
  |    +-- Track sentiment over time:
  |    |   +-- Compare early vs recent messages
  |    |   +-- Identify turning points
  |    |
  |    +-- Note concerning patterns:
  |        +-- Increasing frustration
  |        +-- Decreasing engagement
  |        +-- Unanswered questions
  |
  +--- 6. Generate summary
  |    |
  |    +-- BASED ON summaryType:
  |    |
  |    +-- brief:
  |    |   +-- 2-3 sentence overview
  |    |   +-- Main topic and current status
  |    |   +-- Most important next step
  |    |
  |    +-- standard:
  |    |   +-- Paragraph overview
  |    |   +-- Bulleted key points
  |    |   +-- Action items list
  |    |   +-- Current status
  |    |
  |    +-- detailed:
  |    |   +-- Comprehensive analysis
  |    |   +-- All key points with context
  |    |   +-- Full action item breakdown
  |    |   +-- Sentiment analysis
  |    |   +-- Timeline of events
  |    |   +-- Open questions
  |    |   +-- Suggested next steps
  |    |
  |    +-- action_items:
  |    |   +-- Just the action items
  |    |   +-- Categorized by owner
  |    |   +-- With due dates if mentioned
  |    |
  |    +-- timeline:
  |        +-- Chronological list of events
  |        +-- Key milestones highlighted
  |        +-- Decision points marked
  |
  +--- 7. Extract quotes (if requested)
  |    |
  |    +-- Find significant statements:
  |    |   +-- Commitments: "I will..."
  |    |   +-- Decisions: "We've decided..."
  |    |   +-- Concerns: "I'm worried about..."
  |    |   +-- Approvals: "That works for me..."
  |    |
  |    +-- Include context for each quote
  |
  +--- 8. Generate suggestions
  |    |
  |    +-- Based on thread analysis:
  |    |   +-- Unanswered questions to address
  |    |   +-- Pending items to follow up
  |    |   +-- Concerns to acknowledge
  |    |   +-- Next logical steps
  |    |
  |    +-- Prioritize by urgency
  |
  +--- 9. Cache summary
  |    |
  |    +-- Store for quick retrieval
  |    +-- Invalidate when new message arrives
  |
  +--- 10. Return result
```

## Summary Templates

### Brief Summary
```
{{messageCount}} messages between {{participantsSummary}} from {{dateRange}}.
Main topic: {{mainTopic}}. Current status: {{currentStatus}}.
{{#if topActionItem}}Next step: {{topActionItem}}.{{/if}}
```

### Standard Summary
```
**Thread Summary: {{subject}}**

{{overview}}

**Key Points:**
{{#each keyPoints}}
- {{this}}
{{/each}}

**Action Items:**
{{#each actionItems}}
- [ ] {{this.item}} ({{this.owner}}){{#if this.dueDate}} - Due {{this.dueDate | formatDate}}{{/if}}
{{/each}}

**Status:** {{currentStatus}}
```

### Detailed Summary
```
**Communication Analysis: {{subject}}**

**Overview**
{{detailedOverview}}

**Participants**
{{#each participants}}
- {{this.name}} ({{this.role}}): {{this.messageCount}} messages
{{/each}}

**Timeline**
{{#each timeline}}
- {{this.date | formatDate}}: {{this.event}}
{{/each}}

**Key Decisions Made**
{{#each decisions}}
- {{this}}
{{/each}}

**Open Questions**
{{#each openQuestions}}
- {{this}}
{{/each}}

**Action Items**
| Item | Owner | Due | Status |
|------|-------|-----|--------|
{{#each actionItems}}
| {{this.item}} | {{this.owner}} | {{this.dueDate | formatDate}} | {{this.status}} |
{{/each}}

**Sentiment Analysis**
Overall: {{sentiment.overall}} | Trend: {{sentiment.trend}}
{{sentimentNotes}}

**Key Quotes**
{{#each keyQuotes}}
> "{{this.quote}}"
> — {{this.from}}, {{this.date | formatDate}}
{{/each}}

**Suggested Next Steps**
{{#each suggestedNextSteps}}
1. {{this}}
{{/each}}
```

### Action Items Only
```
**Action Items from {{subject}}**

**Agent Tasks:**
{{#each agentActions}}
- [ ] {{this.item}}{{#if this.dueDate}} (Due: {{this.dueDate | formatDate}}){{/if}}
{{/each}}

**Waiting On Others:**
{{#each waitingOn}}
- {{this.item}} - Waiting on {{this.owner}}
{{/each}}
```

### Timeline Format
```
**Communication Timeline: {{subject}}**

{{#each timeline}}
**{{this.date | formatDateTime}}** {{#if this.significance === 'high'}}*{{/if}}
{{this.from}}: {{this.summary}}
{{#if this.actionTaken}}→ {{this.actionTaken}}{{/if}}

{{/each}}
```

## Content Analysis Rules

### Action Item Detection
Keywords that indicate action items:
- "Please [verb]...", "Could you [verb]..."
- "I need [noun]...", "We require..."
- "Make sure to...", "Don't forget to..."
- "By [date]...", "Before [event]..."
- Questions seeking confirmation

### Decision Detection
Phrases indicating decisions:
- "We've decided to...", "Let's go with..."
- "I approve...", "That works..."
- "Confirmed:", "Agreed:"
- "We will proceed with..."

### Question Detection
- Sentences ending with "?"
- "Can you...", "Will you...", "Do you..."
- "What about...", "How should we..."
- "Is it possible...", "Would it be okay..."

### Sentiment Indicators
| Positive | Negative | Neutral |
|----------|----------|---------|
| Thanks, Great, Excited | Frustrated, Concerned, Disappointed | Regarding, Please note |
| Perfect, Wonderful | Worried, Upset, Confused | As discussed, For your reference |
| Appreciate, Happy | Problem, Issue, Delay | Attached, Following up |

## Error Handling

| Error | Cause | Response |
|-------|-------|----------|
| `NO_MESSAGES` | Empty thread/filter | Return empty summary with explanation |
| `ACCESS_DENIED` | Unauthorized messages | Skip unauthorized, summarize accessible |
| `TOO_MANY_MESSAGES` | Thread too large (500+) | Summarize most recent, note truncation |
| `PARSE_ERROR` | Malformed message content | Skip problematic, note in summary |
| `TIMEOUT` | Analysis taking too long | Return partial summary |

## Caching Strategy

- Cache summaries by thread ID
- Cache duration: Until new message arrives
- Invalidation: Automatic on new communication
- Refresh trigger: User explicitly requests update

## Quality Checklist

- [x] Gathers all relevant communications
- [x] Parses message content accurately
- [x] Removes signature/disclaimer noise
- [x] Identifies all participants and roles
- [x] Extracts action items comprehensively
- [x] Detects decisions and commitments
- [x] Finds unanswered questions
- [x] Analyzes sentiment appropriately
- [x] Generates appropriate summary type
- [x] Includes relevant quotes when requested
- [x] Suggests logical next steps
- [x] Handles large threads gracefully
- [x] Caches for performance

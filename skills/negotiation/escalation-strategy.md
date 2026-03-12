# Skill: Escalation Strategy

**Category:** Negotiation
**Priority:** P0
**Approval Required:** Yes (all escalation decisions require human approval)

## Purpose

Determine when negotiations have exceeded the agent's scope or AI capabilities and require escalation to senior agents, brokers, attorneys, or other professionals. This skill monitors negotiation health, identifies warning signs, and provides clear escalation paths with appropriate urgency levels.

## Triggers

### Voice Commands
- "Should I escalate this?"
- "This negotiation is stuck"
- "I need help with this deal"
- "When should I involve my broker?"
- "Is this beyond my scope?"
- "Call for backup"
- "Get a supervisor involved"
- "This is getting complicated"

### System Events
- Negotiation stalled (no movement in X days)
- Multiple counter-offers (5+ rounds)
- Deadline approaching with no resolution
- Legal language or threats detected
- Unusual contract terms requested
- Agent requests escalation assessment
- Client expressing frustration

## Required Inputs

| Input | Type | Required | Source | Description |
|-------|------|----------|--------|-------------|
| `dealId` | string | Yes | context | The deal being evaluated |

## Optional Inputs

| Input | Type | Default | Source | Description |
|-------|------|---------|--------|-------------|
| `issue` | string | null | agent | Specific issue to evaluate |
| `urgency` | string | 'normal' | agent | Perceived urgency level |
| `clientMood` | string | 'neutral' | agent | Client satisfaction state |
| `negotiationHistory` | NegotiationEvent[] | null | deal | Full negotiation history |
| `daysInNegotiation` | number | null | deal | Days negotiating |
| `deadlineApproaching` | boolean | null | deal | Is a deadline near? |

## Output Schema

```typescript
{
  success: boolean;
  actionTaken: string;
  result: {
    assessment: {
      shouldEscalate: boolean;
      escalationType: 'none' | 'advisory' | 'required' | 'urgent' | 'critical';
      confidence: number; // 0-100
      reasoning: string;
    };
    warningSignals: WarningSignal[];
    escalationPath: EscalationStep[];
    recommendedResource: {
      type: 'broker' | 'attorney' | 'senior_agent' | 'mediator' | 'specialist';
      reason: string;
      urgency: 'low' | 'medium' | 'high' | 'immediate';
      contactInfo?: string;
    };
    alternatives: {
      action: string;
      likelihood: string;
      risk: string;
    }[];
    agentGuidance: {
      whatToDo: string[];
      whatToAvoid: string[];
      talkingPoints: string[];
    };
    timeline: {
      maxTimeBeforeEscalation: string;
      criticalDeadlines: Deadline[];
    };
    nextSteps: string[];
  };
  requiresApproval: true;
  approvalContext: {
    action: "Escalate to human expert";
    stakes: "varies";
    reversible: false;
  };
}

interface WarningSignal {
  signal: string;
  severity: 'low' | 'medium' | 'high' | 'critical';
  detected: Date;
  details: string;
  action: string;
}

interface EscalationStep {
  step: number;
  escalateTo: string;
  when: string;
  how: string;
  expectedOutcome: string;
}
```

## Execution Flow

```
START
  │
  ├─── 1. Load deal and negotiation context
  │    ├── Get full negotiation history
  │    ├── Identify current status
  │    ├── Load all deadlines
  │    └── Check client communications
  │
  ├─── 2. Scan for warning signals
  │    │
  │    ├─── Legal warning signs
  │    │    ├── Attorney involvement threatened
  │    │    ├── Legal language in communications
  │    │    ├── Fraud allegations
  │    │    └── Licensing complaints mentioned
  │    │
  │    ├─── Relationship warning signs
  │    │    ├── Hostile communications
  │    │    ├── Personal attacks
  │    │    ├── Unreasonable demands
  │    │    └── Client distress
  │    │
  │    ├─── Process warning signs
  │    │    ├── Stalled negotiation (5+ days)
  │    │    ├── Multiple failed counters
  │    │    ├── Deadline pressure
  │    │    └── Unusual terms requested
  │    │
  │    └─── Complexity warning signs
  │         ├── Multiple contingencies at risk
  │         ├── Lender issues
  │         ├── Title problems
  │         └── Estate/trust/entity involved
  │
  ├─── 3. Calculate escalation score
  │    ├── Weight each signal by severity
  │    ├── Consider cumulative impact
  │    ├── Adjust for urgency
  │    └── Determine escalation type
  │
  ├─── 4. Determine escalation path
  │    │
  │    ├─── Level 0: No escalation needed
  │    │    └── Continue with current approach
  │    │
  │    ├─── Level 1: Advisory consultation
  │    │    ├── Check in with broker
  │    │    ├── Peer review
  │    │    └── Strategy session
  │    │
  │    ├─── Level 2: Required escalation
  │    │    ├── Broker involvement
  │    │    ├── Senior agent support
  │    │    └── Formal escalation
  │    │
  │    ├─── Level 3: Urgent professional help
  │    │    ├── Attorney consultation
  │    │    ├── Title company escalation
  │    │    └── Lender escalation
  │    │
  │    └─── Level 4: Critical - Immediate action
  │         ├── Legal counsel immediately
  │         ├── Broker emergency
  │         └── Regulatory consideration
  │
  ├─── 5. Identify appropriate resource
  │    ├── Match issue type to expert
  │    ├── Check urgency requirements
  │    └── Provide contact paths
  │
  ├─── 6. Generate guidance for agent
  │    ├── What to do now
  │    ├── What to avoid
  │    ├── Talking points
  │    └── Documentation needs
  │
  ├─── 7. Set timeline
  │    ├── Time until must escalate
  │    ├── Critical deadlines
  │    └── Follow-up schedule
  │
  ├─── 8. Log assessment
  │    └── action_type: 'escalation_assessed'
  │
  └─── 9. Present recommendation
```

## Warning Signal Categories

### Level 1: Monitor (Low Severity)

| Signal | Indicator | Action |
|--------|-----------|--------|
| Slow Response | >48 hours between communications | Follow up, document |
| Minor Disagreement | Normal negotiation back-and-forth | Continue process |
| Client Questions | Standard concerns about deal | Educate, reassure |
| First Counter-Reject | Initial offer rejected | Normal, make counter |

### Level 2: Attention (Medium Severity)

| Signal | Indicator | Action |
|--------|-----------|--------|
| Extended Negotiation | 5+ counter-offers | Strategy review |
| Client Frustration | Multiple complaints | Check in with client |
| Deadline Pressure | <3 days to deadline | Accelerate resolution |
| Unusual Terms | Non-standard requests | Research and consult |
| Agent Conflict | Disagreement with other agent | Involve brokers |

### Level 3: Escalate (High Severity)

| Signal | Indicator | Action |
|--------|-----------|--------|
| Stalled Negotiation | No movement 7+ days | Broker involvement |
| Client Distress | Threats to withdraw/sue | Immediate attention |
| Other Agent Hostile | Unprofessional behavior | Broker-to-broker |
| Complex Legal Issue | Beyond standard contract | Attorney consult |
| Multiple Issues | 3+ simultaneous problems | Senior agent help |
| Financial Discrepancy | Numbers don't add up | Lender/title check |

### Level 4: Critical (Immediate Action)

| Signal | Indicator | Action |
|--------|-----------|--------|
| Legal Threat | "See you in court" | Attorney immediately |
| Fraud Allegation | Claims of misrepresentation | Broker + legal |
| License Complaint | "I'm filing a complaint" | Broker + legal |
| Safety Concern | Threats or harassment | Broker + authorities |
| Contract Breach | Material breach occurring | Attorney |
| Earnest Money Dispute | Fight over deposit | Title + attorney |

## Escalation Score Calculation

```typescript
function calculateEscalationScore(signals: WarningSignal[]): EscalationResult {
  const severityWeights = {
    low: 1,
    medium: 3,
    high: 7,
    critical: 15
  };

  let totalScore = 0;
  let hasCritical = false;

  for (const signal of signals) {
    totalScore += severityWeights[signal.severity];
    if (signal.severity === 'critical') hasCritical = true;
  }

  // Critical signals always escalate
  if (hasCritical) {
    return { type: 'critical', score: totalScore, immediate: true };
  }

  // Scoring thresholds
  if (totalScore >= 20) return { type: 'urgent', score: totalScore, immediate: false };
  if (totalScore >= 10) return { type: 'required', score: totalScore, immediate: false };
  if (totalScore >= 5) return { type: 'advisory', score: totalScore, immediate: false };

  return { type: 'none', score: totalScore, immediate: false };
}
```

## Escalation Resources

### Broker Involvement
**When:**
- Agent conflict with other side
- Client threatening to leave
- Deal value > threshold
- Complex legal questions
- Licensing concerns

**How:**
1. Document situation thoroughly
2. Schedule call with broker
3. Present facts objectively
4. Follow broker's guidance
5. Document resolution

### Attorney Consultation
**When:**
- Legal threats made
- Contract interpretation dispute
- Fraud allegations
- Unusual legal structures (trusts, estates)
- Potential liability issues

**How:**
1. Gather all documentation
2. Contact approved transaction attorney
3. Do NOT give legal advice yourself
4. Document attorney's guidance
5. Follow recommended actions

### Senior Agent/Mentor
**When:**
- Complex negotiation tactics needed
- Unusual property situations
- First-time scenario for agent
- Strategy advice needed

**How:**
1. Request informal consultation
2. Share situation overview
3. Ask specific questions
4. Apply guidance
5. Report outcome

### Title Company Escalation
**When:**
- Title issues discovered
- Survey problems
- Lien discoveries
- Ownership questions

**How:**
1. Contact title officer directly
2. Request issue clarification
3. Get resolution timeline
4. Communicate to parties
5. Document resolution

## Voice Response

**When escalation is recommended:**
> "I'm seeing some warning signs on this deal that suggest we should escalate:
>
> **Warning Signals Detected:**
> 1. Negotiation stalled for 8 days (High)
> 2. Other agent becoming hostile in emails (High)
> 3. Buyer threatening to walk (Medium)
> 4. Deadline in 3 days (Medium)
>
> **My Recommendation:** Required escalation to your broker.
>
> **Why:** When the other agent is unprofessional and negotiations are stalled near a deadline, broker-to-broker communication often breaks the logjam. Your broker can also protect you if there are complaints later.
>
> **What to do:**
> 1. Document all communications (I can generate a summary)
> 2. Call your broker today
> 3. Don't engage further with the hostile agent directly
> 4. Let broker handle agent-to-broker communication
>
> Would you like me to prepare the documentation for your broker call?"

**When legal escalation is needed:**
> "**CRITICAL: This situation requires attorney involvement.**
>
> The other party has made a fraud allegation in writing. This is beyond normal real estate negotiation and could affect your license.
>
> **Immediate Actions:**
> 1. STOP all direct communication about this allegation
> 2. Contact your broker within the hour
> 3. Request attorney consultation through your brokerage
> 4. Document everything but don't respond yet
>
> I can prepare a timeline of events for your attorney. This is not something I can help you negotiate through - you need human legal counsel.
>
> Should I prepare the documentation?"

## Error Handling

| Error | Cause | Response |
|-------|-------|----------|
| `INSUFFICIENT_HISTORY` | Not enough data to assess | "I don't have enough history on this negotiation. Can you tell me what's happening?" |
| `ALREADY_ESCALATED` | Issue already escalated | "This issue was already escalated on [date]. Here's the status..." |
| `NO_CONTACT_INFO` | Can't find escalation resource | "I recommend escalating to [role], but I don't have their contact info. Can you provide it?" |
| `MULTIPLE_CRITICAL` | Several critical issues | "There are multiple critical issues requiring immediate professional help. Start with [most urgent]." |

## Approval Gate

**This skill ALWAYS requires human approval before:**
1. Contacting any escalation resource
2. Changing communication strategy
3. Pausing negotiations
4. Recommending withdrawal from deal

**Approval Dialog:**
```
┌─────────────────────────────────────────────────────────────┐
│ ESCALATION ASSESSMENT                                        │
├─────────────────────────────────────────────────────────────┤
│ Deal: 123 Main Street                                        │
│ Escalation Level: REQUIRED (Score: 14)                       │
│                                                              │
│ WARNING SIGNALS:                                             │
│ ⚠️ Negotiation stalled 8 days (High)                         │
│ ⚠️ Other agent hostile communications (High)                 │
│ ⚠ Client expressing frustration (Medium)                     │
│ ⚠ Deadline in 3 days (Medium)                                │
│                                                              │
│ RECOMMENDED ACTION:                                          │
│ Escalate to: Broker                                          │
│ Urgency: High (within 24 hours)                              │
│ Reason: Agent conflict + stalled negotiation                 │
│                                                              │
│ [Proceed with Escalation] [Continue Monitoring] [Override]  │
└─────────────────────────────────────────────────────────────┘
```

## Agent Guidance Templates

### Before Broker Call
```
Preparation Checklist:
□ Timeline of events documented
□ All communications gathered
□ Current status summarized
□ Specific ask for broker identified
□ Available for call at [times]

Key Points to Cover:
1. Deal overview (address, price, parties)
2. What happened (chronological)
3. Current situation
4. What you've tried
5. What you need help with
```

### Before Attorney Call
```
Documentation to Prepare:
□ Purchase contract (all pages, signed)
□ All addenda and amendments
□ Communication timeline
□ Specific legal question written out
□ Deadline calendar

Remember:
- Describe facts, not opinions
- Don't admit fault or liability
- Take notes on attorney's advice
- Get guidance in writing if possible
- Follow instructions exactly
```

### Communication Pause Template
```
"Thank you for your message. We are reviewing the situation internally
and will respond by [date/time]. Please direct any urgent matters to
[broker name] at [broker contact] in the interim."
```

## AI Limitation Acknowledgment

This skill explicitly recognizes when AI cannot help:

```typescript
const AI_LIMITATIONS = [
  {
    situation: "Legal advice needed",
    response: "I can help you prepare documentation, but I cannot give legal advice. You need an attorney.",
    canDo: ["Prepare timeline", "Gather documents", "Draft factual summary"],
    cannotDo: ["Interpret legal implications", "Advise on liability", "Recommend legal strategy"]
  },
  {
    situation: "Fraud allegation",
    response: "Fraud allegations are beyond my scope. Stop and get professional help immediately.",
    canDo: ["Document timeline", "Prepare facts"],
    cannotDo: ["Defend against allegations", "Advise on response"]
  },
  {
    situation: "Hostile party",
    response: "I can help you document, but human intervention is needed for hostile situations.",
    canDo: ["Draft professional responses", "Document behavior"],
    cannotDo: ["De-escalate hostile humans", "Negotiate with irrational parties"]
  },
  {
    situation: "Complex legal structures",
    response: "Trusts, estates, and entity transactions require specialized legal review.",
    canDo: ["Identify complexity", "Flag for review"],
    cannotDo: ["Interpret trust documents", "Advise on entity issues"]
  }
];
```

## Integration Points

### Inputs From
- All negotiation skills - Status and history
- Communication logs - Tone analysis
- Deal timeline - Deadline tracking
- Client interaction history - Satisfaction signals

### Triggers After
- Alert broker dashboard (if escalation approved)
- Update deal status
- Pause automated communications (if needed)
- Schedule follow-up assessment

### Database Tables
- `escalations` - Escalation records
- `warning_signals` - Detected signals
- `action_log` - Audit trail
- `communications` - Message history

## Quality Checklist

- [x] Monitors all negotiation warning signals
- [x] Calculates objective escalation scores
- [x] Identifies appropriate escalation resource
- [x] Provides clear urgency levels
- [x] Generates agent guidance
- [x] Includes documentation templates
- [x] Acknowledges AI limitations explicitly
- [x] Requires human approval for all escalations
- [x] Tracks escalation outcomes
- [x] Integrates with broker notifications
- [x] Creates comprehensive audit trail
- [x] Provides timeline and deadline awareness

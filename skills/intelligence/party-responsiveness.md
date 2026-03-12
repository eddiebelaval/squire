# Skill: Party Responsiveness

**Category:** Intelligence
**Priority:** P1
**Approval Required:** No

## Purpose

Track and analyze response times for all parties in a transaction. Identify slow responders, communication patterns, and flag parties who may be causing delays. This intelligence helps agents proactively manage relationships and prevent bottlenecks.

## Triggers

### Voice Commands
- "Who's being slow on [address]?"
- "How responsive is the lender?"
- "Response times for [deal]"
- "Is the buyer responding?"
- "Who should I follow up with?"
- "Check party responsiveness"
- "Who's holding things up?"

### Automatic
- When party hasn't responded in 48+ hours
- When deadline approaches with pending party action
- Daily analysis run (with risk assessment)
- After communication sent, track response

### Programmatic
- `GET /deals/:id/party-responsiveness`
- `GET /parties/:id/responsiveness`
- Risk assessment integration
- Dashboard display

## Responsiveness Metrics

### Core Metrics per Party

```typescript
interface PartyResponsiveness {
  partyId: string;
  partyName: string;
  partyRole: PartyRole;
  dealId: string;

  // Response Time Metrics
  averageResponseTime: number;       // Hours
  medianResponseTime: number;        // Hours
  fastestResponse: number;           // Hours
  slowestResponse: number;           // Hours
  responseTimeVariance: number;      // Consistency measure

  // Volume Metrics
  totalMessagesSent: number;
  totalMessagesReceived: number;
  totalResponsesNeeded: number;
  totalResponsesGiven: number;
  responseRate: number;              // Percentage

  // Current Status
  lastContactedAt: Date;
  lastRespondedAt: Date;
  hoursSinceLastContact: number;
  pendingResponseCount: number;
  oldestPendingMessage: Date | null;

  // Pattern Analysis
  preferredContactMethod: 'email' | 'sms' | 'phone' | 'unknown';
  typicalResponseWindow: string;     // e.g., "weekday mornings"
  responseTrend: 'IMPROVING' | 'STABLE' | 'DECLINING';

  // Classification
  responsivenessScore: number;       // 0-100
  classification: 'EXCELLENT' | 'GOOD' | 'FAIR' | 'SLOW' | 'UNRESPONSIVE';
  riskLevel: 'LOW' | 'MEDIUM' | 'HIGH';
}
```

### Response Time Classification

| Classification | Avg Response Time | Score Range | Description |
|---------------|-------------------|-------------|-------------|
| `EXCELLENT` | < 4 hours | 90-100 | Same-day response |
| `GOOD` | 4-12 hours | 70-89 | Within business hours |
| `FAIR` | 12-24 hours | 50-69 | Next day response |
| `SLOW` | 24-48 hours | 25-49 | Taking time |
| `UNRESPONSIVE` | > 48 hours | 0-24 | Problem communication |

### Scoring Algorithm

```typescript
function calculateResponsivenessScore(party: PartyData): number {
  let score = 100;

  // Base score from average response time
  const avgHours = party.averageResponseTime;
  if (avgHours <= 4) score = 100;
  else if (avgHours <= 12) score = 90 - ((avgHours - 4) / 8 * 20);
  else if (avgHours <= 24) score = 70 - ((avgHours - 12) / 12 * 20);
  else if (avgHours <= 48) score = 50 - ((avgHours - 24) / 24 * 25);
  else score = Math.max(0, 25 - ((avgHours - 48) / 48 * 25));

  // Adjust for consistency
  if (party.responseTimeVariance > 24) {
    score -= 10; // Inconsistent responder
  }

  // Adjust for response rate
  if (party.responseRate < 0.9) {
    score -= (1 - party.responseRate) * 20; // Penalize non-responses
  }

  // Adjust for current pending items
  if (party.pendingResponseCount > 0) {
    const hoursPending = party.oldestPendingMessage
      ? hoursSince(party.oldestPendingMessage)
      : 0;
    if (hoursPending > 48) score -= 15;
    else if (hoursPending > 24) score -= 10;
    else if (hoursPending > 12) score -= 5;
  }

  // Adjust for trend
  if (party.responseTrend === 'DECLINING') score -= 10;
  if (party.responseTrend === 'IMPROVING') score += 5;

  return Math.max(0, Math.min(100, score));
}
```

## Party Role Expectations

Different parties have different expected response times based on their professional obligations:

| Party Role | Expected Response | Escalation Threshold | Critical Threshold |
|-----------|-------------------|---------------------|-------------------|
| **Buyer's Agent** | < 4 hours | 24 hours | 48 hours |
| **Seller's Agent** | < 4 hours | 24 hours | 48 hours |
| **Lender** | < 8 hours | 48 hours | 72 hours |
| **Title Company** | < 8 hours | 48 hours | 72 hours |
| **Buyer** | < 24 hours | 48 hours | 72 hours |
| **Seller** | < 24 hours | 48 hours | 72 hours |
| **Appraiser** | < 24 hours | 48 hours | 72 hours |
| **Inspector** | < 24 hours | 48 hours | 72 hours |
| **HOA** | < 48 hours | 72 hours | 96 hours |
| **Attorney** | < 24 hours | 48 hours | 72 hours |

## Execution Flow

```
START
  │
  ├─── 1. Load party and communication data
  │    ├── Get all parties for deal (or specific party)
  │    ├── Get all communications per party
  │    ├── Get pending action items
  │    └── Get historical responsiveness (if exists)
  │
  ├─── 2. FOR EACH party:
  │    │
  │    ├─── 2a. Calculate response times
  │    │    │
  │    │    ├── FOR EACH outbound message:
  │    │    │   ├── Find corresponding response (if any)
  │    │    │   ├── Calculate time difference
  │    │    │   ├── Exclude weekends/holidays (optional)
  │    │    │   └── Add to response time array
  │    │    │
  │    │    ├── Calculate average, median, min, max
  │    │    └── Calculate variance
  │    │
  │    ├─── 2b. Count pending responses
  │    │    ├── Identify unanswered messages
  │    │    ├── Identify overdue action items
  │    │    └── Calculate hours since oldest pending
  │    │
  │    ├─── 2c. Analyze patterns
  │    │    ├── Identify preferred contact method
  │    │    │   └── Which channel gets fastest response?
  │    │    │
  │    │    ├── Identify response window
  │    │    │   ├── Morning (8am-12pm)
  │    │    │   ├── Afternoon (12pm-5pm)
  │    │    │   ├── Evening (5pm-9pm)
  │    │    │   └── Weekday vs weekend
  │    │    │
  │    │    └── Calculate trend
  │    │        ├── Compare last 5 responses to overall average
  │    │        └── Set IMPROVING/STABLE/DECLINING
  │    │
  │    ├─── 2d. Calculate score
  │    │    └── Apply scoring algorithm
  │    │
  │    └─── 2e. Classify party
  │         ├── Set classification (EXCELLENT → UNRESPONSIVE)
  │         └── Set risk level
  │
  ├─── 3. Identify problem parties
  │    ├── Filter parties with score < 50
  │    ├── Filter parties with pending > 48 hours
  │    └── Sort by impact on timeline
  │
  ├─── 4. Generate recommendations
  │    │
  │    ├── FOR EACH problem party:
  │    │   ├── Suggest contact method
  │    │   ├── Suggest optimal contact time
  │    │   ├── Suggest escalation path
  │    │   └── Draft follow-up message
  │    │
  │    └── Prioritize by urgency
  │
  ├─── 5. Store analysis
  │    └── UPDATE parties SET responsiveness_score, last_analysis
  │
  └─── 6. Return result
```

## Output

```typescript
{
  success: true,
  actionTaken: "Analyzed party responsiveness for 123 Main St",
  result: {
    deal: {
      id: "uuid",
      address: "123 Main St, Miami FL 33101"
    },
    overallDealHealth: "FAIR",
    problemParties: 1,
    parties: [
      {
        partyId: "uuid-1",
        name: "John Smith",
        role: "buyer",
        responsivenessScore: 85,
        classification: "GOOD",
        riskLevel: "LOW",
        averageResponseTime: 8.5,
        lastContact: "2026-01-14T15:00:00Z",
        pendingResponses: 0,
        preferredContact: "sms",
        typicalWindow: "weekday mornings",
        trend: "STABLE"
      },
      {
        partyId: "uuid-2",
        name: "Jane Doe",
        role: "seller",
        responsivenessScore: 72,
        classification: "GOOD",
        riskLevel: "LOW",
        averageResponseTime: 14.2,
        lastContact: "2026-01-13T10:00:00Z",
        pendingResponses: 0,
        preferredContact: "email",
        typicalWindow: "weekday afternoons",
        trend: "STABLE"
      },
      {
        partyId: "uuid-3",
        name: "First National Bank",
        role: "lender",
        responsivenessScore: 35,
        classification: "SLOW",
        riskLevel: "HIGH",
        averageResponseTime: 52.3,
        lastContact: "2026-01-11T09:00:00Z",
        pendingResponses: 2,
        oldestPending: "2026-01-11T14:00:00Z",
        hoursSinceOldest: 96,
        preferredContact: "phone",
        typicalWindow: "weekday mornings",
        trend: "DECLINING"
      },
      {
        partyId: "uuid-4",
        name: "ABC Title Company",
        role: "title_company",
        responsivenessScore: 88,
        classification: "GOOD",
        riskLevel: "LOW",
        averageResponseTime: 6.1,
        lastContact: "2026-01-14T11:00:00Z",
        pendingResponses: 0,
        preferredContact: "email",
        typicalWindow: "business hours",
        trend: "IMPROVING"
      }
    ],
    flags: [
      {
        type: "UNRESPONSIVE_PARTY",
        severity: "HIGH",
        party: "First National Bank (Lender)",
        description: "Has not responded to 2 messages in 4 days",
        impact: "May delay financing approval and closing",
        suggestedAction: "Call lender directly at (305) 555-0123"
      }
    ],
    recommendations: [
      {
        party: "First National Bank",
        action: "Call loan officer directly",
        timing: "Today, preferably before 11 AM (their typical response window)",
        method: "Phone",
        script: "Following up on the financing status for 123 Main St. We have two outstanding items..."
      }
    ],
    analyzedAt: "2026-01-15T06:00:00Z"
  }
}
```

## Voice Response

### All Parties Responsive
> "Everyone on 123 Main Street is being responsive.
>
> The buyer, John Smith, averages 8-hour responses. Best to text him in the mornings.
>
> The seller, Jane Doe, averages 14 hours. She prefers email in the afternoons.
>
> Title company is excellent - 6-hour average. The lender is responding in about 18 hours, which is normal for lenders.
>
> No follow-ups needed right now."

### Problem Party Identified
> "We have a responsiveness issue on 123 Main Street.
>
> First National Bank, the lender, has 2 unanswered messages from 4 days ago. Their average response time has climbed to 52 hours, and they're getting worse.
>
> This is high risk because we're 30 days from the financing contingency deadline.
>
> I recommend calling them directly this morning - they tend to be most responsive before 11 AM.
>
> Everyone else is doing fine - buyer and seller are both responding within a day, and title company is excellent.
>
> Want me to remind you to call the lender at 9 AM?"

### Multiple Problem Parties
> "Red flag on 123 Main Street. Two parties are being slow.
>
> The lender hasn't responded in 4 days. The appraiser hasn't responded in 3 days.
>
> Combined, these two could derail your timeline. The appraisal needs to be ordered for financing to clear.
>
> Priority one: Call the lender about the appraisal order.
> Priority two: Follow up with the appraiser on scheduling.
>
> The buyer and seller are both responsive. No issues there.
>
> Should I draft follow-up emails for both?"

## Pattern Insights

### Preferred Contact Method Detection

```typescript
function detectPreferredContactMethod(communications: Communication[]): ContactMethod {
  const responseTimeByChannel: Record<string, number[]> = {
    email: [],
    sms: [],
    phone: []
  };

  for (const comm of communications) {
    if (comm.response) {
      const responseTime = hoursBetween(comm.sentAt, comm.response.receivedAt);
      responseTimeByChannel[comm.channel].push(responseTime);
    }
  }

  // Find channel with fastest average response
  let bestChannel = 'unknown';
  let bestAverage = Infinity;

  for (const [channel, times] of Object.entries(responseTimeByChannel)) {
    if (times.length >= 2) { // Need at least 2 data points
      const avg = times.reduce((a, b) => a + b, 0) / times.length;
      if (avg < bestAverage) {
        bestAverage = avg;
        bestChannel = channel;
      }
    }
  }

  return bestChannel;
}
```

### Response Window Detection

```typescript
function detectResponseWindow(communications: Communication[]): string {
  const responseTimes: Date[] = communications
    .filter(c => c.response)
    .map(c => new Date(c.response.receivedAt));

  const hourCounts = new Array(24).fill(0);
  const dayCounts = { weekday: 0, weekend: 0 };

  for (const time of responseTimes) {
    hourCounts[time.getHours()]++;
    const day = time.getDay();
    if (day === 0 || day === 6) dayCounts.weekend++;
    else dayCounts.weekday++;
  }

  // Find peak hour range
  let peakStart = 0;
  let peakSum = 0;
  for (let i = 0; i < 24; i++) {
    const windowSum = hourCounts[i] + hourCounts[(i + 1) % 24] + hourCounts[(i + 2) % 24];
    if (windowSum > peakSum) {
      peakSum = windowSum;
      peakStart = i;
    }
  }

  const timeOfDay =
    peakStart < 12 ? 'mornings' :
    peakStart < 17 ? 'afternoons' : 'evenings';

  const dayType = dayCounts.weekday >= dayCounts.weekend ? 'weekday' : 'weekend';

  return `${dayType} ${timeOfDay}`;
}
```

## Integration Points

### Invokes
- `send-email` - For follow-up drafting
- `send-sms` - For follow-up drafting

### Invoked By
- `deal-risk-assessment` - Party score component
- `daily-planning` - Who to follow up with
- `proactive-alerts` - Unresponsive party alerts

### Database Tables
- `parties` - Party records and contact info
- `communications` - Message history
- `party_responsiveness` - Cached responsiveness metrics
- `action_items` - Pending party actions

## Error Handling

| Error | Cause | Response |
|-------|-------|----------|
| `NO_COMMUNICATIONS` | No message history | "There's no communication history to analyze for this party yet." |
| `PARTY_NOT_FOUND` | Invalid party ID | "I couldn't find that party. Can you give me their name or role?" |
| `INSUFFICIENT_DATA` | < 2 messages exchanged | "Not enough data for a responsiveness score yet. I'll have better insights after a few more interactions." |

## Quality Checklist

- [x] Tracks response times across all channels
- [x] Accounts for business hours and weekends
- [x] Identifies preferred contact method
- [x] Detects response pattern changes (trend)
- [x] Flags unresponsive parties proactively
- [x] Provides actionable follow-up recommendations
- [x] Suggests optimal contact timing
- [x] Integrates with risk assessment
- [x] Respects different expectations by party role
- [x] Generates follow-up scripts when needed

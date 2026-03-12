# Skill: Timeline Analysis

**Category:** Intelligence
**Priority:** P0
**Approval Required:** No

## Purpose

Analyze whether a real estate transaction is on track to close on the scheduled date. This skill examines the relationship between remaining deadlines, their dependencies, historical completion patterns, and external factors to predict closing probability and identify timeline risks.

## Triggers

### Voice Commands
- "Is [address] on track to close?"
- "Will we close on time for [address]?"
- "What's the timeline status for [deal]?"
- "Are we going to make the closing date?"
- "Timeline check for [address]"
- "How much buffer do we have?"

### Automatic
- Daily scheduled analysis (6:00 AM with risk assessment)
- When closing date is within 30 days
- When any deadline is extended
- When any deadline is missed
- After financing contingency clears or expires

### Programmatic
- `GET /deals/:id/timeline-analysis`
- Weekly summary generation
- Dashboard data

## Timeline Health Model

### Closing Probability Score: 0-100%

```typescript
interface TimelineAnalysis {
  closingProbability: number;      // 0-100% likelihood of on-time close
  riskLevel: 'ON_TRACK' | 'AT_RISK' | 'BEHIND' | 'CRITICAL';
  daysToClosing: number;
  bufferDays: number;              // Days of slack in schedule
  criticalPath: Deadline[];        // Deadlines that can't slip
  blockers: Blocker[];             // Issues that could delay closing
  projectedClosingDate: Date;      // Estimated actual close date
  slippage: number;                // Days projected beyond scheduled
  milestones: MilestoneStatus[];
  recommendations: string[];
}

interface Blocker {
  type: string;
  description: string;
  severity: 'MINOR' | 'MODERATE' | 'MAJOR' | 'BLOCKING';
  estimatedDelay: number;          // Days this could add
  requiredAction: string;
  owner: string;                   // Party responsible
}

interface MilestoneStatus {
  name: string;
  category: string;
  dueDate: Date;
  status: 'COMPLETE' | 'ON_TRACK' | 'AT_RISK' | 'OVERDUE';
  daysUntil: number;
  dependencies: string[];
  isCriticalPath: boolean;
}
```

## Critical Path Analysis

### Default Florida Transaction Critical Path

```
Effective Date
    │
    ├──[3 days]── Escrow Deposit Due
    │                 │
    ├──[15 days]── Inspection Period Ends ─────────────┐
    │                 │                                 │
    │           (repairs/negotiations)                  │
    │                 │                                 │
    ├──[21 days]── Appraisal Complete ──────────────────┤
    │                 │                                 │
    ├──[30 days]── Financing Contingency ───────────────┤
    │                 │                                 │
    │           ┌─────┴─────┐                           │
    │           │           │                           │
    │      [Closing-15]  [Closing-5]                    │
    │      Title Commit   Clear to Close                │
    │           │           │                           │
    │           └─────┬─────┘                           │
    │                 │                                 │
    └──[Closing-3]── Closing Disclosure ────────────────┤
                      │                                 │
                [Closing-1]                             │
                Final Walk-Through                      │
                      │                                 │
                  CLOSING ◄─────────────────────────────┘
```

### Critical Path Calculation

```typescript
function calculateCriticalPath(deal: Deal, deadlines: Deadline[]): CriticalPath {
  // Identify dependencies
  const dependencies = {
    'closing': ['clear_to_close', 'final_walkthrough', 'closing_disclosure'],
    'clear_to_close': ['title_commitment', 'financing_approved', 'appraisal_complete'],
    'title_commitment': ['title_search_ordered'],
    'financing_approved': ['appraisal_complete', 'income_verification'],
    'appraisal_complete': ['appraisal_ordered'],
    // ... more dependencies
  };

  // Calculate float (slack) for each deadline
  const floatByDeadline = {};
  for (const deadline of deadlines) {
    const latestPossible = calculateLatestStart(deadline, dependencies, deal.closingDate);
    const scheduledDate = deadline.dueDate;
    floatByDeadline[deadline.id] = daysBetween(scheduledDate, latestPossible);
  }

  // Critical path = deadlines with zero float
  const criticalPath = deadlines.filter(d => floatByDeadline[d.id] === 0);

  return {
    criticalPath,
    floatByDeadline,
    totalFloat: Math.min(...Object.values(floatByDeadline))
  };
}
```

## Probability Calculation

### Base Probability by Days to Close

| Days to Close | Base Probability | Rationale |
|---------------|-----------------|-----------|
| 60+ days | 95% | Plenty of buffer |
| 45-59 days | 90% | Normal timeline |
| 30-44 days | 85% | Entering critical period |
| 21-29 days | 75% | Limited recovery time |
| 14-20 days | 60% | Tight timeline |
| 7-13 days | 45% | Very tight |
| 1-6 days | 30% | Almost no buffer |

### Adjustment Factors

```typescript
function calculateClosingProbability(
  deal: Deal,
  deadlines: Deadline[],
  parties: Party[],
  history: CommunicationHistory
): number {
  const daysToClose = daysBetween(today, deal.closingDate);
  let probability = getBaseProbability(daysToClose);

  // Positive adjustments
  if (allMilestonesComplete(['escrow', 'inspection', 'appraisal'])) {
    probability += 10; // Major milestones done
  }
  if (financingApproved) {
    probability += 15; // Biggest risk eliminated
  }
  if (titleClear) {
    probability += 5; // Title ready
  }
  if (averagePartyResponseTime < 24) {
    probability += 5; // Responsive parties
  }

  // Negative adjustments
  for (const deadline of deadlines) {
    if (deadline.status === 'overdue') {
      probability -= 15; // Each overdue hurts
    }
    if (deadline.extended) {
      probability -= 5; // Extensions signal risk
    }
  }

  if (financingNotConfirmed && daysToClose < 21) {
    probability -= 25; // Financing risk near close
  }
  if (titleIssuesExist) {
    probability -= 20; // Title problems delay closings
  }
  if (hasUnresponsiveParty) {
    probability -= 10; // Communication problems
  }

  // Historical adjustment
  const agentSuccessRate = getAgentClosingRate(deal.agentId);
  if (agentSuccessRate > 0.95) {
    probability += 5; // Reliable agent
  } else if (agentSuccessRate < 0.85) {
    probability -= 5; // Higher risk agent
  }

  return Math.max(5, Math.min(100, probability));
}
```

## Execution Flow

```
START
  │
  ├─── 1. Load deal and deadline data
  │    ├── Deal details including closing date
  │    ├── All deadlines with statuses
  │    ├── Party information
  │    ├── Document completion status
  │    └── Communication history
  │
  ├─── 2. Calculate days to closing
  │    ├── Business days remaining
  │    ├── Calendar days remaining
  │    └── Identify holidays in window
  │
  ├─── 3. Analyze milestone status
  │    │
  │    ├── FOR EACH deadline/milestone:
  │    │   ├── Check completion status
  │    │   ├── Calculate days until due
  │    │   ├── Assess on-track vs at-risk
  │    │   └── Identify dependencies
  │    │
  │    └── Categorize:
  │        ├── Complete milestones
  │        ├── On-track milestones
  │        ├── At-risk milestones
  │        └── Overdue milestones
  │
  ├─── 4. Calculate critical path
  │    ├── Build dependency graph
  │    ├── Calculate float for each deadline
  │    ├── Identify zero-float deadlines
  │    └── Determine buffer days
  │
  ├─── 5. Identify blockers
  │    │
  │    ├── Check for overdue deadlines
  │    │   └── Estimate delay impact
  │    │
  │    ├── Check financing status
  │    │   └── If not approved & tight timeline = blocker
  │    │
  │    ├── Check title status
  │    │   └── Any issues = potential blocker
  │    │
  │    ├── Check for unresponsive parties
  │    │   └── On critical path = blocker
  │    │
  │    └── Check document gaps
  │        └── Missing critical docs = blocker
  │
  ├─── 6. Calculate closing probability
  │    ├── Get base probability from days to close
  │    ├── Apply positive adjustments
  │    ├── Apply negative adjustments
  │    └── Apply historical adjustment
  │
  ├─── 7. Project actual closing date
  │    │
  │    ├── IF blockers exist:
  │    │   ├── Sum estimated delays
  │    │   └── projectedClose = scheduledClose + delays
  │    │
  │    └── ELSE:
  │        └── projectedClose = scheduledClose
  │
  ├─── 8. Determine risk level
  │    ├── ON_TRACK: probability >= 80%, no blockers
  │    ├── AT_RISK: probability 60-79%, minor blockers
  │    ├── BEHIND: probability 40-59%, moderate blockers
  │    └── CRITICAL: probability < 40%, major blockers
  │
  ├─── 9. Generate recommendations
  │    │
  │    ├── FOR EACH blocker:
  │    │   └── Generate specific remediation action
  │    │
  │    ├── FOR EACH at-risk milestone:
  │    │   └── Generate preventive action
  │    │
  │    └── Prioritize by impact
  │
  ├─── 10. Store analysis
  │     └── INSERT INTO timeline_analyses
  │
  └─── 11. Return result
```

## Output

```typescript
{
  success: true,
  actionTaken: "Completed timeline analysis for 123 Main St",
  result: {
    deal: {
      id: "uuid",
      address: "123 Main St, Miami FL 33101",
      scheduledClosing: "2026-03-12",
      daysToClosing: 56,
      businessDaysToClosing: 40
    },
    closingProbability: 78,
    riskLevel: "AT_RISK",
    bufferDays: 5,
    projectedClosingDate: "2026-03-12",
    slippage: 0,
    criticalPath: [
      {
        name: "Financing Contingency",
        dueDate: "2026-02-14",
        daysUntil: 30,
        status: "ON_TRACK",
        isCriticalPath: true
      },
      {
        name: "Title Commitment",
        dueDate: "2026-02-25",
        daysUntil: 41,
        status: "ON_TRACK",
        isCriticalPath: true
      },
      {
        name: "Clear to Close",
        dueDate: "2026-03-07",
        daysUntil: 51,
        status: "PENDING",
        isCriticalPath: true
      }
    ],
    milestones: [
      {
        name: "Escrow Deposit",
        status: "COMPLETE",
        completedDate: "2026-01-18"
      },
      {
        name: "Inspection Period",
        status: "COMPLETE",
        completedDate: "2026-01-30"
      },
      {
        name: "Appraisal",
        status: "AT_RISK",
        dueDate: "2026-02-05",
        daysUntil: 21,
        note: "Appraisal not yet ordered"
      },
      {
        name: "Financing Approval",
        status: "ON_TRACK",
        dueDate: "2026-02-14",
        daysUntil: 30
      }
    ],
    blockers: [
      {
        type: "APPRAISAL_NOT_ORDERED",
        description: "Appraisal has not been ordered yet",
        severity: "MODERATE",
        estimatedDelay: 5,
        requiredAction: "Order appraisal immediately",
        owner: "First National Bank (Lender)"
      }
    ],
    recommendations: [
      "1. Contact lender to order appraisal today - delay could compress timeline",
      "2. Verify title search has been ordered",
      "3. Schedule tentative walk-through date with buyer"
    ],
    analyzedAt: "2026-01-15T06:00:00Z"
  }
}
```

## Voice Response

### ON_TRACK (80%+ probability)
> "Good news on 123 Main Street. We're on track to close March 12th as scheduled.
>
> We have 56 days to go and 5 days of buffer built in.
>
> Escrow and inspection are complete. Financing is progressing well.
>
> The critical path runs through financing approval on February 14th, then title and clear-to-close.
>
> No blockers identified. I'll keep monitoring."

### AT_RISK (60-79% probability)
> "123 Main Street has a 78% chance of closing on time, but there's one issue to address.
>
> The appraisal hasn't been ordered yet, and we're 21 days from when it's due. That's cutting it close.
>
> The lender needs to order the appraisal today to stay on track. If it slips, we could need an extension.
>
> Everything else looks good - escrow and inspection are done, financing is progressing.
>
> Want me to draft a follow-up to the lender about the appraisal?"

### BEHIND (40-59% probability)
> "I'm concerned about 123 Main Street. Only 52% chance of closing on time.
>
> Two issues are causing problems:
>
> First, the appraisal came in low and we're waiting on a price reduction or second appraisal. This could add 7-10 days.
>
> Second, title found a lien that needs to be cleared. The seller is working on it, but no resolution yet.
>
> At this pace, we're looking at closing around March 20th instead of March 12th.
>
> I recommend preparing an extension request. Would you like me to draft that?"

### CRITICAL (<40% probability)
> "Alert: 123 Main Street is at serious risk of not closing on time.
>
> Current probability is only 35%.
>
> The financing contingency expires tomorrow and we don't have loan approval. The appraisal was rejected. Title has unresolved liens.
>
> Unless something changes today, we need to either extend or this deal may fall through.
>
> I strongly recommend an urgent call with all parties. Should I set that up?"

## Milestone Categories

| Category | Milestones | Typical Day |
|----------|-----------|-------------|
| **Execution** | Contract signed, Escrow deposited | Day 1-3 |
| **Due Diligence** | Inspection complete, Repairs negotiated | Day 15 |
| **Financing** | Appraisal ordered, Appraisal complete, Loan approved | Day 21-30 |
| **Title** | Title search, Title commitment, Title clear | Day 30-45 |
| **Pre-Closing** | Clear to close, Closing disclosure, Final walk-through | Close-5 to Close-1 |
| **Closing** | Funds transferred, Deed recorded | Day of Close |

## Error Handling

| Error | Cause | Response |
|-------|-------|----------|
| `NO_CLOSING_DATE` | Closing date not set | "I need a target closing date to analyze the timeline." |
| `INSUFFICIENT_DEADLINES` | Few deadlines defined | "This deal doesn't have enough milestones tracked for a full analysis." |
| `PAST_CLOSING` | Closing date has passed | "This deal was supposed to close on [date]. Is it still active?" |

## Quality Checklist

- [x] Calculates accurate critical path
- [x] Identifies buffer/float in schedule
- [x] Predicts closing probability based on multiple factors
- [x] Projects actual closing date when delays exist
- [x] Identifies specific blockers with owners
- [x] Provides actionable recommendations
- [x] Handles various deal types (cash, financed, condo)
- [x] Accounts for holidays in timeline
- [x] Integrates with risk assessment
- [x] Voice response matches severity level

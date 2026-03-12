# Skill: Daily Planning

**Category:** Intelligence
**Priority:** P0
**Approval Required:** No

## Purpose

Generate a prioritized daily action plan based on deadlines, risk assessments, party follow-ups, and strategic opportunities. This is Homer's "morning briefing" that tells the agent exactly what needs attention today and in what order.

## Triggers

### Voice Commands
- "What should I focus on today?"
- "Give me my daily plan"
- "What's on my plate today?"
- "Morning briefing"
- "What needs attention today?"
- "Plan my day"
- "What are my priorities?"

### Automatic
- Daily scheduled run at 7:00 AM (agent's timezone)
- On-demand refresh

### Programmatic
- `GET /agents/:id/daily-plan`
- Dashboard "Today" view
- Mobile app morning notification

## Daily Plan Structure

```typescript
interface DailyPlan {
  agentId: string;
  planDate: Date;
  generatedAt: Date;

  // High-level summary
  summary: {
    dealsNeedingAttention: number;
    criticalItems: number;
    totalActionItems: number;
    estimatedTimeMinutes: number;
  };

  // Prioritized sections
  criticalActions: ActionItem[];      // Must do today - deal at risk
  deadlineActions: ActionItem[];      // Deadline-related tasks
  followUpActions: ActionItem[];      // Party follow-ups needed
  proactiveActions: ActionItem[];     // Preventive/strategic
  routineActions: ActionItem[];       // Regular maintenance

  // Deal-by-deal breakdown
  dealBreakdown: DealDayPlan[];

  // Calendar context
  scheduledEvents: CalendarEvent[];
  suggestedTimeBlocks: TimeBlock[];

  // Insights
  topPriority: string;
  watchList: string[];
  goodNews: string[];
}

interface ActionItem {
  id: string;
  priority: 1 | 2 | 3 | 4 | 5;         // 1 = highest
  category: ActionCategory;
  dealId?: string;
  dealAddress?: string;
  title: string;
  description: string;
  reason: string;                       // Why this is important
  estimatedMinutes: number;
  suggestedTime?: string;               // e.g., "First thing" or "2 PM"
  relatedDeadline?: Deadline;
  relatedParty?: Party;
  quickAction?: QuickAction;            // Can Homer do this for you?
  status: 'pending' | 'in_progress' | 'completed' | 'deferred';
}

type ActionCategory =
  | 'deadline_today'
  | 'deadline_tomorrow'
  | 'overdue'
  | 'follow_up'
  | 'document_needed'
  | 'signature_needed'
  | 'communication'
  | 'risk_mitigation'
  | 'closing_prep'
  | 'new_deal_setup';

interface QuickAction {
  available: boolean;
  description: string;
  command: string;                      // Skill to invoke
  params: Record<string, any>;
}
```

## Priority Scoring Algorithm

```typescript
function calculateActionPriority(item: RawActionItem): number {
  let score = 0;

  // Time urgency (0-40 points)
  if (item.dueToday) score += 40;
  else if (item.dueTomorrow) score += 25;
  else if (item.dueThisWeek) score += 15;
  else if (item.overdue) score += 50; // Overdue is highest

  // Deal risk level (0-25 points)
  if (item.dealRiskLevel === 'CRITICAL') score += 25;
  else if (item.dealRiskLevel === 'HIGH') score += 18;
  else if (item.dealRiskLevel === 'MEDIUM') score += 10;
  else score += 3;

  // Deadline category (0-20 points)
  if (item.deadlineCategory === 'closing') score += 20;
  else if (item.deadlineCategory === 'financing') score += 18;
  else if (item.deadlineCategory === 'inspection') score += 16;
  else if (item.deadlineCategory === 'escrow') score += 14;

  // Financial impact (0-10 points)
  if (item.dealValue > 1000000) score += 10;
  else if (item.dealValue > 500000) score += 7;
  else if (item.dealValue > 250000) score += 4;

  // Days to closing (0-5 points)
  if (item.daysToClosing <= 7) score += 5;
  else if (item.daysToClosing <= 14) score += 3;

  return score;
}

function assignPriorityTier(score: number): 1 | 2 | 3 | 4 | 5 {
  if (score >= 70) return 1;  // Critical - must do immediately
  if (score >= 50) return 2;  // High - do first half of day
  if (score >= 30) return 3;  // Medium - do today
  if (score >= 15) return 4;  // Low - do if time permits
  return 5;                    // Optional - defer if needed
}
```

## Execution Flow

```
START
  │
  ├─── 1. Load agent data
  │    ├── All active deals
  │    ├── All deadlines
  │    ├── All parties
  │    ├── Risk assessments
  │    ├── Proactive alerts
  │    ├── Communication history
  │    └── Calendar events (if integrated)
  │
  ├─── 2. Identify critical actions
  │    │
  │    ├── Overdue items
  │    │   └── Each overdue deadline → action item
  │    │
  │    ├── Proactive alerts with severity HIGH/CRITICAL
  │    │   └── Each alert → action item
  │    │
  │    └── Deals with risk score > 70
  │        └── Each → "Review and address risks"
  │
  ├─── 3. Identify deadline-driven actions
  │    │
  │    ├── Deadlines due today
  │    │   └── Each → verification/completion action
  │    │
  │    ├── Deadlines due tomorrow
  │    │   └── Each → preparation action
  │    │
  │    └── Deadlines due in 48 hours (incomplete)
  │        └── Each → warning action
  │
  ├─── 4. Identify follow-up actions
  │    │
  │    ├── Parties not responded in 48+ hours
  │    │   └── Each → follow-up action
  │    │
  │    ├── Pending signatures > 24 hours
  │    │   └── Each → reminder action
  │    │
  │    └── Communication gaps > 5 days
  │        └── Each → outreach action
  │
  ├─── 5. Identify proactive actions
  │    │
  │    ├── Medium risk deals (preemptive)
  │    │   └── Pattern-matched preventive actions
  │    │
  │    ├── Closing in 14 days (prep tasks)
  │    │   └── Pre-closing checklist items
  │    │
  │    └── New deals needing setup
  │        └── Initial configuration tasks
  │
  ├─── 6. Identify routine actions
  │    ├── Weekly status updates due
  │    ├── Document expiration checks
  │    └── Contact info verification
  │
  ├─── 7. Score and prioritize all actions
  │    │
  │    ├── FOR EACH action:
  │    │   ├── Calculate priority score
  │    │   ├── Assign priority tier (1-5)
  │    │   └── Estimate time needed
  │    │
  │    └── Sort by priority score descending
  │
  ├─── 8. Group by category
  │    ├── Critical (Priority 1)
  │    ├── Deadline-driven (Priority 2)
  │    ├── Follow-ups (Priority 3)
  │    ├── Proactive (Priority 4)
  │    └── Routine (Priority 5)
  │
  ├─── 9. Generate deal breakdown
  │    │
  │    ├── FOR EACH deal with actions:
  │    │   ├── List actions for that deal
  │    │   ├── Current status summary
  │    │   └── Risk level
  │    │
  │    └── Sort by urgency
  │
  ├─── 10. Generate time blocks (optional)
  │     ├── Map actions to available time
  │     └── Suggest schedule
  │
  ├─── 11. Generate insights
  │     ├── Identify top priority
  │     ├── Identify watch list items
  │     └── Identify good news
  │
  ├─── 12. Store plan
  │     └── INSERT INTO daily_plans
  │
  └─── 13. Return result
```

## Output

```typescript
{
  success: true,
  actionTaken: "Generated daily plan for January 15, 2026",
  result: {
    planDate: "2026-01-15",
    generatedAt: "2026-01-15T07:00:00Z",

    summary: {
      dealsNeedingAttention: 3,
      criticalItems: 1,
      totalActionItems: 8,
      estimatedTimeMinutes: 95
    },

    topPriority: "123 Main St - Financing contingency expires tomorrow, lender hasn't confirmed approval",

    criticalActions: [
      {
        id: "action-1",
        priority: 1,
        category: "risk_mitigation",
        dealId: "deal-123",
        dealAddress: "123 Main St, Miami",
        title: "Confirm financing approval with lender",
        description: "Financing contingency expires tomorrow. Must confirm loan approval status today.",
        reason: "75% probability of needing extension if not resolved",
        estimatedMinutes: 15,
        suggestedTime: "First thing - 8:00 AM",
        quickAction: {
          available: true,
          description: "I can draft a follow-up email to the lender",
          command: "send-email",
          params: { dealId: "deal-123", partyRole: "lender", emailType: "status_request" }
        }
      }
    ],

    deadlineActions: [
      {
        id: "action-2",
        priority: 2,
        category: "deadline_today",
        dealId: "deal-456",
        dealAddress: "456 Oak Lane, Coral Gables",
        title: "Verify inspection period resolution",
        description: "Inspection period ends today at 5 PM. Confirm buyer's decision.",
        reason: "After 5 PM, buyer accepts property as-is",
        estimatedMinutes: 10,
        suggestedTime: "Morning",
        relatedDeadline: {
          name: "Inspection Period Ends",
          dueDate: "2026-01-15",
          dueTime: "17:00"
        }
      },
      {
        id: "action-3",
        priority: 2,
        category: "deadline_tomorrow",
        dealId: "deal-789",
        dealAddress: "789 Palm Ave, Miami Beach",
        title: "Prepare escrow deposit verification",
        description: "Escrow deposit due tomorrow. Confirm with title company receipt is ready.",
        reason: "Deposit deadline is contract-critical",
        estimatedMinutes: 10,
        suggestedTime: "Morning"
      }
    ],

    followUpActions: [
      {
        id: "action-4",
        priority: 3,
        category: "follow_up",
        dealId: "deal-456",
        dealAddress: "456 Oak Lane, Coral Gables",
        title: "Follow up with buyer's agent",
        description: "Buyer's agent hasn't responded to repair request in 3 days.",
        reason: "Need response to keep deal moving",
        estimatedMinutes: 10,
        relatedParty: {
          name: "Bob Agent",
          role: "buyers_agent",
          lastContact: "2026-01-12"
        },
        quickAction: {
          available: true,
          description: "I can send a follow-up email or text",
          command: "send-sms",
          params: { dealId: "deal-456", partyRole: "buyers_agent" }
        }
      },
      {
        id: "action-5",
        priority: 3,
        category: "communication",
        dealId: "deal-789",
        dealAddress: "789 Palm Ave, Miami Beach",
        title: "Send weekly status update to seller",
        description: "Last contact with seller was 6 days ago. Send status update.",
        reason: "Maintain seller engagement and confidence",
        estimatedMinutes: 15,
        quickAction: {
          available: true,
          description: "I can draft and send a status update email",
          command: "send-email",
          params: { dealId: "deal-789", partyRole: "seller", emailType: "status_update" }
        }
      }
    ],

    proactiveActions: [
      {
        id: "action-6",
        priority: 4,
        category: "closing_prep",
        dealId: "deal-101",
        dealAddress: "101 Sunset Dr, Key Biscayne",
        title: "Schedule final walk-through",
        description: "Closing in 12 days. Good time to schedule walk-through with buyer.",
        reason: "Proactive scheduling prevents last-minute conflicts",
        estimatedMinutes: 10
      }
    ],

    routineActions: [
      {
        id: "action-7",
        priority: 5,
        category: "document_needed",
        dealId: "deal-456",
        dealAddress: "456 Oak Lane, Coral Gables",
        title: "Request updated HOA estoppel letter",
        description: "Current estoppel expires in 10 days. Request updated version.",
        reason: "Avoid document expiration before closing",
        estimatedMinutes: 5
      }
    ],

    dealBreakdown: [
      {
        dealId: "deal-123",
        address: "123 Main St, Miami",
        riskLevel: "HIGH",
        daysToClose: 56,
        actionCount: 1,
        status: "Financing at risk - needs immediate attention",
        actions: ["Confirm financing approval with lender"]
      },
      {
        dealId: "deal-456",
        address: "456 Oak Lane, Coral Gables",
        riskLevel: "MEDIUM",
        daysToClose: 35,
        actionCount: 3,
        status: "Inspection deadline today",
        actions: [
          "Verify inspection period resolution",
          "Follow up with buyer's agent",
          "Request updated HOA estoppel letter"
        ]
      },
      {
        dealId: "deal-789",
        address: "789 Palm Ave, Miami Beach",
        riskLevel: "LOW",
        daysToClose: 28,
        actionCount: 2,
        status: "On track, routine items",
        actions: [
          "Prepare escrow deposit verification",
          "Send weekly status update to seller"
        ]
      },
      {
        dealId: "deal-101",
        address: "101 Sunset Dr, Key Biscayne",
        riskLevel: "LOW",
        daysToClose: 12,
        actionCount: 1,
        status: "Closing soon, final prep",
        actions: ["Schedule final walk-through"]
      }
    ],

    watchList: [
      "123 Main St - Financing contingency expires tomorrow",
      "456 Oak Lane - Inspection period ends today at 5 PM"
    ],

    goodNews: [
      "789 Palm Ave - Appraisal came in at contract price",
      "101 Sunset Dr - Clear to close received yesterday"
    ],

    suggestedTimeBlocks: [
      { time: "8:00 AM", action: "Call lender for 123 Main St", duration: 15 },
      { time: "8:30 AM", action: "Verify inspection for 456 Oak Lane", duration: 10 },
      { time: "9:00 AM", action: "Follow-up calls and emails", duration: 35 },
      { time: "10:00 AM", action: "Proactive tasks", duration: 20 },
      { time: "2:00 PM", action: "Final check on today's deadlines", duration: 15 }
    ]
  }
}
```

## Voice Response

### Morning Briefing
> "Good morning! Here's your plan for today.
>
> You have 8 action items across 4 deals. Estimated time: about an hour and a half.
>
> **Top priority:** 123 Main Street. The financing contingency expires tomorrow and the lender hasn't confirmed approval. I'd call them first thing this morning.
>
> **Also critical today:** 456 Oak Lane's inspection period ends at 5 PM. Make sure the buyer has made their decision.
>
> **Good news:** The appraisal came in at contract price for 789 Palm Ave, and 101 Sunset Drive got clear-to-close yesterday.
>
> **Watch list:** Those two critical items I mentioned.
>
> Would you like me to go through each deal, or should I draft that follow-up to the lender?"

### Quick Summary
> "Quick recap: 8 items today, 1 critical.
>
> Most important: Call the lender on 123 Main Street before anything else.
>
> Inspection deadline at 5 PM on 456 Oak Lane.
>
> Everything else is routine. Should take about 90 minutes total."

### Deal-Specific Request
> "For 456 Oak Lane specifically:
>
> The inspection period ends today at 5 PM. You need to confirm the buyer's decision.
>
> Also, the buyer's agent hasn't responded to the repair request in 3 days. Worth a follow-up.
>
> And one minor thing: the HOA estoppel letter expires in 10 days. You should request an updated one.
>
> Three items total for that deal. Want me to handle any of them?"

## Quick Actions

Homer can execute these automatically if the agent approves:

| Action | Skill Invoked | Approval |
|--------|--------------|----------|
| Draft follow-up email | `send-email` | Quick confirm |
| Send reminder text | `send-sms` | Quick confirm |
| Generate status update | `send-email` with `status_update` | Quick confirm |
| Schedule deadline reminder | Internal scheduling | Auto |
| Log action as complete | Internal logging | Auto |

## Error Handling

| Error | Cause | Response |
|-------|-------|----------|
| `NO_ACTIVE_DEALS` | Agent has no active deals | "You don't have any active deals right now. Enjoy the quiet!" |
| `CALENDAR_UNAVAILABLE` | Can't access calendar | Generate plan without time blocks |
| `DATA_STALE` | Risk assessments outdated | Regenerate fresh data first |

## Quality Checklist

- [x] Prioritizes correctly based on urgency and impact
- [x] Groups actions logically by category
- [x] Provides deal-by-deal breakdown
- [x] Estimates time for each action
- [x] Suggests optimal scheduling
- [x] Highlights critical items clearly
- [x] Includes good news to start positive
- [x] Offers quick actions Homer can handle
- [x] Voice response is conversational and clear
- [x] Updates status as agent completes items

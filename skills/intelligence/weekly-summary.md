# Skill: Weekly Summary

**Category:** Intelligence
**Priority:** P1
**Approval Required:** No

## Purpose

Generate a comprehensive weekly status report summarizing deal progress, completed milestones, upcoming priorities, risk trends, and performance metrics. This gives agents a high-level view of their portfolio and helps them communicate status to clients and team members.

## Triggers

### Voice Commands
- "Give me my weekly summary"
- "Weekly report"
- "How did this week go?"
- "What happened this week?"
- "Summarize my week"
- "Week in review"

### Automatic
- Friday at 4:00 PM (weekly wrap-up)
- Monday at 7:00 AM (week ahead preview)
- On-demand generation

### Programmatic
- `GET /agents/:id/weekly-summary`
- `GET /agents/:id/weekly-summary?week=2026-W03`
- Dashboard "Week" view
- Email newsletter generation

## Weekly Summary Structure

```typescript
interface WeeklySummary {
  agentId: string;
  weekNumber: string;                  // e.g., "2026-W03"
  weekStart: Date;
  weekEnd: Date;
  generatedAt: Date;

  // Executive Summary
  headline: string;                    // One-line summary
  weekRating: 'EXCELLENT' | 'GOOD' | 'FAIR' | 'CHALLENGING';

  // Deal Portfolio
  portfolioSnapshot: {
    activeDeals: number;
    newDeals: number;
    closedDeals: number;
    cancelledDeals: number;
    totalValue: number;
    averageRiskScore: number;
    riskTrend: 'IMPROVING' | 'STABLE' | 'DECLINING';
  };

  // Accomplishments
  weekAccomplishments: Accomplishment[];

  // Concerns
  weekConcerns: Concern[];

  // Deal Details
  dealStatuses: DealWeekStatus[];

  // Upcoming Week
  nextWeekPriorities: Priority[];
  upcomingDeadlines: Deadline[];
  upcomingClosings: Deal[];

  // Metrics
  weeklyMetrics: {
    communicationsSent: number;
    communicationsReceived: number;
    averageResponseTime: number;
    deadlinesMet: number;
    deadlinesMissed: number;
    extensionsRequested: number;
    documentsProcessed: number;
  };

  // Trends
  trends: {
    riskScoreHistory: { date: Date; average: number }[];
    dealCountHistory: { date: Date; count: number }[];
    responseTimeHistory: { date: Date; hours: number }[];
  };

  // Recommendations
  focusAreas: string[];
  improvements: string[];
}

interface Accomplishment {
  type: string;
  description: string;
  dealId?: string;
  dealAddress?: string;
  impact: string;
}

interface Concern {
  type: string;
  severity: 'LOW' | 'MEDIUM' | 'HIGH';
  description: string;
  dealId?: string;
  dealAddress?: string;
  recommendation: string;
}

interface DealWeekStatus {
  dealId: string;
  address: string;
  status: string;
  riskLevel: RiskLevel;
  riskChange: number;                  // Delta from last week
  weekHighlights: string[];
  weekIssues: string[];
  nextWeekFocus: string;
  daysToClose: number;
  progressPercent: number;
}
```

## Week Rating Algorithm

```typescript
function calculateWeekRating(weekData: WeekData): WeekRating {
  let score = 100;

  // Negative factors
  if (weekData.cancelledDeals > 0) score -= 20 * weekData.cancelledDeals;
  if (weekData.deadlinesMissed > 0) score -= 15 * weekData.deadlinesMissed;
  if (weekData.riskTrend === 'DECLINING') score -= 15;
  if (weekData.averageRiskScore > 50) score -= 10;
  if (weekData.extensionsRequested > 2) score -= 10;

  // Positive factors
  if (weekData.closedDeals > 0) score += 15 * weekData.closedDeals;
  if (weekData.newDeals > 0) score += 10 * weekData.newDeals;
  if (weekData.riskTrend === 'IMPROVING') score += 10;
  if (weekData.deadlinesMet >= 5) score += 10;
  if (weekData.averageResponseTime < 12) score += 5;

  // Cap and classify
  score = Math.max(0, Math.min(100, score));

  if (score >= 85) return 'EXCELLENT';
  if (score >= 70) return 'GOOD';
  if (score >= 50) return 'FAIR';
  return 'CHALLENGING';
}

function generateHeadline(weekData: WeekData, rating: WeekRating): string {
  if (weekData.closedDeals > 0 && rating === 'EXCELLENT') {
    return `Great week! ${weekData.closedDeals} deal${weekData.closedDeals > 1 ? 's' : ''} closed.`;
  }
  if (weekData.cancelledDeals > 0) {
    return `Challenging week. ${weekData.cancelledDeals} deal fell through, but ${weekData.activeDeals} still on track.`;
  }
  if (weekData.newDeals > 0) {
    return `${weekData.newDeals} new deal${weekData.newDeals > 1 ? 's' : ''} added. ${weekData.activeDeals} active.`;
  }
  if (rating === 'EXCELLENT') {
    return `Strong week. All deals progressing well.`;
  }
  if (rating === 'GOOD') {
    return `Solid week. ${weekData.deadlinesMet} deadlines met, portfolio stable.`;
  }
  return `Active week. ${weekData.activeDeals} deals in motion.`;
}
```

## Execution Flow

```
START
  │
  ├─── 1. Determine week boundaries
  │    ├── Calculate week start (Monday)
  │    ├── Calculate week end (Sunday)
  │    └── Handle current week vs past week
  │
  ├─── 2. Load week data
  │    ├── All deals active during week
  │    ├── Deals closed during week
  │    ├── Deals cancelled during week
  │    ├── New deals created during week
  │    ├── All deadlines during week
  │    ├── All communications during week
  │    ├── Risk assessments from week
  │    └── Action logs from week
  │
  ├─── 3. Calculate portfolio snapshot
  │    ├── Count deals by status
  │    ├── Sum total deal value
  │    ├── Calculate average risk score
  │    └── Compare to last week for trend
  │
  ├─── 4. Generate accomplishments
  │    │
  │    ├── Check for closings
  │    │   └── Each closing → accomplishment
  │    │
  │    ├── Check for key milestones met
  │    │   ├── Financing approved
  │    │   ├── Inspection cleared
  │    │   ├── Title cleared
  │    │   └── Each → accomplishment
  │    │
  │    ├── Check for risk improvements
  │    │   └── Deals that moved from HIGH to MEDIUM/LOW
  │    │
  │    └── Check for new business
  │        └── New deals signed
  │
  ├─── 5. Generate concerns
  │    │
  │    ├── Check for cancelled deals
  │    │   └── Each → concern with analysis
  │    │
  │    ├── Check for missed deadlines
  │    │   └── Each → concern
  │    │
  │    ├── Check for risk increases
  │    │   └── Deals that got worse
  │    │
  │    └── Check for chronic issues
  │        └── Unresponsive parties, delayed financing
  │
  ├─── 6. Generate deal statuses
  │    │
  │    ├── FOR EACH active deal:
  │    │   ├── Calculate week's progress
  │    │   ├── List highlights (milestones met)
  │    │   ├── List issues (problems encountered)
  │    │   ├── Compare risk to last week
  │    │   └── Determine next week focus
  │    │
  │    └── Sort by urgency
  │
  ├─── 7. Identify next week priorities
  │    ├── Deals closing next week
  │    ├── Critical deadlines next week
  │    ├── Deals at high risk
  │    └── Required follow-ups
  │
  ├─── 8. Calculate weekly metrics
  │    ├── Communication stats
  │    ├── Response time average
  │    ├── Deadline performance
  │    └── Document activity
  │
  ├─── 9. Generate trends
  │    ├── Risk score over time
  │    ├── Deal count over time
  │    └── Response time over time
  │
  ├─── 10. Generate recommendations
  │     ├── Identify focus areas
  │     └── Suggest improvements
  │
  ├─── 11. Calculate week rating
  │     ├── Apply scoring algorithm
  │     └── Generate headline
  │
  ├─── 12. Store summary
  │     └── INSERT INTO weekly_summaries
  │
  └─── 13. Return result
```

## Output

```typescript
{
  success: true,
  actionTaken: "Generated weekly summary for Week 3, 2026",
  result: {
    weekNumber: "2026-W03",
    weekStart: "2026-01-13",
    weekEnd: "2026-01-19",
    generatedAt: "2026-01-17T16:00:00Z",

    headline: "Great week! 1 deal closed, 2 new deals signed.",
    weekRating: "EXCELLENT",

    portfolioSnapshot: {
      activeDeals: 5,
      newDeals: 2,
      closedDeals: 1,
      cancelledDeals: 0,
      totalValue: 2850000,
      averageRiskScore: 32,
      riskTrend: "IMPROVING"
    },

    weekAccomplishments: [
      {
        type: "CLOSING",
        description: "101 Sunset Dr closed successfully",
        dealId: "deal-101",
        dealAddress: "101 Sunset Dr, Key Biscayne",
        impact: "$650,000 sale completed, commission earned"
      },
      {
        type: "NEW_DEAL",
        description: "Signed contract for 222 Maple St",
        dealId: "deal-222",
        dealAddress: "222 Maple St, Coconut Grove",
        impact: "$420,000 added to pipeline"
      },
      {
        type: "NEW_DEAL",
        description: "Signed contract for 333 Birch Ave",
        dealId: "deal-333",
        dealAddress: "333 Birch Ave, Brickell",
        impact: "$580,000 added to pipeline"
      },
      {
        type: "MILESTONE",
        description: "Financing approved for 123 Main St",
        dealId: "deal-123",
        dealAddress: "123 Main St, Miami",
        impact: "Major risk eliminated, closing on track"
      },
      {
        type: "RISK_IMPROVEMENT",
        description: "456 Oak Lane moved from HIGH to MEDIUM risk",
        dealId: "deal-456",
        dealAddress: "456 Oak Lane, Coral Gables",
        impact: "Inspection issues resolved"
      }
    ],

    weekConcerns: [
      {
        type: "SLOW_PROGRESS",
        severity: "MEDIUM",
        description: "789 Palm Ave title search taking longer than expected",
        dealId: "deal-789",
        dealAddress: "789 Palm Ave, Miami Beach",
        recommendation: "Follow up with title company, may need escalation"
      }
    ],

    dealStatuses: [
      {
        dealId: "deal-123",
        address: "123 Main St, Miami",
        status: "Active - Post Financing",
        riskLevel: "LOW",
        riskChange: -25,
        weekHighlights: ["Financing approved", "Appraisal came in at value"],
        weekIssues: [],
        nextWeekFocus: "Title clearance and closing prep",
        daysToClose: 54,
        progressPercent: 65
      },
      {
        dealId: "deal-456",
        address: "456 Oak Lane, Coral Gables",
        status: "Active - Post Inspection",
        riskLevel: "MEDIUM",
        riskChange: -15,
        weekHighlights: ["Inspection repairs agreed", "Buyer committed to proceed"],
        weekIssues: ["Buyer's agent slow to respond"],
        nextWeekFocus: "Financing approval confirmation",
        daysToClose: 33,
        progressPercent: 45
      },
      {
        dealId: "deal-789",
        address: "789 Palm Ave, Miami Beach",
        status: "Active - Title Review",
        riskLevel: "LOW",
        riskChange: 5,
        weekHighlights: ["Escrow deposited", "Inspection completed"],
        weekIssues: ["Title search delayed - HOA complications"],
        nextWeekFocus: "Resolve title issues",
        daysToClose: 26,
        progressPercent: 50
      },
      {
        dealId: "deal-222",
        address: "222 Maple St, Coconut Grove",
        status: "New - Initial Setup",
        riskLevel: "LOW",
        riskChange: 0,
        weekHighlights: ["Contract executed", "Escrow deadline set"],
        weekIssues: [],
        nextWeekFocus: "Escrow deposit, inspection scheduling",
        daysToClose: 58,
        progressPercent: 10
      },
      {
        dealId: "deal-333",
        address: "333 Birch Ave, Brickell",
        status: "New - Initial Setup",
        riskLevel: "LOW",
        riskChange: 0,
        weekHighlights: ["Contract executed"],
        weekIssues: [],
        nextWeekFocus: "Escrow deposit, lender selection",
        daysToClose: 52,
        progressPercent: 5
      }
    ],

    nextWeekPriorities: [
      {
        priority: 1,
        dealAddress: "123 Main St",
        focus: "Schedule final walk-through and closing",
        deadline: null
      },
      {
        priority: 2,
        dealAddress: "456 Oak Lane",
        focus: "Confirm financing approval by Wednesday",
        deadline: "2026-01-22"
      },
      {
        priority: 3,
        dealAddress: "789 Palm Ave",
        focus: "Resolve title issues with HOA",
        deadline: null
      },
      {
        priority: 4,
        dealAddress: "222 Maple St",
        focus: "Escrow deposit and inspection scheduling",
        deadline: "2026-01-21"
      },
      {
        priority: 5,
        dealAddress: "333 Birch Ave",
        focus: "Escrow deposit and lender selection",
        deadline: "2026-01-23"
      }
    ],

    upcomingDeadlines: [
      { date: "2026-01-21", deal: "222 Maple St", deadline: "Escrow Deposit Due" },
      { date: "2026-01-22", deal: "456 Oak Lane", deadline: "Financing Contingency" },
      { date: "2026-01-23", deal: "333 Birch Ave", deadline: "Escrow Deposit Due" }
    ],

    upcomingClosings: [
      { date: "2026-03-12", deal: "123 Main St", daysAway: 54 },
      { date: "2026-02-21", deal: "456 Oak Lane", daysAway: 33 }
    ],

    weeklyMetrics: {
      communicationsSent: 28,
      communicationsReceived: 34,
      averageResponseTime: 8.5,
      deadlinesMet: 4,
      deadlinesMissed: 0,
      extensionsRequested: 0,
      documentsProcessed: 12
    },

    trends: {
      riskScoreHistory: [
        { date: "2026-01-03", average: 42 },
        { date: "2026-01-10", average: 38 },
        { date: "2026-01-17", average: 32 }
      ],
      dealCountHistory: [
        { date: "2026-01-03", count: 4 },
        { date: "2026-01-10", count: 4 },
        { date: "2026-01-17", count: 5 }
      ],
      responseTimeHistory: [
        { date: "2026-01-03", hours: 10.2 },
        { date: "2026-01-10", hours: 9.1 },
        { date: "2026-01-17", hours: 8.5 }
      ]
    },

    focusAreas: [
      "Title resolution for 789 Palm Ave - potential to delay if not addressed",
      "Two new deals need escrow deposits next week - stay on top of buyers"
    ],

    improvements: [
      "Response time improved from 10.2 to 8.5 hours this month - nice work!",
      "Zero missed deadlines for 3 weeks straight"
    ]
  }
}
```

## Voice Response

### Friday Wrap-Up
> "Here's your week in review:
>
> **Great week!** You closed 101 Sunset Drive for $650,000, and signed two new deals totaling a million dollars.
>
> **Portfolio status:** 5 active deals worth $2.85 million. Average risk score dropped to 32 - your portfolio is getting healthier.
>
> **Highlights:**
> - Financing approved for 123 Main Street - that was the big one
> - 456 Oak Lane moved from high to medium risk after resolving inspection issues
>
> **One watch item:** The title search for 789 Palm Ave is taking longer than expected. You might want to follow up with the title company.
>
> **Next week's priorities:**
> 1. Schedule final walk-through for 123 Main Street
> 2. Confirm financing by Wednesday for 456 Oak Lane
> 3. Two escrow deposits due - Monday and Thursday
>
> Overall rating: Excellent week. Keep it up!
>
> Would you like me to email this summary to anyone?"

### Monday Preview
> "Good morning! Here's your week ahead:
>
> You have 5 active deals worth $2.85 million.
>
> **Key deadlines this week:**
> - Tuesday: Escrow deposit due for 222 Maple Street
> - Wednesday: Financing contingency for 456 Oak Lane
> - Thursday: Escrow deposit due for 333 Birch Avenue
>
> **Priority deals:**
> 123 Main Street is your closest to closing - 54 days out. Schedule the walk-through this week.
>
> 456 Oak Lane has a financing deadline Wednesday - make sure the lender is on track.
>
> **Carried over:** 789 Palm Ave's title search needs follow-up.
>
> Your two new deals need escrow deposits this week. Stay on top of the buyers.
>
> Want me to set reminders for these deadlines?"

### Quick Status Check
> "Quick update: 5 active deals, 1 closing soon.
>
> Last week was excellent - 1 closed, 2 new, zero problems.
>
> This week: 3 deadlines, nothing critical. Focus on 456 Oak Lane's financing by Wednesday.
>
> Anything specific you want to know?"

## Email/PDF Report Format

```markdown
# Weekly Transaction Summary
**Week of January 13-19, 2026**
**Agent: [Name]**

---

## Executive Summary

**Rating: EXCELLENT**

Great week! 1 deal closed, 2 new deals signed.

| Metric | This Week | Last Week | Change |
|--------|-----------|-----------|--------|
| Active Deals | 5 | 4 | +1 |
| Total Pipeline Value | $2,850,000 | $2,650,000 | +$200,000 |
| Avg Risk Score | 32 | 38 | -6 ✓ |
| Deadlines Met | 4/4 | 3/3 | 100% |

---

## Week Accomplishments

✓ **Closed:** 101 Sunset Dr ($650,000)
✓ **New Contract:** 222 Maple St ($420,000)
✓ **New Contract:** 333 Birch Ave ($580,000)
✓ **Financing Approved:** 123 Main St
✓ **Risk Reduced:** 456 Oak Lane (HIGH → MEDIUM)

---

## Concerns

⚠️ **789 Palm Ave:** Title search delayed due to HOA complications
   - Recommendation: Follow up with title company

---

## Deal-by-Deal Status

### 123 Main St, Miami
- **Status:** Post Financing | **Risk:** LOW | **Closing:** Mar 12 (54 days)
- **Progress:** ████████░░ 65%
- **This Week:** Financing approved, appraisal at value
- **Next Week:** Title clearance, closing prep

[Additional deals...]

---

## Next Week Priorities

1. **123 Main St** - Schedule walk-through
2. **456 Oak Lane** - Financing approval by Wed
3. **789 Palm Ave** - Resolve title issues
4. **222 Maple St** - Escrow deposit (Tue)
5. **333 Birch Ave** - Escrow deposit (Thu)

---

*Generated by Homer Pro | [Date]*
```

## Error Handling

| Error | Cause | Response |
|-------|-------|----------|
| `NO_WEEK_DATA` | No activity in requested week | "There wasn't much activity that week. No report to generate." |
| `FUTURE_WEEK` | Requested future week | "I can't summarize a week that hasn't happened yet!" |
| `NO_DEALS` | Agent has no deals | "You don't have any deals to summarize. Let's get some contracts signed!" |

## Quality Checklist

- [x] Comprehensive portfolio snapshot
- [x] Clear accomplishments and concerns
- [x] Deal-by-deal breakdown with trends
- [x] Next week priorities identified
- [x] Metrics tracked over time
- [x] Visual trend data for dashboards
- [x] Email/PDF export capability
- [x] Voice summary conversational
- [x] Compares to previous weeks
- [x] Actionable recommendations included

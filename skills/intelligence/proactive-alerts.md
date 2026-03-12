# Skill: Proactive Alerts

**Category:** Intelligence
**Priority:** P0
**Approval Required:** No

## Purpose

Generate alerts BEFORE problems occur by analyzing deal state, patterns, and predictive signals. Unlike reactive deadline alerts, proactive alerts anticipate issues 3-7 days ahead based on risk indicators, historical patterns, and current trajectory.

## Triggers

### Automatic (Primary)
- Morning intelligence run (6:00 AM daily)
- Risk score threshold exceeded
- Pattern match detected
- Timeline deviation detected
- Party responsiveness drop
- Communication gap threshold reached

### Programmatic
- `POST /alerts/generate`
- Risk assessment trigger
- Timeline analysis trigger

## Alert Categories

### 1. Predictive Alerts (Pattern-Based)

```typescript
interface PredictiveAlert {
  type: 'PREDICTIVE';
  alertId: string;
  dealId: string;
  category: PredictiveCategory;
  confidence: number;           // 0-100% confidence in prediction
  severity: AlertSeverity;
  title: string;
  description: string;
  evidence: Evidence[];
  predictedOutcome: string;
  timeToImpact: number;         // Days until predicted issue
  preventiveActions: Action[];
  createdAt: Date;
  expiresAt: Date;
  status: 'active' | 'dismissed' | 'resolved' | 'expired';
}

type PredictiveCategory =
  | 'FINANCING_AT_RISK'
  | 'CLOSING_DELAY_LIKELY'
  | 'PARTY_DISENGAGEMENT'
  | 'INSPECTION_CONCERN'
  | 'TITLE_ISSUE_PROBABLE'
  | 'APPRAISAL_GAP_RISK'
  | 'DEAL_FATIGUE';
```

### 2. Trend Alerts (Trajectory-Based)

```typescript
interface TrendAlert {
  type: 'TREND';
  alertId: string;
  dealId: string;
  metric: string;
  currentValue: number;
  previousValue: number;
  trend: 'IMPROVING' | 'DECLINING';
  changePercent: number;
  projectedImpact: string;
  recommendedAction: string;
}
```

### 3. Threshold Alerts (Limit-Based)

```typescript
interface ThresholdAlert {
  type: 'THRESHOLD';
  alertId: string;
  dealId: string;
  metric: string;
  currentValue: number;
  threshold: number;
  exceeded: boolean;
  severity: AlertSeverity;
  action: string;
}
```

## Predictive Alert Logic

### FINANCING_AT_RISK Detection

```typescript
function detectFinancingRisk(deal: Deal, history: AgentHistory): Alert | null {
  const signals = [];
  let riskScore = 0;

  // Signal: Close to contingency with no approval
  const daysToContingency = daysBetween(today, deal.financingContingencyDate);
  if (daysToContingency <= 7 && !deal.financingApproved) {
    signals.push({
      signal: 'Financing contingency in 7 days, not approved',
      weight: 40
    });
    riskScore += 40;
  }

  // Signal: Lender responsiveness declining
  const lender = deal.parties.find(p => p.role === 'lender');
  if (lender && lender.responsivenessScore < 40) {
    signals.push({
      signal: `Lender responsiveness poor (${lender.responsivenessScore}/100)`,
      weight: 25
    });
    riskScore += 25;
  }

  // Signal: Pattern match - this lender has failed before
  const lenderHistory = history.lenderPerformance[lender?.name];
  if (lenderHistory && lenderHistory.closeRate < 0.70) {
    signals.push({
      signal: `Lender has ${Math.round(lenderHistory.closeRate * 100)}% historical close rate`,
      weight: 20
    });
    riskScore += 20;
  }

  // Signal: First-time buyer + high DTI indicators
  if (deal.buyerType === 'first_time' && deal.priceRange === '300k-500k') {
    signals.push({
      signal: 'First-time buyer in high financing-failure price range',
      weight: 15
    });
    riskScore += 15;
  }

  // Signal: Appraisal not ordered with 14 days to contingency
  if (daysToContingency <= 14 && !deal.appraisalOrdered) {
    signals.push({
      signal: 'Appraisal not ordered, needed for financing',
      weight: 30
    });
    riskScore += 30;
  }

  if (riskScore >= 50) {
    return {
      type: 'PREDICTIVE',
      category: 'FINANCING_AT_RISK',
      severity: riskScore >= 70 ? 'HIGH' : 'MEDIUM',
      confidence: Math.min(95, riskScore),
      title: 'Financing may not clear in time',
      description: `Multiple signals indicate financing risk for this deal`,
      evidence: signals,
      predictedOutcome: 'Possible contract termination or extension needed',
      timeToImpact: daysToContingency,
      preventiveActions: [
        { action: 'Contact lender for status update', priority: 1 },
        { action: 'Verify appraisal ordered', priority: 2 },
        { action: 'Prepare extension request', priority: 3 }
      ]
    };
  }

  return null;
}
```

### CLOSING_DELAY_LIKELY Detection

```typescript
function detectClosingDelay(deal: Deal): Alert | null {
  const signals = [];
  let riskScore = 0;
  const daysToClose = daysBetween(today, deal.closingDate);

  // Signal: Multiple deadlines already extended
  const extensions = deal.deadlines.filter(d => d.extended).length;
  if (extensions >= 2) {
    signals.push({
      signal: `${extensions} deadlines already extended`,
      weight: 25
    });
    riskScore += 25;
  }

  // Signal: Critical milestone overdue
  const overdueCount = deal.deadlines.filter(d =>
    d.status === 'overdue' && d.isCritical
  ).length;
  if (overdueCount > 0) {
    signals.push({
      signal: `${overdueCount} critical milestone(s) overdue`,
      weight: 35
    });
    riskScore += 35;
  }

  // Signal: Tight timeline with open items
  const openCriticalItems = deal.deadlines.filter(d =>
    d.status !== 'completed' && d.isCritical
  ).length;
  if (daysToClose <= 21 && openCriticalItems >= 3) {
    signals.push({
      signal: `${openCriticalItems} critical items open with ${daysToClose} days to close`,
      weight: 30
    });
    riskScore += 30;
  }

  // Signal: Title issues identified
  if (deal.titleIssues?.length > 0) {
    signals.push({
      signal: `${deal.titleIssues.length} title issue(s) unresolved`,
      weight: 25
    });
    riskScore += 25;
  }

  // Signal: Party unresponsive on critical path
  const criticalParties = deal.parties.filter(p =>
    ['lender', 'title_company', 'buyer', 'seller'].includes(p.role)
  );
  const unresponsive = criticalParties.filter(p => p.responsivenessScore < 30);
  if (unresponsive.length > 0) {
    signals.push({
      signal: `${unresponsive.map(p => p.role).join(', ')} unresponsive`,
      weight: 20
    });
    riskScore += 20;
  }

  if (riskScore >= 50) {
    const estimatedDelay = Math.ceil(riskScore / 20) * 3; // Rough delay estimate

    return {
      type: 'PREDICTIVE',
      category: 'CLOSING_DELAY_LIKELY',
      severity: riskScore >= 70 ? 'HIGH' : 'MEDIUM',
      confidence: Math.min(90, riskScore),
      title: 'Closing delay likely',
      description: `Current trajectory suggests closing may slip by ${estimatedDelay} days`,
      evidence: signals,
      predictedOutcome: `Estimated new closing: ${addDays(deal.closingDate, estimatedDelay)}`,
      timeToImpact: daysToClose,
      preventiveActions: generateDelayPreventionActions(signals)
    };
  }

  return null;
}
```

### PARTY_DISENGAGEMENT Detection

```typescript
function detectDisengagement(deal: Deal): Alert | null {
  const signals = [];
  let riskScore = 0;

  for (const party of deal.parties) {
    const daysSinceContact = daysSince(party.lastContactAt);
    const responseTrend = party.responseTrend;

    // Check for concerning patterns
    if (daysSinceContact > 7 && ['buyer', 'seller'].includes(party.role)) {
      signals.push({
        signal: `${party.role} hasn't responded in ${daysSinceContact} days`,
        party: party.name,
        weight: 30
      });
      riskScore += 30;
    }

    if (responseTrend === 'DECLINING' && party.responsivenessScore < 50) {
      signals.push({
        signal: `${party.role} response time worsening`,
        party: party.name,
        weight: 20
      });
      riskScore += 20;
    }

    // Check for engagement drop-off after specific milestone
    if (deal.status === 'post_inspection' && party.role === 'buyer') {
      const preInspectionEngagement = party.preInspectionResponseRate;
      const postInspectionEngagement = party.postInspectionResponseRate;
      if (postInspectionEngagement < preInspectionEngagement * 0.5) {
        signals.push({
          signal: 'Buyer engagement dropped 50%+ after inspection',
          party: party.name,
          weight: 35
        });
        riskScore += 35;
      }
    }
  }

  if (riskScore >= 50) {
    return {
      type: 'PREDICTIVE',
      category: 'PARTY_DISENGAGEMENT',
      severity: 'MEDIUM',
      confidence: Math.min(85, riskScore),
      title: 'Party engagement declining',
      description: 'One or more parties showing disengagement signals',
      evidence: signals,
      predictedOutcome: 'Risk of delays or deal falling through',
      timeToImpact: 7,
      preventiveActions: [
        { action: 'Schedule check-in call with disengaged party', priority: 1 },
        { action: 'Send status update to re-engage', priority: 2 },
        { action: 'Address any unspoken concerns', priority: 3 }
      ]
    };
  }

  return null;
}
```

## Alert Severity Levels

| Severity | Criteria | Response Time | Notification Channels |
|----------|----------|---------------|----------------------|
| **CRITICAL** | Deal in jeopardy, immediate action needed | Immediate | Push, SMS, Email, Voice |
| **HIGH** | Significant risk, action needed today | < 4 hours | Push, SMS, Email |
| **MEDIUM** | Potential issue, action needed this week | < 24 hours | Push, Email |
| **LOW** | Minor concern, monitor | < 48 hours | Email only |
| **INFO** | Informational only | End of day | Dashboard only |

## Execution Flow

```
START
  │
  ├─── 1. Load active deals and data
  │    ├── All active deals
  │    ├── Party responsiveness data
  │    ├── Deadline statuses
  │    ├── Communication history
  │    ├── Historical patterns
  │    └── Existing active alerts
  │
  ├─── 2. FOR EACH active deal:
  │    │
  │    ├─── 2a. Run predictive detections
  │    │    ├── detectFinancingRisk()
  │    │    ├── detectClosingDelay()
  │    │    ├── detectDisengagement()
  │    │    ├── detectInspectionConcern()
  │    │    ├── detectTitleIssue()
  │    │    ├── detectAppraisalGap()
  │    │    └── detectDealFatigue()
  │    │
  │    ├─── 2b. Run trend analysis
  │    │    ├── Risk score trend
  │    │    ├── Party responsiveness trend
  │    │    └── Communication frequency trend
  │    │
  │    ├─── 2c. Check thresholds
  │    │    ├── Risk score > 60
  │    │    ├── Days to close < 14 with open items
  │    │    ├── Party unresponsive > 48h
  │    │    └── Communication gap > 7 days
  │    │
  │    └─── 2d. Deduplicate alerts
  │         └── Don't create duplicate of existing active alert
  │
  ├─── 3. Prioritize alerts
  │    ├── Sort by severity
  │    ├── Sort by time to impact
  │    └── Group by deal
  │
  ├─── 4. Store new alerts
  │    └── INSERT INTO alerts
  │
  ├─── 5. Send notifications
  │    │
  │    ├── FOR EACH alert:
  │    │   ├── Determine channels based on severity
  │    │   ├── Format message for each channel
  │    │   └── Dispatch via notification service
  │    │
  │    └── Update alert.notified_at
  │
  ├─── 6. Expire old alerts
  │    └── Mark alerts past expiresAt as expired
  │
  └─── 7. Return results
```

## Output

```typescript
{
  success: true,
  actionTaken: "Generated proactive alerts for 5 active deals",
  result: {
    totalDealsAnalyzed: 5,
    alertsGenerated: 3,
    alertsSent: 3,
    alerts: [
      {
        alertId: "uuid-1",
        dealId: "deal-uuid-1",
        address: "123 Main St, Miami",
        type: "PREDICTIVE",
        category: "FINANCING_AT_RISK",
        severity: "HIGH",
        confidence: 75,
        title: "Financing may not clear in time",
        description: "Multiple signals indicate financing risk for this deal",
        evidence: [
          "Financing contingency in 5 days, not approved",
          "Lender responsiveness poor (35/100)",
          "Appraisal not ordered, needed for financing"
        ],
        predictedOutcome: "Possible contract termination or extension needed",
        timeToImpact: 5,
        preventiveActions: [
          "Contact lender for status update",
          "Verify appraisal ordered",
          "Prepare extension request"
        ],
        notificationsSent: ["push", "sms", "email"]
      },
      {
        alertId: "uuid-2",
        dealId: "deal-uuid-2",
        address: "456 Oak Lane, Coral Gables",
        type: "PREDICTIVE",
        category: "PARTY_DISENGAGEMENT",
        severity: "MEDIUM",
        confidence: 65,
        title: "Buyer engagement declining",
        description: "Buyer's response rate dropped significantly after inspection",
        evidence: [
          "Buyer hasn't responded in 8 days",
          "Buyer engagement dropped 60% after inspection"
        ],
        predictedOutcome: "Risk of delays or deal falling through",
        timeToImpact: 7,
        preventiveActions: [
          "Schedule check-in call with buyer",
          "Send status update to re-engage",
          "Ask buyer's agent if there are concerns"
        ],
        notificationsSent: ["push", "email"]
      },
      {
        alertId: "uuid-3",
        dealId: "deal-uuid-3",
        address: "789 Palm Ave, Miami Beach",
        type: "THRESHOLD",
        category: "RISK_SCORE_HIGH",
        severity: "HIGH",
        title: "Risk score exceeded threshold",
        description: "Deal risk score jumped from 45 to 68 in 2 days",
        currentValue: 68,
        threshold: 60,
        action: "Review risk assessment and address top issues"
      }
    ],
    summary: {
      critical: 0,
      high: 2,
      medium: 1,
      low: 0
    },
    dealsWithAlerts: [
      "123 Main St (HIGH - Financing)",
      "456 Oak Lane (MEDIUM - Engagement)",
      "789 Palm Ave (HIGH - Risk Score)"
    ]
  }
}
```

## Voice Notifications

### HIGH Severity Alert
> "Heads up on 123 Main Street. I'm seeing financing risk.
>
> The financing contingency is in 5 days and we don't have approval yet. The lender has been slow to respond, and the appraisal still isn't ordered.
>
> Based on similar situations, there's a 75% chance this will need an extension.
>
> I recommend calling the lender today. Want me to remind you in an hour?"

### MEDIUM Severity Alert
> "Something to watch at 456 Oak Lane.
>
> The buyer's engagement has dropped significantly since the inspection. They haven't responded in 8 days, and their response rate is down 60%.
>
> This could be cold feet or unspoken concerns. I'd suggest a check-in call.
>
> Want me to draft a friendly outreach?"

### CRITICAL Severity Alert
> "Urgent alert for 789 Palm Avenue.
>
> Multiple critical issues just converged:
> - Financing contingency expires tomorrow, no approval
> - Title has an unresolved lien
> - Clear to close impossible by scheduled date
>
> This deal needs immediate attention or it won't close on time.
>
> I'm sending you the details now. This is your top priority today."

## Alert Templates

### Push Notification (Short)
```
[SEVERITY] [Address]: [Title]
[One-line description]
Tap to view actions →
```

### SMS
```
Homer Pro Alert [SEVERITY]

[Address]
[Title]

[2-3 sentence description]

Top action: [Primary recommended action]

Reply "V" to view details or "D" to dismiss.
```

### Email
```
Subject: [Severity Icon] [Title] - [Address]

[Full description]

EVIDENCE:
• [Signal 1]
• [Signal 2]
• [Signal 3]

RECOMMENDED ACTIONS:
1. [Action 1]
2. [Action 2]
3. [Action 3]

Time to impact: [X] days

---
View in Homer Pro: [link]
Dismiss this alert: [link]
```

## Error Handling

| Error | Cause | Response |
|-------|-------|----------|
| `NO_ACTIVE_DEALS` | Agent has no active deals | Skip alert generation, log |
| `ALERT_DUPLICATE` | Alert already exists for this issue | Don't create new, update existing |
| `NOTIFICATION_FAILED` | Push/SMS/email failed | Retry, fallback to other channels |
| `LOW_CONFIDENCE` | Prediction confidence < 50% | Don't alert, log for review |

## Quality Checklist

- [x] Predicts issues 3-7 days before they occur
- [x] Provides evidence for each prediction
- [x] Confidence levels are calibrated
- [x] Deduplicates existing alerts
- [x] Severity matches actual urgency
- [x] Preventive actions are specific and actionable
- [x] Multi-channel notifications based on severity
- [x] Voice notifications for high/critical alerts
- [x] Alerts expire appropriately
- [x] Integrates with risk assessment and timeline analysis

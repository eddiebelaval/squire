# Skill: Learning From Outcome

**Category:** Intelligence
**Priority:** P1
**Approval Required:** No

## Purpose

Analyze completed transactions (both successful closings and failed deals) to extract lessons, identify what worked, what didn't, and continuously improve Homer's predictive models and recommendations. This skill closes the feedback loop that makes Homer smarter over time.

## Triggers

### Automatic (Primary)
- Deal status changed to `closed`
- Deal status changed to `cancelled` / `fallen_through`
- 30 days after closing (long-term follow-up analysis)

### Voice Commands
- "What did we learn from [address]?"
- "Analyze the [address] outcome"
- "Post-mortem for [address]"
- "Why did [address] fall through?"
- "What worked on [address]?"

### Programmatic
- `POST /deals/:id/analyze-outcome`
- Monthly learning aggregation
- Pattern recognition training

## Learning Categories

### 1. Success Factors Analysis (Closed Deals)

```typescript
interface SuccessAnalysis {
  dealId: string;
  address: string;
  closingDate: Date;
  finalPrice: number;
  daysToClose: number;

  // What went right
  successFactors: SuccessFactor[];

  // Efficiency metrics
  efficiency: {
    daysVsAverage: number;           // +/- compared to agent average
    extensionsUsed: number;
    riskScoreAtClose: number;
    highestRiskDuringDeal: number;
    riskRecoveryStory?: string;
  };

  // Party performance
  topPerformers: PartyPerformance[];
  underperformers: PartyPerformance[];

  // Pattern validation
  patternsValidated: string[];       // Predictions that came true
  patternsMissed: string[];          // Things we didn't predict

  // Lessons
  lessonsLearned: Lesson[];

  // Recommendations for future
  futureRecommendations: string[];
}

interface SuccessFactor {
  factor: string;
  impact: 'HIGH' | 'MEDIUM' | 'LOW';
  description: string;
  replicable: boolean;               // Can this be repeated?
}

interface Lesson {
  type: 'POSITIVE' | 'NEGATIVE' | 'INSIGHT';
  category: string;
  description: string;
  actionItem: string;
}
```

### 2. Failure Analysis (Cancelled/Fallen Through)

```typescript
interface FailureAnalysis {
  dealId: string;
  address: string;
  cancellationDate: Date;
  daysActive: number;

  // Primary failure reason
  primaryCause: FailureCause;
  contributingFactors: FailureCause[];

  // Timeline to failure
  warningSignsTimeline: WarningSign[];

  // What we predicted vs what happened
  predictionAccuracy: {
    alertsRaised: Alert[];
    alertsActedOn: Alert[];
    alertsIgnored: Alert[];
    missedWarnings: string[];
  };

  // Preventability assessment
  preventability: {
    couldHavePrevented: boolean;
    preventionWindow: string;        // When action could have helped
    suggestedPrevention: string;
  };

  // Pattern classification
  matchesKnownPattern: boolean;
  patternName?: string;              // e.g., "FINANCING_COLLAPSE"
  newPatternIdentified?: string;

  // Lessons
  lessonsLearned: Lesson[];

  // Model updates
  modelUpdates: ModelUpdate[];
}

interface FailureCause {
  category: string;
  description: string;
  timeOfOccurrence: Date;
  detectedBy: 'homer' | 'agent' | 'party' | 'discovered_post';
  advanceWarning: number;            // Days before failure we could have seen it
}

interface WarningSign {
  date: Date;
  signal: string;
  severity: 'LOW' | 'MEDIUM' | 'HIGH';
  actionTaken?: string;
  outcome: string;
}

interface ModelUpdate {
  model: string;                     // Which model to update
  updateType: 'weight_adjustment' | 'new_signal' | 'threshold_change';
  description: string;
  before: any;
  after: any;
}
```

## Analysis Algorithms

### Success Factor Identification

```typescript
function identifySuccessFactors(deal: ClosedDeal): SuccessFactor[] {
  const factors: SuccessFactor[] = [];

  // Fast closing analysis
  const avgDaysToClose = getAgentAverageDaysToClose(deal.agentId);
  if (deal.daysToClose < avgDaysToClose * 0.8) {
    // Analyze why it was fast
    if (deal.financingType === 'cash') {
      factors.push({
        factor: 'CASH_BUYER',
        impact: 'HIGH',
        description: 'Cash purchase eliminated financing timeline',
        replicable: false
      });
    }
    if (deal.lenderResponseTime < 12) {
      factors.push({
        factor: 'EXCELLENT_LENDER',
        impact: 'HIGH',
        description: `${deal.lender.name} averaged 12-hour responses`,
        replicable: true
      });
    }
    if (deal.preApprovalStrength === 'full_underwrite') {
      factors.push({
        factor: 'STRONG_PREAPPROVAL',
        impact: 'HIGH',
        description: 'Buyer had full underwriting pre-approval',
        replicable: true
      });
    }
  }

  // Clean inspection analysis
  if (!deal.inspectionIssuesFound || deal.inspectionIssuesResolved) {
    if (deal.preInspectionDone) {
      factors.push({
        factor: 'PRE_INSPECTION',
        impact: 'MEDIUM',
        description: 'Pre-inspection prevented surprises',
        replicable: true
      });
    }
    if (deal.propertyAge < 10) {
      factors.push({
        factor: 'NEWER_PROPERTY',
        impact: 'MEDIUM',
        description: 'Property age under 10 years reduced inspection risk',
        replicable: false
      });
    }
  }

  // Communication analysis
  const avgResponseTime = calculateAvgPartyResponseTime(deal);
  if (avgResponseTime < 8) {
    factors.push({
      factor: 'RESPONSIVE_PARTIES',
      impact: 'HIGH',
      description: 'All parties averaged under 8-hour response times',
      replicable: true
    });
  }

  // Risk management analysis
  if (deal.highestRiskScore > 50 && deal.riskAtClose < 20) {
    factors.push({
      factor: 'RISK_RECOVERY',
      impact: 'HIGH',
      description: 'Successfully navigated high-risk period',
      replicable: true
    });
  }

  return factors;
}
```

### Failure Cause Analysis

```typescript
function analyzeFailure(deal: FailedDeal): FailureAnalysis {
  const analysis: FailureAnalysis = {
    dealId: deal.id,
    address: deal.address,
    cancellationDate: deal.cancelledAt,
    daysActive: deal.daysActive
  };

  // Determine primary cause
  analysis.primaryCause = determinePrimaryCause(deal);
  analysis.contributingFactors = determineContributingFactors(deal);

  // Build warning signs timeline
  analysis.warningSignsTimeline = buildWarningTimeline(deal);

  // Analyze prediction accuracy
  analysis.predictionAccuracy = analyzePredictionAccuracy(deal);

  // Assess preventability
  analysis.preventability = assessPreventability(deal);

  // Check pattern match
  analysis.matchesKnownPattern = checkPatternMatch(deal);
  if (analysis.matchesKnownPattern) {
    analysis.patternName = identifyPattern(deal);
  } else if (isNewPattern(deal)) {
    analysis.newPatternIdentified = classifyNewPattern(deal);
  }

  // Generate lessons
  analysis.lessonsLearned = generateLessons(deal, analysis);

  // Determine model updates
  analysis.modelUpdates = determineModelUpdates(deal, analysis);

  return analysis;
}

function determinePrimaryCause(deal: FailedDeal): FailureCause {
  const causes = [];

  // Check financing
  if (deal.cancelReason?.includes('financing') ||
      deal.cancelledDuring === 'financing_contingency' ||
      !deal.financingApproved) {
    causes.push({
      category: 'FINANCING',
      description: 'Buyer unable to obtain financing',
      severity: calculateSeverity(deal),
      advanceWarning: calculateAdvanceWarning(deal, 'financing')
    });
  }

  // Check inspection
  if (deal.cancelReason?.includes('inspection') ||
      deal.cancelledDuring === 'inspection_period') {
    causes.push({
      category: 'INSPECTION',
      description: 'Buyer cancelled based on inspection findings',
      severity: calculateSeverity(deal),
      advanceWarning: calculateAdvanceWarning(deal, 'inspection')
    });
  }

  // Check appraisal
  if (deal.cancelReason?.includes('appraisal') ||
      deal.appraisalGap > 0) {
    causes.push({
      category: 'APPRAISAL',
      description: `Appraisal came in ${deal.appraisalGap} below contract`,
      severity: calculateSeverity(deal),
      advanceWarning: calculateAdvanceWarning(deal, 'appraisal')
    });
  }

  // Check title
  if (deal.cancelReason?.includes('title') ||
      deal.unresolvedTitleIssues?.length > 0) {
    causes.push({
      category: 'TITLE',
      description: 'Unresolvable title issues discovered',
      severity: calculateSeverity(deal),
      advanceWarning: calculateAdvanceWarning(deal, 'title')
    });
  }

  // Check buyer cold feet
  if (deal.cancelledDuring === 'inspection_period' &&
      !deal.inspectionIssuesFound &&
      deal.buyerEngagementScore < 50) {
    causes.push({
      category: 'BUYER_COLD_FEET',
      description: 'Buyer cancelled without specific reason during inspection',
      severity: 'HIGH',
      advanceWarning: calculateAdvanceWarning(deal, 'cold_feet')
    });
  }

  // Return highest severity cause
  return causes.sort((a, b) => b.severity - a.severity)[0];
}

function assessPreventability(deal: FailedDeal): Preventability {
  const analysis = {
    couldHavePrevented: false,
    preventionWindow: '',
    suggestedPrevention: ''
  };

  // Financing failures with warning signs
  if (deal.primaryCause?.category === 'FINANCING') {
    const earlyWarnings = deal.alerts.filter(a =>
      a.category === 'FINANCING_AT_RISK' &&
      a.daysBeforeFailure > 7
    );

    if (earlyWarnings.length > 0 && !earlyWarnings.some(a => a.actedOn)) {
      analysis.couldHavePrevented = true;
      analysis.preventionWindow = `${earlyWarnings[0].daysBeforeFailure} days before cancellation`;
      analysis.suggestedPrevention = 'Acting on the financing risk alert could have allowed time for alternative lender or extension negotiation';
    }
  }

  // Inspection failures with pattern match
  if (deal.primaryCause?.category === 'INSPECTION') {
    if (deal.propertyAge > 30 && !deal.preInspectionDone) {
      analysis.couldHavePrevented = true;
      analysis.preventionWindow = 'Before offer acceptance';
      analysis.suggestedPrevention = 'Pre-inspection on properties over 25 years old reduces surprise cancellations';
    }
  }

  // Cold feet with engagement drop
  if (deal.primaryCause?.category === 'BUYER_COLD_FEET') {
    const engagementDrop = deal.alerts.find(a =>
      a.category === 'PARTY_DISENGAGEMENT'
    );
    if (engagementDrop && !engagementDrop.actedOn) {
      analysis.couldHavePrevented = true;
      analysis.preventionWindow = `When engagement dropped (day ${engagementDrop.dealDay})`;
      analysis.suggestedPrevention = 'Proactive check-in call when engagement drops can surface concerns before they become cancellations';
    }
  }

  return analysis;
}
```

### Model Update Generation

```typescript
function determineModelUpdates(deal: FailedDeal, analysis: FailureAnalysis): ModelUpdate[] {
  const updates: ModelUpdate[] = [];

  // If we missed this pattern, update detection weights
  if (!analysis.matchesKnownPattern && analysis.newPatternIdentified) {
    updates.push({
      model: 'pattern_recognition',
      updateType: 'new_signal',
      description: `Add new failure pattern: ${analysis.newPatternIdentified}`,
      before: null,
      after: {
        patternName: analysis.newPatternIdentified,
        signals: extractSignals(deal),
        weight: 0.7  // Start at 70% confidence
      }
    });
  }

  // If alerts were raised but not severe enough
  if (analysis.predictionAccuracy.alertsIgnored.length > 0) {
    const ignoredAlert = analysis.predictionAccuracy.alertsIgnored[0];
    updates.push({
      model: 'alert_severity',
      updateType: 'threshold_change',
      description: `Increase severity for ${ignoredAlert.category} alerts`,
      before: { severity: ignoredAlert.severity },
      after: { severity: increaseSeverity(ignoredAlert.severity) }
    });
  }

  // If a specific lender/party performed poorly
  if (deal.lender && analysis.primaryCause?.category === 'FINANCING') {
    updates.push({
      model: 'party_performance',
      updateType: 'weight_adjustment',
      description: `Update ${deal.lender.name} close rate`,
      before: { closeRate: deal.lender.historicalCloseRate },
      after: { closeRate: recalculateCloseRate(deal.lender) }
    });
  }

  // If property age was a factor
  if (deal.propertyAge > 25 && analysis.primaryCause?.category === 'INSPECTION') {
    updates.push({
      model: 'risk_assessment',
      updateType: 'weight_adjustment',
      description: 'Increase property age weight in inspection risk',
      before: { propertyAgeWeight: 0.15 },
      after: { propertyAgeWeight: 0.20 }
    });
  }

  return updates;
}
```

## Execution Flow

```
START
  │
  ├─── 1. Load deal data
  │    ├── Complete deal history
  │    ├── All communications
  │    ├── All alerts raised
  │    ├── All risk assessments
  │    ├── Party performance data
  │    └── Outcome details
  │
  ├─── 2. Determine outcome type
  │    ├── IF status = 'closed' → Success analysis
  │    └── IF status = 'cancelled'/'fallen_through' → Failure analysis
  │
  ├─── 3A. FOR SUCCESS:
  │    │
  │    ├── Calculate efficiency metrics
  │    │   ├── Compare to averages
  │    │   ├── Count extensions
  │    │   └── Track risk journey
  │    │
  │    ├── Identify success factors
  │    │   ├── Fast closing factors
  │    │   ├── Clean process factors
  │    │   └── Party performance factors
  │    │
  │    ├── Validate predictions
  │    │   ├── Which alerts came true?
  │    │   └── Which predictions missed?
  │    │
  │    ├── Generate lessons
  │    │   └── What should we replicate?
  │    │
  │    └── Update party scores
  │        └── Reward good performers
  │
  ├─── 3B. FOR FAILURE:
  │    │
  │    ├── Determine primary cause
  │    │   └── Classify failure reason
  │    │
  │    ├── Build warning timeline
  │    │   └── What signals appeared when?
  │    │
  │    ├── Analyze prediction accuracy
  │    │   ├── What did we alert on?
  │    │   ├── What was acted on?
  │    │   └── What did we miss?
  │    │
  │    ├── Assess preventability
  │    │   └── Could we have avoided this?
  │    │
  │    ├── Check pattern match
  │    │   ├── Known pattern?
  │    │   └── New pattern?
  │    │
  │    ├── Generate lessons
  │    │   └── What should we do differently?
  │    │
  │    └── Determine model updates
  │        ├── New patterns to add
  │        ├── Weights to adjust
  │        └── Thresholds to change
  │
  ├─── 4. Store analysis
  │    └── INSERT INTO outcome_analyses
  │
  ├─── 5. Apply model updates (if approved)
  │    └── Update pattern/risk models
  │
  ├─── 6. Update aggregate statistics
  │    ├── Agent close rate
  │    ├── Party performance scores
  │    └── Pattern frequency counts
  │
  └─── 7. Return result
```

## Output

### Success Analysis Output

```typescript
{
  success: true,
  actionTaken: "Analyzed successful closing for 101 Sunset Dr",
  result: {
    dealId: "deal-101",
    address: "101 Sunset Dr, Key Biscayne",
    outcome: "CLOSED",
    closingDate: "2026-01-15",
    finalPrice: 650000,
    daysToClose: 38,

    efficiency: {
      daysVsAverage: -4,
      extensionsUsed: 0,
      riskScoreAtClose: 12,
      highestRiskDuringDeal: 45,
      riskRecoveryStory: "Risk peaked at day 22 due to appraisal scheduling delay, recovered after appraisal completed on time"
    },

    successFactors: [
      {
        factor: "EXCELLENT_LENDER",
        impact: "HIGH",
        description: "First National Bank averaged 8-hour responses, approved financing in 21 days",
        replicable: true
      },
      {
        factor: "RESPONSIVE_PARTIES",
        impact: "HIGH",
        description: "All parties averaged under 6-hour response times",
        replicable: true
      },
      {
        factor: "CLEAN_TITLE",
        impact: "MEDIUM",
        description: "Title search completed in 10 days with no issues",
        replicable: false
      }
    ],

    topPerformers: [
      { name: "First National Bank", role: "lender", score: 95 },
      { name: "ABC Title Company", role: "title_company", score: 92 }
    ],

    underperformers: [],

    patternsValidated: [
      "First National Bank continues strong performance (8th successful deal)"
    ],

    patternsMissed: [],

    lessonsLearned: [
      {
        type: "POSITIVE",
        category: "lender_selection",
        description: "First National Bank is now 8-for-8 on closings",
        actionItem: "Continue prioritizing First National for financing"
      },
      {
        type: "INSIGHT",
        category: "party_engagement",
        description: "High party responsiveness correlated with 4 days faster close",
        actionItem: "Monitor responsiveness early and address slow responders immediately"
      }
    ],

    futureRecommendations: [
      "Continue using First National Bank as preferred lender",
      "Set expectation for 6-hour response times with all parties",
      "This deal type (Key Biscayne, $600k-700k) has 100% success rate - consider focusing here"
    ]
  }
}
```

### Failure Analysis Output

```typescript
{
  success: true,
  actionTaken: "Analyzed failed deal for 555 Oak St",
  result: {
    dealId: "deal-555",
    address: "555 Oak St, Miami",
    outcome: "CANCELLED",
    cancellationDate: "2026-01-10",
    daysActive: 42,

    primaryCause: {
      category: "FINANCING",
      description: "Buyer's loan denied after underwriting review",
      timeOfOccurrence: "2026-01-08",
      detectedBy: "lender",
      advanceWarning: 8
    },

    contributingFactors: [
      {
        category: "LENDER_PERFORMANCE",
        description: "ABC Mortgage took 35 days to reach underwriting",
        advanceWarning: 15
      },
      {
        category: "BUYER_QUALIFICATION",
        description: "Buyer's debt-to-income changed after pre-approval",
        advanceWarning: 0
      }
    ],

    warningSignsTimeline: [
      {
        date: "2025-12-20",
        signal: "Lender responsiveness dropped below 30",
        severity: "MEDIUM",
        actionTaken: "Alert raised, no action taken",
        outcome: "Delay continued"
      },
      {
        date: "2025-12-28",
        signal: "Homer raised FINANCING_AT_RISK alert",
        severity: "HIGH",
        actionTaken: "Agent acknowledged but didn't follow up",
        outcome: "Issue not addressed"
      },
      {
        date: "2026-01-03",
        signal: "Underwriting request for additional docs",
        severity: "HIGH",
        actionTaken: "Documents provided in 3 days",
        outcome: "Loan denied"
      }
    ],

    predictionAccuracy: {
      alertsRaised: [
        { type: "FINANCING_AT_RISK", date: "2025-12-28", severity: "HIGH" }
      ],
      alertsActedOn: [],
      alertsIgnored: [
        { type: "FINANCING_AT_RISK", date: "2025-12-28", severity: "HIGH" }
      ],
      missedWarnings: [
        "Buyer's employment status changed but not flagged"
      ]
    },

    preventability: {
      couldHavePrevented: true,
      preventionWindow: "December 28 - January 3 (6 days)",
      suggestedPrevention: "Following up on the financing risk alert could have allowed time to explore alternative lenders or request an extension before the issue became terminal"
    },

    matchesKnownPattern: true,
    patternName: "FINANCING_COLLAPSE",

    lessonsLearned: [
      {
        type: "NEGATIVE",
        category: "alert_response",
        description: "HIGH severity financing alert was ignored",
        actionItem: "Treat HIGH alerts as mandatory same-day follow-up"
      },
      {
        type: "NEGATIVE",
        category: "lender_selection",
        description: "ABC Mortgage now has 50% close rate (3 of 6)",
        actionItem: "Remove ABC Mortgage from preferred lender list"
      },
      {
        type: "INSIGHT",
        category: "buyer_monitoring",
        description: "Buyer employment changes during deal weren't tracked",
        actionItem: "Add employment status check at financing contingency"
      }
    ],

    modelUpdates: [
      {
        model: "party_performance",
        updateType: "weight_adjustment",
        description: "Update ABC Mortgage close rate",
        before: { closeRate: 0.60 },
        after: { closeRate: 0.50 }
      },
      {
        model: "risk_assessment",
        updateType: "new_signal",
        description: "Add employment verification check near financing contingency",
        before: null,
        after: { signal: "employment_verification_pending", weight: 0.15 }
      }
    ]
  }
}
```

## Voice Response

### Successful Closing Review
> "Let's look at what worked on 101 Sunset Drive.
>
> You closed in 38 days, which is 4 days faster than your average. Zero extensions needed.
>
> **What made it work:**
>
> First, First National Bank was excellent again - 8-hour average response, loan approved in 21 days. That's their 8th successful deal with you. They're your best lender by far.
>
> Second, everyone was responsive. All parties averaged under 6-hour responses, which definitely helped speed things up.
>
> **Lessons for future deals:**
> Keep using First National. Set the expectation for 6-hour responses upfront.
>
> Also interesting: you're 100% on Key Biscayne deals in this price range. That might be a market to focus on."

### Failed Deal Review
> "Let's analyze what happened with 555 Oak Street.
>
> The deal failed at day 42 when the buyer's financing was denied. But looking back, there were warning signs we could have acted on.
>
> **What went wrong:**
>
> Primary issue: ABC Mortgage took 35 days to reach underwriting - way too slow. I raised a HIGH severity financing risk alert on December 28th, but it wasn't acted on.
>
> **Could we have prevented this?**
>
> Likely yes. If we'd followed up on that alert, we had a 6-day window to explore other lenders or request an extension. By the time the denial came, it was too late.
>
> **Lessons:**
>
> One - ABC Mortgage is now at 50% close rate. I'm removing them from your preferred list.
>
> Two - HIGH severity alerts need same-day response. We had the signal; we just didn't act on it.
>
> Three - I'm adding an employment verification check near financing contingency. The buyer's employment changed and we didn't catch it.
>
> I've updated my models with these lessons. This pattern won't catch us off guard again."

## Integration Points

### Invokes
- `pattern-recognition` - Update pattern database
- `party-responsiveness` - Update party scores

### Invoked By
- Deal status change triggers
- Monthly learning aggregation job

### Updates
- `patterns` table - New patterns
- `party_performance` - Updated scores
- `model_weights` - Adjusted weights
- `agent_statistics` - Updated metrics

## Error Handling

| Error | Cause | Response |
|-------|-------|----------|
| `DEAL_STILL_ACTIVE` | Deal not closed/cancelled | "This deal is still active. I can only analyze outcomes for completed deals." |
| `INSUFFICIENT_HISTORY` | Not enough data to analyze | "There isn't enough activity on this deal for a meaningful analysis." |
| `ANALYSIS_EXISTS` | Already analyzed this deal | Return existing analysis |

## Quality Checklist

- [x] Analyzes both successes and failures
- [x] Identifies replicable success factors
- [x] Determines root cause of failures
- [x] Assesses preventability honestly
- [x] Validates Homer's predictions
- [x] Identifies what Homer missed
- [x] Generates actionable lessons
- [x] Updates models automatically
- [x] Tracks party performance over time
- [x] Closes the feedback loop for continuous improvement

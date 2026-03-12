# Skill: Deal Risk Assessment

**Category:** Intelligence
**Priority:** P0
**Approval Required:** No

## Purpose

Analyze the overall health and risk profile of a real estate transaction. This skill combines multiple risk signals (deadline proximity, party responsiveness, document status, communication gaps, market conditions) to generate a comprehensive risk score and identify specific concerns before they become problems.

## Triggers

### Voice Commands
- "What's the risk level on [address]?"
- "How's the health of the [address] deal?"
- "Any concerns with [address]?"
- "Risk assessment for [deal]"
- "Is [address] on track?"
- "Give me a deal health check"

### Automatic
- Daily scheduled run for all active deals (6:00 AM)
- When deadline status changes
- When party response time exceeds threshold
- When deal enters critical period (last 30 days before closing)
- After any deadline is missed or extended

### Programmatic
- `GET /deals/:id/risk-assessment`
- Dashboard refresh
- Weekly summary generation

## Risk Scoring Algorithm

### Overall Risk Score: 0-100 (Higher = More Risk)

```typescript
interface RiskScore {
  overall: number;           // 0-100 composite score
  category_scores: {
    timeline: number;        // 0-100 deadline/timeline risk
    parties: number;         // 0-100 party engagement risk
    documents: number;       // 0-100 documentation risk
    financial: number;       // 0-100 financial risk
    communication: number;   // 0-100 communication gap risk
  };
  risk_level: 'LOW' | 'MEDIUM' | 'HIGH' | 'CRITICAL';
  flags: RiskFlag[];
  recommendations: string[];
  trend: 'IMPROVING' | 'STABLE' | 'DECLINING';
}

interface RiskFlag {
  type: string;
  severity: 'WARNING' | 'CONCERN' | 'CRITICAL';
  description: string;
  affectedParty?: string;
  affectedDeadline?: string;
  suggestedAction: string;
}
```

### Category Scoring Details

#### 1. Timeline Risk (25% of total)

| Factor | Weight | Scoring |
|--------|--------|---------|
| Overdue deadlines | 40% | +25 per overdue deadline |
| Deadlines due today | 25% | +15 per deadline |
| Deadlines in 48h (incomplete) | 20% | +10 per deadline |
| Extended deadlines | 15% | +5 per extension |

```
timeline_score = min(100, sum of factors)
```

#### 2. Party Responsiveness Risk (25% of total)

| Factor | Weight | Scoring |
|--------|--------|---------|
| Unresponsive party (>48h) | 35% | +30 per party |
| Slow responder (24-48h avg) | 25% | +15 per party |
| Missing critical party contact | 25% | +25 per missing |
| Party communication gap (7+ days) | 15% | +20 per gap |

```
party_score = min(100, sum of factors)
```

#### 3. Document Risk (20% of total)

| Factor | Weight | Scoring |
|--------|--------|---------|
| Missing required documents | 40% | +20 per document |
| Pending signatures (>48h) | 30% | +15 per document |
| Expired documents needing renewal | 20% | +25 per document |
| Rejected/invalid documents | 10% | +30 per document |

```
document_score = min(100, sum of factors)
```

#### 4. Financial Risk (15% of total)

| Factor | Weight | Scoring |
|--------|--------|---------|
| Escrow not received | 40% | +40 if past due |
| Financing not confirmed | 35% | +30 if within 10 days of contingency |
| Title issues identified | 25% | +25 per issue |

```
financial_score = min(100, sum of factors)
```

#### 5. Communication Risk (15% of total)

| Factor | Weight | Scoring |
|--------|--------|---------|
| No outbound contact in 5+ days | 35% | +25 |
| No inbound contact in 7+ days | 35% | +30 |
| Unanswered agent emails (48h+) | 30% | +20 per email |

```
communication_score = min(100, sum of factors)
```

### Overall Score Calculation

```typescript
function calculateOverallRisk(categoryScores: CategoryScores): number {
  const weights = {
    timeline: 0.25,
    parties: 0.25,
    documents: 0.20,
    financial: 0.15,
    communication: 0.15
  };

  let overall = 0;
  for (const [category, weight] of Object.entries(weights)) {
    overall += categoryScores[category] * weight;
  }

  // Apply multipliers for compounding risk
  const criticalFactors = countCriticalFlags(categoryScores);
  if (criticalFactors >= 3) {
    overall = Math.min(100, overall * 1.3); // 30% amplification
  } else if (criticalFactors >= 2) {
    overall = Math.min(100, overall * 1.15); // 15% amplification
  }

  return Math.round(overall);
}

function getRiskLevel(score: number): RiskLevel {
  if (score >= 75) return 'CRITICAL';
  if (score >= 50) return 'HIGH';
  if (score >= 25) return 'MEDIUM';
  return 'LOW';
}
```

## Execution Flow

```
START
  │
  ├─── 1. Load deal data
  │    ├── Deal details and status
  │    ├── All deadlines and statuses
  │    ├── All parties and contact info
  │    ├── All documents and signatures
  │    ├── Communication history
  │    ├── Financial milestones (escrow, financing)
  │    └── Previous risk assessments (for trend)
  │
  ├─── 2. Calculate timeline risk
  │    ├── Count overdue deadlines
  │    ├── Check deadlines due today/tomorrow
  │    ├── Check deadlines in next 48h
  │    ├── Count extensions used
  │    └── Calculate timeline_score
  │
  ├─── 3. Calculate party risk
  │    │
  │    ├── FOR EACH party:
  │    │   ├── Calculate average response time
  │    │   ├── Check last contact date
  │    │   ├── Verify contact info exists
  │    │   └── Check assigned tasks status
  │    │
  │    └── Calculate party_score
  │
  ├─── 4. Calculate document risk
  │    ├── List required documents by deal stage
  │    ├── Check which are missing
  │    ├── Check pending signatures
  │    ├── Check expired/expiring documents
  │    └── Calculate document_score
  │
  ├─── 5. Calculate financial risk
  │    ├── Check escrow deposit status
  │    ├── Check financing contingency status
  │    ├── Check for title issues
  │    ├── Check for liens or encumbrances
  │    └── Calculate financial_score
  │
  ├─── 6. Calculate communication risk
  │    ├── Days since last outbound contact
  │    ├── Days since last inbound contact
  │    ├── Count unanswered messages
  │    └── Calculate communication_score
  │
  ├─── 7. Generate risk flags
  │    │
  │    ├── FOR EACH identified risk factor:
  │    │   ├── Classify severity (WARNING/CONCERN/CRITICAL)
  │    │   ├── Generate human-readable description
  │    │   ├── Link to affected party/deadline
  │    │   └── Generate suggested action
  │    │
  │    └── Sort flags by severity
  │
  ├─── 8. Calculate overall score
  │    ├── Weight category scores
  │    ├── Apply compounding multipliers
  │    └── Determine risk level
  │
  ├─── 9. Determine trend
  │    ├── Compare to previous assessment (if exists)
  │    ├── Calculate score delta
  │    └── Set trend: IMPROVING/STABLE/DECLINING
  │
  ├─── 10. Generate recommendations
  │     │
  │     ├── FOR EACH critical/high flag:
  │     │   └── Generate specific action recommendation
  │     │
  │     └── Prioritize by impact
  │
  ├─── 11. Store assessment
  │     └── INSERT INTO risk_assessments (deal_id, score, flags, ...)
  │
  └─── 12. Return result
```

## Output

```typescript
{
  success: true,
  actionTaken: "Completed risk assessment for 123 Main St",
  result: {
    deal: {
      id: "uuid",
      address: "123 Main St, Miami FL 33101",
      closingDate: "2026-03-12",
      daysToClose: 56
    },
    riskScore: {
      overall: 45,
      level: "MEDIUM",
      trend: "DECLINING",
      previousScore: 32,
      scoreDelta: +13,
      categoryScores: {
        timeline: 35,
        parties: 65,
        documents: 40,
        financial: 25,
        communication: 55
      }
    },
    flags: [
      {
        type: "UNRESPONSIVE_PARTY",
        severity: "CONCERN",
        description: "Buyer's lender hasn't responded in 4 days",
        affectedParty: "First National Bank (Lender)",
        suggestedAction: "Call lender directly or have buyer contact their loan officer"
      },
      {
        type: "COMMUNICATION_GAP",
        severity: "WARNING",
        description: "No contact with seller in 8 days",
        affectedParty: "Jane Doe (Seller)",
        suggestedAction: "Send status update email to seller"
      },
      {
        type: "DEADLINE_APPROACHING",
        severity: "WARNING",
        description: "Financing contingency expires in 3 days",
        affectedDeadline: "Financing Contingency",
        suggestedAction: "Confirm loan approval status with lender"
      }
    ],
    recommendations: [
      "1. Contact lender today to get financing status",
      "2. Send weekly update to seller to maintain engagement",
      "3. Prepare extension request if financing won't clear by deadline"
    ],
    assessedAt: "2026-01-15T06:00:00Z",
    nextAssessment: "2026-01-16T06:00:00Z"
  }
}
```

## Voice Response

### Low Risk (0-24)
> "The deal at 123 Main Street is looking healthy. Risk score is 18 out of 100, which is low.
>
> All deadlines are on track, parties are responsive, and documents are in order.
>
> No concerns at this time. I'll keep monitoring and let you know if anything changes."

### Medium Risk (25-49)
> "123 Main Street has a medium risk score of 45.
>
> I have 3 items to flag:
>
> First, the buyer's lender hasn't responded in 4 days. You might want to call them directly or have the buyer reach out.
>
> Second, there's been no contact with the seller in 8 days. A quick status update would help.
>
> Third, the financing contingency expires in 3 days and we haven't confirmed loan approval yet.
>
> Would you like me to draft a follow-up to the lender?"

### High Risk (50-74)
> "Warning: 123 Main Street has a high risk score of 62. This deal needs attention today.
>
> The main issues are:
> - Two deadlines are overdue
> - The lender has been unresponsive for a week
> - The appraisal is still pending with closing in 3 weeks
>
> I recommend calling the lender immediately and preparing an extension request. Want me to draft the extension?"

### Critical Risk (75-100)
> "Alert: 123 Main Street is at critical risk. Score is 85 out of 100.
>
> Multiple issues are compounding:
> - Financing deadline passed yesterday without resolution
> - Escrow deposit still not received
> - Title has unresolved liens
>
> This deal may be in jeopardy. I strongly recommend immediate action. Should I prepare a status call with all parties?"

## Risk Flag Types

| Flag Type | Severity Threshold | Description |
|-----------|-------------------|-------------|
| `DEADLINE_OVERDUE` | CRITICAL | Deadline has passed without completion |
| `DEADLINE_TODAY` | CONCERN | Critical deadline due today |
| `DEADLINE_APPROACHING` | WARNING | Deadline within 48 hours |
| `UNRESPONSIVE_PARTY` | CONCERN | Party hasn't responded in 48+ hours |
| `MISSING_PARTY_CONTACT` | CONCERN | Critical party has no contact info |
| `COMMUNICATION_GAP` | WARNING | No contact with party in 7+ days |
| `MISSING_DOCUMENT` | WARNING/CONCERN | Required document not uploaded |
| `PENDING_SIGNATURE` | WARNING | Document awaiting signature 48+ hours |
| `ESCROW_NOT_RECEIVED` | CRITICAL | Escrow past due date |
| `FINANCING_UNCERTAIN` | CONCERN | Financing not confirmed near contingency |
| `TITLE_ISSUE` | CONCERN/CRITICAL | Problem identified in title search |
| `MULTIPLE_EXTENSIONS` | WARNING | Deal has had 2+ deadline extensions |
| `CLOSING_COMPRESSED` | CONCERN | Less than 14 days to closing with open items |

## Integration Points

### Invokes
- `party-responsiveness` - For detailed party response analysis
- `timeline-analysis` - For deadline-specific assessment
- `proactive-alerts` - To generate alerts for critical issues

### Invoked By
- `daily-planning` - Morning risk roundup
- `weekly-summary` - Risk trend analysis
- Dashboard data refresh
- Agent voice queries

### Database Tables
- `risk_assessments` - Store assessment history
- `risk_flags` - Individual flag records
- `deals` - Deal data
- `deadlines` - Deadline statuses
- `parties` - Party contact and response data
- `communications` - Contact history

## Error Handling

| Error | Cause | Response |
|-------|-------|----------|
| `DEAL_NOT_FOUND` | Invalid deal ID | "I couldn't find that deal. Can you give me the address?" |
| `INSUFFICIENT_DATA` | New deal with no history | "This deal is too new for a full risk assessment. I'll have better data in a few days." |
| `ASSESSMENT_STALE` | Cached assessment too old | Force recalculation |

## Quality Checklist

- [x] Weights all risk categories appropriately
- [x] Applies compounding multipliers for multiple issues
- [x] Generates actionable recommendations
- [x] Tracks trend over time
- [x] Provides severity-appropriate voice responses
- [x] Links flags to specific parties/deadlines
- [x] Runs automatically daily
- [x] Stores history for trend analysis
- [x] Integrates with alert system
- [x] Handles edge cases (new deals, closed deals)

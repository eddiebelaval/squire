# Skill: Analyze Inspection Report

**Category:** Negotiation
**Priority:** P0
**Approval Required:** Yes (before sharing findings with client or other party)

## Purpose

Parse, categorize, and summarize inspection findings from uploaded home inspection reports. This skill extracts actionable items, identifies safety hazards, and prepares findings for negotiation strategy. This is typically the first step after receiving an inspection report.

## Triggers

### Voice Commands
- "Analyze this inspection report"
- "What did the inspection find?"
- "Review the inspection for [address]"
- "Parse the inspection report"
- "Summarize inspection findings"
- "What are the major issues from the inspection?"

### System Events
- Inspection report PDF uploaded to deal
- Inspection deadline approaching (prompt for analysis if report uploaded)
- Agent requests inspection summary

## Required Inputs

| Input | Type | Required | Source | Description |
|-------|------|----------|--------|-------------|
| `dealId` | string | Yes | context | The deal to associate findings with |
| `inspectionReport` | File | Yes | upload/document | PDF of inspection report |

## Optional Inputs

| Input | Type | Default | Source | Description |
|-------|------|---------|--------|-------------|
| `inspectorName` | string | null | extracted | Name of inspector |
| `inspectorLicense` | string | null | extracted | FL license number |
| `inspectionDate` | Date | null | extracted | Date inspection was performed |
| `inspectionCompany` | string | null | extracted | Inspection company name |
| `focusAreas` | string[] | all | agent | Specific areas to prioritize |
| `includeCosmetic` | boolean | false | agent | Include cosmetic/minor items |

## Output Schema

```typescript
{
  success: boolean;
  actionTaken: string;
  result: {
    summary: {
      totalFindings: number;
      criticalCount: number;
      majorCount: number;
      minorCount: number;
      informationalCount: number;
      estimatedTotalCost: {
        low: number;
        high: number;
      };
    };
    findings: InspectionFinding[];
    categories: {
      category: string;
      findingCount: number;
      severity: 'critical' | 'major' | 'minor';
      estimatedCost: { low: number; high: number };
    }[];
    inspectionMeta: {
      inspectorName: string;
      inspectorLicense: string;
      inspectionDate: Date;
      company: string;
      reportType: string;
    };
    aiAnalysis: {
      negotiationLeverage: 'strong' | 'moderate' | 'weak';
      topConcerns: string[];
      recommendedStrategy: string;
      redFlags: string[];
    };
    nextSteps: string[];
  };
  requiresApproval: true;
  approvalContext: {
    action: "Share analysis with client";
    stakes: "high";
    reversible: false;
  };
}

// InspectionFinding type
interface InspectionFinding {
  id: string;
  category: 'structural' | 'roof' | 'electrical' | 'plumbing' | 'hvac' |
            'foundation' | 'exterior' | 'interior' | 'insulation' |
            'ventilation' | 'safety' | 'appliances' | 'pool' | 'other';
  location: string;
  issue: string;
  description: string;
  severity: 'critical' | 'major' | 'minor' | 'informational';
  safetyHazard: boolean;
  codeViolation: boolean;
  estimatedCost: {
    low: number;
    high: number;
  };
  repairTimeframe: 'immediate' | 'within_30_days' | 'within_year' | 'monitor';
  photos: string[];
  inspectorRecommendation: string;
  negotiationPriority: 'must_address' | 'should_address' | 'optional';
}
```

## Execution Flow

```
START
  │
  ├─── 1. Validate inputs
  │    ├── Verify deal exists and is active
  │    ├── Verify inspection report is valid PDF
  │    └── Check inspection period status
  │
  ├─── 2. Extract report metadata
  │    ├── Inspector name and license
  │    ├── Inspection date
  │    ├── Property address (verify matches deal)
  │    └── Report format/type
  │
  ├─── 3. Parse inspection findings
  │    ├── OCR if needed (scanned reports)
  │    ├── Identify sections and categories
  │    ├── Extract individual findings
  │    └── Capture photos and references
  │
  ├─── 4. Categorize each finding
  │    ├── Assign category (structural, electrical, etc.)
  │    ├── Assign severity (critical, major, minor, informational)
  │    ├── Flag safety hazards
  │    ├── Flag code violations
  │    └── Assign negotiation priority
  │
  ├─── 5. Estimate repair costs
  │    ├── Use Florida contractor pricing database
  │    ├── Apply regional adjustments (South FL vs. North FL)
  │    ├── Calculate low/high range
  │    └── Flag items needing specialist quotes
  │
  ├─── 6. Generate AI analysis
  │    ├── Assess overall negotiation leverage
  │    ├── Identify top concerns for client
  │    ├── Recommend strategy (request repairs vs. credit)
  │    ├── Identify red flags (deal-breakers)
  │    └── Consider As-Is contract implications
  │
  ├─── 7. Store analysis
  │    ├── Link to deal
  │    ├── Store extracted findings
  │    └── Create searchable index
  │
  ├─── 8. Prepare approval request
  │    ├── Create summary for agent review
  │    ├── Highlight critical items
  │    └── Queue for approval before sharing
  │
  ├─── 9. Log action
  │    └── action_type: 'inspection_analyzed'
  │
  └─── 10. Return findings (pending approval)
```

## Severity Classification Rules

| Severity | Criteria | Examples |
|----------|----------|----------|
| **Critical** | Safety hazard, immediate risk, major system failure | Active leaks, electrical hazards, structural failure, mold, no HVAC |
| **Major** | Significant repair needed, system at end of life | Roof replacement, HVAC over 15yrs, water heater issues, foundation cracks |
| **Minor** | Functional but needs attention | Worn outlets, minor leaks fixed, cosmetic damage, weatherstripping |
| **Informational** | FYI, maintenance recommended | Clean dryer vent, service HVAC, regrade around foundation |

## Category Definitions

| Category | Includes | Florida Considerations |
|----------|----------|----------------------|
| Structural | Foundation, framing, load-bearing walls | Hurricane straps, tie-downs |
| Roof | Shingles, flashing, underlayment, decking | Hurricane damage, 4-point inspection items |
| Electrical | Panel, wiring, outlets, grounding | Aluminum wiring (1970s), FPE panels |
| Plumbing | Pipes, fixtures, water heater, water pressure | Polybutylene pipes, cast iron drain lines |
| HVAC | AC, furnace, ductwork, thermostat | AC critical in FL, hurricane shutoffs |
| Foundation | Slab, crawlspace, piers | Sinkholes in Central FL |
| Exterior | Siding, windows, doors, paint | Stucco cracks, hurricane windows |
| Interior | Walls, floors, ceilings, doors | Drywall cracks, floor leveling |
| Insulation | Attic, walls, crawlspace | FL energy code requirements |
| Safety | Smoke/CO detectors, railings, GFCI | Pool barriers, hurricane safety |
| Pool | Equipment, surface, barriers | FL pool safety act compliance |

## Negotiation Priority Logic

```typescript
function calculateNegotiationPriority(finding: InspectionFinding): Priority {
  // Must address: safety + structural + code
  if (finding.safetyHazard || finding.codeViolation) {
    return 'must_address';
  }
  if (finding.severity === 'critical') {
    return 'must_address';
  }
  if (finding.category === 'structural' && finding.severity === 'major') {
    return 'must_address';
  }

  // Should address: major items with significant cost
  if (finding.severity === 'major' && finding.estimatedCost.high > 2000) {
    return 'should_address';
  }

  // Optional: everything else
  return 'optional';
}
```

## Voice Response

**After analysis (awaiting approval):**
> "I've analyzed the inspection report for 123 Main Street. Here's what I found:
>
> **Critical Items (2):** The roof has active leaks requiring immediate repair, estimated $3,500 to $5,500. The electrical panel is an FPE Stab-Lok, which is a known fire hazard - replacement is $2,000 to $3,000.
>
> **Major Items (5):** HVAC is 18 years old and showing signs of failure. Water heater is past its life expectancy. There are several plumbing issues totaling $1,500 to $2,500.
>
> **Minor Items (8):** Mostly cosmetic and maintenance items.
>
> **Total estimated repairs: $12,000 to $18,000.**
>
> Given the critical safety issues, I'd recommend requesting repairs for the electrical panel and roof, plus a credit for the aging systems. You have moderate to strong negotiation leverage here.
>
> Would you like me to share this analysis with your client for approval before we proceed?"

**If inspection period is expiring:**
> "Heads up - the inspection period ends in 2 days. Let me analyze this quickly so you have time to respond."

## Error Handling

| Error | Cause | Response |
|-------|-------|----------|
| `UNREADABLE_REPORT` | Poor PDF quality | "This report is hard to read. Can you upload a clearer copy, or I can do my best with what's here." |
| `UNSUPPORTED_FORMAT` | Not a PDF | "I need the inspection report as a PDF. Can you convert it?" |
| `ADDRESS_MISMATCH` | Report address differs | "This inspection is for a different address. Are you sure this is the right report?" |
| `INSPECTION_EXPIRED` | Past inspection period | "Note: The inspection period has already ended. You may still want this analysis, but negotiation options may be limited." |
| `NO_FINDINGS_DETECTED` | Could not parse findings | "I couldn't automatically parse this report format. Would you like to manually enter the key findings?" |

## Approval Gate

**This skill requires human approval before:**
1. Sharing analysis with buyer/seller
2. Using findings to generate repair request
3. Providing negotiation recommendations to client

**Approval Dialog:**
```
┌─────────────────────────────────────────────────────────────┐
│ APPROVAL REQUIRED: Inspection Analysis                       │
├─────────────────────────────────────────────────────────────┤
│ I've analyzed the inspection report for 123 Main Street.     │
│                                                              │
│ Summary:                                                     │
│ • 2 Critical items ($5,500 - $8,500)                        │
│ • 5 Major items ($6,500 - $9,500)                           │
│ • 8 Minor items                                             │
│ • Total: $12,000 - $18,000                                  │
│                                                              │
│ Recommended strategy: Request electrical panel + roof        │
│ repairs, plus credit for aging HVAC.                        │
│                                                              │
│ [Approve & Share with Client] [Review Details] [Edit First] │
└─────────────────────────────────────────────────────────────┘
```

## Integration Points

### Triggers After Analysis
- Ready input for `prioritize-repairs` skill
- Ready input for `calculate-repair-credit` skill
- Ready input for `draft-repair-request` skill
- Update deal with inspection status

### Database Tables
- `inspection_reports` - Report metadata and storage
- `inspection_findings` - Individual findings
- `action_log` - Audit entry

### Related Skills
- `prioritize-repairs` - Next step after analysis
- `calculate-repair-credit` - Estimate credit amounts
- `draft-repair-request` - Generate formal request

## Florida-Specific Considerations

1. **4-Point Inspection Items**: Flag roof, electrical, plumbing, HVAC for insurance purposes
2. **Wind Mitigation**: Note hurricane protection features (impact windows, roof tie-downs)
3. **As-Is Contracts**: Buyer can still cancel but can't demand repairs
4. **Pool Safety Act**: Verify pool barrier compliance
5. **Sinkholes**: Flag any foundation or geological concerns (especially Central FL)
6. **Termite Damage**: Common in FL, note any WDO (Wood Destroying Organism) findings
7. **Chinese Drywall**: Flag if property built 2004-2009 with drywall concerns

## Quality Checklist

- [x] Parses standard inspection report formats
- [x] Handles OCR for scanned reports
- [x] Categorizes findings consistently
- [x] Applies Florida-specific considerations
- [x] Estimates costs using regional pricing
- [x] Identifies safety hazards and code violations
- [x] Assigns negotiation priorities
- [x] Provides AI-powered strategy recommendations
- [x] Requires approval before sharing with client
- [x] Creates audit trail
- [x] Handles inspection period timing
- [x] Integrates with repair request workflow

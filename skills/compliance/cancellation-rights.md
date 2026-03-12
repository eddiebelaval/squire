# Skill: Florida Cancellation Rights

**Category:** Compliance
**Priority:** P0
**Approval Required:** No

## Purpose

Determine when and how parties can legally cancel a Florida real estate contract. Covers contingency-based cancellations, statutory rescission rights, default-based terminations, and mutual cancellation procedures.

## Legal Authority

- **FAR/BAR Contract** - Contingency and termination provisions
- **Florida Statutes §718.503** - Condo rescission (15-day right)
- **Florida Statutes §720.401** - HOA rescission (3-day right)
- **Florida Statutes §501.165** - Home solicitation sales (3-day right)
- **TILA (12 CFR 1026.23)** - Refinance rescission (3-day right)
- **General Contract Law** - Default remedies

## Triggers

### Voice Commands
- "Can the buyer cancel?"
- "How do we get out of this contract?"
- "What are the cancellation rights?"
- "When can the seller terminate?"
- "Is it too late to cancel?"
- "What happens if the buyer backs out?"

### Programmatic
- Cancellation requested
- Contingency period status check
- Default notice sent
- Compliance check running
- Contract termination needed

## Required Inputs

| Input | Type | Required | Source | Description |
|-------|------|----------|--------|-------------|
| `dealId` | UUID | Yes | context | Deal to check |
| `cancellingParty` | string | Yes | request | 'buyer' or 'seller' |
| `currentDate` | Date | Yes | system | Current date |

## Optional Inputs

| Input | Type | Default | Source | Description |
|-------|------|---------|--------|-------------|
| `cancellationReason` | string | null | request | Why cancelling |
| `contingencyStatus` | object | null | deal | Status of all contingencies |
| `depositStatus` | string | null | deal | Escrow status |

## Cancellation Rights Matrix

### Buyer Cancellation Rights

| Right | Timeframe | Condition | Deposit Outcome |
|-------|-----------|-----------|-----------------|
| **Inspection Contingency** | Inspection period | Any reason during period | Full refund |
| **Financing Contingency** | Per contract | Loan denied in good faith | Full refund |
| **Appraisal Contingency** | Per contract | Appraises low, can't agree | Full refund |
| **Condo Rescission** | 15 days | After receiving condo docs | Full refund |
| **HOA Rescission** | 3 days | After receiving HOA docs | Full refund |
| **Title Defect** | Per contract | Uncurable title issue | Full refund |
| **Seller Default** | Any time | Seller fails to perform | Full refund + damages |
| **Mutual Agreement** | Any time | Both parties agree | Per agreement |
| **No Right** | After contingencies | Buyer simply changes mind | Forfeits deposit |

### Seller Cancellation Rights

| Right | Timeframe | Condition | Outcome |
|-------|-----------|-----------|---------|
| **Buyer Default** | After deadline | Buyer fails to perform | Keep deposit (if Para 16a) |
| **Mutual Agreement** | Any time | Both parties agree | Per agreement |
| **Title Cannot Clear** | Per contract | Seller can't deliver marketable title | Contract void |
| **Property Destruction** | Before closing | Casualty loss | May terminate |

## Statutory Rescission Rights

### Condo Rescission - §718.503

```
RIGHT: Buyer may cancel within 15 days of receiving:
─────────────────────────────────────────────────────
- Declaration of Condominium
- Articles of Incorporation
- Bylaws
- Rules and Regulations
- Most recent year-end financial statement
- FAQ sheet
- Governance form (if 100+ units)

EXERCISE: Written notice of rescission to seller
OUTCOME: Full deposit refund, no penalty
```

### HOA Rescission - §720.401

```
RIGHT: Buyer may cancel within 3 days of receiving:
─────────────────────────────────────────────────────
- HOA Disclosure Summary (§720.401 form)
- Governing documents (if requested)

EXERCISE: Written notice of rescission to seller
OUTCOME: Full deposit refund, no penalty
NOTE: 3 days = calendar days, excludes date of receipt
```

### Additional Statutory Rights

| Statute | Right | Timeframe | Applies To |
|---------|-------|-----------|------------|
| §501.165 | Home Solicitation | 3 days | Door-to-door sales |
| TILA | Refinance | 3 days | Refinance of homestead |
| Interstate Land Sales | ILSFDA | 7 days | Certain subdivisions |

## Execution Flow

```
START
  │
  ├─── 1. Load deal status
  │    ├── Get all contingencies and deadlines
  │    ├── Get current date
  │    └── Identify cancelling party
  │
  ├─── 2. Check statutory rescission rights
  │    ├── Is this a condo? → Check 15-day period
  │    ├── Is there an HOA? → Check 3-day period
  │    ├── Home solicitation? → Check 3-day period
  │    └── Calculate if within window
  │
  ├─── 3. Check contingency rights
  │    ├── Inspection period → Is it still open?
  │    ├── Financing contingency → Still active?
  │    ├── Appraisal contingency → Still active?
  │    ├── Sale contingency → Still active?
  │    └── Any contingency met? Waived? Expired?
  │
  ├─── 4. Check for other party default
  │    ├── Has other party missed deadline?
  │    ├── Has other party failed to perform?
  │    └── Has notice been given?
  │
  ├─── 5. Assess deposit consequences
  │    ├── Rightful cancellation → Deposit returned
  │    ├── Wrongful cancellation → Deposit at risk
  │    └── Mutual cancellation → Per agreement
  │
  ├─── 6. Generate cancellation guidance
  │    ├── Can cancel? Yes/No
  │    ├── Method to cancel
  │    ├── Deadline to act
  │    └── Deposit outcome
  │
  └─── RETURN cancellation_rights
```

## Output

```typescript
{
  success: true,
  actionTaken: "Assessed cancellation rights for buyer",
  result: {
    party: "buyer",
    dealId: "deal_123",
    currentDate: "2026-01-25",
    canCancel: true,
    cancellationRights: [
      {
        right: "inspection_contingency",
        status: "active",
        deadline: "2026-01-30",
        daysRemaining: 5,
        method: "Written notice to seller before deadline",
        depositOutcome: "Full refund",
        noReasonRequired: true
      },
      {
        right: "financing_contingency",
        status: "active",
        deadline: "2026-02-14",
        daysRemaining: 20,
        method: "Loan denial letter + written cancellation",
        depositOutcome: "Full refund if denied in good faith",
        noReasonRequired: false
      }
    ],
    expiredRights: [
      {
        right: "hoa_rescission",
        expired: "2026-01-18",
        reason: "3-day period passed after HOA docs received"
      }
    ],
    noCurrentRight: [
      {
        situation: "Buyer simply changed mind",
        consequence: "Forfeits deposit to seller under Para 16(a)",
        depositAtRisk: 15000
      }
    ],
    recommendation: {
      if: "Buyer wants out",
      then: "Cancel before inspection deadline (Jan 30)",
      method: "Send written cancellation per FAR/BAR Para 12",
      outcome: "Full deposit refund, no questions asked"
    },
    documents: [
      {
        name: "Inspection Period Cancellation Notice",
        template: "cancellation_inspection_period.pdf"
      }
    ]
  }
}
```

## Voice Response

**Active Cancellation Right:**
> "The buyer can still cancel. The inspection period runs through January 30th - that's 5 days from now. To cancel, send written notice to the seller before the deadline. No reason needed, and the buyer gets their full deposit back. Want me to prepare the cancellation notice?"

**No Current Right:**
> "The buyer doesn't have a clear right to cancel right now. The inspection period ended, they have conventional financing so no FHA rescission, and the seller hasn't defaulted. If the buyer walks away, they'll likely forfeit their $15,000 deposit to the seller under the liquidated damages clause. Want to explore options?"

**Statutory Rescission:**
> "This is a condo sale, so the buyer has a 15-day rescission right under Florida Statute 718.503. The condo docs were received on January 10th, so the rescission period ends January 25th - that's today. If the buyer wants to cancel, they need to send written notice by end of day today. After that, this right expires."

**Seller Default:**
> "The seller missed the deadline to provide clear title - that's a seller default. The buyer can terminate the contract and get their full deposit back. Additionally, the buyer may be entitled to actual damages for any expenses incurred. Do you want to send a termination notice or give the seller more time?"

## Cancellation Process

### To Exercise Contingency Cancellation

```
STEP 1: Verify right is still active
        └── Check deadline hasn't passed

STEP 2: Prepare written notice
        └── Reference contract paragraph
        └── State intention to cancel
        └── Request deposit return

STEP 3: Deliver properly
        └── Per contract's notice provisions
        └── Email if contract allows electronic
        └── Keep proof of delivery

STEP 4: Follow up on deposit
        └── Escrow agent releases to buyer
        └── Both parties may need to sign release
```

### To Exercise Statutory Rescission (Condo/HOA)

```
STEP 1: Calculate deadline from document receipt
        └── Condo: 15 days from receipt
        └── HOA: 3 days from receipt

STEP 2: Send written rescission notice
        └── State exercising statutory right
        └── Cite statute (§718.503 or §720.401)
        └── Demand deposit return

STEP 3: Deposit automatically refundable
        └── Seller must return without penalty
```

## Error Handling

| Error | Cause | Response |
|-------|-------|----------|
| `PARTY_NOT_SPECIFIED` | Don't know who's cancelling | "Is the buyer or seller looking to cancel?" |
| `DEADLINE_UNKNOWN` | Can't determine contingency status | "When did the inspection period end? I need to check if rights are still active." |
| `CONDO_DOCS_DATE_UNKNOWN` | Don't know when docs received | "When did the buyer receive the condo documents? That starts the 15-day rescission period." |
| `REASON_NEEDED` | Cancellation reason required | "What's the reason for cancelling? That affects which rights apply." |

## Integration Points

### Related Skills
- `time-is-of-the-essence` - Deadline enforcement
- `escrow-rules` - Deposit handling on cancellation
- `deposit-dispute-rules` - If parties disagree
- `florida-far-bar-rules` - Contract provisions

### Database Tables
- `deals` - Deal status and contingencies
- `deadlines` - Contingency deadlines
- `documents` - Cancellation notices
- `action_log` - Audit trail

### Document Templates
- Inspection Period Cancellation Notice
- Financing Contingency Cancellation
- Condo Rescission Notice
- HOA Rescission Notice
- Mutual Release and Cancellation
- Default Termination Notice

## Quality Checklist

- [x] Covers all contingency cancellation rights
- [x] Includes Florida statutory rescission rights
- [x] Calculates deadline status accurately
- [x] Identifies deposit consequences
- [x] Provides clear exercise methods
- [x] Cites statutes and contract provisions
- [x] Offers document templates
- [x] Handles mutual cancellation
- [x] Voice-friendly responses
- [x] Recommends next steps

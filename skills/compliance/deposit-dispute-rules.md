# Skill: Florida Deposit Dispute Resolution

**Category:** Compliance
**Priority:** P0
**Approval Required:** No

## Purpose

Guide resolution of escrow deposit disputes in Florida real estate transactions. When buyer and seller disagree on who gets the deposit, this skill outlines the legal procedures, timelines, and options under Florida law and FREC rules.

## Legal Authority

- **FREC Rule 61J2-14.008** - Escrow accounts
- **FREC Rule 61J2-14.009** - Conflicting demands/good faith doubt
- **FREC Rule 61J2-14.010** - Escrow disbursement procedures
- **FREC Rule 61J2-14.012** - Escrow disbursement order
- **Florida Statutes §475.25(1)(d)** - Failure to account for funds
- **Florida Statutes Chapter 44** - Mediation (FAR/BAR required)
- **FAR/BAR Contract Paragraph 17** - Dispute Resolution

## Triggers

### Voice Commands
- "There's a dispute over the deposit"
- "Buyer and seller both want the escrow"
- "How do we resolve an escrow dispute?"
- "The buyer won't sign the release"
- "What happens to disputed funds?"
- "Can we interplead the deposit?"

### Programmatic
- Conflicting demands received
- Escrow holder flags dispute
- Contract terminated with contested deposit
- Dispute resolution requested
- Compliance check with deposit issue

## Required Inputs

| Input | Type | Required | Source | Description |
|-------|------|----------|--------|-------------|
| `dealId` | UUID | Yes | context | Deal with dispute |
| `escrowAmount` | number | Yes | deal | Amount in dispute |
| `escrowHolder` | string | Yes | deal | Who holds funds |
| `claimantBuyer` | boolean | Yes | dispute | Buyer claims deposit |
| `claimantSeller` | boolean | Yes | dispute | Seller claims deposit |

## Optional Inputs

| Input | Type | Default | Source | Description |
|-------|------|---------|--------|-------------|
| `disputeReason` | string | null | dispute | Cause of dispute |
| `buyerBasis` | string | null | dispute | Buyer's claim basis |
| `sellerBasis` | string | null | dispute | Seller's claim basis |
| `escrowHolderType` | string | null | deal | Broker, title, attorney |
| `contractMediationClause` | boolean | true | contract | FAR/BAR mediation required |

## Dispute Resolution Timeline (FREC Rules)

### When Broker Holds Escrow

```
DAY 0: CONFLICTING DEMANDS RECEIVED
─────────────────────────────────────
Broker receives demands from both buyer and seller
for the same escrow funds.

WITHIN 30 BUSINESS DAYS: CHOOSE RESOLUTION METHOD
─────────────────────────────────────────────────
Broker must notify FREC of dispute and select ONE:

OPTION 1: Mediation (if contract requires)
OPTION 2: Arbitration (if parties agree)
OPTION 3: Interpleader (court holds funds)
OPTION 4: FREC Escrow Disbursement Order

WITHIN 10 BUSINESS DAYS: IMPLEMENT CHOSEN METHOD
────────────────────────────────────────────────
Take action to implement the selected resolution.

PENALTY FOR FAILURE:
─────────────────────
Broker who fails to follow these rules may have
license suspended or revoked under §475.25(1)(d).
```

### Timeline Summary

| Event | Deadline | Consequence of Miss |
|-------|----------|---------------------|
| Conflicting demands received | Day 0 | Clock starts |
| Notify FREC of dispute | 30 business days | License violation |
| Choose resolution method | 30 business days | License violation |
| Implement resolution | 10 more business days | License violation |
| Complete resolution | Varies by method | Ongoing obligation |

## Resolution Methods

### Method 1: Mediation (FAR/BAR Default)

```
FAR/BAR PARAGRAPH 17: MEDIATION REQUIRED
─────────────────────────────────────────
Before any lawsuit (except for emergency relief),
parties must attempt mediation per Florida Rules.

PROCESS:
1. Select mediator (certified by FL Supreme Court)
2. Schedule mediation within 45 days
3. Attend in good faith
4. Mediator helps parties reach agreement
5. If agreement: Deposit disbursed per terms
6. If no agreement: May proceed to arbitration/court

COST: Split equally unless otherwise agreed
TIME: Usually 30-60 days
SUCCESS RATE: ~70% for real estate disputes
```

### Method 2: Arbitration

```
VOLUNTARY ARBITRATION
─────────────────────
Both parties must agree to arbitrate.
NOT required by FAR/BAR (only mediation is required).

PROCESS:
1. Parties sign arbitration agreement
2. Select arbitrator (usually one)
3. Each side presents case
4. Arbitrator issues binding decision
5. Deposit disbursed per decision

COST: Higher than mediation
TIME: 60-90 days typically
BINDING: Usually yes (limited appeal rights)
```

### Method 3: Interpleader

```
COURT INTERPLEADER ACTION
─────────────────────────
Escrow holder files lawsuit asking court to decide.

PROCESS:
1. Holder files interpleader complaint
2. Deposits funds with court
3. Holder released from liability
4. Buyer and seller litigate
5. Court awards funds to prevailing party

COST: Holder's attorney fees from deposit (typically)
TIME: 6-12 months or more
OUTCOME: Judge or jury decides
```

### Method 4: FREC Escrow Disbursement Order (EDO)

```
FREC ADMINISTRATIVE PROCESS
───────────────────────────
Available when broker holds escrow.
FREC investigates and issues disbursement order.

PROCESS:
1. Broker requests EDO from FREC
2. Submits all documentation
3. FREC investigates (may take months)
4. FREC issues order
5. Broker disburses per order

COST: No direct cost (but time-intensive)
TIME: 3-6 months typically
OUTCOME: Administrative determination
```

## Execution Flow

```
START
  │
  ├─── 1. Confirm dispute exists
  │    ├── Both parties claiming deposit?
  │    ├── What are the competing claims?
  │    └── Document basis for each claim
  │
  ├─── 2. Identify escrow holder
  │    ├── Broker → FREC rules apply directly
  │    ├── Title Company → Follow their procedures
  │    ├── Attorney → Bar rules apply
  │    └── Other → General interpleader rules
  │
  ├─── 3. Check contract dispute provisions
  │    ├── FAR/BAR → Mediation required first
  │    ├── Custom contract → Check provisions
  │    └── No mediation clause → Skip mediation
  │
  ├─── 4. Assess claim strength
  │    ├── Who appears to have stronger claim?
  │    ├── What does contract language say?
  │    ├── What contingencies were in play?
  │    └── Was there a clear default?
  │
  ├─── 5. Recommend resolution path
  │    ├── Clear-cut case → Try direct negotiation first
  │    ├── Mediation required → Set up mediation
  │    ├── Broker holding → Consider EDO
  │    └── Complex dispute → May need interpleader
  │
  ├─── 6. Calculate timeline obligations
  │    └── If broker holds: 30 business day FREC deadline
  │
  └─── RETURN dispute_resolution_plan
```

## Common Dispute Scenarios

### Scenario 1: Inspection Period Dispute

```
SITUATION: Buyer cancelled during inspection period.
           Seller claims buyer didn't cancel properly.

ANALYSIS:
─────────
- Was cancellation within inspection period? Check date/time.
- Was cancellation in writing? Check documentation.
- Did buyer give proper notice? Per contract terms.

LIKELY OUTCOME:
─────────
If properly cancelled: Buyer gets deposit.
If improper cancellation: Dispute goes to mediation.
```

### Scenario 2: Financing Denial Dispute

```
SITUATION: Buyer's loan denied. Seller claims buyer
           didn't apply in good faith.

ANALYSIS:
─────────
- Did buyer apply timely? Check loan application date.
- Did buyer provide required docs? Check lender records.
- Was denial legitimate? Review denial letter.
- Any suspicious timing? (e.g., denied after contract change)

LIKELY OUTCOME:
─────────
Legitimate denial: Buyer gets deposit.
Bad faith application: Seller may prevail.
```

### Scenario 3: Buyer Just Walked Away

```
SITUATION: Buyer stopped responding after inspection
           period. No contingency right to cancel.

ANALYSIS:
─────────
- All contingencies waived or expired? Check dates.
- Any seller default? Check seller's performance.
- Liquidated damages clause? Usually Para 16(a).

LIKELY OUTCOME:
─────────
If buyer default: Seller gets deposit (up to contract limit).
If seller contributed: Mediation needed.
```

## Output

```typescript
{
  success: true,
  actionTaken: "Assessed deposit dispute for 123 Main St",
  result: {
    dispute: {
      escrowAmount: 15000,
      holder: "ABC Title Company",
      holderType: "title_company",
      buyerClaim: "Cancelled within inspection period",
      sellerClaim: "Cancellation was after period expired"
    },
    analysis: {
      inspectionDeadline: "2026-01-30T23:59:00",
      cancellationReceived: "2026-01-30T23:45:00",
      withinPeriod: true,
      recommendation: "Buyer's cancellation appears timely"
    },
    contractRequirements: {
      mediationRequired: true,
      reference: "FAR/BAR Paragraph 17",
      beforeLitigation: true
    },
    resolution: {
      recommendedPath: "Negotiate based on timeline evidence",
      if_unresolved: "Mediation required per contract",
      brokerDeadline: null, // Title company holds
      options: [
        {
          method: "Direct Negotiation",
          timeframe: "1-2 weeks",
          cost: "None",
          recommendation: "Try first - evidence supports buyer"
        },
        {
          method: "Mediation",
          timeframe: "30-45 days",
          cost: "~$500-1000 split",
          recommendation: "If negotiation fails"
        },
        {
          method: "Title Company Interpleader",
          timeframe: "6-12 months",
          cost: "Legal fees from deposit",
          recommendation: "Last resort"
        }
      ]
    },
    nextSteps: [
      "Request cancellation timestamp documentation",
      "Show evidence to seller's agent",
      "If disputed, propose mediation",
      "Title company will hold pending resolution"
    ],
    warnings: [
      "Do not pressure title company to release without agreement",
      "Document all communications",
      "Consider attorney if mediation fails"
    ]
  }
}
```

## Voice Response

**Clear-Cut Case:**
> "Looking at the timeline, the buyer cancelled at 11:45 PM on January 30th, and the inspection period ended at 11:59 PM. That's within the period, so the buyer should get their deposit back. I'd share this evidence with the seller's agent and request a mutual release. If they still disagree, you'll need to go to mediation per the FAR/BAR contract."

**Disputed Case:**
> "Both sides have claims on the $15,000 deposit. The buyer says they cancelled in time, the seller says they didn't. Since this is a FAR/BAR contract, you're required to try mediation before going to court. I recommend setting up mediation within 30 days - success rate is about 70% for these disputes. Want me to help find a certified mediator?"

**Broker Holding Funds:**
> "Since a broker is holding the escrow, FREC rules kick in. The broker has 30 business days to choose a resolution method and notify FREC. Options are: request an EDO from FREC, set up mediation, or file interpleader. Given the complexity here, mediation might be the fastest path. The broker needs to act within the FREC deadline or risk a license violation."

## Error Handling

| Error | Cause | Response |
|-------|-------|----------|
| `NO_DISPUTE` | Only one party claiming | "This isn't a dispute - only one party is claiming the deposit. Follow normal release procedures." |
| `HOLDER_UNKNOWN` | Don't know who holds funds | "Who's holding the escrow? That affects which rules apply." |
| `BASIS_UNCLEAR` | No claim basis provided | "What's the seller's basis for claiming the deposit? I need to understand both sides." |
| `CONTRACT_MISSING` | Can't check mediation clause | "I need the contract to check the dispute resolution provisions." |

## Integration Points

### Related Skills
- `escrow-rules` - General escrow handling
- `cancellation-rights` - When cancellation is valid
- `time-is-of-the-essence` - Deadline enforcement
- `audit-trail` - Document all dispute communications

### Database Tables
- `deals` - Deal and escrow info
- `escrow_deposits` - Deposit status
- `disputes` - Dispute tracking
- `action_log` - All communications

### External Resources
- FREC EDO request forms
- Florida certified mediator directory
- Title company interpleader procedures

## Quality Checklist

- [x] Explains all resolution methods
- [x] Cites FREC rules and deadlines
- [x] Identifies holder-specific procedures
- [x] Analyzes claim strength
- [x] Recommends resolution path
- [x] Calculates FREC deadlines (if broker)
- [x] References mediation requirement
- [x] Provides next steps
- [x] Voice-friendly responses
- [x] Warns about compliance risks

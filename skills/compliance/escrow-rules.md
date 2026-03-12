# Skill: Florida Escrow Deposit Rules

**Category:** Compliance
**Priority:** P0
**Approval Required:** No

## Purpose

Ensure proper handling of earnest money deposits (escrow) in Florida real estate transactions. Covers deposit timelines, holder requirements, disbursement rules, and dispute resolution procedures under Florida law.

## Legal Authority

- **Florida Statutes §475.25** - License law violations (escrow)
- **Florida Statutes §475.25(1)(d)** - Failure to account for funds
- **Florida Statutes §475.25(1)(k)** - Escrow account requirements
- **FREC Rule 61J2-14.008** - Escrow accounts
- **FREC Rule 61J2-14.009** - Conflicting demands/good faith doubt
- **FREC Rule 61J2-14.010** - Escrow disbursement procedures
- **FAR/BAR Contract Paragraph 5** - Deposit terms

## Triggers

### Voice Commands
- "When is the escrow due?"
- "Where should the deposit go?"
- "Is the escrow in?"
- "Who's holding the deposit?"
- "How do I handle an escrow dispute?"
- "Can the buyer get their deposit back?"

### Programmatic
- Deal created with escrow amount
- Deposit deadline approaching
- Deposit status update
- Contract cancelled
- Dispute notification
- Compliance check running

## Required Inputs

| Input | Type | Required | Source | Description |
|-------|------|----------|--------|-------------|
| `dealId` | UUID | Yes | context | Deal with escrow |
| `escrowAmount` | number | Yes | contract | Deposit amount |
| `effectiveDate` | Date | Yes | contract | Contract effective date |

## Optional Inputs

| Input | Type | Default | Source | Description |
|-------|------|---------|--------|-------------|
| `escrowHolder` | string | 'title_company' | contract | Who holds funds |
| `escrowHolderLicense` | string | null | contract | License number |
| `additionalDeposit` | number | null | contract | Second deposit amount |
| `additionalDepositDate` | Date | null | contract | When additional due |
| `depositMethod` | string | 'wire' | transaction | How deposited |
| `depositStatus` | string | 'pending' | tracking | Current status |

## Escrow Holder Requirements

### Who Can Hold Escrow in Florida

| Holder Type | Requirement | Common Use |
|-------------|-------------|------------|
| **Title Company/Attorney** | Licensed | Most common |
| **Real Estate Broker** | Active FL license | Listing broker |
| **Florida-licensed Escrow Agent** | Licensed per Ch. 627 | Specialized |
| **Builder (new construction)** | With conditions | New builds |

### Broker Escrow Account Rules (FREC)

```
RULE: Broker Must Deposit Within 3 Business Days
─────────────────────────────────────────────────
If broker receives deposit, must place in escrow account by end
of 3rd business day following receipt.

RULE: Segregated Account Required
─────────────────────────────────
Escrow funds must be in a separate, clearly labeled account.
Cannot be commingled with broker's operating funds.

RULE: Interest-Bearing Option
─────────────────────────────
May be in interest-bearing account with written agreement.
Must specify who receives interest.
```

## Deposit Timeline Rules

### FAR/BAR Standard Timeline

| Deposit | Default Timing | Count Method | FAR/BAR Paragraph |
|---------|----------------|--------------|-------------------|
| Initial Deposit | 3 days | < 5 day rule | Para 5(a) |
| Additional Deposit | Per contract | Calendar | Para 5(b) |
| Increase After Inspection | Per addendum | Calendar | Addendum |

### Calculation Example

```
Effective Date: Friday, January 15, 2026
Initial Deposit: Due within 3 days

Day 0: January 15 (Friday) - NOT counted
Day 1: January 16 (Saturday) - SKIPPED (< 5 day rule)
Day 2: January 17 (Sunday) - SKIPPED (< 5 day rule)
Day 3: January 18 (Monday) - Day 1
Day 4: January 19 (Tuesday) - Day 2
Day 5: January 20 (Wednesday) - Day 3 ← DEADLINE

Deposit Due: Wednesday, January 20, 2026 by 11:59 PM
```

## Execution Flow

```
START
  │
  ├─── 1. Load deal escrow data
  │    ├── Get deal record
  │    ├── Get escrow amounts and dates
  │    └── Get current deposit status
  │
  ├─── 2. Validate escrow holder
  │    ├── Title company → Check active license
  │    ├── Broker → Verify FL license active
  │    ├── Attorney → Verify FL Bar status
  │    └── Flag if holder unverified
  │
  ├─── 3. Calculate deposit deadline
  │    └── INVOKE: deadline-calculation-rules
  │        └── Apply < 5 day rule for 3-day deposit
  │
  ├─── 4. Check deposit status
  │    ├── pending → Not yet received
  │    ├── received → In escrow account
  │    ├── verified → Confirmed with holder
  │    ├── disputed → Conflicting demands
  │    └── released → Disbursed to party
  │
  ├─── 5. Assess compliance
  │    ├── On time? Compare receipt to deadline
  │    ├── Correct holder? Per contract terms
  │    ├── Correct amount? Matches contract
  │    └── Documentation complete?
  │
  ├─── 6. Generate alerts if needed
  │    ├── Deadline approaching (< 48 hours)
  │    ├── Deadline passed, no deposit
  │    ├── Amount mismatch
  │    └── Holder issue
  │
  └─── RETURN escrow_status
```

## Disbursement Rules

### When Escrow Can Be Released

| Scenario | Release To | Authority | Documentation |
|----------|------------|-----------|---------------|
| **Closing Occurs** | Seller (via closing) | Settlement statement | HUD-1/CD |
| **Contract Cancelled - Buyer's Right** | Buyer | Inspection contingency | Cancellation notice |
| **Contract Cancelled - Mutual** | Per agreement | Signed release | Mutual release form |
| **Financing Denial** | Buyer | Loan denial letter | Denial + cancellation |
| **Seller Default** | Buyer | Buyer's demand | Notice of default |
| **Buyer Default** | Seller (maybe) | See liquidated damages | Demand letter |
| **Dispute** | Court/Arbitration | Interpleader or mediation | See dispute rules |

### FREC Disbursement Procedure (Rule 61J2-14.010)

```
STEP 1: Receive Written Demand
──────────────────────────────
One party makes written demand for escrow funds.

STEP 2: Notify Other Party
──────────────────────────
Within 15 business days, holder must notify other party.

STEP 3: Response Period
───────────────────────
Other party has 10 business days to respond.

STEP 4: If No Conflicting Demand
───────────────────────────────
Holder may disburse to demanding party after response period.

STEP 5: If Conflicting Demands
─────────────────────────────
INVOKE: deposit-dispute-rules skill
```

## Common Escrow Amounts

| Purchase Price Range | Typical Escrow | Percentage |
|---------------------|----------------|------------|
| < $200,000 | $2,000 - $5,000 | 1-2.5% |
| $200,000 - $500,000 | $5,000 - $15,000 | 2-3% |
| $500,000 - $1,000,000 | $15,000 - $30,000 | 2-3% |
| > $1,000,000 | $25,000 - $50,000+ | 2-5% |

*Note: These are typical ranges; amounts are negotiable.*

## Output

```typescript
{
  success: true,
  actionTaken: "Checked escrow status for 123 Main St",
  result: {
    escrow: {
      initialAmount: 10000,
      additionalAmount: 5000,
      totalDeposit: 15000,
      percentOfPrice: 3.3,
      holder: "ABC Title Company",
      holderLicense: "W123456",
      holderVerified: true
    },
    timeline: {
      initialDeadline: "2026-01-20",
      initialReceived: "2026-01-19",
      initialOnTime: true,
      additionalDeadline: "2026-02-01",
      additionalReceived: null,
      additionalOnTime: null
    },
    status: {
      current: "partial",
      initialDeposit: "verified",
      additionalDeposit: "pending",
      daysUntilAdditionalDue: 12
    },
    compliance: {
      onTime: true,
      correctHolder: true,
      correctAmount: true,
      allVerified: false,
      issues: []
    },
    alerts: [
      {
        type: "reminder",
        message: "Additional deposit of $5,000 due February 1, 2026",
        daysRemaining: 12
      }
    ]
  }
}
```

## Voice Response

**Deposit On Track:**
> "The initial deposit of $10,000 is in escrow with ABC Title Company, received on time January 19th. The additional $5,000 is due February 1st, that's 12 days away. Total escrow will be $15,000, about 3.3% of the purchase price."

**Deadline Approaching:**
> "Alert: The escrow deposit of $10,000 is due tomorrow, January 20th. I haven't received confirmation it's been deposited. Want me to send a reminder to the buyer's agent?"

**Late Deposit:**
> "The escrow deposit is late. It was due January 20th and I still don't show it received as of January 22nd. Under the FAR/BAR contract, this could be a default. You should send a notice to cure and contact the buyer's agent immediately. Want me to draft that notice?"

## Error Handling

| Error | Cause | Response |
|-------|-------|----------|
| `NO_ESCROW_AMOUNT` | Amount not in deal | "I don't have the escrow amount. What's the deposit?" |
| `INVALID_HOLDER` | Can't verify holder | "I can't verify ABC Title's license. Let me search the DBPR database." |
| `PAST_DEADLINE` | Deadline has passed | "The escrow deadline passed on [date]. Is the deposit in?" |
| `AMOUNT_MISMATCH` | Received ≠ expected | "The deposit I show ($8,000) doesn't match the contract ($10,000). Can you verify?" |

## Integration Points

### Related Skills
- `deadline-calculation-rules` - Calculate deposit due date
- `deposit-dispute-rules` - Handle conflicting demands
- `cancellation-rights` - When buyer can get deposit back
- `time-is-of-the-essence` - Deadline enforcement

### Database Tables
- `deals` - Escrow amounts and holder
- `escrow_deposits` - Deposit tracking
- `parties` - Escrow holder info
- `action_log` - Audit trail

### External Verification
- DBPR License Search (brokers)
- Florida Bar (attorneys)
- Title insurance underwriters

## Quality Checklist

- [x] Calculates deposit deadline per FAR/BAR
- [x] Applies < 5 day counting rule
- [x] Tracks multiple deposits
- [x] Verifies escrow holder license
- [x] Monitors deposit status
- [x] Alerts on approaching deadlines
- [x] Handles late deposit scenarios
- [x] Cites FREC rules
- [x] Voice-friendly responses
- [x] Integrates with dispute handling

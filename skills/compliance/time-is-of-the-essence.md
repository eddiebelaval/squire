# Skill: Time is of the Essence Enforcement

**Category:** Compliance
**Priority:** P0
**Approval Required:** No

## Purpose

Enforce and explain "Time is of the Essence" clause provisions in Florida real estate contracts. This clause makes ALL deadlines strict and enforceable - missing a deadline can constitute default.

## Legal Authority

- **FAR/BAR Contract Paragraph 19** - Time is of the Essence clause
- **Florida Case Law** - Interpretive precedent
- **General Contract Law** - Strict construction of time provisions
- **FREC Guidelines** - Agent responsibilities for deadlines

## The Clause

### FAR/BAR Paragraph 19 - Standard Language

> "Time is of the essence for all provisions of this Contract. If Buyer or Seller fails to complete any of the obligations under this Contract within the time specified, Buyer or Seller will be in default and subject to the remedies set forth in this Contract."

### What This Means

```
INTERPRETATION:
─────────────────────────────────────────────────────────
1. EVERY deadline in the contract is STRICTLY enforceable
2. Missing ANY deadline = potential default
3. No "grace period" unless specifically granted
4. The other party can pursue remedies immediately
5. Courts will enforce deadlines as written

COMMON MISCONCEPTION:
"I'm just a day late, it's not a big deal" = WRONG
Under TIOE, even 1 day late is a default.
```

## Triggers

### Voice Commands
- "Is time of the essence?"
- "What happens if we miss the deadline?"
- "Can we extend the inspection period?"
- "The buyer is late on the deposit"
- "Are we in default?"
- "What are my remedies if they're late?"

### Programmatic
- Deadline passed without completion
- Deadline approaching (< 24 hours)
- Party requests extension
- Default notice triggered
- Compliance check running

## Required Inputs

| Input | Type | Required | Source | Description |
|-------|------|----------|--------|-------------|
| `dealId` | UUID | Yes | context | Deal to check |
| `deadlineType` | string | Yes | deadline | Which deadline |
| `deadlineDate` | DateTime | Yes | deadline | When it was/is due |

## Optional Inputs

| Input | Type | Default | Source | Description |
|-------|------|---------|--------|-------------|
| `deadlineMet` | boolean | null | status | Was it met? |
| `representingSide` | string | null | context | Buyer or seller side |
| `currentDate` | DateTime | now | system | Current date/time |
| `extensionRequested` | boolean | false | request | Extension pending |

## Deadlines Subject to TIOE

### All FAR/BAR Deadlines

| Deadline | Consequence if Missed |
|----------|----------------------|
| **Initial Deposit** | Buyer default, seller can terminate |
| **Additional Deposit** | Buyer default, seller can terminate |
| **Inspection Period** | Contingency waived, cannot cancel |
| **Financing Contingency** | Contingency waived, must close or default |
| **Loan Approval** | Buyer must proceed or risk default |
| **Closing Date** | Default by failing party |
| **Post-Closing Possession** | Holdover penalties apply |

### Impact of Missing Deadlines

```
MISSED DEADLINE → ONE OF THESE OUTCOMES:
─────────────────────────────────────────

1. DEFAULT
   - Non-performing party is in breach
   - Other party can pursue remedies
   - May include liquidated damages

2. WAIVER OF CONTINGENCY
   - If contingency deadline missed
   - Buyer loses right to cancel under that contingency
   - Must proceed or be in default

3. AUTOMATIC EXTENSION (rare)
   - Only if contract specifically provides
   - "If X doesn't happen, closing extends by Y days"

4. MUTUAL EXTENSION AGREEMENT
   - Both parties sign extension addendum
   - New deadline replaces old
   - Still subject to TIOE
```

## Execution Flow

```
START
  │
  ├─── 1. Identify the deadline
  │    ├── Get deadline type and date
  │    ├── Get current status
  │    └── Identify responsible party
  │
  ├─── 2. Determine deadline status
  │    ├── Upcoming: > 24 hours away
  │    ├── Imminent: < 24 hours away
  │    ├── Due today: Deadline is today
  │    ├── Missed: Past deadline, not met
  │    └── Met: Obligation completed on time
  │
  ├─── 3. If missed, assess consequences
  │    ├── Is this a contingency deadline?
  │    │   └── Yes → Contingency may be waived
  │    ├── Is this a performance deadline?
  │    │   └── Yes → Party may be in default
  │    └── What remedies are available?
  │
  ├─── 4. Check for extension
  │    ├── Has extension been requested?
  │    ├── Has extension been signed?
  │    └── Is there a new deadline?
  │
  ├─── 5. Advise on options
  │    ├── If our side missed → How to cure
  │    ├── If other side missed → Available remedies
  │    └── Document current status
  │
  └─── RETURN tioe_assessment
```

## Remedies for Default

### If Buyer Defaults

| Remedy | Availability | FAR/BAR Reference |
|--------|--------------|-------------------|
| **Retain Deposit** | If selected Para 16(a) | Liquidated damages |
| **Seek Actual Damages** | If selected Para 16(b) | Beyond deposit |
| **Specific Performance** | If selected Para 16(b) | Force purchase |
| **Terminate Contract** | Always available | Walk away |

### If Seller Defaults

| Remedy | Availability | FAR/BAR Reference |
|--------|--------------|-------------------|
| **Return of Deposit** | Always | Buyer gets deposit back |
| **Seek Actual Damages** | If selected Para 16 | Out of pocket costs |
| **Specific Performance** | If selected Para 16 | Force sale |
| **Terminate Contract** | Always available | Walk away |

## Output

```typescript
{
  success: true,
  actionTaken: "Assessed Time is of the Essence status for deposit deadline",
  result: {
    clause: {
      active: true,
      reference: "FAR/BAR Paragraph 19",
      language: "Time is of the essence for all provisions..."
    },
    deadline: {
      type: "initial_deposit",
      date: "2026-01-20T23:59:00",
      responsibleParty: "Buyer",
      status: "missed",
      daysPastDue: 2
    },
    consequence: {
      type: "potential_default",
      defaultingParty: "Buyer",
      description: "Buyer failed to deposit escrow by deadline",
      severityLevel: "high"
    },
    options: {
      forDefaultingParty: [
        {
          action: "Cure immediately",
          description: "Deposit funds now and hope seller doesn't terminate",
          timeframe: "ASAP"
        },
        {
          action: "Request extension",
          description: "Ask seller for extension via addendum",
          riskLevel: "Seller may refuse or renegotiate terms"
        }
      ],
      forNonDefaultingParty: [
        {
          action: "Terminate contract",
          description: "End deal due to buyer default",
          benefit: "Free to sell to other buyers"
        },
        {
          action: "Demand performance",
          description: "Send notice to cure",
          benefit: "Gives buyer chance to cure, documents your position"
        },
        {
          action: "Waive and continue",
          description: "Accept late deposit, proceed with deal",
          risk: "May waive future strict enforcement"
        }
      ]
    },
    recommendation: {
      action: "Send notice to cure within 24 hours",
      reason: "Preserves seller's rights while giving buyer chance to perform",
      template: "Notice to Cure - Deposit Default"
    },
    warnings: [
      "Do not accept partial deposit without written agreement",
      "Document all communications about the delay",
      "Consult attorney before terminating"
    ]
  }
}
```

## Voice Response

**Deadline Approaching:**
> "The inspection period ends tomorrow at 11:59 PM. Time is of the essence, so if the buyer doesn't cancel by then, they waive their right to cancel under the inspection contingency and must proceed to closing. Has the buyer made a decision?"

**Deadline Missed - Our Side:**
> "We have a problem. The deposit was due January 20th and it's now January 22nd. Under Time is of the Essence, the buyer is technically in default. The seller can terminate the contract. I'd recommend getting that deposit in immediately and calling the listing agent to explain. We should also send a written request for extension. Want me to draft that?"

**Deadline Missed - Other Side:**
> "The seller missed their deadline to deliver the HOA documents - they were due January 18th. Under Time is of the Essence, this is a seller default. Your options are: terminate the contract and get your deposit back, demand performance with a notice to cure, or waive the delay and proceed. What would you like to do?"

**Extension Requested:**
> "The buyer is asking for a 5-day extension on the financing contingency. Since Time is of the Essence applies, you're not obligated to grant it. However, if you want to keep the deal alive, you could agree but maybe ask for an additional deposit or other consideration. Should I prepare an extension addendum?"

## Error Handling

| Error | Cause | Response |
|-------|-------|----------|
| `DEADLINE_NOT_FOUND` | No such deadline in deal | "I don't have that deadline on file. When was it supposed to be?" |
| `STATUS_UNKNOWN` | Can't determine if met | "I'm not sure if this deadline was met. Can you confirm?" |
| `NO_CONTRACT` | Contract not uploaded | "I need the contract to check the Time is of the Essence terms." |

## Best Practices

### For Agents

```
DO:
─────────────────────────────────────────
✓ Calendar ALL deadlines immediately
✓ Set reminders 5 days AND 24 hours before
✓ Confirm completion IN WRITING
✓ Get extensions BEFORE deadlines pass
✓ Document everything

DON'T:
─────────────────────────────────────────
✗ Assume other side won't enforce
✗ Promise your client grace periods
✗ Wait until deadline day to act
✗ Accept verbal extensions (get it written)
✗ Ignore missed deadlines (address immediately)
```

### Extension Best Practices

1. Request in writing BEFORE deadline
2. Use standard extension addendum
3. All parties must sign
4. New deadline subject to TIOE
5. Consider requesting consideration for granting extension

## Integration Points

### Related Skills
- `deadline-calculation-rules` - Calculate exact deadlines
- `cancellation-rights` - When parties can exit
- `escrow-rules` - Deposit deadline specifics
- `florida-far-bar-rules` - Default remedies

### Database Tables
- `deadlines` - All deal deadlines
- `deadline_status` - Met/missed tracking
- `action_log` - Audit trail
- `documents` - Extension addenda

## Quality Checklist

- [x] Explains TIOE clause clearly
- [x] Tracks deadline status
- [x] Identifies default situations
- [x] Lists available remedies
- [x] Provides cure options
- [x] Warns about waiver risks
- [x] Recommends next steps
- [x] References FAR/BAR paragraph
- [x] Voice-friendly responses
- [x] Suggests extension templates

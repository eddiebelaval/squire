# Skill: Deposit Dispute Resolution

**Category:** Document/Template
**Priority:** P1
**Approval Required:** Yes (always - legal implications)

## Purpose

Generate Florida-compliant documents for earnest money deposit disputes. This skill handles demand letters, release agreements, mutual releases, and dispute documentation when parties disagree about who should receive the deposit after a failed transaction.

## Triggers

### Voice Commands
- "Create deposit demand for [party]"
- "Dispute the earnest money"
- "Release escrow to [buyer/seller]"
- "Mutual release for [address]"
- "The deposit is in dispute"
- "Escrow dispute on [deal]"
- "Demand earnest money return"

### Programmatic
- `POST /deals/:dealId/documents/deposit-dispute`
- `POST /deals/:dealId/documents/generate` with `templateId: deposit_dispute`
- Triggered by deal cancellation with unresolved escrow

## Required Inputs

| Input | Type | Required | Source | Default |
|-------|------|----------|--------|---------|
| `dealId` | UUID | Yes | context | - |
| `documentSubtype` | string | Yes | voice/manual | See subtypes |
| `claimingParty` | string | Yes | voice | 'buyer' or 'seller' |

## Document Subtypes

| Subtype | Description | When Used |
|---------|-------------|-----------|
| `demand_letter` | Formal demand for deposit | Party believes entitled to deposit |
| `mutual_release` | Both parties agree on split | Negotiated resolution |
| `interpleader_notice` | Escrow agent's notice | Agent caught in dispute |
| `release_to_buyer` | Release deposit to buyer | Seller agrees |
| `release_to_seller` | Release deposit to seller | Buyer agrees |
| `dispute_response` | Response to demand | Contesting party |

## Optional Inputs

| Input | Type | Default | Source | Description |
|-------|------|---------|--------|-------------|
| `depositAmount` | number | from deal | manual | Total deposit amount |
| `escrowAgent` | Company | from deal | manual | Holding escrow |
| `demandReason` | string | null | voice | Why party claims deposit |
| `contractClause` | string | null | manual | Supporting contract section |
| `splitAmount` | object | null | manual | If splitting {buyer, seller} |
| `disputeDate` | Date | today | manual | When dispute arose |
| `deadline` | Date | 15 days | manual | Response deadline |
| `includeContractRef` | boolean | true | config | Reference contract terms |
| `sendForSignature` | boolean | true | config | Auto-send |
| `ccAttorney` | boolean | false | config | Copy to attorney |

## Execution Flow

```
START
  │
  ├─── 1. Load deal context
  │    ├── Get deal by ID
  │    ├── Get deposit amount and escrow info
  │    ├── Get all parties
  │    ├── Get deal status and history
  │    └── Get relevant contract clauses
  │
  ├─── 2. Validate dispute context
  │    ├── Verify deal is cancelled/disputed
  │    ├── Confirm deposit is held
  │    ├── Check for existing dispute docs
  │    └── Identify escrow holder
  │
  ├─── 3. Analyze claim basis
  │    │
  │    ├── IF buyer claiming:
  │    │   ├── Contract terminated within contingency?
  │    │   ├── Seller default?
  │    │   └── Financing/appraisal contingency?
  │    │
  │    └── IF seller claiming:
  │        ├── Buyer default?
  │        ├── Missed deadlines?
  │        └── Breach of contract?
  │
  ├─── 4. Generate appropriate document
  │    │
  │    ├── IF demand_letter:
  │    │   ├── State claim and basis
  │    │   ├── Reference contract terms
  │    │   ├── Set response deadline
  │    │   └── Warn of legal action
  │    │
  │    ├── IF mutual_release:
  │    │   ├── Document agreed split
  │    │   ├── Include release language
  │    │   └── Authorize escrow disbursement
  │    │
  │    ├── IF release_to_buyer/seller:
  │    │   ├── Document agreement
  │    │   ├── Release claims
  │    │   └── Authorize disbursement
  │    │
  │    └── IF interpleader_notice:
  │        ├── Escrow agent position
  │        ├── Court filing notice
  │        └── Hold harmless request
  │
  ├─── 5. Add required disclaimers
  │    ├── Not legal advice
  │    ├── Recommend attorney review
  │    └── Florida law governs
  │
  ├─── 6. Generate PDF
  │
  ├─── 7. Create document record
  │    ├── type: 'dispute'
  │    ├── subtype: documentSubtype
  │    ├── status: 'draft' (always review first)
  │    └── Link to deal
  │
  ├─── 8. Request agent approval
  │    └── "This is a legal document. Please review before sending."
  │
  ├─── 9. IF approved and sendForSignature:
  │    ├── Configure appropriate signers
  │    ├── INVOKE: send-for-signature skill
  │    └── Update status
  │
  ├─── 10. Log action
  │     └── action_type: 'deposit_dispute_generated'
  │
  └─── 11. Return result
```

## Template Content - Demand Letter

```
DEMAND FOR RELEASE OF EARNEST MONEY DEPOSIT

Date: {{current_date}}

VIA EMAIL AND CERTIFIED MAIL

TO: {{otherParty.name}}
    {{otherParty.address}}
    {{otherParty.email}}

CC: {{escrowAgent.name}}
    {{escrowAgent.address}}
    {{escrowAgent.email}}

RE: Demand for Release of Earnest Money Deposit
    Property: {{deal.property_address.street}}, {{deal.property_address.city}}, FL {{deal.property_address.zip}}
    Contract Date: {{deal.effective_date | formatDate}}
    Deposit Amount: ${{depositAmount | currency}}

================================================================================
DEMAND
================================================================================

Dear {{otherParty.name}}:

Please be advised that I represent the {{claimingParty | capitalize}} in the
above-referenced real estate transaction. This letter constitutes a formal
demand for the release of the earnest money deposit in the amount of
${{depositAmount | currency}} currently held by {{escrowAgent.name}}.

================================================================================
FACTUAL BACKGROUND
================================================================================

On {{deal.effective_date | formatDate}}, {{buyers.[0].name}} ("Buyer") and
{{sellers.[0].name}} ("Seller") entered into a Contract for Sale and Purchase
for the Property referenced above.

{{#if claimingParty === 'buyer'}}
{{demandReason}}

Pursuant to the terms of the Contract, specifically {{contractClause}},
Buyer properly exercised their right to terminate the Contract. As such,
Buyer is entitled to a full refund of the earnest money deposit.

The Contract states: "[relevant contract language]"

Buyer complied with all notice requirements and timely exercised this right.
{{/if}}

{{#if claimingParty === 'seller'}}
{{demandReason}}

Buyer has breached the Contract by {{breachDescription}}. Pursuant to the
terms of the Contract, specifically {{contractClause}}, Seller is entitled
to the earnest money deposit as liquidated damages.

The Contract states: "[relevant contract language]"
{{/if}}

================================================================================
DEMAND
================================================================================

{{claimingParty | capitalize}} hereby demands that {{otherParty.role}}
execute a release of the earnest money deposit to {{claimingParty | capitalize}}
within {{responseDays}} ({{responseDays | numberToWords}}) days of receipt
of this demand.

Please sign and return the enclosed Release of Earnest Money Deposit form to:

{{escrowAgent.name}}
{{escrowAgent.address}}
{{escrowAgent.email}}

================================================================================
NOTICE OF RIGHTS
================================================================================

Please be advised that if you fail to comply with this demand within the
time specified, {{claimingParty | capitalize}} reserves all rights and
remedies available under the Contract and Florida law, including but not
limited to:

1. Filing a civil action for recovery of the deposit and attorney's fees
2. Seeking specific performance of the Contract terms
3. Pursuing all damages available under Florida law

{{#if claimingParty === 'buyer'}}
The Florida Real Estate Commission (FREC) requires timely disbursement of
deposits per Chapter 475, Florida Statutes.
{{/if}}

================================================================================
RESPONSE REQUIRED
================================================================================

Please respond in writing within {{responseDays}} days to:

{{claimingAgent.name}}
{{claimingAgent.brokerage}}
{{claimingAgent.email}}
{{claimingAgent.phone}}

Failure to respond will be considered a rejection of this demand.

================================================================================

This demand is made without prejudice to any other rights or remedies
available to {{claimingParty | capitalize}}.

Sincerely,

_________________________________
{{claimingParty | capitalize}} / Agent
{{claimingAgent.name}}
{{claimingAgent.brokerage}}
License #: {{claimingAgent.licenseNumber}}

DISCLAIMER: This letter is not intended as legal advice. The parties are
encouraged to seek independent legal counsel regarding their rights and
obligations.
```

## Template Content - Mutual Release

```
MUTUAL RELEASE OF EARNEST MONEY DEPOSIT
AND RELEASE OF ALL CLAIMS

Date: {{current_date}}

Property Address: {{deal.property_address.street}}
                  {{deal.property_address.city}}, {{deal.property_address.state}} {{deal.property_address.zip}}

Contract Date: {{deal.effective_date | formatDate}}
Deposit Amount: ${{depositAmount | currency}}
Escrow Agent: {{escrowAgent.name}}

================================================================================
PARTIES
================================================================================

BUYER(S): {{#each buyers}}{{this.name}}{{#unless @last}}, {{/unless}}{{/each}}
SELLER(S): {{#each sellers}}{{this.name}}{{#unless @last}}, {{/unless}}{{/each}}

================================================================================
RECITALS
================================================================================

WHEREAS, the parties entered into a Contract for Sale and Purchase dated
{{deal.effective_date | formatDate}} for the above-referenced Property; and

WHEREAS, the Contract has been terminated and/or will not proceed to closing; and

WHEREAS, the earnest money deposit in the amount of ${{depositAmount | currency}}
is currently held by {{escrowAgent.name}}; and

WHEREAS, the parties wish to resolve the disposition of the earnest money
deposit and release each other from all claims arising from the Contract;

NOW, THEREFORE, for good and valuable consideration, the receipt and
sufficiency of which is hereby acknowledged, the parties agree as follows:

================================================================================
DEPOSIT DISBURSEMENT
================================================================================

The parties hereby authorize and direct {{escrowAgent.name}} to disburse the
earnest money deposit as follows:

{{#if splitAmount}}
To Buyer:  ${{splitAmount.buyer | currency}}
To Seller: ${{splitAmount.seller | currency}}
TOTAL:     ${{depositAmount | currency}}
{{else}}
{{#if releaseToParty === 'buyer'}}
To Buyer: ${{depositAmount | currency}} (100% of deposit)
{{/if}}
{{#if releaseToParty === 'seller'}}
To Seller: ${{depositAmount | currency}} (100% of deposit)
{{/if}}
{{/if}}

{{escrowAgent.name}} is authorized to release the funds as directed above
upon receipt of this fully executed Release.

================================================================================
MUTUAL RELEASE OF CLAIMS
================================================================================

Buyer and Seller, for themselves and their respective heirs, successors,
assigns, agents, and representatives, hereby:

1. RELEASE each other from any and all claims, demands, damages, actions,
   causes of action, or liabilities of any kind, whether known or unknown,
   arising out of or related to the Contract or the Property.

2. WAIVE any right to pursue legal action against each other related to
   the Contract or this transaction.

3. AGREE that this Release is a full and final settlement of all matters
   between them regarding the Contract and Property.

================================================================================
REPRESENTATIONS
================================================================================

Each party represents and warrants that:

1. They have the full authority to execute this Release
2. They have not assigned or transferred any claims to any third party
3. They have read and understand this Release
4. They are executing this Release voluntarily
5. They have had the opportunity to consult with legal counsel

================================================================================
ESCROW AGENT AUTHORIZATION
================================================================================

The parties jointly and severally authorize {{escrowAgent.name}} to:

1. Rely upon this Release as full authorization to disburse funds
2. Disburse the deposit as directed above
3. Close the escrow file upon disbursement

The parties agree to hold {{escrowAgent.name}} harmless from any claims
arising from disbursement in accordance with this Release.

================================================================================
GENERAL PROVISIONS
================================================================================

1. This Release contains the entire agreement between the parties regarding
   the deposit and supersedes all prior discussions.

2. This Release may be executed in counterparts.

3. This Release shall be governed by Florida law.

4. If any provision is deemed invalid, the remaining provisions shall
   remain in effect.

================================================================================
SIGNATURES
================================================================================

BUYER:                                    DATE:
_________________________________        _______________
{{buyers.[0].name}}

{{#if buyers.[1]}}
_________________________________        _______________
{{buyers.[1].name}}
{{/if}}

SELLER:                                   DATE:
_________________________________        _______________
{{sellers.[0].name}}

{{#if sellers.[1]}}
_________________________________        _______________
{{sellers.[1].name}}
{{/if}}

================================================================================
ESCROW AGENT ACKNOWLEDGMENT
================================================================================

{{escrowAgent.name}} acknowledges receipt of this Mutual Release and agrees
to disburse the earnest money deposit in accordance with the instructions
provided herein.

_________________________________        _______________
Authorized Representative                  Date
{{escrowAgent.name}}
```

## Output

```typescript
{
  success: true,
  actionTaken: "Created deposit demand letter for 123 Main St",
  result: {
    document: {
      id: "uuid",
      name: "Demand for Earnest Money - Buyer",
      type: "dispute",
      subtype: "demand_letter",
      status: "pending_approval",
      pdfUrl: "https://...",
      requiresApproval: true
    },
    dispute: {
      depositAmount: 10000,
      claimingParty: "buyer",
      reason: "Contract terminated within inspection period",
      contractClause: "Section 12(a) - Inspection Contingency",
      responseDeadline: "2026-01-30"
    },
    escrow: {
      agent: "First American Title",
      email: "escrow@firstam.com",
      notified: false
    },
    approval: {
      status: "pending",
      message: "This is a legal document with significant implications. Please review carefully before sending.",
      recommendAttorney: true
    },
    nextSteps: [
      "Review document carefully before sending",
      "Consider consulting with attorney",
      "Document will be sent via email and certified mail",
      "Other party has 15 days to respond"
    ]
  }
}
```

## Voice Response

**Demand letter:**
> "I've drafted a deposit demand letter for the buyer on 123 Main Street.
>
> This claims the $10,000 deposit based on the inspection termination. The seller has 15 days to respond.
>
> This is a legal document - please review it carefully. I'd recommend having your broker or attorney look at it before sending. Ready when you are."

**Mutual release:**
> "Created a mutual release for 123 Main Street.
>
> The deposit will be split - $6,000 to the buyer and $4,000 to the seller, as you discussed.
>
> Once both parties sign, the escrow agent can release the funds. Want me to send it for signatures?"

## Error Handling

| Error | Cause | Response |
|-------|-------|----------|
| `DEAL_NOT_CANCELLED` | Deal still active | "This deal is still active. Are you sure you want to create a dispute document?" |
| `NO_DEPOSIT` | No escrow on record | "I don't have a deposit amount on record. What's the escrow amount?" |
| `MISSING_ESCROW_AGENT` | No escrow info | "Who's holding the deposit? I need the escrow agent's information." |
| `EXISTING_DISPUTE` | Dispute already filed | "There's already a dispute document for this deal from [date]." |
| `INVALID_SPLIT` | Split doesn't total deposit | "The split amounts don't add up to the total deposit of $[amount]." |

## Florida-Specific Notes

- FREC Rule 61J2-10.032 governs escrow disbursement disputes
- Escrow agents must notify FREC of disputes within 15 business days
- Interpleader is common when parties can't agree
- Broker cannot disburse without signed release from BOTH parties
- Small claims court limit is $8,000; circuit court above

## Common Dispute Scenarios

| Scenario | Typical Outcome | Document |
|----------|----------------|----------|
| Buyer terminates in inspection | Buyer gets deposit | Release to Buyer |
| Financing falls through timely | Buyer gets deposit | Release to Buyer |
| Buyer walks away no reason | Split or Seller | Negotiated |
| Seller can't convey clear title | Buyer gets deposit | Release to Buyer |
| Both claim deposit | Interpleader | Notice to Court |

## Quality Checklist

- [x] Requires approval before sending
- [x] References specific contract clauses
- [x] Includes response deadline
- [x] Handles mutual release splits
- [x] Includes escrow agent authorization
- [x] Contains release of claims
- [x] Recommends attorney review
- [x] Florida law compliant
- [x] Certified mail recommendation
- [x] Hold harmless for escrow agent
- [x] Complete audit trail
- [x] Serious tone in voice response

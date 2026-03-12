# Skill: Contract Cancellation Notice

**Category:** Document/Template
**Priority:** P0
**Approval Required:** Yes (HIGH STAKES - always requires explicit agent approval)

## Purpose

Generate a formal contract cancellation notice when a buyer exercises their right to terminate the contract. This is a critical document that must comply with contract terms and Florida law to properly release earnest money.

## Triggers

### Voice Commands
- "Cancel the contract on [property]"
- "Buyer wants to terminate"
- "Generate cancellation notice"
- "Exercise the inspection contingency cancellation"
- "Terminate due to [reason]"

### System Events
- NEVER auto-triggered - always requires explicit request

## Input

```typescript
{
  dealId: string;
  cancellationReason:
    | 'inspection_contingency'
    | 'financing_contingency'
    | 'appraisal_contingency'
    | 'hoa_contingency'
    | 'title_defect'
    | 'seller_breach'
    | 'mutual_release'
    | 'other';
  reasonDetails: string;
  earnestMoneyDisposition: 'return_to_buyer' | 'release_to_seller' | 'disputed' | 'split';
  splitAmount?: {                    // If split
    buyer: number;
    seller: number;
  };
  effectiveDate?: Date;              // Default: today
  additionalTerms?: string;
  requiresSellerSignature: boolean;  // True for mutual release
}
```

## Output

```typescript
{
  success: boolean;
  actionTaken: string;
  result: {
    document: {
      id: string;
      name: string;
      type: 'notice' | 'release';
      pdfUrl: string;
      status: string;
    };
    docusign: {
      envelopeId: string;
      signers: {
        role: string;
        name: string;
        email: string;
        status: string;
      }[];
    };
    earnestMoney: {
      amount: number;
      disposition: string;
      titleCompanyNotified: boolean;
    };
    dealStatusChange: {
      previousStatus: string;
      newStatus: 'cancelled';
    };
    notificationsSent: string[];
  };
  requiresApproval: true;
  approvalMessage: string;
}
```

## Document Template - Unilateral Cancellation

```
NOTICE OF CONTRACT CANCELLATION

Date: {{currentDate | formatDate}}

TO:     {{#each sellers}}{{this.name}}{{#unless @last}}, {{/unless}}{{/each}} (Seller)
        {{listingAgent.name}}, {{listingAgent.brokerage}} (Listing Agent)

FROM:   {{#each buyers}}{{this.name}}{{#unless @last}}, {{/unless}}{{/each}} (Buyer)

RE:     Contract for Sale and Purchase dated {{deal.effectiveDate | formatDate}}
        Property: {{deal.address.street}}
                  {{deal.address.city}}, {{deal.address.state}} {{deal.address.zip}}

================================================================================
NOTICE OF CANCELLATION
================================================================================

Buyer hereby provides notice of cancellation of the above-referenced Contract
for Sale and Purchase pursuant to the terms thereof.

REASON FOR CANCELLATION:

{{#if cancellationReason === 'inspection_contingency'}}
☑ Inspection Contingency (Paragraph 12 of FAR/BAR Contract)
  Buyer is not satisfied with the condition of the Property based on
  inspections conducted during the inspection period.
{{/if}}

{{#if cancellationReason === 'financing_contingency'}}
☑ Financing Contingency (Paragraph 8 of FAR/BAR Contract)
  Buyer has been unable to obtain financing approval as required by the
  Contract within the time period specified.
{{/if}}

{{#if cancellationReason === 'appraisal_contingency'}}
☑ Appraisal Contingency (Paragraph 8 of FAR/BAR Contract)
  The Property did not appraise at or above the purchase price and the
  parties were unable to reach agreement on a resolution.
{{/if}}

{{#if cancellationReason === 'hoa_contingency'}}
☑ HOA/Condominium Document Review (Paragraph 13 of FAR/BAR Contract)
  Buyer has reviewed the HOA/Condominium documents and is exercising the
  right to cancel based on the review.
{{/if}}

{{#if cancellationReason === 'title_defect'}}
☑ Title Defect (Paragraph 9 of FAR/BAR Contract)
  A title defect has been identified that Seller has been unable or
  unwilling to cure within the time allowed.
{{/if}}

{{#if cancellationReason === 'seller_breach'}}
☑ Seller Breach
  Seller has materially breached the Contract as follows:
{{/if}}

{{#if cancellationReason === 'other'}}
☑ Other:
{{/if}}

Details: {{reasonDetails}}

================================================================================
EARNEST MONEY DEPOSIT
================================================================================

Earnest Money Amount: ${{deal.escrowAmount | currency}}
Held by: {{deal.titleCompany.name}}

{{#if earnestMoneyDisposition === 'return_to_buyer'}}
Pursuant to the terms of the Contract, Buyer is entitled to a full refund
of the earnest money deposit. Buyer hereby demands the immediate release
and return of the earnest money deposit in the amount of ${{deal.escrowAmount | currency}}.
{{/if}}

{{#if earnestMoneyDisposition === 'disputed'}}
The parties have not reached agreement on the disposition of the earnest
money deposit. The earnest money shall remain in escrow pending resolution
by mutual agreement or pursuant to Florida Statutes Chapter 475.
{{/if}}

================================================================================
EFFECTIVE DATE
================================================================================

This cancellation is effective as of: {{effectiveDate | formatDate}}

{{#if additionalTerms}}
================================================================================
ADDITIONAL TERMS
================================================================================

{{additionalTerms}}
{{/if}}

================================================================================
BUYER'S SIGNATURE
================================================================================

BUYER:

_________________________________    Date: ____________
{{buyers.[0].name}}

{{#if buyers.[1]}}
_________________________________    Date: ____________
{{buyers.[1].name}}
{{/if}}


ACKNOWLEDGMENT OF RECEIPT:

_________________________________    Date: ____________    Time: ____________
{{listingAgent.name}}
Listing Agent


Prepared by: {{agent.name}}
             {{agent.brokerage}}
             License #: {{agent.licenseNumber}}
             {{agent.phone}} | {{agent.email}}
```

## Document Template - Mutual Release

```
MUTUAL RELEASE AND CANCELLATION OF CONTRACT

Date: {{currentDate | formatDate}}

Property Address: {{deal.address.street}}
                  {{deal.address.city}}, {{deal.address.state}} {{deal.address.zip}}

Contract Date: {{deal.effectiveDate | formatDate}}

Buyer(s): {{#each buyers}}{{this.name}}{{#unless @last}}, {{/unless}}{{/each}}
Seller(s): {{#each sellers}}{{this.name}}{{#unless @last}}, {{/unless}}{{/each}}

================================================================================
MUTUAL AGREEMENT TO CANCEL
================================================================================

The undersigned Buyer(s) and Seller(s) hereby mutually agree to cancel and
terminate the above-referenced Contract for Sale and Purchase.

Reason: {{reasonDetails}}

================================================================================
EARNEST MONEY DISPOSITION
================================================================================

Earnest Money Amount: ${{deal.escrowAmount | currency}}
Held by: {{deal.titleCompany.name}}

The parties agree that the earnest money deposit shall be disbursed as follows:

{{#if earnestMoneyDisposition === 'return_to_buyer'}}
☑ Full amount returned to Buyer: ${{deal.escrowAmount | currency}}
{{/if}}

{{#if earnestMoneyDisposition === 'release_to_seller'}}
☑ Full amount released to Seller: ${{deal.escrowAmount | currency}}
{{/if}}

{{#if earnestMoneyDisposition === 'split'}}
☑ Split between parties:
   To Buyer: ${{splitAmount.buyer | currency}}
   To Seller: ${{splitAmount.seller | currency}}
{{/if}}

================================================================================
RELEASE OF CLAIMS
================================================================================

Upon execution of this Mutual Release and disbursement of the earnest money
as specified above, Buyer and Seller each release and forever discharge the
other, and their respective agents, brokers, and representatives, from any
and all claims, demands, damages, costs, expenses, and causes of action,
known or unknown, arising out of or related to the above-referenced Contract.

This release is intended to be a full and complete settlement of all claims
between the parties arising from the Contract.

================================================================================
SIGNATURES
================================================================================

BUYER(S):

_________________________________    Date: ____________
{{buyers.[0].name}}

{{#if buyers.[1]}}
_________________________________    Date: ____________
{{buyers.[1].name}}
{{/if}}


SELLER(S):

_________________________________    Date: ____________
{{sellers.[0].name}}

{{#if sellers.[1]}}
_________________________________    Date: ____________
{{sellers.[1].name}}
{{/if}}


Prepared by: {{agent.name}}
             {{agent.brokerage}}
             {{agent.phone}} | {{agent.email}}
```

## Execution Flow

```
START
  │
  ├─── 1. **APPROVAL GATE** (MANDATORY)
  │    │
  │    │   ⚠️ HIGH STAKES ACTION
  │    │   This action CANNOT proceed without explicit agent approval
  │    │
  │    ├── Present cancellation summary to agent:
  │    │   - Property address
  │    │   - Cancellation reason
  │    │   - Earnest money amount and proposed disposition
  │    │   - Impact on deal
  │    │
  │    ├── IF NOT approved:
  │    │   └── STOP - Return without action
  │    │
  │    └── IF approved:
  │        └── CONTINUE
  │
  ├─── 2. Validate cancellation right
  │    ├── Check if contingency period is still active
  │    ├── Verify buyer has right to cancel for stated reason
  │    └── Warn if cancellation may be contested
  │
  ├─── 3. Load deal context
  │    ├── Get all parties
  │    ├── Get earnest money details
  │    ├── Get title company info
  │    └── Get relevant deadlines
  │
  ├─── 4. Select document template
  │    ├── IF requiresSellerSignature = true:
  │    │   └── Use Mutual Release template
  │    └── ELSE:
  │        └── Use Unilateral Cancellation template
  │
  ├─── 5. Generate document
  │    ├── Apply appropriate template
  │    ├── Include reason-specific language
  │    └── Generate PDF
  │
  ├─── 6. Configure DocuSign
  │    │
  │    ├── IF Mutual Release:
  │    │   ├── Signers: Buyer(s) → Seller(s)
  │    │   └── Sequential signing: true
  │    │
  │    └── IF Unilateral:
  │        ├── Signers: Buyer(s) → Listing Agent (acknowledgment)
  │        └── Sequential signing: true
  │
  ├─── 7. Send for signatures
  │    ├── Create DocuSign envelope
  │    └── Send to appropriate parties
  │
  ├─── 8. Notify title company
  │    ├── Send cancellation notice
  │    ├── Include earnest money instruction
  │    └── Request acknowledgment
  │
  ├─── 9. Update deal status
  │    ├── Set deal.status = 'cancelled'
  │    ├── Record cancellation reason
  │    ├── Cancel all pending deadlines
  │    └── Archive deal
  │
  ├─── 10. Notify all parties
  │     ├── Listing agent (formal notice)
  │     ├── Lender (if applicable)
  │     ├── Insurance (if bound)
  │     └── All other stakeholders
  │
  └─── 11. Return result with confirmation
```

## Cancellation Rights by Reason

| Reason | Earnest Money | Seller Signature Required |
|--------|---------------|--------------------------|
| Inspection Contingency | Return to Buyer | No |
| Financing Contingency | Return to Buyer | No |
| Appraisal Contingency | Return to Buyer | No |
| HOA Contingency | Return to Buyer | No |
| Title Defect (uncured) | Return to Buyer | No |
| Seller Breach | Return to Buyer | No |
| Mutual Agreement | As agreed | Yes |
| Buyer Breach/Default | May be disputed | Yes (or litigation) |

## Timing Requirements

| Contingency | Cancellation Must Be | Deadline |
|-------------|---------------------|----------|
| Inspection | During inspection period | Per contract |
| Financing | Before contingency expiration | Per contract |
| Appraisal | Before contingency expiration | Per contract |
| HOA | Within review period | Per contract |
| Title | Per contract terms | Varies |

## Notification Recipients

| Party | Method | Content |
|-------|--------|---------|
| Listing Agent | DocuSign + Email | Formal notice |
| Seller | Via listing agent | Formal notice |
| Title Company | Email | Escrow instruction |
| Lender | Email | Loan cancellation |
| Insurance | Email | Policy cancellation |
| All parties | Email | Transaction summary |

## Error Handling

| Error | Cause | Response |
|-------|-------|----------|
| `CONTINGENCY_EXPIRED` | Past deadline | Warn agent, may require mutual release |
| `NO_RIGHT_TO_CANCEL` | Invalid reason | Explain limitations, suggest alternatives |
| `DEAL_ALREADY_CANCELLED` | Already terminated | Return existing cancellation info |
| `APPROVAL_DENIED` | Agent rejected | Stop, log rejection |

## Florida Escrow Release Rules

Per Florida Statutes Chapter 475:
- If both parties agree → Escrow released per agreement
- If dispute → Escrow holder may:
  - Request mediation/interpleader
  - Hold funds pending resolution
  - Follow contract dispute provisions
- 10-day demand rule for uncontested cancellations

## Quality Checklist

- [x] **ALWAYS requires explicit agent approval**
- [x] Validates cancellation right before proceeding
- [x] Uses correct template (unilateral vs mutual)
- [x] Includes reason-specific language
- [x] Properly addresses earnest money disposition
- [x] Notifies title company with escrow instruction
- [x] Updates deal status to cancelled
- [x] Cancels all pending deadlines
- [x] Notifies all relevant parties
- [x] Creates complete audit trail
- [x] Handles disputed earnest money scenarios

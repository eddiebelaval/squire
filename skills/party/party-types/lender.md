# Party Type: Lender

**Role Code:** `lender`
**Category:** Vendor Party
**Typical Count:** 1 per deal (if financing)

## Overview

The lender provides financing for the buyer's purchase. They underwrite the loan, order the appraisal, and fund the transaction at closing. The lender's timeline often drives the transaction timeline, making them a critical party to track in financed deals.

## Role Definition

### Who Is This Party?
- Bank, credit union, or mortgage company providing the loan
- Represented by a loan officer who is the primary contact
- May use a mortgage broker as intermediary
- Processes the loan through underwriting

### Common Configurations
| Type | Description | Example |
|------|-------------|---------|
| Direct Lender | Bank or lender direct | Chase, Wells Fargo |
| Mortgage Company | Non-bank lender | Quicken, Movement Mortgage |
| Credit Union | Member-owned | Navy Federal |
| Mortgage Broker | Shops multiple lenders | ABC Mortgage Brokers |
| Hard Money | Asset-based lending | Investment property |

## Contact Requirements

### Required Information
| Field | Required | Reason |
|-------|----------|--------|
| Company Name | Yes | Contract, coordination |
| Loan Officer Name | Yes | Primary contact |
| Email | Yes | Document delivery |
| Phone | Yes | Status updates |
| NMLS Number | Yes | License verification |

### Optional Information
| Field | When Needed |
|-------|-------------|
| Processor Name | Day-to-day contact |
| Underwriter | If escalation needed |
| Branch Manager | If issues arise |
| Pre-Approval Amount | To verify |
| Loan Type | Conventional, FHA, VA, etc. |

## Key Deadlines Involving Lender

| Deadline | Lender's Role | Action Required |
|----------|--------------|-----------------|
| Financing Application | Accept | Process application |
| Loan Estimate | Issue | 3 days of application |
| Appraisal Order | Order | Within first week |
| Appraisal Delivery | Deliver | Provide to buyer |
| Financing Contingency | Clear | Issue approval |
| Clear to Close | Confirm | Final underwriting |
| Closing Disclosure | Issue | 3 days before closing |
| Funding | Wire funds | Close transaction |

## Typical Communications

### With Lender

| Type | Frequency | Purpose |
|------|-----------|---------|
| Contract Delivery | Once | Start processing |
| Status Check | Weekly | Loan progress |
| Appraisal Follow-up | Once | Confirm value |
| Condition Follow-up | As needed | Clear conditions |
| Closing Coordination | 1 week before | Confirm funding |

### Communication Templates

**Contract Delivery:**
> Subject: Contract for [Borrower Name] - [Address]
>
> Hi [Loan Officer Name],
>
> Attached is the executed contract for your borrower:
>
> Borrower: [Buyer Name]
> Property: [Address]
> Purchase Price: $[Amount]
> Effective Date: [Date]
> Closing Date: [Date]
>
> Financing Contingency: [Days] days from effective
>
> Please confirm receipt and provide an update on the appraisal timeline.

**Status Check:**
> Subject: Loan Status - [Borrower Name] / [Address]
>
> Hi [Loan Officer Name],
>
> Can you provide an update on the loan for [Address]?
>
> Key questions:
> - Has the appraisal been ordered/completed?
> - Are there any outstanding conditions?
> - Are we on track for the [Date] closing?
>
> The financing contingency expires [Date]. Please let me know if you need anything from the buyer.

## Voice Command Examples

### Adding Lender
```
"The lender is Chase Bank with Mike as the loan officer"
"Add Mike Chen at ABC Mortgage, NMLS 123456"
"Buyer is using Wells Fargo for financing"
"Loan officer is Mike Chen, email mike@abcmortgage.com"
```

### Lender Queries
```
"Who is the lender?"
"What's the loan officer's phone?"
"Has the appraisal been ordered?"
"What's the financing status?"
```

### Lender Actions
```
"Email the lender about appraisal status"
"Send contract to the lender"
"Check in with the loan officer"
"Ask lender about clear to close"
```

## Schema

```typescript
interface Lender {
  // Identity
  id: string;
  role: 'lender';

  // Company Info
  companyName: string;
  companyNMLS?: string;
  lenderType: 'bank' | 'credit_union' | 'mortgage_company' | 'broker' | 'hard_money';

  // Loan Officer (Primary Contact)
  loanOfficerName: string;
  loanOfficerEmail: string;
  loanOfficerPhone: string;
  loanOfficerNMLS: string;

  // Processor (Secondary Contact)
  processorName?: string;
  processorEmail?: string;
  processorPhone?: string;

  // Office Info
  branchAddress?: Address;
  mainPhone?: string;

  // Loan Details
  loanNumber?: string;
  loanType?: 'conventional' | 'fha' | 'va' | 'usda' | 'jumbo' | 'hard_money' | 'other';
  loanAmount?: number;
  interestRate?: number;
  downPaymentPercent?: number;

  // Pre-Approval
  preApprovalAmount?: number;
  preApprovalDate?: Date;
  preApprovalExpiration?: Date;

  // Loan Milestones
  applicationDate?: Date;
  loanEstimateDate?: Date;
  appraisalOrdered?: Date;
  appraisalCompleted?: Date;
  appraisalValue?: number;
  conditionalApproval?: Date;
  clearToClose?: Date;
  closingDisclosureDate?: Date;

  // Conditions
  outstandingConditions?: string[];
  conditionsCleared?: boolean;

  // Preferences
  communicationPrefs: CommunicationPreferences;
  preferredContactTime?: string;

  // Timestamps
  addedAt: Date;
  updatedAt: Date;
}
```

## Florida-Specific Considerations

### Loan Types
| Type | Details |
|------|---------|
| Conventional | 3-20% down, PMI if <20% |
| FHA | 3.5% down, MIP required |
| VA | 0% down, veterans only |
| USDA | 0% down, rural areas |
| Jumbo | >$766,550 (2024 FL limit) |

### Florida Requirements
- Flood zone determination required
- Wind mitigation inspection may reduce insurance
- Condo project approval for FHA/VA

### Appraisal Issues
- Low appraisal: Renegotiate or buyer covers gap
- Appraisal contingency: Buyer can cancel
- Multiple appraisals rare but possible

### Closing Disclosure Timing
- CD required 3 business days before closing
- Changes restart the 3-day period
- LE changes must stay within tolerance

## Integration Points

### Deadline Skills
- Financing contingency deadline
- Appraisal contingency deadline
- Clear to close timeline

### Document Skills
- Pre-approval letter
- Loan estimate
- Closing disclosure

### Communication Skills
- Status update requests
- Condition follow-ups
- Closing coordination

## Loan Progress Tracking

```typescript
enum LoanMilestone {
  APPLICATION_RECEIVED = 'Application Received',
  LOAN_ESTIMATE_SENT = 'Loan Estimate Sent',
  DOCUMENTS_SUBMITTED = 'Documents Submitted',
  APPRAISAL_ORDERED = 'Appraisal Ordered',
  APPRAISAL_RECEIVED = 'Appraisal Received',
  SUBMITTED_TO_UNDERWRITING = 'Submitted to Underwriting',
  CONDITIONAL_APPROVAL = 'Conditional Approval',
  CONDITIONS_CLEARING = 'Clearing Conditions',
  CLEAR_TO_CLOSE = 'Clear to Close',
  CLOSING_DISCLOSURE_SENT = 'Closing Disclosure Sent',
  FUNDED = 'Funded'
}

// Track in deal
deal.financingMilestone = LoanMilestone.APPRAISAL_RECEIVED;
deal.financingMilestoneDate = new Date();
```

## Appraisal Scenarios

### Low Appraisal Handling
```
If appraisal < purchase price:

Options:
1. Seller reduces price to appraisal
2. Buyer covers gap with additional cash
3. Meet in the middle
4. Buyer cancels (if contingency still in place)
5. Request reconsideration of value (ROV)
```

## Quality Checklist

- [x] Lender company and NMLS captured
- [x] Loan officer direct contact info
- [x] NMLS number verified
- [x] Processor contact if available
- [x] Loan type documented
- [x] Pre-approval amount and expiration tracked
- [x] Loan milestones being tracked
- [x] Appraisal status monitored
- [x] Clear to close timeline established
- [x] Communication preferences noted

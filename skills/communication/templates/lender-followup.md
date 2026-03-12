# Template: Lender Follow-up

**Category:** Communication > Templates
**Priority:** P1
**Auto-Send Eligible:** Yes (milestone-triggered)

## Purpose

Templates for agent-to-lender communications to check on loan status, request updates, coordinate appraisals, and ensure timely clear-to-close. Helps agents stay informed about financing progress to anticipate issues and keep transactions on track.

## Template Variants

### Email Templates

#### Initial Loan Status Check
```
Subject: Loan Status Request | {{deal.address.street}} - {{buyer.name}}

Hi {{lender.name}},

I'm following up on the loan status for the transaction below. Could you provide a quick update on where we stand?

**Transaction Details:**
- Property: {{deal.address.full}}
- Buyer: {{buyer.name}}
- Contract Price: {{deal.purchasePrice | formatCurrency}}
- Loan Amount: {{loan.amount | formatCurrency}}
- Closing Date: {{deal.closingDate | formatDate}}

**Questions:**
1. Has the loan been submitted to underwriting?
2. Are there any outstanding conditions?
3. When do you expect clear-to-close?
4. Is the appraisal ordered/scheduled?

**Key Dates:**
- Financing Contingency: {{deal.financingContingency | formatDate}}
- Closing Date: {{deal.closingDate | formatDate}}

Please let me know if you need anything from my side to keep things moving.

Thank you,
{{signature}}
```

#### Appraisal Status Request
```
Subject: Appraisal Status | {{deal.address.street}}

Hi {{lender.name}},

Checking in on the appraisal for {{deal.address.street}}. Can you confirm the current status?

**Property:** {{deal.address.full}}
**Buyer:** {{buyer.name}}
**Contract Price:** {{deal.purchasePrice | formatCurrency}}
**Closing Date:** {{deal.closingDate | formatDate}}

**Questions:**
1. Has the appraisal been ordered?
2. When is it scheduled?
3. Will we have results before {{deal.appraisalNeededBy | formatDate}}?

{{#if appraisal.accessInfo}}
**Property Access:**
{{appraisal.accessInfo}}
{{/if}}

{{#if appraisal.contacts}}
**For Access Coordination:**
{{#if listing.isListed}}
Listing Agent: {{listingAgent.name}} - {{listingAgent.phone}}
{{else}}
Seller: {{seller.name}} - {{seller.phone}}
{{/if}}
{{/if}}

Let me know if you need access arrangements or additional information.

Thanks,
{{signature}}
```

#### Conditions Follow-up
```
Subject: Outstanding Conditions | {{deal.address.street}} - {{buyer.name}}

Hi {{lender.name}},

Following up on the outstanding conditions for {{buyer.name}}'s loan. Can you provide an update on what's still needed and the timeline?

**Transaction:**
- Property: {{deal.address.street}}
- Closing: {{deal.closingDate | formatDate}} ({{deal.daysToClosing}} days away)

**My Understanding of Outstanding Items:**
{{#each loan.outstandingConditions}}
- {{this.item}} - {{this.status}}
{{/each}}

**Questions:**
1. Is this list current?
2. What's the status on each item?
3. Is there anything holding up clear-to-close?
4. Anything I can help with on my end?

{{#if loan.urgentItems}}
**Urgent Items:**
{{#each loan.urgentItems}}
- {{this}}
{{/each}}
{{/if}}

We're getting close to closing - want to make sure we're on track.

Thanks,
{{signature}}
```

#### Clear-to-Close Request
```
Subject: Clear to Close Status | {{deal.address.street}} - Closing {{deal.closingDate | formatDate}}

Hi {{lender.name}},

With closing on {{deal.closingDate | formatDate}} ({{deal.daysToClosing}} days away), I wanted to check on the clear-to-close status for {{buyer.name}}.

**Transaction Summary:**
- Property: {{deal.address.street}}
- Buyer: {{buyer.name}}
- Loan Amount: {{loan.amount | formatCurrency}}
- Closing: {{deal.closingDate | formatDate}} at {{deal.closingTime}}
- Title Company: {{titleCompany.name}}

**Questions:**
1. Are we clear to close?
2. If not, what conditions remain?
3. When will the closing disclosure be issued?
4. When will the closing package be sent to title?

**Title Company Contact:**
{{closer.name}}
{{closer.email}}
{{closer.phone}}
{{#if titleCompany.closingPackageEmail}}
Closing Package Email: {{titleCompany.closingPackageEmail}}
{{/if}}

Please confirm we're on track for {{deal.closingDate | formatDate}}.

Thank you,
{{signature}}
```

#### Appraisal Results Follow-up
```
Subject: Appraisal Results | {{deal.address.street}}

Hi {{lender.name}},

The appraisal for {{deal.address.street}} should be complete. Can you share the results?

**Property:** {{deal.address.street}}
**Contract Price:** {{deal.purchasePrice | formatCurrency}}
**Appraisal Date:** {{appraisal.date | formatDate}}

**Questions:**
1. What did the property appraise for?
2. Are there any appraisal conditions?
3. Does this affect the loan amount or terms?

{{#if appraisal.concerns}}
**Concerns:**
{{appraisal.concerns}}
{{/if}}

Thanks for the update,
{{signature}}
```

#### Closing Package Reminder
```
Subject: Closing Package Needed | {{deal.address.street}} - Closing {{deal.closingDate | formatDate}}

Hi {{lender.name}},

Closing is {{deal.closingDate | formatDate}} ({{deal.daysToClosing}} days away). Has the closing package been sent to title?

**Transaction:**
- Property: {{deal.address.street}}
- Buyer: {{buyer.name}}
- Closing: {{deal.closingDate | formatDate}} at {{deal.closingTime}}

**Title Company:**
{{titleCompany.name}}
Closer: {{closer.name}}
Email: {{closer.email}}
{{#if titleCompany.closingPackageEmail}}
Package Email: {{titleCompany.closingPackageEmail}}
{{/if}}
{{#if titleCompany.closingPackageFax}}
Package Fax: {{titleCompany.closingPackageFax}}
{{/if}}

**Needed by Title:**
{{#each title.neededFromLender}}
- {{this}}
{{/each}}

Please confirm when the package will be sent.

Thanks,
{{signature}}
```

#### Financing Contingency Deadline Approaching
```
Subject: Financing Deadline {{deal.financingContingency | formatDate}} | {{deal.address.street}}

Hi {{lender.name}},

The financing contingency for {{buyer.name}}'s loan expires on {{deal.financingContingency | formatDate}} ({{deal.daysToFinancingContingency}} days).

**Transaction:**
- Property: {{deal.address.street}}
- Buyer: {{buyer.name}}
- Contingency Expires: {{deal.financingContingency | formatDate}}

**Questions:**
1. Will we have clear-to-close by this date?
2. If not, do we need to request an extension?
3. What's the current hold-up?

The seller will need to know if we need more time. Please advise on realistic timing.

Thanks,
{{signature}}
```

### SMS Templates

#### Quick Status Check
```
{{agent.firstName}}: Quick check on {{buyer.name}}'s loan for {{deal.address.street | abbreviateAddress}}. Any updates? Closing {{deal.closingDate | formatShortDate}}. Thanks! -{{agent.firstName}}
```

#### Appraisal Check
```
{{agent.firstName}}: Appraisal status for {{deal.address.street | abbreviateAddress}}? Ordered/scheduled? Closing {{deal.closingDate | formatShortDate}}. Thanks!
```

#### CTC Check
```
{{agent.firstName}}: Are we clear to close for {{buyer.name}} - {{deal.address.street | abbreviateAddress}}? Closing {{deal.closingDate | formatShortDate}}. Need to confirm with title.
```

#### Urgent - Package Needed
```
{{agent.firstName}}: Urgent - closing {{deal.closingDate | formatShortDate}} for {{deal.address.street | abbreviateAddress}}. Title needs closing package ASAP. Can you confirm when sent?
```

## Template Variables

| Variable | Type | Description | Example |
|----------|------|-------------|---------|
| `lender.name` | string | Loan officer name | "Mike Johnson" |
| `lender.email` | string | LO email | "mjohnson@lender.com" |
| `lender.phone` | string | LO phone | "(512) 555-0123" |
| `buyer.name` | string | Borrower name | "John Smith" |
| `loan.amount` | number | Loan amount | 360000 |
| `loan.type` | string | Loan type | "Conventional" |
| `loan.outstandingConditions` | object[] | Pending conditions | [{item, status}] |
| `deal.financingContingency` | Date | Financing deadline | 2025-02-01 |
| `deal.daysToFinancingContingency` | number | Days to deadline | 5 |
| `appraisal.date` | Date | Appraisal date | 2025-01-25 |
| `appraisal.accessInfo` | string | Property access | "Lockbox 1234" |
| `titleCompany.closingPackageEmail` | string | Package email | "closing@title.com" |

## Follow-up Cadence

| Stage | Trigger | Template |
|-------|---------|----------|
| Week 1 | Contract executed | Initial Status Check |
| Ongoing | Appraisal ordered | Appraisal Status Request |
| Ongoing | Appraisal complete | Appraisal Results |
| Pre-CTC | 10 days before closing | Conditions Follow-up |
| Pre-CTC | 7 days before closing | Clear-to-Close Request |
| Pre-Closing | 3 days before closing | Closing Package Reminder |
| Deadline | 5 days before financing | Financing Deadline Alert |

## Auto-Send Rules

| Trigger | Template | Auto-Send | Approval |
|---------|----------|-----------|----------|
| 14 days after contract | Initial Status | Yes | No |
| Appraisal scheduled | Appraisal Status | Yes | No |
| Appraisal complete | Appraisal Results | Yes | No |
| 7 days before closing | CTC Request | Yes | No |
| 3 days before closing | Package Reminder | Yes | No |
| 5 days to financing deadline | Financing Deadline | Yes | Alert agent |

## Information to Track

### From Lender Updates
- Underwriting status
- Outstanding conditions
- Appraisal value
- Clear-to-close date
- Closing package status

### Red Flags
- Conditions not being cleared
- Appraisal concerns
- CTC not on track
- Package not sent 48 hours before
- Financing deadline at risk

## Error Handling

| Error | Cause | Response |
|-------|-------|----------|
| `NO_LENDER_CONTACT` | Lender not in system | Ask buyer for LO contact |
| `NO_RESPONSE_48HR` | Lender not responding | Escalate to agent |
| `DEADLINE_AT_RISK` | Contingency may expire | Alert agent immediately |
| `CTC_DELAYED` | Won't clear in time | Coordinate extension |

## Quality Checklist

- [x] Tracks loan milestones
- [x] Follows up on appraisal
- [x] Monitors conditions
- [x] Requests clear-to-close
- [x] Ensures package delivery
- [x] Watches financing deadline
- [x] Escalates issues to agent
- [x] Maintains lender relationship

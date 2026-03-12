# Template: Status Update - Seller

**Category:** Communication > Templates
**Priority:** P1
**Auto-Send Eligible:** Yes (scheduled weekly updates)

## Purpose

Templates for keeping sellers informed about their transaction progress from contract acceptance through closing. Focuses on buyer performance, contingency timelines, and closing preparation. Designed to give sellers confidence that the deal is on track.

## Template Variants

### Email Templates

#### Contract Acceptance Confirmation
```
Subject: Offer Accepted! | {{deal.address.street}} - Next Steps

Hi {{recipient.firstName}},

Congratulations! Your offer on {{deal.address.street}} has been accepted. The buyer is excited to proceed, and we're officially under contract.

**Contract Summary:**
- Sale Price: {{deal.purchasePrice | formatCurrency}}
- Earnest Money: {{deal.earnestMoney | formatCurrency}}
- Option Fee: {{deal.optionFee | formatCurrency}}
- Closing Date: {{deal.closingDate | formatDate 'long'}}

**Buyer Information:**
- Buyer: {{buyer.name}}
- Financing: {{buyer.financingType}}
{{#if buyer.preApprovalAmount}}- Pre-approved: {{buyer.preApprovalAmount | formatCurrency}}{{/if}}

**Key Dates:**
{{#each keyDates}}
| {{this.name}} | {{this.date | formatDate}} |
{{/each}}

**What Happens Next:**
1. **Earnest Money** - Buyer deposits by {{deal.earnestMoneyDue | formatDate}}
2. **Option Period** - Buyer has until {{deal.optionExpires | formatDate}} for inspections
3. **Financing** - Buyer completes loan process
4. **Closing** - {{deal.closingDate | formatDate}}

**Your Responsibilities:**
{{#each sellerResponsibilities}}
- {{this.item}} {{#if this.deadline}}- By {{this.deadline | formatDate}}{{/if}}
{{/each}}

**Access for Inspections:**
The buyer will schedule a home inspection soon. I'll coordinate access with you. Please ensure:
- Property is accessible
- Utilities are on
- Pets are secured during inspections

I'll keep you updated throughout the process. Questions? Call me anytime at {{agent.phone}}.

{{signature}}
```

#### Weekly Status Update
```
Subject: Sale Update | {{deal.address.street}} - Week of {{currentDate | formatDate 'short'}}

Hi {{recipient.firstName}},

Here's your weekly update on the sale of {{deal.address.street}}.

**Transaction Status:**
- Stage: {{deal.stage | formatStageName}}
- Days to Closing: {{deal.daysToClosing}}
- Progress: {{deal.progressPercent}}% complete

---

**Buyer Performance:**

| Milestone | Due Date | Status |
|-----------|----------|--------|
{{#each buyerMilestones}}
| {{this.name}} | {{this.dueDate | formatDate 'short'}} | {{this.status}} |
{{/each}}

{{#if buyerIssues}}
**Note:** {{buyerIssues}}
{{else}}
The buyer is performing well and meeting all deadlines.
{{/if}}

---

**This Week's Activity:**
{{#each weeklyActivity}}
- {{this.date | formatDate 'short'}}: {{this.description}}
{{/each}}

{{#if noActivity}}
*Quiet week - everything is proceeding as expected.*
{{/if}}

---

**Upcoming:**
{{#each upcomingItems}}
- **{{this.item}}**: {{this.date | formatDate}}
{{/each}}

---

**Reminders for You:**
{{#if sellerReminders}}
{{#each sellerReminders}}
- {{this}}
{{/each}}
{{else}}
No action needed from you right now.
{{/if}}

---

**Your Estimated Proceeds:**
Based on current contract terms:
- Sale Price: {{deal.purchasePrice | formatCurrency}}
- Estimated Closing Costs: {{deal.estimatedSellerCosts | formatCurrency}}
- Mortgage Payoff: {{deal.mortgagePayoff | formatCurrency}}
- **Estimated Net Proceeds: {{deal.estimatedProceeds | formatCurrency}}**

*Final numbers will be confirmed on the closing disclosure.*

Questions? Just reply or call {{agent.phone}}.

{{signature}}
```

#### Option Period Update
```
Subject: Inspection Period Update | {{deal.address.street}}

Hi {{recipient.firstName}},

Here's an update on the buyer's option/inspection period for {{deal.address.street}}.

**Option Period:**
- Ends: {{deal.optionExpires | formatDate 'long'}} at {{deal.optionExpiresTime}}
- Days Remaining: {{deal.optionDaysRemaining}}

**Inspection Status:**
{{#if inspection.completed}}
- Completed: {{inspection.date | formatDate}}
- Inspector: {{inspection.inspectorName}}

**Buyer's Position:**
{{inspection.buyerPosition}}

{{#if repair.requested}}
**Repair Request Received:**
The buyer has submitted a repair request. Here's a summary:

{{#each repair.items}}
{{@index}}. {{this.item}}
   - Issue: {{this.description}}
   - Request: {{this.request}}
   - Estimated Cost: {{this.estimatedCost | formatCurrency}}
{{/each}}

**Total Estimated Cost:** {{repair.totalEstimated | formatCurrency}}

**Your Options:**
1. Agree to repairs
2. Counter with partial repairs
3. Offer closing credit instead
4. Decline (buyer may terminate during option)

I recommend we discuss your response. Call me at {{agent.phone}}.
{{/if}}

{{else}}
- Status: {{inspection.status}}
{{#if inspection.scheduled}}
- Scheduled: {{inspection.date | formatDate}} at {{inspection.time}}
{{/if}}
{{/if}}

**What to Expect:**
{{optionPeriodExpectation}}

{{signature}}
```

#### Financing Period Update
```
Subject: Buyer Financing Update | {{deal.address.street}}

Hi {{recipient.firstName}},

Update on the buyer's financing for {{deal.address.street}}.

**Financing Status:**
- Loan Type: {{buyer.loanType}}
- Status: {{loan.status}}
- Financing Contingency: {{#if loan.contingencyCleared}}Cleared{{else}}Active until {{loan.contingencyDate | formatDate}}{{/if}}

**Key Milestones:**
{{#each financingMilestones}}
- {{this.name}}: {{this.status}} {{#if this.date}}({{this.date | formatDate}}){{/if}}
{{/each}}

**Appraisal:**
{{#if appraisal.ordered}}
- Ordered: {{appraisal.orderedDate | formatDate}}
{{#if appraisal.scheduled}}
- Scheduled: {{appraisal.scheduledDate | formatDate}}
{{/if}}
{{#if appraisal.completed}}
- Completed: {{appraisal.completedDate | formatDate}}
- Appraised Value: {{appraisal.value | formatCurrency}}
{{#if appraisal.atOrAbove}}
- Result: At or above purchase price. No issues.
{{else}}
- Result: Below purchase price by {{appraisal.shortfall | formatCurrency}}
- {{appraisal.resolution}}
{{/if}}
{{/if}}
{{else}}
- Status: Appraisal pending order from lender
{{/if}}

**Access Requests:**
{{#if accessRequests}}
The buyer/lender has requested access for:
{{#each accessRequests}}
- {{this.purpose}}: {{this.date | formatDate}} at {{this.time}}
{{/each}}
{{else}}
No access requests at this time.
{{/if}}

**What This Means:**
{{financingAnalysis}}

{{signature}}
```

#### Final Week - Closing Preparation
```
Subject: {{deal.daysToClosing}} Days to Closing | {{deal.address.street}}

Hi {{recipient.firstName}},

We're almost there! Just {{deal.daysToClosing}} days until closing on {{deal.address.street}}.

**Closing Details:**
- Date: {{deal.closingDate | formatDate 'long'}}
- Time: {{deal.closingTime}}
- Location: {{deal.closingLocation}}

**Your Checklist:**

**Before Closing:**
{{#each sellerChecklist}}
- {{#if this.complete}}[x]{{else}}[ ]{{/if}} {{this.item}}
{{/each}}

**Day of Closing:**
- Bring valid photo ID
- Keys, garage remotes, gate codes
- Mailbox keys
- Home warranty info (if transferring)
- Any instruction manuals for appliances

**Move-Out:**
{{#if deal.leaseBack}}
You have a leaseback until {{deal.leasebackEnd | formatDate}}. Closing will proceed as scheduled, and you'll pay {{deal.leasebackRate | formatCurrency}} per day after closing.
{{else}}
Please complete move-out before closing. The buyer expects vacant possession at closing.
{{/if}}

**Final Walkthrough:**
The buyer will do a final walkthrough {{walkthrough.timing}}. Please ensure:
- All agreed repairs are complete
- Property is in the condition per contract
- Personal belongings removed (unless otherwise agreed)
- Property is clean and ready for new owners

**Your Proceeds:**
Based on the closing disclosure:
- Sale Price: {{deal.purchasePrice | formatCurrency}}
- Your Costs: {{deal.sellerClosingCosts | formatCurrency}}
- Mortgage Payoff: {{deal.mortgagePayoff | formatCurrency}}
- Prorations: {{deal.prorations | formatCurrency}}
- **Net Proceeds: {{deal.netProceeds | formatCurrency}}**

Proceeds will be wired to your account, typically within 24 hours of closing.

Congratulations on a successful sale!

{{signature}}
```

#### Closing Complete
```
Subject: SOLD! | {{deal.address.street}}

{{recipient.firstName}},

Congratulations - you've officially sold {{deal.address.street}}!

**Transaction Complete:**
- Sale Price: {{deal.purchasePrice | formatCurrency}}
- Closing Date: {{deal.closingDate | formatDate}}
- Status: Deed recorded

**Your Proceeds:**
- Net Amount: {{deal.netProceeds | formatCurrency}}
- Method: Wire transfer
- Expected: {{proceeds.expectedDate | formatDate}}

**Final Items:**
{{#each finalItems}}
- {{this}}
{{/each}}

**Document Delivery:**
Your signed closing documents will arrive within {{document.deliveryTime}}.

**Thank You:**
It's been a pleasure helping you sell your home. {{personalNote}}

If you ever need real estate assistance again - or know someone who does - I'd be honored to help. Referrals are the greatest compliment you can give.

Wishing you all the best in your next chapter!

{{signature}}
```

### SMS Templates

#### Contract Accepted
```
{{agent.firstName}}: Great news! Offer accepted on {{deal.address.street | abbreviateAddress}} - {{deal.purchasePrice | formatCurrency}}. Closing {{deal.closingDate | formatShortDate}}. Details in email. Congrats!
```

#### Weekly Status
```
{{agent.firstName}}: {{deal.address.street | abbreviateAddress}} update: Buyer on track, {{deal.daysToClosing}} days to closing. {{#if actionNeeded}}{{actionNeeded}}{{else}}All good!{{/if}} Questions? {{agent.phone}}
```

#### Inspection Complete
```
{{agent.firstName}}: Buyer inspection complete for {{deal.address.street | abbreviateAddress}}. {{inspection.briefSummary}}. Details in email - let's discuss. {{agent.phone}}
```

#### Closing Week
```
{{agent.firstName}}: Final week! Closing {{deal.closingDate | formatShortDate}} for {{deal.address.street | abbreviateAddress}}. Checklist in email. Almost there!
```

## Template Variables

| Variable | Type | Description | Example |
|----------|------|-------------|---------|
| `deal.stage` | string | Current stage | "financing" |
| `deal.progressPercent` | number | Overall progress | 65 |
| `deal.daysToClosing` | number | Days until closing | 15 |
| `deal.purchasePrice` | number | Sale price | 450000 |
| `deal.estimatedProceeds` | number | Seller net estimate | 125000 |
| `deal.netProceeds` | number | Final net proceeds | 124500 |
| `buyer.name` | string | Buyer name | "John Smith" |
| `buyer.financingType` | string | Financing type | "Conventional" |
| `buyerMilestones` | object[] | Buyer performance | [{name, status}] |
| `repair.items` | object[] | Repair requests | [{item, cost}] |
| `appraisal.value` | number | Appraised value | 455000 |
| `sellerChecklist` | object[] | Seller to-dos | [{item, complete}] |

## Update Focus by Stage

| Stage | Focus | Key Info |
|-------|-------|----------|
| Week 1 | Contract terms, timeline | Buyer info, key dates |
| Option Period | Inspections, repairs | Repair requests, options |
| Financing | Buyer loan progress | Appraisal, clear to close |
| Pre-Closing | Move-out, preparation | Checklist, proceeds estimate |
| Closing | Final details | What to bring, walkthrough |

## Auto-Send Rules

| Trigger | Template | Auto-Send | Timing |
|---------|----------|-----------|--------|
| Contract executed | Acceptance Confirmation | Yes | Immediate |
| Weekly schedule | Weekly Status | Yes | Monday 9 AM |
| Inspection complete | Option Period Update | Yes | Immediate |
| 7 days to closing | Final Week | Yes | Automatic |
| Closing complete | Sold Confirmation | Yes | Immediate |

## Seller-Specific Concerns

### Address Proactively
- Buyer performance/reliability
- Timeline adherence
- Net proceeds estimates
- Move-out coordination
- Repair negotiations

### Tone Guidelines
- Reassuring about buyer performance
- Transparent about issues
- Solution-oriented on challenges
- Celebratory at closing

## Quality Checklist

- [x] Tracks buyer performance milestones
- [x] Reports on contingency status
- [x] Provides proceeds estimates
- [x] Covers move-out preparation
- [x] Handles repair negotiations
- [x] Coordinates access requests
- [x] Confirms closing details
- [x] Celebrates successful sale

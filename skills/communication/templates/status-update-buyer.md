# Template: Status Update - Buyer

**Category:** Communication > Templates
**Priority:** P1
**Auto-Send Eligible:** Yes (scheduled weekly updates)

## Purpose

Templates for keeping buyers informed about their transaction progress. Covers all stages from contract acceptance through closing. Designed to reduce buyer anxiety by providing proactive, regular updates on deal status, milestones, and next steps.

## Template Variants

### Email Templates

#### Weekly Status Update (Generic)
```
Subject: Your Transaction Update | {{deal.address.street}} - Week of {{currentDate | formatDate 'short'}}

Hi {{recipient.firstName}},

Here's your weekly update on {{deal.address.street}}!

**Current Status:** {{deal.stage | formatStageName}}
**Days in Contract:** {{deal.daysInContract}}
**Progress:** {{deal.progressPercent}}% complete

---

**What's Happened This Week:**
{{#each weeklyActivity}}
- {{this.date | formatDate 'short'}}: {{this.description}}
{{/each}}

{{#if noActivity}}
*This was a quiet week with no major activity. Everything is proceeding normally.*
{{/if}}

---

**Upcoming Milestones:**
{{#each upcomingMilestones}}
- **{{this.name}}**: {{this.date | formatDate}} {{#if this.daysAway}}({{this.daysAway}} days){{/if}}
{{/each}}

---

**Action Items for You:**
{{#if buyerActionItems}}
{{#each buyerActionItems}}
- [ ] {{this.item}} {{#if this.deadline}}- Due {{this.deadline | formatDate}}{{/if}}
{{/each}}
{{else}}
No action needed from you right now! We'll reach out when we need anything.
{{/if}}

---

**Key Dates:**
| Milestone | Date | Status |
|-----------|------|--------|
{{#each keyDates}}
| {{this.name}} | {{this.date | formatDate 'short'}} | {{this.status}} |
{{/each}}

---

Questions? Just reply to this email or call me at {{agent.phone}}.

{{signature}}
```

#### Under Contract - First Week
```
Subject: Your Home is Under Contract! | {{deal.address.street}}

Hi {{recipient.firstName}},

Congratulations again on getting {{deal.address.street}} under contract! I wanted to give you an overview of what happens next and our timeline.

**Contract Summary:**
- Purchase Price: {{deal.purchasePrice | formatCurrency}}
- Earnest Money: {{deal.earnestMoney | formatCurrency}} (due {{deal.earnestMoneyDue | formatDate}})
- Closing Date: {{deal.closingDate | formatDate 'long'}}

**Your Timeline:**
{{#each timeline}}
{{@index}}. **{{this.milestone}}** - {{this.date | formatDate}}
   {{this.description}}
{{/each}}

**This Week's Priorities:**
1. **Earnest Money** - Due {{deal.earnestMoneyDue | formatDate}}. I'll send payment instructions.
2. **Home Inspection** - Schedule ASAP. {{#if inspection.recommended}}Recommended inspectors attached.{{/if}}
3. **Loan Application** - If not already done, finalize with your lender.

**Upcoming Deadlines:**
{{#each urgentDeadlines}}
- {{this.name}}: {{this.date | formatDate}} ({{this.daysAway}} days)
{{/each}}

**Your Team:**
- Your Agent: {{agent.name}} - {{agent.phone}}
- Lender: {{lender.name}} - {{lender.phone}}
- Title Company: {{titleCompany.name}} - {{titleCompany.phone}}

I'll send you weekly updates every {{updateDay}}, plus immediate updates when anything significant happens.

Let's get you to closing!

{{signature}}
```

#### Option/Due Diligence Period
```
Subject: Option Period Update | {{deal.address.street}} - {{deal.optionDaysRemaining}} Days Remaining

Hi {{recipient.firstName}},

Here's where we stand during your option period for {{deal.address.street}}.

**Option Period Status:**
- Started: {{deal.optionStart | formatDate}}
- Expires: {{deal.optionExpires | formatDate 'long'}} at {{deal.optionExpiresTime}}
- Days Remaining: {{deal.optionDaysRemaining}}

**Inspection Status:**
{{#if inspection.completed}}
- Inspection Complete: {{inspection.date | formatDate}}
- Report: {{#if inspection.reportUrl}}[View Report]({{inspection.reportUrl}}){{else}}Attached{{/if}}
- Key Findings: {{inspection.findingsSummary}}
{{else}}
- Status: {{inspection.status}}
{{#if inspection.scheduled}}
- Scheduled: {{inspection.date | formatDate}} at {{inspection.time}}
{{else}}
- **Action Needed**: Please schedule your inspection ASAP
{{/if}}
{{/if}}

**Your Options Before {{deal.optionExpires | formatDate}}:**
1. **Proceed with purchase** - Continue as planned
2. **Request repairs** - Submit repair amendment
3. **Negotiate credit** - Request closing cost credit
4. **Terminate** - Exercise option to terminate (earnest money refunded minus option fee)

{{#if inspection.completed}}
**Recommendation:**
{{inspection.recommendation}}
{{/if}}

**What Happens Next:**
{{#if repair.needed}}
If requesting repairs, we need to submit by {{repair.deadline | formatDate}} to allow seller response time.
{{else}}
If you're comfortable proceeding, no action needed - we move forward automatically after option expires.
{{/if}}

Let's discuss! Call me at {{agent.phone}}.

{{signature}}
```

#### Financing/Appraisal Period
```
Subject: Financing Update | {{deal.address.street}}

Hi {{recipient.firstName}},

Here's your financing status update for {{deal.address.street}}.

**Loan Status:**
- Loan Type: {{loan.type}}
- Lender: {{loan.lenderName}}
- Loan Officer: {{loan.officerName}} ({{loan.officerPhone}})
- Status: {{loan.status}}

**Financing Timeline:**
| Milestone | Due Date | Status |
|-----------|----------|--------|
{{#each financingMilestones}}
| {{this.name}} | {{this.date | formatDate 'short'}} | {{this.status}} |
{{/each}}

**Appraisal Status:**
{{#if appraisal.ordered}}
- Ordered: {{appraisal.orderedDate | formatDate}}
- Scheduled: {{appraisal.scheduledDate | formatDate}} {{#if appraisal.scheduledTime}}at {{appraisal.scheduledTime}}{{/if}}
{{#if appraisal.completed}}
- Completed: {{appraisal.completedDate | formatDate}}
- Value: {{appraisal.value | formatCurrency}}
- Status: {{appraisal.status}}
{{/if}}
{{else}}
- Status: Pending lender order
{{/if}}

{{#if appraisal.valueIssue}}
**Appraisal Note:**
The appraised value ({{appraisal.value | formatCurrency}}) is {{appraisal.difference | formatCurrency}} {{appraisal.differenceDirection}} the purchase price. {{appraisal.recommendation}}
{{/if}}

**Items Still Needed by Lender:**
{{#if lenderNeedsItems}}
{{#each lenderNeedsItems}}
- {{this.item}} {{#if this.deadline}}- Due {{this.deadline | formatDate}}{{/if}}
{{/each}}
{{else}}
Your lender has everything they need!
{{/if}}

**Next Steps:**
{{nextSteps}}

{{signature}}
```

#### Final Week Before Closing
```
Subject: 1 Week to Closing! | {{deal.address.street}}

Hi {{recipient.firstName}},

We're in the final stretch! Just {{deal.daysToClosing}} days until you own {{deal.address.street}}.

**Closing Details:**
- Date: {{deal.closingDate | formatDate 'long'}}
- Time: {{deal.closingTime}}
- Location: {{deal.closingLocation}}
- Address: {{deal.closingAddress}}

**Final Week Checklist:**

**Completed:**
{{#each completedItems}}
- [x] {{this}}
{{/each}}

**This Week:**
{{#each thisWeekItems}}
- [ ] {{this.item}} {{#if this.date}}- {{this.date | formatDate}}{{/if}}
{{/each}}

**Final Walkthrough:**
{{#if walkthrough.scheduled}}
Scheduled for {{walkthrough.date | formatDate}} at {{walkthrough.time}}
{{else}}
We'll schedule this for 24-48 hours before closing. I'll coordinate with the seller.
{{/if}}

**Wire Transfer:**
- Amount: {{closing.wireAmount | formatCurrency}}
- Instructions: {{closing.wireInstructionsStatus}}
- Send by: {{closing.wireDeadline | formatDate}}
{{#if closing.wireSent}}
- Status: Wire received!
{{/if}}

**What to Bring to Closing:**
- Valid photo ID (driver's license or passport)
- Secondary ID (if required)
- Certified funds or wire confirmation
- This is it - you're about to be a homeowner!

Almost there!

{{signature}}
```

### SMS Templates

#### Quick Status Check
```
{{agent.firstName}}: Quick update on {{deal.address.street | abbreviateAddress}}: {{deal.briefStatus}}. {{#if actionNeeded}}Need: {{actionNeeded}}.{{/if}} Questions? {{agent.phone}}
```

#### Milestone Completed
```
{{agent.firstName}}: Great news for {{deal.address.street | abbreviateAddress}}! {{milestone.name}} complete. Next up: {{nextMilestone}}. On track for {{deal.closingDate | formatShortDate}} closing!
```

#### Weekly Ping
```
{{agent.firstName}}: {{deal.address.street | abbreviateAddress}} update: {{deal.progressPercent}}% complete. {{deal.daysToClosing}} days to closing. Full update in your email. Questions? Call me!
```

## Template Variables

| Variable | Type | Description | Example |
|----------|------|-------------|---------|
| `deal.stage` | string | Current stage | "option_period" |
| `deal.progressPercent` | number | Overall progress | 45 |
| `deal.daysInContract` | number | Days since acceptance | 12 |
| `deal.daysToClosing` | number | Days until closing | 23 |
| `deal.purchasePrice` | number | Purchase price | 450000 |
| `deal.closingDate` | Date | Closing date | 2025-02-15 |
| `weeklyActivity` | object[] | This week's events | [{date, description}] |
| `upcomingMilestones` | object[] | Next milestones | [{name, date}] |
| `buyerActionItems` | object[] | Buyer to-dos | [{item, deadline}] |
| `inspection.status` | string | Inspection status | "completed" |
| `loan.status` | string | Loan status | "underwriting" |
| `appraisal.value` | number | Appraised value | 455000 |

## Update Frequency

| Stage | Frequency | Template |
|-------|-----------|----------|
| Week 1 | Immediate + Day 3 | First Week |
| Option Period | Every 2-3 days | Option Period |
| Financing | Weekly | Financing Update |
| Pending Closing | Weekly | Weekly Status |
| Final Week | Daily | Final Week |

## Auto-Send Rules

| Trigger | Template | Auto-Send | Day/Time |
|---------|----------|-----------|----------|
| Contract accepted | First Week | Yes | Immediate |
| Weekly schedule | Weekly Status | Yes | Monday 9 AM |
| Milestone complete | Milestone SMS | Yes | Immediate |
| Option expiring (3 days) | Option Period | Yes | Automatic |
| 7 days to closing | Final Week | Yes | Automatic |

## Personalization

### By Buyer Type
- **First-time buyer**: More explanation, reassurance
- **Experienced buyer**: More concise, assume knowledge
- **Investor**: Focus on numbers and timeline

### By Deal Status
- **On track**: Celebratory tone
- **Delayed**: Explanation and resolution focus
- **Issues**: Empathetic, solution-oriented

## Quality Checklist

- [x] Covers all transaction stages
- [x] Includes clear progress indicators
- [x] Lists specific action items
- [x] Provides key dates and deadlines
- [x] Offers contact information
- [x] Adapts to transaction status
- [x] Reduces buyer anxiety
- [x] Sent on reliable schedule

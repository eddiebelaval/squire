# Template: Deadline Reminder

**Category:** Communication > Templates
**Priority:** P0
**Auto-Send Eligible:** Yes (system-triggered deadline alerts)

## Purpose

Multi-channel template for reminding parties about upcoming transaction deadlines. Supports varying urgency levels based on time remaining and deadline criticality. Used for contingency expirations, document due dates, and milestone deadlines.

## Template Variants

### Email Templates

#### 7+ Days Out (Gentle Reminder)
```
Subject: Upcoming Deadline - {{deadline.name}} | {{deal.address.street}}

Hi {{recipient.firstName}},

I wanted to give you advance notice about an upcoming deadline for your transaction at {{deal.address.street}}:

**{{deadline.name}}**
Due: {{deadline.dueDate | formatDate 'long'}}
{{#if deadline.dueTime}}Time: {{deadline.dueTime | formatTime}}{{/if}}

{{#if deadline.description}}
{{deadline.description}}
{{/if}}

**What you need to do:**
{{#each deadline.actionItems}}
- {{this}}
{{/each}}

{{#if deadline.preparationTips}}
**To prepare:**
{{#each deadline.preparationTips}}
- {{this}}
{{/each}}
{{/if}}

This gives you {{deadline.daysRemaining}} days to prepare. Please let me know if you have any questions or need assistance.

{{signature}}
```

#### 3-6 Days Out (Standard Reminder)
```
Subject: Reminder: {{deadline.name}} Due {{deadline.dueDate | formatDate}} | {{deal.address.street}}

Hi {{recipient.firstName}},

This is a reminder about an important deadline coming up for {{deal.address.street}}:

**{{deadline.name}}**
Due: {{deadline.dueDate | formatDate 'long'}}
{{#if deadline.dueTime}}Time: {{deadline.dueTime | formatTime}}{{/if}}

{{#if deadline.actionRequired}}
**Action Required:** {{deadline.actionRequired}}
{{/if}}

{{#if deadline.consequences}}
*Please note: {{deadline.consequences}}*
{{/if}}

You have {{deadline.daysRemaining}} days remaining. Please reach out if you need any help meeting this deadline.

{{signature}}
```

#### 1-2 Days Out (Urgent Reminder)
```
Subject: [ACTION NEEDED] {{deadline.name}} Due {{deadline.dueDate | formatDate}} | {{deal.address.street}}

Hi {{recipient.firstName}},

**This deadline is coming up soon:**

**{{deadline.name}}**
Due: {{deadline.dueDate | formatDate 'long'}}
{{#if deadline.dueTime}}Time: {{deadline.dueTime | formatTime}}{{/if}}

{{#if deadline.actionRequired}}
**What's needed:** {{deadline.actionRequired}}
{{/if}}

{{#if deadline.consequences}}
**Important:** {{deadline.consequences}}
{{/if}}

You have **{{deadline.daysRemaining}} day(s)** remaining. Please confirm you're on track or let me know if you need assistance.

Call me at {{agent.phone}} if you have any questions.

{{signature}}
```

#### Same Day (Critical)
```
Subject: [URGENT - TODAY] {{deadline.name}} Due Today | {{deal.address.street}}

Hi {{recipient.firstName}},

**Today is the deadline for:**

**{{deadline.name}}**
Due: TODAY, {{deadline.dueDate | formatDate 'long'}}
{{#if deadline.dueTime}}By: {{deadline.dueTime | formatTime}}{{/if}}

**Required action:** {{deadline.actionRequired}}

{{#if deadline.consequences}}
**If missed:** {{deadline.consequences}}
{{/if}}

Please complete this immediately and confirm with me. If you're unable to meet this deadline, call me right away at {{agent.phone}}.

{{signature}}
```

### SMS Templates

#### Standard Reminder (3+ days)
```
{{agent.firstName}}: Reminder - {{deadline.name}} due {{deadline.dueDate | formatShortDate}} for {{deal.address.street | abbreviateAddress}}. {{deadline.briefAction}}. Questions? {{agent.phone}}
```

#### Urgent Reminder (1-2 days)
```
{{agent.firstName}}: {{deadline.name}} due {{deadline.dueDate | formatShortDate}}! {{deadline.briefAction}} for {{deal.address.street | abbreviateAddress}}. Please confirm. {{agent.phone}}
```

#### Same Day (Critical)
```
[URGENT] {{deadline.name}} due TODAY for {{deal.address.street | abbreviateAddress}}. {{deadline.briefAction}}. Call {{agent.phone}} if any issues. -{{agent.firstName}}
```

### Voice Call Scripts

#### Standard Reminder
```
Opening: "Hi {{recipient.firstName}}, this is {{voiceName}} calling on behalf of
{{agent.name}} regarding your property at {{deal.address.street}}."

Main Point: "I'm calling to remind you about the upcoming {{deadline.name}} deadline
on {{deadline.dueDate | formatDate}}."

Details: "{{deadline.description}}. {{deadline.actionRequired}}."

Closing: "Do you have any questions about this deadline? Would you like
{{agent.firstName}} to call you to discuss?"
```

#### Urgent/Same Day
```
Opening: "Hi {{recipient.firstName}}, this is an important call from
{{agent.brokerage}} regarding your property at {{deal.address.street}}."

Urgency: "The {{deadline.name}} deadline is {{#if sameDay}}TODAY{{else}}in {{deadline.daysRemaining}} day(s){{/if}}."

Action: "We need {{deadline.actionRequired}}. {{#if deadline.consequences}}If this is missed, {{deadline.consequences}}.{{/if}}"

Closing: "Are you able to complete this today? Do you need {{agent.firstName}} to assist?"
```

## Template Variables

| Variable | Type | Description | Example |
|----------|------|-------------|---------|
| `recipient.firstName` | string | Recipient's first name | "John" |
| `recipient.email` | string | Recipient's email | "john@email.com" |
| `deal.address.street` | string | Property street address | "123 Main St" |
| `deal.address.city` | string | City | "Austin" |
| `deadline.name` | string | Deadline name | "Inspection Contingency" |
| `deadline.dueDate` | Date | Due date | 2025-01-20 |
| `deadline.dueTime` | string | Due time (optional) | "5:00 PM" |
| `deadline.daysRemaining` | number | Days until due | 3 |
| `deadline.description` | string | Full description | "Period for completing..." |
| `deadline.actionRequired` | string | What needs to be done | "Complete inspection" |
| `deadline.actionItems` | string[] | List of action items | ["Schedule inspector", "Review report"] |
| `deadline.consequences` | string | What happens if missed | "Contingency expires" |
| `deadline.preparationTips` | string[] | Preparation suggestions | ["Gather documents"] |
| `deadline.briefAction` | string | Short action (for SMS) | "Complete inspection" |
| `agent.firstName` | string | Agent's first name | "Sarah" |
| `agent.name` | string | Agent's full name | "Sarah Johnson" |
| `agent.phone` | string | Agent's phone | "(512) 555-0123" |
| `agent.brokerage` | string | Brokerage name | "Premier Realty" |

## Urgency Levels

| Days Remaining | Urgency | Email Subject Prefix | SMS Emoji |
|----------------|---------|---------------------|-----------|
| 7+ | Gentle | None | None |
| 3-6 | Standard | "Reminder:" | None |
| 1-2 | Urgent | "[ACTION NEEDED]" | None |
| 0 (same day) | Critical | "[URGENT - TODAY]" | None |
| Overdue | Expired | "[OVERDUE]" | Warning |

## Channel Selection Logic

| Scenario | Channels | Timing |
|----------|----------|--------|
| 7+ days, routine | Email only | Morning |
| 3-6 days | Email | Morning |
| 1-2 days | Email + SMS | Morning |
| Same day | Email + SMS + Call | ASAP |
| Overdue | All channels + Agent alert | Immediate |

## Deadline Types

### Contract Deadlines
- Option Period Expiration
- Inspection Contingency
- Financing Contingency
- Appraisal Contingency
- Title Review Period
- Survey Review Period

### Document Deadlines
- Pre-approval Letter
- Proof of Funds
- HOA Documents
- Disclosure Signatures
- Amendment Signatures

### Milestone Deadlines
- Earnest Money Deposit
- Final Walkthrough
- Closing Date
- Possession Date

## Auto-Send Rules

| Deadline Type | Days Out | Auto-Send |
|---------------|----------|-----------|
| Contract deadline | 3+ | Yes |
| Document deadline | 3+ | Yes |
| Any deadline | 1-2 | Yes |
| Any deadline | Same day | Yes |
| Overdue | Any | Agent alert |

## Personalization Rules

1. **Recipient Role Adjustments:**
   - Buyer: Focus on contingency implications
   - Seller: Focus on deal timeline impact
   - Lender: Focus on loan timeline
   - Attorney: Formal language

2. **Deal Stage Adjustments:**
   - Early stage: More explanation
   - Late stage: Assume familiarity
   - Near closing: Higher urgency

3. **Previous Response History:**
   - Responsive party: Lighter touch
   - Unresponsive party: Stronger language

## Error Handling

| Error | Cause | Response |
|-------|-------|----------|
| `DEADLINE_PASSED` | Already expired | Alert agent, stop reminders |
| `NO_RECIPIENT_CONTACT` | Missing email/phone | Alert agent |
| `RECENTLY_REMINDED` | Sent within 24 hours | Skip, schedule next |

## Quality Checklist

- [x] Adapts content to urgency level
- [x] Selects appropriate channels
- [x] Personalizes by recipient role
- [x] Includes clear action required
- [x] States consequences when relevant
- [x] Provides agent contact for questions
- [x] Tracks reminder history
- [x] Escalates appropriately

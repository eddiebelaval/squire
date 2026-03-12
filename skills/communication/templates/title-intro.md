# Template: Title Introduction

**Category:** Communication > Templates
**Priority:** P1
**Auto-Send Eligible:** Yes (on title company assignment)

## Purpose

Templates for introducing parties to the title company handling their transaction. Establishes the relationship, provides contact information, explains the title company's role, and sets expectations for the title/escrow process.

## Template Variants

### Email Templates

#### Buyer Introduction to Title
```
Subject: Meet Your Title Company | {{deal.address.street}}

Hi {{recipient.firstName}},

I'd like to introduce you to the title company that will be handling your closing for {{deal.address.street}}.

**Your Title Company:**
{{titleCompany.name}}
{{titleCompany.address}}
{{titleCompany.phone}}

**Your Closer:**
{{closer.name}}, {{closer.title}}
Email: {{closer.email}}
Direct: {{closer.phone}}

**What the Title Company Does:**
1. **Title Search** - Researches property ownership history to ensure clear title
2. **Title Insurance** - Protects you against title defects or claims
3. **Escrow Services** - Holds earnest money and manages closing funds
4. **Closing Coordination** - Prepares documents and conducts closing
5. **Recording** - Files the deed with the county after closing

**Key Dates:**
- Earnest Money Due: {{deal.earnestMoneyDue | formatDate}}
- Closing Date: {{deal.closingDate | formatDate 'long'}}

**What to Expect:**
{{#each titleProcess}}
- {{this.step}}: {{this.timing}}
{{/each}}

**Wire Fraud Warning:**
When you receive wire instructions from {{titleCompany.name}}, ALWAYS verify by calling them at {{closer.phone}} before sending any funds. Never rely solely on email instructions.

{{closer.name}} will be reaching out soon. In the meantime, feel free to contact them with any title-related questions.

{{signature}}

---
cc: {{closer.name}} <{{closer.email}}>
```

#### Seller Introduction to Title
```
Subject: Title Company Introduction | {{deal.address.street}}

Hi {{recipient.firstName}},

Your sale of {{deal.address.street}} will be closed by the title company below. I wanted to make the introduction.

**Title Company:**
{{titleCompany.name}}
{{titleCompany.address}}

**Your Closer:**
{{closer.name}}
{{closer.email}} | {{closer.phone}}

**What They'll Handle:**
- Title search and clearance
- Preparation of deed and closing documents
- Collection of payoff amounts
- Distribution of proceeds to you
- Recording of documents with the county

**What They'll Need From You:**
{{#each sellerRequirements}}
- {{this.item}} {{#if this.deadline}}- Due {{this.deadline | formatDate}}{{/if}}
{{/each}}

**Mortgage Payoff:**
{{closer.name}} will order your mortgage payoff statement. If you have multiple mortgages, liens, or HOA dues, please let them know.

**Proceeds:**
After closing, your net proceeds will be wired to your bank account, typically within 24 hours. {{closer.name}} will collect your wiring information closer to closing.

**Timeline:**
{{#each sellerTimeline}}
- {{this.milestone}}: {{this.timing}}
{{/each}}

They'll be in touch soon. Questions in the meantime? Reach out to me or {{closer.firstName}} directly.

{{signature}}

---
cc: {{closer.name}} <{{closer.email}}>
```

#### Both Parties Introduction (Transaction Coordinator Style)
```
Subject: Title Company Information | {{deal.address.street}}

Hello,

I'm pleased to share the title company information for our transaction at {{deal.address.street}}.

**Title Company:**
{{titleCompany.name}}
{{titleCompany.address}}
Main: {{titleCompany.phone}}

**Your Closer:**
{{closer.name}}, {{closer.title}}
Email: {{closer.email}}
Direct: {{closer.phone}}

**Transaction Details:**
- Property: {{deal.address.full}}
- Buyer: {{buyer.name}}
- Seller: {{seller.name}}
- Closing Date: {{deal.closingDate | formatDate 'long'}}

**Title Company Role:**
{{titleCompany.name}} will handle all aspects of closing including:
- Title examination and insurance
- Escrow account management
- Document preparation
- Funds disbursement
- Recording with {{deal.county}} County

**Next Steps:**
{{#each nextSteps}}
- {{this.party}}: {{this.action}} {{#if this.deadline}}by {{this.deadline | formatDate}}{{/if}}
{{/each}}

**Important Reminder:**
Please verify any wire instructions by phone before sending funds. Call {{closer.phone}} directly - do not use numbers provided in emails.

{{closer.name}} will be in contact shortly. Please don't hesitate to reach out with questions.

{{signature}}

---
cc: {{closer.name}} <{{closer.email}}>
```

#### Lender Introduction to Title
```
Subject: Title Company Contact | {{deal.address.street}} - {{deal.mlsNumber}}

Hi {{recipient.firstName}},

Here is the title company information for the transaction at {{deal.address.street}}.

**Title Company:**
{{titleCompany.name}}
{{titleCompany.address}}
Phone: {{titleCompany.phone}}
Fax: {{titleCompany.fax}}

**Closer:**
{{closer.name}}
{{closer.email}}
{{closer.phone}}

**Transaction Details:**
- Property: {{deal.address.full}}
- Buyer: {{buyer.name}}
- Loan Amount: {{loan.amount | formatCurrency}}
- Closing Date: {{deal.closingDate | formatDate}}

**For Closing Package Delivery:**
{{#if titleCompany.closingPackageEmail}}
Email to: {{titleCompany.closingPackageEmail}}
{{/if}}
{{#if titleCompany.closingPackageFax}}
Fax to: {{titleCompany.closingPackageFax}}
{{/if}}

**Title Commitment:**
{{#if title.commitmentStatus}}
Status: {{title.commitmentStatus}}
{{#if title.commitmentSentDate}}
Sent: {{title.commitmentSentDate | formatDate}}
{{/if}}
{{else}}
Will be issued within {{title.commitmentExpectedDays}} business days.
{{/if}}

Please reach out to {{closer.firstName}} for any title-related questions.

{{signature}}
```

### SMS Templates

#### Quick Introduction
```
{{agent.firstName}}: Title company for {{deal.address.street | abbreviateAddress}}: {{titleCompany.name}}. Your closer is {{closer.name}} at {{closer.phone}}. They'll reach out soon!
```

#### Closer Contact
```
{{agent.firstName}}: Need to reach your title closer? {{closer.name}} at {{titleCompany.name}}: {{closer.phone}} or {{closer.email}}. They handle all closing questions.
```

## Template Variables

| Variable | Type | Description | Example |
|----------|------|-------------|---------|
| `titleCompany.name` | string | Company name | "First American Title" |
| `titleCompany.address` | string | Full address | "100 Title Way, Austin TX" |
| `titleCompany.phone` | string | Main phone | "(512) 555-1234" |
| `titleCompany.fax` | string | Fax number | "(512) 555-1235" |
| `closer.name` | string | Closer's full name | "Jennifer Smith" |
| `closer.firstName` | string | Closer's first name | "Jennifer" |
| `closer.title` | string | Closer's title | "Escrow Officer" |
| `closer.email` | string | Closer's email | "jsmith@title.com" |
| `closer.phone` | string | Closer's direct | "(512) 555-1236" |
| `title.commitmentStatus` | string | Title status | "Issued" |
| `sellerRequirements` | object[] | What seller needs to provide | [{item, deadline}] |
| `titleProcess` | object[] | Process steps | [{step, timing}] |

## Title Process Overview

### Typical Timeline
| Step | Timing | Notes |
|------|--------|-------|
| Title ordered | Day 1-2 | After contract execution |
| Title search | 3-5 days | Research property history |
| Commitment issued | 5-7 days | Lists exceptions, requirements |
| Curative work | As needed | Clear any issues |
| Closing package prep | 2-3 days before | Prepare all documents |
| Closing | Scheduled date | Sign and fund |
| Recording | Same day | File with county |
| Disbursement | Same/next day | Distribute funds |

## Auto-Send Rules

| Trigger | Template | Recipient | Auto-Send |
|---------|----------|-----------|-----------|
| Title company assigned | Buyer Intro | Buyer | Yes |
| Title company assigned | Seller Intro | Seller | Yes |
| Title ordered | Lender Intro | Lender | Yes |
| File opened | Both Parties | All | Optional |

## Contact Scenarios

### When to Contact Title
- Questions about closing costs
- Wire instruction verification
- Title commitment questions
- Closing date/time coordination
- Document corrections
- Proceeds timing

### When to Contact Agent First
- Contract amendments
- Repair negotiations
- Deadline extensions
- Access issues
- Party disputes

## Error Handling

| Error | Cause | Response |
|-------|-------|----------|
| `NO_TITLE_COMPANY` | Not yet assigned | Wait for assignment |
| `CLOSER_NOT_ASSIGNED` | No specific closer | Use general title contact |
| `CONTACT_INFO_MISSING` | Incomplete info | Request from title company |

## Quality Checklist

- [x] Introduces title company and closer by name
- [x] Provides all contact methods
- [x] Explains title company role
- [x] Sets expectations for process
- [x] Lists what's needed from party
- [x] Includes wire fraud warning
- [x] CCs closer on introduction
- [x] Appropriate for recipient role

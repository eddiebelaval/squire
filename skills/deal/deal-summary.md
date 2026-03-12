# Skill: Deal Summary

**Category:** Deal
**Priority:** P1
**Approval Required:** No

## Purpose

Generate comprehensive status reports for real estate transactions. This skill creates formatted summaries suitable for different audiences (agents, clients, title company, lender) with the appropriate level of detail and tone.

## Triggers

### Voice Commands
- "Summarize the [address] deal"
- "Give me a deal update for [address]"
- "Send [address] status to [party]"
- "What's the summary on [address]?"
- "Deal recap for [address]"
- "Brief me on [address]"
- "Prepare update for [client] on [address]"

### Programmatic
- Scheduled weekly summaries
- Pre-meeting brief generation
- API call to `/deals/{id}/summary`
- Email digest trigger
- Report generation request

## Required Inputs

| Input | Type | Required | Source | Description |
|-------|------|----------|--------|-------------|
| `dealId` | UUID | Yes* | context/manual | Deal to summarize |
| `propertyAddress` | string | Yes* | voice | Can identify deal by address |

*One of dealId or propertyAddress required

## Optional Inputs

| Input | Type | Default | Source | Description |
|-------|------|---------|--------|-------------|
| `audience` | string | 'agent' | voice/manual | Target audience (see below) |
| `format` | string | 'text' | manual | Output format (text/html/pdf) |
| `includeTimeline` | boolean | true | config | Include milestone timeline |
| `includeNextSteps` | boolean | true | config | Include recommended actions |
| `includeHistory` | boolean | false | config | Include full action history |
| `dateRange` | object | null | manual | Filter to specific date range |
| `sendTo` | string[] | null | voice | Email recipients |

## Audience Types

| Audience | Tone | Content Focus | Detail Level |
|----------|------|---------------|--------------|
| `agent` | Professional | All details, internal notes | Full |
| `buyer` | Friendly | Buyer-relevant items, encouraging | Medium |
| `seller` | Friendly | Seller-relevant items, professional | Medium |
| `lender` | Formal | Loan-related deadlines, property info | Specific |
| `title` | Formal | Transaction details, parties, dates | Specific |
| `all_parties` | Professional | Shared update, no confidential info | Medium |
| `broker` | Executive | Key metrics, risks, needs | High-level |

## Execution Flow

```
START
  │
  ├─── 1. Identify deal
  │    ├── If dealId provided → load deal
  │    ├── If propertyAddress provided → find deal
  │    └── Verify deal exists
  │
  ├─── 2. Determine audience
  │    ├── Parse from voice command (if mentioned)
  │    ├── Use provided audience parameter
  │    └── Default to 'agent' if not specified
  │
  ├─── 3. Gather deal data
  │    ├── Core deal information
  │    ├── All parties and contacts
  │    ├── Deadline status
  │    ├── Document status
  │    ├── Financial details
  │    ├── Recent activity
  │    └── Notes (filtered by audience)
  │
  ├─── 4. Calculate key metrics
  │    ├── Days under contract
  │    ├── Days until closing
  │    ├── Completion percentage
  │    ├── Health score
  │    └── Milestones hit/remaining
  │
  ├─── 5. Filter for audience
  │    ├── Remove confidential information
  │    ├── Adjust language/tone
  │    ├── Focus on relevant sections
  │    └── Exclude internal notes (client views)
  │
  ├─── 6. Generate timeline (if includeTimeline)
  │    ├── Key milestones completed
  │    ├── Upcoming milestones
  │    ├── Current position in process
  │    └── Visual representation
  │
  ├─── 7. Generate next steps (if includeNextSteps)
  │    ├── Immediate actions needed
  │    ├── Upcoming deadlines
  │    ├── Assigned responsibilities
  │    └── Suggested dates
  │
  ├─── 8. Format summary
  │    ├── Apply audience template
  │    ├── Format for output type (text/html/pdf)
  │    └── Add branding elements (if external)
  │
  ├─── 9. Send if requested (if sendTo provided)
  │    ├── Generate email-friendly version
  │    ├── Send to recipients
  │    └── Log delivery
  │
  ├─── 10. Log summary generation
  │     └── action_type: 'deal_summary_generated'
  │
  └── RETURN summary
```

## Output

```typescript
{
  success: true,
  actionTaken: "Generated deal summary for 123 Main St for buyer audience",
  result: {
    deal: {
      id: "uuid",
      propertyAddress: "123 Main St, Miami FL 33101",
      status: "active"
    },

    audience: "buyer",
    format: "text",
    generatedAt: "2026-01-27T10:30:00Z",

    summary: {
      // Rendered summary text (see templates below)
      text: "...",
      html: "...", // if format=html
      pdfUrl: "..." // if format=pdf
    },

    data: {
      overview: {
        propertyAddress: "123 Main Street, Miami FL 33101",
        purchasePrice: 450000,
        effectiveDate: "2026-01-15",
        closingDate: "2026-03-12",
        daysUnderContract: 12,
        daysUntilClosing: 45,
        status: "active",
        healthScore: 85
      },

      parties: {
        buyers: [{ name: "John Smith", role: "Buyer" }],
        sellers: [{ name: "Jane Doe", role: "Seller" }],
        agents: [
          { name: "Sarah Johnson", role: "Listing Agent", company: "Sunshine Realty" },
          { name: "Mike Brown", role: "Buyer's Agent", company: "Coastal Properties" }
        ],
        titleCompany: { name: "ABC Title Company", contact: "Lisa Wilson" },
        lender: { name: "First National Bank", contact: "Tom Garcia" }
      },

      financial: {
        purchasePrice: 450000,
        escrowDeposit: 10000,
        additionalDeposit: 15000,
        loanAmount: 360000,
        downPayment: 90000,
        estimatedClosingCosts: 12000
      },

      timeline: {
        completed: [
          { name: "Contract Executed", date: "2026-01-15", status: "done" },
          { name: "Escrow Deposited", date: "2026-01-18", status: "done" }
        ],
        upcoming: [
          { name: "Inspection Period Ends", date: "2026-01-30", daysRemaining: 3 },
          { name: "Additional Deposit Due", date: "2026-02-01", daysRemaining: 5 },
          { name: "Financing Contingency", date: "2026-02-14", daysRemaining: 18 },
          { name: "Closing", date: "2026-03-12", daysRemaining: 45 }
        ],
        percentComplete: 27
      },

      recentActivity: [
        { date: "2026-01-25", action: "Home inspection completed" },
        { date: "2026-01-24", action: "Appraisal scheduled for January 28" },
        { date: "2026-01-20", action: "Loan application submitted" }
      ],

      nextSteps: [
        { action: "Review inspection report", due: "2026-01-28", owner: "Buyer" },
        { action: "Submit additional deposit", due: "2026-02-01", owner: "Buyer" },
        { action: "Appraisal completion", due: "2026-01-28", owner: "Lender" }
      ],

      pendingItems: [
        { item: "Inspection report review", status: "in_progress" },
        { item: "Loan approval", status: "pending" },
        { item: "HOA approval", status: "submitted" }
      ]
    },

    sentTo: ["buyer@email.com"], // if sendTo was provided
    deliveryStatus: "sent"
  }
}
```

## Summary Templates by Audience

### Agent Summary (Full Detail)
```
═══════════════════════════════════════════════════════════════
                     DEAL SUMMARY
═══════════════════════════════════════════════════════════════

Property: 123 Main Street, Miami FL 33101
Status: ACTIVE | Health Score: 85/100

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

TIMELINE
├── Day 12 of 57 (27% complete)
├── Effective Date: January 15, 2026
└── Closing Date: March 12, 2026

FINANCIAL
├── Purchase Price: $450,000
├── Escrow Deposit: $10,000 (received)
├── Additional Deposit: $15,000 (due Feb 1)
├── Loan Amount: $360,000 (conventional)
└── Down Payment: $90,000 (20%)

PARTIES
├── Buyer: John Smith (305-555-1234)
├── Seller: Jane Doe (305-555-5678)
├── Listing Agent: Sarah Johnson - Sunshine Realty
├── Buyer's Agent: Mike Brown - Coastal Properties
├── Title: ABC Title Company - Lisa Wilson
└── Lender: First National Bank - Tom Garcia

KEY DATES
├── ✓ Contract Executed: Jan 15
├── ✓ Escrow Deposited: Jan 18
├── ⚠ Inspection Period Ends: Jan 30 (3 days)
├── ○ Additional Deposit: Feb 1 (5 days)
├── ○ Financing Contingency: Feb 14 (18 days)
└── ○ Closing: Mar 12 (45 days)

RECENT ACTIVITY
├── Jan 25: Home inspection completed
├── Jan 24: Appraisal scheduled
└── Jan 20: Loan application submitted

NEXT STEPS
├── 1. Review inspection report (Jan 28)
├── 2. Submit additional deposit (Feb 1)
└── 3. Follow up on loan status (Feb 7)

NOTES
└── Buyer is a first-time homebuyer. Keep communication
    supportive and educational. They're excited but nervous.

═══════════════════════════════════════════════════════════════
Generated by Homer Pro | January 27, 2026 at 10:30 AM
═══════════════════════════════════════════════════════════════
```

### Buyer Summary (Client-Friendly)
```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
          Your Home Purchase Update
                123 Main Street
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

Hi John,

Great news! Your purchase of 123 Main Street is
progressing nicely. Here's where things stand:

PROGRESS: ████████░░░░░░░░░░░░░░ 27%

You're 12 days into the process with 45 days until
your closing on March 12th. Everything is on track!

WHAT'S BEEN COMPLETED ✓
• Contract signed and executed
• Your earnest money deposit is safely held at
  ABC Title Company
• Home inspection was completed yesterday

COMING UP NEXT
• Inspection Period Ends: January 30 (3 days)
  → Please review the inspection report and let us
    know if you have any questions

• Additional Deposit Due: February 1 (5 days)
  → $15,000 due to ABC Title Company

• Appraisal: January 28
  → The lender's appraiser will visit the property

YOUR ACTION ITEMS
1. Review the home inspection report
2. Prepare your additional deposit ($15,000)
3. Respond to any lender document requests

FINANCIAL SNAPSHOT
├── Purchase Price: $450,000
├── Your Down Payment: $90,000
├── Loan Amount: $360,000
└── Estimated Closing Costs: ~$12,000

Questions? I'm here to help! Just call or text anytime.

Your Agent,
Mike Brown
Coastal Properties
305-555-8888
mike@coastalproperties.com

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

### Lender Summary (Formal)
```
TO: First National Bank
RE: Loan Status Update - 123 Main Street, Miami FL 33101

Date: January 27, 2026

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

PROPERTY INFORMATION
Address: 123 Main Street, Miami FL 33101
Property Type: Single Family Residence
MLS#: A12345678

TRANSACTION DETAILS
Purchase Price: $450,000
Loan Amount: $360,000 (80% LTV)
Loan Type: Conventional - 30 Year Fixed
Effective Date: January 15, 2026
Closing Date: March 12, 2026

BORROWER INFORMATION
Borrower: John Smith
Co-Borrower: N/A

KEY DATES
Financing Contingency Deadline: February 14, 2026
Appraisal Scheduled: January 28, 2026
Target Closing: March 12, 2026

CURRENT STATUS
✓ Purchase contract fully executed
✓ Earnest money deposited ($10,000)
✓ Home inspection completed
○ Appraisal pending
○ Loan approval pending

TITLE COMPANY
ABC Title Company
789 Legal Way, Miami FL 33103
Contact: Lisa Wilson
Phone: 305-555-0000

AGENT CONTACTS
Buyer's Agent: Mike Brown, Coastal Properties (305-555-8888)
Listing Agent: Sarah Johnson, Sunshine Realty (305-555-9999)

Please contact Mike Brown with any questions or
document requests.

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
```

## Voice Response

**Quick Summary:**
> "Here's the quick summary for 123 Main Street:
>
> You're 12 days in with 45 days until closing on March 12th. Health score is 85 - everything's on track.
>
> Key updates: The inspection was completed yesterday, and the appraisal is scheduled for the 28th. The inspection period ends in 3 days, so we need to review that report.
>
> Escrow is in, additional deposit is due February 1st. Anything specific you want to know?"

**Preparing Summary for Client:**
> "Got it, I'll prepare an update for the buyer on 123 Main Street.
>
> Here's what I'll include:
> - Progress update (27% complete, on track)
> - Completed milestones (contract, escrow, inspection)
> - Upcoming deadlines (inspection period, additional deposit)
> - Their action items (review report, prepare deposit)
>
> Should I send this to John Smith at the email we have on file, or would you like to review it first?"

**Sending Summary:**
> "I've sent the deal update to John Smith for 123 Main Street.
>
> The summary covers their progress, upcoming deadlines, and the two things they need to do: review the inspection report and prepare the additional deposit.
>
> I kept it encouraging since you mentioned they're first-time buyers. Let me know if you want me to adjust the tone for future updates."

## Error Handling

| Error | Cause | Response |
|-------|-------|----------|
| `DEAL_NOT_FOUND` | Invalid dealId or address | "I can't find a deal for that address. Can you verify?" |
| `INVALID_AUDIENCE` | Unknown audience type | "I don't recognize that audience type. Options are: agent, buyer, seller, lender, title, or all_parties." |
| `SEND_FAILED` | Email delivery issue | "I couldn't send the email to [address]. Want me to try again or give you the summary to send manually?" |
| `INSUFFICIENT_DATA` | Deal has minimal info | "This deal doesn't have much information yet. Here's what I have: [basic info]. Would you like me to create a summary with what's available?" |

## Integration Points

### Email Delivery
- SendGrid/SES for transactional email
- HTML template rendering
- PDF attachment generation

### Scheduled Reports
- Weekly digest for all active deals
- Pre-meeting briefs
- Monthly broker reports

### Database Tables
- `deals` - Core data
- `summaries` - Generated summary history
- `summary_deliveries` - Sent email log
- `action_log` - Audit entry

## Example Usage

### Voice Summary Request
```
Agent: "Summarize the Main Street deal for me"

Homer: "123 Main Street - Day 12 of 57 to closing.

        Quick status: 85 health score, everything on track.

        Financials: $450K purchase, $10K escrow in, $15K
        additional due Feb 1st. Loan at $360K conventional.

        Timeline:
        - Done: Contract, escrow deposit
        - Next 7 days: Inspection ends Jan 30, appraisal Jan 28
        - Coming up: Financing contingency Feb 14, closing Mar 12

        Recent: Inspection completed yesterday, need to review
        the report. Loan app submitted, waiting on appraisal.

        Anything you want me to dig into?"
```

### Generating Client Update
```
Agent: "Send the buyer a deal update on Oak Street"

Homer: "I'll send an update to the buyer for 456 Oak Street.

        The buyer is Sarah Chen at sarah@email.com. Here's what
        I'm planning to send:

        - Progress: 40% complete, 28 days to closing
        - Recent wins: Appraisal came in at value, loan approved
        - Coming up: Clear to close expected next week
        - Action needed: Schedule final walkthrough

        Tone will be positive and informative. Send it now,
        or do you want to review first?"

Agent: "Send it"

Homer: "Done! Update sent to Sarah Chen. I included congrats
        on the loan approval and reminded her about the
        walkthrough. Want me to set a reminder to follow up?"
```

### Broker Executive Summary
```
Broker: "Give me a summary of all active deals"

Homer: "You have 12 active deals across 4 agents. Here's the
        executive view:

        BY HEALTH:
        - 7 Excellent (90+)
        - 3 Good (75-89)
        - 1 Fair (68)
        - 1 At Risk (48)

        CLOSING THIS MONTH:
        - 3 deals totaling $1.2M in volume
        - Projected commission: $36,000

        ATTENTION NEEDED:
        - 101 Elm Drive (at risk): Financing issues, buyer
          unresponsive. Agent: Mike Brown
        - 789 Pine Lane (fair): Inspection report overdue.
          Agent: Sarah Johnson

        TOP PERFORMERS:
        - Sarah Johnson: 4 active, 2 closing this month
        - Mike Brown: 3 active, but one at-risk

        Want me to drill into any of these?"
```

## Quality Checklist

- [x] Handles voice input naturally
- [x] Supports multiple audience types
- [x] Adjusts tone and content by audience
- [x] Provides comprehensive deal overview
- [x] Includes visual timeline representation
- [x] Generates actionable next steps
- [x] Supports multiple output formats (text/html/pdf)
- [x] Enables direct email delivery
- [x] Filters confidential information appropriately
- [x] Supports scheduled report generation
- [x] Creates comprehensive audit log
- [x] Handles minimal data gracefully
- [x] Professional formatting for all audiences
- [x] Includes all Florida-specific relevant details
- [x] Handles errors gracefully

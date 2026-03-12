# Skill: Archive Deal

**Category:** Deal
**Priority:** P2
**Approval Required:** No (automatic) / Yes (manual early archive)

## Purpose

Move completed or cancelled deals to archived status with proper file organization, document retention, and historical record maintenance. This skill ensures deals are preserved for compliance, reference, and analytics while keeping the active deal pipeline clean.

## Triggers

### Voice Commands
- "Archive the deal at [address]"
- "File away [address]"
- "Move [address] to archive"
- "Store [address] for records"
- "Close out the file for [address]"

### Programmatic
- 30 days after deal status changed to 'closed'
- 30 days after deal status changed to 'cancelled'
- API call to `/deals/{id}/archive`
- Manual archive request from agent dashboard
- Scheduled cleanup job

## Required Inputs

| Input | Type | Required | Source | Description |
|-------|------|----------|--------|-------------|
| `dealId` | UUID | Yes* | context/schedule | Deal to archive |
| `propertyAddress` | string | Yes* | voice | Can identify deal by address |

*One of dealId or propertyAddress required

## Optional Inputs

| Input | Type | Default | Source | Description |
|-------|------|---------|--------|-------------|
| `archiveReason` | string | 'standard' | manual | Reason for archiving |
| `retentionYears` | number | 5 | config | Years to retain archived deal |
| `generatePdfBundle` | boolean | true | config | Create PDF archive bundle |
| `organizeFiles` | boolean | true | config | Organize documents by type |
| `skipConfirmation` | boolean | false | auto | Skip confirmation (for scheduled) |

## Archive Contents

### Documents Preserved

| Category | Documents |
|----------|-----------|
| **Contracts** | Purchase contract, all addenda, amendments, counter-offers |
| **Disclosures** | Seller's disclosure, lead paint, HOA docs, condo docs |
| **Inspections** | Home inspection, WDO, roof, pool, seawall reports |
| **Financial** | Appraisal, loan documents, proof of funds, deposit receipts |
| **Title** | Title commitment, survey, deed, title policy |
| **Closing** | HUD/CD statement, wire confirmations, final walkthrough |
| **Communications** | Key emails, text logs, signed authorizations |

### Metadata Preserved

| Data | Purpose |
|------|---------|
| Deal timeline | Full event history from creation to close |
| Party information | All contacts with roles |
| Deadline history | Original and actual completion dates |
| Agent notes | All notes and internal comments |
| Action log | Complete audit trail |
| Financial summary | All amounts, deposits, commissions |

## Execution Flow

```
START
  │
  ├─── 1. Identify deal
  │    ├── If dealId provided → load deal
  │    ├── If propertyAddress provided → find deal
  │    └── Verify deal exists and is archivable
  │
  ├─── 2. Validate archive eligibility
  │    ├── Deal must be 'closed' or 'cancelled'
  │    ├── If 'closed': check 30-day waiting period (or override)
  │    ├── If 'cancelled': check 30-day waiting period (or override)
  │    └── Early archive requires confirmation
  │
  ├─── 3. Confirm archive (if manual & not skipConfirmation)
  │    ├── Show deal summary
  │    ├── Show archive implications
  │    └── Wait for confirmation
  │
  ├─── 4. Gather all deal documents
  │    ├── Contracts and addenda
  │    ├── Disclosure documents
  │    ├── Inspection reports
  │    ├── Financial documents
  │    ├── Title documents
  │    ├── Closing documents
  │    └── Communication records
  │
  ├─── 5. Organize file structure (if organizeFiles=true)
  │    └── Create structured folder:
  │        /archive/[year]/[address]/
  │        ├── /01-contracts/
  │        ├── /02-disclosures/
  │        ├── /03-inspections/
  │        ├── /04-financial/
  │        ├── /05-title/
  │        ├── /06-closing/
  │        ├── /07-communications/
  │        └── /deal-summary.pdf
  │
  ├─── 6. Generate archive bundle (if generatePdfBundle=true)
  │    ├── Create combined PDF with all documents
  │    ├── Add table of contents
  │    ├── Include deal summary cover sheet
  │    └── Add document verification checksums
  │
  ├─── 7. Generate deal summary document
  │    ├── Property details
  │    ├── Transaction timeline
  │    ├── All parties involved
  │    ├── Financial breakdown
  │    ├── Key dates (effective, contingencies, closing)
  │    ├── Commission details
  │    └── Final notes
  │
  ├─── 8. Update deal record
  │    ├── Set status = 'archived'
  │    ├── Set archived_at timestamp
  │    ├── Set archive_location (storage path)
  │    ├── Set retention_until date
  │    └── Store archive metadata
  │
  ├─── 9. Update related records
  │    ├── Mark all deadlines as 'archived'
  │    ├── Archive party associations
  │    ├── Archive action log entries
  │    └── Update document references
  │
  ├─── 10. Set retention policy
  │     ├── Calculate retention_until date
  │     ├── Schedule retention review
  │     └── Flag for compliance tracking
  │
  ├─── 11. Log archive action
  │     └── action_type: 'deal_archived'
  │
  └── RETURN archive confirmation
```

## File Organization Structure

```
/archive/
└── 2026/
    └── 123-main-st-miami-fl-33101/
        ├── 00-deal-summary.pdf
        ├── 00-archive-manifest.json
        │
        ├── 01-contracts/
        │   ├── far-bar-as-is-contract.pdf
        │   ├── addendum-a-as-is.pdf
        │   ├── addendum-b-financing.pdf
        │   ├── counter-offer-1.pdf
        │   └── amendment-1-extension.pdf
        │
        ├── 02-disclosures/
        │   ├── seller-disclosure.pdf
        │   ├── lead-paint-disclosure.pdf
        │   ├── hoa-disclosure.pdf
        │   └── flood-zone-disclosure.pdf
        │
        ├── 03-inspections/
        │   ├── home-inspection-report.pdf
        │   ├── wdo-termite-report.pdf
        │   ├── roof-certification.pdf
        │   └── pool-inspection.pdf
        │
        ├── 04-financial/
        │   ├── appraisal-report.pdf
        │   ├── proof-of-funds.pdf
        │   ├── escrow-deposit-receipt.pdf
        │   └── loan-approval-letter.pdf
        │
        ├── 05-title/
        │   ├── title-commitment.pdf
        │   ├── survey.pdf
        │   ├── warranty-deed.pdf
        │   └── title-policy.pdf
        │
        ├── 06-closing/
        │   ├── closing-disclosure.pdf
        │   ├── hud-statement.pdf
        │   ├── final-walkthrough-checklist.pdf
        │   └── wire-confirmation.pdf
        │
        └── 07-communications/
            ├── key-email-thread.pdf
            └── signed-authorizations.pdf
```

## Output

```typescript
{
  success: true,
  actionTaken: "Archived deal for 123 Main St, Miami FL 33101",
  result: {
    deal: {
      id: "uuid",
      propertyAddress: "123 Main St, Miami FL 33101",
      previousStatus: "closed",
      currentStatus: "archived",
      archivedAt: "2026-04-12T00:00:00Z",
      archivedBy: "system" // or user email for manual
    },

    archive: {
      location: "/archive/2026/123-main-st-miami-fl-33101/",
      bundlePdf: "/archive/2026/123-main-st-miami-fl-33101/complete-deal-bundle.pdf",
      summaryPdf: "/archive/2026/123-main-st-miami-fl-33101/00-deal-summary.pdf",
      manifestJson: "/archive/2026/123-main-st-miami-fl-33101/00-archive-manifest.json",
      retentionUntil: "2031-04-12",
      sizeBytes: 45678901,
      documentCount: 23
    },

    documents: {
      contracts: 5,
      disclosures: 4,
      inspections: 4,
      financial: 4,
      title: 4,
      closing: 4,
      communications: 2,
      total: 27
    },

    dealSummary: {
      propertyAddress: "123 Main St, Miami FL 33101",
      purchasePrice: 450000,
      closingDate: "2026-03-12",
      effectiveDate: "2026-01-15",
      daysToClose: 56,
      buyers: ["John Smith"],
      sellers: ["Jane Doe"],
      listingAgent: "Sarah Johnson",
      buyerAgent: "Mike Brown",
      titleCompany: "ABC Title Company",
      escrowDeposit: 10000,
      finalCommission: 13500
    },

    retention: {
      policy: "standard",
      years: 5,
      reviewDate: "2031-03-12",
      autoDeleteEnabled: false,
      complianceFlags: []
    }
  }
}
```

## Voice Response

**Automatic Archive (30 days post-close):**
> "I've archived the deal for 123 Main Street that closed on March 12th.
>
> All 27 documents are organized and stored. I created a complete PDF bundle and summary document for easy reference.
>
> The records will be retained for 5 years until April 2031. You can find everything in the archive section if you need to reference it."

**Manual Early Archive:**
> "Got it, I'll archive the deal for 456 Oak Avenue now instead of waiting the full 30 days.
>
> Just to confirm - this deal closed on March 5th, which was 15 days ago. Archiving now means it won't appear in your recent deals. Proceed?"
>
> [After confirmation]
>
> "Done. Deal archived with 19 documents. You'll find it in the 2026 archive folder."

**Cancelled Deal Archive:**
> "I've archived the cancelled deal for 789 Pine Lane.
>
> Even though the deal didn't close, I've preserved all the documents and timeline for your records. This includes:
> - The original contract and all addenda
> - The cancellation notice
> - The escrow release form
> - All communications
>
> Records retained for 5 years. The cancellation reason was: 'Buyer failed to secure financing.'"

## Error Handling

| Error | Cause | Response |
|-------|-------|----------|
| `DEAL_NOT_FOUND` | Invalid dealId or address | "I can't find a deal for that address. Can you verify?" |
| `NOT_ARCHIVABLE` | Deal not closed or cancelled | "This deal is still [status]. I can only archive closed or cancelled deals." |
| `WAITING_PERIOD` | 30 days not elapsed | "This deal closed [X] days ago. I usually wait 30 days before archiving. Want me to archive it now anyway?" |
| `MISSING_DOCUMENTS` | Key documents not found | "Some documents are missing from this deal. I can still archive what we have, but the file may be incomplete. Proceed?" |
| `STORAGE_ERROR` | File system issue | "I'm having trouble saving to the archive. Let me try again, or I can flag this for manual archiving." |

## Integration Points

### Triggers Before Archive
- Verify all documents are present
- Generate final commission report
- Close out any open tasks

### Database Tables
- `deals` - Status update, archive metadata
- `deal_archives` - Archive details and location
- `documents` - Update storage references
- `deadlines` - Archive status
- `action_log` - Audit entry

### Storage Systems
- Cloud storage (S3, GCS, Azure) for document archive
- PDF generation service for bundles
- File organization utility

## Retention Policy

### Standard Retention Periods

| Document Type | Florida Requirement | Homer Pro Default |
|---------------|--------------------|--------------------|
| Transaction records | 5 years | 5 years |
| Contracts | 5 years | 7 years |
| Financial records | 5 years | 7 years |
| Commission records | 5 years | 7 years |
| Correspondence | 2 years | 5 years |

### Retention Options

| Policy | Duration | Use Case |
|--------|----------|----------|
| minimum | 2 years | Non-FL transactions |
| standard | 5 years | Default for FL |
| extended | 7 years | Recommended best practice |
| permanent | Indefinite | Litigation hold, special cases |

## Florida Compliance Notes

### FREC Record Retention (Rule 61J2-14.012)
- Brokers must keep transaction records for 5 years
- Includes contracts, closing statements, escrow records
- Records must be available for DBPR inspection

### Document Accessibility
- Archived deals must remain searchable
- Documents must be producible within reasonable timeframe
- Original or true copies acceptable

## Example Usage

### Automatic Archive Notification
```
[System notification 30 days after close]

Homer: "I've automatically archived the deal for 123 Main Street.

        Quick summary:
        - Closed: March 12, 2026
        - Purchase price: $450,000
        - Your commission: $13,500
        - Documents archived: 27

        All records are preserved for 5 years. You can find this
        deal in the 2026 archive anytime you need it."
```

### Manual Early Archive
```
Agent: "Archive the Oak Street deal"

Homer: "The deal at 456 Oak Street closed 12 days ago on March 8th.

        Normally I wait 30 days before archiving, in case you need
        to reference or update anything. Archiving now will:

        - Move it out of your active deals
        - Organize all 22 documents
        - Generate a summary PDF

        Want me to archive it now, or wait until April 7th?"

Agent: "Archive it now"

Homer: "Done. Deal for 456 Oak Street is now archived.

        All documents organized in:
        /archive/2026/456-oak-st-miami-fl/

        I created a complete bundle PDF and summary.
        Records retained until March 2031."
```

### Viewing Archived Deal
```
Agent: "Find the Main Street deal from last year"

Homer: "I found the archived deal for 123 Main Street:

        - Closed: March 12, 2025
        - Purchase price: $425,000
        - Buyer: Jane Smith
        - Seller: Bob Jones

        Would you like me to pull up the full summary, or are you
        looking for a specific document?"

Agent: "I need the inspection report"

Homer: "Here's the home inspection report from the Main Street
        archive. It's dated February 15, 2025, from ABC Inspections.

        [Document link]

        Need anything else from this deal?"
```

## Quality Checklist

- [x] Handles voice input naturally
- [x] Validates archive eligibility (status, timing)
- [x] Respects 30-day waiting period with override option
- [x] Gathers all deal documents comprehensively
- [x] Organizes files in logical folder structure
- [x] Generates archive bundle PDF
- [x] Creates deal summary document
- [x] Sets appropriate retention policy
- [x] Updates all related records
- [x] Maintains searchability of archived deals
- [x] Creates comprehensive audit log
- [x] Handles missing documents gracefully
- [x] Florida retention requirements met
- [x] Supports compliance inspection requirements
- [x] Handles errors gracefully

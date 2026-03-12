# Skill: Parse Contract

**Category:** Deal
**Priority:** P0
**Approval Required:** No

## Purpose

Extract structured data from FAR/BAR PDF contracts uploaded to Homer Pro. This skill reads Florida real estate contracts, identifies key fields, and returns normalized data that can be used to create or update a deal.

## Triggers

### Voice Commands
- "Parse this contract"
- "Read the contract at [address]"
- "What does this contract say?"
- "Extract contract details"
- "Import contract"

### Programmatic
- PDF uploaded to deal dropzone
- Email with PDF attachment forwarded
- API call to `/contracts/parse`
- Agent dashboard "Upload Contract" button
- Drag-and-drop to conversation

## Required Inputs

| Input | Type | Required | Source | Description |
|-------|------|----------|--------|-------------|
| `contractFile` | File/URL | Yes | upload/email | PDF file or URL to contract |

## Optional Inputs

| Input | Type | Default | Source | Description |
|-------|------|---------|--------|-------------|
| `dealId` | UUID | null | context | Existing deal to associate with |
| `contractType` | string | 'auto' | manual | Override auto-detection (far_bar_as_is, far_bar_standard, custom) |
| `extractParties` | boolean | true | config | Whether to extract buyer/seller info |
| `extractAddenda` | boolean | true | config | Whether to identify attached addenda |
| `ocrFallback` | boolean | true | config | Use OCR if text extraction fails |

## Execution Flow

```
START
  │
  ├─── 1. Validate file
  │    ├── Check file exists and is accessible
  │    ├── Verify file type is PDF
  │    ├── Check file size < 50MB
  │    └── Scan for malware/corruption
  │
  ├─── 2. Detect contract type
  │    ├── Search for "FAR/BAR" or "Florida REALTORS" header
  │    ├── Check for "AS-IS" language
  │    ├── Identify standard vs. as-is form
  │    └── Note if custom/unrecognized format
  │
  ├─── 3. Extract text layer
  │    ├── Use PDF text extraction
  │    ├── If text layer empty → trigger OCR
  │    └── Store raw text for audit
  │
  ├─── 4. Parse property information
  │    ├── Legal description
  │    ├── Street address
  │    ├── City, State, ZIP
  │    ├── County
  │    ├── Folio/Parcel number
  │    └── Property type (SFR, condo, townhome)
  │
  ├─── 5. Parse financial terms
  │    ├── Purchase price
  │    ├── Escrow deposit amount(s)
  │    ├── Escrow holder
  │    ├── Additional deposit amount
  │    ├── Balance due at closing
  │    └── Financing type and terms
  │
  ├─── 6. Parse dates
  │    ├── Effective date
  │    ├── Closing date
  │    ├── Inspection period end date
  │    ├── Financing contingency end date
  │    ├── Escrow deposit due date
  │    ├── Additional deposit due date
  │    └── Any extension dates
  │
  ├─── 7. Parse parties (if extractParties=true)
  │    ├── Buyer name(s)
  │    ├── Buyer address
  │    ├── Buyer phone/email (if present)
  │    ├── Seller name(s)
  │    ├── Seller address
  │    ├── Seller phone/email (if present)
  │    ├── Listing agent and brokerage
  │    ├── Buyer's agent and brokerage
  │    └── Title company (if specified)
  │
  ├─── 8. Parse contingencies & special terms
  │    ├── Inspection contingency (Y/N, days)
  │    ├── Financing contingency (Y/N, days)
  │    ├── Appraisal contingency
  │    ├── Sale of buyer's property contingency
  │    ├── HOA approval required
  │    ├── Condo association approval
  │    ├── Personal property included
  │    └── Special conditions/addenda noted
  │
  ├─── 9. Identify addenda (if extractAddenda=true)
  │    ├── AS-IS Addendum
  │    ├── Financing Addendum
  │    ├── Condo Addendum
  │    ├── HOA Addendum
  │    ├── Lead Paint Disclosure
  │    ├── Seller's Disclosure
  │    ├── Wire Fraud Warning
  │    └── Custom addenda
  │
  ├─── 10. Calculate confidence scores
  │     ├── Per-field confidence (0-100)
  │     ├── Overall document confidence
  │     └── Flag low-confidence extractions
  │
  ├─── 11. Log extraction
  │     └── action_type: 'contract_parsed'
  │
  └── RETURN parsed contract data
```

## Output

```typescript
{
  success: true,
  actionTaken: "Parsed FAR/BAR AS-IS contract for 123 Main St, Miami FL 33101",
  result: {
    contractType: "far_bar_as_is",
    formVersion: "Rev. 8/22",
    confidence: 94,

    property: {
      street: "123 Main Street",
      unit: null,
      city: "Miami",
      state: "FL",
      zip: "33101",
      county: "Miami-Dade",
      legalDescription: "Lot 5, Block 2, Sunshine Estates...",
      folioNumber: "01-3456-001-0050",
      propertyType: "single_family",
      confidence: 98
    },

    financial: {
      purchasePrice: 450000,
      escrowDeposit: 10000,
      escrowHolder: "ABC Title Company",
      additionalDeposit: 15000,
      balanceDue: 425000,
      financingType: "conventional",
      loanAmount: 360000,
      confidence: 96
    },

    dates: {
      effectiveDate: "2026-01-15",
      closingDate: "2026-03-12",
      inspectionPeriodDays: 15,
      inspectionEndDate: "2026-01-30",
      financingContingencyDays: 30,
      financingEndDate: "2026-02-14",
      escrowDueDate: "2026-01-18",
      additionalDepositDueDate: "2026-01-25",
      confidence: 92
    },

    parties: {
      buyers: [
        {
          name: "John Smith",
          address: "456 Oak Ave, Miami FL 33102",
          phone: "305-555-1234",
          email: "john@email.com"
        }
      ],
      sellers: [
        {
          name: "Jane Doe",
          address: "123 Main Street, Miami FL 33101",
          phone: "305-555-5678",
          email: null
        }
      ],
      listingAgent: {
        name: "Sarah Johnson",
        licenseNumber: "SL123456",
        brokerage: "Sunshine Realty",
        phone: "305-555-9999"
      },
      buyerAgent: {
        name: "Mike Brown",
        licenseNumber: "BK654321",
        brokerage: "Coastal Properties",
        phone: "305-555-8888"
      },
      titleCompany: {
        name: "ABC Title Company",
        address: "789 Legal Way, Miami FL 33103",
        phone: "305-555-0000"
      },
      confidence: 88
    },

    contingencies: {
      inspection: { applies: true, days: 15 },
      financing: { applies: true, days: 30 },
      appraisal: { applies: true },
      saleOfProperty: { applies: false },
      hoaApproval: { applies: true, days: 30 },
      condoApproval: { applies: false }
    },

    addenda: [
      { type: "as_is", detected: true, page: 8 },
      { type: "financing", detected: true, page: 10 },
      { type: "hoa", detected: true, page: 12 },
      { type: "lead_paint", detected: true, page: 14 },
      { type: "wire_fraud_warning", detected: true, page: 15 }
    ],

    warnings: [
      {
        field: "parties.sellers[0].email",
        message: "Seller email not found in contract",
        severity: "low"
      },
      {
        field: "dates.closingDate",
        message: "Closing date is a Saturday - verify with title",
        severity: "medium"
      }
    ],

    rawTextExcerpt: "RESIDENTIAL CONTRACT FOR SALE AND PURCHASE...",
    originalFileUrl: "https://storage.homer.pro/contracts/abc123.pdf"
  }
}
```

## Voice Response

**Successful Parse:**
> "I've read the contract for 123 Main Street, Miami. Here's what I found:
>
> Purchase price: $450,000. Buyer is John Smith. Seller is Jane Doe.
>
> Effective date is January 15th, with closing set for March 12th.
>
> The inspection period is 15 days, ending January 30th. Financing contingency is 30 days.
>
> I found a few things to verify: the closing date falls on a Saturday, and I couldn't find the seller's email. Should I create a deal with these details?"

**Low Confidence Parse:**
> "I was able to read most of the contract for 123 Main Street, but some parts were unclear. I'm 75% confident on the effective date - it might be January 15th or January 18th. Can you confirm? The handwriting in section 3 was difficult to read."

**Unrecognized Format:**
> "This doesn't look like a standard FAR/BAR contract. I can see it's for 123 Main Street with a purchase price of $450,000, but I may have missed some fields. Would you like me to proceed with what I found, or would you prefer to enter the details manually?"

## Error Handling

| Error | Cause | Response |
|-------|-------|----------|
| `FILE_NOT_FOUND` | File doesn't exist or inaccessible | "I can't find that contract. Can you upload it again?" |
| `INVALID_FILE_TYPE` | Not a PDF | "I need a PDF file. This looks like a [file type]. Can you convert it to PDF?" |
| `FILE_TOO_LARGE` | Exceeds 50MB limit | "This file is too large. Can you compress it or split it into sections?" |
| `CORRUPTED_FILE` | PDF is damaged | "This PDF appears to be corrupted. Can you try re-downloading or re-scanning it?" |
| `NO_TEXT_EXTRACTABLE` | PDF is image-only, OCR failed | "This PDF is just images and I couldn't read the text. Can you provide a text-searchable version?" |
| `UNRECOGNIZED_FORMAT` | Not a known FL contract | "I don't recognize this contract format. I'll extract what I can, but please verify the details." |
| `MISSING_CRITICAL_FIELDS` | Can't find address or price | "I couldn't find the property address in this contract. Is this the complete document?" |

## Integration Points

### Triggers After Parsing
- Prompt to create deal (if no dealId provided)
- Auto-invoke `validate-contract` skill
- Store parsed data for comparison with future amendments

### Database Tables
- `contracts` - Store original file and parsed data
- `contract_extractions` - Field-level extraction log
- `action_log` - Audit entry

### External Services
- PDF text extraction library (pdf-parse, pdfjs)
- OCR service (AWS Textract, Google Vision)
- Address validation API (USPS, Google)

## Florida-Specific Logic

### FAR/BAR Form Detection
- **Standard Form**: "RESIDENTIAL CONTRACT FOR SALE AND PURCHASE" without AS-IS language
- **AS-IS Form**: Contains "AS IS" Addendum K language
- **Rev Date**: Extract revision date (e.g., "Rev. 8/22") for compliance tracking

### Florida Date Calculations
- Inspection period: "...days from Effective Date" (calendar days, excludes effective date)
- Financing contingency: Calendar days from effective date
- Closing: Business days for funding, but contract date may be weekend

### Florida-Specific Fields
- County: Critical for doc stamps, transfer tax calculations
- Folio Number: Property tax parcel ID format varies by county
- HOA/Condo: Florida-specific disclosure requirements
- Flood Zone: Often noted in addenda

## Example Usage

### From Voice
```
Agent uploads: FAR_BAR_AS_IS_123_Main_Signed.pdf

Homer: "Got it, reading the contract now...

        I've parsed the FAR/BAR AS-IS contract for 123 Main Street, Miami.

        Key details:
        - Purchase Price: $450,000
        - Effective Date: January 15th
        - Closing: March 12th
        - Buyer: John Smith
        - Seller: Jane Doe

        Contingencies:
        - 15-day inspection ending January 30th
        - 30-day financing ending February 14th
        - HOA approval required

        I noticed the contract has an AS-IS addendum, so the inspection is
        for information only.

        Should I create a deal with these details and generate all the deadlines?"

Agent: "Yes, create the deal"

Homer: [Invokes create-deal skill with parsed data]
```

### Handling Poor Quality Scan
```
Agent uploads: blurry_contract_scan.pdf

Homer: "I'm having trouble reading this scan clearly. Here's what I could make out:

        - Property: 123 Main Street, Miami FL (confident)
        - Purchase Price: $450,000 or $456,000 (unclear - the handwritten number is smudged)
        - Effective Date: January 15th (confident)
        - Buyer: John S... (last name cut off)

        Can you confirm the purchase price and buyer's full name? Or if you
        have a clearer scan, I can try again."
```

## Quality Checklist

- [x] Handles voice input naturally
- [x] Supports multiple PDF sources (upload, email, URL)
- [x] Detects FAR/BAR standard vs AS-IS forms
- [x] Extracts all critical deal fields
- [x] Parses all parties with contact info
- [x] Identifies attached addenda
- [x] Provides per-field confidence scores
- [x] Falls back to OCR when needed
- [x] Warns about potential issues (weekend closing, missing fields)
- [x] Creates audit log entry
- [x] Handles errors gracefully with clear messages
- [x] Florida-specific field extraction
- [x] Stores original file for reference

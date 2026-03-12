# Skill: Store Document

**Category:** Document
**Priority:** P1
**Approval Required:** No

## Purpose

Upload, organize, and store documents in Homer Pro's document management system. This skill handles file uploads, metadata extraction, categorization, and integration with the deal's document folder structure.

## Triggers

### Voice Commands
- "Upload [document] to [deal/address]"
- "Store this document for [address]"
- "Add [file] to the deal"
- "File the [document type] for [address]"
- "Save the [document] to [folder]"

### Programmatic
- `POST /deals/:dealId/documents`
- `POST /documents/upload`
- Drag-and-drop upload in dashboard
- Email attachment extraction
- DocuSign completed document storage

## Required Inputs

| Input | Type | Required | Source | Description |
|-------|------|----------|--------|-------------|
| `file` | File/URL | Yes* | upload | File to store |
| `fileUrl` | string | Yes* | system | URL of file to store |
| `dealId` | UUID | Yes* | context | Deal to attach to |

*Either `file` OR `fileUrl` required; dealId recommended

## Optional Inputs

| Input | Type | Default | Source | Description |
|-------|------|---------|--------|-------------|
| `documentType` | string | auto-detect | manual | Document category |
| `name` | string | filename | manual | Display name |
| `folder` | string | root | manual | Folder path |
| `description` | string | null | manual | Document description |
| `tags` | string[] | [] | manual | Searchable tags |
| `isConfidential` | boolean | false | manual | Restrict access |
| `expirationDate` | Date | null | manual | Document expiration |
| `sourceType` | string | 'upload' | system | How document was received |
| `extractText` | boolean | true | config | OCR/text extraction |
| `parseContract` | boolean | auto | config | Attempt contract parsing |

## Document Types

| Type | Description | Auto-Detection Hints |
|------|-------------|---------------------|
| `contract` | Purchase contract | FAR, BAR, sale, purchase |
| `addendum` | Contract addendum | Addendum, amendment |
| `disclosure` | Disclosure forms | Disclosure, lead paint, HOA |
| `inspection` | Inspection reports | Inspection, 4-point, wind mit |
| `appraisal` | Appraisal reports | Appraisal, valuation |
| `title` | Title documents | Title, commitment, policy |
| `survey` | Property surveys | Survey, plat |
| `hoa` | HOA documents | HOA, association, bylaws |
| `mortgage` | Loan documents | Mortgage, loan, lender |
| `insurance` | Insurance docs | Insurance, policy, binder |
| `id` | Identity documents | ID, license, passport |
| `tax` | Tax records | Tax, assessment |
| `correspondence` | Emails, letters | Email, letter, memo |
| `photo` | Property photos | Photo, image |
| `other` | Uncategorized | - |

## Folder Structure (Default)

```
Deal: 123 Main St
├── 📁 Contract
│   ├── Original Contract.pdf
│   ├── Addendum 1 - Inspection Extension.pdf
│   └── Addendum 2 - Price Reduction.pdf
├── 📁 Disclosures
│   ├── Seller Disclosure.pdf
│   └── Lead Paint Disclosure.pdf
├── 📁 Inspections
│   ├── Home Inspection Report.pdf
│   ├── 4-Point Inspection.pdf
│   └── Wind Mitigation.pdf
├── 📁 Title
│   ├── Title Commitment.pdf
│   └── Survey.pdf
├── 📁 Financing
│   ├── Pre-Approval Letter.pdf
│   └── Loan Estimate.pdf
├── 📁 Correspondence
│   └── Emails/
└── 📁 Closing
    ├── HUD-1.pdf
    └── Deed.pdf
```

## Execution Flow

```
START
  │
  ├─── 1. Validate upload
  │    ├── Check file size (max 50MB)
  │    ├── Validate file type
  │    ├── Check for viruses/malware
  │    └── Verify storage quota
  │
  ├─── 2. Process file
  │    │
  │    ├── Generate unique file ID
  │    │
  │    ├── IF image:
  │    │   ├── Generate thumbnails
  │    │   └── Extract EXIF data
  │    │
  │    ├── IF PDF:
  │    │   ├── Extract text content
  │    │   ├── Count pages
  │    │   └── Generate thumbnail
  │    │
  │    └── IF other:
  │        └── Store as-is
  │
  ├─── 3. Auto-detect document type (if not specified)
  │    ├── Analyze filename
  │    ├── Analyze extracted text
  │    ├── Use ML classifier
  │    └── Assign confidence score
  │
  ├─── 4. Extract metadata
  │    │
  │    ├── Basic metadata:
  │    │   ├── File size
  │    │   ├── Page count
  │    │   ├── Created date
  │    │   └── Modified date
  │    │
  │    ├── IF contract/addendum AND parseContract:
  │    │   ├── INVOKE: parse-contract skill
  │    │   └── Extract deal details
  │    │
  │    └── IF inspection report:
  │        └── Extract summary/issues
  │
  ├─── 5. Determine storage location
  │    │
  │    ├── IF folder specified:
  │    │   └── Use specified folder
  │    │
  │    ├── IF dealId AND documentType:
  │    │   └── Use type-based default folder
  │    │
  │    └── ELSE:
  │        └── Use root folder or unfiled
  │
  ├─── 6. Upload to storage
  │    ├── Upload to cloud storage (S3/GCS)
  │    ├── Generate secure URL
  │    ├── Set access permissions
  │    └── Store file hash for integrity
  │
  ├─── 7. Create document record
  │    ├── Store all metadata
  │    ├── Link to deal
  │    ├── Set document type
  │    ├── Store folder path
  │    ├── Add tags
  │    └── Set permissions
  │
  ├─── 8. Index for search
  │    ├── Index extracted text
  │    ├── Index metadata
  │    └── Update deal document count
  │
  ├─── 9. Trigger follow-up actions
  │    │
  │    ├── IF contract uploaded:
  │    │   └── Offer to parse and create deal
  │    │
  │    ├── IF inspection report:
  │    │   └── Offer to extract issues
  │    │
  │    └── IF signed document:
  │        └── Update related records
  │
  ├─── 10. Log action
  │     └── action_type: 'document_stored'
  │
  └─── 11. Return result
```

## Output

```typescript
{
  success: true,
  actionTaken: "Stored home inspection report for 123 Main St",
  result: {
    document: {
      id: "doc-uuid",
      name: "Home Inspection Report",
      type: "inspection",
      mimeType: "application/pdf",
      size: 2456789,
      pageCount: 45,
      url: "https://storage.homer.pro/docs/...",
      thumbnailUrl: "https://storage.homer.pro/thumbs/...",
      folder: "/Inspections",
      uploadedAt: "2026-01-15T14:30:00Z",
      uploadedBy: {
        id: "agent-uuid",
        name: "Mike Agent"
      }
    },
    metadata: {
      extracted: true,
      textLength: 15000,
      confidence: 0.95,
      detectedType: "inspection",
      inspectorName: "ABC Home Inspections",
      inspectionDate: "2026-01-10"
    },
    deal: {
      id: "deal-uuid",
      address: "123 Main St, Miami FL 33101",
      documentCount: 12
    },
    suggestions: [
      {
        action: "extract_issues",
        message: "Want me to extract the major issues from this report?"
      }
    ],
    nextSteps: [
      "Document stored in Inspections folder",
      "Text indexed for search",
      "12 documents now in this deal"
    ]
  }
}
```

## Voice Response

**Standard upload:**
> "I've stored the home inspection report for 123 Main Street in the Inspections folder.
>
> It's a 45-page report from ABC Home Inspections dated January 10th.
>
> Would you like me to extract the major issues from the report?"

**Contract upload with parsing:**
> "I've stored the contract and extracted the key details:
>
> Property at 456 Oak Avenue, purchase price $425,000, closing March 15th.
>
> Should I create a deal from this contract?"

## Bulk Upload

```typescript
// Upload multiple documents
{
  files: [
    { file: File, type: "inspection" },
    { file: File, type: "inspection" },
    { file: File, type: "disclosure" }
  ],
  dealId: "deal-uuid",
  folder: "/Inspections"
}

// Result
{
  success: true,
  uploaded: 3,
  failed: 0,
  documents: [...]
}
```

## Error Handling

| Error | Cause | Response |
|-------|-------|----------|
| `FILE_TOO_LARGE` | Over 50MB | "This file is too large (52MB). Maximum size is 50MB." |
| `INVALID_FILE_TYPE` | Unsupported format | "I can't store .exe files. Supported formats are PDF, images, Office docs." |
| `STORAGE_QUOTA_EXCEEDED` | Out of space | "Your storage is full. Upgrade or delete old files." |
| `VIRUS_DETECTED` | Malware found | "This file failed security scanning. It cannot be uploaded." |
| `UPLOAD_FAILED` | Network issue | "Upload failed. Let me try again..." |
| `DEAL_NOT_FOUND` | Invalid dealId | "I can't find that deal. Store without linking, or specify the address?" |

## Supported File Types

| Category | Extensions | Max Size |
|----------|------------|----------|
| Documents | .pdf, .doc, .docx, .xls, .xlsx, .ppt, .pptx | 50MB |
| Images | .jpg, .jpeg, .png, .gif, .tiff, .webp | 25MB |
| Text | .txt, .rtf, .csv | 10MB |
| Archives | .zip | 100MB |

## Security & Access

```typescript
const accessControl = {
  // Default permissions
  default: {
    owner: ["read", "write", "delete", "share"],
    team: ["read"],
    deal_parties: []  // No access by default
  },

  // Confidential documents
  confidential: {
    owner: ["read", "write", "delete"],
    team: [],  // No team access
    deal_parties: []
  },

  // Shared with parties
  shared: {
    owner: ["read", "write", "delete", "share"],
    team: ["read"],
    deal_parties: ["read"]
  }
};
```

## Integration Points

### Invokes
- Cloud storage (S3/GCS)
- OCR/text extraction
- ML classifier
- `parse-contract` (for contracts)
- Virus scanning

### Invoked By
- File upload UI
- Email processing
- DocuSign completion webhook
- API integrations

### Database Updates
- `documents` - New record
- `deals` - Document count
- `search_index` - Text content

## Quality Checklist

- [x] Supports all common file types
- [x] Validates file size and type
- [x] Scans for viruses
- [x] Extracts text for search
- [x] Auto-detects document type
- [x] Organizes in folder structure
- [x] Generates thumbnails
- [x] Links to deals
- [x] Supports bulk upload
- [x] Handles confidential documents
- [x] Creates audit trail
- [x] Triggers smart follow-up actions

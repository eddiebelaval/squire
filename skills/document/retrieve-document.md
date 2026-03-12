# Skill: Retrieve Document

**Category:** Document
**Priority:** P1
**Approval Required:** No

## Purpose

Find and retrieve documents from Homer Pro's document management system. Supports searching by name, type, content, deal, date, and other criteria. Returns documents with download links, previews, and contextual information.

## Triggers

### Voice Commands
- "Find the [document type] for [address]"
- "Get me the inspection report for [deal]"
- "Where's the contract for [address]?"
- "Show me the addendums for [deal]"
- "Pull up [document name]"
- "What documents do we have for [address]?"
- "Find documents mentioning [term]"

### Programmatic
- `GET /deals/:dealId/documents`
- `GET /documents/search`
- Dashboard document browser
- Related document suggestions

## Required Inputs

At least one search criterion required:

| Input | Type | Required | Source | Description |
|-------|------|----------|--------|-------------|
| `query` | string | No | voice | Free-text search |
| `dealId` | UUID | No | context | Documents for a deal |
| `documentId` | UUID | No | manual | Specific document |
| `documentType` | string | No | voice | Filter by type |

## Optional Inputs

| Input | Type | Default | Source | Description |
|-------|------|---------|--------|-------------|
| `folder` | string | null | manual | Specific folder |
| `dateFrom` | Date | null | manual | Uploaded after date |
| `dateTo` | Date | null | manual | Uploaded before date |
| `uploadedBy` | UUID | null | manual | Specific uploader |
| `status` | string | null | manual | Document status |
| `tags` | string[] | null | manual | Filter by tags |
| `contentSearch` | boolean | true | config | Search within documents |
| `includeArchived` | boolean | false | manual | Include archived |
| `limit` | number | 20 | config | Max results |
| `sortBy` | string | 'relevance' | manual | Sort order |

## Execution Flow

```
START
  │
  ├─── 1. Parse search request
  │    │
  │    ├── IF documentId provided:
  │    │   └── Direct lookup → skip to step 6
  │    │
  │    ├── IF voice query:
  │    │   ├── Extract document type hints
  │    │   ├── Extract property address
  │    │   ├── Extract date references
  │    │   └── Build structured query
  │    │
  │    └── Build search query
  │
  ├─── 2. Determine search scope
  │    │
  │    ├── IF dealId:
  │    │   └── Scope to deal's documents
  │    │
  │    ├── IF no scope specified:
  │    │   └── Search agent's accessible documents
  │    │
  │    └── Apply access permissions
  │
  ├─── 3. Execute search
  │    │
  │    ├── Metadata search:
  │    │   ├── Match name, type, tags
  │    │   ├── Match folder path
  │    │   └── Match date range
  │    │
  │    ├── IF contentSearch:
  │    │   ├── Full-text search on extracted content
  │    │   └── Highlight matching snippets
  │    │
  │    └── Combine and rank results
  │
  ├─── 4. Enhance results
  │    │
  │    ├── FOR EACH document:
  │    │   ├── Generate signed download URL
  │    │   ├── Get thumbnail URL
  │    │   ├── Load deal context
  │    │   ├── Get signature status (if applicable)
  │    │   └── Calculate relevance score
  │    │
  │    └── Sort by sortBy parameter
  │
  ├─── 5. Group results (if multiple deals)
  │    ├── Group by deal
  │    ├── Group by type
  │    └── Provide summary
  │
  ├─── 6. Format response
  │    │
  │    ├── IF single document:
  │    │   └── Full document details
  │    │
  │    ├── IF multiple documents:
  │    │   └── List with summaries
  │    │
  │    └── Include:
  │        ├── Download links
  │        ├── Preview URLs
  │        ├── Related documents
  │        └── Quick actions
  │
  ├─── 7. Log action
  │    └── action_type: 'document_retrieved'
  │
  └─── 8. Return result
```

## Output

### Single Document
```typescript
{
  success: true,
  actionTaken: "Retrieved home inspection report for 123 Main St",
  result: {
    document: {
      id: "doc-uuid",
      name: "Home Inspection Report",
      type: "inspection",
      mimeType: "application/pdf",
      size: 2456789,
      pageCount: 45,
      folder: "/Inspections",

      urls: {
        download: "https://storage.homer.pro/download/...",
        preview: "https://storage.homer.pro/preview/...",
        thumbnail: "https://storage.homer.pro/thumb/..."
      },

      metadata: {
        uploadedAt: "2026-01-10T14:30:00Z",
        uploadedBy: "Mike Agent",
        inspectorName: "ABC Home Inspections",
        inspectionDate: "2026-01-10"
      },

      deal: {
        id: "deal-uuid",
        address: "123 Main St, Miami FL 33101"
      },

      signatureStatus: null,  // Not a signature document

      relatedDocuments: [
        { id: "doc-2", name: "4-Point Inspection", type: "inspection" },
        { id: "doc-3", name: "Wind Mitigation", type: "inspection" }
      ]
    },

    quickActions: [
      { action: "download", label: "Download PDF" },
      { action: "share", label: "Share with Party" },
      { action: "extract_issues", label: "Extract Issues" }
    ]
  }
}
```

### Multiple Documents
```typescript
{
  success: true,
  actionTaken: "Found 5 documents for 123 Main St",
  result: {
    summary: {
      total: 5,
      byType: {
        contract: 1,
        addendum: 2,
        inspection: 2
      }
    },

    documents: [
      {
        id: "doc-1",
        name: "FAR/BAR As-Is Contract",
        type: "contract",
        folder: "/Contract",
        uploadedAt: "2026-01-05T10:00:00Z",
        pageCount: 12,
        thumbnailUrl: "...",
        signatureStatus: "completed"
      },
      {
        id: "doc-2",
        name: "Inspection Extension Addendum",
        type: "addendum",
        folder: "/Contract",
        uploadedAt: "2026-01-12T14:00:00Z",
        pageCount: 1,
        thumbnailUrl: "...",
        signatureStatus: "pending"
      },
      // ... more documents
    ],

    groupedByFolder: {
      "/Contract": ["doc-1", "doc-2", "doc-3"],
      "/Inspections": ["doc-4", "doc-5"]
    },

    nextSteps: [
      "One document pending signature",
      "All inspections received"
    ]
  }
}
```

### Search Results with Content Matching
```typescript
{
  success: true,
  actionTaken: "Found 3 documents mentioning 'roof'",
  result: {
    query: "roof",
    total: 3,

    documents: [
      {
        id: "doc-1",
        name: "Home Inspection Report",
        type: "inspection",
        relevanceScore: 0.95,
        contentMatches: [
          {
            page: 12,
            snippet: "...the **roof** shows signs of wear with an estimated remaining life of 5-7 years...",
            context: "Section: Roof and Attic"
          },
          {
            page: 15,
            snippet: "...recommend **roof** inspection by licensed contractor before closing...",
            context: "Recommendations"
          }
        ],
        deal: {
          address: "123 Main St, Miami FL 33101"
        }
      },
      // ... more documents
    ]
  }
}
```

## Voice Response

**Single document found:**
> "I found the home inspection report for 123 Main Street.
>
> It's a 45-page report from ABC Home Inspections dated January 10th.
>
> I can send you the download link, or would you like me to show you the major findings?"

**Multiple documents found:**
> "I found 5 documents for 123 Main Street:
>
> The signed contract, two addendums - one pending signature, and two inspection reports.
>
> Which one do you need?"

**Content search results:**
> "I found 3 documents mentioning 'roof':
>
> The home inspection has the most detail - pages 12 and 15 discuss roof condition. The inspector estimates 5-7 years remaining life.
>
> Want me to pull up the full inspection report?"

**No documents found:**
> "I couldn't find any documents matching 'appraisal' for 123 Main Street.
>
> This deal has contracts and inspections, but no appraisal yet. Has the lender ordered one?"

## Search Examples

| Query | Interpretation | Results |
|-------|---------------|---------|
| "Get the contract for 123 Main" | dealId + type:contract | Contract document |
| "Inspection reports" | type:inspection, current deal | All inspections |
| "Documents from last week" | dateFrom: 7 days ago | Recent uploads |
| "Find roof issues" | content search: "roof" | Docs mentioning roof |
| "Signed addendums" | type:addendum, status:completed | Executed addendums |
| "What do we have?" | dealId only | All deal documents |

## Error Handling

| Error | Cause | Response |
|-------|-------|----------|
| `NO_RESULTS` | Nothing matched | "I couldn't find any documents matching that. Try different terms?" |
| `DEAL_NOT_FOUND` | Invalid deal | "I can't find that deal. Which property are you asking about?" |
| `ACCESS_DENIED` | No permission | "You don't have access to that document." |
| `DOCUMENT_DELETED` | Doc was deleted | "That document was deleted on [date]." |
| `EXPIRED_LINK` | URL expired | "That link has expired. Let me generate a new one." |

## Smart Suggestions

When retrieving documents, suggest related actions:

```typescript
const suggestions = {
  // For inspection reports
  inspection: [
    { action: "extract_issues", label: "Extract major issues" },
    { action: "create_repair_request", label: "Create repair request" }
  ],

  // For unsigned contracts
  pendingContract: [
    { action: "send_reminder", label: "Remind to sign" },
    { action: "check_status", label: "Check signature status" }
  ],

  // For complete deals
  closingDocs: [
    { action: "create_closing_folder", label: "Prepare closing package" },
    { action: "share_with_party", label: "Share with title company" }
  ]
};
```

## Integration Points

### Invokes
- Document storage (signed URLs)
- Full-text search index
- Thumbnail service

### Invoked By
- Voice queries
- Dashboard search
- Document viewers
- Related document links
- API requests

### Database Tables
- `documents` - Document records
- `search_index` - Full-text content
- `deals` - Deal context

## Quality Checklist

- [x] Supports free-text voice queries
- [x] Searches document content
- [x] Filters by type, date, folder
- [x] Generates secure download links
- [x] Provides document previews
- [x] Shows signature status
- [x] Groups by deal/type
- [x] Highlights search matches
- [x] Suggests related documents
- [x] Respects access permissions
- [x] Handles "not found" gracefully
- [x] Natural voice responses

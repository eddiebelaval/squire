# Skill: Fill Template

**Category:** Document
**Priority:** P0
**Approval Required:** No (generation) / Varies (sending)

## Purpose

Populate any document template with data from a deal, parties, or custom inputs. This is the universal template engine that powers all document generation in Homer Pro. It supports variable substitution, conditional sections, loops, and formatting.

## Triggers

### Voice Commands
- "Fill out [template name] for [deal/address]"
- "Generate [document] from template"
- "Create [form name] for [address]"
- "Populate [template] with deal info"
- "Use template [name]"

### Programmatic
- `POST /deals/:dealId/documents/fill-template`
- Called by other document skills
- Bulk document generation

## Required Inputs

| Input | Type | Required | Source | Description |
|-------|------|----------|--------|-------------|
| `templateId` | string | Yes | voice/manual | Template to use |
| `dealId` | UUID | Yes* | context | Deal for data extraction |
| `customData` | object | Yes* | manual | Custom data when no deal |

*Either `dealId` OR `customData` required

## Optional Inputs

| Input | Type | Default | Source | Description |
|-------|------|---------|--------|-------------|
| `overrides` | object | {} | manual | Override extracted data |
| `outputFormat` | string | 'pdf' | config | 'pdf', 'docx', 'html' |
| `preserveTemplate` | boolean | false | config | Keep unfilled placeholders |
| `dateFormat` | string | 'MMMM D, YYYY' | config | Date formatting |
| `currencyFormat` | string | 'USD' | config | Currency formatting |
| `includeBlankFields` | boolean | true | config | Show fields with no data |
| `watermark` | string | null | config | Add watermark text |

## Template Registry

| Template ID | Name | Category | Fields |
|-------------|------|----------|--------|
| `far_bar_as_is` | FAR/BAR As-Is Contract | Contract | 150+ |
| `far_bar_standard` | FAR/BAR Standard Contract | Contract | 150+ |
| `inspection_extension` | Inspection Extension | Addendum | 12 |
| `closing_extension` | Closing Extension | Addendum | 12 |
| `financing_extension` | Financing Extension | Addendum | 15 |
| `repair_credit` | Repair Credit | Addendum | 18 |
| `price_reduction` | Price Reduction | Addendum | 10 |
| `cancellation_notice` | Cancellation Notice | Notice | 15 |
| `repair_request` | Repair Request | Notice | 25+ |
| `buyer_disclosure` | Buyer Disclosure | Form | 20 |
| `seller_disclosure` | Seller Disclosure | Form | 50+ |
| `wire_instructions` | Wire Instructions | Form | 10 |
| `custom` | Custom Template | Custom | Variable |

## Execution Flow

```
START
  │
  ├─── 1. Load template
  │    ├── Get template by ID from registry
  │    ├── Validate template exists
  │    ├── Parse template for placeholders
  │    └── Identify required vs optional fields
  │
  ├─── 2. Extract deal data (if dealId provided)
  │    ├── Load deal record
  │    ├── Load all parties
  │    ├── Load deadlines
  │    ├── Load documents
  │    ├── Load agent info
  │    └── Build data context
  │
  ├─── 3. Merge custom data
  │    ├── Apply customData over deal data
  │    ├── Apply overrides over merged data
  │    └── Final data context ready
  │
  ├─── 4. Validate required fields
  │    ├── Check all required placeholders have data
  │    ├── Collect missing fields
  │    │
  │    ├── IF missing required fields:
  │    │   └── Return error with list of missing
  │    │
  │    └── IF missing optional fields:
  │        └── Log warning, continue
  │
  ├─── 5. Process template
  │    │
  │    ├── Variable substitution:
  │    │   └── {{variable}} → value
  │    │
  │    ├── Formatting:
  │    │   ├── {{date | formatDate}} → "January 15, 2026"
  │    │   ├── {{amount | currency}} → "$450,000"
  │    │   ├── {{text | uppercase}} → "TEXT"
  │    │   └── {{number | ordinal}} → "15th"
  │    │
  │    ├── Conditionals:
  │    │   ├── {{#if condition}}...{{/if}}
  │    │   ├── {{#unless condition}}...{{/unless}}
  │    │   └── {{#if condition}}...{{else}}...{{/if}}
  │    │
  │    ├── Loops:
  │    │   ├── {{#each items}}...{{/each}}
  │    │   └── Access: {{this.property}}, {{@index}}
  │    │
  │    └── Nested data:
  │        └── {{deal.address.street}}
  │
  ├─── 6. Post-processing
  │    ├── Remove empty conditional blocks
  │    ├── Clean up whitespace
  │    ├── Add page breaks where needed
  │    └── Apply watermark if specified
  │
  ├─── 7. Generate output
  │    │
  │    ├── IF outputFormat === 'pdf':
  │    │   └── Convert to PDF
  │    │
  │    ├── IF outputFormat === 'docx':
  │    │   └── Generate Word document
  │    │
  │    └── IF outputFormat === 'html':
  │        └── Return formatted HTML
  │
  ├─── 8. Store document
  │    ├── Upload to document storage
  │    ├── Create document record
  │    ├── Link to deal
  │    └── Return document URL
  │
  ├─── 9. Log action
  │    └── action_type: 'template_filled'
  │
  └─── 10. Return result
```

## Data Context Structure

```typescript
interface TemplateContext {
  // Deal information
  deal: {
    id: string;
    status: string;
    effectiveDate: Date;
    closingDate: Date;
    purchasePrice: number;
    escrowAmount: number;
    financingType: string;
    contractType: string;
    address: {
      street: string;
      unit?: string;
      city: string;
      state: string;
      zip: string;
      county: string;
    };
    legalDescription?: string;
    parcelId?: string;
  };

  // Parties
  buyers: Party[];
  sellers: Party[];
  agents: {
    listing?: Agent;
    buyers?: Agent;
  };

  // Third parties
  escrowAgent?: Company;
  titleCompany?: Company;
  lender?: Company;

  // Deadlines
  deadlines: {
    inspection?: Deadline;
    financing?: Deadline;
    closing?: Deadline;
    [key: string]: Deadline;
  };

  // Calculated values
  calculated: {
    daysUntilClosing: number;
    inspectionDaysRemaining: number;
    financingDaysRemaining: number;
  };

  // Current context
  currentDate: Date;
  currentTime: string;
  preparedBy: Agent;
}

interface Party {
  name: string;
  email: string;
  phone: string;
  address: Address;
  role: 'buyer' | 'seller';
  isPrimary: boolean;
}

interface Agent {
  name: string;
  email: string;
  phone: string;
  licenseNumber: string;
  brokerage: string;
  brokerageAddress: string;
}
```

## Template Syntax Reference

### Variables
```handlebars
{{deal.purchasePrice}}           → 450000
{{deal.purchasePrice | currency}} → $450,000
{{deal.effectiveDate | formatDate}} → January 15, 2026
{{deal.effectiveDate | formatDate:'MM/DD/YY'}} → 01/15/26
```

### Conditionals
```handlebars
{{#if deal.hasHoa}}
HOA Information:
Name: {{deal.hoa.name}}
Dues: {{deal.hoa.dues | currency}}
{{/if}}

{{#unless deal.isCash}}
Financing Terms:
Loan Type: {{deal.financingType}}
{{/unless}}

{{#if buyers.length > 1}}
Multiple buyers
{{else}}
Single buyer
{{/if}}
```

### Loops
```handlebars
{{#each buyers}}
Buyer {{@index + 1}}: {{this.name}}
Address: {{this.address.street}}, {{this.address.city}}
{{/each}}

{{#each repairItems as |item index|}}
{{index + 1}}. {{item.description}} - {{item.estimatedCost | currency}}
{{/each}}
```

### Formatters

| Formatter | Input | Output |
|-----------|-------|--------|
| `currency` | 450000 | $450,000.00 |
| `currencyWhole` | 450000 | $450,000 |
| `formatDate` | Date | January 15, 2026 |
| `formatDate:'MM/DD/YY'` | Date | 01/15/26 |
| `uppercase` | "text" | "TEXT" |
| `lowercase` | "TEXT" | "text" |
| `capitalize` | "text" | "Text" |
| `titleCase` | "the title" | "The Title" |
| `ordinal` | 15 | "15th" |
| `numberToWords` | 450000 | "four hundred fifty thousand" |
| `phone` | "3055551234" | "(305) 555-1234" |
| `ssn` | "123456789" | "XXX-XX-6789" |
| `percent` | 0.06 | "6%" |
| `yesNo` | true | "Yes" |

### Built-in Helpers
```handlebars
{{today}}                    → Current date
{{now}}                      → Current date/time
{{dateAdd deal.effectiveDate days=15}} → Date + 15 days
{{dateDiff closing effectiveDate}}     → Days between dates
{{sum item1 item2 item3}}              → Sum of values
{{default value 'N/A'}}                → Value or default
```

## Output

```typescript
{
  success: true,
  actionTaken: "Generated Inspection Extension Addendum for 123 Main St",
  result: {
    document: {
      id: "uuid",
      name: "Inspection Extension Addendum",
      templateId: "inspection_extension",
      outputFormat: "pdf",
      pdfUrl: "https://...",
      pageCount: 1,
      fileSize: 45000
    },
    dataUsed: {
      deal: "deal-uuid",
      fieldsPopulated: 12,
      fieldsSkipped: 0,
      overridesApplied: 1
    },
    warnings: [],
    nextSteps: [
      "Document generated successfully",
      "Ready to send for signature"
    ]
  }
}
```

## Voice Response

**Successful generation:**
> "I've filled out the inspection extension addendum for 123 Main Street.
>
> All 12 fields populated - buyer is John Smith, seller is Jane Doe, extending from January 30th to February 4th.
>
> Would you like me to send it for signature?"

**Missing required fields:**
> "I can't complete the financing extension addendum. I'm missing the lender name and loan amount.
>
> Can you provide those, or should I pull them from the contract?"

## Error Handling

| Error | Cause | Response |
|-------|-------|----------|
| `TEMPLATE_NOT_FOUND` | Invalid templateId | "I don't have a template called [name]. Available templates are..." |
| `DEAL_NOT_FOUND` | Invalid dealId | "I couldn't find that deal. Can you specify the property address?" |
| `MISSING_REQUIRED` | Required fields empty | "I need [fields] to complete this template." |
| `INVALID_DATA_TYPE` | Wrong data type | "The [field] needs to be a [type], but I got [actual]." |
| `TEMPLATE_PARSE_ERROR` | Malformed template | "There's an error in the template. Contact support." |
| `PDF_GENERATION_FAILED` | PDF creation failed | "I couldn't generate the PDF. Trying again..." |

## Template Creation Guidelines

### Required Elements
- Clear header with document type
- Property identification section
- Party identification section
- Date and timestamp
- Signature blocks

### Best Practices
1. Use semantic field names (`deal.purchasePrice` not `price1`)
2. Include fallbacks for optional fields
3. Format all dates and currencies
4. Handle multiple parties (co-buyers, co-sellers)
5. Include prepared by section
6. Add page breaks for multi-page documents

## Custom Template Upload

```typescript
// Custom template structure
{
  templateId: "custom_123",
  name: "My Custom Addendum",
  category: "custom",
  content: "...", // Template content
  requiredFields: ["deal.address", "buyer.name", "seller.name"],
  optionalFields: ["customField1", "customField2"],
  signatureBlocks: 2,
  createdBy: "agent-uuid"
}
```

## Quality Checklist

- [x] Supports all standard Florida RE templates
- [x] Handles variable substitution
- [x] Processes conditionals and loops
- [x] Formats dates, currencies, numbers
- [x] Validates required fields before generation
- [x] Supports multiple output formats
- [x] Handles multiple parties correctly
- [x] Creates clean, professional PDFs
- [x] Stores documents properly
- [x] Complete audit trail
- [x] Clear error messages for missing data
- [x] Extensible for custom templates

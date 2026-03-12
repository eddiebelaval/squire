# Skill: Florida FAR/BAR Contract Compliance

**Category:** Compliance
**Priority:** P0
**Approval Required:** No

## Purpose

Validate transactions against Florida Association of Realtors (FAR) and Florida Bar (BAR) contract rules. Ensures all contract provisions comply with the standard FAR/BAR AS-IS or standard residential contract forms and Florida real estate law.

## Legal Authority

- **FAR/BAR AS-IS Contract (Rev. 6/23)** - Standard form for residential sales
- **FAR/BAR Residential Contract for Sale and Purchase**
- **Florida Statutes Chapter 475** - Real Estate Brokers
- **Florida Statutes Chapter 720** - HOA Disclosure
- **Florida Statutes Chapter 718** - Condominium Act
- **FREC Rule 61J2** - Florida Real Estate Commission rules

## Triggers

### Voice Commands
- "Check contract compliance"
- "Is this FAR/BAR compliant?"
- "Validate contract for [address]"
- "Review contract terms"
- "Check if contract is valid"

### Programmatic
- Contract uploaded to deal
- Deal status changed to 'under_contract'
- Manual compliance check requested
- Amendment uploaded
- Before deadline calculation

## Required Inputs

| Input | Type | Required | Source | Description |
|-------|------|----------|--------|-------------|
| `dealId` | UUID | Yes | context | Deal being validated |
| `contractType` | string | Yes | deal | 'far_bar_as_is', 'far_bar_standard', 'custom' |
| `effectiveDate` | Date | Yes | contract | Date contract became effective |
| `purchasePrice` | number | Yes | contract | Total purchase price |

## Optional Inputs

| Input | Type | Default | Source | Description |
|-------|------|---------|--------|-------------|
| `escrowAmount` | number | null | contract | Initial deposit amount |
| `additionalDeposit` | number | null | contract | Additional deposit if any |
| `escrowHolder` | string | null | contract | Who holds escrow |
| `inspectionPeriod` | number | 15 | contract | Days for inspection |
| `financingContingency` | number | null | contract | Days for financing |
| `financingType` | string | null | contract | Cash, conventional, FHA, VA |
| `closingDate` | Date | null | contract | Target closing date |
| `personalProperty` | string[] | [] | contract | Items included |
| `isCondo` | boolean | false | contract | Condo transaction |
| `hasHoa` | boolean | false | contract | HOA property |
| `buyerAgentSide` | boolean | true | context | User represents buyer |

## Execution Flow

```
START
  │
  ├─── 1. Load contract data
  │    ├── Fetch deal record
  │    ├── Load parsed contract if available
  │    └── Identify contract version/form
  │
  ├─── 2. Validate essential elements
  │    ├── Buyer identified (name/entity)
  │    ├── Seller identified (name/entity)
  │    ├── Property legally described
  │    ├── Purchase price stated
  │    └── Effective date present
  │
  ├─── 3. Check escrow compliance
  │    ├── Escrow amount reasonable (typically 1-3%)
  │    ├── Escrow holder licensed/authorized
  │    ├── Deposit timeline stated (3 days typical)
  │    └── Additional deposit terms if applicable
  │
  ├─── 4. Validate contingency periods
  │    ├── Inspection period within norms (10-15 days)
  │    ├── Financing contingency if applicable
  │    ├── Sale contingency if applicable
  │    └── Appraisal contingency for financed deals
  │
  ├─── 5. Check required addenda
  │    ├── Condo Rider (if condo) - §718.503
  │    ├── HOA Disclosure (if HOA) - §720.401
  │    ├── Lead-Based Paint (if pre-1978)
  │    ├── Flood Zone Disclosure
  │    ├── Seller's Property Disclosure
  │    └── Energy Efficiency Disclosure
  │
  ├─── 6. Validate closing terms
  │    ├── Closing date reasonable (30-60 days typical)
  │    ├── Closing costs allocation specified
  │    ├── Proration date stated
  │    └── Title insurance requirement stated
  │
  ├─── 7. Check signature requirements
  │    └── INVOKE: signature-requirements skill
  │
  ├─── 8. Generate compliance report
  │    ├── List all passed checks
  │    ├── List any warnings
  │    ├── List any failures
  │    └── Calculate compliance score
  │
  └─── RETURN compliance_report
```

## Compliance Checks

### Essential Elements (Must Pass)

| Check | FAR/BAR Reference | Statute | Description |
|-------|-------------------|---------|-------------|
| `parties_identified` | Para 1-2 | - | Buyer and seller named |
| `property_described` | Para 3 | - | Legal description or address |
| `purchase_price` | Para 4 | - | Price clearly stated |
| `effective_date` | Para 24 | - | Date of mutual acceptance |
| `escrow_terms` | Para 5 | §475.25 | Deposit handling specified |
| `closing_date` | Para 7 | - | Date or formula for closing |

### Required Disclosures (Florida Law)

| Disclosure | Statute | Required When |
|------------|---------|---------------|
| Seller's Property Disclosure | Common Law | All residential sales |
| Lead-Based Paint | 42 USC 4852d | Built before 1978 |
| HOA Disclosure | §720.401 | Property in HOA |
| Condo Documents | §718.503 | Condo/co-op sales |
| Coastal Erosion | §161.57 | Coastal properties |
| Energy Efficiency | §553.996 | New construction |
| Flood Zone | §627.7011 | All sales (lender req) |
| Radon Gas | §404.056 | All residential |

### FAR/BAR Specific Provisions

| Provision | Paragraph | Status Check |
|-----------|-----------|--------------|
| Time is of Essence | 19 | Always applies |
| Default Remedies | 16 | Must be initialed |
| Risk of Loss | 13 | Seller bears until closing |
| Inspections | 12 | Period clearly stated |
| Financing | 9 | Terms match reality |
| Title | 10 | Marketable title required |
| Survey | 11 | Responsibility assigned |
| Prorations | 14 | Method stated |

## Output

```typescript
{
  success: true,
  actionTaken: "Compliance check completed for 123 Main St",
  result: {
    compliant: boolean,
    score: number, // 0-100
    contractType: "far_bar_as_is",
    contractVersion: "Rev. 6/23",
    checks: {
      passed: [
        { id: "parties_identified", description: "Buyer and seller identified" },
        { id: "purchase_price", description: "Price of $450,000 stated" }
      ],
      warnings: [
        {
          id: "escrow_low",
          description: "Escrow of $5,000 (1.1%) is below typical 2-3%",
          recommendation: "Consider negotiating higher deposit"
        }
      ],
      failures: [
        {
          id: "hoa_disclosure_missing",
          description: "Property is in HOA but HOA disclosure not found",
          statute: "§720.401",
          action: "Obtain HOA disclosure before closing",
          critical: true
        }
      ]
    },
    requiredActions: [
      {
        action: "Obtain HOA disclosure",
        deadline: "Before closing",
        responsible: "Seller/Listing Agent",
        statute: "§720.401"
      }
    ],
    missingAddenda: ["HOA Disclosure Summary"],
    recommendations: [
      "Consider increasing escrow deposit",
      "Verify flood zone status"
    ]
  }
}
```

## Voice Response

**Fully Compliant:**
> "The contract for 123 Main Street is FAR/BAR compliant. All required elements are present, disclosures are complete, and the timeline is valid. I found no issues. The inspection period ends January 30th and closing is set for March 12th."

**With Warnings:**
> "The contract is mostly compliant, but I have two concerns. First, the escrow deposit of $5,000 is lower than the typical 2-3%. Second, I don't see a signed lead-based paint disclosure - the home was built in 1972. Want me to flag these for the title company?"

**Non-Compliant:**
> "I found a compliance issue. The property is in a homeowners association, but there's no HOA disclosure on file. Florida statute 720.401 requires this before closing. The seller needs to provide the HOA disclosure summary. Should I send a reminder to the listing agent?"

## Error Handling

| Error | Cause | Response |
|-------|-------|----------|
| `CONTRACT_NOT_FOUND` | No contract uploaded | "I need the contract document to check compliance. Please upload it." |
| `MISSING_ESSENTIAL` | Key field not parseable | "I couldn't find the [field] in the contract. Can you tell me what it is?" |
| `UNSUPPORTED_FORM` | Non-standard contract | "This isn't a standard FAR/BAR form. I'll do my best, but recommend attorney review." |
| `OUTDATED_FORM` | Old contract version | "This uses an older FAR/BAR form. Some provisions may have changed. Consider using the current version." |

## Integration Points

### Related Skills
- `signature-requirements` - Check signing compliance
- `disclosure-requirements` - Detailed disclosure checklist
- `deadline-calculation-rules` - Validate timeline compliance
- `time-is-of-the-essence` - Strict deadline enforcement

### Database Tables
- `deals` - Contract details
- `documents` - Uploaded contracts/addenda
- `compliance_checks` - Store results
- `action_log` - Audit trail

### External Resources
- FAR Forms Library
- Florida Statutes online
- County-specific requirements

## Quality Checklist

- [x] Validates all FAR/BAR essential elements
- [x] Checks Florida statutory disclosures
- [x] Identifies missing addenda
- [x] Flags low escrow deposits
- [x] Verifies timeline reasonableness
- [x] Cites specific statutes
- [x] Provides actionable remediation
- [x] Handles custom contracts gracefully
- [x] Creates audit trail
- [x] Voice-friendly responses

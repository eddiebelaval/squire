# Skill: Florida Disclosure Requirements

**Category:** Compliance
**Priority:** P0
**Approval Required:** No

## Purpose

Track and verify all required disclosures in a Florida real estate transaction. Provides a comprehensive checklist of federal, state, and property-specific disclosure requirements, ensuring legal compliance and reducing liability.

## Legal Authority

- **Florida Statutes Chapter 475** - Real Estate Brokers
- **Florida Statutes Chapter 720** - HOA Disclosure
- **Florida Statutes Chapter 718** - Condominium Act
- **Florida Statutes §689.25** - Radon Gas Disclosure
- **Florida Statutes §404.056** - Radon Protection
- **Florida Statutes §161.57** - Coastal Construction
- **Florida Statutes §627.7011** - Flood Insurance
- **42 U.S.C. §4852d** - Lead-Based Paint Disclosure
- **RESPA (12 U.S.C. §2601)** - Settlement procedures

## Triggers

### Voice Commands
- "What disclosures are required?"
- "Check disclosures for [address]"
- "What's missing for closing?"
- "Generate disclosure checklist"
- "Is the lead paint disclosure done?"
- "Do we need HOA documents?"

### Programmatic
- Deal created
- Compliance check requested
- Closing checklist generated
- Document upload (auto-check-off)
- Pre-closing review

## Required Inputs

| Input | Type | Required | Source | Description |
|-------|------|----------|--------|-------------|
| `dealId` | UUID | Yes | context | Deal to check |
| `propertyType` | string | Yes | deal | 'single_family', 'condo', 'townhouse', etc. |
| `yearBuilt` | number | Yes | property | Year of construction |

## Optional Inputs

| Input | Type | Default | Source | Description |
|-------|------|---------|--------|-------------|
| `hasHoa` | boolean | false | deal | Property has HOA |
| `isCondo` | boolean | false | deal | Is condominium |
| `isCoastal` | boolean | false | property | Coastal property |
| `floodZone` | string | null | property | FEMA flood zone |
| `hasPool` | boolean | false | property | Property has pool |
| `hasSeptic` | boolean | false | property | Septic system |
| `hasWell` | boolean | false | property | Private well |
| `newConstruction` | boolean | false | property | New build |
| `isForeign` | boolean | false | seller | Foreign seller (FIRPTA) |

## Disclosure Matrix

### Universal Disclosures (All FL Sales)

| Disclosure | Statute | Required By | Timing | Form |
|------------|---------|-------------|--------|------|
| **Seller's Property Disclosure** | Common Law | Seller | Before contract | SPD Form |
| **Radon Gas Disclosure** | §689.25 | Seller | In contract | Contract language |
| **Real Estate Brokerage Disclosure** | §475.278 | Agent | First contact | Notice form |
| **Energy Efficiency Brochure** | §553.996 | Seller | At/before contract | State brochure |

### Property-Specific Disclosures

| Disclosure | Statute | Required When | Timing | Form |
|------------|---------|---------------|--------|------|
| **Lead-Based Paint** | 42 USC 4852d | Built before 1978 | Before contract | Federal form |
| **HOA Disclosure Summary** | §720.401 | Has HOA | Before contract | Seller provides |
| **Condo/Co-op Documents** | §718.503 | Condo sale | 3-day review period | Association docs |
| **Coastal Construction** | §161.57 | Coastal property | Before contract | State notice |
| **Flood Zone Disclosure** | §627.7011 | Flood zone property | Before closing | Lender requirement |
| **FIRPTA Affidavit** | 26 USC 1445 | Foreign seller | At closing | IRS form |
| **Pool Safety Disclosure** | §515.27 | Has pool | At contract | Safety notice |
| **Septic Disclosure** | Local codes | Has septic | Before contract | Inspection report |
| **Well Water Disclosure** | §373.323 | Has well | Before contract | Water test |
| **Mold Disclosure** | §404.056 | Known mold | Immediate | Written notice |
| **Chinese Drywall** | Common Law | Known issue | Immediate | Written notice |
| **Sinkholes** | §627.7073 | Known/suspected | Before contract | Written notice |
| **Homeowners Insurance** | §627.7011 | All sales | Before closing | Written notice |

### New Construction Disclosures

| Disclosure | Statute | Required When | Timing | Form |
|------------|---------|---------------|--------|------|
| **Builder Warranty** | §553.835 | New construction | At closing | Warranty docs |
| **Energy Rating** | §553.996 | New construction | At closing | Energy cert |
| **Impact Windows** | §553.844 | New construction | At closing | Certificate |
| **Termite Bond** | Industry std | New construction | At closing | Bond document |

## Execution Flow

```
START
  │
  ├─── 1. Load deal and property data
  │    ├── Get deal record
  │    ├── Get property characteristics
  │    └── Get uploaded documents
  │
  ├─── 2. Build disclosure requirements list
  │    ├── Add universal disclosures
  │    ├── Check year built → Add lead paint if < 1978
  │    ├── Check hasHoa → Add HOA disclosure
  │    ├── Check isCondo → Add condo docs
  │    ├── Check isCoastal → Add coastal notice
  │    ├── Check floodZone → Add flood disclosure
  │    ├── Check hasPool → Add pool safety
  │    ├── Check hasSeptic → Add septic disclosure
  │    ├── Check hasWell → Add well disclosure
  │    ├── Check newConstruction → Add builder disclosures
  │    └── Check isForeign → Add FIRPTA
  │
  ├─── 3. Match against uploaded documents
  │    ├── Scan document names/types
  │    ├── Mark as complete if found
  │    └── Note upload date
  │
  ├─── 4. Calculate compliance status
  │    ├── Required: Must have before closing
  │    ├── Recommended: Best practice
  │    ├── Complete: Document on file
  │    └── Missing: Required but not found
  │
  ├─── 5. Generate checklist with deadlines
  │    ├── Pre-contract disclosures
  │    ├── Due diligence disclosures
  │    ├── Pre-closing disclosures
  │    └── At-closing disclosures
  │
  └─── RETURN disclosure_checklist
```

## Output

```typescript
{
  success: true,
  actionTaken: "Generated disclosure checklist for 123 Main St",
  result: {
    propertyProfile: {
      yearBuilt: 1972,
      hasHoa: true,
      isCondo: false,
      isCoastal: false,
      floodZone: "X",
      hasPool: true
    },
    totalRequired: 8,
    completed: 5,
    missing: 3,
    percentComplete: 62.5,
    disclosures: {
      complete: [
        {
          name: "Seller's Property Disclosure",
          statute: "Common Law",
          uploadedDate: "2026-01-10",
          documentId: "doc_123"
        },
        {
          name: "Radon Gas Disclosure",
          statute: "§689.25",
          status: "In contract language",
          documentId: null
        }
      ],
      missing: [
        {
          name: "Lead-Based Paint Disclosure",
          statute: "42 USC 4852d",
          required: true,
          reason: "Property built in 1972 (before 1978)",
          deadline: "Before contract execution",
          responsible: "Seller",
          action: "Provide EPA lead disclosure form and pamphlet",
          penalty: "Up to $16,773 per violation"
        },
        {
          name: "HOA Disclosure Summary",
          statute: "§720.401",
          required: true,
          reason: "Property is in an HOA",
          deadline: "Before contract",
          responsible: "Seller",
          action: "Request from HOA management company"
        },
        {
          name: "Pool Safety Disclosure",
          statute: "§515.27",
          required: true,
          reason: "Property has pool",
          deadline: "At contract",
          responsible: "Seller",
          action: "Provide pool safety compliance disclosure"
        }
      ],
      recommended: [
        {
          name: "Home Inspection Report",
          required: false,
          reason: "Best practice for buyer protection",
          status: "Not uploaded"
        }
      ]
    },
    byTimeline: {
      preContract: ["Lead-Based Paint", "HOA Disclosure"],
      dueDiligence: ["Home Inspection"],
      preClosing: ["Flood Insurance Notice"],
      atClosing: ["FIRPTA (if applicable)"]
    },
    nextAction: {
      disclosure: "Lead-Based Paint Disclosure",
      responsible: "Seller/Listing Agent",
      suggestion: "Obtain EPA form and have seller sign before contract execution"
    }
  }
}
```

## Voice Response

**All Complete:**
> "All required disclosures are complete for 123 Main Street. I have the seller's disclosure, radon statement, and HOA documents on file. You're good to go for closing."

**Missing Disclosures:**
> "I'm missing 3 disclosures for 123 Main Street. Most urgent: the lead-based paint disclosure - the home was built in 1972. The seller needs to sign the EPA form before the contract is executed. Want me to send them a reminder?"

**Condo Transaction:**
> "This is a condo sale, so under Florida Statute 718.503, the buyer has 3 days to review the condo documents after receipt. I don't see the condo docs uploaded yet. The seller needs to provide the declaration, bylaws, FAQ sheet, and most recent budget. Should I request these from the association?"

## Error Handling

| Error | Cause | Response |
|-------|-------|----------|
| `YEAR_BUILT_UNKNOWN` | Missing construction year | "I need to know when the property was built to check lead paint requirements. What year was it constructed?" |
| `PROPERTY_TYPE_UNKNOWN` | Type not specified | "Is this a condo, townhouse, or single-family home? That affects the disclosure requirements." |
| `HOA_STATUS_UNKNOWN` | HOA not confirmed | "I'm not sure if this property has an HOA. Can you confirm? If yes, we'll need the HOA disclosure summary." |
| `DOCUMENT_PARSE_FAIL` | Can't identify document | "I see a document was uploaded but can't identify it. What type of disclosure is this?" |

## Integration Points

### Related Skills
- `florida-far-bar-rules` - Contract compliance check
- `signature-requirements` - Who signs disclosures
- `parse-document` - Identify uploaded documents

### Database Tables
- `deals` - Property characteristics
- `documents` - Uploaded disclosures
- `disclosure_checklist` - Tracking table
- `action_log` - Audit trail

### External Resources
- EPA Lead Paint Forms
- Florida DBPR Forms
- County-specific requirements

## Disclosure Templates

Homer Pro should have these templates available:

1. Seller's Property Disclosure (Florida standard)
2. Lead-Based Paint Disclosure (EPA form)
3. HOA Disclosure Summary (§720.401 format)
4. Radon Gas Notice (contract addendum)
5. Pool Safety Disclosure
6. Coastal Property Notice
7. Flood Insurance Notice
8. FIRPTA Withholding Notice
9. Brokerage Relationship Disclosure

## Quality Checklist

- [x] Covers all Florida statutory disclosures
- [x] Includes federal requirements (lead, FIRPTA)
- [x] Property-type specific requirements
- [x] Tracks completion status
- [x] Provides deadline guidance
- [x] Identifies responsible party
- [x] Cites statutes and penalties
- [x] Auto-detects from uploaded docs
- [x] Voice-friendly responses
- [x] Suggests next action

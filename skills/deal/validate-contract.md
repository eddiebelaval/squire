# Skill: Validate Contract

**Category:** Deal
**Priority:** P0
**Approval Required:** No

## Purpose

Check a real estate contract for errors, missing fields, inconsistencies, and compliance issues. This skill ensures contracts are complete and accurate before execution, reducing risk of delays or failed transactions.

## Triggers

### Voice Commands
- "Check this contract"
- "Validate the contract"
- "Is this contract complete?"
- "Review contract for errors"
- "What's wrong with this contract?"
- "Contract compliance check"

### Programmatic
- Automatically after `parse-contract` skill completes
- API call to `/contracts/validate`
- Agent dashboard "Validate" button
- Before deal status change to 'active'

## Required Inputs

| Input | Type | Required | Source | Description |
|-------|------|----------|--------|-------------|
| `contractData` | object | Yes | parse-contract | Parsed contract data object |

OR

| Input | Type | Required | Source | Description |
|-------|------|----------|--------|-------------|
| `contractFile` | File/URL | Yes | upload | PDF to parse then validate |

## Optional Inputs

| Input | Type | Default | Source | Description |
|-------|------|---------|--------|-------------|
| `dealId` | UUID | null | context | Existing deal for cross-reference |
| `strictMode` | boolean | false | config | Fail on warnings, not just errors |
| `checkSignatures` | boolean | true | config | Verify all signature fields are complete |
| `validateParties` | boolean | true | config | Check party info completeness |
| `checkDates` | boolean | true | config | Validate date logic and conflicts |

## Execution Flow

```
START
  │
  ├─── 1. Prepare contract data
  │    ├── If contractFile provided → invoke parse-contract
  │    ├── If contractData provided → use directly
  │    └── If dealId provided → load existing contract data
  │
  ├─── 2. Required fields check
  │    ├── Property address complete
  │    ├── Purchase price present
  │    ├── Effective date present
  │    ├── Closing date present
  │    ├── At least one buyer named
  │    ├── At least one seller named
  │    ├── Escrow deposit amount specified
  │    └── Financing type indicated
  │
  ├─── 3. Date logic validation
  │    ├── Effective date is not in future (or reasonable range)
  │    ├── Closing date is after effective date
  │    ├── Inspection period ends before closing
  │    ├── Financing contingency ends before closing
  │    ├── Escrow deposit due date is after effective
  │    ├── All dates are valid calendar dates
  │    └── Check for weekend/holiday closings
  │
  ├─── 4. Financial consistency check
  │    ├── Escrow + additional deposit + balance = purchase price
  │    ├── If financed: loan amount is reasonable percentage
  │    ├── Down payment aligns with financing type
  │    ├── Escrow deposit meets minimum requirements
  │    └── Price is within reasonable range for property type
  │
  ├─── 5. Party information validation
  │    ├── Buyer name is complete (not just first name)
  │    ├── Seller name matches property records (if available)
  │    ├── Contact information present for key parties
  │    ├── Agent license numbers format is valid
  │    └── Brokerage information present
  │
  ├─── 6. Florida-specific compliance
  │    ├── FAR/BAR form version is current
  │    ├── Required disclosures present
  │    │   ├── Lead paint (if pre-1978)
  │    │   ├── Flood zone disclosure
  │    │   ├── Property tax disclosure
  │    │   ├── HOA disclosure (if applicable)
  │    │   ├── Condo disclosure (if applicable)
  │    │   └── Wire fraud warning
  │    ├── Correct addenda attached for deal type
  │    └── DBPR regulations compliance
  │
  ├─── 7. Signature verification (if checkSignatures)
  │    ├── Buyer signature(s) present
  │    ├── Seller signature(s) present
  │    ├── All pages initialed where required
  │    ├── Agent signatures present
  │    └── Date signed matches or near effective date
  │
  ├─── 8. Contingency validation
  │    ├── Contingency days are reasonable
  │    ├── AS-IS vs standard terms align with addenda
  │    ├── Financing contingency matches financing type
  │    └── HOA/Condo terms present if property has HOA
  │
  ├─── 9. Cross-reference deal (if dealId provided)
  │    ├── Property address matches deal
  │    ├── Parties match deal records
  │    ├── Dates align with deal deadlines
  │    └── Price matches deal record
  │
  ├─── 10. Compile validation report
  │     ├── Categorize issues: ERROR / WARNING / INFO
  │     ├── Calculate overall validation score
  │     ├── Prioritize issues by impact
  │     └── Generate recommendations
  │
  ├─── 11. Log validation
  │     └── action_type: 'contract_validated'
  │
  └── RETURN validation report
```

## Output

```typescript
{
  success: true,
  actionTaken: "Validated contract for 123 Main St, Miami FL 33101",
  result: {
    isValid: false, // true if no ERRORS (warnings allowed)
    validationScore: 72, // 0-100

    summary: {
      errors: 2,
      warnings: 3,
      info: 4,
      passed: 28
    },

    errors: [
      {
        code: "MISSING_SELLER_SIGNATURE",
        field: "signatures.seller",
        message: "Seller has not signed the contract",
        severity: "error",
        page: 7,
        impact: "Contract is not executable without seller signature",
        recommendation: "Obtain seller signature on page 7 before proceeding"
      },
      {
        code: "MATH_ERROR_DEPOSITS",
        field: "financial",
        message: "Deposits don't add up to purchase price: $10,000 + $15,000 + $430,000 = $455,000 but price is $450,000",
        severity: "error",
        page: 2,
        impact: "Financial terms are inconsistent",
        recommendation: "Verify deposit amounts and balance due with all parties"
      }
    ],

    warnings: [
      {
        code: "CLOSING_ON_WEEKEND",
        field: "dates.closingDate",
        message: "Closing date (March 14, 2026) falls on a Saturday",
        severity: "warning",
        impact: "Title company may not be open; may need to adjust",
        recommendation: "Confirm with title company or adjust to Friday March 13th"
      },
      {
        code: "OUTDATED_FORM_VERSION",
        field: "contractType",
        message: "Contract uses FAR/BAR Rev. 6/21, current version is Rev. 8/22",
        severity: "warning",
        impact: "Minor form updates may not be reflected",
        recommendation: "Consider using current form version for new contracts"
      },
      {
        code: "MISSING_WIRE_FRAUD_WARNING",
        field: "disclosures",
        message: "Wire fraud warning addendum not detected",
        severity: "warning",
        impact: "Best practice for buyer protection",
        recommendation: "Add wire fraud warning addendum"
      }
    ],

    info: [
      {
        code: "HOA_APPROVAL_REQUIRED",
        field: "contingencies.hoa",
        message: "HOA approval contingency present - 30 days",
        severity: "info",
        impact: "Buyer has right to cancel if HOA denies",
        recommendation: "Ensure HOA application submitted promptly"
      },
      {
        code: "AS_IS_CONTRACT",
        field: "contractType",
        message: "This is an AS-IS contract - inspection is for information only",
        severity: "info",
        impact: "Seller not obligated to make repairs",
        recommendation: "Ensure buyer understands AS-IS terms"
      },
      {
        code: "FLOOD_ZONE_AE",
        field: "property.floodZone",
        message: "Property is in flood zone AE - flood insurance required",
        severity: "info",
        impact: "Buyer must obtain flood insurance",
        recommendation: "Get flood insurance quote early in process"
      },
      {
        code: "PRE_1978_BUILDING",
        field: "disclosures.leadPaint",
        message: "Property built before 1978 - lead paint disclosure required",
        severity: "info",
        impact: "Federal requirement",
        recommendation: "Verify lead paint disclosure is signed"
      }
    ],

    passedChecks: [
      "Property address complete",
      "Purchase price present and reasonable",
      "Effective date valid",
      "Closing date after effective date",
      "Buyer information complete",
      "Inspection period before closing",
      "Financing contingency before closing",
      "Escrow holder specified",
      "Agent license numbers valid format",
      // ... more passed checks
    ],

    floridaCompliance: {
      isCompliant: true,
      farBarVersion: "Rev. 6/21",
      currentVersion: "Rev. 8/22",
      requiredDisclosures: {
        leadPaint: true,
        floodZone: true,
        propertyTax: true,
        hoa: true,
        wireFraud: false
      }
    },

    recommendations: [
      {
        priority: 1,
        action: "Obtain seller signature on page 7",
        deadline: "Before presenting to buyer",
        assignTo: "listing_agent"
      },
      {
        priority: 2,
        action: "Resolve deposit math discrepancy",
        deadline: "Before execution",
        assignTo: "both_agents"
      },
      {
        priority: 3,
        action: "Confirm Saturday closing with title company",
        deadline: "Within 48 hours",
        assignTo: "transaction_coordinator"
      }
    ]
  }
}
```

## Voice Response

**Valid Contract:**
> "I've checked the contract for 123 Main Street. Everything looks good - all required fields are present, the dates make sense, and the numbers add up. The contract is ready for execution.
>
> A few things to note: this is an AS-IS contract, the property is in flood zone AE so flood insurance will be required, and it's a pre-1978 home so make sure the lead paint disclosure is signed.
>
> Ready to create the deal?"

**Contract with Issues:**
> "I found some issues with the contract for 123 Main Street.
>
> Two things need to be fixed before we can proceed:
> 1. The seller hasn't signed - we need their signature on page 7
> 2. The deposits don't add up right - $10,000 plus $15,000 plus $430,000 equals $455,000, but the purchase price is $450,000
>
> Also, the closing is scheduled for Saturday March 14th - you'll want to check with the title company on that.
>
> Want me to flag these for follow-up?"

**Critical Errors:**
> "This contract has problems that need to be fixed right away.
>
> I'm seeing a serious issue: there's no seller signature, and the financial terms are inconsistent. The deposit amounts don't add up to the purchase price.
>
> I'd recommend not proceeding until these are resolved. Should I create tasks for the corrections needed?"

## Error Handling

| Error | Cause | Response |
|-------|-------|----------|
| `NO_CONTRACT_DATA` | Neither file nor data provided | "I need a contract to validate. Please upload the PDF or select an existing contract." |
| `PARSE_FAILED` | Could not parse provided file | "I couldn't read this contract. Can you provide a clearer PDF?" |
| `DEAL_NOT_FOUND` | Invalid dealId provided | "I can't find that deal. Can you verify the deal ID?" |
| `INVALID_CONTRACT_TYPE` | Unrecognized contract format | "This doesn't look like a Florida residential contract. I can still check what's there, but some validations may not apply." |

## Integration Points

### Triggers After Validation
- If `isValid=true`: Prompt to create/update deal
- If `isValid=false`: Create tasks for corrections
- Store validation report for audit trail

### Database Tables
- `contract_validations` - Validation history
- `validation_issues` - Individual issues found
- `action_log` - Audit entry

### External Services
- Property records API (for seller name verification)
- FAR/BAR form version database
- Florida DBPR license lookup (agent validation)

## Florida-Specific Validation Rules

### Required Disclosures by Property Type
| Property Type | Required Disclosures |
|---------------|---------------------|
| All | Property tax disclosure, wire fraud warning |
| Pre-1978 | Lead paint disclosure |
| Flood zone | Flood zone disclosure |
| HOA property | HOA disclosure (Homeowner Association/Community Disclosure) |
| Condo | Condo disclosure, condo documents |
| Coastal | Coastal construction control line disclosure (if applicable) |

### FAR/BAR Form Versions
| Version | Status | Notes |
|---------|--------|-------|
| Rev. 8/22 | Current | Latest version |
| Rev. 6/21 | Outdated | Still valid but warn |
| Rev. 11/19 | Outdated | Recommend update |
| Pre-2019 | Critical | Should not use |

### Deposit Requirements
- Initial escrow: Typically within 3 business days of effective date
- Minimum conventional: Usually 1-3% of purchase price
- FHA/VA: Specific requirements apply

## Example Usage

### Auto-Validation After Parse
```
[After parse-contract completes]

Homer: "I've reviewed the contract and found a few things:

        ISSUES TO FIX:
        1. The seller hasn't signed page 7 yet
        2. The escrow deposit is due January 18th, but that's MLK Day -
           the title company will be closed

        THINGS TO NOTE:
        - This is an AS-IS contract
        - HOA approval is required within 30 days
        - Property is in flood zone AE

        Everything else checks out. Want me to create the deal once
        the seller signs?"
```

### Manual Validation Request
```
Agent: "Check the Smith contract for any issues"

Homer: "Looking at the contract for 123 Main Street...

        Good news - this contract is complete and ready to go.

        All signatures are present, the dates are logical, and
        the financial terms add up correctly.

        The only note I have is that this uses the June 2021
        FAR/BAR form - there's a newer version, but this one
        is still valid.

        Ready to proceed with the deal?"
```

### Strict Mode Validation
```
Agent: "I need a strict compliance check on this contract"

Homer: "Running strict validation for 123 Main Street...

        In strict mode, I'm flagging 3 items that would normally
        be warnings:

        1. Wire fraud warning addendum not attached (best practice)
        2. Form version is Rev. 6/21, not current Rev. 8/22
        3. Closing date is on a Saturday

        Plus the 2 errors that definitely need fixing:
        - Missing seller signature
        - Deposit math doesn't add up

        Should I create tasks for all 5 items?"
```

## Quality Checklist

- [x] Handles voice input naturally
- [x] Accepts parsed data or raw file
- [x] Checks all required fields
- [x] Validates date logic and conflicts
- [x] Verifies financial consistency
- [x] Checks Florida-specific requirements
- [x] Validates signatures when detectable
- [x] Categorizes issues by severity (error/warning/info)
- [x] Provides actionable recommendations
- [x] Cross-references with existing deal data
- [x] Supports strict mode for compliance review
- [x] Creates audit log entry
- [x] Handles errors gracefully
- [x] Florida-specific compliance checks

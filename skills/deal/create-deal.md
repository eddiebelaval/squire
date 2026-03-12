# Skill: Create Deal

**Category:** Deal
**Priority:** P0
**Approval Required:** No

## Purpose

Create a new real estate transaction in Homer Pro. This is the foundational action that initiates all tracking, deadlines, and coordination for a property sale.

## Triggers

### Voice Commands
- "New deal at [address]"
- "Create transaction for [address]"
- "Start deal for [address]"
- "Add property [address]"
- "Open file for [address]"

### Programmatic
- Contract PDF uploaded
- Email with contract forwarded
- API call to `/deals`
- Agent dashboard "New Deal" button

## Required Inputs

| Input | Type | Required | Source | Description |
|-------|------|----------|--------|-------------|
| `propertyAddress` | Address | Yes | voice/manual/contract | Full property address |
| `propertyAddress.street` | string | Yes | - | Street address |
| `propertyAddress.city` | string | Yes | - | City |
| `propertyAddress.state` | string | Yes | - | State (FL) |
| `propertyAddress.zip` | string | Yes | - | ZIP code |
| `propertyAddress.county` | string | Yes | - | County name |

## Optional Inputs

| Input | Type | Default | Source | Description |
|-------|------|---------|--------|-------------|
| `effectiveDate` | Date | null | contract | Contract effective date |
| `closingDate` | Date | null | contract | Target closing date |
| `purchasePrice` | number | null | contract | Purchase price |
| `escrowAmount` | number | null | contract | Escrow deposit amount |
| `inspectionPeriodDays` | number | 15 | contract | Days for inspection |
| `financingContingencyDays` | number | 30 | contract | Days for financing |
| `contractType` | string | 'far_bar_as_is' | contract | Contract form type |
| `financingType` | string | null | contract | Cash, conventional, FHA, VA |
| `hasHoa` | boolean | false | contract | Property has HOA |
| `isCondo` | boolean | false | contract | Is condo/co-op |
| `notes` | string | null | manual | Agent notes |

## Execution Flow

```
START
  │
  ├─── 1. Validate inputs
  │    ├── Address is complete
  │    ├── State is Florida (or supported state)
  │    └── No duplicate deal for same address (active)
  │
  ├─── 2. Create deal record
  │    ├── Generate UUID
  │    ├── Set status = 'draft' (or 'active' if effectiveDate)
  │    ├── Store all provided fields
  │    └── Set timestamps
  │
  ├─── 3. If effectiveDate provided:
  │    └── INVOKE: calculate-deadlines skill
  │        └── Generate all default deadlines
  │
  ├─── 4. Create default parties (if known)
  │    ├── Add listing agent (current user)
  │    └── Placeholder for buyer, seller, title, lender
  │
  ├─── 5. Log action
  │    └── action_type: 'deal_created'
  │
  ├─── 6. Notify agent
  │    └── "Created deal for [address]"
  │
  └─── 7. If from contract upload:
       └── Store original_contract_url
  │
  └── RETURN deal object
```

## Output

```typescript
{
  success: true,
  actionTaken: "Created deal for 123 Main St, Miami FL 33101",
  result: {
    deal: Deal,
    deadlines: Deadline[], // If effectiveDate was provided
    nextSteps: [
      "Add buyer and seller contact information",
      "Set effective date to generate deadlines",
      "Upload contract for reference"
    ]
  }
}
```

## Voice Response

**If effectiveDate provided:**
> "Created deal for 123 Main Street, Miami. I've generated 10 deadlines based on the effective date of January 15th. Closing is scheduled for March 12th. The inspection period ends January 30th. Would you like me to add the buyer and seller contacts?"

**If no effectiveDate:**
> "Created deal for 123 Main Street, Miami. Once you have the effective date, I'll generate all the deadlines. Would you like to add any details now?"

## Error Handling

| Error | Cause | Response |
|-------|-------|----------|
| `INVALID_ADDRESS` | Address incomplete | "I need a complete address including street, city, state, and ZIP." |
| `DUPLICATE_DEAL` | Active deal exists for address | "There's already an active deal for this address. Did you mean to update it?" |
| `UNSUPPORTED_STATE` | State not Florida | "I currently only support Florida transactions. Would you like to continue anyway?" |
| `INVALID_DATES` | Closing before effective | "The closing date can't be before the effective date." |

## Integration Points

### Triggers After Creation
- If `effectiveDate`: Auto-invoke `calculate-deadlines`
- Send confirmation to agent (email/push)
- Add to agent's dashboard

### Database Tables
- `deals` - Main record
- `parties` - Default listing agent
- `deadlines` - If dates provided
- `action_log` - Audit entry

## Example Usage

### From Voice
```
Agent: "Hey Homer, new deal at 123 Main Street, Miami 33101,
        purchase price 450,000, closing March 12th"

Homer: "Got it. Creating deal for 123 Main Street, Miami 33101.
        Purchase price $450,000, closing March 12th.

        Do you have the effective date? That's when I'll start
        calculating all your deadlines."

Agent: "Effective date is January 15th"

Homer: "Perfect. Deal created with effective date January 15th.
        I've generated all your deadlines:
        - Escrow deposit due: January 18th
        - Inspection period ends: January 30th
        - Financing contingency: February 14th
        - Closing: March 12th

        I'll start sending reminders 5 days before each deadline.
        Who are the buyer and seller?"
```

### From Contract Upload
```
Agent uploads: FAR_BAR_Contract_123_Main.pdf

Homer: [Invokes parse-contract skill]
       "I've extracted the following from the contract:
        - Property: 123 Main St, Miami FL 33101
        - Purchase Price: $450,000
        - Effective Date: January 15, 2026
        - Closing Date: March 12, 2026
        - Buyer: John Smith
        - Seller: Jane Doe

        Creating deal with these details and generating deadlines.
        Confirm or let me know what to change."
```

## Quality Checklist

- [x] Handles voice input naturally
- [x] Handles contract parsing
- [x] Validates all required fields
- [x] Prevents duplicates
- [x] Auto-generates deadlines when possible
- [x] Creates audit log entry
- [x] Returns actionable next steps
- [x] Provides clear voice response
- [x] Handles errors gracefully
- [x] Florida-specific defaults applied

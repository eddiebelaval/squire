# Skill: Add Party

**Category:** Party
**Priority:** P0
**Approval Required:** No

## Purpose

Add a new party to a real estate transaction. Parties are the individuals or entities involved in the deal: buyers, sellers, agents, lenders, title companies, inspectors, and more. This is the foundational action for all party management in Homer Pro.

## Triggers

### Voice Commands
- "Add [role] to this deal"
- "Add [name] as the [role]"
- "[Name] is the buyer's agent"
- "The lender is [company name]"
- "Add title company [name]"
- "John Smith is buying the property"

### Programmatic
- Contract parsing extracts parties
- Agent dashboard "Add Party" button
- API call to `/deals/:id/parties`
- Email signature extraction
- Business card scan

## Required Inputs

| Input | Type | Required | Source | Description |
|-------|------|----------|--------|-------------|
| `dealId` | UUID | Yes | context | Deal to add party to |
| `role` | PartyRole | Yes | voice/manual | Party's role in transaction |

## Optional Inputs

| Input | Type | Default | Source | Description |
|-------|------|---------|--------|-------------|
| `firstName` | string | null | voice/manual | First name |
| `lastName` | string | null | voice/manual | Last name |
| `companyName` | string | null | voice/manual | Company/organization name |
| `email` | string | null | voice/manual | Primary email |
| `phone` | string | null | voice/manual | Primary phone |
| `licenseNumber` | string | null | manual | License # (agents, inspectors) |
| `address` | Address | null | manual | Mailing address |
| `notes` | string | null | manual | Agent notes about party |
| `isPrimary` | boolean | true | auto | Primary contact for this role |
| `communicationPrefs` | CommPrefs | default | manual | Contact preferences |

## Party Roles

| Role | Code | Typical Count | Required Info |
|------|------|---------------|---------------|
| Buyer | `buyer` | 1-4 | Name, email, phone |
| Seller | `seller` | 1-4 | Name, email, phone |
| Buyer's Agent | `buyer_agent` | 1 | Name, email, phone, license |
| Listing Agent | `listing_agent` | 1 | Name, email, phone, license |
| Lender | `lender` | 1 | Company, contact, email, phone |
| Title Company | `title_company` | 1 | Company, contact, email, phone |
| Escrow Officer | `escrow_officer` | 1 | Name, email, phone |
| Inspector | `inspector` | 1-3 | Company, name, phone, license |
| Appraiser | `appraiser` | 1 | Company, name, phone |
| Insurance Agent | `insurance_agent` | 1 | Company, name, email, phone |
| HOA | `hoa` | 0-2 | Company, contact, email, phone |
| Attorney | `attorney` | 0-2 | Name, firm, email, phone, bar # |
| Transaction Coord | `transaction_coordinator` | 0-1 | Name, email, phone |
| Mortgage Broker | `mortgage_broker` | 0-1 | Name, company, email, phone |

## Execution Flow

```
START
  |
  +--- 1. Validate inputs
  |    +-- Deal exists and agent has access
  |    +-- Role is valid PartyRole enum
  |    +-- No duplicate party (same email + same role)
  |
  +--- 2. Parse and normalize contact info
  |    +-- Phone: normalize to E.164 format
  |    +-- Email: lowercase, validate format
  |    +-- Name: proper case, split first/last
  |    +-- License: strip non-alphanumeric
  |
  +--- 3. Check for existing party in system
  |    +-- Search by email across all deals
  |    +-- Search by phone number
  |    |
  |    +-- IF FOUND existing party:
  |    |   +-- Link to existing party record
  |    |   +-- Update any new information
  |    |   +-- "I recognize [name] from previous deals"
  |    |
  |    +-- IF NOT FOUND:
  |        +-- Create new party record
  |
  +--- 4. Create party-to-deal association
  |    +-- INSERT INTO deal_parties
  |    +-- Set role, is_primary, added_at
  |
  +--- 5. Determine missing critical info
  |    +-- FOR role type, check required fields
  |    +-- Build list of missing items
  |
  +--- 6. Set default communication preferences
  |    +-- Based on role defaults
  |    +-- Lenders/title: email + sms
  |    +-- Clients: per agent preference
  |
  +--- 7. Log action
  |    +-- action_type: 'party_added'
  |    +-- Include role and basic info
  |
  +--- 8. Trigger related actions
  |    +-- IF role = 'lender': Prompt for loan info
  |    +-- IF role = 'title_company': Check title order status
  |    +-- IF role = 'inspector': Prompt for inspection date
  |
  +-- RETURN party object with next steps
```

## Output

```typescript
{
  success: true,
  actionTaken: "Added Jane Smith as buyer to 123 Main St",
  result: {
    party: {
      id: "uuid",
      role: "buyer",
      firstName: "Jane",
      lastName: "Smith",
      email: "jane@email.com",
      phone: "+13055551234",
      isPrimary: true,
      isNew: true, // or false if existing contact
      createdAt: "2026-01-15T10:30:00Z"
    },
    missingInfo: [
      { field: "email", prompt: "What's Jane's email address?" },
      { field: "phone", prompt: "What's Jane's phone number?" }
    ],
    relatedActions: [
      "Add seller contact information",
      "Set up buyer's lender"
    ],
    dealPartySummary: {
      total: 4,
      roles: ["listing_agent", "buyer", "seller", "lender"],
      missing: ["title_company", "inspector"]
    }
  }
}
```

## Voice Response

**Complete information provided:**
> "Added Jane Smith as the buyer for 123 Main Street. I have her email and phone number saved. Would you like to add the seller or any other parties?"

**Partial information:**
> "Added Jane Smith as the buyer. I'll need her email and phone number to send updates and documents. What's her email?"

**Recognized from previous deal:**
> "I recognize Jane Smith from the Oak Lane deal you closed last month. I've added her as the buyer with her existing contact info. Her email is still jane@email.com — is that correct?"

**Multiple parties for same role:**
> "Added David and Maria Rodriguez as buyers. Both are now on the deal. Would you like separate email communications for each, or should I CC both on everything?"

## Error Handling

| Error | Cause | Response |
|-------|-------|----------|
| `DUPLICATE_PARTY` | Same email already has role | "[Name] is already the [role] on this deal. Did you mean to update their info?" |
| `INVALID_ROLE` | Unknown role type | "I don't recognize that role. Common roles are buyer, seller, lender, title company, or inspector." |
| `DEAL_NOT_FOUND` | Invalid dealId | "I couldn't find that deal. Which property are you adding a party to?" |
| `INVALID_EMAIL` | Bad email format | "That email doesn't look right. Can you double-check the spelling?" |
| `INVALID_PHONE` | Unparseable phone | "I couldn't parse that phone number. What's the area code and number?" |

## Integration Points

### Triggers After Adding
- If first buyer/seller added: Prompt for missing counterparty
- If lender added: Check for loan application status
- If inspector added: Prompt for inspection scheduling
- If title company added: Prompt for title order

### Database Tables
- `parties` - Master party records (shared across deals)
- `deal_parties` - Party-to-deal associations with role
- `action_log` - Audit entry
- `communication_preferences` - Contact preferences

### Cross-System
- Check CRM for existing contact match
- Sync with agent's phone contacts (optional)
- MLS lookup for agent license verification

## Example Usage

### Simple Add from Voice
```
Agent: "Add John Smith as the buyer"

Homer: "Got it. Adding John Smith as the buyer for 123 Main Street.
        What's his email address?"

Agent: "john.smith@gmail.com"

Homer: "Saved. And his phone number?"

Agent: "305-555-1234"

Homer: "Perfect. John Smith is now added as the buyer with email
        john.smith@gmail.com and phone 305-555-1234.

        I'll include him on all buyer communications.
        Would you like to add the seller?"
```

### Add from Contract
```
Homer: [After parsing contract]
       "I found these parties in the contract:
        - Buyer: John Smith
        - Seller: Maria Rodriguez
        - Buyer's Agent: You (already added)
        - Listing Agent: Sarah Johnson at ABC Realty

        Should I add them all to the deal?"

Agent: "Yes, add them all"

Homer: "Done. I added John as buyer, Maria as seller, and Sarah
        as listing agent. I'll need contact info for each.
        Let's start with John - what's his email?"
```

### Add Company as Party
```
Agent: "Title company is First American Title"

Homer: "Adding First American Title to the deal. Who's your
        contact there?"

Agent: "Jennifer at their Miami office"

Homer: "Jennifer at First American Title, Miami.
        Do you have her email or phone number?"

Agent: "Email is jennifer@firstam.com, phone 305-555-4000"

Homer: "Got it. First American Title added with Jennifer as your
        contact. I'll send title-related communications to her.
        Has the title order been placed yet?"
```

## Quality Checklist

- [x] Handles voice input naturally
- [x] Parses names into first/last
- [x] Normalizes phone numbers
- [x] Validates email format
- [x] Detects duplicate parties
- [x] Recognizes existing contacts
- [x] Prompts for missing required info
- [x] Supports company-type parties
- [x] Logs all additions
- [x] Triggers appropriate follow-ups
- [x] Returns actionable next steps
- [x] Handles multiple parties per role

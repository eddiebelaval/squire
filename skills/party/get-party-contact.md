# Skill: Get Party Contact

**Category:** Party
**Priority:** P1
**Approval Required:** No

## Purpose

Retrieve contact information for a party on a deal. Used when the agent needs to reach someone, verify contact details, or share information. Returns phone, email, and other contact methods based on party's communication preferences.

## Triggers

### Voice Commands
- "What's the buyer's phone number?"
- "Get me the lender's email"
- "How do I reach [name]?"
- "Contact info for the title company"
- "[Name]'s number"
- "Give me the seller's email"
- "What's [role]'s contact?"

### Programmatic
- Communication skill needs recipient
- Document routing needs contact
- Calendar invite needs attendee
- API call to `GET /parties/:id/contact`

## Required Inputs

| Input | Type | Required | Source | Description |
|-------|------|----------|--------|-------------|
| `dealId` | UUID | Yes | context | Deal to look up party in |
| `partyIdentifier` | string | Yes* | voice | Role or name to look up |
| `partyId` | UUID | Yes* | context | Direct party ID |

*One of: `partyIdentifier` OR `partyId`

## Optional Inputs

| Input | Type | Default | Source | Description |
|-------|------|---------|--------|-------------|
| `contactType` | string | 'all' | voice | 'phone', 'email', 'address', 'all' |
| `includeSecondary` | boolean | false | manual | Include secondary contacts |
| `includeCompany` | boolean | true | default | Include company contact if applicable |

## Execution Flow

```
START
  |
  +--- 1. Identify party
  |    |
  |    +-- IF partyId: Direct lookup
  |    |
  |    +-- IF partyIdentifier is role:
  |    |   +-- Find party with that role
  |    |   +-- IF multiple: Return primary contact
  |    |
  |    +-- IF partyIdentifier is name:
  |        +-- Fuzzy match on deal parties
  |        +-- Handle nicknames (Bob = Robert)
  |
  +--- 2. Verify party found
  |    +-- Validate party exists on deal
  |    +-- Validate agent has access
  |
  +--- 3. Retrieve contact info
  |    |
  |    +-- Primary phone
  |    +-- Primary email
  |    +-- Mailing address (if requested)
  |    +-- Company info (if applicable)
  |    |
  |    +-- IF includeSecondary:
  |        +-- Secondary phone
  |        +-- Secondary email
  |
  +--- 4. Get communication preferences
  |    +-- Preferred contact method
  |    +-- Preferred contact times
  |    +-- Do not contact restrictions
  |
  +--- 5. Format response for context
  |    |
  |    +-- IF voice query: Format for speaking
  |    +-- IF programmatic: Return structured data
  |
  +--- 6. Log access (privacy compliance)
  |    +-- action_type: 'contact_accessed'
  |    +-- No PII in logs
  |
  +-- RETURN contact information
```

## Output

```typescript
{
  success: true,
  actionTaken: "Retrieved contact info for John Smith (buyer)",
  result: {
    party: {
      id: "uuid",
      role: "buyer",
      firstName: "John",
      lastName: "Smith",
      displayName: "John Smith"
    },
    contact: {
      phone: {
        primary: "+13055551234",
        formatted: "(305) 555-1234",
        type: "mobile"
      },
      email: {
        primary: "john.smith@email.com"
      },
      address: {
        street: "456 Current Ave",
        city: "Miami",
        state: "FL",
        zip: "33101"
      }
    },
    company: null, // or company info if applicable
    preferences: {
      preferredMethod: "phone",
      preferredTimes: "weekdays 9am-6pm",
      restrictions: null
    },
    secondary: null // or secondary contacts if requested
  }
}
```

## Voice Response

**Phone request:**
> "The buyer, John Smith's phone number is 305-555-1234. That's his mobile. Would you like me to call him or send a text?"

**Email request:**
> "Jane Doe's email is jane.doe@email.com. Want me to draft an email to her?"

**Full contact:**
> "Here's the title company contact: Jennifer Martinez at First American Title. Her direct line is 305-555-4000 and email is jennifer@firstam.com. She prefers email for documents and calls for urgent matters."

**Multiple parties same role:**
> "There are two buyers on this deal. John Smith's phone is 305-555-1234, and Maria Smith's is 305-555-5678. Which one did you need?"

**Missing information:**
> "I don't have a phone number for the seller yet. I have their email: seller@email.com. Would you like me to request their phone number?"

## Error Handling

| Error | Cause | Response |
|-------|-------|----------|
| `PARTY_NOT_FOUND` | No match | "I don't see a [role/name] on this deal. Would you like to add one?" |
| `NO_CONTACT_INFO` | Party has no contact | "[Name] is on the deal but I don't have their contact info. Would you like to add it?" |
| `CONTACT_TYPE_MISSING` | Requested type not available | "I don't have [name]'s phone number, but I have their email: [email]. Want me to use that?" |
| `AMBIGUOUS_REQUEST` | Multiple matches | "There are multiple [role]s. Did you mean [name1] or [name2]?" |

## Quick Access Patterns

### Common Requests

| Voice Pattern | Interpreted As |
|---------------|----------------|
| "Buyer's number" | Buyer primary phone |
| "Lender email" | Lender contact email |
| "Title company" | Title company primary contact |
| "Call the seller" | Seller phone + initiate call |
| "[Name]'s info" | All contact info for party |

### Role Shortcuts

| Shortcut | Resolves To |
|----------|-------------|
| "buyer" | buyer |
| "seller" | seller |
| "lender" / "loan officer" | lender |
| "title" / "escrow" | title_company |
| "other agent" / "co-op" | listing_agent or buyer_agent (opposite) |
| "inspector" | inspector |

## Examples

### Simple Phone Lookup
```
Agent: "What's the lender's phone number?"

Homer: "The lender is Michael Chen at ABC Mortgage.
        His direct line is 305-555-7890.
        Want me to call him?"
```

### Company Contact
```
Agent: "How do I reach the title company?"

Homer: "Your contact at First American Title is Jennifer Martinez.
        Phone: 305-555-4000
        Email: jennifer@firstam.com

        She's in the Brickell office. Prefer to call or email?"
```

### Missing Info
```
Agent: "What's the inspector's email?"

Homer: "I don't have an email for ABC Home Inspections yet.
        I have their phone: 305-555-3333.

        Want me to ask them for an email address?"
```

## Integration Points

### Call/Text Integration
- Phone lookup can trigger call
- Can initiate SMS send
- Click-to-call on mobile

### Email Integration
- Email lookup can start compose
- Pre-fill recipient in drafts

### Privacy Compliance
- Access logging for audit
- PII not stored in logs
- Consent tracking for marketing

## Quality Checklist

- [x] Handles voice requests naturally
- [x] Resolves role and name lookups
- [x] Returns formatted phone numbers
- [x] Indicates contact type (mobile/office)
- [x] Includes company info when relevant
- [x] Handles multiple parties per role
- [x] Reports missing contact info
- [x] Offers alternatives when info missing
- [x] Respects communication preferences
- [x] Logs access for compliance
- [x] Supports common shortcuts

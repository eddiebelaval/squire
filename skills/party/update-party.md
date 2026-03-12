# Skill: Update Party

**Category:** Party
**Priority:** P1
**Approval Required:** No

## Purpose

Update contact information, preferences, or details for an existing party in a transaction. This skill handles corrections, additions to incomplete records, and changes to communication preferences.

## Triggers

### Voice Commands
- "Update [party name]'s email"
- "Change the buyer's phone number to [number]"
- "[Party name]'s new email is [email]"
- "The lender contact changed to [name]"
- "Update the title company info"
- "Correct the seller's name spelling"

### Programmatic
- API call to `PATCH /parties/:id`
- Party profile edit in dashboard
- Email bounce triggers email update
- Business card re-scan

## Required Inputs

| Input | Type | Required | Source | Description |
|-------|------|----------|--------|-------------|
| `partyId` | UUID | Yes* | context | Party record ID |
| `dealId` | UUID | Yes* | context | Deal context for lookup |
| `partyRole` | PartyRole | Yes* | voice | Role to identify party |
| `partyName` | string | Yes* | voice | Name to identify party |

*One of: `partyId` OR (`dealId` + `partyRole`) OR (`dealId` + `partyName`)

## Optional Inputs

| Input | Type | Default | Source | Description |
|-------|------|---------|--------|-------------|
| `firstName` | string | null | voice/manual | Updated first name |
| `lastName` | string | null | voice/manual | Updated last name |
| `companyName` | string | null | voice/manual | Updated company name |
| `email` | string | null | voice/manual | Updated email |
| `phone` | string | null | voice/manual | Updated phone |
| `secondaryEmail` | string | null | manual | Additional email |
| `secondaryPhone` | string | null | manual | Additional phone |
| `licenseNumber` | string | null | manual | Updated license |
| `address` | Address | null | manual | Updated address |
| `notes` | string | null | manual | Updated notes |
| `isPrimary` | boolean | null | manual | Primary contact flag |
| `role` | PartyRole | null | manual | Change party's role |

## Execution Flow

```
START
  |
  +--- 1. Identify party
  |    |
  |    +-- IF partyId provided:
  |    |   +-- Direct lookup
  |    |
  |    +-- IF partyRole provided:
  |    |   +-- Find party with role in deal
  |    |   +-- IF multiple: Ask for clarification
  |    |
  |    +-- IF partyName provided:
  |    |   +-- Fuzzy match on name in deal
  |    |   +-- IF multiple matches: Ask for clarification
  |    |
  |    +-- Validate agent has access to party
  |
  +--- 2. Parse update fields
  |    +-- Extract changed fields from input
  |    +-- Normalize values (phone, email, etc.)
  |    +-- Validate each field format
  |
  +--- 3. Check for conflicts
  |    +-- Email change: Check not already used in deal
  |    +-- Role change: Check not creating duplicate
  |    +-- Name change: Confirm it's a correction
  |
  +--- 4. Store previous values
  |    +-- Snapshot current state for audit
  |    +-- Enable undo capability
  |
  +--- 5. Apply updates
  |    +-- UPDATE party record
  |    +-- UPDATE deal_parties if role changed
  |    +-- UPDATE communication_preferences if prefs changed
  |
  +--- 6. Propagate updates
  |    +-- IF email changed:
  |    |   +-- Update pending email deliveries
  |    |   +-- Notify agent of the change
  |    |
  |    +-- IF phone changed:
  |    |   +-- Update pending SMS
  |    |
  |    +-- IF shared party (multiple deals):
  |        +-- Update across all linked deals
  |        +-- Notify affected agents
  |
  +--- 7. Log action
  |    +-- action_type: 'party_updated'
  |    +-- Include before/after for changed fields
  |
  +-- RETURN updated party with changes summary
```

## Output

```typescript
{
  success: true,
  actionTaken: "Updated Jane Smith's email from old@email.com to jane@newemail.com",
  result: {
    party: {
      id: "uuid",
      role: "buyer",
      firstName: "Jane",
      lastName: "Smith",
      email: "jane@newemail.com",
      phone: "+13055551234",
      updatedAt: "2026-01-15T14:30:00Z"
    },
    changes: [
      {
        field: "email",
        from: "old@email.com",
        to: "jane@newemail.com"
      }
    ],
    affectedDeals: 1, // Number of deals this party is on
    propagated: true  // Whether changes applied to shared records
  }
}
```

## Voice Response

**Single field update:**
> "Updated Jane's email to jane@newemail.com. I'll use this for all future communications. Her phone number is still 305-555-1234 - should I update that too?"

**Multiple field update:**
> "Updated the buyer's contact info. New email is jane@newemail.com and new phone is 786-555-9999. All future messages will go to these contacts."

**Shared party update:**
> "Jane Smith is on 2 of your deals. I've updated her email on both the Main Street and Oak Lane transactions. She'll receive communications at jane@newemail.com for both."

**Clarification needed:**
> "There are two buyers on this deal - John Smith and Maria Smith. Which one are you updating?"

## Error Handling

| Error | Cause | Response |
|-------|-------|----------|
| `PARTY_NOT_FOUND` | No match for criteria | "I couldn't find that party on this deal. Who are you trying to update?" |
| `AMBIGUOUS_PARTY` | Multiple matches | "There are multiple parties matching that. Can you be more specific - is it [name1] or [name2]?" |
| `INVALID_EMAIL` | Bad email format | "That email doesn't look right. Can you spell it out for me?" |
| `DUPLICATE_EMAIL` | Email already in use | "That email is already used by another party on this deal. Did you mean to merge them?" |
| `NO_CHANGES` | No valid updates provided | "I didn't catch what to update. What would you like to change about [name]?" |

## Special Cases

### Name Correction vs. Party Change
```
Agent: "The buyer's name is Jane, not Janet"

Homer: "Got it - I've corrected the buyer's name from Janet Smith
        to Jane Smith. This was a spelling correction, right?"

Agent: "Yes"

Homer: "Updated. All documents and communications will now
        show Jane Smith."
```

### Contact Person Change at Company
```
Agent: "The title company contact is now Michael instead of Jennifer"

Homer: "I'll update the contact at First American Title to Michael.
        Do you have Michael's email and phone, or should I
        keep Jennifer's contact info for now?"

Agent: "Michael's email is michael@firstam.com"

Homer: "Updated. Michael is now the contact at First American Title.
        I'll send title communications to michael@firstam.com.
        Would you like me to keep Jennifer's info as a secondary contact?"
```

### Role Change
```
Agent: "John Smith is actually the co-buyer, not the main buyer"

Homer: "I'll update John Smith from primary buyer to co-buyer.
        Sarah remains the primary buyer. Communications will
        go to Sarah first with John CC'd. Is that right?"
```

## Integration Points

### Cascading Updates
- Email campaigns: Update recipient address
- Scheduled reminders: Update contact info
- Document routing: Update party references
- Calendar invites: Update attendee info

### Audit Trail
- Full change history maintained
- Previous values recoverable
- Who made the change tracked

### Cross-Deal Sync
- Shared party records update everywhere
- Optional: Ask before propagating
- Notification to other agents on shared deals

## Quality Checklist

- [x] Handles voice input naturally
- [x] Resolves party by role or name
- [x] Validates all input formats
- [x] Preserves previous values
- [x] Propagates to shared records
- [x] Handles name corrections vs. replacements
- [x] Updates pending communications
- [x] Creates audit trail
- [x] Handles company contact changes
- [x] Supports role changes
- [x] Confirms ambiguous requests

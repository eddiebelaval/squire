# Skill: Remove Party

**Category:** Party
**Priority:** P1
**Approval Required:** Conditional

## Purpose

Remove a party from a real estate transaction. This may be needed when a party drops out, was added in error, or is replaced by someone else. The skill handles archival, reassignment of responsibilities, and notification management.

## Triggers

### Voice Commands
- "Remove [name] from this deal"
- "[Name] is no longer involved"
- "Take off the [role]"
- "The buyer dropped out"
- "Remove the inspector"
- "Wrong person added, remove them"

### Programmatic
- API call to `DELETE /deals/:id/parties/:partyId`
- Dashboard remove action
- Party replacement flow

## Required Inputs

| Input | Type | Required | Source | Description |
|-------|------|----------|--------|-------------|
| `dealId` | UUID | Yes | context | Deal to remove party from |
| `partyId` | UUID | Yes* | context | Party record ID |
| `partyRole` | PartyRole | Yes* | voice | Role to identify party |
| `partyName` | string | Yes* | voice | Name to identify party |

*One of: `partyId` OR `partyRole` OR `partyName`

## Optional Inputs

| Input | Type | Default | Source | Description |
|-------|------|---------|--------|-------------|
| `reason` | string | null | voice/manual | Reason for removal |
| `replacementPartyId` | UUID | null | manual | Party replacing this one |
| `archiveCommunications` | boolean | true | default | Keep comm history |
| `notifyParty` | boolean | false | manual | Send removal notification |
| `reassignTasks` | boolean | true | default | Move tasks to replacement |

## Approval Rules

| Scenario | Approval Required | Reason |
|----------|-------------------|--------|
| Remove vendor (inspector, lender) | No | Low risk, operational |
| Remove wrong person added | No | Error correction |
| Remove buyer/seller | Yes | High risk, deal impact |
| Remove with pending documents | Yes | May affect workflow |
| Remove only party of role | Confirm | Ensure intentional |

## Execution Flow

```
START
  |
  +--- 1. Identify party to remove
  |    |
  |    +-- IF partyId: Direct lookup
  |    +-- IF partyRole: Find party with role in deal
  |    +-- IF partyName: Fuzzy match in deal parties
  |    |
  |    +-- Validate party exists on deal
  |
  +--- 2. Check removal impact
  |    |
  |    +-- Pending documents assigned to party
  |    +-- Scheduled communications to party
  |    +-- Open tasks assigned to party
  |    +-- Deadlines where party is responsible
  |    |
  |    +-- Build impact summary
  |
  +--- 3. Determine approval requirement
  |    |
  |    +-- IF high-impact removal:
  |    |   +-- Present impact summary
  |    |   +-- Request confirmation
  |    |   +-- PAUSE until approved
  |    |
  |    +-- IF last party of critical role:
  |        +-- Warn: "This is the only [role] on the deal"
  |        +-- Request confirmation
  |
  +--- 4. Handle reassignments (if replacement provided)
  |    |
  |    +-- Transfer pending documents
  |    +-- Reassign open tasks
  |    +-- Update deadline responsibilities
  |    +-- Migrate communication threads
  |
  +--- 5. Archive party association
  |    |
  |    +-- Soft delete from deal_parties
  |    +-- Set removed_at, removed_by, removal_reason
  |    +-- Keep party record intact (may be on other deals)
  |    +-- Preserve communication history
  |
  +--- 6. Update notifications
  |    |
  |    +-- Cancel pending notifications to party
  |    +-- Cancel pending emails to party
  |    +-- Remove from group communications
  |    |
  |    +-- IF notifyParty = true:
  |        +-- Queue removal notification email
  |
  +--- 7. Log action
  |    +-- action_type: 'party_removed'
  |    +-- Include reason and any reassignments
  |
  +-- RETURN removal summary
```

## Output

```typescript
{
  success: true,
  actionTaken: "Removed John Smith (buyer) from 123 Main St deal",
  result: {
    removedParty: {
      id: "uuid",
      role: "buyer",
      firstName: "John",
      lastName: "Smith",
      removedAt: "2026-01-15T16:00:00Z"
    },
    impact: {
      documentsReassigned: 2,
      tasksReassigned: 1,
      notificationsCancelled: 3,
      communicationsPreserved: true
    },
    replacement: null, // or replacement party info
    remainingParties: {
      total: 5,
      roles: ["listing_agent", "seller", "lender", "title_company"]
    },
    warning: "No buyer is now assigned to this deal."
  }
}
```

## Voice Response

**Simple removal:**
> "Removed John Smith from the deal. I've cancelled any pending notifications to him. Would you like to add a replacement buyer?"

**Removal with impact:**
> "Removing Jane Doe will affect 2 pending documents and 3 scheduled reminders assigned to her. Should I proceed and reassign these to you, or would you like to add a replacement first?"

**Last party of role:**
> "This would remove the only lender on the deal. The financing deadline is in 10 days. Are you sure you want to remove them? I can add a new lender first if needed."

**Wrong person correction:**
> "Got it - removed James Johnson. He was added in error. The deal now has the correct parties. Is there anything else to fix?"

**With replacement:**
> "Replaced ABC Inspections with XYZ Home Inspectors. I've transferred the pending inspection report task to them. Their contact number is on file - would you like me to send them the inspection details?"

## Error Handling

| Error | Cause | Response |
|-------|-------|----------|
| `PARTY_NOT_FOUND` | No match for criteria | "I couldn't find that party on this deal. Who are you trying to remove?" |
| `AMBIGUOUS_PARTY` | Multiple matches | "There are multiple people matching that. Do you mean [name1] the [role1] or [name2] the [role2]?" |
| `CANNOT_REMOVE_SELF` | Agent removing themselves | "You can't remove yourself from your own deal. Did you mean to transfer this deal?" |
| `REMOVAL_BLOCKED` | Active signing in progress | "[Name] has documents currently being signed. Complete or cancel the signing session first." |

## Special Cases

### Buyer/Seller Drops Out
```
Agent: "The buyer dropped out"

Homer: "I'm sorry to hear that. I'll remove John Smith as the buyer
        from 123 Main Street.

        Before I do:
        - 3 pending notifications will be cancelled
        - The escrow deposit tracking will be marked as N/A
        - The financing contingency deadline will be removed

        Should I proceed? You can also mark the deal as cancelled
        if the transaction is ending."
```

### Replace Party
```
Agent: "Remove ABC Title and add First American instead"

Homer: "I'll replace ABC Title Company with First American Title.
        - Outstanding title commitment request transfers to First American
        - Jennifer was your ABC contact - who's your contact at First American?

        Adding First American... who should I contact there?"
```

### Error Correction
```
Agent: "I added the wrong John - remove John Johnson"

Homer: "Removed John Johnson from the deal. John Smith is still
        listed as the buyer - that's the correct one, right?"

Agent: "Yes"

Homer: "Great, the deal now shows the correct parties."
```

## Integration Points

### Cascading Actions
- Cancel scheduled emails/SMS
- Remove from notification groups
- Reassign document routing
- Update calendar invites
- Archive communication threads

### Audit Trail
- Soft delete preserves history
- Reason recorded
- Can be undone within 7 days
- Full audit in action_log

### Deal Status Check
- Removing all buyers → prompt for deal status
- Removing lender → check financing type
- Removing title → check closing timeline

## Quality Checklist

- [x] Handles voice input naturally
- [x] Resolves party by role, name, or ID
- [x] Calculates removal impact
- [x] Requires confirmation for high-impact removals
- [x] Warns when removing only party of role
- [x] Handles reassignment to replacement
- [x] Preserves communication history
- [x] Cancels pending notifications
- [x] Creates audit trail
- [x] Suggests next steps
- [x] Cannot remove self from own deal
- [x] Handles signing-in-progress blocks

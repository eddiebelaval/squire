# Skill: Identify Party Role

**Category:** Party
**Priority:** P1
**Approval Required:** No

## Purpose

Determine the role of a party mentioned in voice commands, documents, or communications when not explicitly stated. Uses context clues, relationship patterns, and transaction history to correctly classify parties.

## Triggers

### Automatic
- Contract parsing with unnamed roles
- Email forwarded with new contacts
- Voice command mentions person without role
- Business card scan

### Voice Commands
- "Who is [name] on this deal?"
- "What's [name]'s role?"
- "Is [name] the buyer or seller?"
- "[Name] just emailed - add them to the deal"

### Programmatic
- Party auto-detection from communications
- Document signature field matching
- CRM contact lookup

## Required Inputs

| Input | Type | Required | Source | Description |
|-------|------|----------|--------|-------------|
| `dealId` | UUID | Yes | context | Deal for role determination |
| `partyIdentifier` | string | Yes | voice/doc | Name, email, or phone |

## Optional Inputs

| Input | Type | Default | Source | Description |
|-------|------|---------|--------|-------------|
| `contextClues` | string[] | [] | parsing | Keywords from source |
| `sourceType` | string | null | auto | Where info came from |
| `emailDomain` | string | null | email | Company email domain |
| `signatureBlock` | string | null | email | Email signature text |
| `documentField` | string | null | doc | Field label in document |

## Role Identification Logic

### Context Clue Keywords

| Role | Keywords / Patterns |
|------|---------------------|
| Buyer | "purchasing", "buying", "borrower", "grantee", "offer" |
| Seller | "selling", "owner", "grantor", "listed by", "listing" |
| Buyer's Agent | "representing buyer", "buyer's rep", "buyer agent" |
| Listing Agent | "listing agent", "seller's agent", "listed by" |
| Lender | "loan officer", "mortgage", "NMLS", "financing", bank names |
| Title Company | "title", "escrow", "closing", "settlement" |
| Inspector | "inspection", "home inspector", "ASHI", "InterNACHI" |
| Appraiser | "appraisal", "appraiser", "AMC", "value" |
| Insurance | "insurance", "hazard", "policy", "coverage" |
| HOA | "association", "HOA", "community", "management" |
| Attorney | "attorney", "Esq.", "law firm", "legal", "counsel" |

### Email Domain Patterns

| Domain Pattern | Likely Role |
|----------------|-------------|
| @bankofamerica.com, @chase.com | Lender |
| @firstam.com, @stewart.com | Title Company |
| @[agentname]realty.com | Agent |
| @hoa-[name].com | HOA |
| @lawfirm.com, @[name]law.com | Attorney |

### Document Field Mapping

| Field Label | Role |
|-------------|------|
| "Buyer:", "Purchaser:" | Buyer |
| "Seller:", "Owner:" | Seller |
| "Listing Agent:", "Seller's Agent:" | Listing Agent |
| "Selling Agent:", "Buyer's Agent:" | Buyer's Agent |
| "Lender:", "Mortgagee:" | Lender |
| "Title Company:", "Escrow:" | Title Company |

## Execution Flow

```
START
  |
  +--- 1. Gather all available signals
  |    |
  |    +-- Name/email/phone provided
  |    +-- Context clue keywords
  |    +-- Email domain (if email provided)
  |    +-- Signature block content
  |    +-- Document field labels
  |    +-- Source type (email, doc, voice)
  |
  +--- 2. Check existing deal parties
  |    |
  |    +-- Is this person already on the deal?
  |    +-- Do they match an existing party email/phone?
  |    +-- Return known role if found
  |
  +--- 3. Check agent's contact history
  |    |
  |    +-- Previous deals with this contact
  |    +-- Known role from past transactions
  |    +-- CRM data if available
  |
  +--- 4. Apply keyword matching
  |    |
  |    +-- Score each role based on keyword matches
  |    +-- Weight by signal reliability:
  |    |   +-- Document field: 0.9
  |    |   +-- Signature block: 0.7
  |    |   +-- Email domain: 0.6
  |    |   +-- Context keywords: 0.5
  |
  +--- 5. Apply heuristics
  |    |
  |    +-- IF "NMLS#" in signature → Lender (high confidence)
  |    +-- IF "License#" + real estate terms → Agent
  |    +-- IF "@[titlecompany]" domain → Title Company
  |    +-- IF "Esq." or "JD" → Attorney
  |
  +--- 6. Determine confidence
  |    |
  |    +-- HIGH (>0.8): Single strong signal or multiple aligned signals
  |    +-- MEDIUM (0.5-0.8): Some signals but ambiguous
  |    +-- LOW (<0.5): Insufficient information
  |
  +--- 7. Handle by confidence level
  |    |
  |    +-- HIGH: Return role with auto-apply option
  |    +-- MEDIUM: Present top 2 options, ask for confirmation
  |    +-- LOW: Ask agent to specify role
  |
  +-- RETURN identified role with confidence
```

## Output

```typescript
{
  success: true,
  actionTaken: "Identified Sarah Johnson as listing agent",
  result: {
    identification: {
      suggestedRole: "listing_agent",
      confidence: 0.92,
      confidenceLevel: "high",
      reasoning: [
        "Email signature contains 'Listing Agent'",
        "Email domain matches known brokerage",
        "Context mentions 'listed by'"
      ]
    },
    alternatives: [
      { role: "buyer_agent", confidence: 0.15 }
    ],
    partyInfo: {
      name: "Sarah Johnson",
      email: "sarah@abcrealty.com",
      phone: "+13055559999",
      company: "ABC Realty"
    },
    action: "confirm", // or "auto_add", "ask_agent"
    prompt: null // or question to ask
  }
}
```

## Voice Response

**High confidence:**
> "Sarah Johnson appears to be the listing agent - her signature says 'Listing Agent at ABC Realty.' Should I add her to the deal as listing agent?"

**Medium confidence:**
> "I found Jennifer at First American Title. Based on the email, she's either the title officer or escrow agent. Which role should I add her as?"

**Low confidence:**
> "I don't have enough information to determine [name]'s role. Are they the buyer, seller, lender, or another party type?"

**Already on deal:**
> "[Name] is already on this deal as the [role]. Their contact info is [email]. Did you need to update something?"

**Recognized from history:**
> "I recognize Michael Chen from your Oak Lane closing last year - he was the loan officer. Should I add him as the lender for this deal too?"

## Error Handling

| Error | Cause | Response |
|-------|-------|----------|
| `INSUFFICIENT_INFO` | No useful signals | "I need more information to identify [name]'s role. What's their involvement in the transaction?" |
| `AMBIGUOUS_SIGNALS` | Conflicting signals | "[Name]'s info mentions both lending and title work. Are they the lender or title company?" |
| `PARTY_NOT_FOUND` | Can't match identifier | "I couldn't find anyone matching [identifier]. Can you provide more details?" |

## Examples

### From Email Forward
```
Agent forwards email from: jennifer.martinez@firstam.com
Subject: RE: Closing on 123 Main St
Signature: "Jennifer Martinez, Escrow Officer, First American Title"

Homer: "I see Jennifer Martinez from First American Title emailed
        about the closing. She's likely the escrow officer.
        Should I add her as the title company contact?"
```

### From Contract Parsing
```
Homer: [Parsing contract PDF]
       "I found these names in the contract:
        - 'John Smith' in the 'Purchaser' field → likely buyer
        - 'Maria Rodriguez' in the 'Seller' field → likely seller
        - 'ABC Mortgage' in the 'Lender' field → lender company

        Should I add them with these roles?"
```

### From Voice Without Role
```
Agent: "Add Mike to this deal"

Homer: "I found Mike Johnson in your contacts. In your previous
        deals, Mike was usually the inspector. Is he the inspector
        for this deal too, or a different role?"
```

## Integration Points

### Signal Sources
- Email parsing (domain, signature, content)
- Document OCR (field labels, position)
- CRM lookup (previous roles)
- MLS data (agent verification)
- NMLS lookup (lender verification)

### Confidence Calibration
- Track accuracy over time
- Learn from corrections
- Agent-specific patterns

## Quality Checklist

- [x] Uses multiple signal sources
- [x] Weighs signals by reliability
- [x] Checks deal history first
- [x] Checks agent's contact history
- [x] Returns confidence level
- [x] Presents alternatives when unsure
- [x] Asks for clarification when needed
- [x] Handles domain pattern matching
- [x] Parses email signatures
- [x] Learns from corrections
- [x] Handles role ambiguity gracefully

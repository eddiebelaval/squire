# Skill: Florida Signature Requirements

**Category:** Compliance
**Priority:** P0
**Approval Required:** No

## Purpose

Determine who needs to sign what documents in a Florida real estate transaction. Covers buyer, seller, spouse, entity, and witness signature requirements based on property type, ownership, and document type.

## Legal Authority

- **Florida Statutes §689.01** - Conveyance of real property
- **Florida Statutes §689.11** - Married persons may convey
- **Florida Statutes §708.08** - Homestead signatures
- **Florida Constitution Article X, §4** - Homestead protection
- **Florida Statutes §695.01** - Instruments to be recorded
- **Florida Statutes §117.05** - Notarization requirements
- **Florida Statutes §668.50** - Electronic signatures (UETA)

## Triggers

### Voice Commands
- "Who needs to sign the contract?"
- "Does the spouse need to sign?"
- "What signatures are missing?"
- "Is this ready for closing?"
- "Who signs for the LLC?"
- "Do we need witnesses?"

### Programmatic
- Contract prepared for signature
- Document ready for execution
- Closing documents prepared
- Signature verification requested
- Compliance check running

## Required Inputs

| Input | Type | Required | Source | Description |
|-------|------|----------|--------|-------------|
| `dealId` | UUID | Yes | context | Deal being checked |
| `documentType` | string | Yes | document | Type of document |
| `parties` | Party[] | Yes | deal | All deal parties |

## Optional Inputs

| Input | Type | Default | Source | Description |
|-------|------|---------|--------|-------------|
| `isHomestead` | boolean | false | deal | Seller's homestead |
| `ownershipType` | string | null | title | How title is held |
| `entityType` | string | null | party | Corp, LLC, Trust, etc. |
| `maritalStatus` | string | null | party | Married, single, etc. |
| `hasPoA` | boolean | false | party | Power of Attorney used |

## Signature Requirements Matrix

### Contract (FAR/BAR Purchase Agreement)

| Party | Required | Condition | Notes |
|-------|----------|-----------|-------|
| **Buyer(s)** | Yes | All named buyers | All on contract must sign |
| **Buyer Spouse** | No* | *If also on title | Not required for contract |
| **Seller(s)** | Yes | All titleholders | All owners must sign |
| **Seller Spouse** | Yes* | *If homestead | Required even if not on title |
| **Listing Agent** | Yes | As broker rep | May be initialed |
| **Buyer Agent** | Yes | As broker rep | May be initialed |

### Deed (Warranty, Special Warranty, Quitclaim)

| Party | Required | Condition | Notes |
|-------|----------|-----------|-------|
| **Grantor(s)** | Yes | All titleholders | Must match title exactly |
| **Grantor Spouse** | Yes* | *If homestead | Even if not on title |
| **Two Witnesses** | Yes | Per witness | FL law requires 2 witnesses |
| **Notary** | Yes | Acknowledgment | Must notarize signatures |
| **Grantee(s)** | No | Acceptance implied | Usually doesn't sign |

### Mortgage/Security Instrument

| Party | Required | Condition | Notes |
|-------|----------|-----------|-------|
| **Borrower(s)** | Yes | All borrowers | Everyone on loan |
| **Borrower Spouse** | Yes* | *If homestead | Required for homestead lien |
| **Two Witnesses** | Yes | Per FL law | 2 witnesses required |
| **Notary** | Yes | Required | Notarization required |

## Homestead Signature Rules

### Florida Constitution Article X, §4

```
RULE: Homestead Cannot Be Alienated Without Spouse Consent
────────────────────────────────────────────────────────
If property is seller's homestead and seller is married,
the non-owner spouse MUST sign the deed.

This applies even if:
- Spouse is not on title
- Property was owned before marriage
- Spouse has never lived there (if still married)

EXCEPTION: If legally separated or divorced, spouse signature
not required (get evidence of divorce).
```

### Homestead Indicators

| Indicator | Suggests Homestead |
|-----------|-------------------|
| Seller residence matches property | Yes |
| Homestead exemption on tax roll | Yes |
| Seller claims as primary residence | Yes |
| Recently married, property acquired before | Verify |

## Entity Signature Requirements

### Corporation

| Signer | Requirements |
|--------|--------------|
| **Authorized Officer** | President, VP, Secretary, or Treasurer |
| **Per Bylaws** | Check corporate resolution |
| **Corporate Seal** | Recommended but not required |
| **Title Block** | "[Name], as [Title] of [Corp]" |

### Limited Liability Company (LLC)

| Signer | Requirements |
|--------|--------------|
| **Manager** | If manager-managed |
| **Member** | If member-managed |
| **Per Operating Agreement** | Check signing authority |
| **Title Block** | "[Name], as Manager of [LLC]" |

### Trust

| Signer | Requirements |
|--------|--------------|
| **Trustee(s)** | All acting trustees |
| **Per Trust Agreement** | Check trust powers |
| **Title Block** | "[Name], as Trustee of [Trust]" |
| **Trust Certification** | May be required by title |

### Estate

| Signer | Requirements |
|--------|--------------|
| **Personal Representative** | Court-appointed |
| **Letters of Administration** | Must be current |
| **Court Approval** | May be required for sale |
| **Title Block** | "[Name], as PR of Estate of [Decedent]" |

## Execution Flow

```
START
  │
  ├─── 1. Load deal and party data
  │    ├── Get all parties
  │    ├── Get document type
  │    └── Get property characteristics
  │
  ├─── 2. Identify signers by role
  │    ├── Buyers: All named on contract
  │    ├── Sellers: All on title
  │    ├── Spouses: Check homestead/marital status
  │    └── Agents: Both sides
  │
  ├─── 3. Check ownership type
  │    ├── Individual → Name and capacity
  │    ├── Joint Tenancy → Both parties
  │    ├── Tenancy in Common → All co-owners
  │    ├── Corporation → Authorized officer
  │    ├── LLC → Manager or member
  │    ├── Trust → Trustee(s)
  │    └── Estate → Personal representative
  │
  ├─── 4. Apply homestead rules
  │    ├── Is this seller's homestead?
  │    ├── Is seller married?
  │    ├── If yes → Spouse must sign deed
  │    └── Get proof of status if single
  │
  ├─── 5. Check document-specific requirements
  │    ├── Contract: Parties + agents
  │    ├── Deed: Grantors + witnesses + notary
  │    ├── Mortgage: Borrowers + witnesses + notary
  │    ├── Disclosure: Per disclosure type
  │    └── Addendum: All contract parties
  │
  ├─── 6. Compare to obtained signatures
  │    ├── Check signed documents on file
  │    ├── Mark as complete or missing
  │    └── Identify specific missing signatures
  │
  └─── RETURN signature_requirements
```

## Output

```typescript
{
  success: true,
  actionTaken: "Checked signature requirements for 123 Main St",
  result: {
    document: "FAR/BAR AS-IS Contract",
    documentType: "purchase_contract",
    homestead: {
      isHomestead: true,
      sellerMarried: true,
      spouseSignatureRequired: true,
      reason: "Seller's homestead per FL Constitution Art X, §4"
    },
    requiredSignatures: [
      {
        party: "John Smith",
        role: "Buyer",
        capacity: "Individual",
        required: true,
        obtained: true,
        dateObtained: "2026-01-15"
      },
      {
        party: "Jane Doe",
        role: "Seller",
        capacity: "Individual - Titleholder",
        required: true,
        obtained: true,
        dateObtained: "2026-01-15"
      },
      {
        party: "Robert Doe",
        role: "Seller Spouse",
        capacity: "Non-titled spouse (homestead)",
        required: true,
        obtained: false,
        dateObtained: null,
        reason: "Must sign due to homestead, per FL Const. Art X, §4"
      }
    ],
    witnessesRequired: false,
    notaryRequired: false,
    status: {
      complete: false,
      totalRequired: 3,
      totalObtained: 2,
      missing: ["Robert Doe (Seller Spouse)"]
    },
    nextAction: {
      action: "Obtain spouse signature",
      party: "Robert Doe",
      urgency: "high",
      reason: "Contract invalid without spouse signature on homestead property"
    }
  }
}
```

## Voice Response

**All Signatures Complete:**
> "All required signatures are in for the contract. Both buyers signed, the seller signed, and the seller's spouse signed since it's their homestead. We're good to proceed."

**Missing Spouse Signature:**
> "Hold up - the seller's spouse needs to sign. This is the seller's homestead, so under the Florida Constitution, the spouse must sign even though they're not on title. The contract won't be enforceable without it. Can you get Robert Doe's signature?"

**Entity Signing:**
> "This LLC sale needs the manager's signature. Based on the operating agreement, that's Michael Johnson as Managing Member. Make sure the signature block says 'Michael Johnson, as Managing Member of 123 Main LLC.' I'll need a copy of the operating agreement for the title company."

**Trust Transaction:**
> "The seller is a trust, so the trustee needs to sign. That's Sarah Williams, Trustee of the Williams Family Trust dated March 15, 2020. The title company will want a trust certification showing she has authority to sell. I don't have that on file yet."

## Error Handling

| Error | Cause | Response |
|-------|-------|----------|
| `PARTIES_UNKNOWN` | No parties in deal | "I need to know who the buyers and sellers are. Can you add them to the deal?" |
| `TITLE_UNKNOWN` | Don't know how title held | "How is title being held? I need to know to determine who signs." |
| `MARITAL_STATUS_UNKNOWN` | Can't determine if married | "Is the seller married? This affects whether the spouse needs to sign." |
| `ENTITY_DOCS_MISSING` | No operating agreement/bylaws | "I'll need the [LLC operating agreement/corporate resolution] to verify signing authority." |

## Document-Specific Requirements

### Contract and Addenda
- Buyer(s): All named buyers
- Seller(s): All titleholders
- Seller spouse: If homestead AND married
- Agents: Both sides
- Witnesses: Not required
- Notary: Not required

### Deed
- Grantor(s): All titleholders
- Grantor spouse: If homestead
- Two witnesses: Required per §689.01
- Notary: Required for recording
- Grantee: Not required

### Closing Disclosure / Settlement Statement
- Buyer(s): All borrowers
- Seller(s): All sellers
- Witnesses: Not required
- Notary: Often required by lender

### Disclosures (Lead Paint, Seller's, etc.)
- Party making disclosure
- Party receiving disclosure
- Witnesses: Usually not required
- Notary: Usually not required

## Quality Checklist

- [x] Identifies all required signers
- [x] Applies Florida homestead rules
- [x] Handles entity transactions
- [x] Handles trust transactions
- [x] Tracks signature status
- [x] Identifies missing signatures
- [x] Cites legal authority
- [x] Explains why spouse must sign
- [x] Voice-friendly responses
- [x] Provides next action

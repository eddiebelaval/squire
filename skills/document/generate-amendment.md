# Skill: Generate Amendment

**Category:** Document
**Priority:** P0
**Approval Required:** Yes (all amendments require explicit approval)

## Purpose

Generate a formal amendment to modify existing contract terms after the original contract has been executed. Amendments are more formal than addenda and typically modify core terms or correct errors in the original document.

## Triggers

### Voice Commands
- "Amend the contract for [address]"
- "Create amendment to change [term]"
- "We need to amend [specific term] on [deal]"
- "Correct the contract - [error description]"
- "Formal amendment to [address]"

### Programmatic
- `POST /deals/:dealId/documents/amendment`
- Agent dashboard "Create Amendment" action
- Escalation from addendum when formal amendment required

## Required Inputs

| Input | Type | Required | Source | Description |
|-------|------|----------|--------|-------------|
| `dealId` | UUID | Yes | context | Active deal identifier |
| `amendmentType` | string | Yes | voice/manual | Type of amendment |
| `termToAmend` | string | Yes | voice/manual | Which contract term is being amended |

## Optional Inputs

| Input | Type | Default | Source | Description |
|-------|------|---------|--------|-------------|
| `originalText` | string | null | manual | Original contract language |
| `newText` | string | null | manual | Replacement language |
| `section` | string | null | manual | Contract section/paragraph reference |
| `reason` | string | null | voice | Reason for amendment |
| `legalReviewRequired` | boolean | false | system | Flag for legal review |
| `notarization` | boolean | false | manual | Requires notarization |
| `witnesses` | number | 0 | manual | Number of witnesses required |
| `sendForSignature` | boolean | true | config | Auto-send to DocuSign |
| `allPartiesRequired` | boolean | true | config | All parties must sign |

## Amendment Types

| Type | Description | Typical Use Case |
|------|-------------|-----------------|
| `correction` | Fix typos, errors, or omissions | Name misspelling, wrong address |
| `term_modification` | Change contract terms | Price, dates, contingencies |
| `party_substitution` | Replace a party | Buyer assigns to LLC, seller estate |
| `clause_addition` | Add new clause | Special conditions, new requirements |
| `clause_removal` | Remove existing clause | Waive requirement, remove condition |
| `legal_description` | Correct property legal | Survey revealed different legal |
| `financing_change` | Change financing terms | Loan type, amount, conditions |
| `mutual_release` | Release obligations | Cancel specific requirements |

## Execution Flow

```
START
  │
  ├─── 1. Validate amendment request
  │    ├── Verify deal exists and is active
  │    ├── Check amendment type is valid
  │    ├── Verify user has authority to amend
  │    └── Check for pending amendments on same term
  │
  ├─── 2. Load contract context
  │    ├── Get original contract details
  │    ├── Get all parties (may need additional signers)
  │    ├── Get any existing amendments
  │    └── Determine amendment number (1st, 2nd, etc.)
  │
  ├─── 3. Determine formality requirements
  │    │
  │    ├── IF party_substitution OR legal_description:
  │    │   ├── Set legalReviewRequired = true
  │    │   └── May require notarization
  │    │
  │    ├── IF financing_change AND lender involved:
  │    │   └── Include lender acknowledgment
  │    │
  │    └── IF correction type:
  │        └── Simpler format, all parties still sign
  │
  ├─── 4. Build amendment document
  │    ├── Formal header with amendment number
  │    ├── Full recitals (WHEREAS clauses)
  │    ├── Specific section references
  │    ├── Original text (struck through)
  │    ├── New text (inserted)
  │    ├── Legal effect language
  │    └── Execution section
  │
  ├─── 5. Generate PDF
  │    ├── Apply formal amendment template
  │    ├── Include strikethrough formatting
  │    └── Add witness/notary blocks if required
  │
  ├─── 6. Create document record
  │    ├── type: 'amendment'
  │    ├── amendmentNumber: calculated
  │    ├── status: 'draft'
  │    ├── legalReviewRequired: boolean
  │    └── Link to deal and original contract
  │
  ├─── 7. IF legalReviewRequired:
  │    ├── Flag for review
  │    ├── Notify appropriate party
  │    └── Hold signature sending
  │
  ├─── 8. IF sendForSignature AND !legalReviewRequired:
  │    ├── Configure all required signers
  │    ├── Add witness tabs if needed
  │    ├── INVOKE: send-for-signature skill
  │    └── Update status to 'pending_signature'
  │
  ├─── 9. Track pending changes
  │    └── Store changes to apply when fully executed
  │
  ├─── 10. Log action
  │     └── action_type: 'amendment_generated'
  │
  └─── 11. Return result
```

## Template Content

```
AMENDMENT TO CONTRACT FOR SALE AND PURCHASE

AMENDMENT NUMBER: {{amendmentNumber}}

Date of Amendment: {{currentDate | formatDate}}

Property Address: {{deal.address.street}}
                  {{deal.address.city}}, {{deal.address.state}} {{deal.address.zip}}

Legal Description: {{deal.legalDescription}}

Original Contract Date: {{deal.effectiveDate | formatDate}}
{{#if previousAmendments.length > 0}}
Previous Amendments: {{#each previousAmendments}}
  - Amendment {{this.number}}, dated {{this.date | formatDate}}
{{/each}}
{{/if}}

================================================================================
PARTIES
================================================================================

BUYER(S):
{{#each buyers}}
  {{this.name}}
  {{this.address}}
{{/each}}

SELLER(S):
{{#each sellers}}
  {{this.name}}
  {{this.address}}
{{/each}}

================================================================================
RECITALS
================================================================================

WHEREAS, the parties entered into that certain Contract for Sale and Purchase
dated {{deal.effectiveDate | formatDate}} (the "Original Contract") for the
purchase and sale of the Property described above; and

{{#if previousAmendments.length > 0}}
WHEREAS, the parties have previously amended the Original Contract by the
amendments listed above; and
{{/if}}

WHEREAS, the parties now desire to {{amendmentPurpose}};

NOW, THEREFORE, for good and valuable consideration, the receipt and sufficiency
of which are hereby acknowledged, the parties agree as follows:

================================================================================
AMENDMENT
================================================================================

{{#if amendmentType === 'correction'}}
CORRECTION OF ERROR

The following correction is made to the {{#if section}}{{section}} of the {{/if}}
Contract:

Original Text: "{{originalText}}"
Corrected Text: "{{newText}}"

This correction is made to accurately reflect the intent of the parties.
{{/if}}

{{#if amendmentType === 'term_modification'}}
MODIFICATION OF TERMS

{{section}} of the Contract is hereby amended as follows:

DELETE the following:
┌─────────────────────────────────────────────────────────────────────────────┐
│ {{originalText}}                                                            │
└─────────────────────────────────────────────────────────────────────────────┘

INSERT in its place:
┌─────────────────────────────────────────────────────────────────────────────┐
│ {{newText}}                                                                 │
└─────────────────────────────────────────────────────────────────────────────┘
{{/if}}

{{#if amendmentType === 'party_substitution'}}
SUBSTITUTION OF PARTY

Effective upon the execution of this Amendment:

The {{partyRole}} known as "{{originalParty.name}}" shall be released from all
obligations under the Contract, and "{{newParty.name}}" shall be substituted as
the {{partyRole}} and shall assume all rights and obligations of the original
{{partyRole}} under the Contract.

New {{partyRole}} Information:
Name: {{newParty.name}}
Address: {{newParty.address}}
Email: {{newParty.email}}
Phone: {{newParty.phone}}
{{/if}}

{{#if amendmentType === 'clause_addition'}}
ADDITION OF TERMS

The following clause is hereby added to the Contract:

NEW CLAUSE: {{clauseTitle}}
"{{newText}}"
{{/if}}

{{#if amendmentType === 'clause_removal'}}
REMOVAL OF TERMS

The following clause is hereby removed from the Contract and shall be of no
further force or effect:

REMOVED: {{section}}
"{{originalText}}"
{{/if}}

{{#if reason}}
================================================================================
REASON FOR AMENDMENT
================================================================================

{{reason}}
{{/if}}

================================================================================
GENERAL PROVISIONS
================================================================================

1. EFFECT OF AMENDMENT. Except as expressly modified by this Amendment, all
   terms and conditions of the Original Contract{{#if previousAmendments.length > 0}},
   as previously amended,{{/if}} shall remain in full force and effect.

2. CONFLICT. In the event of any conflict between this Amendment and the
   Original Contract or any previous amendments, the terms of this Amendment
   shall control.

3. COUNTERPARTS. This Amendment may be executed in counterparts, each of which
   shall be deemed an original, and all of which together shall constitute one
   and the same instrument.

4. INTEGRATION. This Amendment, together with the Original Contract and all
   prior amendments, constitutes the entire agreement between the parties
   concerning the subject matter hereof.

5. BINDING EFFECT. This Amendment shall be binding upon and inure to the benefit
   of the parties and their respective heirs, successors, and assigns.

================================================================================
EXECUTION
================================================================================

IN WITNESS WHEREOF, the parties have executed this Amendment as of the date
first written above.

BUYER(S):

_________________________________    Date: ____________
{{buyers.[0].name}}

{{#if buyers.[1]}}
_________________________________    Date: ____________
{{buyers.[1].name}}
{{/if}}

SELLER(S):

_________________________________    Date: ____________
{{sellers.[0].name}}

{{#if sellers.[1]}}
_________________________________    Date: ____________
{{sellers.[1].name}}
{{/if}}

{{#if witnesses > 0}}
================================================================================
WITNESSES
================================================================================

{{#times witnesses}}
Witness {{@index + 1}}:
_________________________________    Date: ____________
Print Name: _________________________
{{/times}}
{{/if}}

{{#if notarization}}
================================================================================
NOTARY ACKNOWLEDGMENT
================================================================================

STATE OF FLORIDA
COUNTY OF {{deal.address.county}}

The foregoing instrument was acknowledged before me this _____ day of
_____________, 20___, by {{#each allSigners}}{{this.name}}{{#unless @last}}, {{/unless}}{{/each}},
who {{#if personallyKnown}}is/are personally known to me{{else}}produced
_________________________ as identification{{/if}}.

_________________________________
Notary Public, State of Florida
Print Name: _________________________
My Commission Expires: ______________
{{/if}}
```

## Output

```typescript
{
  success: true,
  actionTaken: "Generated Amendment #2 to correct buyer name spelling",
  result: {
    document: {
      id: "uuid",
      name: "Amendment #2 - Correction",
      type: "amendment",
      amendmentNumber: 2,
      amendmentType: "correction",
      status: "pending_signature",
      pdfUrl: "https://...",
      docusignEnvelopeId: "env-456"
    },
    changes: {
      section: "Buyer identification",
      original: "John Smithe",
      new: "John Smith"
    },
    requirements: {
      legalReviewRequired: false,
      notarization: false,
      witnesses: 0
    },
    signers: [
      { name: "John Smith", role: "buyer", status: "sent" },
      { name: "Jane Doe", role: "seller", status: "pending" }
    ],
    nextSteps: [
      "Amendment sent for signature",
      "Both parties must sign for amendment to take effect",
      "Contract will be updated when fully executed"
    ]
  }
}
```

## Voice Response

**Standard amendment:**
> "I've created Amendment Number 2 to correct the buyer's name from 'Smithe' to 'Smith.'
>
> This is a formal correction to the contract. I've sent it to both parties for signature.
>
> The contract record will update once everyone signs. Need anything else?"

**Amendment requiring legal review:**
> "I've drafted an amendment to substitute the buyer with their LLC.
>
> This type of amendment typically needs legal review before sending. I've flagged it for review.
>
> Would you like me to send it to your broker or attorney first?"

## Error Handling

| Error | Cause | Response |
|-------|-------|----------|
| `DEAL_NOT_ACTIVE` | Deal closed/cancelled | "This deal is no longer active. Cannot amend." |
| `PENDING_AMENDMENT` | Amendment pending on same term | "There's already a pending amendment for this. Complete or void it first?" |
| `UNAUTHORIZED` | User can't amend | "Amendments require broker approval for this deal." |
| `INVALID_SECTION` | Section reference not found | "I couldn't find that section. Can you specify which part of the contract?" |
| `PARTY_MISSING` | Party info incomplete | "I need complete contact info for all parties to send this amendment." |

## Amendment vs Addendum Guidelines

| Use Amendment When | Use Addendum When |
|-------------------|-------------------|
| Correcting errors in original | Extending deadlines |
| Changing party names/entities | Adding new terms |
| Modifying core contract terms | Minor modifications |
| Legal description changes | Price adjustments |
| Formal substitution of parties | Waivers |
| Court or legal requirements | Day-to-day negotiations |

## Florida-Specific Notes

- Amendments to real property contracts should reference specific sections
- Party substitutions may require additional title insurance endorsements
- Legal description amendments should match title commitment
- Some amendments trigger new disclosure requirements
- Recording may be required for certain amendment types

## Quality Checklist

- [x] Tracks amendment number in sequence
- [x] Formal legal language appropriate for amendments
- [x] Clear DELETE/INSERT formatting
- [x] Recitals establish context
- [x] References all previous amendments
- [x] Supports notarization when required
- [x] Supports witness requirements
- [x] Flags for legal review when appropriate
- [x] Handles party substitution properly
- [x] Florida-compliant language
- [x] Complete audit trail
- [x] All parties must sign

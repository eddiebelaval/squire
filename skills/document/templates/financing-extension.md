# Skill: Financing Extension Addendum

**Category:** Document/Template
**Priority:** P0
**Approval Required:** No

## Purpose

Generate a Florida-compliant addendum to extend the financing contingency period on a real estate contract. This addendum is used when buyers need additional time to secure loan approval, often due to lender delays, document requests, or underwriting issues.

## Triggers

### Voice Commands
- "Extend financing contingency by [X] days"
- "Add financing extension, [X] days"
- "Extend loan deadline to [date]"
- "Need more time for financing on [address]"
- "Create financing extension addendum"
- "Push back the financing deadline"

### Programmatic
- `POST /deals/:dealId/documents/addendum/financing-extension`
- `POST /deals/:dealId/documents/generate` with `templateId: financing_extension`

## Required Inputs

| Input | Type | Required | Source | Default |
|-------|------|----------|--------|---------|
| `dealId` | UUID | Yes | context | - |
| `extensionDays` | number | Yes* | voice | - |
| `newDeadline` | Date | Yes* | voice/calculated | - |

*Either `extensionDays` OR `newDeadline` required

## Optional Inputs

| Input | Type | Default | Source | Description |
|-------|------|---------|--------|-------------|
| `reason` | string | "additional time needed to secure financing" | voice | Reason for extension |
| `lenderName` | string | from deal | manual | Current lender |
| `loanType` | string | from deal | manual | Loan type (conventional, FHA, VA) |
| `specificConditions` | string[] | [] | manual | Any conditions attached |
| `sendForSignature` | boolean | true | config | Auto-send to DocuSign |
| `signers` | Signer[] | from deal parties | config | Override default signers |

## Execution Flow

```
START
  │
  ├─── 1. Load deal and deadline data
  │    ├── Get deal by ID
  │    ├── Find financing contingency deadline
  │    ├── Get current deadline date
  │    ├── Get buyer and seller from parties
  │    └── Get financing details (lender, loan type)
  │
  ├─── 2. Calculate new deadline
  │    │
  │    ├── IF extensionDays provided:
  │    │   └── newDeadline = currentDeadline + extensionDays
  │    │
  │    ├── IF newDeadline provided:
  │    │   └── extensionDays = newDeadline - currentDeadline
  │    │
  │    └── Apply weekend/holiday adjustment
  │        └── INVOKE: adjust-for-weekends skill
  │
  ├─── 3. Validate extension
  │    ├── New deadline not past closing date
  │    ├── Extension is reasonable (flag if > 21 days)
  │    ├── Current deadline hasn't already passed
  │    └── Financing contingency still exists (not waived)
  │
  ├─── 4. Fill template
  │    ├── Property address
  │    ├── Buyer name(s)
  │    ├── Seller name(s)
  │    ├── Original effective date
  │    ├── Current financing deadline
  │    ├── New financing deadline
  │    ├── Extension days
  │    ├── Lender information (if known)
  │    ├── Loan type
  │    └── Reason
  │
  ├─── 5. Generate PDF
  │    └── Create PDF from filled template
  │
  ├─── 6. Create document record
  │    ├── type: 'addendum'
  │    ├── template_id: 'financing_extension'
  │    ├── status: 'draft' or 'sent'
  │    └── Store PDF URL
  │
  ├─── 7. IF sendForSignature:
  │    ├── Create signers
  │    │   ├── Buyer (required)
  │    │   └── Seller (required)
  │    │
  │    ├── INVOKE: send-for-signature skill
  │    │
  │    └── Update document status to 'sent'
  │
  ├─── 8. Update deadline (pending signature)
  │    └── Mark deadline as 'pending_extension'
  │
  ├─── 9. Log action
  │    └── action_type: 'document_generated'
  │
  └─── 10. Return result
```

## Template Content

```
ADDENDUM TO RESIDENTIAL CONTRACT FOR SALE AND PURCHASE
FINANCING CONTINGENCY EXTENSION

Date: {{current_date}}

Property Address: {{deal.property_address.street}}
                  {{deal.property_address.city}}, {{deal.property_address.state}} {{deal.property_address.zip}}

Buyer(s): {{#each buyers}}{{this.name}}{{#unless @last}}, {{/unless}}{{/each}}
Seller(s): {{#each sellers}}{{this.name}}{{#unless @last}}, {{/unless}}{{/each}}

Effective Date of Original Contract: {{deal.effective_date}}

This Addendum is made a part of the above-referenced Contract for Sale and
Purchase ("Contract").

================================================================================
FINANCING CONTINGENCY EXTENSION
================================================================================

WHEREAS, the Contract contains a financing contingency requiring Buyer to
obtain loan approval by {{current_deadline}}; and

WHEREAS, Buyer requires additional time to satisfy the financing contingency;

NOW, THEREFORE, the parties agree as follows:

1. EXTENSION OF FINANCING CONTINGENCY

   The Financing Contingency deadline established in the Contract is hereby
   extended from:

   ORIGINAL DEADLINE: {{current_deadline}}
   NEW DEADLINE:      {{new_deadline}}

   This represents an extension of {{extension_days}} calendar day(s).

2. FINANCING DETAILS
   {{#if lenderName}}
   Current Lender: {{lenderName}}
   {{/if}}
   {{#if loanType}}
   Loan Type: {{loanType}}
   {{/if}}

3. REASON FOR EXTENSION

   {{reason}}

{{#if specificConditions.length > 0}}
4. SPECIAL CONDITIONS

   The following conditions apply to this extension:
   {{#each specificConditions}}
   • {{this}}
   {{/each}}
{{/if}}

4. BUYER'S OBLIGATIONS

   Buyer shall continue to diligently pursue loan approval and provide any
   documentation or information requested by the lender in a timely manner.

   Buyer agrees to keep Seller and/or Seller's agent informed of the loan
   status and any material changes.

5. EFFECT ON CONTRACT

   All other terms and conditions of the Contract not modified by this
   Addendum shall remain unchanged and in full force and effect.

   Time remains of the essence for all provisions of the Contract.

================================================================================
ACKNOWLEDGMENT
================================================================================

The parties acknowledge that:

• Seller is not obligated to grant this extension
• This extension does not guarantee loan approval
• Buyer remains obligated to meet the new deadline
• Failure to meet the new deadline subjects Buyer to the same consequences
  as failure to meet the original deadline

================================================================================
SIGNATURES
================================================================================

BUYER:                                    DATE:
_________________________________        _______________
{{buyers.[0].name}}

{{#if buyers.[1]}}
_________________________________        _______________
{{buyers.[1].name}}
{{/if}}

SELLER:                                   DATE:
_________________________________        _______________
{{sellers.[0].name}}

{{#if sellers.[1]}}
_________________________________        _______________
{{sellers.[1].name}}
{{/if}}
```

## DocuSign Configuration

```typescript
const docusignConfig = {
  emailSubject: "Financing Extension Addendum - {{property_address}}",
  emailBlurb: "Please sign the attached Financing Contingency Extension Addendum for {{property_address}}. This extends the financing deadline to {{new_deadline}}.",
  signers: [
    {
      role: "buyer",
      routingOrder: 1,
      tabs: {
        signHere: { anchorString: "BUYER:", anchorYOffset: 20 },
        dateSigned: { anchorString: "DATE:", anchorYOffset: 20, anchorXOffset: -100 }
      }
    },
    {
      role: "seller",
      routingOrder: 2,
      tabs: {
        signHere: { anchorString: "SELLER:", anchorYOffset: 20 },
        dateSigned: { anchorString: "DATE:", anchorYOffset: 20, anchorXOffset: -100 }
      }
    }
  ]
};
```

## Output

```typescript
{
  success: true,
  actionTaken: "Created financing extension addendum for 123 Main St",
  result: {
    document: {
      id: "uuid",
      name: "Financing Extension Addendum",
      type: "addendum",
      templateId: "financing_extension",
      status: "sent",
      pdfUrl: "https://...",
      docusignEnvelopeId: "env-123"
    },
    extension: {
      originalDeadline: "2026-02-14",
      newDeadline: "2026-02-28",
      extensionDays: 14
    },
    financing: {
      lender: "First National Bank",
      loanType: "Conventional"
    },
    signers: [
      { name: "John Smith", email: "john@email.com", status: "sent" },
      { name: "Jane Doe", email: "jane@email.com", status: "sent" }
    ],
    nextSteps: [
      "Document sent to buyer and seller for signature",
      "You'll be notified when both parties sign",
      "Financing deadline will auto-update once signed",
      "Continue working with lender on approval"
    ]
  }
}
```

## Voice Response

> "Created a financing extension addendum for 123 Main Street.
>
> The financing deadline is extended from February 14th to February 28th — that's 14 additional days.
>
> I've sent it to John Smith and Jane Doe for signature. The deadline will update in your tracker once both parties sign.
>
> Is the lender expecting to close by the new deadline?"

## Post-Signature Actions

When all parties sign (via DocuSign webhook):

1. Update document status to 'completed'
2. Update financing deadline:
   - `due_date` = new deadline
   - `original_due_date` = old deadline
   - `extension_count` += 1
   - `status` = 'upcoming'
3. Reschedule deadline alerts for new date
4. Notify agent: "Financing extension signed. New deadline: [date]"
5. Log action

## Error Handling

| Error | Cause | Response |
|-------|-------|----------|
| `DEADLINE_PASSED` | Financing deadline already passed | "The financing deadline has already passed. You may need to negotiate with the seller." |
| `PAST_CLOSING` | New deadline would be after closing | "That extension would push past the closing date of [date]. Extend closing first?" |
| `CONTINGENCY_WAIVED` | Financing contingency removed | "The financing contingency has been waived. This extension may not apply." |
| `NO_BUYER` | Buyer not in parties | "I need the buyer's name and email to send for signature." |
| `NO_SELLER` | Seller not in parties | "I need the seller's name and email to send for signature." |
| `EXCESSIVE_EXTENSION` | More than 21 days | "That's a significant extension. Make sure the seller is agreeable before sending." |

## Florida-Specific Notes

- FAR/BAR contracts typically include financing contingency periods of 30 days
- Extensions should be in writing and signed by all parties
- Lender delays are common reasons for extensions
- Some sellers may require interest or concessions for long extensions
- Consider whether extension impacts other deadlines (appraisal, etc.)

## Common Reasons for Financing Extensions

| Reason | Typical Extension |
|--------|-------------------|
| Lender processing delays | 7-14 days |
| Additional documentation requested | 5-10 days |
| Underwriting conditions | 7-14 days |
| Appraisal issues | 7-14 days |
| Rate lock expiration concerns | 5-7 days |
| Employment/income verification | 7-14 days |
| Change of lender | 14-21 days |

## Quality Checklist

- [x] Extracts days or date from voice naturally
- [x] Calculates correct new deadline
- [x] Applies weekend/holiday adjustment
- [x] Includes lender and loan type if known
- [x] Uses Florida-compliant template language
- [x] Auto-sends for signature by default
- [x] Updates deadline after signing
- [x] Reschedules alerts for new deadline
- [x] Handles multiple buyers/sellers
- [x] Creates complete audit trail
- [x] Validates against closing date
- [x] Checks that contingency hasn't been waived
- [x] Clear voice response with all details

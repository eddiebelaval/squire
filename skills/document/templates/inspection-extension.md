# Skill: Inspection Extension Addendum

**Category:** Document/Template
**Priority:** P0
**Approval Required:** No

## Purpose

Generate a Florida-compliant addendum to extend the inspection period on a real estate contract. This is one of the most commonly needed addenda, used when buyers need more time to complete inspections or negotiate repairs.

## Triggers

### Voice Commands
- "Add inspection extension, [X] days"
- "Extend inspection period by [X] days"
- "Extend inspection to [date]"
- "Need more time for inspection on [address]"
- "Create inspection extension addendum"

### Programmatic
- `POST /deals/:dealId/documents/addendum/inspection-extension`
- `POST /deals/:dealId/documents/generate` with `templateId: inspection_extension`

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
| `reason` | string | "additional time needed for inspections" | voice | Reason for extension |
| `sendForSignature` | boolean | true | config | Auto-send to DocuSign |
| `signers` | Signer[] | from deal parties | config | Override default signers |

## Execution Flow

```
START
  │
  ├─── 1. Load deal and deadline data
  │    ├── Get deal by ID
  │    ├── Find inspection period deadline
  │    ├── Get current deadline date
  │    └── Get buyer and seller from parties
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
  │    ├── Extension is reasonable (not > 30 days typically)
  │    └── Current deadline hasn't already passed
  │
  ├─── 4. Fill template
  │    ├── Property address
  │    ├── Buyer name(s)
  │    ├── Seller name(s)
  │    ├── Original effective date
  │    ├── Current inspection deadline
  │    ├── New inspection deadline
  │    ├── Extension days
  │    └── Reason
  │
  ├─── 5. Generate PDF
  │    └── Create PDF from filled template
  │
  ├─── 6. Create document record
  │    ├── type: 'addendum'
  │    ├── template_id: 'inspection_extension'
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

Date: {{current_date}}

Property Address: {{deal.property_address.street}}
                  {{deal.property_address.city}}, {{deal.property_address.state}} {{deal.property_address.zip}}

Buyer(s): {{buyer.name}}
Seller(s): {{seller.name}}

Effective Date of Original Contract: {{deal.effective_date}}

This Addendum is made a part of the above-referenced Contract.

INSPECTION PERIOD EXTENSION

The parties agree to amend the Contract as follows:

1. The Inspection Period deadline established in the Contract is hereby
   extended from {{current_deadline}} to {{new_deadline}}.

2. This extension represents an additional {{extension_days}} calendar
   day(s) for the Buyer to complete inspections and deliver any notices
   required under the inspection provisions of the Contract.

3. Reason for Extension: {{reason}}

4. All other terms and conditions of the Contract remain unchanged and
   in full force and effect.

5. Time remains of the essence for all provisions of the Contract.

SIGNATURES:

BUYER:                                    DATE:
_________________________________        _______________
{{buyer.name}}

SELLER:                                   DATE:
_________________________________        _______________
{{seller.name}}
```

## DocuSign Configuration

```typescript
const docusignConfig = {
  emailSubject: "Inspection Extension Addendum - {{property_address}}",
  emailBlurb: "Please sign the attached Inspection Period Extension Addendum for {{property_address}}. This extends the inspection deadline to {{new_deadline}}.",
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
  actionTaken: "Created inspection extension addendum for 123 Main St",
  result: {
    document: {
      id: "uuid",
      name: "Inspection Extension Addendum",
      type: "addendum",
      templateId: "inspection_extension",
      status: "sent",
      pdfUrl: "https://...",
      docusignEnvelopeId: "env-123"
    },
    extension: {
      originalDeadline: "2026-01-30",
      newDeadline: "2026-02-04",
      extensionDays: 5
    },
    signers: [
      { name: "John Smith", email: "john@email.com", status: "sent" },
      { name: "Jane Doe", email: "jane@email.com", status: "sent" }
    ],
    nextSteps: [
      "Document sent to buyer and seller for signature",
      "You'll be notified when both parties sign",
      "Deadline will auto-update once signed"
    ]
  }
}
```

## Voice Response

> "Created an inspection extension addendum for 123 Main Street.
>
> The inspection deadline is extended from January 30th to February 4th — that's 5 additional days.
>
> I've sent it to John Smith and Jane Doe for signature via DocuSign. I'll update the deadline in your tracker once both parties sign.
>
> Is there anything else you need for this deal?"

## Post-Signature Actions

When all parties sign (via DocuSign webhook):

1. Update document status to 'completed'
2. Update deadline:
   - `due_date` = new deadline
   - `original_due_date` = old deadline
   - `extension_count` += 1
   - `status` = 'upcoming'
3. Reschedule deadline alerts for new date
4. Notify agent: "Inspection extension signed. New deadline: [date]"
5. Log action

## Error Handling

| Error | Cause | Response |
|-------|-------|----------|
| `DEADLINE_PASSED` | Current inspection deadline already passed | "The inspection deadline has already passed. You may need a different addendum or seller agreement." |
| `PAST_CLOSING` | New deadline would be after closing | "That extension would push past the closing date of [date]. Extend closing first?" |
| `NO_BUYER` | Buyer not in parties | "I need the buyer's name and email to send for signature." |
| `NO_SELLER` | Seller not in parties | "I need the seller's name and email to send for signature." |
| `EXCESSIVE_EXTENSION` | More than 30 days | "That's a long extension. Are you sure you want to extend by [X] days?" |

## Quality Checklist

- [x] Extracts days or date from voice naturally
- [x] Calculates correct new deadline
- [x] Applies weekend/holiday rule to new date
- [x] Uses Florida-compliant template language
- [x] Auto-sends for signature by default
- [x] Updates deadline after signing
- [x] Reschedules alerts for new deadline
- [x] Handles multiple buyers/sellers
- [x] Creates complete audit trail
- [x] Validates against closing date
- [x] Clear voice response with all details

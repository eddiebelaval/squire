# Skill: Send for Signature

**Category:** Document
**Priority:** P0
**Approval Required:** Yes (for high-stakes documents)

## Purpose

Send documents for electronic signature via DocuSign integration. This skill handles envelope creation, signer configuration, tab placement, and delivery tracking. It's the core signature workflow that other document skills invoke.

## Triggers

### Voice Commands
- "Send [document] for signature"
- "Get signatures on [document/deal]"
- "Send to [party] for signing"
- "DocuSign the [document type]"
- "E-sign [document]"

### Programmatic
- `POST /documents/:documentId/send-for-signature`
- Invoked by document generation skills
- Bulk signature request
- API integration

## Required Inputs

| Input | Type | Required | Source | Description |
|-------|------|----------|--------|-------------|
| `documentId` | UUID | Yes* | context | Document to send |
| `documentUrl` | string | Yes* | document | PDF URL if no documentId |
| `signers` | Signer[] | Yes | manual/deal | People who need to sign |

*Either `documentId` OR `documentUrl` required

## Optional Inputs

| Input | Type | Default | Source | Description |
|-------|------|---------|--------|-------------|
| `dealId` | UUID | null | context | Link to deal for tracking |
| `emailSubject` | string | auto | manual | Custom email subject |
| `emailBody` | string | auto | manual | Custom email message |
| `signingOrder` | string | 'sequential' | config | 'sequential' or 'parallel' |
| `expirationDays` | number | 7 | config | Days until envelope expires |
| `reminderDays` | number | 2 | config | Days before reminder |
| `urgency` | string | 'normal' | voice | 'urgent', 'normal', 'low' |
| `accessCode` | boolean | false | config | Require access code |
| `inPerson` | boolean | false | config | In-person signing |
| `carbonCopy` | Recipient[] | [] | config | People to CC |
| `brandingId` | string | default | config | DocuSign branding |

## Signer Object

```typescript
interface Signer {
  // Required
  name: string;
  email: string;
  role: 'buyer' | 'seller' | 'agent' | 'broker' | 'attorney' | 'other';

  // Optional
  routingOrder?: number;           // Signing sequence (1, 2, 3...)
  accessCode?: string;             // PIN for verification
  phone?: string;                  // For SMS authentication
  tabs?: SignatureTabs;            // Tab placement
  inPerson?: boolean;              // Requires in-person signing
  signHereOptional?: boolean;      // Sign is optional

  // Notification preferences
  emailNotification?: boolean;     // Send email
  smsNotification?: boolean;       // Send SMS
}

interface SignatureTabs {
  signHere?: TabPlacement[];
  initialHere?: TabPlacement[];
  dateSigned?: TabPlacement[];
  textTabs?: TextTab[];
  checkboxTabs?: CheckboxTab[];
}

interface TabPlacement {
  anchorString?: string;           // Text anchor in document
  anchorXOffset?: number;
  anchorYOffset?: number;
  pageNumber?: number;             // Specific page
  xPosition?: number;              // Absolute position
  yPosition?: number;
}
```

## Execution Flow

```
START
  │
  ├─── 1. Validate inputs
  │    ├── Verify document exists/URL valid
  │    ├── Validate all signer emails
  │    ├── Check for duplicate signers
  │    └── Verify document not already sent
  │
  ├─── 2. Load document context
  │    ├── Get document record
  │    ├── Get deal if linked
  │    ├── Determine document type
  │    └── Get default tab configurations
  │
  ├─── 3. Configure envelope
  │    │
  │    ├── Basic settings:
  │    │   ├── emailSubject: generated or custom
  │    │   ├── emailBlurb: generated or custom
  │    │   ├── status: 'sent' (send immediately)
  │    │   └── expirationDays: based on urgency
  │    │
  │    ├── Reminder settings:
  │    │   ├── reminderEnabled: true
  │    │   ├── reminderDelay: calculated
  │    │   └── reminderFrequency: 1 day
  │    │
  │    └── Notification settings:
  │        └── Configure per signer preference
  │
  ├─── 4. Configure signers
  │    │
  │    ├── FOR EACH signer:
  │    │   ├── Set routing order
  │    │   ├── Configure authentication
  │    │   ├── Place signature tabs
  │    │   │   ├── Use anchor strings if available
  │    │   │   └── Fall back to absolute positioning
  │    │   ├── Place date tabs
  │    │   └── Place any required text/checkbox tabs
  │    │
  │    └── Configure carbon copies
  │
  ├─── 5. Create DocuSign envelope
  │    ├── Upload document(s)
  │    ├── Add recipients
  │    ├── Place all tabs
  │    ├── Set envelope options
  │    └── Send envelope
  │
  ├─── 6. Handle DocuSign response
  │    │
  │    ├── IF success:
  │    │   ├── Store envelope ID
  │    │   ├── Store per-recipient status
  │    │   └── Continue to step 7
  │    │
  │    └── IF error:
  │        ├── Parse error type
  │        ├── Attempt recovery if possible
  │        └── Return detailed error
  │
  ├─── 7. Update document record
  │    ├── status: 'pending_signature'
  │    ├── docusignEnvelopeId: envelope ID
  │    ├── sentAt: timestamp
  │    └── signers: with status
  │
  ├─── 8. Create signature tracking
  │    ├── Create signature_requests entries
  │    ├── Set expected completion date
  │    └── Queue follow-up reminders
  │
  ├─── 9. Notify agent
  │    └── "Document sent to [signers]"
  │
  ├─── 10. Log action
  │     └── action_type: 'document_sent_for_signature'
  │
  └─── 11. Return result
```

## DocuSign Integration

### API Configuration
```typescript
const docusignConfig = {
  baseUrl: process.env.DOCUSIGN_BASE_URL,
  accountId: process.env.DOCUSIGN_ACCOUNT_ID,
  integrationKey: process.env.DOCUSIGN_INTEGRATION_KEY,
  userId: process.env.DOCUSIGN_USER_ID,
  privateKey: process.env.DOCUSIGN_PRIVATE_KEY,

  defaultBranding: 'homer_pro_brand',

  urgencySettings: {
    urgent: {
      expirationDays: 1,
      reminderDelay: 0,
      reminderFrequency: 4  // hours
    },
    normal: {
      expirationDays: 7,
      reminderDelay: 2,
      reminderFrequency: 24  // hours
    },
    low: {
      expirationDays: 14,
      reminderDelay: 5,
      reminderFrequency: 48  // hours
    }
  }
};
```

### Webhook Events Handled
| Event | Action |
|-------|--------|
| `envelope-sent` | Update status, log |
| `envelope-delivered` | Update recipient status |
| `envelope-completed` | INVOKE: handle-signature-complete |
| `envelope-declined` | Alert agent, update status |
| `envelope-voided` | Update status, clean up |
| `recipient-signed` | Update individual status |
| `recipient-declined` | Alert agent, pause flow |

### Standard Tab Placements by Document Type

```typescript
const standardTabs = {
  addendum: {
    buyer: {
      signHere: [{ anchorString: "BUYER:", anchorYOffset: 20 }],
      dateSigned: [{ anchorString: "Date:", anchorXOffset: 100, pageNumber: -1 }]
    },
    seller: {
      signHere: [{ anchorString: "SELLER:", anchorYOffset: 20 }],
      dateSigned: [{ anchorString: "Date:", anchorXOffset: 100, pageNumber: -1 }]
    }
  },
  notice: {
    sender: {
      signHere: [{ anchorString: "SIGNATURE", anchorYOffset: 20 }],
      dateSigned: [{ anchorString: "Date:", anchorXOffset: 100 }]
    }
  },
  contract: {
    // More complex tab placement for full contracts
    buyer: {
      signHere: [
        { pageNumber: 8, xPosition: 100, yPosition: 650 },
        { pageNumber: 10, xPosition: 100, yPosition: 400 }
      ],
      initialHere: [
        { anchorString: "Buyer Initials:", anchorYOffset: -5 }
      ]
    }
    // ... more roles
  }
};
```

## Output

```typescript
{
  success: true,
  actionTaken: "Sent inspection extension for signature",
  result: {
    envelope: {
      id: "env-abc123",
      status: "sent",
      createdAt: "2026-01-15T14:30:00Z",
      expiresAt: "2026-01-22T14:30:00Z"
    },
    document: {
      id: "doc-uuid",
      name: "Inspection Extension Addendum",
      status: "pending_signature"
    },
    signers: [
      {
        name: "John Smith",
        email: "john@email.com",
        role: "buyer",
        routingOrder: 1,
        status: "sent",
        sentAt: "2026-01-15T14:30:00Z"
      },
      {
        name: "Jane Doe",
        email: "jane@email.com",
        role: "seller",
        routingOrder: 2,
        status: "created",  // Waiting for previous signer
        sentAt: null
      }
    ],
    carbonCopy: [
      { name: "Listing Agent", email: "agent@broker.com" }
    ],
    tracking: {
      url: "https://docusign.com/track/env-abc123",
      expectedCompletion: "2026-01-17"
    },
    nextSteps: [
      "John Smith will receive the document first",
      "After John signs, Jane Doe will receive it",
      "You'll be notified when both parties sign",
      "Expected completion: 2 days"
    ]
  }
}
```

## Voice Response

**Standard send:**
> "I've sent the inspection extension to John Smith and Jane Doe for signature.
>
> John will sign first, then Jane. I've set a reminder for 2 days if they haven't signed.
>
> I'll notify you when it's fully executed. The deal will update automatically."

**Urgent send:**
> "Sending as urgent - the document expires tomorrow at this time.
>
> John Smith should receive it now. I'll send reminders every 4 hours until signed.
>
> Want me to text John to let him know it's urgent?"

## Error Handling

| Error | Cause | Response |
|-------|-------|----------|
| `INVALID_EMAIL` | Bad email format | "The email [email] doesn't look right. Can you verify?" |
| `DUPLICATE_SIGNER` | Same email twice | "[Name] is listed twice. Should they sign once or twice?" |
| `DOCUMENT_NOT_FOUND` | Doc doesn't exist | "I can't find that document. Which one should I send?" |
| `ALREADY_SENT` | Already pending signature | "This document is already out for signature. Void it first?" |
| `DOCUSIGN_AUTH_FAILED` | Auth issue | "Having trouble connecting to DocuSign. Trying again..." |
| `ENVELOPE_CREATE_FAILED` | API error | "DocuSign returned an error: [details]. Let me try again." |
| `SIGNER_OPTED_OUT` | Email blocked | "[Name] has opted out of DocuSign. Try in-person signing?" |

## In-Person Signing Flow

```typescript
// When inPerson = true for a signer
{
  hostName: "Agent Name",
  hostEmail: "agent@email.com",
  signerName: "John Smith",
  signerEmail: "john@email.com",  // For record only

  // Agent gets in-person signing link
  signingUrl: "https://docusign.com/inperson/..."
}
```

## Bulk Sending

```typescript
// Send same document to multiple parties
{
  documentId: "uuid",
  recipients: [
    { dealId: "deal-1", signers: [...] },
    { dealId: "deal-2", signers: [...] },
    { dealId: "deal-3", signers: [...] }
  ],
  template: {
    emailSubject: "Document for {{property_address}}",
    emailBody: "Please sign the attached..."
  }
}
```

## Integration Points

### Invokes
- DocuSign eSignature API
- `store-document` - After signing complete
- `remind-unsigned` - For overdue signatures

### Invoked By
- `generate-addendum`
- `generate-amendment`
- `generate-notice`
- All document template skills

### Webhook Handler
- Receives DocuSign events
- Updates document/signature status
- Triggers completion workflows

## Quality Checklist

- [x] Validates all email addresses
- [x] Supports sequential and parallel signing
- [x] Configures tabs automatically by document type
- [x] Handles multiple signers correctly
- [x] Sets appropriate expiration based on urgency
- [x] Configures automatic reminders
- [x] Tracks per-recipient status
- [x] Handles DocuSign errors gracefully
- [x] Supports in-person signing
- [x] Supports access code verification
- [x] Creates complete audit trail
- [x] Updates deal when signed
- [x] Clear voice responses with next steps

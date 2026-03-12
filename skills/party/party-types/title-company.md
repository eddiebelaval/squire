# Party Type: Title Company

**Role Code:** `title_company`
**Category:** Vendor Party
**Typical Count:** 1 per deal

## Overview

The title company (or closing agent) handles the title search, title insurance, escrow, and closing in Florida real estate transactions. They are a neutral third party that ensures proper transfer of title and distribution of funds. In Florida, closings are typically conducted by title companies rather than attorneys.

## Role Definition

### Who Is This Party?
- Licensed title insurance agent/agency
- Holds escrow deposits
- Conducts title search
- Issues title insurance
- Coordinates and conducts closing

### Common Configurations
| Type | Description | Example |
|------|-------------|---------|
| National Company | Large title insurer | First American, Stewart |
| Regional Company | State-wide operation | Attorney's Title, Florida Title |
| Local Company | Local independent | Miami Title Services |
| Attorney Escrow | Attorney as closing agent | Smith Law Firm |

## Contact Requirements

### Required Information
| Field | Required | Reason |
|-------|----------|--------|
| Company Name | Yes | Contract, title commitment |
| Closing Agent Name | Yes | Primary contact |
| Email | Yes | Document delivery |
| Phone | Yes | Coordination |
| Escrow Account | Yes | Wire instructions |
| Address | Yes | Closing location |

### Optional Information
| Field | When Needed |
|-------|-------------|
| Underwriter | Title insurance policy |
| Title Processor | Day-to-day contact |
| File Number | Reference on communications |
| Wire Instructions | Deposit, closing funds |

## Key Deadlines Involving Title Company

| Deadline | Title's Role | Action Required |
|----------|--------------|-----------------|
| Escrow Deposit | Receive and hold | Confirm receipt |
| Title Commitment | Issue commitment | Deliver to parties |
| Title Cure | Resolve issues | Clear defects |
| Survey | Coordinate | Order if needed |
| Closing Disclosure | Prepare and deliver | 3 days before closing |
| Closing | Conduct | Execute transfer |
| Recording | Record deed | File with county |

## Typical Communications

### With Title Company

| Type | Frequency | Purpose |
|------|-----------|---------|
| Title Order | Once | Open title/escrow |
| Escrow Confirmation | Once | Confirm deposit receipt |
| Title Status | As needed | Check for issues |
| Closing Scheduling | 1 week before | Set date/time |
| Document Delivery | Before closing | Provide party info |
| Closing Confirmation | Day of | Confirm completion |

### Communication Templates

**Title Order:**
> Subject: New File - [Address]
>
> Hi [Title Contact],
>
> Please open a file for the following transaction:
>
> Property: [Full Address]
> Seller: [Seller Name(s)]
> Buyer: [Buyer Name(s)]
> Purchase Price: $[Amount]
> Effective Date: [Date]
> Closing Date: [Date]
>
> Lender: [If applicable]
> Contract: Attached
>
> Please send wire instructions for the escrow deposit and let me know the file number.

**Title Status Check:**
> Subject: Title Status - [Address] / File #[Number]
>
> Hi [Title Contact],
>
> Can you provide a status update on the title search for [Address]?
>
> Specifically:
> - Has the title commitment been issued?
> - Are there any defects or issues to address?
> - Do you need anything from the parties?
>
> Closing is scheduled for [Date].

## Voice Command Examples

### Adding Title Company
```
"Title company is First American"
"Add First American Title with Jennifer as my contact"
"The closing is at Stewart Title"
"Jennifer at First American, phone 305-555-4000"
```

### Title Company Queries
```
"Who is the title company?"
"Get the wire instructions"
"What's the title company's number?"
"Title file number for this deal"
```

### Title Company Actions
```
"Email the title company to check status"
"Send contract to title"
"Ask title about the escrow deposit"
"Schedule closing with title"
```

## Schema

```typescript
interface TitleCompany {
  // Identity
  id: string;
  role: 'title_company';

  // Company Info
  companyName: string;
  branchName?: string;
  underwriter?: string; // First American, Fidelity, Stewart, etc.

  // Primary Contact (Closer/Escrow Officer)
  closingAgentName: string;
  closingAgentEmail: string;
  closingAgentPhone: string;

  // Secondary Contact (Title Processor)
  processorName?: string;
  processorEmail?: string;
  processorPhone?: string;

  // Office Info
  address: {
    street: string;
    suite?: string;
    city: string;
    state: string;
    zip: string;
  };
  mainPhone: string;
  fax?: string;

  // File Info
  fileNumber?: string;
  openedDate?: Date;

  // Financial
  wireInstructions?: {
    bankName: string;
    routingNumber: string;
    accountNumber: string;
    accountName: string;
    reference?: string;
  };

  // Title Details
  titleCommitmentNumber?: string;
  titleCommitmentDate?: Date;
  titlePolicyAmount?: number;

  // Closing Details
  closingScheduled?: boolean;
  closingDateTime?: Date;
  closingLocation?: string; // Office, remote, or address
  closingType?: 'in_person' | 'remote' | 'hybrid' | 'mail_away';

  // Preferences
  communicationPrefs: CommunicationPreferences;

  // Timestamps
  addedAt: Date;
  updatedAt: Date;
}
```

## Florida-Specific Considerations

### Title Insurance
- Owner's policy protects buyer (optional but standard)
- Lender's policy required if financing (buyer pays)
- Seller typically pays owner's policy in South Florida

### Who Pays What (South Florida Custom)
| Item | Typically Pays |
|------|---------------|
| Owner's Title Insurance | Seller |
| Lender's Title Insurance | Buyer |
| Title Search | Seller |
| Closing Fee | Split or negotiable |
| Recording Fees | Buyer |
| Doc Stamps on Deed | Seller |
| Doc Stamps on Mortgage | Buyer |

### Title Defects Common in Florida
- Open mortgages
- HOA liens
- Judgment liens
- Child support liens
- Code enforcement liens
- Easement issues
- Survey encroachments

### Remote Closing
- Florida allows RON (Remote Online Notarization)
- Some title companies offer remote closings
- COVID accelerated adoption

## Integration Points

### Escrow Skills
- Track deposit status
- Confirm receipt
- Wire instruction delivery

### Deadline Skills
- Title commitment deadline
- Closing disclosure (3-day rule)
- Closing date coordination

### Document Skills
- Title commitment delivery
- Survey coordination
- Closing doc preparation

### Communication Skills
- Title order submission
- Status updates
- Closing coordination

## Title Issue Resolution

### Common Issues and Actions

```typescript
const titleIssues = [
  {
    issue: 'Open Mortgage',
    resolution: 'Obtain payoff letter, pay at closing',
    responsible: 'seller'
  },
  {
    issue: 'HOA Lien',
    resolution: 'Pay current or negotiate',
    responsible: 'seller'
  },
  {
    issue: 'Judgment Lien',
    resolution: 'Negotiate payoff or release',
    responsible: 'seller'
  },
  {
    issue: 'Name Discrepancy',
    resolution: 'Affidavit of identity',
    responsible: 'seller'
  },
  {
    issue: 'Missing Release',
    resolution: 'Obtain release or indemnity',
    responsible: 'seller/title'
  },
  {
    issue: 'Survey Encroachment',
    resolution: 'Remove or get neighbor agreement',
    responsible: 'seller'
  }
];
```

## Quality Checklist

- [x] Company and contact name accurate
- [x] Direct contact info for closing agent
- [x] File number captured when assigned
- [x] Wire instructions on file
- [x] Underwriter identified
- [x] Office address confirmed (for in-person closing)
- [x] Title commitment deadline tracked
- [x] Closing date/time scheduled
- [x] Remote closing capability noted
- [x] Communication preferences set

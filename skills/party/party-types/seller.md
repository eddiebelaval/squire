# Party Type: Seller

**Role Code:** `seller`
**Category:** Principal Party
**Typical Count:** 1-4 per deal

## Overview

The seller is the current owner of the property conveying title to the buyer. They are one of the two principal parties to the transaction (along with the buyer) and must sign all contract documents and the deed. In Florida transactions, the seller has disclosure obligations and must deliver marketable title.

## Role Definition

### Who Is This Party?
- The individual(s) or entity currently holding title to the property
- Named as "Seller" on the contract
- Named as "Grantor" on the deed
- Current owner per public records

### Common Configurations
| Type | Description | Example |
|------|-------------|---------|
| Single Seller | One individual | Maria Rodriguez |
| Married Couple | Spouses selling together | John & Jane Doe |
| Estate Sale | Deceased owner's estate | Estate of John Smith |
| Entity Seller | LLC, Corp, Trust | ABC Properties LLC |
| Multiple Owners | Inherited property | Smith, Jones, Williams |
| Relocation | Corporate relocation | Assisted by relo company |

## Contact Requirements

### Required Information
| Field | Required | Reason |
|-------|----------|--------|
| Full Legal Name | Yes | Must match deed |
| Email | Yes | Document delivery, updates |
| Phone | Yes | Showings, negotiations |
| Current/Forward Address | Yes | Correspondence after close |

### Optional Information
| Field | When Needed |
|-------|-------------|
| Attorney | If represented |
| Power of Attorney | If seller won't attend closing |
| HOA Login | To transfer account |
| Utility Accounts | For final bills |
| Forwarding Address | Post-closing mail |

## Key Deadlines Involving Seller

| Deadline | Seller's Role | Action Required |
|----------|--------------|-----------------|
| Contract Execution | Must sign | Execute contract |
| HOA Docs | Must provide | Request from HOA |
| Repair Response | Decision maker | Respond to buyer requests |
| Survey Issues | Must resolve | Clear encroachments |
| Title Defects | Must cure | Resolve liens, judgments |
| Closing | Attend & sign | Execute deed, closing docs |

## Typical Communications

### From Agent to Seller

| Type | Frequency | Purpose |
|------|-----------|---------|
| Showing Feedback | After showings | Market response |
| Offer Presentation | As received | Negotiation |
| Status Updates | Weekly or per milestone | Transaction progress |
| Deadline Reminders | As needed | Ensure timely action |
| Closing Coordination | 1 week before | Final details |

### Communication Templates

**Offer Received:**
> Subject: New Offer Received - [Address]
>
> Dear [Seller Name],
>
> Great news! We've received an offer on your property at [Address].
>
> Offer Details:
> - Purchase Price: $[Amount]
> - Earnest Money: $[Amount]
> - Financing: [Cash/Conventional/FHA/VA]
> - Closing Date: [Date]
> - Contingencies: [List]
>
> I'd like to discuss this offer with you. When are you available for a call?

**Repair Request Received:**
> Subject: Buyer Repair Request - [Address]
>
> Hi [Seller Name],
>
> The buyer has completed their inspection and submitted a repair request. Here's what they're asking for:
>
> [List of repairs]
>
> We have until [date] to respond. Our options are:
> 1. Agree to all repairs
> 2. Agree to some repairs
> 3. Offer a credit instead
> 4. Decline (buyer may cancel)
>
> Let's discuss the best approach. Can we talk today?

## Voice Command Examples

### Adding Seller
```
"Add Maria Rodriguez as the seller"
"The sellers are John and Jane Doe"
"Estate of Robert Smith is the seller"
"ABC Properties LLC is selling"
```

### Seller Queries
```
"What's the seller's email?"
"Call the seller"
"Who is the seller's attorney?"
"Get the seller's forwarding address"
```

### Seller Actions
```
"Email the seller about the repair request"
"Send the seller the closing documents"
"The seller agreed to repairs - update the deal"
"Schedule the seller for closing"
```

## Schema

```typescript
interface Seller {
  // Identity
  id: string;
  role: 'seller';
  isPrimary: boolean;

  // Personal Info
  firstName: string;
  lastName: string;
  middleName?: string;
  suffix?: string;
  entityName?: string;
  entityType?: 'individual' | 'llc' | 'corporation' | 'trust' | 'estate' | 'partnership';

  // Estate-specific
  isEstate?: boolean;
  personalRepName?: string;
  personalRepPhone?: string;

  // Contact
  email: string;
  phone: string;
  phoneType?: 'mobile' | 'home' | 'work';
  secondaryEmail?: string;
  secondaryPhone?: string;

  // Address
  currentAddress: {
    street: string;
    unit?: string;
    city: string;
    state: string;
    zip: string;
  };
  forwardingAddress?: Address;
  isOccupied: boolean;

  // Transaction Details
  relationToOtherSellers?: 'spouse' | 'partner' | 'relative' | 'business_partner' | 'co-owner' | 'other';
  ownershipPercentage?: number;

  // Power of Attorney
  hasPoa?: boolean;
  poaName?: string;
  poaRelationship?: string;

  // Relocation
  isRelocation?: boolean;
  relocationCompany?: string;
  relocationContact?: string;

  // Property Details
  isPropertyOccupied: boolean;
  tenantInPlace?: boolean;
  leaseExpiration?: Date;

  // Preferences
  communicationPrefs: CommunicationPreferences;
  showingNotifications: boolean;

  // Timestamps
  addedAt: Date;
  updatedAt: Date;
}
```

## Florida-Specific Considerations

### Title Issues Common in Florida
- **Homestead**: Must be addressed if primary residence
- **Mortgages**: Payoff required at closing
- **Liens**: HOA, contractor, tax liens
- **Judgments**: Must be satisfied or negotiated
- **Code Violations**: Open permits, violations

### Seller Disclosures
- Property condition disclosure
- Lead-based paint (pre-1978)
- HOA disclosures
- Material defects known to seller
- Previous insurance claims

### Documentary Stamps
- Florida seller pays documentary stamps on deed
- Rate: $0.70 per $100 (most counties)
- Miami-Dade: $0.60 per $100

## Integration Points

### Document Skills
- Seller signs: Contract, disclosures, deed, affidavits
- Seller provides: HOA docs, survey, permits

### Deadline Skills
- Repair response deadline
- HOA document delivery
- Title cure deadlines

### Communication Skills
- Showing notifications (if requested)
- Offer presentations
- Status updates
- Closing coordination

## Estate Sale Considerations

When the seller is an estate:
```typescript
{
  entityType: 'estate',
  entityName: 'Estate of Robert Smith',
  personalRepName: 'Jane Smith',
  personalRepPhone: '305-555-1234',

  // May need court approval
  requiresCourtApproval: true,
  probateCaseNumber: 'XXXX-XXX',

  // Letters of Administration required
  documentsNeeded: ['Letters of Administration', 'Death Certificate']
}
```

## Relocation Sale Considerations

When seller is assisted by relocation company:
```typescript
{
  isRelocation: true,
  relocationCompany: 'SIRVA Relocation',
  relocationContact: {
    name: 'Jennifer Adams',
    email: 'jadams@sirva.com',
    phone: '800-555-1234'
  },

  // Relo company may be on title
  relocationBuyout: true,
  amendmentRequired: 'Relocation Addendum'
}
```

## Quality Checklist

- [x] Legal name matches title exactly
- [x] All owners on title are included as sellers
- [x] Entity sellers have authorization docs noted
- [x] Estate sales have personal rep info
- [x] Power of Attorney documented if needed
- [x] Forwarding address captured
- [x] Occupancy status confirmed
- [x] HOA account access arranged
- [x] Communication preferences set

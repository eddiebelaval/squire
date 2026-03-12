# Party Type: Buyer

**Role Code:** `buyer`
**Category:** Principal Party
**Typical Count:** 1-4 per deal

## Overview

The buyer is the person or entity purchasing the property. They are one of the two principal parties to the transaction (along with the seller) and must sign all contract documents. In Florida transactions, the buyer has specific rights during inspection and financing contingency periods.

## Role Definition

### Who Is This Party?
- The individual(s) or entity acquiring title to the property
- Named as "Purchaser" or "Buyer" on the contract
- Named as "Grantee" on the deed
- Named as "Borrower" if financing

### Common Configurations
| Type | Description | Example |
|------|-------------|---------|
| Single Buyer | One individual | John Smith |
| Married Couple | Spouses purchasing together | John & Jane Smith |
| Multiple Buyers | Unrelated co-buyers | John Smith & Maria Rodriguez |
| Entity Buyer | LLC, Corp, Trust | Smith Family Trust |
| TBD Entity | Individual "and/or assigns" | John Smith and/or assigns |

## Contact Requirements

### Required Information
| Field | Required | Reason |
|-------|----------|--------|
| Full Legal Name | Yes | Contract execution |
| Email | Yes | Document delivery, updates |
| Phone | Yes | Urgent communications |
| Current Address | Yes | Contract, closing documents |
| SSN (last 4) | Later | Title/lender verification |

### Optional Information
| Field | When Needed |
|-------|-------------|
| Employer | Financing verification |
| Secondary Email | Spouse CC |
| Attorney | If represented |
| Pre-approval Letter | Financing contingency |

## Key Deadlines Involving Buyer

| Deadline | Buyer's Role | Action Required |
|----------|--------------|-----------------|
| Escrow Deposit | Must deliver | Wire/check to title |
| Inspection Period | Decision maker | Approve, repair request, or cancel |
| Financing Contingency | Must secure loan | Provide approval letter |
| Appraisal Contingency | Await result | May negotiate if low |
| Final Walk-Through | Attend | Verify property condition |
| Closing | Attend & sign | Execute closing documents |

## Typical Communications

### From Agent to Buyer

| Type | Frequency | Purpose |
|------|-----------|---------|
| Status Updates | Weekly or per milestone | Transaction progress |
| Deadline Reminders | 5, 2, 1 day before | Ensure timely action |
| Document Requests | As needed | Lender docs, signatures |
| Inspection Coordination | Once | Schedule walk-through |
| Closing Coordination | 1 week before | Final details |

### Communication Templates

**Initial Welcome:**
> Subject: Welcome to Your Home Purchase - [Address]
>
> Dear [Buyer Name],
>
> Congratulations on your offer being accepted! I'm excited to guide you through the purchase of [Address].
>
> Here are the key dates for your transaction:
> - Escrow Deposit Due: [Date]
> - Inspection Period Ends: [Date]
> - Financing Contingency: [Date]
> - Closing Date: [Date]
>
> I'll keep you updated at every step. Please let me know your preferred way to receive updates.

**Deadline Reminder:**
> Subject: Reminder: [Deadline Name] - [Days] Days Away
>
> Hi [Buyer Name],
>
> This is a reminder that [deadline] is coming up on [date].
>
> What you need to do: [Action Required]
>
> Let me know if you have any questions or need assistance.

## Voice Command Examples

### Adding Buyer
```
"Add John Smith as the buyer"
"The buyers are John and Jane Smith"
"Smith Family Trust is purchasing the property"
"Add buyer John Smith, email john@email.com, phone 305-555-1234"
```

### Buyer Queries
```
"What's the buyer's email?"
"Call the buyer"
"When does the buyer need to have financing?"
"Remind me of the buyer's full name"
```

### Buyer Actions
```
"Email the buyer about the inspection"
"Send the buyer the status update"
"The buyer approved the inspection - mark it complete"
"Notify the buyer about the appraisal results"
```

## Schema

```typescript
interface Buyer {
  // Identity
  id: string;
  role: 'buyer';
  isPrimary: boolean; // Primary buyer in multi-buyer scenario

  // Personal Info
  firstName: string;
  lastName: string;
  middleName?: string;
  suffix?: string;
  entityName?: string; // If buying as LLC/Trust
  entityType?: 'individual' | 'llc' | 'corporation' | 'trust' | 'partnership';

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

  // Transaction Details
  relationToOtherBuyers?: 'spouse' | 'partner' | 'relative' | 'business_partner' | 'other';
  vestingType?: 'joint_tenants' | 'tenants_in_common' | 'tenants_by_entireties' | 'sole' | 'trust';
  ownershipPercentage?: number; // For tenants in common

  // Financing
  isFinancing: boolean;
  preApprovalAmount?: number;
  lenderId?: string;

  // Preferences
  communicationPrefs: CommunicationPreferences;

  // Timestamps
  addedAt: Date;
  updatedAt: Date;
}
```

## Florida-Specific Considerations

### Vesting Options
- **Tenants by the Entireties**: Married couples only, provides asset protection
- **Joint Tenants with Rights of Survivorship**: Unmarried co-buyers
- **Tenants in Common**: Ownership percentage can differ

### Financing Types
- Conventional
- FHA (Federal Housing Administration)
- VA (Veterans Affairs)
- USDA
- Cash

### Required Disclosures to Buyer
- Lead-based paint (pre-1978 homes)
- HOA documents (condo/HOA properties)
- Seller's disclosures
- Survey
- Title commitment

## Integration Points

### Document Skills
- Buyer signs: Contract, disclosures, closing docs
- Buyer receives: Title commitment, survey, HOA docs

### Deadline Skills
- Inspection period tied to buyer decision
- Financing contingency requires buyer's lender
- Walk-through scheduled with buyer

### Communication Skills
- Status updates default to buyer
- Deadline reminders prioritize buyer action items
- Document requests route to buyer for signatures

## Quality Checklist

- [x] Full legal name captured correctly
- [x] Vesting type discussed and documented
- [x] Financing status and lender captured
- [x] Communication preferences set
- [x] Current address on file (for contract)
- [x] Co-buyers properly configured
- [x] Entity buyers have entity documentation noted
- [x] Pre-approval attached if financing

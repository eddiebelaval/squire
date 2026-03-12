# Party Type: Attorney

**Role Code:** `attorney`
**Category:** Advisory Party
**Typical Count:** 0-2 per deal (optional)

## Overview

Attorneys may represent buyers or sellers in Florida real estate transactions. While Florida does not require attorney involvement (unlike some states), parties often engage attorneys for complex transactions, estate sales, commercial deals, or when disputes arise. Attorneys review contracts, advise on legal issues, and may attend closing.

## Role Definition

### Who Is This Party?
- Licensed Florida Bar attorney
- Represents buyer, seller, or both (with consent)
- Reviews legal documents
- Provides legal advice on transaction
- May handle closing (as closing agent)

### Common Configurations
| Type | Description | Example |
|------|-------------|---------|
| Buyer's Attorney | Represents buyer | John Smith, Esq. |
| Seller's Attorney | Represents seller | Jane Doe, P.A. |
| Closing Attorney | Handles closing | Acting as title agent |
| Transaction Attorney | Represents both | With disclosure |
| Estate Attorney | For estate sales | Probate matters |

## Contact Requirements

### Required Information
| Field | Required | Reason |
|-------|----------|--------|
| Attorney Name | Yes | Primary contact |
| Firm Name | Yes | Professional identification |
| Email | Yes | Document delivery |
| Phone | Yes | Consultations |
| Bar Number | Yes | License verification |

### Optional Information
| Field | When Needed |
|-------|-------------|
| Paralegal Contact | For admin matters |
| Fax | Some attorneys prefer |
| Specialty | Estate, litigation, etc. |

## Key Deadlines Involving Attorney

| Deadline | Attorney's Role | Action Required |
|----------|----------------|-----------------|
| Contract Review | Review before signing | Early involvement |
| Inspection Period | Advise on findings | Before deadline |
| Title Review | Review commitment | Within review period |
| Closing | May attend | Day of closing |

## Typical Communications

### With Attorney

| Type | Frequency | Purpose |
|------|-----------|---------|
| Document Sharing | As executed | Keep attorney informed |
| Consultation Request | As issues arise | Legal questions |
| Title Issues | If found | Legal resolution |
| Closing Coordination | If attending | Schedule and documents |

### Communication Templates

**Attorney Introduction:**
> Subject: New Transaction - [Client Name] - [Address]
>
> Dear [Attorney Name],
>
> I'm reaching out regarding a real estate transaction for your client, [Client Name], who is the [buyer/seller] in the purchase of:
>
> Property: [Address]
> Purchase Price: $[Amount]
> Effective Date: [Date]
> Closing Date: [Date]
>
> Attached please find the executed contract for your review.
>
> Please let me know if you have any questions or need additional documents. I look forward to working with you on this transaction.

**Legal Issue Escalation:**
> Subject: Title Issue - [Address] - Need Legal Review
>
> Dear [Attorney Name],
>
> A title issue has been identified that may require legal attention:
>
> Issue: [Description of issue]
> Discovered By: [Title Company]
> Impact: [How it affects closing]
>
> Attached is the title commitment highlighting the issue.
>
> Please advise on next steps. Our closing deadline is [Date].

## Voice Command Examples

### Adding Attorney
```
"The buyer has an attorney - John Smith from Smith Law"
"Add seller's attorney Jane Doe, bar number 123456"
"Attorney is handling the estate sale"
```

### Attorney Queries
```
"Who is the buyer's attorney?"
"What's the attorney's email?"
"Has the attorney reviewed the contract?"
"Get me the attorney's phone number"
```

### Attorney Actions
```
"Send contract to the attorney"
"Email the attorney about the title issue"
"CC the attorney on all communications"
"Ask the attorney about the closing"
```

## Schema

```typescript
interface Attorney {
  // Identity
  id: string;
  role: 'attorney';
  representingRole: 'buyer' | 'seller' | 'both' | 'estate' | 'closing_agent';

  // Attorney Info
  firstName: string;
  lastName: string;
  suffix?: string;  // Esq., J.D., P.A.
  barNumber: string;
  barState: string;

  // Firm Info
  firmName: string;
  firmAddress: Address;
  firmPhone: string;
  firmFax?: string;
  firmWebsite?: string;

  // Contact
  email: string;
  directPhone?: string;
  mobilePhone?: string;

  // Support Staff
  paralegalName?: string;
  paralegalEmail?: string;
  paralegalPhone?: string;

  assistantName?: string;
  assistantEmail?: string;
  assistantPhone?: string;

  // Specialty
  specialty?: string[];  // real estate, probate, litigation

  // Involvement Level
  reviewOnly: boolean;  // Just reviews docs
  attendingClosing: boolean;
  handlingClosing: boolean;  // Acting as closing agent

  // Contract Review
  contractReviewed?: boolean;
  contractApproved?: boolean;
  contractModifications?: string[];

  // Communications
  ccOnAllComms: boolean;
  copyParalegal: boolean;

  // Preferences
  communicationPrefs: CommunicationPreferences;
  preferredDocFormat?: 'pdf' | 'word' | 'both';

  // Timestamps
  addedAt: Date;
  updatedAt: Date;
}
```

## Florida-Specific Considerations

### Attorney Not Required
- Florida does not require attorney at closing
- Title companies typically handle closings
- Attorney involvement is optional but sometimes advised

### When Attorney is Recommended
| Situation | Reason |
|-----------|--------|
| Estate Sale | Probate issues, authority questions |
| Commercial Property | Complex terms, due diligence |
| Short Sale | Lender negotiations |
| Title Defects | Legal resolution needed |
| Contract Disputes | Negotiation, potential litigation |
| Foreign Buyer/Seller | FIRPTA, special requirements |
| Entity Purchases | LLC/Corp documentation |
| Divorce Situations | Authority, proceeds distribution |

### Attorney-Handled Closings
Some attorneys act as closing agent:
- Usually in North Florida (more common)
- Acts as title agent and attorney
- May provide title insurance
- Full service closing

### Florida Bar Requirements
- Must be in good standing with Florida Bar
- May need to verify specialty (board certified)
- Attorney-client privilege applies

## Integration Points

### Document Skills
- Contract delivery to attorney
- Amendment review requests
- Closing document preparation

### Communication Skills
- Attorney CC preferences
- Consultation scheduling
- Document delivery tracking

### Deadline Skills
- Attorney review periods
- Response deadlines

## Attorney Involvement Levels

### Review Only
```typescript
{
  reviewOnly: true,
  attendingClosing: false,
  handlingClosing: false,

  // Typical workflow:
  // 1. Send contract for review
  // 2. Attorney provides feedback
  // 3. Client decides on modifications
  // 4. Attorney available for questions
}
```

### Active Representation
```typescript
{
  reviewOnly: false,
  attendingClosing: true,
  handlingClosing: false,

  // Typical workflow:
  // 1. Attorney reviews all documents
  // 2. Attorney negotiates on client's behalf
  // 3. CC attorney on all transaction comms
  // 4. Attorney attends closing with client
}
```

### Closing Agent
```typescript
{
  reviewOnly: false,
  attendingClosing: true,
  handlingClosing: true,

  // Attorney acts as title/closing agent:
  // 1. Conducts title search
  // 2. Issues title insurance
  // 3. Prepares closing documents
  // 4. Conducts closing
  // 5. Handles recording and disbursement
}
```

## Estate Sale Considerations

When attorney represents estate:
```typescript
{
  representingRole: 'estate',
  specialty: ['probate', 'real_estate'],

  // Required items:
  requiredDocs: [
    'Letters of Administration',
    'Death Certificate',
    'Court Authority (if needed)',
    'Heir Waivers (if applicable)'
  ],

  // May need court approval:
  courtApprovalRequired: boolean,
  probateCaseNumber: string,
  probateCourt: string
}
```

## Communication Best Practices

### When Working with Attorney
- Always CC attorney as they request
- Provide clean PDF documents
- Summarize key issues clearly
- Respect attorney-client privilege
- Route legal questions through attorney

### When Issues Arise
```
Escalation Path:
1. Identify the legal issue
2. Document the facts
3. Notify attorney with supporting docs
4. Let attorney advise client
5. Follow attorney's guidance
6. Document resolution
```

## Quality Checklist

- [x] Attorney bar number verified
- [x] Firm and direct contact info complete
- [x] Representing party clearly identified
- [x] Involvement level established
- [x] CC preferences configured
- [x] Paralegal/assistant contacts if applicable
- [x] Contract review status tracked
- [x] Closing attendance confirmed if applicable
- [x] Specialty noted (estate, commercial, etc.)
- [x] Document format preferences noted

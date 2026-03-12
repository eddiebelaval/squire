# Party Type: HOA

**Role Code:** `hoa`
**Category:** Vendor Party
**Typical Count:** 0-2 per deal (if applicable)

## Overview

The HOA (Homeowners Association) or Condominium Association governs the community where the property is located. They maintain common areas, enforce rules, and collect dues. In Florida, associations must provide disclosure documents to buyers, and the buyer typically has a right to cancel after receiving them.

## Role Definition

### Who Is This Party?
- The association governing the community
- May be managed by a management company
- Provides estoppel letter and HOA documents
- Collects dues and special assessments

### Common Configurations
| Type | Description | Example |
|------|-------------|---------|
| HOA Only | Single-family community | Oak Estates HOA |
| Condo Association | Condominium building | Miami Tower Condo Assn |
| Master + Sub | Community within community | Master HOA + Building HOA |
| Self-Managed | No management company | Board-managed directly |
| Professionally Managed | Uses mgmt company | Via FirstService, ABM |

## Contact Requirements

### Required Information
| Field | Required | Reason |
|-------|----------|--------|
| Association Name | Yes | Document requests |
| Management Company | If applicable | Primary contact |
| Contact Name | Yes | Document orders |
| Phone | Yes | Follow-up |
| Email | Yes | Document delivery |

### Optional Information
| Field | When Needed |
|-------|-------------|
| Monthly Dues | For buyer budgeting |
| Special Assessments | If pending |
| Portal Access | For seller docs |
| Estoppel Fee | For closing costs |

## Key Deadlines Involving HOA

| Deadline | HOA's Role | Action Required |
|----------|-----------|-----------------|
| HOA Docs Requested | Provide docs | Order early |
| Doc Delivery | Deliver within 10 days | FL law requirement |
| Buyer Review Period | N/A | 3 days to cancel |
| Estoppel Request | Provide estoppel | Order for closing |
| Estoppel Delivery | Deliver | Usually 10-15 days |
| Transfer Fee | Process | Paid at closing |

## Typical Communications

### With HOA/Management

| Type | Frequency | Purpose |
|------|-----------|---------|
| HOA Doc Request | Once | Obtain disclosures |
| Estoppel Request | Once | Obtain for closing |
| Status Follow-up | As needed | Track delivery |
| Transfer Application | Once | New owner registration |

### Communication Templates

**HOA Document Request:**
> Subject: HOA Document Request - [Address]
>
> To: [HOA Management Company]
>
> Please provide the required HOA/Condo documents for:
>
> Property: [Address]
> Unit/Lot: [If applicable]
> Seller: [Seller Name]
>
> Documents Needed:
> - Declaration/Covenants (CC&Rs)
> - Articles of Incorporation
> - Bylaws
> - Rules and Regulations
> - Current Year Budget
> - Financial Statements
> - FAQ (if available)
> - Meeting Minutes (most recent)
>
> Please send to: [Email]
>
> This is for a real estate transaction with closing scheduled for [Date].

**Estoppel Request:**
> Subject: Estoppel Letter Request - [Address]
>
> To: [HOA Management Company]
>
> Please provide an estoppel letter for:
>
> Property: [Address]
> Seller: [Seller Name]
> Closing Date: [Date]
> Title Company: [Title Company Name]
>
> Send To: [Title Company Email]
> CC: [Agent Email]
>
> Payment: [Seller credit card / Bill to closing / Other]
>
> Thank you for your prompt attention.

## Voice Command Examples

### Adding HOA
```
"The HOA is Oak Estates Homeowners Association"
"Add FirstService as the management company"
"HOA contact is Jennifer at 305-555-1000"
"This is a condo, add the condo association"
```

### HOA Queries
```
"What are the monthly HOA dues?"
"Who is the HOA management company?"
"Has the HOA doc been ordered?"
"When will we get the estoppel?"
```

### HOA Actions
```
"Order the HOA documents"
"Email the HOA for the estoppel"
"Follow up on HOA doc delivery"
"Check if there are any special assessments"
```

## Schema

```typescript
interface HOA {
  // Identity
  id: string;
  role: 'hoa';
  hoaType: 'hoa' | 'condo' | 'master' | 'sub';

  // Association Info
  associationName: string;
  isSelfManaged: boolean;

  // Management Company (if applicable)
  managementCompany?: string;
  managementContact?: string;
  managementEmail?: string;
  managementPhone?: string;
  managementAddress?: Address;

  // Direct Association Contact (if self-managed)
  boardContact?: string;
  boardEmail?: string;
  boardPhone?: string;

  // Fees
  monthlyDues: number;
  duesFrequency?: 'monthly' | 'quarterly' | 'annually';
  specialAssessments?: {
    amount: number;
    purpose: string;
    remainingPayments: number;
  }[];

  // HOA Documents
  docsRequested: boolean;
  docsRequestedDate?: Date;
  docsReceivedDate?: Date;
  docsDeliveredToBuyer?: boolean;
  buyerCancelDeadline?: Date;  // 3 days after delivery

  // Estoppel
  estoppelRequested: boolean;
  estoppelRequestedDate?: Date;
  estoppelReceivedDate?: Date;
  estoppelFee?: number;
  estoppelBalance?: number;  // Amount due at closing

  // Property Details
  hasClubhouse?: boolean;
  hasPool?: boolean;
  hasGym?: boolean;
  hasSecurity?: boolean;
  rentingRestrictions?: string;
  petRestrictions?: string;

  // Status
  sellerCurrent: boolean;  // Is seller current on dues?
  pendingViolations?: string[];

  // Portal Access
  portalUrl?: string;

  // Preferences
  communicationPrefs: CommunicationPreferences;

  // Timestamps
  addedAt: Date;
  updatedAt: Date;
}
```

## Florida-Specific Considerations

### HOA Disclosure Requirements
Florida Statute 720.401 requires:
- Disclosure summary before contract or 3-day rescission
- Must disclose if community is governed by HOA
- Assessments, fees, and restrictions

### Condo Disclosure Requirements
Florida Statute 718.503 requires seller to provide:
- Declaration of Condominium
- Articles of Incorporation
- Bylaws
- Rules and Regulations
- Current year's annual budget
- Financial statement
- FAQ (if available)

### Buyer Cancellation Rights
- **Resale Condos**: 3 days after receiving documents
- **HOA Communities**: 3 days after receiving documents
- Must be in writing
- Full deposit refund

### Estoppel Letters
- Association must provide within 10 business days (condo) or 10 days (HOA)
- Shows balance due, special assessments, violations
- Title company relies on for closing
- Fee capped by statute

### Approval Requirements
Some associations require:
- Buyer application and approval
- Background checks
- Interviews
- May delay closing if not approved

## Integration Points

### Deadline Skills
- HOA document delivery tracking
- Buyer cancellation window
- Estoppel timing

### Document Skills
- HOA docs storage
- Estoppel filing
- Delivery confirmation

### Communication Skills
- HOA doc request templates
- Estoppel request templates
- Follow-up tracking

## HOA Document Workflow

```
Property Has HOA/Condo
         │
         ▼
Request HOA Documents (Day 1)
         │
         ▼
Await Delivery (10 business days)
         │
         ▼
Receive Documents
         │
         ▼
Deliver to Buyer
         │
         ▼
Buyer Review Period (3 days)
         │
         ├─── Buyer Cancels ──► Return Deposit
         │
         └─── Buyer Accepts (or no response) ──► Continue Transaction
```

## Estoppel Workflow

```
Closing Scheduled
         │
         ▼
Order Estoppel (2-3 weeks before)
         │
         ├─── Self-Managed: Contact Board
         │
         └─── Mgmt Company: Submit Request + Fee
                   │
                   ▼
         Estoppel Processing (10-15 days)
                   │
                   ▼
         Estoppel Received
                   │
                   ▼
         Forward to Title Company
                   │
                   ▼
         Title Uses for Closing Statement
```

## Quality Checklist

- [x] HOA/Condo association identified correctly
- [x] Management company contact info complete
- [x] Monthly dues amount documented
- [x] Special assessments noted if any
- [x] HOA docs ordered early in transaction
- [x] HOA docs delivered to buyer with tracking
- [x] Buyer cancellation deadline tracked
- [x] Estoppel ordered 2-3 weeks before closing
- [x] Estoppel forwarded to title company
- [x] Rental/pet restrictions noted for buyer
- [x] Approval requirement status tracked

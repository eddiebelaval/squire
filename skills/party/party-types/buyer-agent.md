# Party Type: Buyer's Agent

**Role Code:** `buyer_agent`
**Category:** Agent Party
**Typical Count:** 1 per deal

## Overview

The buyer's agent represents the buyer in the transaction. They are responsible for helping the buyer find property, negotiate on their behalf, and guide them through the purchase. In Florida, buyer's agents work under a buyer-broker agreement and owe fiduciary duties to the buyer.

## Role Definition

### Who Is This Party?
- Licensed real estate agent/broker representing the buyer
- May have buyer-broker agreement
- Introduces buyer to property
- Owes fiduciary duties to buyer

### Common Configurations
| Type | Description | Example |
|------|-------------|---------|
| Single Agent | One buyer's agent | Mike Chen, XYZ Realty |
| Team Lead | Team represents buyer | Mike Chen Team |
| Referral | Referred from another agent | Referral from out-of-area |
| Dual Agent | Same agent as listing | Transaction broker |

## Contact Requirements

### Required Information
| Field | Required | Reason |
|-------|----------|--------|
| Full Name | Yes | Communication, commission |
| Email | Yes | Primary communication |
| Phone | Yes | Urgent matters |
| License Number | Yes | Compliance verification |
| Brokerage | Yes | Commission payment |

### Optional Information
| Field | When Needed |
|-------|-------------|
| Assistant Contact | If agent uses assistant |
| TC Contact | If transaction coordinator involved |
| Referral Agent | If referral deal |
| Preferred Communication | Agent's preference |

## Key Deadlines Involving Buyer's Agent

| Deadline | Agent's Role | Action Required |
|----------|--------------|-----------------|
| Contract Submission | Submit offer | Prepare and deliver offer |
| Escrow Deposit | Ensure delivery | Track buyer's deposit |
| Inspections | Coordinate | Schedule all inspections |
| Repair Request | Advise buyer | Present findings/negotiate |
| Financing | Monitor | Track buyer's loan progress |
| Walk-Through | Attend with buyer | Conduct final inspection |
| Closing | Attend | Support buyer at closing |

## Typical Communications

### With Buyer's Agent (as Listing Agent)

| Type | Frequency | Purpose |
|------|-----------|---------|
| Offer Response | As received | Counter/accept/reject |
| Inspection Access | As scheduled | Property access |
| Repair Response | Per deadline | Seller's position |
| Status Updates | As needed | Transaction progress |
| Closing Coordination | Near close | Final details |

### Communication Templates

**Counter Offer:**
> Subject: Counter Offer - [Address]
>
> Hi [Buyer's Agent Name],
>
> Thank you for your buyer's offer on [Address]. After reviewing with my seller, please find attached our counter offer.
>
> Key Changes:
> - Purchase Price: $[Amount]
> - Closing Date: [Date]
> - [Other terms]
>
> Please present to your buyer and let us know their decision.

**Repair Response:**
> Subject: Seller's Response to Repair Request - [Address]
>
> Hi [Buyer's Agent Name],
>
> My seller has reviewed the repair request. Their response is attached.
>
> Summary:
> - Agreed Items: [List]
> - Declined Items: [List]
> - Alternative Offered: [If any]
>
> Please advise how your buyer wishes to proceed.

## Voice Command Examples

### Adding Buyer's Agent
```
"The buyer's agent is Mike Chen at XYZ Realty"
"Add the cooperating agent from the offer"
"Mike Chen, license 654321, represents the buyer"
```

### Buyer's Agent Queries
```
"Who is the buyer's agent?"
"Get the buyer's agent phone number"
"Email for the selling agent"
"Who is the cooperating broker?"
```

### Buyer's Agent Actions
```
"Send the counter offer to the buyer's agent"
"Email the buyer's agent about access"
"Call the cooperating agent"
"Ask the buyer's agent about financing status"
```

## Schema

```typescript
interface BuyerAgent {
  // Identity
  id: string;
  role: 'buyer_agent';

  // Personal Info
  firstName: string;
  lastName: string;
  nickname?: string;

  // Contact
  email: string;
  phone: string;
  phoneType?: 'mobile' | 'office';
  fax?: string;

  // Professional Info
  licenseNumber: string;
  licenseState: string;
  licenseExpiration?: Date;

  // Brokerage
  brokerageName: string;
  brokerageAddress?: Address;
  brokeragePhone?: string;
  brokerageLicense?: string;

  // Team
  isTeam?: boolean;
  teamName?: string;

  // Support Staff
  hasAssistant?: boolean;
  assistantName?: string;
  assistantEmail?: string;

  hasTransactionCoordinator?: boolean;
  tcName?: string;
  tcEmail?: string;
  tcPhone?: string;

  // Referral
  isReferral?: boolean;
  referralAgent?: {
    name: string;
    brokerage: string;
    referralFee: string;
  };

  // Commission
  commissionExpected?: string;
  buyerBrokerAgreement?: boolean;

  // Preferences
  preferredCommunication: 'email' | 'phone' | 'text';

  // Timestamps
  addedAt: Date;
  updatedAt: Date;
}
```

## Florida-Specific Considerations

### Buyer-Broker Agreements
- Not always required in Florida
- Commission may be paid from listing
- NAR settlement changes affecting buyer agreements

### Agency Disclosure
- Florida requires agency disclosure
- Transaction broker common in Florida
- Single agent relationship available

### Commission Considerations
- Typically paid from listing side
- Buyer-broker agreement may guarantee
- Negotiable between brokerages

### Dual Agency / Transaction Broker
- If same brokerage as listing, may be transaction broker
- Limited representation for both parties
- Requires disclosure and consent

## Integration Points

### Document Skills
- Receives: Seller responses, disclosures, closing info
- Provides: Offers, repair requests, buyer docs

### Deadline Skills
- Tracks all buyer deadlines
- Coordinates inspection scheduling
- Monitors financing timeline

### Communication Skills
- Offer/counter negotiations
- Inspection coordination
- Status updates to/from
- Closing coordination

## If You Are the Buyer's Agent

When the current user is the buyer's agent:

```typescript
{
  role: 'buyer_agent',
  isSelf: true,

  // Auto-filled from user profile
  firstName: currentUser.firstName,
  lastName: currentUser.lastName,
  email: currentUser.email,
  phone: currentUser.phone,
  licenseNumber: currentUser.licenseNumber,
  brokerageName: currentUser.brokerage
}
```

In this case:
- Don't prompt for buyer's agent info (it's you)
- Focus communications on other parties
- Dashboard shows buyer-centric view
- Track your buyer's deadlines prominently

## Working Relationship Best Practices

### Communication Standards
- Respond within business hours
- Confirm receipt of documents
- Document all negotiations in writing

### Coordination Points
```
Key Coordination:
- Inspection scheduling (need access)
- Repair negotiation (back and forth)
- Financing updates (may affect closing)
- Walk-through scheduling
- Closing time coordination
```

## Quality Checklist

- [x] License verified as active
- [x] Correct brokerage on file
- [x] Direct contact info (not just office)
- [x] Commission expectation documented
- [x] TC/Assistant contacts if applicable
- [x] Buyer-broker agreement status noted
- [x] Referral details if applicable
- [x] Agency relationship confirmed

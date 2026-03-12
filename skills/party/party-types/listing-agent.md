# Party Type: Listing Agent

**Role Code:** `listing_agent`
**Category:** Agent Party
**Typical Count:** 1 per deal

## Overview

The listing agent represents the seller in the transaction. They are responsible for marketing the property, negotiating on behalf of the seller, and coordinating the sale through closing. In Florida, listing agents work under a listing agreement and owe fiduciary duties to the seller.

## Role Definition

### Who Is This Party?
- Licensed real estate agent/broker representing the seller
- Holds the listing agreement
- Member of the MLS
- Owes fiduciary duties to seller

### Common Configurations
| Type | Description | Example |
|------|-------------|---------|
| Single Agent | One listing agent | Jane Smith, ABC Realty |
| Team Lead | Team handles listing | Jane Smith Team |
| Co-List | Two agents share listing | Jane Smith & John Doe |
| Transaction Coord | Agent + TC support | Agent delegates admin |

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
| Team Name | If part of team |
| Preferred Communication | Agent's preference |

## Key Deadlines Involving Listing Agent

| Deadline | Agent's Role | Action Required |
|----------|--------------|-----------------|
| Contract Execution | Deliver to all parties | Distribute executed contract |
| Inspection Period | Coordinate access | Schedule inspections |
| Repair Response | Advise seller | Present repair requests |
| Title Review | Monitor progress | Ensure clear title |
| Closing | Coordinate with all | Ensure successful close |

## Typical Communications

### With Listing Agent (as Buyer's Agent)

| Type | Frequency | Purpose |
|------|-----------|---------|
| Offer Submission | As made | Presenting buyer's offer |
| Inspection Access | Once | Schedule inspections |
| Repair Negotiation | As needed | Negotiate repairs |
| Status Checks | Weekly | Transaction progress |
| Closing Coordination | Near close | Final details |

### Communication Templates

**Offer Submission:**
> Subject: Offer Submitted - [Address]
>
> Hi [Listing Agent Name],
>
> Please find attached an offer from my buyer for the property at [Address].
>
> Offer Highlights:
> - Purchase Price: $[Amount]
> - Earnest Money: $[Amount]
> - Financing: [Type]
> - Closing Date: [Date]
> - Contingencies: [List]
>
> My buyer is [brief qualification]. We look forward to your response.

**Inspection Request:**
> Subject: Inspection Scheduling - [Address]
>
> Hi [Listing Agent Name],
>
> We'd like to schedule the following inspections:
>
> - General Home Inspection: Preferred [Date/Time]
> - Wood Destroying Organism: Same time
> - [Other inspections]
>
> Inspector: [Company Name], Contact: [Number]
>
> Please confirm the property will be accessible and utilities on.

## Voice Command Examples

### Adding Listing Agent
```
"The listing agent is Sarah Johnson at ABC Realty"
"Sarah Johnson, license number 123456, is the listing agent"
"Add listing agent from the contract"
```

### Listing Agent Queries
```
"Who is the listing agent?"
"Get the listing agent's phone number"
"What's the other agent's email?"
"Call the listing agent"
```

### Listing Agent Actions
```
"Email the listing agent about inspections"
"Send the repair request to the listing agent"
"Ask the listing agent about showing feedback"
"Schedule a call with the listing agent"
```

## Schema

```typescript
interface ListingAgent {
  // Identity
  id: string;
  role: 'listing_agent';

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
  teamMembers?: TeamMember[];

  // Support Staff
  hasAssistant?: boolean;
  assistantName?: string;
  assistantEmail?: string;
  assistantPhone?: string;

  hasTransactionCoordinator?: boolean;
  tcName?: string;
  tcEmail?: string;
  tcPhone?: string;

  // Commission
  commissionSplit?: string; // e.g., "3%"

  // Preferences
  preferredCommunication: 'email' | 'phone' | 'text';
  bestTimeToReach?: string;

  // History
  previousDealsWithAgent?: number;
  notes?: string;

  // Timestamps
  addedAt: Date;
  updatedAt: Date;
}
```

## Florida-Specific Considerations

### License Verification
- Verify active license with DBPR
- Check for disciplinary actions
- Confirm brokerage affiliation

### Fiduciary Duties
- Listing agent owes duties to seller
- Must disclose material facts
- Cannot share confidential info with buyer

### Agency Disclosure
- Florida requires agency disclosure
- Transaction broker is common
- Single agent representation available

### Commission
- Typically offered through MLS
- Buyer's agent commission from listing
- Negotiate if needed

## Integration Points

### Document Skills
- Listing agent receives: Offers, repair requests, disclosures
- Listing agent provides: Contract, disclosures, amendments

### Deadline Skills
- Coordinate inspection access
- Relay seller responses
- Track title/closing progress

### Communication Skills
- Formal offer submission
- Negotiation correspondence
- Status updates
- Closing coordination

## Working Relationship Best Practices

### Building Rapport
- Professional, timely communication
- Follow MLS/association rules
- Document all agreements in writing

### Conflict Resolution
```
Common Issues:
- Inspection access delays → Escalate to broker
- Response time issues → Document and follow up
- Commission disputes → Involve brokers early
- Repair negotiations → Keep factual, avoid emotional
```

### Documentation
- Keep all communications in writing
- Use transaction platform for tracking
- Screenshot MLS data at contract time

## Quality Checklist

- [x] License verified as active
- [x] Correct brokerage on file
- [x] Direct phone number (not just office)
- [x] Email confirmed valid
- [x] Commission terms documented
- [x] TC/Assistant contacts if applicable
- [x] Preferred communication method noted
- [x] Previous relationship history captured
- [x] MLS member verification

# Party Type: Insurance Agent

**Role Code:** `insurance_agent`
**Category:** Vendor Party
**Typical Count:** 1 per deal

## Overview

The insurance agent provides homeowners/hazard insurance for the property. In Florida, property insurance is particularly critical due to hurricane exposure, and obtaining coverage can be challenging in some areas. Lenders require proof of insurance before closing, making this party essential for financed transactions.

## Role Definition

### Who Is This Party?
- Licensed insurance agent or broker
- Provides hazard/homeowners insurance quote
- Binds coverage for closing
- May also provide flood insurance

### Common Configurations
| Type | Description | Example |
|------|-------------|---------|
| Insurance Agent | Independent agent | John Smith Insurance |
| Insurance Broker | Shops multiple carriers | ABC Insurance Brokers |
| Captive Agent | Single carrier only | State Farm Agent |
| Direct Writer | Company direct | GEICO, Progressive |

## Contact Requirements

### Required Information
| Field | Required | Reason |
|-------|----------|--------|
| Agent/Agency Name | Yes | Primary contact |
| Phone | Yes | Quotes, questions |
| Email | Yes | Documentation |
| License Number | Yes | Verification |

### Optional Information
| Field | When Needed |
|-------|-------------|
| Carrier Name | When quoted |
| Policy Number | When bound |
| Premium Amount | For closing costs |
| Binder | Required for closing |

## Key Deadlines Involving Insurance Agent

| Deadline | Agent's Role | Action Required |
|----------|--------------|-----------------|
| Insurance Quote | Provide options | Early in transaction |
| 4-Point Inspection | May require | For older homes |
| Wind Mitigation | May reduce premium | Before binding |
| Proof of Insurance | Provide binder | Before closing |
| Flood Insurance | If in flood zone | Before closing |

## Typical Communications

### With Insurance Agent

| Type | Frequency | Purpose |
|------|-----------|---------|
| Quote Request | Once | Get premium options |
| Application | Once | Submit for policy |
| 4-Point/Wind Mit | If needed | Additional inspections |
| Bind Request | Once | Finalize coverage |
| Binder Delivery | Once | Send to lender/title |

### Communication Templates

**Quote Request:**
> Subject: Insurance Quote Needed - [Address]
>
> Hi [Agent Name],
>
> I have a buyer who needs homeowners insurance for:
>
> Property: [Address]
> Purchase Price: $[Amount]
> Closing Date: [Date]
> Property Type: [Single Family / Condo / Townhouse]
> Year Built: [Year]
> Roof Age: [Years]
> Pool: [Yes/No]
> Construction: [CBS/Frame/Other]
>
> Buyer: [Name]
> Buyer Phone: [Number]
> Buyer Email: [Email]
>
> Please provide quote options. Note: Lender requires evidence of insurance before closing.

**Binder Request:**
> Subject: Bind Coverage - [Address]
>
> Hi [Agent Name],
>
> Please bind the [Carrier] policy for [Address].
>
> Closing Date: [Date]
> Effective Date: [Closing Date]
>
> Please send the binder to:
> - Lender: [Lender Email]
> - Title: [Title Email]
> - Me: [Your Email]
>
> Payment: [First year at closing / Monthly]

## Voice Command Examples

### Adding Insurance Agent
```
"Insurance agent is Mike at State Farm"
"Add ABC Insurance for the buyer's policy"
"The insurance quote is from Citizens"
```

### Insurance Queries
```
"Who is the insurance agent?"
"What's the annual premium?"
"Has insurance been bound?"
"Did we get the binder?"
```

### Insurance Actions
```
"Email the insurance agent for a quote"
"Send property details to insurance"
"Request the insurance binder"
"Forward binder to the lender"
```

## Schema

```typescript
interface InsuranceAgent {
  // Identity
  id: string;
  role: 'insurance_agent';

  // Agency Info
  agencyName: string;
  isBroker: boolean;

  // Agent Info
  agentName: string;
  email: string;
  phone: string;
  licenseNumber?: string;

  // Quote Status
  quoteRequested: boolean;
  quoteReceivedDate?: Date;

  // Policy Details
  carrier?: string;
  policyType?: 'ho3' | 'ho6' | 'dp1' | 'dp3' | 'other';
  annualPremium?: number;
  deductible?: number;
  hurricaneDeductible?: number;
  coverageAmount?: number;

  // Status
  applicationSubmitted?: boolean;
  policyBound?: boolean;
  binderReceived?: boolean;
  binderSentToLender?: boolean;
  binderSentToTitle?: boolean;

  // Policy Numbers
  policyNumber?: string;
  effectiveDate?: Date;

  // Flood Insurance (if separate)
  floodRequired?: boolean;
  floodCarrier?: string;
  floodPremium?: number;
  floodPolicyNumber?: string;

  // Documents
  binderUrl?: string;
  quoteUrl?: string;

  // Preferences
  communicationPrefs: CommunicationPreferences;

  // Timestamps
  addedAt: Date;
  updatedAt: Date;
}
```

## Florida-Specific Considerations

### Insurance Market Challenges
- Many carriers have left Florida market
- Citizens is insurer of last resort
- Premiums have increased significantly
- Some areas hard to insure

### Common Florida Carriers
| Carrier | Notes |
|---------|-------|
| Citizens | State-run, last resort |
| Universal | Florida-focused |
| Federated National | Florida-focused |
| Heritage | Florida-focused |
| People's Trust | Florida-focused |
| Florida Peninsula | Florida-focused |

### Required Coverages
- Hazard/Dwelling coverage (at replacement cost)
- Liability coverage
- Hurricane/wind coverage (often separate deductible)
- Flood insurance (if in flood zone)

### 4-Point Inspection
Required by most carriers for homes 25+ years old:
- Roof
- Electrical
- Plumbing
- HVAC

### Wind Mitigation
- Documents hurricane-resistant features
- Can significantly reduce premium
- Hip roof, hurricane straps, shutters, etc.

### Flood Insurance
- Required if in FEMA flood zone A or V
- Buyer can request for any property
- Through NFIP or private carriers

## Integration Points

### Inspector Skills
- 4-point inspection coordination
- Wind mitigation inspection

### Lender Skills
- Binder required for funding
- Coverage amounts verified

### Deadline Skills
- Insurance must be bound before closing
- Binder delivery tracking

### Document Skills
- Binder storage
- Policy document filing

## Insurance Timeline

```
Contract Executed
       │
       ▼
Request Quote (Week 1)
       │
       ▼
Receive Quote Options
       │
       ├─── If 4-Point Needed ──► Order Inspection
       │                              │
       │                              ▼
       │                         Submit to Carrier
       │                              │
       │◄─────────────────────────────┘
       │
       ▼
Buyer Selects Coverage
       │
       ▼
Submit Application
       │
       ▼
Carrier Approval
       │
       ▼
Bind Coverage (Before Closing)
       │
       ▼
Binder to Lender & Title
       │
       ▼
Coverage Effective (Closing Date)
```

## Insurance Challenges

### When Coverage is Difficult
```
Common Issues:
1. Roof too old → May need new roof before coverage
2. Property in high-risk area → Limited carrier options
3. Claims history → Increased premium or denial
4. Vacant property → Specialized policy needed
5. Pool without fence → May need to add fence

Homer Response:
"Insurance is proving challenging for this property because
[reason]. Options include:
- [Option 1]
- [Option 2]
- Citizens Insurance as last resort

Would you like me to help coordinate [next steps]?"
```

### Citizens Insurance
- Florida's insurer of last resort
- Higher premiums, but available when others won't insure
- Buyer must be rejected by other carriers first

## Quality Checklist

- [x] Insurance agent contact info complete
- [x] Quote requested early in transaction
- [x] 4-point/wind mit ordered if needed
- [x] Carrier and premium documented
- [x] Flood zone checked
- [x] Flood insurance arranged if required
- [x] Policy bound before closing
- [x] Binder sent to lender and title
- [x] Policy number recorded
- [x] Premium included in closing costs

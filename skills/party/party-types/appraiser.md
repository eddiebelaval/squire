# Party Type: Appraiser

**Role Code:** `appraiser`
**Category:** Vendor Party
**Typical Count:** 1 per deal (if financing)

## Overview

The appraiser provides an independent assessment of the property's market value for the lender. This is required for all financed transactions. The appraisal protects the lender by ensuring the property is worth at least the loan amount. Since HVCC reforms, agents typically cannot select the appraiser - the lender orders through an AMC (Appraisal Management Company).

## Role Definition

### Who Is This Party?
- State-licensed or certified appraiser
- Independent from the transaction parties
- Ordered by lender (often through AMC)
- Determines fair market value

### Common Configurations
| Type | Description | Example |
|------|-------------|---------|
| Licensed Appraiser | Direct lender order | John Smith, Appraiser |
| AMC-Assigned | Through management company | Via CoreLogic, Clear Capital |
| FHA Roster | FHA-approved appraiser | Required for FHA loans |
| VA Fee Panel | VA-approved appraiser | Required for VA loans |

## Contact Requirements

### Required Information
| Field | Required | Reason |
|-------|----------|--------|
| Company/AMC Name | Yes | Communication |
| Appraiser Name | When assigned | Property access |
| Phone | Yes | Access coordination |
| Email | Yes | Reports, questions |
| License Number | Yes | Verification |

### Optional Information
| Field | When Needed |
|-------|-------------|
| Appointment Date/Time | When scheduled |
| Access Instructions | For property entry |
| Comparable Sales | If providing |

## Key Deadlines Involving Appraiser

| Deadline | Appraiser's Role | Action Required |
|----------|-----------------|-----------------|
| Appraisal Order | Ordered by lender | Usually within 1 week |
| Property Inspection | Visit property | Schedule with access |
| Report Delivery | Complete appraisal | 3-7 days after visit |
| Reconsideration | If value disputed | Review comparables |

## Typical Communications

### With Appraiser/AMC

| Type | Frequency | Purpose |
|------|-----------|---------|
| Access Request | Once | Schedule property visit |
| Comparable Info | Once (optional) | Support value |
| Status Check | As needed | ETA on report |
| Reconsideration | If needed | Dispute value |

### Communication Templates

**Access Confirmation:**
> Subject: Appraisal Access - [Address]
>
> Hi [Appraiser Name],
>
> This confirms your appraisal appointment:
>
> Property: [Address]
> Date: [Date]
> Time: [Time]
>
> Access: [Lockbox code / Occupied - call ahead / Listing agent will meet you]
>
> Please let me know if you have any questions about the property or need to reschedule.

**Comparable Information:**
> Subject: Comparable Sales for [Address]
>
> Hi [Appraiser Name],
>
> For your reference, here are recent comparable sales in the area:
>
> 1. [Address] - Sold [Date] - $[Amount] - [Details]
> 2. [Address] - Sold [Date] - $[Amount] - [Details]
> 3. [Address] - Sold [Date] - $[Amount] - [Details]
>
> Please note: [Upgrades, unique features, etc.]
>
> Let me know if you need any additional information.

## Voice Command Examples

### Adding Appraiser
```
"Appraiser is John Smith from ABC Appraisals"
"The appraisal is through CoreLogic"
"Add appraiser scheduled for Friday"
```

### Appraiser Queries
```
"When is the appraisal?"
"Who is the appraiser?"
"Has the appraisal been completed?"
"What did the property appraise for?"
```

### Appraiser Actions
```
"Email appraiser the access instructions"
"Send comparable sales to the appraiser"
"Check on appraisal status"
"Request reconsideration of value"
```

## Schema

```typescript
interface Appraiser {
  // Identity
  id: string;
  role: 'appraiser';

  // Company Info
  companyName?: string;
  amcName?: string;  // Appraisal Management Company

  // Appraiser Info
  appraiserName?: string;  // May not know until assigned
  email?: string;
  phone?: string;
  licenseNumber?: string;
  licenseType?: 'licensed' | 'certified_residential' | 'certified_general';
  licenseState?: string;

  // Appraisal Details
  appraisalType: AppraisalType;
  orderedBy?: string;  // Lender name
  orderedDate?: Date;

  // Scheduling
  inspectionDate?: Date;
  inspectionTime?: string;
  accessInstructions?: string;

  // Results
  completedDate?: Date;
  appraisedValue?: number;
  conditionRating?: string;
  qualityRating?: string;

  // Value Issues
  valueCameIn: 'at_or_above' | 'below' | 'pending';
  valueShortfall?: number;  // If below purchase price

  // Reconsideration
  reconsiderationRequested?: boolean;
  reconsiderationDate?: Date;
  revisedValue?: number;

  // Report
  reportUrl?: string;

  // Preferences
  communicationPrefs: CommunicationPreferences;

  // Timestamps
  addedAt: Date;
  updatedAt: Date;
}

type AppraisalType =
  | 'full'
  | 'drive_by'
  | 'desktop'
  | 'fha'
  | 'va'
  | 'usda'
  | 'refinance';
```

## Florida-Specific Considerations

### License Types
- **Licensed Appraiser**: Non-complex < $1M
- **Certified Residential**: Residential any value
- **Certified General**: All property types, commercial

### FHA/VA Appraisals
- Must use roster/panel appraiser
- Additional requirements (safety, habitability)
- FHA: Health and safety issues must be corrected
- VA: Similar to FHA, additional veteran protections

### Appraisal Waivers
- Some loans qualify for property inspection waiver (PIW)
- Fannie Mae/Freddie Mac may waive for low LTV refinances
- Not common for purchases

### Flood Zone Impact
- Flood zone affects value
- May require flood insurance
- FEMA map changes can impact

## Integration Points

### Deadline Skills
- Appraisal contingency deadline
- Tied to financing timeline

### Document Skills
- Appraisal report delivery
- Comparables documentation

### Lender Communication
- Ordered by lender
- Results go to lender first
- Agent may not see full report

## Appraisal Value Scenarios

### At or Above Value
```
Appraisal >= Purchase Price

Status: No issues
Action: Proceed normally
Timeline: Continue to closing
```

### Below Value
```
Appraisal < Purchase Price

Options:
1. Seller reduces price to appraisal value
2. Buyer brings additional cash (covers gap)
3. Meet in the middle (split the difference)
4. Buyer cancels (if contingency in place)
5. Request Reconsideration of Value (ROV)

Homer Response:
"The appraisal came in at $[value], which is $[shortfall]
below the purchase price of $[price].

We have these options:
- Ask seller to reduce price
- Buyer covers the $[shortfall] gap
- Split the difference
- Cancel and return deposit (if contingency active)
- Request reconsideration with additional comparables

What would you like to do?"
```

### Reconsideration of Value (ROV)
```
When to Request:
- Recent comparable sales support higher value
- Appraiser missed upgrades or features
- Used inappropriate comparables

Required:
- 3+ comparable sales within 6 months, 1 mile
- Sales should support contract price
- Clear explanation of why original was incorrect

Homer can:
- Pull recent sales for ROV package
- Draft cover letter explaining discrepancy
- Track ROV submission and response
```

## Appraiser Assignment Flow

```
Lender Orders Appraisal
         │
         ▼
AMC Assigns Appraiser
         │
         ▼
Appraiser Contacts for Access
         │
         ▼
Property Inspection (30-60 min)
         │
         ▼
Report Preparation (3-7 days)
         │
         ▼
Report to Lender
         │
         ▼
Value Disclosure to Buyer
         │
         ├─── At Value ──► Proceed
         │
         └─── Below Value ──► Negotiate/ROV/Cancel
```

## Quality Checklist

- [x] AMC or appraiser company identified
- [x] Appraiser name and license when assigned
- [x] Inspection date/time scheduled
- [x] Access instructions provided
- [x] Comparable sales provided (optional but helpful)
- [x] Appraisal value recorded when received
- [x] Value vs. purchase price comparison noted
- [x] ROV filed if needed with tracking
- [x] Report stored in documents
- [x] Timeline impact on financing noted

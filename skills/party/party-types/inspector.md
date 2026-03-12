# Party Type: Inspector

**Role Code:** `inspector`
**Category:** Vendor Party
**Typical Count:** 1-3 per deal

## Overview

Inspectors examine the property and provide reports on its condition. The most common is the general home inspector, but deals may also involve pest inspectors (WDO), pool inspectors, roof inspectors, and other specialists. Inspections are crucial during the inspection contingency period.

## Role Definition

### Who Is This Party?
- Licensed professional who examines property condition
- Provides written report of findings
- Does not make repairs (independent)
- May specialize in specific systems

### Common Inspector Types
| Type | Purpose | When Used |
|------|---------|-----------|
| General Home | Overall condition | Every financed deal |
| WDO/Termite | Wood destroying organisms | Standard in Florida |
| Pool/Spa | Pool condition | If pool on property |
| Roof | Roof condition/life | Older roofs, insurance |
| HVAC | Heating/cooling systems | Older systems |
| Mold | Mold testing | If concerns arise |
| Septic | Septic system | Non-sewer properties |
| Well | Well water quality | Well properties |
| Structural | Foundation/structure | If concerns noted |
| Chimney | Fireplace/chimney | If wood-burning |
| Seawall | Waterfront seawall | Waterfront properties |

## Contact Requirements

### Required Information
| Field | Required | Reason |
|-------|----------|--------|
| Company Name | Yes | Report attribution |
| Inspector Name | Yes | Primary contact |
| Phone | Yes | Scheduling |
| Email | Yes | Report delivery |
| License Number | Yes | Florida requirement |

### Optional Information
| Field | When Needed |
|-------|-------------|
| Specialties | For specialized inspections |
| Insurance Info | If issues arise |
| Availability | Scheduling |

## Key Deadlines Involving Inspector

| Deadline | Inspector's Role | Action Required |
|----------|-----------------|-----------------|
| Inspection Scheduling | Schedule | Within first week |
| Inspection Date | Conduct | Before period ends |
| Report Delivery | Deliver report | Usually same day |
| Reinspection | If requested | After repairs |

## Typical Communications

### With Inspector

| Type | Frequency | Purpose |
|------|-----------|---------|
| Scheduling | Once | Set inspection date |
| Confirmation | Day before | Confirm time/access |
| Report Request | After inspection | Get report |
| Follow-up Questions | As needed | Clarify findings |
| Reinspection | If repairs done | Verify work |

### Communication Templates

**Scheduling Request:**
> Subject: Inspection Request - [Address]
>
> Hi [Inspector Name],
>
> I need to schedule an inspection for:
>
> Property: [Address]
> Type: [General Home / WDO / Pool / etc.]
> Preferred Dates: [Date options]
> Time Frame: [Morning / Afternoon / Flexible]
>
> Inspection period ends: [Date]
>
> Access: [Lockbox code / Contact listing agent / Occupied - call first]
>
> Please confirm availability and provide your fee.

**Report Follow-up:**
> Subject: Inspection Report - [Address]
>
> Hi [Inspector Name],
>
> Thank you for conducting the inspection yesterday. Can you send me the report when ready?
>
> Also, a few questions about the findings:
> - [Question 1]
> - [Question 2]
>
> Please let me know if you need any additional access for follow-up.

## Voice Command Examples

### Adding Inspector
```
"Add ABC Home Inspections as the inspector"
"Inspector is John at Miami Inspections, 305-555-3333"
"Add termite inspection by All Pest Control"
"Schedule an inspection with Mike at Quality Inspections"
```

### Inspector Queries
```
"Who is doing the inspection?"
"What's the inspector's phone?"
"When is the inspection scheduled?"
"Did we get the inspection report?"
```

### Inspector Actions
```
"Call the inspector to schedule"
"Email the inspector for the report"
"Add pool inspection to this deal"
"Schedule reinspection for Friday"
```

## Schema

```typescript
interface Inspector {
  // Identity
  id: string;
  role: 'inspector';

  // Company Info
  companyName: string;
  inspectionType: InspectionType;

  // Inspector Info
  inspectorName: string;
  email: string;
  phone: string;
  licenseNumber: string;
  licenseState: string;

  // Certifications
  certifications?: string[]; // ASHI, InterNACHI, etc.
  specialties?: string[];

  // Scheduling
  inspectionDate?: Date;
  inspectionTime?: string;
  estimatedDuration?: string; // "2-3 hours"

  // Report
  reportDelivered?: boolean;
  reportDeliveryDate?: Date;
  reportUrl?: string;

  // Findings Summary
  majorIssues?: string[];
  minorIssues?: string[];
  safetyIssues?: string[];

  // Reinspection
  reinspectionScheduled?: boolean;
  reinspectionDate?: Date;
  reinspectionPurpose?: string;

  // Fees
  inspectionFee?: number;
  feePaid?: boolean;

  // Preferences
  communicationPrefs: CommunicationPreferences;

  // Timestamps
  addedAt: Date;
  updatedAt: Date;
}

type InspectionType =
  | 'general_home'
  | 'wdo_termite'
  | 'pool'
  | 'roof'
  | 'hvac'
  | 'mold'
  | 'septic'
  | 'well'
  | 'structural'
  | 'chimney'
  | 'seawall'
  | 'radon'
  | '4_point'
  | 'wind_mitigation';
```

## Florida-Specific Considerations

### Required Licenses
- General inspectors: Florida license required
- WDO inspectors: Must be licensed pest control
- Mold assessors: State license required
- Roof inspectors: Often require certification

### 4-Point Inspection
Required by many Florida insurers for homes 25+ years old:
- Roof
- Electrical
- Plumbing
- HVAC

### Wind Mitigation Inspection
- Documents hurricane-resistant features
- Can reduce insurance premiums significantly
- Specific form required by insurers

### WDO (Wood Destroying Organism)
- Standard in Florida transactions
- Looks for termites, wood rot, etc.
- Lenders often require for financing

## Integration Points

### Deadline Skills
- Inspection period deadline
- Reinspection scheduling

### Document Skills
- Inspection report storage
- Repair request based on report

### Communication Skills
- Scheduling coordination
- Report request follow-up
- Reinspection coordination

## Inspection Findings Workflow

```
Inspection Complete
       │
       ▼
Report Delivered ─────────────────────────┐
       │                                   │
       ▼                                   │
Review Findings                            │
       │                                   │
       ├─── No Issues ──► Accept Property  │
       │                                   │
       ├─── Minor Issues ──► Accept As-Is  │
       │                                   │
       ├─── Major Issues ──► Repair Request│
       │                       │           │
       │                       ▼           │
       │            Seller Responds        │
       │                       │           │
       │    ┌──────────────────┼──────┐    │
       │    │                  │      │    │
       │    ▼                  ▼      ▼    │
       │  Agree          Negotiate  Decline│
       │    │                  │      │    │
       │    ▼                  ▼      ▼    │
       │ Repairs Done    Counter  Cancel   │
       │    │                  │           │
       │    ▼                  │           │
       │ Reinspect             │           │
       │    │                  │           │
       └────┴──────────────────┴───────────┘
```

## Multiple Inspectors

When a deal has multiple inspectors:

```typescript
// Add multiple inspection types
const inspections = [
  {
    type: 'general_home',
    company: 'ABC Home Inspections',
    inspector: 'John Smith',
    scheduled: '2026-01-20T09:00',
    fee: 450
  },
  {
    type: 'wdo_termite',
    company: 'Pest Control Plus',
    inspector: 'Mike Johnson',
    scheduled: '2026-01-20T09:00', // Often same time as general
    fee: 100
  },
  {
    type: 'pool',
    company: 'Pool Pros',
    inspector: 'Sarah Lee',
    scheduled: '2026-01-21T10:00',
    fee: 200
  }
];
```

## Quality Checklist

- [x] Inspector license verified
- [x] Correct inspection type identified
- [x] Inspection scheduled within period
- [x] Access arrangements confirmed
- [x] Report received and stored
- [x] Major findings summarized
- [x] Reinspection scheduled if repairs done
- [x] Fee tracked for closing statement
- [x] 4-point/wind mit ordered if needed
- [x] WDO inspection completed for Florida

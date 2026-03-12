# Template: Inspection Reminder

**Category:** Communication > Templates
**Priority:** P0
**Auto-Send Eligible:** Yes (inspection scheduling and deadline reminders)

## Purpose

Templates for inspection-related communications including scheduling reminders, day-of confirmations, post-inspection follow-ups, and repair request notifications. Covers home inspection, pest inspection, pool inspection, and specialty inspections.

## Template Variants

### Email Templates

#### Schedule Inspection Reminder
```
Subject: Schedule Your Home Inspection | {{deal.address.street}}

Hi {{recipient.firstName}},

It's time to schedule your home inspection for {{deal.address.street}}. The sooner we get this done, the more time you'll have to review the report and negotiate any repairs.

**Inspection Timeline:**
- Inspection Contingency Expires: {{inspection.contingencyExpires | formatDate 'long'}}
- Recommended Inspection Date: By {{inspection.recommendedDate | formatDate}}
- Days Remaining to Schedule: {{inspection.daysRemaining}}

**What You Need to Know:**
- Duration: Typically {{inspection.estimatedDuration}}
- Cost: Usually {{inspection.estimatedCost}} (paid directly to inspector)
- Your Attendance: Highly recommended for the last 30-60 minutes

{{#if inspection.recommendedInspectors}}
**Recommended Inspectors:**
{{#each inspection.recommendedInspectors}}
- {{this.name}} - {{this.phone}} - {{this.specialty}}
{{/each}}
{{/if}}

**What to Expect:**
1. Inspector examines structure, systems, and major components
2. You'll receive a detailed written report (usually same day)
3. We'll review together and discuss any concerns
4. If issues found, we can negotiate repairs or credits

{{#if inspection.accessInfo}}
**Property Access:**
{{inspection.accessInfo}}
{{/if}}

Let me know when you've scheduled, and I'll coordinate with the {{#if deal.isListing}}buyer{{else}}seller{{/if}}'s agent.

{{signature}}
```

#### Inspection Scheduled Confirmation
```
Subject: Inspection Confirmed | {{deal.address.street}} - {{inspection.date | formatDate}}

Hi {{recipient.firstName}},

Your home inspection is confirmed for {{deal.address.street}}.

**Inspection Details:**
- Date: {{inspection.date | formatDate 'long'}}
- Time: {{inspection.time}}
- Duration: Approximately {{inspection.duration}}
- Inspector: {{inspection.inspectorName}} from {{inspection.inspectorCompany}}
- Contact: {{inspection.inspectorPhone}}

**Address:**
{{deal.address.full}}

{{#if inspection.specialInstructions}}
**Special Instructions:**
{{inspection.specialInstructions}}
{{/if}}

**Recommended Attendance:**
I suggest arriving about 30-60 minutes before the inspection ends. This gives you time to walk through with the inspector and ask questions. {{#if inspection.arrivalTime}}Plan to arrive around {{inspection.arrivalTime}}.{{/if}}

**What to Bring:**
- Notepad for questions
- Camera/phone for photos
- Comfortable shoes (you'll be walking around)

**Day Of:**
I'll be there to let the inspector in and observe. Feel free to arrive when you can.

{{#if inspection.additionalInspections}}
**Additional Inspections Scheduled:**
{{#each inspection.additionalInspections}}
- {{this.type}}: {{this.date | formatDate}} at {{this.time}} - {{this.inspectorName}}
{{/each}}
{{/if}}

Looking forward to getting you answers about the property!

{{signature}}
```

#### Day-Of Inspection Reminder
```
Subject: Inspection Today | {{deal.address.street}} - {{inspection.time}}

Hi {{recipient.firstName}},

Just a reminder that your home inspection is today!

**Today's Inspection:**
- Property: {{deal.address.street}}
- Time: {{inspection.time}}
- Inspector: {{inspection.inspectorName}}
- Inspector Phone: {{inspection.inspectorPhone}}

{{#if inspection.arrivalTime}}
**Suggested Arrival:** {{inspection.arrivalTime}}
{{/if}}

**Address:**
{{deal.address.full}}

{{#if inspection.accessNotes}}
**Access Notes:**
{{inspection.accessNotes}}
{{/if}}

If you're running late or can't make it, let me know. You can also reach the inspector directly if needed.

See you there!

{{signature}}
```

#### Inspection Complete - Report Ready
```
Subject: Inspection Report Ready | {{deal.address.street}}

Hi {{recipient.firstName}},

The home inspection for {{deal.address.street}} is complete, and the report is ready for your review.

{{#if inspection.reportUrl}}
**View Full Report:** [Click here to view]({{inspection.reportUrl}})
{{else}}
The report is attached to this email.
{{/if}}

**Summary:**
{{inspection.summary}}

**Key Findings:**
{{#each inspection.keyFindings}}
- **{{this.category}}:** {{this.finding}} {{#if this.severity}}({{this.severity}}){{/if}}
{{/each}}

**What This Means:**
{{#if inspection.majorIssues}}
There are some items worth discussing. I recommend we schedule a call to review the report together and decide on next steps.
{{else}}
Overall, the inspection went well. There are some minor items noted, which is normal for any home. Let's review these together.
{{/if}}

**Next Steps:**
1. Review the full report
2. Let's discuss by {{inspection.discussBy | formatDate}}
3. Decide on repair requests (if any)
4. Submit repair request by {{inspection.repairRequestDeadline | formatDate}}

**Your Options:**
- Request repairs from seller
- Request seller credit at closing
- Accept property as-is
- Exercise inspection contingency (walk away)

I'm available to discuss the report at your convenience. When works for a call?

{{signature}}
```

#### Repair Request Submission
```
Subject: Inspection Repair Request | {{deal.address.street}}

{{recipient.firstName}},

Following our review of the inspection report for {{deal.address.street}}, here is the formal repair request to submit to the seller:

**Requested Repairs:**
{{#each repairs.items}}
{{@index}}. **{{this.item}}**
   - Location: {{this.location}}
   - Issue: {{this.description}}
   - Request: {{this.requestedAction}}
{{/each}}

**Total Items:** {{repairs.totalItems}}

{{#if repairs.creditAlternative}}
**Alternative:** If preferred, we would accept a closing credit of {{repairs.creditAmount | formatCurrency}} in lieu of repairs.
{{/if}}

**Timeline:**
- Seller response due: {{repairs.responseDeadline | formatDate}}
- If no response: Contingency considerations

Please confirm these items look correct before I submit to the {{#if deal.isListing}}buyer{{else}}seller{{/if}}'s agent.

{{signature}}
```

### SMS Templates

#### Schedule Reminder
```
{{agent.firstName}}: Time to schedule inspection for {{deal.address.street | abbreviateAddress}}. Contingency expires {{inspection.contingencyExpires | formatShortDate}}. Need inspector recs? Reply or call {{agent.phone}}
```

#### Day-Of Reminder
```
{{agent.firstName}}: Inspection today at {{inspection.time}} for {{deal.address.street | abbreviateAddress}}. Inspector: {{inspection.inspectorName}} ({{inspection.inspectorPhone}}). See you there!
```

#### Inspection Starting
```
{{agent.firstName}}: Inspection starting now at {{deal.address.street | abbreviateAddress}}. Plan to arrive around {{inspection.arrivalTime}} to walk through with inspector.
```

#### Report Ready
```
{{agent.firstName}}: Inspection report ready for {{deal.address.street | abbreviateAddress}}. Check your email. Let's talk - when works for a quick call?
```

### Voice Call Scripts

#### Inspection Not Yet Scheduled
```
Opening: "Hi {{recipient.firstName}}, this is {{voiceName}} calling on behalf of
{{agent.name}} about your property at {{deal.address.street}}."

Purpose: "I'm calling because we need to schedule your home inspection soon.
Your inspection contingency expires on {{inspection.contingencyExpires | formatDate}},
and we want to make sure you have plenty of time to review the report."

Question: "Have you had a chance to reach out to a home inspector yet?"

Options: "I can provide some inspector recommendations if that would help.
Would you like me to send those over?"

Closing: "Once you have a date scheduled, please let {{agent.firstName}} know
so they can coordinate property access."
```

#### Day-Of Confirmation
```
Opening: "Hi {{recipient.firstName}}, this is {{voiceName}} with a quick
reminder about your inspection today."

Details: "Your home inspection at {{deal.address.street}} is scheduled for
{{inspection.time}}. {{inspection.inspectorName}} from {{inspection.inspectorCompany}}
will be there."

Attendance: "If you can make it, plan to arrive around {{inspection.arrivalTime}}
to walk through the findings with the inspector."

Closing: "{{agent.firstName}} will be there. Any questions before today?"
```

## Template Variables

| Variable | Type | Description | Example |
|----------|------|-------------|---------|
| `inspection.contingencyExpires` | Date | Contingency deadline | 2025-01-25 |
| `inspection.recommendedDate` | Date | Suggested inspection date | 2025-01-22 |
| `inspection.date` | Date | Scheduled date | 2025-01-22 |
| `inspection.time` | string | Scheduled time | "10:00 AM" |
| `inspection.duration` | string | Expected duration | "2-3 hours" |
| `inspection.estimatedDuration` | string | Typical duration | "2-3 hours" |
| `inspection.estimatedCost` | string | Typical cost | "$400-$600" |
| `inspection.inspectorName` | string | Inspector name | "John Smith" |
| `inspection.inspectorCompany` | string | Company name | "Pro Home Inspections" |
| `inspection.inspectorPhone` | string | Inspector phone | "(512) 555-0123" |
| `inspection.recommendedInspectors` | object[] | Inspector recommendations | [{name, phone}] |
| `inspection.reportUrl` | string | Link to report | "https://..." |
| `inspection.summary` | string | Brief summary | "Overall good condition" |
| `inspection.keyFindings` | object[] | Important findings | [{category, finding}] |
| `inspection.majorIssues` | boolean | Has major issues | false |
| `inspection.repairRequestDeadline` | Date | Repair request due | 2025-01-28 |
| `repairs.items` | object[] | Repair requests | [{item, description}] |
| `repairs.creditAmount` | number | Credit alternative | 5000 |

## Inspection Types

| Type | Duration | Cost Range | Notes |
|------|----------|------------|-------|
| General Home | 2-4 hours | $400-$600 | Standard inspection |
| Pest/Termite | 1 hour | $75-$150 | Often same day |
| Pool/Spa | 1 hour | $150-$250 | If applicable |
| Roof | 1-2 hours | $200-$400 | For older roofs |
| HVAC | 1 hour | $100-$200 | System age >10 years |
| Foundation | 2-3 hours | $400-$600 | If concerns |
| Sewer Scope | 1 hour | $150-$300 | Older homes |
| Mold | 1-2 hours | $300-$500 | If visible/suspected |

## Inspection Timeline

| Stage | Days from Contract | Template |
|-------|-------------------|----------|
| Schedule reminder | Day 1-2 | Schedule Inspection Reminder |
| Scheduled confirmation | At booking | Inspection Scheduled Confirmation |
| Day before | -1 day | Day-Of Reminder (email + SMS) |
| Day of (morning) | Day 0 | Day-Of SMS |
| Report received | Same day | Inspection Complete email |
| Review deadline | -2 days from contingency | Repair Request (if applicable) |

## Auto-Send Rules

| Trigger | Template | Auto-Send | Timing |
|---------|----------|-----------|--------|
| Contract executed | Schedule Reminder | Yes | Day 1 |
| Inspection scheduled | Confirmation | Yes | Immediate |
| Day before inspection | Day-Of Reminder | Yes | 6 PM prior |
| Day of inspection | SMS Reminder | Yes | 2 hours before |
| Report uploaded | Report Ready | Yes | Immediate |
| 48 hours before contingency | Deadline reminder | Yes | If not complete |

## Error Handling

| Error | Cause | Response |
|-------|-------|----------|
| `NO_INSPECTION_SCHEDULED` | Contingency approaching, no booking | Escalate to agent |
| `INSPECTOR_CANCELLED` | Inspector cancelled | Alert immediately |
| `REPORT_NOT_RECEIVED` | No report 24 hours after | Follow up with inspector |
| `DEADLINE_MISSED` | Contingency expired | Alert agent, determine status |

## Quality Checklist

- [x] Tracks inspection contingency deadline
- [x] Sends timely scheduling reminders
- [x] Confirms inspection details
- [x] Provides inspector recommendations
- [x] Delivers report promptly
- [x] Summarizes key findings
- [x] Facilitates repair negotiations
- [x] Manages multiple inspection types
- [x] Escalates timeline issues

# Template: Closing Reminder

**Category:** Communication > Templates
**Priority:** P0
**Auto-Send Eligible:** Yes (closing timeline communications)

## Purpose

Templates for closing-related communications including closing date confirmations, day-of reminders, what to bring checklists, final walkthrough coordination, and post-closing follow-ups. Ensures all parties are prepared and aligned for a smooth closing.

## Template Variants

### Email Templates

#### Closing Confirmed (7 Days Out)
```
Subject: Your Closing is Confirmed | {{deal.address.street}} - {{deal.closingDate | formatDate}}

Hi {{recipient.firstName}},

Exciting news - your closing is confirmed! Here's everything you need to know about your upcoming closing for {{deal.address.street}}.

**Closing Details:**
- Date: {{deal.closingDate | formatDate 'long'}}
- Time: {{deal.closingTime}}
- Location: {{deal.closingLocation}}
{{#if deal.closingAddress}}
- Address: {{deal.closingAddress}}
{{/if}}
{{#if deal.closingRemote}}
- Method: {{deal.closingMethod}} (Remote Online Notarization)
{{/if}}

**Title Company:**
{{closing.titleCompanyName}}
{{closing.closerName}} - {{closing.closerPhone}}
{{closing.closerEmail}}

**What to Bring:**
- Valid government-issued photo ID (driver's license or passport)
- Secondary ID may be required
{{#if closing.isBuyer}}
- Proof of wire transfer or certified funds
{{/if}}
- Any documents still pending signature
{{#if closing.cashierCheckAmount}}
- Cashier's check for {{closing.cashierCheckAmount | formatCurrency}} made out to "{{closing.payableTo}}"
{{/if}}

**Before Closing:**
{{#each closing.priorTasks}}
- [ ] {{this.task}} - Due {{this.dueDate | formatDate}}
{{/each}}

**Wire Transfer:**
{{#if closing.isBuyer}}
You'll receive wire instructions from {{closing.titleCompanyName}} separately. Remember:
- VERIFY all wire instructions by calling {{closing.titleCompanyPhone}}
- Do NOT rely on email instructions alone
- Wire funds {{closing.wireDeadline}} before closing
{{/if}}

**Final Walkthrough:**
{{#if closing.walkthroughScheduled}}
Scheduled for {{closing.walkthroughDate | formatDate}} at {{closing.walkthroughTime}}
{{else}}
We'll schedule your final walkthrough soon - typically 24-48 hours before closing.
{{/if}}

I'm here to help with any questions as we approach closing day. It's almost time to celebrate!

{{signature}}
```

#### 3 Days Before Closing
```
Subject: 3 Days to Closing | {{deal.address.street}} - Action Items

Hi {{recipient.firstName}},

We're just 3 days away from closing on {{deal.address.street}}! Let's make sure everything is in order.

**Closing Recap:**
- Date: {{deal.closingDate | formatDate 'long'}}
- Time: {{deal.closingTime}}
- Location: {{deal.closingLocation}}

**Final Checklist:**
{{#each closing.checklistItems}}
- {{#if this.complete}}[x]{{else}}[ ]{{/if}} {{this.item}}{{#if this.note}} - *{{this.note}}*{{/if}}
{{/each}}

{{#if closing.pendingItems}}
**Still Needed:**
{{#each closing.pendingItems}}
- {{this.item}} - {{this.responsibility}} - Due {{this.dueDate | formatDate}}
{{/each}}
{{/if}}

**Final Walkthrough:**
{{#if closing.walkthroughScheduled}}
Your final walkthrough is scheduled for:
- Date: {{closing.walkthroughDate | formatDate 'long'}}
- Time: {{closing.walkthroughTime}}
- Meet at: {{deal.address.street}}
{{else}}
Let's schedule your final walkthrough. What works for you on {{closing.suggestedWalkthroughDate | formatDate}}?
{{/if}}

{{#if closing.isBuyer}}
**Wire Transfer Status:**
{{#if closing.wireReceived}}
- Wire received. You're all set.
{{else}}
- Wire due: {{closing.wireDeadline | formatDate}}
- Amount: {{closing.wireAmount | formatCurrency}}
- Status: {{closing.wireStatus}}
{{/if}}
{{/if}}

Almost there! Call me at {{agent.phone}} with any questions.

{{signature}}
```

#### Day Before Closing
```
Subject: Tomorrow: Your Closing | {{deal.address.street}}

Hi {{recipient.firstName}},

Tomorrow is the big day! Here's your final checklist for closing on {{deal.address.street}}.

**Tomorrow's Schedule:**
{{#if closing.walkthroughScheduled}}
- **{{closing.walkthroughTime}}** - Final walkthrough at {{deal.address.street}}
{{/if}}
- **{{deal.closingTime}}** - Closing at {{deal.closingLocation}}

**Location Details:**
{{deal.closingAddress}}
{{#if closing.parkingInstructions}}
Parking: {{closing.parkingInstructions}}
{{/if}}

**Bring With You:**
{{#each closing.bringList}}
- {{this}}
{{/each}}

**Contacts for Tomorrow:**
- Me: {{agent.phone}}
- Title Company: {{closing.closerPhone}} ({{closing.closerName}})
{{#if closing.isBuyer}}
- Lender: {{closing.lenderContact}}
{{/if}}

{{#if closing.isBuyer}}
**Wire Status:** {{closing.wireConfirmation}}
{{/if}}

**What to Expect:**
- Signing will take approximately {{closing.estimatedDuration}}
- You'll sign {{closing.documentCount}}+ documents
- The closer will explain each document
- Bring your questions - no rush

**After Closing:**
{{#if closing.isBuyer}}
- You'll receive your keys!
- Title transfer is recorded with the county
- You'll receive your closing package within a few days
{{else}}
- Proceeds will be wired to your account (typically same day)
- Title transfer is recorded with the county
- You'll receive your closing package within a few days
{{/if}}

See you tomorrow! This is the finish line.

{{signature}}
```

#### Day of Closing
```
Subject: Today: Closing Day | {{deal.address.street}}

Hi {{recipient.firstName}},

Today's the day! Here's your closing day rundown for {{deal.address.street}}.

**Today's Schedule:**
{{#if closing.walkthroughScheduled}}
- **{{closing.walkthroughTime}}** - Final walkthrough at property
{{/if}}
- **{{deal.closingTime}}** - Closing begins

**Closing Location:**
{{deal.closingAddress}}
{{#if closing.mapLink}}[Get Directions]({{closing.mapLink}}){{/if}}

**Remember to Bring:**
- Photo ID
{{#if closing.cashierCheckNeeded}}- Cashier's check for {{closing.cashierCheckAmount | formatCurrency}}{{/if}}
- Phone (for any last-minute items)

**My Number:** {{agent.phone}} - Text me when you arrive!

Congratulations in advance! Let's get this done.

{{signature}}
```

#### Closing Complete - Congratulations (Buyer)
```
Subject: Congratulations, Homeowner! | {{deal.address.street}}

{{recipient.firstName}},

CONGRATULATIONS! You are officially the owner of {{deal.address.street}}!

**You Did It!**
It's been a journey, and I'm so happy we made it to this moment together. Welcome to your new home!

**What Happens Now:**
1. **Title Recording**: The deed is being recorded with {{deal.county}} County
2. **Keys**: {{#if closing.keyHandoff}}You have them!{{else}}Pickup arranged for {{closing.keyPickupDetails}}{{/if}}
3. **Utilities**: Transfer to your name ({{closing.utilityDeadline | formatDate}} recommended)
4. **Insurance**: Your homeowner's policy is active
5. **Moving**: Time to make it yours!

**Important Documents:**
You'll receive your closing package with all signed documents within {{closing.documentDeliveryTime}}. Keep these in a safe place:
- Deed
- Title Insurance Policy
- Closing Disclosure
- Loan Documents

**Save These Numbers:**
{{#each closing.importantContacts}}
- {{this.service}}: {{this.number}}
{{/each}}

**Home Warranty:**
{{#if closing.hasWarranty}}
Your home warranty is active with {{closing.warrantyCompany}}. Claims: {{closing.warrantyPhone}}
{{else}}
Consider a home warranty for peace of mind. Let me know if you'd like recommendations.
{{/if}}

Thank you for trusting me with this important milestone. I hope your new house becomes everything you dreamed of.

If you know anyone looking to buy or sell, I'd be honored if you'd pass along my name!

Warmly,
{{signature}}
```

#### Closing Complete - Congratulations (Seller)
```
Subject: Sale Complete! | {{deal.address.street}}

{{recipient.firstName}},

Congratulations! The sale of {{deal.address.street}} is complete!

**Transaction Complete:**
The deed has been signed and is being recorded with {{deal.county}} County. Your chapter at this property has officially closed.

**Your Proceeds:**
{{#if closing.proceedsWired}}
- Amount: {{closing.netProceeds | formatCurrency}}
- Status: Wired to your account
- Expected arrival: {{closing.proceedsExpectedDate | formatDate}}
{{else}}
- Amount: {{closing.netProceeds | formatCurrency}}
- Method: {{closing.proceedsMethod}}
{{/if}}

**Document Delivery:**
Your signed closing documents will arrive within {{closing.documentDeliveryTime}}.

**Final Items:**
{{#each closing.sellerFinalItems}}
- {{this}}
{{/each}}

**Thank You:**
It's been a pleasure working with you on this sale. Your home is in good hands with the new owners.

If you're ever in the market to buy or sell again, or know someone who is, I'd love to help. Referrals are the greatest compliment!

Wishing you the best in your next chapter.

{{signature}}
```

### SMS Templates

#### Week Before
```
{{agent.firstName}}: 1 week until closing! {{deal.address.street | abbreviateAddress}} on {{deal.closingDate | formatShortDate}} at {{deal.closingTime}}. Let me know if you have questions!
```

#### 3 Days Before
```
{{agent.firstName}}: 3 days to closing ({{deal.closingDate | formatShortDate}})! Final walkthrough + any pending items - let's connect. {{agent.phone}}
```

#### Day Before
```
{{agent.firstName}}: Tomorrow's the day! Closing at {{deal.closingTime}} at {{deal.closingLocation | abbreviate}}. Bring ID{{#if closing.isBuyer}}, confirm wire sent{{/if}}. See you there!
```

#### Day Of - Morning
```
{{agent.firstName}}: Closing day! See you at {{deal.closingTime}} at {{deal.closingLocation | abbreviate}}. Text when you're on your way. Congrats!
```

#### Congratulations
```
{{agent.firstName}}: CONGRATULATIONS! 🎉 You did it! Welcome to {{deal.address.street | abbreviateAddress}}. Thank you for trusting me with this journey. Enjoy your new home!
```

### Voice Call Scripts

#### Closing Confirmation Call
```
Opening: "Hi {{recipient.firstName}}, this is {{voiceName}} calling on behalf of
{{agent.name}} about your upcoming closing."

Confirmation: "I'm calling to confirm that your closing for {{deal.address.street}}
is scheduled for {{deal.closingDate | formatDate}} at {{deal.closingTime}}
at {{deal.closingLocation}}."

Checklist: "Do you have everything you need? Valid ID,
{{#if closing.isBuyer}}wire confirmation, {{/if}}and any pending documents?"

Questions: "Do you have any questions before closing day?"

Closing: "{{agent.firstName}} will be there with you. Congratulations in advance!"
```

## Template Variables

| Variable | Type | Description | Example |
|----------|------|-------------|---------|
| `deal.closingDate` | Date | Closing date | 2025-02-15 |
| `deal.closingTime` | string | Closing time | "2:00 PM" |
| `deal.closingLocation` | string | Location name | "First American Title" |
| `deal.closingAddress` | string | Full address | "100 Title Way, Austin TX" |
| `closing.titleCompanyName` | string | Title company | "First American Title" |
| `closing.closerName` | string | Closer's name | "Jennifer Smith" |
| `closing.closerPhone` | string | Closer's phone | "(512) 555-1234" |
| `closing.isBuyer` | boolean | Is recipient buyer | true |
| `closing.wireAmount` | number | Wire transfer amount | 85000 |
| `closing.wireReceived` | boolean | Wire confirmed | true |
| `closing.walkthroughScheduled` | boolean | Walkthrough set | true |
| `closing.walkthroughDate` | Date | Walkthrough date | 2025-02-14 |
| `closing.walkthroughTime` | string | Walkthrough time | "10:00 AM" |
| `closing.netProceeds` | number | Seller net proceeds | 250000 |
| `closing.estimatedDuration` | string | Signing duration | "45-60 minutes" |

## Closing Timeline

| Days Out | Template | Recipient |
|----------|----------|-----------|
| 7 days | Closing Confirmed | All |
| 3 days | 3 Days Before | All |
| 1 day | Day Before | All |
| Day of | Day Of Closing | All |
| After | Congratulations | All |

## Auto-Send Rules

| Trigger | Template | Auto-Send | Approval |
|---------|----------|-----------|----------|
| Closing confirmed | 7 Day Confirmation | Yes | No |
| 3 days before | 3 Day Reminder | Yes | No |
| 1 day before | Day Before | Yes | No |
| Morning of closing | Day Of SMS | Yes | No |
| Closing complete | Congratulations | Yes | No |

## Error Handling

| Error | Cause | Response |
|-------|-------|----------|
| `CLOSING_POSTPONED` | Date changed | Cancel pending, reschedule sequence |
| `WIRE_NOT_RECEIVED` | Day before, no wire | Urgent alert to agent |
| `WALKTHROUGH_NOT_SCHEDULED` | 2 days out | Alert agent |
| `PENDING_DOCS` | Closing day items incomplete | Alert agent and closer |

## Quality Checklist

- [x] Confirms all closing details clearly
- [x] Provides complete location/parking info
- [x] Lists what to bring
- [x] Coordinates final walkthrough
- [x] Tracks wire transfer status
- [x] Sends timely reminders
- [x] Celebrates completion appropriately
- [x] Provides post-closing guidance

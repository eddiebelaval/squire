# Template: Congratulations

**Category:** Communication > Templates
**Priority:** P1
**Auto-Send Eligible:** Yes (on closing completion)

## Purpose

Templates for celebrating transaction milestones with clients. Primary focus on closing completion, but also covers contract acceptance, contingency clearances, and other significant moments. Designed to strengthen client relationships and encourage referrals.

## Template Variants

### Email Templates

#### Buyer Closing - New Homeowner
```
Subject: Congratulations, Homeowner! Welcome to {{deal.address.street}}

Dear {{recipient.firstName}},

YOU DID IT!

As of today, you are officially the owner of {{deal.address.street}}. I am so thrilled for you and honored to have been part of this journey.

Buying a home is one of life's biggest milestones, and you navigated it beautifully. From our first showing to handing you the keys today, it's been a pleasure working with you.

**Your New Home:**
{{deal.address.full}}

**Closing Details:**
- Closed: {{deal.closingDate | formatDate 'long'}}
- Purchase Price: {{deal.purchasePrice | formatCurrency}}
- You're now building equity in YOUR home!

**First Week Checklist:**
- [ ] Change the locks
- [ ] Transfer utilities to your name
- [ ] Update your address with USPS, DMV, and subscriptions
- [ ] Meet your neighbors
- [ ] Take a moment to celebrate - you deserve it!

**Save These Numbers:**
{{#each importantContacts}}
- {{this.service}}: {{this.number}}
{{/each}}

**Home Warranty:**
{{#if deal.hasWarranty}}
Your home warranty with {{warranty.company}} is active.
Claims: {{warranty.phone}}
Coverage details attached.
{{/if}}

**Stay Connected:**
I'd love to stay in touch. Don't hesitate to reach out if you have any questions about your new home, need contractor recommendations, or just want to say hi.

If you know anyone - friends, family, colleagues - who could use a dedicated real estate partner, I would be honored by your referral. There's no greater compliment.

Once again, congratulations! May {{deal.address.street}} bring you years of joy, comfort, and wonderful memories.

Welcome home!

Warmly,
{{signature}}

P.S. - I'd love to see how you make the space your own. Feel free to share photos anytime!
```

#### Seller Closing - Successful Sale
```
Subject: Congratulations on Your Sale! | {{deal.address.street}}

Dear {{recipient.firstName}},

Congratulations - you've officially closed on the sale of {{deal.address.street}}!

This marks the end of an era and the beginning of a new chapter. {{#if personal.yearsOwned}}After {{personal.yearsOwned}} years, you've successfully sold your home.{{/if}} I'm honored you trusted me to guide you through this process.

**Transaction Summary:**
- Property: {{deal.address.street}}
- Sale Price: {{deal.purchasePrice | formatCurrency}}
- Closed: {{deal.closingDate | formatDate 'long'}}
- Net Proceeds: {{deal.netProceeds | formatCurrency}}

**Your Proceeds:**
{{#if proceeds.wired}}
Your net proceeds of {{deal.netProceeds | formatCurrency}} have been wired to your account. You should see them within 24-48 hours.
{{else}}
Your proceeds will be delivered as discussed at closing.
{{/if}}

**Next Steps:**
{{#each sellerNextSteps}}
- {{this}}
{{/each}}

**Document Storage:**
Your closing documents will arrive within {{document.deliveryTime}}. Keep these in a safe place:
- Settlement statement (for tax purposes)
- Any disclosure documents
- Final utility bills for record

**Thank You:**
Thank you for the privilege of representing you. Your home has found wonderful new owners, and your next adventure awaits.

{{#if personal.movingTo}}
Best wishes as you settle into {{personal.movingTo}}! Don't hesitate to reach out if you need anything.
{{/if}}

If you ever need real estate guidance - or know someone who does - I'm always here. Referrals are the highest compliment, and I'm grateful for your trust.

To new beginnings!

Warmly,
{{signature}}
```

#### First-Time Buyer Special
```
Subject: You're a Homeowner! Congratulations, {{recipient.firstName}}!

Dear {{recipient.firstName}},

I have goosebumps writing this email...

YOU BOUGHT YOUR FIRST HOME!

Welcome to the world of homeownership. This is a HUGE accomplishment, and you should be incredibly proud. Not everyone makes it to this milestone, but YOU DID.

**Your First Home:**
{{deal.address.street}}

I still remember when we first started this journey together. {{#if personal.journeyNote}}{{personal.journeyNote}}{{/if}} Look at you now - a homeowner!

**What Being a Homeowner Means:**
- Every payment builds YOUR equity
- You can paint the walls any color you want
- No more asking permission for pets
- Tax benefits (consult your tax advisor!)
- A place that's truly YOURS

**First-Time Homeowner Tips:**
1. **Emergency Fund** - Start building reserves for repairs
2. **Learn Your Systems** - Know where shutoffs are
3. **Seasonal Maintenance** - I'll send you a checklist
4. **Don't Rush Renovations** - Live in it first, then decide
5. **Enjoy It** - You worked hard for this!

**Resources I'm Sending:**
- First-year homeowner checklist
- Recommended contractors list
- Home maintenance calendar
- Important numbers to save

**My Promise:**
I'm not disappearing now that you've closed. I'm here for questions, contractor recommendations, market updates, or just to celebrate anniversaries of your purchase!

You did something amazing. Never forget that.

To your new home and all the memories ahead,

{{signature}}

P.S. - Frame a photo from today. You'll look back on it someday and smile.
```

#### Contract Acceptance
```
Subject: Offer Accepted! {{deal.address.street}} is Under Contract

{{recipient.firstName}},

CONGRATULATIONS! Your offer on {{deal.address.street}} has been accepted!

**Contract Summary:**
- Purchase Price: {{deal.purchasePrice | formatCurrency}}
- Closing Date: {{deal.closingDate | formatDate 'long'}}

This is exciting news! While there's still work ahead, this is a major milestone. You're officially under contract on your {{#if isFirstHome}}first {{/if}}home.

**What Happens Now:**
I'll send you a detailed timeline shortly, but here are the immediate next steps:
1. Earnest money deposit due {{deal.earnestMoneyDue | formatDate}}
2. Home inspection scheduling
3. Loan application finalization (if not done)

Celebrate tonight - you earned it! Then we get to work tomorrow.

{{signature}}
```

#### Contingencies Cleared
```
Subject: Great News! All Contingencies Cleared | {{deal.address.street}}

Hi {{recipient.firstName}},

Wonderful news - all your contingencies have been cleared for {{deal.address.street}}!

**What This Means:**
- Option/inspection period: Completed
- Financing: Approved
- Appraisal: Complete

We are now in the home stretch. Barring any unforeseen circumstances, you will be closing on {{deal.closingDate | formatDate 'long'}}.

**Remaining Timeline:**
{{#each remainingSteps}}
- {{this.milestone}}: {{this.date | formatDate}}
{{/each}}

This is a big deal. The hard parts are behind you. Now we just coast to closing!

{{signature}}
```

#### Anniversary (1 Year)
```
Subject: Happy Home Anniversary! One Year at {{deal.address.street}}

Hi {{recipient.firstName}},

Can you believe it? One year ago today, you closed on {{deal.address.street}}!

I hope this first year has been everything you dreamed of. From your first night in your new place to all the memories you've made since, I hope your home has been a source of joy and comfort.

**How Time Flies:**
- Closing Date: {{deal.closingDate | formatDate 'long'}}
- Today: One year of being a homeowner!

**Your Home Today:**
{{#if marketUpdate}}
The market in your area has {{marketUpdate.trend}}. Similar homes are selling for {{marketUpdate.comparableRange}}. Your investment is {{marketUpdate.equity}}.
{{/if}}

**Homeowner Reminder:**
- Annual HVAC maintenance
- Smoke/CO detector battery check
- Review homeowner's insurance coverage
- Check for any needed repairs before they grow

I'd love to hear how you're doing! And of course, if you know anyone thinking about buying or selling, I'd be grateful for the introduction.

Here's to many more years in your wonderful home!

{{signature}}
```

### SMS Templates

#### Closing Congrats
```
CONGRATULATIONS {{recipient.firstName}}! You did it - {{deal.address.street}} is YOURS! So proud of you. Welcome home! -{{agent.firstName}}
```

#### Contract Accepted
```
{{agent.firstName}}: Your offer was ACCEPTED on {{deal.address.street | abbreviateAddress}}! Congrats! Details coming via email. Celebrate tonight!
```

#### Contingencies Cleared
```
{{agent.firstName}}: All contingencies cleared for {{deal.address.street | abbreviateAddress}}! We're on the home stretch to closing {{deal.closingDate | formatShortDate}}. Almost there!
```

#### Anniversary
```
{{agent.firstName}}: Happy 1-year home anniversary! {{deal.closingDate | formatDate 'short'}} was a great day. Hope {{deal.address.street | abbreviateAddress}} has been wonderful! Thinking of you.
```

### Voice Call Scripts

#### Post-Closing Check-in
```
Opening: "Hi {{recipient.firstName}}, this is {{agent.name}} calling to check in."

Celebration: "Congratulations again on {{deal.address.street}}! How does it feel
to be a homeowner?"

Check-in: "I wanted to make sure everything went smoothly with the move and see
if you have any questions about the house."

Offer Help: "Remember, I'm always here if you need anything - contractor
recommendations, questions about the neighborhood, anything at all."

Referral Ask: "Oh, and if you know anyone who's thinking about buying or selling,
I'd be so grateful if you'd pass along my name."

Closing: "Enjoy your new home! Don't hesitate to reach out anytime."
```

## Template Variables

| Variable | Type | Description | Example |
|----------|------|-------------|---------|
| `recipient.firstName` | string | Client's first name | "John" |
| `deal.address.street` | string | Property address | "123 Main St" |
| `deal.address.full` | string | Full address | "123 Main St, Austin TX 78701" |
| `deal.purchasePrice` | number | Sale/purchase price | 450000 |
| `deal.closingDate` | Date | Closing date | 2025-02-15 |
| `deal.netProceeds` | number | Seller proceeds | 125000 |
| `personal.yearsOwned` | number | Years seller owned | 8 |
| `personal.movingTo` | string | Seller's new location | "California" |
| `personal.journeyNote` | string | Personal memory | "You almost gave up after..." |
| `isFirstHome` | boolean | First-time buyer | true |
| `warranty.company` | string | Warranty provider | "American Home Shield" |
| `warranty.phone` | string | Claims number | "(800) 555-0123" |
| `importantContacts` | object[] | Emergency numbers | [{service, number}] |
| `marketUpdate.equity` | string | Equity statement | "up significantly" |

## Milestone Triggers

| Event | Template | Timing |
|-------|----------|--------|
| Contract executed | Contract Acceptance | Immediate |
| All contingencies clear | Contingencies Cleared | Same day |
| Closing complete | Closing Congratulations | Same day |
| 30 days post-close | Check-in call | Scheduled |
| 1 year anniversary | Anniversary email | Annual |

## Auto-Send Rules

| Trigger | Template | Auto-Send | Personalization |
|---------|----------|-----------|-----------------|
| Contract accepted | Contract Acceptance | Yes | Auto |
| Contingencies cleared | Contingencies Cleared | Yes | Auto |
| Closing complete | Closing Congratulations | Draft for review | Manual touch |
| 30 days post-close | Check-in call | Reminder to agent | Agent call |
| 1 year anniversary | Anniversary | Draft for review | Add market update |

## Personalization Tips

### Making It Special
- Reference specific moments from their journey
- Mention challenges they overcame
- For first-timers, emphasize the achievement
- Include market context for anniversary notes

### Gift Ideas (for agent reference)
- Closing gift (wine, cutting board, etc.)
- Gift card to local restaurant
- Plant or flowers
- Custom house portrait
- Key holder or doormat

## Referral Ask Best Practices

### When to Ask
- In closing congratulations (gentle)
- At 30-day check-in (direct)
- At anniversary (reminder)

### How to Ask
```
"If you know anyone - friends, family, colleagues - thinking about buying or
selling, I'd be honored if you'd pass along my name. There's no greater
compliment than a referral."
```

## Quality Checklist

- [x] Genuinely celebratory tone
- [x] Personalized to client situation
- [x] Special recognition for first-timers
- [x] Provides helpful next steps
- [x] Includes important contacts
- [x] Tasteful referral ask
- [x] Anniversary tracking
- [x] Multiple channel options
- [x] Builds lasting relationship

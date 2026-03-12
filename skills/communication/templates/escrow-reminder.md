# Template: Escrow Reminder

**Category:** Communication > Templates
**Priority:** P0
**Auto-Send Eligible:** Yes (scheduled escrow milestone reminders)

## Purpose

Templates for escrow-related communications including earnest money deposits, escrow timeline updates, balance due notifications, and closing fund reminders. Critical for ensuring funds are deposited and transferred correctly and on time.

## Template Variants

### Email Templates

#### Earnest Money Deposit Reminder
```
Subject: Earnest Money Deposit Due | {{deal.address.street}}

Hi {{recipient.firstName}},

Congratulations on your executed contract for {{deal.address.street}}! Now it's time to submit your earnest money deposit.

**Earnest Money Details:**
- Amount: {{escrow.earnestMoneyAmount | formatCurrency}}
- Due By: {{escrow.earnestMoneyDue | formatDate 'long'}}
- {{escrow.daysUntilDue}} days remaining

**Payment Options:**
{{#if escrow.acceptsWire}}
1. **Wire Transfer** (Recommended for speed)
   - Bank: {{escrow.bankName}}
   - For Account: {{escrow.accountName}}
   - {{#if escrow.wireInstructions}}See attached wire instructions{{else}}Wire instructions will be sent separately{{/if}}
{{/if}}

{{#if escrow.acceptsCheck}}
2. **Cashier's Check / Certified Check**
   - Made payable to: {{escrow.payableTo}}
   - Deliver to: {{escrow.deliveryAddress}}
{{/if}}

{{#if escrow.acceptsACH}}
3. **ACH Transfer**
   - {{escrow.achInstructions}}
{{/if}}

**IMPORTANT WIRE FRAUD WARNING:**
Never send money based on email instructions alone. ALWAYS verify wire instructions by calling the title company directly at {{escrow.verificationPhone}}.

Please reply to this email once your deposit has been sent.

{{signature}}
```

#### Earnest Money Deposit Confirmation
```
Subject: Earnest Money Received | {{deal.address.street}}

Hi {{recipient.firstName}},

Great news! We've confirmed receipt of your earnest money deposit for {{deal.address.street}}.

**Deposit Details:**
- Amount Received: {{escrow.depositReceived | formatCurrency}}
- Date Received: {{escrow.dateReceived | formatDate}}
- Held By: {{escrow.heldBy}}
- Reference: {{escrow.referenceNumber}}

Your earnest money is now being held in escrow and will be applied toward your purchase at closing.

**Next Steps:**
{{#each escrow.nextSteps}}
- {{this.item}} - Due {{this.date | formatDate}}
{{/each}}

Let me know if you have any questions.

{{signature}}
```

#### Balance Due Reminder (Pre-Closing)
```
Subject: Closing Funds Due | {{deal.address.street}}

Hi {{recipient.firstName}},

Your closing is approaching! Here's what you need to know about your closing funds for {{deal.address.street}}.

**Closing Details:**
- Closing Date: {{deal.closingDate | formatDate 'long'}}
- Closing Time: {{deal.closingTime}}
- Location: {{deal.closingLocation}}

**Funds Due:**
| Description | Amount |
|-------------|--------|
{{#each escrow.lineItems}}
| {{this.description}} | {{this.amount | formatCurrency}} |
{{/each}}
| **Total Due at Closing** | **{{escrow.totalDue | formatCurrency}}** |

{{#if escrow.earnestMoneyCredited}}
*Your earnest money deposit of {{escrow.earnestMoneyAmount | formatCurrency}} will be credited at closing.*
{{/if}}

**Wire Instructions:**
Wire instructions will be sent {{escrow.wireInstructionsTiming}}. When you receive them:
1. Verify by calling {{escrow.titleCompanyName}} at {{escrow.verificationPhone}}
2. Do NOT call any number included in an email
3. Send wire {{escrow.recommendedWireTiming}} before closing

**CRITICAL WIRE FRAUD WARNING:**
Wire fraud is common in real estate. NEVER wire money based solely on email instructions. ALWAYS verify by calling a known number for the title company.

Please confirm receipt of this email.

{{signature}}
```

#### Wire Instructions Received
```
Subject: Wire Instructions - VERIFY BEFORE SENDING | {{deal.address.street}}

Hi {{recipient.firstName}},

{{escrow.titleCompanyName}} has sent wire instructions for your closing on {{deal.address.street}}.

**BEFORE YOU WIRE ANY FUNDS:**

1. **CALL TO VERIFY** - Call {{escrow.titleCompanyName}} at {{escrow.verificationPhone}}
   - Do NOT use any phone number from emails
   - Use the number from their website or your original documents

2. **Verify these details over the phone:**
   - Bank name and routing number
   - Account number
   - Beneficiary name
   - Wire amount

3. **Start small (optional)** - Consider sending $1 first and verifying receipt

**Amount to Wire:** {{escrow.wireAmount | formatCurrency}}

The attached wire instructions are directly from {{escrow.titleCompanyName}}, but verification is still required.

**Recommended Timeline:**
- Send wire: {{escrow.recommendedWireDate | formatDate}}
- Allow 24-48 hours for processing
- Closing date: {{deal.closingDate | formatDate}}

After sending, reply with your wire confirmation number.

{{signature}}
```

### SMS Templates

#### Earnest Money Reminder
```
{{agent.firstName}}: Earnest money ({{escrow.earnestMoneyAmount | formatCurrency}}) due {{escrow.earnestMoneyDue | formatShortDate}} for {{deal.address.street | abbreviateAddress}}. Details in email. Questions? {{agent.phone}}
```

#### Earnest Money Confirmation
```
{{agent.firstName}}: Earnest money received for {{deal.address.street | abbreviateAddress}}. Deposit confirmed: {{escrow.depositReceived | formatCurrency}}. Next: {{escrow.nextMilestone}}
```

#### Wire Reminder
```
{{agent.firstName}}: Reminder - wire {{escrow.wireAmount | formatCurrency}} for {{deal.address.street | abbreviateAddress}} closing. VERIFY instructions by calling title company before sending. Details in email.
```

#### Wire Fraud Warning
```
WIRE FRAUD ALERT: NEVER send money based on email alone. Call {{escrow.verificationPhone}} to verify ANY wire instructions. Do not use numbers from emails. -{{agent.firstName}}
```

### Voice Call Scripts

#### Earnest Money Follow-Up
```
Opening: "Hi {{recipient.firstName}}, this is {{voiceName}} calling on behalf of
{{agent.name}} about your earnest money deposit for {{deal.address.street}}."

Details: "Your earnest money of {{escrow.earnestMoneyAmount | formatCurrency}} is due
{{escrow.earnestMoneyDue | formatDate}}. That's {{escrow.daysUntilDue}} days from now."

Options: "You can send a wire transfer or cashier's check. Did you receive
the email with payment details?"

Closing: "Do you need any assistance with the deposit? Should I have
{{agent.firstName}} call you?"
```

#### Wire Verification Call
```
Opening: "Hi {{recipient.firstName}}, this is {{voiceName}} from {{agent.brokerage}}."

Purpose: "I'm following up on the wire instructions for your closing
at {{deal.address.street}}. Have you had a chance to review them?"

Verification: "Before you send any funds, please call {{escrow.titleCompanyName}}
directly at {{escrow.verificationPhone}} to verify the wire details.
This is critical for protecting your funds."

Amount: "The amount to wire is {{escrow.wireAmount | formatCurrency}}, and
we recommend sending it by {{escrow.recommendedWireDate | formatDate}}."

Closing: "Any questions? Need {{agent.firstName}} to walk you through this?"
```

## Template Variables

| Variable | Type | Description | Example |
|----------|------|-------------|---------|
| `escrow.earnestMoneyAmount` | number | EM deposit amount | 10000 |
| `escrow.earnestMoneyDue` | Date | EM due date | 2025-01-20 |
| `escrow.daysUntilDue` | number | Days remaining | 3 |
| `escrow.totalDue` | number | Total closing funds | 85000 |
| `escrow.wireAmount` | number | Wire transfer amount | 84500 |
| `escrow.titleCompanyName` | string | Title company | "First American" |
| `escrow.verificationPhone` | string | Phone for verification | "(512) 555-1234" |
| `escrow.bankName` | string | Receiving bank | "Chase Bank" |
| `escrow.payableTo` | string | Check payee | "First American Title" |
| `escrow.deliveryAddress` | string | Check delivery | "100 Title Way" |
| `escrow.wireInstructionsTiming` | string | When instructions sent | "2 days before closing" |
| `escrow.recommendedWireDate` | Date | When to send wire | 2025-02-01 |
| `escrow.heldBy` | string | Escrow holder | "First American Title" |
| `escrow.referenceNumber` | string | Deposit reference | "FA-2025-12345" |
| `escrow.lineItems` | object[] | Closing cost breakdown | [{desc, amount}] |

## Wire Fraud Prevention

### Mandatory Warnings
Every wire-related communication MUST include:

1. **Verification instruction** - Call to verify, not email
2. **Known phone number** - Not from emails
3. **Warning about fraud** - Explicit wire fraud warning

### Warning Text (Required)
```
WIRE FRAUD WARNING: Real estate transactions are targets for wire fraud.
NEVER send money based on email instructions alone. ALWAYS verify wire
instructions by calling a known, trusted phone number for the title company.
If you receive any email with changed wire instructions, STOP and call
{{agent.phone}} immediately.
```

### Verification Steps Template
```
Before wiring funds:
1. Call {{escrow.titleCompanyName}} at {{escrow.verificationPhone}}
2. Verify bank name, routing number, account number
3. Confirm beneficiary name exactly matches
4. Verify wire amount
5. Consider sending $1 test wire first
```

## Escrow Timeline

| Milestone | Timing | Template |
|-----------|--------|----------|
| Contract execution | Day 0 | Earnest Money Deposit Reminder |
| EM deposit received | Day 1-3 | Earnest Money Confirmation |
| 3 days before closing | -3 days | Balance Due Reminder |
| Wire instructions sent | -2 days | Wire Instructions Received |
| Wire due | -1 day | Wire Reminder (SMS) |
| Closing day | Day 0 | Closing confirmation |

## Auto-Send Rules

| Event | Template | Auto-Send | Approval |
|-------|----------|-----------|----------|
| Contract executed | EM Deposit Reminder | Yes | No |
| EM deposit received | EM Confirmation | Yes | No |
| 3 days before closing | Balance Due Reminder | Yes | No |
| Wire instructions received | Wire Instructions | Yes | No |
| 1 day before closing | Wire Reminder SMS | Yes | No |
| Wire fraud warning | Wire Fraud SMS | Always with wire info | No |

## Error Handling

| Error | Cause | Response |
|-------|-------|----------|
| `MISSING_ESCROW_DETAILS` | Title company info missing | Alert agent |
| `EM_OVERDUE` | Past earnest money deadline | Urgent agent alert |
| `WIRE_NOT_RECEIVED` | No wire confirmation | Follow-up sequence |
| `TITLE_CONTACT_MISSING` | No verification number | Block send, alert agent |

## Quality Checklist

- [x] Always includes wire fraud warnings
- [x] Provides verification phone number
- [x] Clear amount and timing
- [x] Offers multiple payment options
- [x] Confirms receipt of deposits
- [x] Tracks wire status
- [x] Escalates missing funds
- [x] Uses verified title company info

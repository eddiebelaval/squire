# Template: Wire Instructions

**Category:** Communication > Templates
**Priority:** P0 (Critical - Financial Security)
**Auto-Send Eligible:** Yes (with mandatory fraud warnings)

## Purpose

Templates for securely communicating wire transfer instructions to buyers. This is a high-stakes template due to wire fraud risks. Every communication MUST include verification instructions and fraud warnings. Never compromise on security messaging.

## Critical Security Requirements

**MANDATORY in ALL wire communications:**
1. Verification phone number (not from email)
2. Wire fraud warning
3. Never include full wire details in email (reference attached PDF or separate secure channel)
4. Recommend phone verification before any wire
5. Never make changes to wire instructions via email

## Template Variants

### Email Templates

#### Wire Instructions Available
```
Subject: Wire Instructions - VERIFY BEFORE SENDING | {{deal.address.street}}

Hi {{recipient.firstName}},

{{closing.titleCompanyName}} has prepared the wire instructions for your closing on {{deal.address.street}}. The instructions are attached to this email as a secure PDF.

**BEFORE YOU WIRE ANY FUNDS - READ THIS:**

Wire fraud is common in real estate. Criminals hack email accounts and send fake wire instructions. Protect yourself:

1. **CALL TO VERIFY**
   Call {{closing.titleCompanyName}} at: **{{closing.verificationPhone}}**
   - This is their verified phone number from their official website
   - Do NOT call any number included in emails (including this one could be compromised)
   - Look up their number independently if unsure

2. **Verify EVERY detail over the phone:**
   - Bank name and routing number
   - Account number
   - Beneficiary name (exact spelling)
   - Wire amount

3. **If ANYTHING changes:**
   - STOP immediately
   - Do NOT wire funds
   - Call {{agent.phone}} and {{closing.verificationPhone}}
   - Never accept wire instruction changes via email

**Wire Details:**
- Amount: {{closing.wireAmount | formatCurrency}}
- Send by: {{closing.wireDeadline | formatDate}}
- From title company: {{closing.titleCompanyName}}

**After Verification, Send Your Wire:**
- Allow 24-48 hours for processing
- Keep confirmation number
- Reply with confirmation once sent

**Your closing is {{deal.closingDate | formatDate}}** - please wire at least 2 business days before.

I'm here if you have any questions. Please call {{agent.phone}} if anything seems off.

{{signature}}

---

**WIRE FRAUD WARNING**
Criminals target real estate transactions. NEVER send money based on email instructions alone. If you receive any email claiming wire instructions have changed, STOP and CALL us immediately. Legitimate changes will NEVER be communicated via email.
```

#### Wire Reminder (Not Yet Received)
```
Subject: Wire Reminder - Funds Needed for Closing | {{deal.address.street}}

Hi {{recipient.firstName}},

I'm following up on the wire transfer for your closing at {{deal.address.street}}.

**Wire Status:** Not yet received
**Closing Date:** {{deal.closingDate | formatDate 'long'}}
**Amount Due:** {{closing.wireAmount | formatCurrency}}
**Deadline to Wire:** {{closing.wireDeadline | formatDate}}

**Action Needed:**
1. Verify wire instructions by calling {{closing.titleCompanyName}} at {{closing.verificationPhone}}
2. Send wire to the verified account
3. Reply with your wire confirmation number

**Having trouble?**
- Contact your bank's wire department
- Ensure you have the bank's routing number (not just account number)
- Some banks require in-person wire requests for large amounts

**Questions about wire instructions?**
Call me: {{agent.phone}}
Call title company: {{closing.verificationPhone}}

Please do not delay - wire processing can take 1-2 business days.

{{signature}}

---
REMINDER: Always verify wire instructions by phone before sending any funds.
```

#### Wire Confirmation Request
```
Subject: Confirm Your Wire Transfer | {{deal.address.street}}

Hi {{recipient.firstName}},

Have you been able to send your wire for the {{deal.address.street}} closing?

**Wire Amount:** {{closing.wireAmount | formatCurrency}}
**Closing Date:** {{deal.closingDate | formatDate}}

If you've already sent the wire, please reply with:
- Wire confirmation/reference number
- Date sent
- Amount sent

If you haven't sent it yet, please do so as soon as possible. The title company needs to confirm receipt before closing can proceed.

**Questions or concerns?** Call me at {{agent.phone}}.

{{signature}}
```

#### Wire Received Confirmation
```
Subject: Wire Received | {{deal.address.street}} - Ready for Closing

Hi {{recipient.firstName}},

Great news! {{closing.titleCompanyName}} has confirmed receipt of your wire transfer.

**Wire Details:**
- Amount Received: {{closing.wireAmountReceived | formatCurrency}}
- Date Received: {{closing.wireReceivedDate | formatDate}}
- Status: Cleared and applied

**You're all set for closing!**
- Date: {{deal.closingDate | formatDate 'long'}}
- Time: {{deal.closingTime}}
- Location: {{deal.closingLocation}}

**Don't forget to bring:**
- Valid photo ID
- This is a big moment - maybe a camera!

See you at closing!

{{signature}}
```

#### Wire Instructions Changed (EXTREMELY RARE)
```
Subject: [URGENT] Call Required - Wire Instruction Update | {{deal.address.street}}

{{recipient.firstName}},

We need to speak with you immediately regarding wire instructions.

**DO NOT SEND ANY FUNDS UNTIL WE SPEAK.**

CALL ME NOW: {{agent.phone}}
Or call {{closing.titleCompanyName}}: {{closing.verificationPhone}}

For your protection, wire instruction changes are NEVER communicated via email. I will explain the situation over the phone.

{{signature}}

---
THIS IS UNUSUAL. Wire instruction changes are very rare. If you receive this, please call before taking any action.
```

### SMS Templates

#### Wire Instructions Sent
```
{{agent.firstName}}: Wire instructions for {{deal.address.street | abbreviateAddress}} sent to your email. IMPORTANT: Call {{closing.verificationPhone}} to verify BEFORE sending any funds. Wire fraud is real.
```

#### Wire Reminder
```
{{agent.firstName}}: Reminder - wire {{closing.wireAmount | formatCurrency}} for {{deal.address.street | abbreviateAddress}} closing. Verify by calling {{closing.verificationPhone}} first. Closing {{deal.closingDate | formatShortDate}}.
```

#### Wire Not Yet Received
```
{{agent.firstName}}: Wire not yet received for {{deal.address.street | abbreviateAddress}} closing on {{deal.closingDate | formatShortDate}}. Please send and reply with confirmation number. Call {{agent.phone}} if issues.
```

#### Wire Received
```
{{agent.firstName}}: Wire received for {{deal.address.street | abbreviateAddress}}. You're all set for closing {{deal.closingDate | formatShortDate}} at {{deal.closingTime}}. See you there!
```

#### Wire Fraud Alert (Triggered if suspicious activity)
```
[URGENT] {{recipient.firstName}}: STOP. Do NOT send any wire for {{deal.address.street | abbreviateAddress}}. Call {{agent.phone}} NOW. Potential fraud detected.
```

### Voice Call Scripts

#### Wire Verification Guidance
```
Opening: "Hi {{recipient.firstName}}, this is {{voiceName}} calling on behalf of
{{agent.name}} about your wire transfer for {{deal.address.street}}."

Purpose: "I'm calling to make sure you received the wire instructions
and understand the verification process before sending any funds."

Verification: "Before you wire any money, please call {{closing.titleCompanyName}}
at {{closing.verificationPhone}} to verify every detail - the bank name,
routing number, account number, and beneficiary name."

Warning: "Wire fraud is common in real estate. Never trust email instructions
without phone verification. If anything seems off or if you get new
instructions, stop and call {{agent.firstName}} immediately."

Closing: "Do you have any questions? The amount to wire is
{{closing.wireAmount | formatCurrency}}, and we need it by
{{closing.wireDeadline | formatDate}}."
```

#### Wire Follow-Up Call
```
Opening: "Hi {{recipient.firstName}}, this is {{voiceName}} following up
on your wire transfer for {{deal.address.street}}."

Status Check: "Have you been able to send the wire for your closing?
The title company hasn't received it yet, and closing is
{{deal.closingDate | formatDate}}."

Assistance: "Is there anything preventing you from sending it?
Do you need help with the verification process?"

Next Steps: "Once you send it, please text the confirmation number to
{{agent.phone}} so we can track it."
```

## Template Variables

| Variable | Type | Description | Example |
|----------|------|-------------|---------|
| `closing.wireAmount` | number | Amount to wire | 85432.50 |
| `closing.wireDeadline` | Date | When to send wire | 2025-02-13 |
| `closing.titleCompanyName` | string | Title company | "First American Title" |
| `closing.verificationPhone` | string | Verified phone number | "(512) 555-1234" |
| `closing.wireAmountReceived` | number | Confirmed amount | 85432.50 |
| `closing.wireReceivedDate` | Date | When received | 2025-02-13 |
| `deal.closingDate` | Date | Closing date | 2025-02-15 |
| `deal.closingTime` | string | Closing time | "2:00 PM" |
| `deal.closingLocation` | string | Closing location | "First American Title" |

## Security Protocols

### Never Include in Email
- Full bank account numbers (use PDF attachment)
- Routing numbers in email body
- Changes to wire instructions

### Always Include
- Verification phone number (from verified source)
- Wire fraud warning
- Instructions to call before wiring
- Warning about email compromise

### If Fraud Suspected
1. Immediately send fraud alert
2. Call buyer directly
3. Alert title company
4. Document incident
5. Do NOT proceed until verified

## Wire Timeline

| Days Before Closing | Action | Template |
|--------------------|--------|----------|
| 5-7 days | Send instructions | Wire Instructions Available |
| 3 days | Reminder if not sent | Wire Reminder |
| 2 days | Confirmation request | Wire Confirmation Request |
| 1 day | Urgent follow-up | SMS + Call if not received |
| Day of receipt | Confirmation | Wire Received Confirmation |

## Auto-Send Rules

| Trigger | Template | Auto-Send | Approval |
|---------|----------|-----------|----------|
| Wire instructions from title | Wire Instructions Available | Yes | No |
| 3 days before, not received | Wire Reminder | Yes | No |
| 2 days before, not received | Confirmation Request + SMS | Yes | No |
| Wire confirmed | Wire Received | Yes | No |
| Suspicious activity | Fraud Alert | Immediate | No |

## Error Handling

| Error | Cause | Response |
|-------|-------|----------|
| `WIRE_INSTRUCTIONS_MISSING` | No attachment from title | Alert agent, wait for title |
| `VERIFICATION_PHONE_MISSING` | No verified number | Block send until provided |
| `WIRE_NOT_RECEIVED_CLOSING_DAY` | No funds, closing imminent | Escalate immediately |
| `POTENTIAL_FRAUD` | Suspicious patterns | Fraud alert protocol |

## Quality Checklist

- [x] Every email includes fraud warning
- [x] Verification phone is from verified source (not email)
- [x] Never includes full wire details in email body
- [x] PDF attachment for actual instructions
- [x] Clear deadline and amount
- [x] Tracks wire status
- [x] Confirms receipt
- [x] Has fraud alert protocol
- [x] Multiple channel reminders

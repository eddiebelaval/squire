# Skill: Party Communication Preferences

**Category:** Party
**Priority:** P2
**Approval Required:** No

## Purpose

Manage communication preferences for parties in a transaction. This includes preferred contact methods, timing restrictions, CC/BCC preferences, and notification settings. Ensures communications respect party preferences while maintaining transaction efficiency.

## Triggers

### Voice Commands
- "The buyer prefers text messages"
- "Don't email the seller after 6pm"
- "Always CC the buyer's spouse"
- "The lender only wants weekly updates"
- "[Name] prefers phone calls"
- "Set up communication preferences for [party]"

### Programmatic
- Party onboarding flow
- Communication settings update
- API call to `PATCH /parties/:id/preferences`

## Required Inputs

| Input | Type | Required | Source | Description |
|-------|------|----------|--------|-------------|
| `dealId` | UUID | Yes | context | Deal context |
| `partyId` | UUID | Yes* | context | Party to configure |
| `partyRole` | PartyRole | Yes* | voice | Role to configure |
| `partyName` | string | Yes* | voice | Name to configure |

*One of: `partyId` OR `partyRole` OR `partyName`

## Preference Options

### Contact Method Preferences

| Preference | Type | Default | Description |
|------------|------|---------|-------------|
| `preferredMethod` | enum | 'email' | Primary: 'email', 'phone', 'text', 'any' |
| `allowEmail` | boolean | true | Can send emails |
| `allowSms` | boolean | true | Can send SMS |
| `allowPhone` | boolean | true | Can make calls |
| `urgentMethod` | enum | 'phone' | Method for urgent matters |

### Timing Preferences

| Preference | Type | Default | Description |
|------------|------|---------|-------------|
| `timezone` | string | 'America/New_York' | Party's timezone |
| `contactWindowStart` | time | '09:00' | Earliest contact time |
| `contactWindowEnd` | time | '18:00' | Latest contact time |
| `allowWeekends` | boolean | false | Contact on weekends |
| `quietHoursStart` | time | '21:00' | Do not disturb start |
| `quietHoursEnd` | time | '08:00' | Do not disturb end |

### Notification Preferences

| Preference | Type | Default | Description |
|------------|------|---------|-------------|
| `statusUpdates` | enum | 'all' | 'all', 'major', 'none' |
| `deadlineAlerts` | boolean | true | Receive deadline reminders |
| `documentNotifications` | boolean | true | New document alerts |
| `updateFrequency` | enum | 'realtime' | 'realtime', 'daily', 'weekly' |

### CC/BCC Preferences

| Preference | Type | Default | Description |
|------------|------|---------|-------------|
| `alwaysCc` | string[] | [] | Email addresses to always CC |
| `alwaysBcc` | string[] | [] | Email addresses to always BCC |
| `ccSpouse` | boolean | false | CC spouse on all comms |
| `ccAttorney` | boolean | false | CC attorney on all comms |

## Execution Flow

```
START
  |
  +--- 1. Identify party
  |    +-- Resolve by ID, role, or name
  |    +-- Verify exists on deal
  |
  +--- 2. Parse preference updates
  |    |
  |    +-- Extract preferences from voice/input
  |    +-- Map natural language to settings:
  |    |   +-- "prefers text" → preferredMethod: 'text'
  |    |   +-- "no calls after 6" → contactWindowEnd: '18:00'
  |    |   +-- "CC his wife" → alwaysCc: [spouse_email]
  |    |   +-- "weekly updates only" → updateFrequency: 'weekly'
  |
  +--- 3. Load existing preferences
  |    +-- Get current communication_preferences record
  |    +-- Merge with updates (update only specified)
  |
  +--- 4. Validate preferences
  |    |
  |    +-- At least one contact method allowed
  |    +-- Time windows are valid
  |    +-- CC emails are valid format
  |    +-- Timezone is recognized
  |
  +--- 5. Save preferences
  |    +-- UPSERT communication_preferences
  |    +-- Apply to all deals (if party spans multiple)
  |
  +--- 6. Update scheduled communications
  |    |
  |    +-- IF timing changed:
  |    |   +-- Reschedule pending notifications
  |    |
  |    +-- IF method changed:
  |    |   +-- Update pending comm channels
  |    |
  |    +-- IF CC changed:
  |        +-- Apply to future comms
  |
  +--- 7. Log action
  |    +-- action_type: 'preferences_updated'
  |    +-- Include changed fields
  |
  +-- RETURN updated preferences
```

## Output

```typescript
{
  success: true,
  actionTaken: "Updated communication preferences for John Smith",
  result: {
    party: {
      id: "uuid",
      role: "buyer",
      name: "John Smith"
    },
    preferences: {
      contactMethod: {
        preferred: "text",
        allowed: ["text", "email"],
        urgent: "phone"
      },
      timing: {
        timezone: "America/New_York",
        contactWindow: "9:00 AM - 6:00 PM",
        weekends: false,
        quietHours: "9:00 PM - 8:00 AM"
      },
      notifications: {
        statusUpdates: "major",
        deadlineAlerts: true,
        documentNotifications: true,
        updateFrequency: "realtime"
      },
      cc: {
        always: ["spouse@email.com"],
        bcc: []
      }
    },
    changesApplied: [
      "Set preferred method to text",
      "Added spouse to CC list"
    ],
    pendingCommsUpdated: 3
  }
}
```

## Voice Response

**Setting preferred method:**
> "Got it - John prefers text messages. I'll send him texts for routine updates and only call for urgent matters. Emails will still go out for documents that need signatures."

**Setting timing:**
> "Noted - I won't contact the seller after 6pm or on weekends. All deadline reminders will be scheduled for business hours."

**Adding CC:**
> "I'll CC Maria on all communications to John going forward. She'll receive copies of all emails about the transaction."

**Complex preference:**
> "Updated preferences for the lender: weekly status updates instead of real-time, email only for routine items, phone for urgent matters. I've adjusted 3 pending notifications to follow these preferences."

**Confirming current preferences:**
> "Here are the buyer's current preferences:
> - Preferred contact: text message
> - Contact hours: 9 AM to 6 PM, weekdays only
> - Updates: All status changes
> - CC: None
>
> Would you like to change anything?"

## Natural Language Mappings

| User Says | Preference Set |
|-----------|----------------|
| "prefers text" / "text is best" | preferredMethod: 'text' |
| "email only" | allowPhone: false, allowSms: false |
| "don't call" / "no phone calls" | allowPhone: false |
| "no texts" | allowSms: false |
| "call for urgent" | urgentMethod: 'phone' |
| "after 6 only" | contactWindowStart: '18:00' |
| "before 5pm" | contactWindowEnd: '17:00' |
| "no weekends" | allowWeekends: false |
| "CC the spouse" | alwaysCc: [spouse_email] |
| "weekly updates" | updateFrequency: 'weekly' |
| "major updates only" | statusUpdates: 'major' |
| "quiet after 9" | quietHoursStart: '21:00' |

## Error Handling

| Error | Cause | Response |
|-------|-------|----------|
| `PARTY_NOT_FOUND` | Can't find party | "I couldn't find that party on the deal. Who's preferences are you updating?" |
| `INVALID_TIME` | Bad time format | "I didn't catch the time. Could you give me the hours like '9am to 6pm'?" |
| `ALL_METHODS_DISABLED` | No contact methods | "I need at least one way to reach them. Should I keep email enabled?" |
| `INVALID_EMAIL` | Bad CC email | "That email address doesn't look right. Can you spell it out?" |
| `SPOUSE_NOT_FOUND` | CC spouse but no spouse on file | "I don't have the spouse's email on file. What's their email address?" |

## Default Preferences by Role

| Role | Default Preferred Method | Update Frequency | Notes |
|------|-------------------------|------------------|-------|
| Buyer | email | realtime | All updates |
| Seller | email | realtime | All updates |
| Buyer's Agent | email | realtime | Professional |
| Listing Agent | email | realtime | Professional |
| Lender | email | daily | Business hours |
| Title Company | email | as-needed | Documents only |
| Inspector | phone | as-needed | Scheduling |
| Appraiser | email | as-needed | Reports |
| Attorney | email | realtime | Legal matters |

## Integration Points

### Communication Skills
- send-email respects preferences
- send-sms respects preferences
- Notification scheduler uses timing

### Quiet Hours Handling
- Queue notifications during quiet hours
- Deliver at next available window
- Urgent overrides quiet hours

### Multi-Deal Sync
- Preferences sync across all deals
- Option for deal-specific overrides

## Quality Checklist

- [x] Parses natural language preferences
- [x] Supports all contact methods
- [x] Handles timezone correctly
- [x] Enforces quiet hours
- [x] Manages CC/BCC lists
- [x] Updates pending communications
- [x] Syncs across deals
- [x] Validates all inputs
- [x] Provides sensible defaults
- [x] Respects urgency overrides
- [x] Logs all changes
- [x] Confirms current preferences on request

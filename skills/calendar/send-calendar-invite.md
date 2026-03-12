# Skill: Send Calendar Invite

**Category:** Calendar
**Priority:** P1
**Approval Required:** No

## Purpose

Send calendar invitations (ICS format) to one or more attendees for an appointment. Handles creation and delivery of properly formatted calendar events that integrate with Google Calendar, Outlook, Apple Calendar, and other calendar systems. Supports RSVPs, reminders, and rich event details.

## Triggers

### Voice Commands
- "Send calendar invite for [appointment]"
- "Invite [party] to the [appointment type]"
- "Send [party] the meeting invite"
- "Add [party] to the calendar event"
- "Resend the invite to [party]"
- "Calendar invite for [date/time] to [party]"

### Programmatic
- `POST /appointments/:id/invite`
- Called by scheduling skills automatically
- Called by reschedule skill for updates

### Automatic
- Appointment created (auto-send to attendees)
- Appointment rescheduled (send update)
- New party added to appointment

## Required Inputs

| Input | Type | Required | Source | Description |
|-------|------|----------|--------|-------------|
| `appointmentId` | UUID | Yes* | context | Appointment to invite for |
| `event` | CalendarEvent | Yes* | manual | Custom event details |

*Either appointmentId (to load existing) or event (to create custom) required.

| Input | Type | Required | Source | Description |
|-------|------|----------|--------|-------------|
| `recipients` | string[] | Yes | voice/auto | Email addresses to invite |

## Optional Inputs

| Input | Type | Default | Source | Description |
|-------|------|---------|--------|-------------|
| `updateExisting` | boolean | false | context | Is this an update to existing invite |
| `includeDescription` | boolean | true | default | Include full event description |
| `includeLocation` | boolean | true | default | Include location details |
| `includeReminders` | boolean | true | default | Set default reminders |
| `reminderMinutes` | number[] | [60, 15] | default | Minutes before for reminders |
| `requestRsvp` | boolean | true | default | Request RSVP response |
| `organizerName` | string | agent name | context | Name shown as organizer |
| `organizerEmail` | string | agent email | context | Reply-to email |
| `attachments` | Attachment[] | null | context | Files to attach |
| `conferenceLink` | string | null | voice | Video conference URL |
| `notes` | string | null | voice | Additional notes in invite |
| `visibility` | string | 'default' | default | public, private, confidential |

## Calendar Event Structure

```typescript
interface CalendarEvent {
  // Required
  title: string;
  startDateTime: string; // ISO 8601
  endDateTime: string;   // ISO 8601
  timezone: string;

  // Location
  location?: {
    name?: string;
    address: string;
    latitude?: number;
    longitude?: number;
  };

  // Description
  description?: string;
  htmlDescription?: string;

  // Organizer
  organizer: {
    name: string;
    email: string;
  };

  // Attendees
  attendees: {
    email: string;
    name?: string;
    role: 'required' | 'optional' | 'chair';
    rsvp: boolean;
  }[];

  // Reminders
  reminders?: {
    useDefault: boolean;
    overrides?: {
      method: 'email' | 'popup' | 'sms';
      minutes: number;
    }[];
  };

  // Recurrence (if recurring)
  recurrence?: string[]; // RRULE format

  // Conference
  conferenceData?: {
    type: 'zoom' | 'meet' | 'teams' | 'custom';
    url: string;
    dialIn?: string;
  };

  // Attachments
  attachments?: {
    name: string;
    url: string;
    mimeType: string;
  }[];

  // Metadata
  uid: string;      // Unique event ID
  sequence: number; // Version for updates
  status: 'confirmed' | 'tentative' | 'cancelled';
}
```

## Appointment Type Templates

### Inspection Event

```typescript
const inspectionTemplate = {
  title: "Home Inspection - {address}",
  description: `
    Home Inspection for {address}

    Property Details:
    - Address: {full_address}
    - Type: {inspection_type}

    Access Instructions:
    {access_instructions}

    Inspector: {inspector_name}
    Phone: {inspector_phone}

    Note: Please arrive on time. The inspection typically takes {duration} hours.
  `,
  reminders: [
    { method: 'email', minutes: 1440 }, // 24 hours
    { method: 'popup', minutes: 60 }
  ]
};
```

### Walkthrough Event

```typescript
const walkthroughTemplate = {
  title: "Final Walkthrough - {address}",
  description: `
    Final Walkthrough before Closing

    Property: {address}
    Closing: {closing_date} at {closing_time}

    Access:
    {access_instructions}

    Checklist items to verify:
    {checklist_items}

    Contact your agent with any concerns immediately.
  `,
  reminders: [
    { method: 'popup', minutes: 120 },
    { method: 'popup', minutes: 30 }
  ]
};
```

### Closing Event

```typescript
const closingTemplate = {
  title: "Closing - {address}",
  description: `
    Real Estate Closing

    Property: {address}
    Purchase Price: {price}

    Location: {title_company_name}
    {title_company_address}

    Closer: {closer_name}
    Phone: {closer_phone}

    What to Bring:
    - Valid photo ID (government-issued)
    - {additional_items}

    Wire Instructions: Contact title company directly for wire details.
    Do not send funds to any account provided via email.
  `,
  reminders: [
    { method: 'email', minutes: 1440 }, // 24 hours
    { method: 'popup', minutes: 120 },
    { method: 'popup', minutes: 60 }
  ]
};
```

### Showing Event

```typescript
const showingTemplate = {
  title: "Property Showing - {address}",
  description: `
    Property Showing

    {address}
    MLS#: {mls_number}

    List Price: {list_price}
    {beds} beds | {baths} baths | {sqft} sqft

    Access: {access_instructions}

    Agent: {showing_agent_name}
    Phone: {showing_agent_phone}
  `,
  reminders: [
    { method: 'popup', minutes: 60 }
  ]
};
```

## Execution Flow

```
START
  |
  +--- 1. Load or create event
  |    +-- If appointmentId: load appointment
  |    +-- Build CalendarEvent from appointment data
  |    +-- If custom event: use provided data
  |    +-- Generate unique event UID
  |
  +--- 2. Resolve recipients
  |    +-- If email addresses: use directly
  |    +-- If party names: look up emails
  |    +-- If roles: get all parties with role
  |    +-- Validate all emails
  |
  +--- 3. Build event content
  |    +-- Apply appropriate template
  |    +-- Fill in variables from deal/appointment
  |    +-- Format description (text and HTML)
  |    +-- Add location with maps link
  |    +-- Set reminders
  |    +-- Add conference link if applicable
  |
  +--- 4. Generate ICS file
  |    +-- Create VCALENDAR
  |    +-- Add VEVENT with all details
  |    +-- Set METHOD: REQUEST (new) or PUBLISH (update)
  |    +-- Include ORGANIZER and ATTENDEE
  |    +-- Set sequence number for updates
  |
  +--- 5. Create email with invite
  |    +-- Set appropriate subject
  |    +-- Add friendly email body
  |    +-- Attach ICS file
  |    +-- Use multipart/alternative (HTML + text)
  |
  +--- 6. Send to each recipient
  |    +-- FOR EACH recipient:
  |    |   +-- Customize attendee list (them as required)
  |    |   +-- Send email with ICS
  |    |   +-- Record delivery status
  |    |
  |    +-- Track successful sends
  |
  +--- 7. Update appointment record
  |    +-- Store event UID
  |    +-- Mark invites_sent
  |    +-- Record who was invited
  |
  +--- 8. Log action
  |    +-- action_type: 'calendar_invite_sent'
  |
  +-- RETURN send confirmation
```

## ICS Format Example

```text
BEGIN:VCALENDAR
VERSION:2.0
PRODID:-//Homer Pro//Calendar//EN
CALSCALE:GREGORIAN
METHOD:REQUEST

BEGIN:VEVENT
UID:insp-123-456-789@homerpro.app
DTSTAMP:20260118T140000Z
DTSTART;TZID=America/New_York:20260120T090000
DTEND;TZID=America/New_York:20260120T120000
SUMMARY:Home Inspection - 123 Main St
DESCRIPTION:Home Inspection for 123 Main St, Miami FL 33101\n\nInspector: John Smith Inspections\nPhone: (305) 555-0100\n\nAccess: Lockbox on front door, code 1234
LOCATION:123 Main St, Miami FL 33101
ORGANIZER;CN=Agent Name:mailto:agent@example.com
ATTENDEE;CUTYPE=INDIVIDUAL;ROLE=REQ-PARTICIPANT;PARTSTAT=NEEDS-ACTION;RSVP=TRUE;CN=Jane Buyer:mailto:jane@example.com
ATTENDEE;CUTYPE=INDIVIDUAL;ROLE=REQ-PARTICIPANT;PARTSTAT=ACCEPTED;CN=John Smith:mailto:inspector@example.com
BEGIN:VALARM
ACTION:DISPLAY
DESCRIPTION:Home Inspection in 1 hour
TRIGGER:-PT1H
END:VALARM
BEGIN:VALARM
ACTION:EMAIL
DESCRIPTION:Home Inspection tomorrow
TRIGGER:-P1D
END:VALARM
SEQUENCE:0
STATUS:CONFIRMED
END:VEVENT

END:VCALENDAR
```

## Output

```typescript
{
  success: true,
  actionTaken: "Sent calendar invites to 3 recipients for inspection",
  result: {
    event: {
      uid: "insp-123-456-789@homerpro.app",
      title: "Home Inspection - 123 Main St",
      start: "2026-01-20T09:00:00-05:00",
      end: "2026-01-20T12:00:00-05:00",
      location: "123 Main St, Miami FL 33101",
      sequence: 0,
      type: "new"
    },
    recipients: [
      {
        email: "jane@example.com",
        name: "Jane Buyer",
        role: "buyer",
        status: "sent",
        rsvpRequested: true
      },
      {
        email: "inspector@example.com",
        name: "John Smith",
        role: "inspector",
        status: "sent",
        rsvpRequested: true
      },
      {
        email: "agent@example.com",
        name: "Agent Name",
        role: "buyer_agent",
        status: "sent",
        rsvpRequested: false
      }
    ],
    delivery: {
      sent: 3,
      failed: 0,
      timestamp: "2026-01-18T14:30:00Z"
    },
    reminders: [
      { trigger: "-P1D", method: "email" },
      { trigger: "-PT1H", method: "popup" }
    ]
  }
}
```

## Voice Response

**Invites sent:**
> "I've sent calendar invites for the inspection on Monday at 9 AM to:
> - Jane Buyer
> - John Smith Inspections
> - Yourself
>
> The invite includes the access instructions and a reminder the day before. Jane and the inspector will get an RSVP request."

**Update sent:**
> "I've sent updated calendar invites with the new time - Wednesday at 10 AM.
>
> Everyone's calendars will be updated automatically when they accept. The old time slot will be freed up."

**Adding attendee:**
> "I've added Mike, the listing agent, to the walkthrough calendar invite. He'll receive an invitation with all the details."

## Error Handling

| Error | Cause | Response |
|-------|-------|----------|
| `INVALID_EMAIL` | Bad email address | "The email address for [party] doesn't look right: [email]. Can you verify it?" |
| `NO_APPOINTMENT` | Can't find appointment | "I couldn't find that appointment. Which appointment did you want to send invites for?" |
| `ALREADY_SENT` | Invites already sent | "Invites were already sent for this appointment. Would you like me to resend them?" |
| `SEND_FAILED` | Email delivery failure | "I couldn't send the invite to [email]. The email bounced. Is there a different email address for [party]?" |
| `PAST_EVENT` | Event is in the past | "This appointment already happened. Calendar invites can only be sent for future events." |
| `NO_RECIPIENTS` | No valid recipients | "I don't have email addresses for the attendees. Who should I send invites to?" |

## Email Template

```html
Subject: Calendar Invite: Home Inspection - 123 Main St

<html>
<body>
  <h2>Home Inspection</h2>

  <p>You're invited to a home inspection for <strong>123 Main St, Miami FL 33101</strong>.</p>

  <table>
    <tr><td><strong>When:</strong></td><td>Monday, January 20, 2026 at 9:00 AM</td></tr>
    <tr><td><strong>Duration:</strong></td><td>3 hours</td></tr>
    <tr><td><strong>Where:</strong></td><td>123 Main St, Miami FL 33101</td></tr>
    <tr><td><strong>Inspector:</strong></td><td>John Smith Inspections</td></tr>
  </table>

  <h3>Access Instructions</h3>
  <p>Lockbox on front door. Code: 1234</p>

  <p>Please add this event to your calendar using the attached invitation.</p>

  <p style="color: #666; font-size: 12px;">
    This invitation was sent by Homer Pro on behalf of [Agent Name].
    <br>Reply to this email if you have questions.
  </p>
</body>
</html>
```

## Integration Points

### Used By
- `schedule-inspection` - Send to inspector, buyer
- `schedule-walkthrough` - Send to buyer, agents
- `schedule-closing` - Send to all parties
- `schedule-showing` - Send to buyer
- `reschedule` - Send updated invites

### External Integrations
- SendGrid / AWS SES for email delivery
- ICS file generation
- Google Calendar API (for direct calendar insert)
- Microsoft Graph API (for direct calendar insert)

### Database Tables
- `appointments` - Store event UID, invite status
- `communications` - Record invite emails sent
- `parties` - Recipient lookup

## Example Usage

### From Voice - Automatic
```
Agent: "Schedule inspection for 123 Main St Monday at 9"

Homer: "Inspection scheduled for Monday, January 20th at 9 AM.

        I've sent calendar invites to:
        - Jane Buyer (buyer)
        - John Smith Inspections (inspector)
        - You

        Everyone will get a reminder 24 hours before."
```

### From Voice - Manual
```
Agent: "Send the closing invite to the title company too"

Homer: "Adding First Title Company to the closing calendar invite.

        I'm sending it to closings@firsttitle.com with Sarah
        Johnson as the specific contact.

        Done - they'll receive the invite with all the
        closing details."
```

### From Voice - Resend
```
Agent: "The buyer didn't get the inspection invite, resend it"

Homer: "Resending the inspection calendar invite to Jane Buyer
        at jane@example.com.

        Done. If she still doesn't see it, have her check
        spam or I can try an alternate email address."
```

## Quality Checklist

- [x] Generates valid ICS/iCalendar format
- [x] Works with Google Calendar, Outlook, Apple Calendar
- [x] Includes all relevant event details
- [x] Formats location with address
- [x] Sets appropriate reminders
- [x] Requests RSVP when needed
- [x] Handles event updates (sequence numbers)
- [x] Sends cancellation notices (METHOD:CANCEL)
- [x] Includes HTML email with friendly formatting
- [x] Attaches ICS file correctly
- [x] Tracks delivery status
- [x] Records who was invited
- [x] Handles multiple recipients efficiently
- [x] Handles errors gracefully
- [x] Provides clear confirmation

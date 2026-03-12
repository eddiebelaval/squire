# Skill: Sync Calendars

**Category:** Calendar
**Priority:** P1
**Approval Required:** No

## Purpose

Connect and synchronize external calendars (Google Calendar, Microsoft Outlook, Apple Calendar) with Homer Pro. Enables two-way sync of appointments, availability checking, and automatic updates. Provides unified calendar view for agents and supports calendar connections for deal parties.

## Triggers

### Voice Commands
- "Connect my Google Calendar"
- "Sync my Outlook calendar"
- "Link my calendar"
- "Sync calendars"
- "Refresh calendar sync"
- "Connect [party name]'s calendar"
- "Update calendar integration"
- "Check my calendar connection"

### Programmatic
- `POST /calendar/connect`
- `POST /calendar/sync`
- OAuth callback after authorization
- Settings page integration button

### Automatic
- Daily sync refresh (background)
- Before availability check (on-demand refresh)
- When scheduling (ensure current data)

## Required Inputs

| Input | Type | Required | Source | Description |
|-------|------|----------|--------|-------------|
| `calendarType` | string | Yes | voice/UI | google, outlook, apple, caldav |

## Optional Inputs

| Input | Type | Default | Source | Description |
|-------|------|---------|--------|-------------|
| `partyId` | UUID | null | context | Connect calendar for specific party |
| `syncDirection` | string | 'both' | settings | read, write, both |
| `calendarIds` | string[] | ['primary'] | UI | Which calendars to sync |
| `syncRange` | number | 90 | settings | Days in future to sync |
| `syncFrequency` | string | 'realtime' | settings | realtime, hourly, daily |
| `showBusyOnly` | boolean | false | settings | Only sync busy/free, not details |
| `excludePatterns` | string[] | null | settings | Event titles to exclude |
| `includeAllDay` | boolean | true | settings | Include all-day events |
| `createFromHomer` | boolean | true | settings | Create Homer events in external cal |
| `updateFromExternal` | boolean | false | settings | Allow external changes to Homer events |

## Supported Calendar Systems

| System | Auth Method | API | Features |
|--------|-------------|-----|----------|
| Google Calendar | OAuth 2.0 | Google Calendar API | Full read/write, push notifications |
| Microsoft Outlook | OAuth 2.0 | Microsoft Graph | Full read/write, webhooks |
| Apple iCloud | App-specific password | CalDAV | Read/write, polling only |
| CalDAV Generic | Username/password | CalDAV | Standard support |

## OAuth Flow

### Google Calendar
```
1. User clicks "Connect Google Calendar"
2. Redirect to Google OAuth consent screen
3. User authorizes Homer Pro access
4. Google redirects back with auth code
5. Exchange code for access + refresh tokens
6. Store tokens securely
7. Fetch calendar list
8. User selects calendars to sync
9. Initial sync begins
10. Set up push notifications (webhook)
```

### Microsoft Outlook
```
1. User clicks "Connect Outlook"
2. Redirect to Microsoft OAuth consent screen
3. User authorizes Homer Pro access
4. Microsoft redirects back with auth code
5. Exchange code for access + refresh tokens
6. Store tokens securely
7. Fetch calendar list
8. User selects calendars to sync
9. Initial sync begins
10. Set up change notifications (webhook)
```

## Execution Flow

```
START
  |
  +--- 1. Determine action type
  |    +-- Connect: New calendar connection
  |    +-- Sync: Refresh existing connection
  |    +-- Status: Check connection status
  |
  +--- 2. For new connection (Connect):
  |    |
  |    +--- 2a. Generate OAuth URL
  |    |    +-- Include required scopes
  |    |    +-- Set state token for security
  |    |    +-- Set redirect URI
  |    |
  |    +--- 2b. Redirect user or return URL
  |    |
  |    +--- 2c. Handle OAuth callback
  |    |    +-- Validate state token
  |    |    +-- Exchange code for tokens
  |    |    +-- Validate token response
  |    |
  |    +--- 2d. Store credentials
  |    |    +-- Encrypt tokens
  |    |    +-- Store refresh token
  |    |    +-- Record connection timestamp
  |    |
  |    +--- 2e. Fetch calendar list
  |    |    +-- Get all accessible calendars
  |    |    +-- Let user select which to sync
  |    |
  |    +--- 2f. Initial sync
  |    |    +-- Fetch events in sync range
  |    |    +-- Store in local database
  |    |    +-- Create sync watermark
  |    |
  |    +--- 2g. Set up push notifications
  |         +-- Register webhook (Google/Outlook)
  |         +-- Or set up polling schedule (CalDAV)
  |
  +--- 3. For sync refresh:
  |    |
  |    +--- 3a. Validate connection
  |    |    +-- Check token validity
  |    |    +-- Refresh if needed
  |    |
  |    +--- 3b. Fetch changes since last sync
  |    |    +-- Use sync token/delta link
  |    |    +-- Get new/modified/deleted events
  |    |
  |    +--- 3c. Process incoming changes
  |    |    +-- Update local records
  |    |    +-- Resolve conflicts
  |    |
  |    +--- 3d. Push outgoing changes
  |    |    +-- Homer events to external calendar
  |    |    +-- Update external events
  |    |
  |    +--- 3e. Update sync watermark
  |
  +--- 4. For status check:
  |    +-- Validate token
  |    +-- Report connection status
  |    +-- Show last sync time
  |    +-- Report any errors
  |
  +--- 5. Log action
  |    +-- action_type: 'calendar_synced' or 'calendar_connected'
  |
  +-- RETURN sync status
```

## Data Sync Model

```typescript
interface CalendarSync {
  id: string;
  userId: string;         // Agent or party
  calendarType: 'google' | 'outlook' | 'apple' | 'caldav';
  calendarId: string;     // External calendar ID
  calendarName: string;

  // OAuth
  accessToken: string;    // Encrypted
  refreshToken: string;   // Encrypted
  tokenExpiry: Date;

  // Sync state
  syncToken?: string;     // For incremental sync
  lastSyncAt: Date;
  lastSyncStatus: 'success' | 'error' | 'partial';
  lastError?: string;

  // Settings
  syncDirection: 'read' | 'write' | 'both';
  syncRangeDays: number;
  showBusyOnly: boolean;

  // Webhook
  webhookId?: string;
  webhookExpiry?: Date;

  // Timestamps
  connectedAt: Date;
  updatedAt: Date;
}

interface SyncedEvent {
  id: string;
  calendarSyncId: string;
  externalEventId: string;
  localEventId?: string;  // If linked to Homer appointment

  // Event data
  title: string;
  start: Date;
  end: Date;
  isAllDay: boolean;
  location?: string;
  status: 'busy' | 'free' | 'tentative';

  // Sync metadata
  externalUpdatedAt: Date;
  localUpdatedAt?: Date;
  syncStatus: 'synced' | 'pending' | 'conflict';
}
```

## Output

```typescript
{
  success: true,
  actionTaken: "Connected Google Calendar and synced 47 events",
  result: {
    connection: {
      id: "uuid",
      type: "google",
      account: "agent@gmail.com",
      status: "connected",
      connectedAt: "2026-01-18T14:30:00Z"
    },
    calendars: [
      {
        id: "primary",
        name: "Agent's Calendar",
        selected: true,
        color: "#4285F4"
      },
      {
        id: "work@company.com",
        name: "Work",
        selected: true,
        color: "#7CB342"
      },
      {
        id: "holidays",
        name: "US Holidays",
        selected: false,
        color: "#EA4335"
      }
    ],
    sync: {
      eventsImported: 47,
      eventsExported: 12,
      dateRange: {
        start: "2026-01-18",
        end: "2026-04-18"
      },
      lastSync: "2026-01-18T14:30:00Z"
    },
    webhook: {
      enabled: true,
      expiresAt: "2026-01-25T14:30:00Z"
    },
    nextSteps: [
      "Your calendar is now synced with Homer Pro",
      "Appointments you create here will appear in Google Calendar",
      "I can check your availability when scheduling"
    ]
  }
}
```

## Voice Response

**New connection:**
> "I've connected your Google Calendar. I can see you have 3 calendars:
>
> 1. Your primary calendar - synced
> 2. Work calendar - synced
> 3. US Holidays - not synced (let me know if you want this one too)
>
> I've imported 47 events for the next 90 days. Any appointments you schedule through Homer Pro will automatically appear in your Google Calendar.
>
> I'll also check your calendar when scheduling to avoid conflicts."

**Sync refresh:**
> "I've refreshed your calendar sync. Found 3 new events and 1 update since last sync.
>
> Your calendars are up to date through April 18th."

**Connection status:**
> "Your Google Calendar is connected and syncing properly.
>
> Last sync was 15 minutes ago. You have 2 calendars connected: your primary and work calendars.
>
> Everything looks good."

**Connection issue:**
> "I'm having trouble connecting to your Outlook calendar. The authorization may have expired.
>
> Would you like me to send you a link to reconnect? It only takes a minute."

## Error Handling

| Error | Cause | Response |
|-------|-------|----------|
| `AUTH_REQUIRED` | Not connected or expired | "Your calendar isn't connected yet. Would you like me to send you a link to connect your [type] calendar?" |
| `TOKEN_EXPIRED` | OAuth token expired | "Your calendar connection has expired. I'll need you to reconnect. I'm sending you a link now." |
| `TOKEN_REVOKED` | User revoked access | "It looks like you removed Homer Pro's access to your calendar. Would you like to reconnect?" |
| `CALENDAR_NOT_FOUND` | Calendar deleted externally | "I can't find the calendar '[name]' anymore. It may have been deleted. Would you like to connect a different calendar?" |
| `QUOTA_EXCEEDED` | API rate limit | "I'm temporarily unable to sync your calendar due to rate limits. I'll try again in a few minutes." |
| `SYNC_CONFLICT` | Conflicting changes | "There's a conflict with the event '[title]'. Which version should I keep - the one from Homer Pro or from your calendar?" |
| `NETWORK_ERROR` | Connectivity issue | "I couldn't reach [calendar service] right now. I'll try again automatically in a few minutes." |
| `SCOPE_INSUFFICIENT` | Missing permissions | "I need additional permissions to fully sync your calendar. Would you like to update the connection?" |

## Security Considerations

### Token Storage
- Access tokens encrypted at rest (AES-256)
- Refresh tokens stored separately, encrypted
- Token rotation on every refresh
- Secure deletion on disconnect

### Data Privacy
- Only sync within specified date range
- Option to sync busy/free only (no event details)
- Exclude personal calendar if desired
- No event content stored if showBusyOnly

### Access Control
- Each user connects their own calendar
- Party calendars require party consent
- Agent can't access party calendar details without permission
- Audit log of all calendar access

## Integration Points

### Used By
- `check-availability` - Query synced calendars
- `schedule-inspection` - Avoid conflicts
- `schedule-closing` - Coordinate availability
- `send-calendar-invite` - Direct calendar insert option

### External APIs
- Google Calendar API v3
- Microsoft Graph API
- CalDAV protocol
- Apple iCloud Calendar

### Database Tables
- `calendar_syncs` - Connection records
- `synced_events` - Cached external events
- `sync_logs` - Sync history and errors

## Example Usage

### From Voice - Connect
```
Agent: "Connect my Google Calendar"

Homer: "I'll help you connect your Google Calendar.

        Click this link to authorize access:
        [Authorization Link]

        Once you approve, I'll automatically sync your
        calendar and start checking your availability
        when scheduling appointments.

        You can choose which calendars to include and
        whether Homer appointments should appear in
        your Google Calendar."

[After OAuth]

Homer: "Got it! Your Google Calendar is now connected.

        I found these calendars:
        - Primary (your main calendar) - synced
        - Real Estate - synced
        - Personal - not synced

        I've imported 52 events for the next 90 days.
        You're all set!"
```

### From Voice - Status Check
```
Agent: "Is my calendar synced?"

Homer: "Yes, your Google Calendar is connected and syncing.

        Connected account: agent@gmail.com
        Last sync: 10 minutes ago
        Calendars synced: 2 (Primary, Real Estate)
        Events tracked: 64

        Everything is working normally. I'll automatically
        check this when scheduling to avoid conflicts."
```

### From Voice - Refresh
```
Agent: "Sync my calendar"

Homer: "Refreshing your calendar sync now...

        Done! I found:
        - 2 new events added
        - 1 event updated
        - 1 event cancelled

        Your Homer Pro calendar is up to date."
```

## Quality Checklist

- [x] Supports Google Calendar OAuth 2.0
- [x] Supports Microsoft Outlook/365 OAuth 2.0
- [x] Supports CalDAV for other calendars
- [x] Securely stores OAuth tokens
- [x] Handles token refresh automatically
- [x] Supports multiple calendars per account
- [x] Two-way sync capability
- [x] Incremental sync (delta updates)
- [x] Webhook/push notifications for real-time
- [x] Graceful fallback to polling
- [x] Conflict resolution strategy
- [x] Privacy controls (busy/free only option)
- [x] Clear connection status reporting
- [x] Automatic reconnection prompts
- [x] Handles API errors gracefully
- [x] Audit logging for compliance

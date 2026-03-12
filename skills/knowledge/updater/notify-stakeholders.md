# Skill: Notify Stakeholders

**Category:** Knowledge/Updater
**Priority:** P1
**Approval Required:** No

## Purpose

Communicate knowledge base changes, legal updates, and system modifications to appropriate stakeholders based on impact level, affected areas, and user preferences. This skill ensures agents, admins, and system operators stay informed about changes that affect their operations.

## Voice Commands

- "Notify agents about the inspection period change"
- "Send update briefing to the team"
- "Who needs to know about this change?"
- "Alert everyone with active deals about [change]"

## Triggers

### Automatic
- Knowledge update applied (post update-knowledge)
- Critical change detected (immediate)
- Daily briefing schedule (7 AM)
- Weekly digest schedule (Monday 8 AM)

### Manual
- Admin requests notification send
- Agent asks about pending updates

## Input Schema

```typescript
interface NotifyStakeholdersInput {
  notification_type: "immediate" | "briefing" | "digest" | "custom";
  change_id?: string;
  changes?: ChangeNotification[];
  recipients?: {
    include?: string[];           // Specific user IDs
    exclude?: string[];           // Users to skip
    filter?: {
      has_active_deals?: boolean;
      affected_by_change?: boolean;
      role?: "agent" | "admin" | "broker";
      brokerage_id?: string;
    };
  };
  channels?: ("push" | "email" | "sms" | "in_app")[];
  options?: {
    schedule_for?: string;        // ISO 8601 datetime
    require_acknowledgment?: boolean;
    track_opens?: boolean;
    priority?: "urgent" | "normal" | "low";
  };
}

interface ChangeNotification {
  change_id: string;
  summary: string;
  details: string;
  impact_level: "critical" | "high" | "medium" | "low";
  effective_date: string;
  action_required?: string;
  affected_deals?: number;
  source: string;
}
```

## Output Schema

```typescript
interface NotifyStakeholdersOutput {
  success: boolean;
  actionTaken: string;
  result: {
    notification_id: string;
    type: string;

    delivery_summary: {
      total_recipients: number;
      delivered: number;
      pending: number;
      failed: number;
    };

    by_channel: {
      push: DeliveryStats;
      email: DeliveryStats;
      sms: DeliveryStats;
      in_app: DeliveryStats;
    };

    recipients: RecipientStatus[];

    tracking: {
      opens: number;
      acknowledgments: number;
      link_clicks: number;
    };

    scheduled_followups?: ScheduledFollowup[];
  };
  shouldContinue: boolean;
}

interface DeliveryStats {
  sent: number;
  delivered: number;
  failed: number;
  pending: number;
}

interface RecipientStatus {
  user_id: string;
  name: string;
  role: string;
  channels_sent: string[];
  status: "delivered" | "pending" | "failed";
  acknowledged?: boolean;
  acknowledged_at?: string;
}

interface ScheduledFollowup {
  type: string;
  scheduled_for: string;
  recipients: string[];
}
```

## Execution Flow

```
START
  │
  ├─── 1. Determine notification scope
  │    │
  │    ├── Load change details
  │    ├── Determine impact level
  │    │
  │    └── Set notification parameters:
  │        ├── CRITICAL: Push + Email + SMS + In-App
  │        ├── HIGH: Push + Email + In-App
  │        ├── MEDIUM: Email + In-App
  │        └── LOW: In-App only
  │
  ├─── 2. Identify recipients
  │    │
  │    ├── IF recipients specified:
  │    │   └── Use provided list
  │    │
  │    ├── ELSE determine by impact:
  │    │   │
  │    │   ├── CRITICAL changes:
  │    │   │   └── All agents + All admins + Broker
  │    │   │
  │    │   ├── HIGH changes:
  │    │   │   └── Agents with affected deals + Admins
  │    │   │
  │    │   ├── MEDIUM changes:
  │    │   │   └── Agents with affected deals
  │    │   │
  │    │   └── LOW changes:
  │    │       └── System log only (no notification)
  │    │
  │    └── Apply filters and exclusions
  │
  ├─── 3. Build notification content
  │    │
  │    ├── Select template by type:
  │    │   ├── critical_alert
  │    │   ├── high_priority_update
  │    │   ├── daily_briefing
  │    │   ├── weekly_digest
  │    │   └── custom
  │    │
  │    ├── Personalize for each recipient:
  │    │   ├── Include their affected deals
  │    │   ├── Include relevant action items
  │    │   └── Apply user preferences
  │    │
  │    └── Generate channel-specific versions:
  │        ├── Push: Short summary + action
  │        ├── Email: Full details + links
  │        ├── SMS: Critical info only
  │        └── In-App: Interactive card
  │
  ├─── 4. Respect user preferences
  │    ├── Load notification preferences
  │    ├── Apply quiet hours (if not CRITICAL)
  │    ├── Apply channel preferences
  │    └── Apply frequency limits
  │
  ├─── 5. Send notifications
  │    │
  │    ├── FOR EACH recipient:
  │    │   │
  │    │   ├── FOR EACH enabled channel:
  │    │   │   ├── Send notification
  │    │   │   ├── Track delivery status
  │    │   │   └── Handle failures with retry
  │    │   │
  │    │   └── Record delivery attempt
  │    │
  │    └── Track aggregate statistics
  │
  ├─── 6. Handle acknowledgments (if required)
  │    ├── Set up acknowledgment tracking
  │    ├── Schedule reminder for unacknowledged
  │    └── Escalate if critical and unacknowledged
  │
  ├─── 7. Schedule follow-ups
  │    ├── IF CRITICAL: Schedule 4-hour reminder
  │    ├── IF HIGH: Schedule 24-hour summary
  │    └── Add to weekly digest for all
  │
  └─── 8. Return delivery report
       └── Complete statistics and tracking info
```

## Notification Templates

### Critical Alert (Immediate)

```markdown
## Subject: 🚨 URGENT: {{change.summary}}

Hi {{recipient.name}},

A critical change affecting your transactions has been identified.

### What Changed
{{change.details}}

### Effective Date
{{change.effective_date}}

### Your Affected Deals
{{#each affected_deals}}
- **{{property_address}}** ({{stage}})
  - Impact: {{impact_description}}
  - Action Required: {{action_required}}
{{/each}}

### Required Action
{{change.action_required}}

Homer has flagged this for your attention. Some automated features may be
paused until you acknowledge this update.

[Acknowledge Update] [View Full Details] [Contact Support]

---
Source: {{change.source}}
Detected: {{detection_timestamp}}
```

### Daily Briefing

```markdown
## Subject: Homer Daily Briefing - {{date}}

Good morning, {{recipient.name}}!

Here's your daily update from Homer.

### Legal & Regulatory Updates

{{#if legal_updates}}
{{#each legal_updates}}
**{{summary}}**
- Impact: {{impact_level}}
- Effective: {{effective_date}}
- {{action_required}}
{{/each}}
{{else}}
No legal updates today.
{{/if}}

### Market Updates

- Interest Rate: {{interest_rate}}% ({{rate_change}})
- Active Inventory: {{inventory_count}} ({{inventory_change}})
- Avg Days on Market: {{dom}} days

### Your Deals Today

{{#each deals_with_deadlines_today}}
- **{{property_address}}**: {{deadline_name}} due today
{{/each}}

### Pending Actions

{{#each pending_actions}}
- {{action_description}} ({{priority}})
{{/each}}

Have a great day!
Homer
```

### Weekly Digest

```markdown
## Subject: Homer Weekly Digest - Week of {{week_start}}

Hi {{recipient.name}},

Here's your weekly summary.

### This Week's Updates

{{#each weekly_changes}}
**{{summary}}** ({{impact_level}})
{{/each}}

### Week in Review

- Deals Progressed: {{deals_progressed}}
- Deadlines Met: {{deadlines_met}} / {{deadlines_total}}
- Documents Generated: {{docs_generated}}

### Coming Up Next Week

{{#each upcoming_deadlines}}
- {{date}}: {{deadline_name}} for {{property_address}}
{{/each}}

### Market Snapshot

| Metric | This Week | Change |
|--------|-----------|--------|
| Interest Rate | {{rate}}% | {{rate_change}} |
| New Listings | {{new_listings}} | {{listings_change}} |
| Avg Price | ${{avg_price}} | {{price_change}} |

Best,
Homer
```

### Push Notification

```json
{
  "title": "🚨 Inspection Period Change",
  "body": "Default inspection period reduced to 10 days. Tap to learn more.",
  "data": {
    "change_id": "chg-inspection-period",
    "action": "VIEW_CHANGE",
    "priority": "critical"
  },
  "ios": {
    "sound": "urgent.caf",
    "badge": 1
  },
  "android": {
    "channel_id": "critical_updates",
    "priority": "high"
  }
}
```

## Notification Channels

### Channel Selection by Impact

| Impact Level | Push | Email | SMS | In-App |
|--------------|------|-------|-----|--------|
| CRITICAL | Yes | Yes | Yes | Yes |
| HIGH | Yes | Yes | No | Yes |
| MEDIUM | No | Yes | No | Yes |
| LOW | No | No | No | Yes |

### Channel Configuration

```typescript
const CHANNEL_CONFIG = {
  push: {
    provider: "firebase",
    critical_bypass_dnd: true,
    max_per_hour: 5,
    batch_window_seconds: 60
  },
  email: {
    provider: "sendgrid",
    from: "homer@homerpro.com",
    reply_to: "support@homerpro.com",
    track_opens: true,
    track_clicks: true
  },
  sms: {
    provider: "twilio",
    from: "+1XXXXXXXXXX",
    critical_only: true,
    max_length: 160
  },
  in_app: {
    persist_until_read: true,
    badge_count: true,
    group_by_type: true
  }
};
```

## User Preferences

```typescript
interface NotificationPreferences {
  user_id: string;

  channels: {
    push: { enabled: boolean; quiet_hours?: QuietHours };
    email: { enabled: boolean; digest_only?: boolean };
    sms: { enabled: boolean; critical_only?: boolean };
    in_app: { enabled: boolean };
  };

  quiet_hours: {
    enabled: boolean;
    start: string;  // "22:00"
    end: string;    // "07:00"
    timezone: string;
    override_for_critical: boolean;
  };

  frequency: {
    daily_briefing: boolean;
    weekly_digest: boolean;
    immediate_critical: boolean;
    immediate_high: boolean;
  };

  topics: {
    legal_updates: boolean;
    market_updates: boolean;
    system_updates: boolean;
    deal_updates: boolean;
  };
}
```

## Escalation Rules

```yaml
critical_unacknowledged:
  - 1 hour: Send reminder via push + email
  - 4 hours: Send SMS
  - 8 hours: Escalate to broker/admin
  - 24 hours: Pause affected features, require acknowledgment

high_unacknowledged:
  - 24 hours: Send reminder via push
  - 48 hours: Include in next briefing with emphasis
  - 72 hours: Escalate to admin
```

## Error Handling

| Error | Cause | Response |
|-------|-------|----------|
| `DELIVERY_FAILED` | Channel unavailable | Retry with backoff, try alternate channel |
| `INVALID_RECIPIENT` | User not found | Log warning, continue with others |
| `RATE_LIMITED` | Too many notifications | Queue for later delivery |
| `PREFERENCE_CONFLICT` | User opted out | Respect preference (except CRITICAL) |
| `TEMPLATE_ERROR` | Missing template variables | Use fallback template, alert admin |

## Quality Checklist

- [x] Respects user notification preferences
- [x] Observes quiet hours (except for CRITICAL)
- [x] Sends via appropriate channels by impact level
- [x] Personalizes content for each recipient
- [x] Tracks delivery and engagement
- [x] Handles acknowledgment requirements
- [x] Escalates unacknowledged critical updates
- [x] Batches notifications when appropriate
- [x] Respects rate limits
- [x] Provides unsubscribe options (except CRITICAL)
- [x] Maintains notification history
- [x] Supports scheduling for later delivery

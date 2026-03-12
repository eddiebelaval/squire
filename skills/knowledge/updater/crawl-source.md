# Skill: Crawl Source

**Category:** Knowledge/Updater
**Priority:** P1
**Approval Required:** No

## Purpose

Crawl web sources to retrieve current content for change detection. This skill handles the technical aspects of fetching, parsing, and storing content from monitored legal, market, and industry sources while respecting rate limits and handling authentication.

## Voice Commands

- "Crawl the Florida Realtors website for updates"
- "Check [source name] for new content"
- "Refresh all monitored sources"
- "Force refresh [source] even if recently checked"

## Triggers

### Scheduled
- **Continuous:** Sources crawled based on their configured frequency
- **Daily:** High-priority sources (Florida Realtors, NAR)
- **Weekly:** Legal/statutory sources (flsenate.gov, FREC)
- **Monthly:** Slow-changing sources (HUD, CFPB)

### Event-Based
- Monitor skill requests fresh content
- Admin triggers manual refresh
- Error recovery after source failure

## Input Schema

```typescript
interface CrawlSourceInput {
  source_id?: string;              // Specific source to crawl
  source_url?: string;             // Direct URL to crawl
  source_type?: "legal" | "market" | "industry" | "news" | "forms";
  force_refresh?: boolean;         // Ignore last_crawl timestamp
  extract_selector?: string;       // CSS selector for content extraction
  authentication?: {
    type: "none" | "basic" | "oauth" | "api_key";
    credentials_key?: string;      // Reference to stored credentials
  };
  options?: {
    follow_redirects?: boolean;
    max_depth?: number;            // For multi-page crawls
    wait_for_selector?: string;    // For JS-rendered content
    timeout_ms?: number;
    user_agent?: string;
  };
}
```

## Output Schema

```typescript
interface CrawlSourceOutput {
  success: boolean;
  actionTaken: string;
  result: {
    source_id: string;
    source_url: string;
    crawl_timestamp: string;        // ISO 8601
    content_hash: string;           // SHA-256 of content
    previous_hash?: string;
    content_changed: boolean;
    content: {
      raw_html?: string;
      extracted_text: string;
      structured_data?: Record<string, unknown>;
      metadata: {
        title: string;
        last_modified?: string;
        content_length: number;
        encoding: string;
      };
    };
    screenshots?: {
      viewport: string;             // URL to stored screenshot
      full_page?: string;
    };
    links_found?: string[];
    errors?: string[];
    next_scheduled_crawl: string;
  };
  shouldContinue: boolean;
}
```

## Execution Flow

```
START
  │
  ├─── 1. Validate input
  │    ├── Resolve source_id to URL if provided
  │    ├── Validate URL format
  │    └── Check rate limits for this source
  │
  ├─── 2. Check crawl eligibility
  │    ├── Load source configuration
  │    ├── Get last_crawl timestamp
  │    ├── IF force_refresh = false AND recently_crawled:
  │    │   └── Return cached content with content_changed: false
  │    └── ELSE: Continue to crawl
  │
  ├─── 3. Initialize browser/fetch
  │    │
  │    ├── IF source requires JavaScript rendering:
  │    │   ├── Launch headless browser (Playwright)
  │    │   ├── Configure viewport (1920x1080)
  │    │   └── Set user agent
  │    │
  │    └── ELSE (static content):
  │        └── Use fetch with appropriate headers
  │
  ├─── 4. Handle authentication (if required)
  │    ├── Retrieve credentials from secure store
  │    ├── Apply authentication method
  │    └── Verify access granted
  │
  ├─── 5. Fetch content
  │    │
  │    ├── Navigate to URL
  │    │
  │    ├── Wait for content (if JS-rendered):
  │    │   ├── Wait for selector if specified
  │    │   ├── Wait for network idle
  │    │   └── Handle lazy loading
  │    │
  │    ├── Extract content:
  │    │   ├── Apply CSS selector if specified
  │    │   ├── Get page title
  │    │   ├── Get meta information
  │    │   └── Extract main content
  │    │
  │    └── Take screenshot (optional)
  │
  ├─── 6. Process content
  │    ├── Clean HTML (remove scripts, styles, ads)
  │    ├── Extract plain text
  │    ├── Parse structured data (tables, lists)
  │    ├── Calculate content hash
  │    └── Compare to previous hash
  │
  ├─── 7. Store results
  │    ├── Save content snapshot
  │    ├── Update source.last_crawl_at
  │    ├── Store content hash
  │    └── Queue for change detection if changed
  │
  └─── 8. Return results
       └── Include all metadata for downstream processing
```

## Source Configuration Schema

```typescript
interface SourceConfiguration {
  id: string;
  name: string;
  url: string;
  type: "legal" | "market" | "industry" | "news" | "forms";
  frequency: "hourly" | "daily" | "weekly" | "monthly";
  priority: "critical" | "high" | "medium" | "low";
  requires_js: boolean;
  extract_selector?: string;
  authentication?: {
    type: string;
    credentials_key: string;
  };
  rate_limit: {
    requests_per_hour: number;
    min_interval_seconds: number;
  };
  last_crawl_at?: string;
  last_hash?: string;
  consecutive_failures: number;
  enabled: boolean;
}
```

## Crawl Examples

### Example 1: Florida Realtors Legal Updates

```yaml
source_id: florida-realtors-legal
url: https://www.floridarealtors.org/law-ethics
type: legal
frequency: daily

request:
  source_id: florida-realtors-legal
  force_refresh: false

result:
  success: true
  content_hash: "sha256:a1b2c3..."
  previous_hash: "sha256:d4e5f6..."
  content_changed: true
  content:
    extracted_text: |
      Latest Legal Updates

      January 15, 2026
      New Wire Fraud Disclosure Requirements
      Effective July 1, 2026, all agents must provide...
```

### Example 2: Florida Statutes (JavaScript Required)

```yaml
source_id: fl-statutes-475
url: https://www.flsenate.gov/Laws/Statutes/2026/Chapter475
type: legal
frequency: weekly
requires_js: true
wait_for_selector: "#statutes-content"

result:
  success: true
  content_changed: false
  next_scheduled_crawl: "2026-01-22T08:00:00Z"
```

### Example 3: Rate-Limited Source

```yaml
source_id: mls-bright-updates
url: https://brightmls.com/updates

rate_limit_status:
  requests_today: 45
  limit: 50
  next_allowed: "2026-01-16T00:00:00Z"

result:
  success: false
  error: "RATE_LIMITED"
  message: "Rate limit reached. Will retry in 6 hours."
```

## Rate Limit Configuration

```typescript
const DEFAULT_RATE_LIMITS = {
  "floridarealtors.org": { requests_per_hour: 10, min_interval_seconds: 360 },
  "flsenate.gov": { requests_per_hour: 5, min_interval_seconds: 720 },
  "nar.realtor": { requests_per_hour: 20, min_interval_seconds: 180 },
  "default": { requests_per_hour: 30, min_interval_seconds: 120 }
};
```

## Error Handling

| Error | Cause | Response |
|-------|-------|----------|
| `SOURCE_UNAVAILABLE` | 4xx/5xx response | Retry with backoff, log failure |
| `RATE_LIMITED` | Too many requests | Wait until rate limit resets |
| `TIMEOUT` | Page load too slow | Increase timeout, retry once |
| `AUTH_FAILED` | Credentials invalid | Alert admin, disable source |
| `SELECTOR_NOT_FOUND` | Page structure changed | Use full page, alert admin |
| `BLOCKED` | IP or bot detection | Rotate user agent, alert admin |
| `SSL_ERROR` | Certificate issue | Log warning, attempt without verification |

## Anti-Detection Measures

```typescript
const CRAWL_CONFIG = {
  // Rotate user agents
  userAgents: [
    "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7)...",
    "Mozilla/5.0 (Windows NT 10.0; Win64; x64)..."
  ],

  // Randomize timing
  delayRange: { min: 2000, max: 5000 },

  // Respect robots.txt
  respectRobotsTxt: true,

  // Identify as legitimate monitor
  customHeaders: {
    "X-Bot-Purpose": "Legal compliance monitoring",
    "X-Contact": "support@homerpro.com"
  }
};
```

## Quality Checklist

- [x] Respects rate limits per source
- [x] Handles JavaScript-rendered content
- [x] Supports multiple authentication methods
- [x] Stores content snapshots for comparison
- [x] Calculates content hashes consistently
- [x] Handles redirects and pagination
- [x] Retries with exponential backoff
- [x] Logs all crawl attempts
- [x] Screenshots pages for verification
- [x] Queues changed content for detection
- [x] Respects robots.txt
- [x] Identifies as legitimate compliance bot

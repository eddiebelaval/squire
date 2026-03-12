# /announce-release - Full Release Announcement Pipeline

Orchestrates the complete release announcement: essay generation, website publishing, and social distribution.

## Usage

```
/announce-release <version> "<features summary>"
/announce-release v1.2.0 "New dashboard with real-time metrics"
/announce-release --research "<topic>"  # For research articles instead
```

## Pipeline Stages

### Stage 1: Content Generation
```
┌─────────────────────────────────────┐
│  /write-release OR /write-research  │
│  Apply Eddie's voice profile         │
│  Generate full MDX content           │
└─────────────────────────────────────┘
                  ↓
           [Review content]
                  ↓
```

### Stage 2: Website Publishing
```
┌─────────────────────────────────────┐
│        /publish-essay                │
│  Create MDX file in id8labs-hub      │
│  Git commit and push                 │
│  Trigger Vercel deploy               │
└─────────────────────────────────────┘
                  ↓
      [Wait for deploy ~60s]
                  ↓
```

### Stage 3: Social Distribution
```
┌─────────────────────────────────────┐
│  /post-tweet (X/Twitter)             │
│  Generate thread from essay          │
│  Optimize with x-viral-optimizer     │
│  Post to @id8labs                    │
└─────────────────────────────────────┘
                  ↓
┌─────────────────────────────────────┐
│  /post-linkedin                      │
│  Adapt essay for LinkedIn format     │
│  Post to Eddie's profile             │
│  Add hashtags in comment             │
└─────────────────────────────────────┘
```

## Process

1. **Generate Content**
   - If release: Run `/write-release <version> "<summary>"`
   - If research: Run `/write-research "<topic>"`
   - Display content for review
   - Allow edits before proceeding

2. **Confirm Publication**
   - Show essay title, slug, category
   - Confirm ready to publish
   - User approval required before git push

3. **Publish to Website**
   - Run `/publish-essay`
   - Wait for Vercel deploy completion
   - Verify essay URL is accessible

4. **Generate Social Content**

   **For X/Twitter:**
   - Extract hook + key insights
   - Format as thread (if > 280 chars)
   - Run through x-viral-optimizer
   - Display score and suggestions

   **For LinkedIn:**
   - Adapt full essay to LinkedIn format
   - Adjust tone (professional Eddie)
   - Add line breaks and structure

5. **Post to Social**
   - Confirm each platform before posting
   - Use Playwright/Comet for automation
   - Capture confirmation screenshots
   - Return posted URLs

6. **Summary Report**
   ```
   ✅ Release Announcement Complete

   Essay: https://id8labs.app/essays/{slug}
   X: https://x.com/id8labs/status/{id}
   LinkedIn: https://linkedin.com/posts/{id}

   Next: Monitor engagement after 1 hour
   ```

## Example Full Run

```
User: /announce-release v1.2.0 "New signal-based dashboard with real-time metrics"

Claude: Starting release announcement pipeline...

[Stage 1: Content Generation]
Generating essay with Eddie's voice...

---
Title: "Building the Dashboard I Needed"
Subtitle: "v1.2.0 brings signal-based metrics to ID8Labs"
Category: release
---

I'll be honest — I've been staring at dashboards my whole career...
[Full content preview]
...

Ready to proceed to publishing? (y/n)

User: y

[Stage 2: Website Publishing]
Creating MDX file: building-the-dashboard-i-needed.mdx
Committing to id8labs-hub...
Pushing to main...
Deploy triggered on Vercel...
Waiting for production deploy... ✅

Essay live at: https://id8labs.app/essays/building-the-dashboard-i-needed

[Stage 3: Social Distribution]

X/Twitter Thread Preview:
---
Thread 1/3: I'll be honest — I've been staring at dashboards my whole career. None of them told me if I was winning.

Thread 2/3: So we built something different. Signal-based. Focused. Actually useful.

Thread 3/3: v1.2.0 is live. Come see what dashboards should have been.
https://id8labs.app/essays/building-the-dashboard-i-needed
---
Viral Score: 78/100

Post to X? (y/n)
User: y
Posted! https://x.com/id8labs/status/123456789

LinkedIn Preview:
---
I've spent 15 years staring at dashboards...
[Adapted content]
---

Post to LinkedIn? (y/n)
User: y
Posted! https://linkedin.com/posts/eddiebelaval/123456

✅ Release Announcement Complete!
```

## ID8Pipeline Integration

This skill implements **Stage 10.5: ANNOUNCE** in the ID8Pipeline.

After Stage 10 (Ship), the announce stage ensures:
- Release is documented on the website
- Community is informed via social
- Content is created in Eddie's voice
- Distribution is consistent and tracked

## Checkpoint

"Is the release announced on website and social?"
- Essay published at id8labs.app/essays/{slug}
- X thread posted from @id8labs
- LinkedIn post from Eddie's profile

## Error Recovery

If any stage fails, follow this protocol:

### Stage 1 Failure (Content Generation)
- **Cause:** Writer prompt issue, API timeout
- **Action:** Retry `/write-release` or `/write-research` with adjusted parameters
- **No rollback needed** — nothing published yet

### Stage 2 Failure (Website Publishing)
- **Cause:** Git push failure, Vercel deploy timeout, MDX syntax error
- **Action:**
  1. Check `git status` for uncommitted state
  2. If MDX was committed but deploy failed: check Vercel dashboard or retry `vercel --prod`
  3. If MDX has syntax errors: fix and recommit
- **Rollback:** `git revert HEAD` to unpublish if content was pushed but shouldn't be live

### Stage 3 Failure (Social Distribution)
- **Cause:** Browser automation failure, login expired, rate limit
- **Action:**
  1. Report which platform failed (X, LinkedIn, or both)
  2. Offer to retry just the failed platform
  3. Offer to skip and continue with remaining platforms
  4. Essay remains published regardless — social is additive
- **No rollback** — partial social distribution is fine

### Resume Support

If the pipeline is interrupted at any point:
```
/announce-release --resume
```
Claude will check:
1. Does the essay draft exist? (Skip Stage 1 if yes)
2. Is the essay published at id8labs.app? (Skip Stage 2 if yes)
3. Were social posts made? (Only post to missing platforms)

## Requirements

- All sub-skills configured (/write-release, /publish-essay, /post-tweet, /post-linkedin)
- Git access to id8labs-hub repo
- Comet browser running with debugging
- Logged into X as @id8labs
- Logged into LinkedIn as Eddie Belaval

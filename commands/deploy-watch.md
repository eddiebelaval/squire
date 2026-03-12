# /deploy-watch - Monitor Vercel Deployment Status

Watch a Vercel deployment until it's live, errored, or timed out. Designed to be used with `/loop` for hands-free monitoring.

## Pre-computed Context

```bash
PROJECT_NAME=$(basename $(pwd))
HAS_VERCEL=$(test -f .vercel/project.json && echo "yes" || echo "no")
CURRENT_BRANCH=$(git branch --show-current)
```

**Project:** $PROJECT_NAME
**Branch:** $CURRENT_BRANCH

## Usage

```
/deploy-watch                    # Check latest deployment status (one-shot)
/loop 30s /deploy-watch          # Poll every 30s until live
```

## Arguments

$ARGUMENTS

## Workflow

### Step 1: Get Latest Deployment

Run: `vercel ls --limit 3 2>/dev/null`

Parse the output to identify:
- Deployment URL
- State (BUILDING / READY / ERROR / QUEUED / CANCELED)
- Age (how long ago it started)

### Step 2: Report Status

Output a single concise line based on state:

- **QUEUED/BUILDING:** `[BUILDING] project-abc123.vercel.app — started Xs ago`
- **READY:** `[LIVE] project-abc123.vercel.app — deployed in Xs`
- **ERROR:** `[FAILED] project-abc123.vercel.app — check vercel logs`
- **CANCELED:** `[CANCELED] deployment was canceled`

### Step 3: Health Check (READY only)

When deployment is READY:
1. `curl -s -o /dev/null -w "%{http_code}" https://{production-url}` to verify HTTP 200
2. If 200: report `[LIVE] {url} — verified healthy`
3. If not 200: report `[LIVE BUT UNHEALTHY] {url} — HTTP {code}`

### Step 4: Terminal Condition

If state is READY, ERROR, or CANCELED — this is a terminal state. Say so clearly so `/loop` users know they can stop:

```
Deploy complete. You can stop watching: Ctrl+C or /loop stop
```

## Error Handling

- If `vercel` CLI not found: report and suggest `npm i -g vercel`
- If no deployments found: report "no active deployments"
- If `.vercel/project.json` missing: warn but try anyway (might be auto-linked)

## Notes

- Keep output SHORT. This runs every 30s in a loop — no walls of text.
- One status line + one action line max.
- Do NOT re-read files or explore the codebase. Just run vercel + curl.

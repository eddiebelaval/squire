# /deploy - Production Deployment

Detect project, verify readiness, trigger deploy, and confirm live.

## Pre-computed Context

```bash
PROJECT_NAME=$(basename $(pwd))
HAS_VERCEL=$(test -f .vercel/project.json && echo "yes" || echo "no")
VERCEL_PROJECT=$(cat .vercel/project.json 2>/dev/null | jq -r '.projectId // "unknown"')
CURRENT_BRANCH=$(git branch --show-current)
OPEN_PRS=$(gh pr list --state open --json number,title,headRefName 2>/dev/null)
LAST_DEPLOY=$(vercel ls --limit 1 2>/dev/null | tail -1)
```

**Project:** $PROJECT_NAME
**Vercel Configured:** $HAS_VERCEL
**Current Branch:** $CURRENT_BRANCH
**Open PRs:** $OPEN_PRS

## Usage

```
/deploy                    # Deploy current project to production
/deploy --status           # Check current deployment status
/deploy --rollback         # Revert to previous deployment
/deploy --preview          # Deploy preview (non-production)
```

## User Intent

$ARGUMENTS

## Deploy Workflow

### Step 1: Pre-flight Checks

1. **Verify on main branch** (or confirm intent to deploy from feature branch)
2. **Check for unmerged PRs** that should go out first
3. **Run quick verification:**
```bash
npm run build && npx tsc --noEmit
```
4. **Check git status** — warn if uncommitted changes exist

### Step 2: Trigger Deployment

**Auto-deploy from main (default):**
```bash
git push origin main
# Vercel auto-deploys from main
```

**Manual production deploy:**
```bash
vercel --prod
```

### Step 3: Monitor Deploy

Use `/deploy-watch` for monitoring. Two options:

**Option A (interactive):** `/loop 30s /deploy-watch` — polls every 30s, you see updates in real time
**Option B (background):** Set up a CronCreate job with `/deploy-watch` every 2 min — monitors while you work on other things

If neither is requested, fall back to inline polling (every 10s, timeout at 5 min):
1. Report deployment URL
2. Check HTTP status of production URL

### Step 4: Smoke Test

1. Hit the root URL — verify 200 response
2. If API routes exist, hit `/api/health` or equivalent
3. Use Playwright MCP to take a screenshot of the live site
4. Report pass/fail

### Step 5: Summary

```
Deploy Complete

Project:  $PROJECT_NAME
URL:      https://{domain}
Status:   LIVE
Duration: Xs
Smoke:    PASS

Previous: https://{previous-deploy-url} (rollback target)
```

## Rollback

When `--rollback` is specified:

1. List recent deployments: `vercel ls --limit 5`
2. Show which deployment is currently active
3. Ask user to confirm rollback target
4. Execute: `vercel rollback [deployment-url]`
5. Verify rollback with smoke test

## Status Check

When `--status` is specified:

1. Show current production deployment
2. Show any in-progress deployments
3. Show last 5 deployment history
4. Report domain health (HTTP status check)

## Project Type Detection

- **Vercel project:** Use `vercel` CLI
- **No Vercel config:** Check for `fly.toml` (Fly.io), `Dockerfile`, or `railway.json`
- **Static site:** Suggest `vercel --prod` or manual upload

## Error Handling

- **Build failure:** Show error, do NOT deploy
- **Deploy timeout:** Report last known state, provide manual check command
- **Smoke test failure:** Warn user, suggest rollback, do NOT auto-rollback (user decides)

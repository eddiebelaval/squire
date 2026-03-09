---
title: "Deploy: [Feature/Release Name]"
date: [YYYY-MM-DD]
author: [Name]
branch: [branch-name]
target: Production | Staging
---

# Deployment: [Feature/Release Name]

## Pre-Deploy Checks

### Code Quality

- [ ] Build passes
- [ ] Type-check passes
- [ ] Lint passes (or no new warnings)
- [ ] All tests passing
- [ ] PR reviewed and approved
- [ ] No `console.log` statements left in production code
- [ ] No hardcoded secrets or API keys

### Environment Variables

| Variable | Added To | Verified |
|----------|----------|----------|
| `[VAR_NAME]` | [Platform] | [ ] |

### Database Migrations

- [ ] Migration tested on staging
- [ ] Rollback SQL prepared
- [ ] No breaking changes to existing data
- [ ] Access policies verified

### Dependencies

- [ ] No new vulnerabilities (`npm audit` / equivalent)
- [ ] Lock file committed
- [ ] No unnecessary new dependencies

## Deploy Steps

1. [ ] Merge PR to main
2. [ ] Verify build succeeds
3. [ ] Apply database migrations (if any)
4. [ ] Verify deployment URL is live

## Smoke Tests

- [ ] Homepage loads
- [ ] Authentication works (login/logout)
- [ ] [Critical user flow 1]
- [ ] [Critical user flow 2]
- [ ] API endpoints respond correctly
- [ ] Mobile viewport renders properly
- [ ] No console errors in browser

## Rollback Procedure

**If something goes wrong:**

1. Revert the merge commit: `git revert [sha] && git push`
2. Platform auto-deploys the revert
3. Roll back database migration (if applied)
4. Verify rollback with smoke tests above
5. Investigate root cause before re-deploying

## Post-Deploy Verification

- [ ] Production URL tested
- [ ] No new errors in logs
- [ ] Performance acceptable (no major regressions)
- [ ] Team notified of successful deploy

## Notes

[Any deployment-specific notes, known issues, or follow-up tasks.]

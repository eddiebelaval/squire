# /ship - Complete Feature & Create PR

You are helping ship a completed feature. Follow these steps:

1. **Verify Everything Works**
   - Run all tests and ensure they pass
   - Check build succeeds in production mode
   - Verify no TypeScript/linting errors

2. **Create Summary**
   - List all files changed
   - Summarize what was built in plain English
   - Note any important decisions made

3. **Commit Changes** (if uncommitted)
   - Stage all relevant files
   - Create a meaningful commit message
   - Follow format: "feat: [description]"

4. **Triad Check** (if project has VISION.md + SPEC.md)
   - Scan the diff for new routes, pages, components, API endpoints
   - Cross-reference with SPEC.md capabilities
   - If new capabilities not in SPEC: use AskUserQuestion to confirm adding them
   - If changes touch a VISION pillar: ask if pillar status should change
   - Update SPEC.md and/or VISION.md before creating PR
   - Reference: `~/.claude/skills/triad-derive/AUTOMATION.md`

5. **Push & Create PR**
   - Push branch to remote
   - Create PR with clear description
   - Include test plan and screenshots if applicable

5. **Final Report**
   - Provide PR URL
   - Summarize what's ready to review
   - Note any follow-up items

6. **Monitor Deploy** (if Vercel project)
   - After PR is created or push lands, suggest: `/loop 30s /deploy-watch`
   - Or set up a Cron watch: `CronCreate` with `/deploy-watch` every 2 min for background monitoring

**Important**: Only proceed if all checks pass. If anything fails, fix it first before creating the PR.

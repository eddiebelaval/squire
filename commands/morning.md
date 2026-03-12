# /morning - Daily Morning Brief

Load context, check status across all projects, surface priorities for the day.

## Pre-computed Context

```bash
TODAY=$(date +%Y-%m-%d)
DAY_OF_WEEK=$(date +%A)
```

**Date:** $TODAY ($DAY_OF_WEEK)

## Process

### 1. Load Memory Context

Read `~/.claude/MEMORY.md` for:
- Active projects and their status
- Current focus area
- Any deadlines or reminders

Read session log (if configured) for:
- What was worked on yesterday
- Any unfinished tasks or blockers

### 2. Cross-Project Git Status

Check each active project for uncommitted work and open PRs:

```bash
# Configure: Add your project directories here
# Example:
# cd ~/Development/project-a && echo "=== PROJECT A ===" && git status -s && git log --oneline -3
# cd ~/Development/project-b && echo "=== PROJECT B ===" && git status -s && git log --oneline -3
```

Check for open PRs across repos:
```bash
gh pr list --state open --json title,url,repository 2>/dev/null
```

### 3. Active Tasks

Scan workspace task directories for active tasks:

```bash
# Configure: Add your project workspace paths here
# Example:
# ls ~/Development/project-a/workspace/tasks/*.md 2>/dev/null
# ls ~/Development/project-b/workspace/tasks/*.md 2>/dev/null
```

Sort by priority (high > medium > low).

### 4. Infrastructure Health

Check for any background job status:
```bash
# Configure: Add your monitoring commands here
# Example:
# launchctl list | grep -i my-jobs 2>/dev/null
```

### 5. Deadlines & Reminders

Check MEMORY.md for any upcoming deadlines.

### 6. Present Morning Brief

Format the output as a concise brief:

```
Morning Brief - [date]

YESTERDAY
- [Summary of last session's work]

UNCOMMITTED WORK
- [Project]: [description of changes]

OPEN PRs
- [PR title] -> [repo] (ready to merge? / needs review?)

PRIORITY TASKS
1. [High priority task]
2. [Medium priority task]
3. [Low priority task]

INFRASTRUCTURE
- [service]: [status]

DEADLINES
- [Any upcoming deadlines within 30 days]

RECOMMENDED FOCUS
Based on priorities and momentum: [recommendation]
```

## Notes

- This command takes no arguments — it figures out what matters
- Keep the brief concise (fit on one screen)
- Recommend focus based on: deadlines > blockers > momentum > new work
- If it's Monday, include a week-ahead view
- If a project has been dormant >7 days, mention it as "needs attention" or "intentionally paused"

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

Read `~/.claude/projects/-Users-eddiebelaval-Development/memory/session-log.md` for:
- What was worked on yesterday
- Any unfinished tasks or blockers

### 2. Cross-Project Git Status

Check each active project for uncommitted work and open PRs:

```bash
# Homer
cd ~/Development/Homer && echo "=== HOMER ===" && git status -s && git log --oneline -3

# Parallax
cd ~/Development/id8/products/parallax && echo "=== PARALLAX ===" && git status -s && git log --oneline -3

# Rune
cd ~/Development/id8/products/rune && echo "=== RUNE ===" && git status -s && git log --oneline -3

# Vox
cd ~/Development/id8/products/vox && echo "=== VOX ===" && git status -s && git log --oneline -3

# Claude Code Artifacts
cd ~/Development/claude-code-visualize && echo "=== ARTIFACTS ===" && git status -s && git log --oneline -3
```

Check for open PRs across repos:
```bash
gh pr list --state open --json title,url,repository 2>/dev/null
```

### 3. Active Tasks

Scan workspace task directories for active tasks:

```bash
# Homer tasks
ls ~/Development/Homer/workspace/tasks/*.md 2>/dev/null

# Parallax tasks
ls ~/Development/id8/products/parallax/workspace/tasks/*.md 2>/dev/null
```

Sort by priority (high > medium > low).

### 4. Infrastructure Health

Check HYDRA job status:
```bash
launchctl list | grep -i hydra 2>/dev/null
```

Check for any failed launchd jobs:
```bash
launchctl list | grep -E "hydra|vox|e2e" 2>/dev/null
```

### 5. Deadlines & Reminders

Check MEMORY.md for any upcoming deadlines. Known recurring:
- Annual Report: May 1, 2026 ($138.75)
- Capital One Spark Classic: Call by March 10, 2026

### 6. Triangle Health Check

For each active project that has VISION.md + SPEC.md at its root:

1. Read SPEC.md frontmatter for `last-reconciled` date
2. Count git commits since that date: `git log --oneline --since="[date]" | wc -l`
3. Check BUILDING.md for entries newer than last reconciliation

Report inline:
```
TRIANGLE HEALTH
- [Project]: CURRENT (reconciled [date])
- [Project]: DRIFTED — [N] commits since reconcile on [date]
```

If any project has >5 commits since last reconciliation, use AskUserQuestion:
- "[PROJECT] has [N] commits since SPEC was last reconciled [date]. Quick sync?"
- Options: "Reconcile now" / "Skip today" / "Nothing meaningful, bump date"

Known triangle projects: Parallax (`~/Development/id8/products/parallax`), Homer (`~/Development/Homer`), Rune (`~/Development/id8/products/rune`)

### 7. Present Morning Brief

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
- HYDRA: [status]
- Vox: [status]

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

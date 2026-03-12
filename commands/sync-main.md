# Sync with Main Branch

You are executing the **sync-main** workflow - keeps your feature branch up to date with main.

## Pre-computed Context

```bash
CURRENT_BRANCH=$(git branch --show-current)
MAIN_BRANCH=$(git symbolic-ref refs/remotes/origin/HEAD 2>/dev/null | sed 's@^refs/remotes/origin/@@' || echo "main")
LOCAL_CHANGES=$(git status --porcelain)
COMMITS_BEHIND=$(git rev-list --count HEAD..origin/$MAIN_BRANCH 2>/dev/null || echo "unknown")
COMMITS_AHEAD=$(git rev-list --count origin/$MAIN_BRANCH..HEAD 2>/dev/null || echo "unknown")
```

**Current Branch:** $CURRENT_BRANCH
**Main Branch:** $MAIN_BRANCH
**Uncommitted Changes:** $LOCAL_CHANGES
**Commits Behind Main:** $COMMITS_BEHIND
**Commits Ahead of Main:** $COMMITS_AHEAD

## User Intent

$ARGUMENTS

## Workflow

### Step 1: Stash if Needed
If LOCAL_CHANGES is not empty:
```bash
git stash push -m "sync-main: auto-stash before rebase"
```

### Step 2: Fetch Latest
```bash
git fetch origin $MAIN_BRANCH
```

### Step 3: Rebase onto Main
```bash
git rebase origin/$MAIN_BRANCH
```

### Step 4: Handle Conflicts
If rebase fails with conflicts:
1. List conflicting files: `git diff --name-only --diff-filter=U`
2. For each file, show the conflict markers
3. Ask user how to resolve OR attempt auto-resolution if obvious
4. After resolving: `git add <file>` then `git rebase --continue`

If user wants to abort: `git rebase --abort`

### Step 5: Pop Stash
If we stashed earlier:
```bash
git stash pop
```

Handle stash conflicts if they occur.

### Step 6: Force Push (if needed)
After rebase, history has changed. Need force push:
```bash
git push --force-with-lease origin $CURRENT_BRANCH
```

Use `--force-with-lease` NOT `--force` for safety.

### Step 7: Report
```
Sync complete:
- Rebased $CURRENT_BRANCH onto $MAIN_BRANCH
- Now up to date (was $COMMITS_BEHIND commits behind)
- Pushed to remote
```

## Safety Checks
- NEVER run on main/master branch directly
- ALWAYS use --force-with-lease instead of --force
- ALWAYS stash uncommitted work first
- If conflicts are complex, ask user before auto-resolving

## Common Scenarios

**Clean sync (no conflicts):**
```bash
git fetch origin main
git rebase origin/main
git push --force-with-lease
```

**With local changes:**
```bash
git stash push -m "sync-main"
git fetch origin main
git rebase origin/main
git push --force-with-lease
git stash pop
```

# Commit, Push & Create PR

You are executing the **commit-push-pr** workflow - the most frequently used inner-loop command.

## Pre-computed Context (inline bash for speed)

```bash
# Current state
BRANCH=$(git branch --show-current)
STATUS=$(git status --porcelain)
STAGED=$(git diff --cached --stat)
UNSTAGED=$(git diff --stat)
REMOTE_STATUS=$(git status -sb | head -1)
RECENT_COMMITS=$(git log --oneline -5)
PR_EXISTS=$(gh pr view --json number 2>/dev/null || echo "none")
```

**Branch:** $BRANCH
**Remote Status:** $REMOTE_STATUS
**Staged Changes:** $STAGED
**Unstaged Changes:** $UNSTAGED
**Recent Commits:** $RECENT_COMMITS
**Existing PR:** $PR_EXISTS

## User Intent

$ARGUMENTS

## Workflow

### Step 1: Analyze Changes
- Review STATUS to understand what's changed
- Identify logical groupings if multiple changes exist
- Check if changes are related or should be separate commits

### Step 2: Stage Appropriately
- If user specified files, stage those
- If no specification, stage all related changes
- NEVER stage unrelated changes together

### Step 3: Craft Commit Message
Follow semantic commit style:
- `feat:` new feature
- `fix:` bug fix
- `refactor:` code restructuring
- `docs:` documentation
- `test:` adding tests
- `chore:` maintenance

Message format:
```
type: short description (imperative mood)

- Bullet points for details if needed
- Focus on WHY, not WHAT (the diff shows what)
```

### Step 4: Commit & Push
```bash
git add [files]
git commit -m "message"
git push -u origin $BRANCH
```

### Step 5: Create or Update PR
If PR_EXISTS is "none":
```bash
gh pr create --title "PR Title" --body "## Summary
- Key change 1
- Key change 2

## Test Plan
- [ ] How to verify this works

---
Generated with [Claude Code](https://claude.com/claude-code)"
```

If PR already exists, just push (PR auto-updates).

### Step 6: Report
Output the PR URL and summary of what was done.

## Error Handling
- If push fails due to divergence: `git pull --rebase origin $BRANCH` first
- If PR creation fails: check if branch is pushed, check gh auth status
- If nothing to commit: report "No changes to commit"

## Speed Optimizations
- Pre-compute all git state via inline bash (no tool calls needed)
- Single commit for related changes
- Use `gh pr create` not manual GitHub navigation

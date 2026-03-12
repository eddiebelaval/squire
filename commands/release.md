# /release — Promote dev to main (production)

You are executing the **release** workflow for a project with a `dev` → `main` branch protocol.

## Arguments
$ARGUMENTS

Parse $ARGUMENTS:
- Empty → Standard release (dev → main)
- "dry-run" → Show what would ship, but don't merge
- "hotfix" → Hotfix release (current branch → main, then sync to dev)

## Pre-flight: Confirm Location

1. Verify you're in a project repo (not ~/Development root)
2. Confirm the project name and directory
3. Check that `main` and `dev` branches exist on the remote
4. If on a feature branch, switch to `dev` first (unless hotfix mode)

## Phase 1: What's Shipping

```bash
# Show all commits on dev that aren't on main
git fetch origin
git log origin/main..origin/dev --oneline --no-merges

# Show file-level diff
git diff origin/main..origin/dev --stat
```

**Present to the user:**
- Number of commits shipping
- List of PRs included (parse from merge commits)
- File count and summary of changes
- Flag any risky files (API routes, migrations, auth, billing)

If there are NO differences between main and dev:
- Report "Nothing to release — dev and main are in sync."
- Stop.

## Phase 2: Pre-flight Checks

Run these in the project directory on the `dev` branch:

```bash
# 1. Type check
npx tsc --noEmit

# 2. Lint (if available)
npm run lint 2>/dev/null

# 3. Tests (if available)
npm test 2>/dev/null || npx vitest run 2>/dev/null

# 4. Build (skip if env vars are needed for prebuild scripts)
# Only run if the build script doesn't require external services
```

Report results:
```
PRE-FLIGHT CHECK
  TypeScript:  PASS/FAIL (N errors)
  Lint:        PASS/FAIL/SKIPPED
  Tests:       PASS/FAIL/SKIPPED (N passed, N failed)
  Build:       PASS/FAIL/SKIPPED
```

If any FAIL: stop and report. Do NOT proceed to merge.
If dry-run mode: stop here after showing the report.

## Phase 3: Create Release PR

```bash
gh pr create --base main --head dev \
  --title "release: [brief description of what's shipping]" \
  --body "[changelog generated from Phase 1]"
```

The PR body should include:
- Summary of all changes (grouped by type: features, fixes, docs)
- List of included PRs with numbers
- Files changed count
- Pre-flight results
- Any migration notes or manual steps needed

## Phase 4: Merge

After creating the PR, ask for confirmation:
"Release PR #N created. Merge to main (production)?"

On confirmation:
```bash
gh pr merge [N] --merge --admin
```

NEVER squash merge. Use regular merge to preserve commit history.

## Phase 5: Post-Release

After merge:
1. Pull main locally: `git checkout main && git pull`
2. Switch back to dev: `git checkout dev`
3. Verify dev and main are in sync: `git log origin/main..origin/dev --oneline`
4. Report the Vercel deployment URL if known

```
RELEASE COMPLETE
  PR:          #N merged to main
  Commits:     N
  Files:       N changed
  Deploy:      [Vercel URL] (auto-deploying)
  Branches:    main and dev are in sync
```

## Hotfix Mode

When $ARGUMENTS contains "hotfix":
1. Confirm the current branch is a hotfix/* branch (or create one)
2. Run pre-flight on the hotfix branch
3. Create PR from hotfix branch → main
4. After merge to main, also merge main → dev to keep them in sync
5. Delete the hotfix branch

## Safety Rules

- NEVER force push to main
- NEVER merge without passing type check at minimum
- NEVER merge if there are migration files without confirming with user
- ALWAYS show the full diff before merging
- ALWAYS use --merge (never --squash)
- If the diff includes .env changes, billing code, or auth changes, flag explicitly

## Project-Specific Notes

Add project-specific release notes here as needed (e.g., deployment targets, required env vars, migration steps).

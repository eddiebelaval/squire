# Heal — Autonomous Test Fix Loop

Run the full test suite, fix every failure at the source, and repeat until green. No guidance needed — fully autonomous red-green loop.

## Usage

```
/heal                    # Fix all failing tests in current project
/heal --unit-only        # Only run unit tests (skip Playwright)
/heal --no-commit        # Fix everything but don't commit at the end
/heal --dry-run          # Show what's failing without fixing anything
```

## Instructions

When invoked:

### Step 0: Detect Environment

1. Identify the project from the current directory (check package.json, CLAUDE.md).
2. State: "Healing [PROJECT] on branch [BRANCH]"
3. Detect available test commands from package.json scripts:
   - Unit: `test`, `test:unit`, `vitest`, `jest`
   - E2E: `test:e2e`, `playwright test`
   - Type check: `tsc --noEmit`
   - Build: `build`, `next build`
4. If `--unit-only` flag is set, skip E2E detection.
5. Create or clear `FIXES.md` in the project root with header:
   ```
   # Fixes — /heal run {date}
   ```

### Step 1: Initial Test Run

Run all detected test commands and capture output:

```bash
npm test 2>&1
npx playwright test 2>&1  # unless --unit-only
npx tsc --noEmit 2>&1
```

If ALL pass on the first run:
- Output "All tests already passing. Nothing to heal."
- Run `npm run build` to confirm clean compilation.
- Delete FIXES.md (nothing to log).
- Exit.

If there are failures, collect them into a failure list:
- Test file path
- Test name
- Error message / assertion failure
- Stack trace (relevant lines only)

Sort failures by dependency order: type errors first, then unit tests, then E2E. Fixing type errors often cascades into fixing test failures.

### Step 2: Fix Loop

For each failure, starting from the most upstream:

1. **Read** the failing test to understand what it expects.
2. **Read** the source file being tested.
3. **Analyze** the root cause. The bug is in the source code, NOT the test.
   - Exception: If the test itself has a typo, stale mock, or references a renamed export, fix the test. But prefer source fixes.
4. **Fix** the root cause with minimal changes. Do not refactor surrounding code.
5. **Run** `npx tsc --noEmit` to verify the fix compiles.
6. **Re-run** the specific failing test to verify it passes:
   ```bash
   npx vitest run path/to/test.ts    # or jest, playwright equivalent
   ```
7. **Log** to FIXES.md:
   ```
   - [file:line] Fixed {what}: {root cause in one sentence}
   ```

**Escalation rule:** If you've attempted the same fix twice without success, do NOT try it a third time. Instead:
- Step back and re-read the broader context (imports, types, related files)
- Try a fundamentally different approach
- If 3 different approaches all fail on the same test, log it as unresolved in FIXES.md and move on

### Step 3: Full Verification

After all individual fixes:

1. Run the COMPLETE test suite again (all commands from Step 1).
2. If new failures appeared (regression from a fix):
   - Go back to Step 2 for the new failures only.
   - Maximum 3 full-suite reruns to prevent infinite loops.
3. Run `npm run build` to confirm clean compilation.

### Step 4: Report and Commit

If `--dry-run`: Output the failure list and suggested fixes, then exit without changing anything. Delete FIXES.md.

If `--no-commit`: Output the summary below but skip the commit.

Otherwise:

1. Stage all changed source files (NOT test files unless they were the ones with bugs).
2. Commit with message:
   ```
   fix: heal {N} failing tests

   {one-line summary per fix from FIXES.md}

   Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>
   ```
3. Output summary:

```
Heal Complete
=============
Tests fixed: {N}
Tests unresolved: {N}  (if any)
Files modified: {list}
Type check: PASS
Build: PASS

Fixes:
{contents of FIXES.md}
```

4. If there are unresolved tests, clearly state which ones and why.

### Step 5: Cleanup

- Keep FIXES.md in the commit (it serves as a changelog for the fix batch).
- Do NOT push to remote.
- Do NOT delete or modify any test files unless they contained the actual bug.

## Fix Priority Order

| Priority | Category | Why First |
|----------|----------|-----------|
| 1 | Type errors (`tsc --noEmit`) | Cascading — fixing types often fixes runtime failures |
| 2 | Import / export errors | Missing exports break many downstream tests |
| 3 | Unit test failures | Isolated, fast to verify |
| 4 | Integration test failures | May depend on unit-level fixes |
| 5 | E2E / Playwright failures | Most complex, may resolve from upstream fixes |

## Rules

- **Fix source, not tests.** Tests define expected behavior. Source should match.
- **Minimal changes.** Fix the bug, nothing else. No drive-by refactors.
- **No suppression.** Never add `@ts-ignore`, `// eslint-disable`, `.skip`, or `xit` to make tests "pass."
- **No mocking away the problem.** If a test expects real behavior, fix the real code.
- **Type-check after every fix.** One broken type can cascade into 20 test failures.
- **3-strike rule.** Same fix fails twice = try different approach. Three different approaches fail = mark unresolved, move on.
- **Never push.** Healing is local. You decide when to push.

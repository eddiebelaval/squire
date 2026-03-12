# /polish - Code Review + Simplify (Full Auto)

You are polishing code that was just written. This runs a two-phase quality pass — review then simplify — and auto-applies all changes. The user sees a final report of everything that changed.

**Philosophy: Ship clean code without manual review overhead.** Review catches bugs and violations. Simplify catches complexity and clutter. Together they produce code that's correct AND readable.

## Arguments

Parse `$ARGUMENTS` for:
- **`--files <glob>`** - Only polish specific files (e.g., `--files src/components/**/*.tsx`)
- **`--skip-review`** - Skip the code review phase, only simplify
- **`--skip-simplify`** - Skip the simplification phase, only review
- **`--no-verify`** - Skip build/type-check verification at the end
- **`--dry-run`** - Show what would change but don't apply anything
- Empty = polish all changes on the current branch vs base (most common usage)

---

## Step 0: Detect Scope

Determine what code to polish:

```bash
# Find base branch
BASE=$(git merge-base HEAD main 2>/dev/null || git merge-base HEAD master 2>/dev/null)

# Get changed files
git diff $BASE..HEAD --name-only
git diff --name-only          # Also include unstaged changes
git diff --cached --name-only # Also include staged changes
```

If `--files` was provided, use that glob instead.

Build a file list of everything that will be polished. Report it:
```
Polishing [N] files on branch [branch-name] (vs [base-branch])
```

If there are no changes detected, inform the user and exit.

---

## Step 1: Code Review (AUTO-APPLY)

Unless `--skip-review` was passed:

Launch the **feature-dev:code-reviewer** agent via the Task tool:
- Pass it the list of changed files
- Ask it to review for: bugs, logic errors, security vulnerabilities, code quality issues, and adherence to project conventions
- Request it returns findings with confidence levels

**Auto-fix everything the reviewer flags:**
- Missing/incorrect imports
- Unused variables and imports
- Security issues (XSS, injection, etc.)
- Logic errors and off-by-one bugs
- Type errors and missing type annotations
- Convention violations (naming, patterns)
- Dead code and unreachable branches

Track every change made in a list for the final report.

If `--dry-run`, collect findings but don't apply changes.

---

## Step 2: Code Simplification (AUTO-APPLY)

Unless `--skip-simplify` was passed:

Launch the **code-simplifier:code-simplifier** agent via the Task tool:
- Pass it the same file list (now with review fixes applied)
- Focus on recently modified code
- Ask it to simplify for clarity, consistency, and maintainability while preserving all functionality

**The simplifier will auto-apply:**
- Reducing unnecessary complexity
- Consolidating duplicated logic
- Improving variable/function naming for clarity
- Removing unnecessary abstractions
- Simplifying conditional chains
- Cleaning up verbose patterns

Track every change made in a list for the final report.

If `--dry-run`, collect proposed simplifications but don't apply them.

---

## Step 3: Verification Gate

Unless `--no-verify` was passed:

```bash
# Run in the project directory
npm run build 2>&1
npx tsc --noEmit 2>&1
```

If either fails:
1. Read the error — if it's caused by a polish change, revert that specific change
2. Re-run verification
3. If it still fails after one revert attempt, report the failure and stop

Optional (if test script exists in package.json):
```bash
npm test -- --passWithNoTests 2>&1
```

---

## Step 4: Final Report

Present a single, clean summary of everything that happened:

```
## Polish Complete: [branch-name]

### Scope
[N] files polished ([list key files])

### Phase 1: Code Review
[N] issues found, [N] auto-fixed
- [file:line] Fixed: [description]
- [file:line] Fixed: [description]
[or "No issues found"]

### Phase 2: Simplification
[N] simplifications applied
- [file:line] Simplified: [description]
- [file:line] Simplified: [description]
[or "No simplifications needed"]

### Verification
- Build: PASS/FAIL
- TypeCheck: PASS/FAIL
- Tests: PASS/FAIL/SKIPPED

### Summary
[1-2 sentence summary of overall code health and what improved]
```

If `--dry-run`, prefix the report with:
```
DRY RUN - No changes applied. Here's what /polish would do:
```

---

## Important Rules

1. **Never change behavior.** Polish is cosmetic + correctness. If a simplification would change what the code does, skip it.
2. **Respect critical markers.** Code marked with `// IMPORTANT: DO NOT REMOVE` or similar must not be touched.
3. **Don't expand scope.** Only touch files in the detected change set. Don't "improve" surrounding code.
4. **Revert on verification failure.** If a polish change breaks the build, undo it rather than trying to fix forward.
5. **Be honest in the report.** If nothing needed fixing, say so. Don't inflate the report with trivial changes.

$ARGUMENTS

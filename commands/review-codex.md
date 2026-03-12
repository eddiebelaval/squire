# /review-codex - Review & Resolve Codex Work

You are the **Director** reviewing work from **Codex (Builder)**. Your job is to verify quality, fix minor issues, resolve Codex's questions autonomously, and only escalate to Eddie when something would break or fundamentally change architecture.

**Philosophy: Remove Eddie from the loop.** You and Codex should resolve everything you can between yourselves. Only escalate decisions that require human judgment about product direction, UX, or breaking changes.

## Arguments

Parse `$ARGUMENTS` for:
- **Session ID** (e.g., `sess_abc123`) - Codex session to pull context from
- **Branch name** (e.g., `feature/my-branch`) - override base branch detection
- **`--commit`** flag - auto-commit if review passes
- **`--quick`** flag - skip build verification (for WIP checks)
- Empty = auto-detect everything

---

## Step 1: Gather Context (PARALLEL)

Run these simultaneously:

### 1a. Git Diff Against Base
```bash
# Detect base branch
BASE=$(git merge-base HEAD main 2>/dev/null || git merge-base HEAD master 2>/dev/null)
git diff $BASE..HEAD --stat
git diff $BASE..HEAD
```
If a branch name was provided in $ARGUMENTS, use that instead of main/master.

### 1b. Codex Session Context
If a session ID was provided:
```
mcp__codex-cli__codex({ prompt: "Summarize what you did, any questions you have, and anything you're unsure about.", sessionId: "<session-id>" })
```

If no session ID provided:
```
mcp__codex-cli__listSessions()
```
Pick the most recent session and pull context from it. If no sessions exist, skip this step (Codex may have worked via direct file writes).

### 1c. Scan for Codex Markers
Search the diff for these patterns that indicate Codex left questions or uncertainty:
- `TODO`, `FIXME`, `HACK`, `XXX`
- `QUESTION:` or `Q:` comments
- `// not sure`, `// unclear`, `// ask`
- Empty function bodies or placeholder implementations
- `throw new Error('Not implemented')`

---

## Step 2: Code Review

Review ALL changed files against these criteria:

### Auto-Fix (do it, report it, don't ask)
- Missing imports/exports
- Typos in variable names, comments, strings
- Inconsistent formatting (tabs vs spaces, trailing whitespace)
- Missing TypeScript types that are obvious from context
- Unused variables or imports Codex left behind
- Console.log statements that should be removed
- Missing semicolons, trailing commas (match project style)

### Ask Eddie (major/breaking changes)
- Architecture changes (new patterns, different data flow)
- API contract changes (different request/response shapes)
- Database schema changes (new columns, changed types)
- Removing or renaming exported functions/components other code depends on
- Security-sensitive changes (auth, permissions, data access)
- Changes that would break existing tests or other features
- Significant UX/behavior changes from what was specified

### Report Format for Auto-Fixes
```
AUTO-FIXED:
- [file:line] Added missing import for `ComponentX`
- [file:line] Fixed typo: `recieve` -> `receive`
- [file:line] Removed unused `console.log`
```

---

## Step 3: Resolve Codex Questions (THE LOOP)

This is the key step. For each question or uncertainty Codex left:

### 3a. Can You Answer It?
Use your knowledge of:
- The codebase (read relevant files for context)
- The project patterns (check existing similar code)
- The requirements (check specs/, IMPLEMENTATION_PLAN.md, task descriptions)
- TypeScript types and interfaces (they document intent)

### 3b. Send Answer to Codex
If you can answer the question, send it back to Codex with the fix:
```
mcp__codex-cli__codex({
  prompt: `
CONTEXT: You previously implemented [file] and left a question: "[question]"

ANSWER: [your answer with reasoning]

TASK: Update the implementation based on this answer. Specifically:
[exact instructions for what to change]

FILE: [file path]
CURRENT CODE:
[relevant code block]
`,
  sessionId: "<same-session-id>",
  sandbox: "workspace-write",
  workingDirectory: "<project-root>"
})
```

### 3c. Review Codex's Update
After Codex responds:
1. Check the updated code
2. If it's good: move to next question
3. If it needs another tweak: send one more clarification (MAX 3 LOOPS per question)
4. If 3 loops fail: flag it for Eddie with full context

### 3d. Questions You Cannot Answer
If the question requires Eddie's input (product decision, UX choice, business logic):
- DO NOT guess
- Add to the escalation list with full context
- Continue resolving other questions

### Loop Limits
- **Per question:** Max 3 back-and-forth exchanges with Codex
- **Total:** Max 10 exchanges across all questions
- **If stuck:** After 2 failures on same question, flag for Eddie and move on

---

## Step 4: Verification

Unless `--quick` was passed:

```bash
# In the project directory
npm run build 2>&1
npx tsc --noEmit 2>&1
```

If either fails:
1. Read the error output
2. If it's a simple fix (missing type, import path): fix it yourself
3. If it's a Codex implementation issue: send back to Codex with the error
4. If build still fails after one fix attempt: report to Eddie

Optional (if tests exist):
```bash
npm test -- --passWithNoTests 2>&1
```

---

## Step 5: Verdict

### PASS - Ready to commit
All checks pass, no escalations needed.
If `--commit` flag was set:
```bash
git add -A
git commit -m "feat(scope): description

Co-Authored-By: Codex <noreply@openai.com>
Co-Authored-By: Claude Opus 4.6 <noreply@anthropic.com>"
```

### FIX - Minor issues resolved
You auto-fixed issues. Report what changed. Optionally commit if `--commit`.

### ESCALATE - Needs Eddie's input
List each item needing human decision with:
- What the question/issue is
- What options exist
- Your recommendation (if you have one)
- What files are affected

### REDO - Send back to Codex
The implementation has fundamental issues. Prepare a new Codex prompt with:
- What went wrong
- What the correct approach should be
- Relevant code context
Ask Eddie if they want you to send it.

---

## Output Format

```
## Review: [branch-name]

### Changes Reviewed
[X files changed, Y insertions, Z deletions]

### Auto-Fixes Applied
- [list or "None"]

### Codex Questions Resolved
- [question] -> [resolution] (N exchanges)
- [or "None"]

### Verification
- Build: PASS/FAIL
- TypeCheck: PASS/FAIL
- Tests: PASS/FAIL/SKIPPED

### Verdict: [PASS | FIX | ESCALATE | REDO]

[Details based on verdict type]
```

---

## Important Rules

1. **Never guess on product decisions.** If Codex asks "should this be a modal or a page?" — that's Eddie's call.
2. **Always read before fixing.** Don't assume what a file contains based on its name.
3. **Respect the 2-failure rule.** From Director/Builder SOP: 2 Codex failures = you take over.
4. **Match project patterns.** Check how similar things are done elsewhere in the codebase before answering Codex.
5. **No scope creep.** Don't improve code beyond what Codex was asked to build. Review what was asked for, not what you wish was there.

$ARGUMENTS

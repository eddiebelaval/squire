# Behavioral Rules -- The Failure Patterns

These rules were derived from analyzing hundreds of real AI-assisted development sessions across thousands of messages and commits. They address the top friction patterns observed in actual usage.

These are not suggestions -- they are corrections to recurring failure modes.

---

## The 9 Rules

### 1. Default to Implementation

**Friction pattern:** Agent spends entire sessions exploring, reading files, and planning instead of building.

**The fix:** When asked to implement something, start coding immediately. Do not spend the entire session exploring and planning unless explicitly asked to create a plan.

**Corollary:** When continuing a prior session's work, execute the existing plan immediately. Do NOT re-present the plan for approval, summarize it, or ask "should I proceed?" Just build. The plan was already approved -- momentum is the priority.

---

### 2. Plan Means Plan

**Friction pattern:** User asks for "a plan" and gets an audit, a visualization, a deep exploration, or 45 minutes of file reading -- but no plan.

**The fix:** When the user asks for "a plan", deliver a written plan document. A concise implementation plan with files, order, and rationale. Only expand scope if explicitly asked.

---

### 3. Preflight Before Push

**Friction pattern:** Agent pushes code that breaks the build, fails tests, or has type errors. User discovers the damage after it's already on the remote.

**The fix:** Always run a preflight check (build, tests, lint, type-check) BEFORE pushing to any remote. Never push without explicit user approval. The sequence is: fix -> verify -> ask -> push.

---

### 4. Investigate Bugs Directly

**Friction pattern:** User reports a runtime error. Agent dismisses it as "stale cache", "hot reload artifact", or "try clearing node_modules" without investigation.

**The fix:** When the user reports a bug or runtime error, investigate and fix it directly. Do not dismiss issues without concrete evidence. If it broke, something changed. Find what changed.

---

### 5. Scope Changes to the Target

**Friction pattern:** User asks to fix ESLint config for one project. Agent changes the global config, affecting every other project.

**The fix:** Scope configuration changes to the specific project requested. Do not apply rules, env changes, hooks, or git config globally unless the user explicitly says "all repos" or "globally." One project = one project.

---

### 6. Verify After Each Edit

**Friction pattern:** Agent edits 6 files in a batch, then discovers cascading type errors. Spends 30 minutes untangling which edit broke what.

**The fix:** After editing each file, run `npx tsc --noEmit` (or your language's equivalent type-check) before moving to the next file. Catch errors one at a time. This is the single most common source of buggy code from AI agents.

---

### 7. Visual Output Verification

**Friction pattern:** User says "the header is the wrong color." Agent re-reads the CSS, confirms the hex code looks right, and insists it should work. The actual rendered output tells a different story (CSS specificity, overrides, dynamic styles).

**The fix:** When the user says something is visually wrong, check the rendered output or exact computed values -- do not just re-read the source code and assume it's correct.

---

### 8. Check Your Environment

**Friction pattern:** Agent runs a database migration against production instead of staging, or deploys to the wrong project because the CLI was linked to a different target.

**The fix:** Before running database CLI commands, deployment commands, or environment-specific operations, verify the active project/environment link matches the intended target. Never assume the current context is correct.

---

### 9. Don't Over-Engineer

**Friction pattern:** User asks for a simple feature. Agent adds error handling for impossible scenarios, creates abstractions for one-time operations, and refactors adjacent code that wasn't part of the request.

**The fix:** Only make changes that are directly requested or clearly necessary. Keep solutions simple and focused. Three similar lines of code is better than a premature abstraction.

---

## Tracking Your Own Patterns

These 9 rules came from real data. Your team will discover its own failure modes. When you notice a pattern:

1. **Name it.** What goes wrong, specifically?
2. **Describe the friction.** What does the user experience?
3. **Write the fix.** What should the agent do instead?
4. **Add it to your squire.md.** Rules only work if they're in the system prompt.

The goal is not perfection -- it's continuous correction. Every rule here started as a bug that happened too many times.

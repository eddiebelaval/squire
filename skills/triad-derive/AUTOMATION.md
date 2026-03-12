---
name: Triad Automation
description: Proactive drift detection, AskUserQuestion-driven reconciliation, and integration with existing workflow commands
version: "1.0.0"
---

# Triad Automation — Self-Maintaining Triangle

The Triad should never require manual maintenance. This document specifies how drift is detected proactively and how AskUserQuestion is used to keep the triangle current without Eddie having to remember anything.

## Core Principle

**Detect drift at natural workflow boundaries. Ask one focused question. Update the docs. Move on.**

Eddie should never see a stale VISION or SPEC. The system watches for signals and intervenes at the right moment — not in the middle of flow, but at natural breakpoints (session start, pre-ship, post-gate).

---

## Trigger Points

### 1. Session Start (`/morning` integration)

After the standard morning brief, run a **lightweight drift check**:

```
QUICK DRIFT SCAN:
1. For each active project with a triangle (VISION.md + SPEC.md):
   a. Check SPEC.md "last-reconciled" date in frontmatter
   b. If >7 days since last reconciliation:
      - Count git commits since that date
      - If >5 commits: FLAG as "SPEC may be stale"
   c. Check BUILDING.md last entry date
      - If new entries since last SPEC reconciliation: FLAG
2. Report flags inline with the morning brief
```

**If drift detected, use AskUserQuestion:**

```
"[PROJECT] has [N] commits since SPEC was last reconciled [date]. Quick sync?"
Options:
- "Yes, reconcile now" -> run /reconcile spec --project [name]
- "Skip for now" -> note skipped, re-prompt tomorrow
- "It's fine, nothing meaningful changed" -> update last-reconciled date only
```

### 2. Pre-Ship (`/ship` integration)

Before creating a PR, check triangle health:

```
SHIP PREFLIGHT — TRIAD CHECK:
1. Does this project have VISION.md + SPEC.md?
   - If no: skip (not all projects use the triangle)
   - If yes: continue
2. Are there new capabilities being shipped that aren't in SPEC?
   - Scan the diff for new routes, pages, components, API endpoints
   - Cross-reference with SPEC capabilities
   - If new capabilities found not in SPEC: FLAG
3. Do any changes touch VISION-level concerns?
   - New pillar-related features
   - Architecture changes
   - User-facing behavior changes
```

**If drift detected, use AskUserQuestion:**

```
"This PR adds [new capability]. SPEC.md doesn't mention it yet. Update before shipping?"
Options:
- "Yes, add to SPEC" -> add capability + verification assertion, update reconciled date
- "No, it's not user-facing" -> skip
- "Full reconcile" -> run /reconcile spec
```

### 3. Post-Gate (Pipeline integration)

After any pipeline gate pass (detected by commit message pattern `[Stage N: Name] verify: gate PASSED`):

```
GATE PASS — TRIAD UPDATE:
1. A gate just passed. The product advanced.
2. Check which VISION pillars this stage maps to.
3. If a pillar status should change (UNREALIZED -> PARTIAL, PARTIAL -> REALIZED):
   - Use AskUserQuestion to confirm
4. Auto-update SPEC with new capabilities from this stage.
5. Add BUILDING.md entry for the gate pass (if not already there).
```

**AskUserQuestion:**

```
"Gate [N] passed. Pillar '[name]' was PARTIAL — does this gate move it to REALIZED?"
Options:
- "Yes, it's realized now"
- "Still partial — [reason]"
- "Skip pillar check"
```

### 4. Significant Commit Detection

When Claude creates a commit that introduces:
- A new file matching `app/**/page.tsx` or `app/api/**/route.ts` (new page/API)
- A new component in `components/`
- A database migration
- A new integration (new env var, new import of external service)

**Silently note it.** Don't interrupt. But at the next natural breakpoint (end of task, pre-ship, session end), mention:

```
"FYI: [N] new capabilities were added this session that aren't in SPEC yet.
Want me to update SPEC before we wrap up?"
```

### 5. Staleness Escalation

If drift is detected and Eddie says "skip" twice for the same project:

- **Third time:** Escalate tone slightly: "SPEC is [N] days stale with [M] unrecorded changes. This is starting to accumulate."
- **After that:** Stop asking. Eddie is aware. Only re-prompt if drift crosses 30 days or 20+ commits.

---

## AskUserQuestion Patterns

All Triad automation questions follow these rules:

1. **One question at a time.** Never batch multiple reconciliation questions.
2. **Always provide a skip option.** Eddie is busy. The system works around his schedule.
3. **Structured choices for scoping, conversation for nuance.** "Which pillar?" = AskUserQuestion. "What changed?" = natural conversation.
4. **Never interrupt flow.** All prompts happen at breakpoints:
   - Session start
   - Pre-ship / pre-PR
   - Post-gate
   - End of task (when Claude would say "done" anyway)
5. **Context in the question.** Don't just say "SPEC is stale." Say "SPEC was last reconciled 12 days ago. 8 commits since then, including a new API route and a migration."

### Question Templates

**Drift detected (lightweight):**
```
AskUserQuestion:
  question: "[PROJECT] SPEC was reconciled [N] days ago. [M] commits since then include [summary]. Quick update?"
  options:
    - "Update SPEC now"
    - "Skip for now"
    - "Nothing meaningful — just bump the date"
```

**New capability shipped:**
```
AskUserQuestion:
  question: "New [type] added: [name]. Add to SPEC capabilities?"
  options:
    - "Yes, add it"
    - "Not user-facing, skip"
    - "Add it and also update VISION pillar status"
```

**Pillar status change:**
```
AskUserQuestion:
  question: "Pillar '[name]' is marked [current status]. Based on what just shipped, should this change?"
  options:
    - "Move to REALIZED"
    - "Move to PARTIAL ([X]%)"
    - "No change"
```

**Vision evolution (conversational, not structured):**
```
"Something about [PROJECT] feels like it shifted. [Evidence: new user feedback / pivot /
learning]. Has the north star moved, or is this just execution?"

[Wait for Eddie's response. If he says something shifted, switch to /reconcile vision mode.]
```

---

## Integration Hooks

### `/morning` — Add after "RECOMMENDED FOCUS":

```
TRIANGLE HEALTH
- [Project]: [CURRENT / N days since reconcile / M unrecorded commits]
- [Project]: [CURRENT / stale]
```

### `/ship` — Add before "Push & Create PR":

```
TRIAD CHECK
- SPEC covers all new capabilities: [YES / N new capabilities not in SPEC]
- VISION alignment: [no pillar changes / pillar [X] may need update]
- Action: [none needed / updating SPEC / asking about pillar status]
```

### `/reconcile` — After any reconciliation:

```
"Triangle updated. Derived outputs (/roadmap, /drift, etc.) will now reflect these changes."
```

---

## What NOT to Automate

- **VISION.md Soul section.** This only changes during pivots. Never auto-detect or prompt for soul changes. If it needs to change, Eddie will know.
- **Anti-Vision updates.** These come from hard-won lessons, not from code changes.
- **BUILDING.md entries.** These are written as part of the release SOP. The automation layer reads BUILDING but never writes to it (reconcile skill rule #7).
- **Cross-project concerns.** Each project's triangle is independent. Don't prompt about Homer drift when working on Parallax.

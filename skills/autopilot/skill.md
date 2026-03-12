---
name: Autopilot
slug: autopilot
description: Execute a feature from description to committed code using three parallel sub-agents: Architect, Builder, and Validator.
category: operations
complexity: complex
version: "1.0.0"
author: "id8Labs"
triggers:
  - "autopilot"
  - "autopilot"
tags:
  - operations
  - tool-factory-retrofitted
---

# Autopilot — Autonomous Parallel Build Pipeline


## Core Workflows

### Workflow 1: Primary Action
1. Analyze the input and context
2. Validate prerequisites are met
3. Execute the core operation
4. Verify the output meets expectations
5. Report results

Execute a feature from description to committed code using three parallel sub-agents: Architect, Builder, and Validator. No approval pauses — full autonomous execution.

## Usage

```
/autopilot "Add user authentication with email OTP"
/autopilot "Implement dark mode toggle with system preference detection"
/autopilot "Add Stripe billing with tiered pricing"
```

The argument is a plain-English feature description. The more specific, the better the output.

## Instructions

When invoked with a feature description:

### Step 0: Pre-Flight

1. **Confirm the project context.** Read the current directory, identify the project (check for package.json, CLAUDE.md, etc.), and state: "Running autopilot for [PROJECT] on branch [BRANCH]."
2. **Detect the test command.** Check package.json scripts for `test`, `test:unit`, `vitest`, `jest`, or `playwright`. If no test command exists, note that Validator will run `npx tsc --noEmit` and `npm run build` instead.
3. **Detect the build command.** Check for `build`, `build:dev`, or `next build` in package.json scripts.

### Step 1: Create the Team

Use `TeamCreate` to create a team named `autopilot-{timestamp}`.

Then create three tasks with dependencies:

**Task 1 — Architect**
```
Subject: "[Autopilot] Architect: Write implementation plan"
Description: |
  Read the codebase to understand architecture, patterns, and conventions.
  Write a detailed implementation plan to PLAN.md in the project root.

  The plan MUST include:
  - Files to create or modify (with full paths)
  - Implementation order (what depends on what)
  - Key design decisions with rationale
  - Type signatures for new functions/components
  - Test cases to verify the feature works

  Feature: {FEATURE_DESCRIPTION}

  Read at minimum: package.json, tsconfig.json, CLAUDE.md (if exists),
  the src/ directory structure, and any files related to the feature area.

  Do NOT implement anything. Only produce PLAN.md.
ActiveForm: "Architecting implementation plan"
```

**Task 2 — Builder** (blocked by Task 1)
```
Subject: "[Autopilot] Builder: Implement feature from plan"
Description: |
  Read PLAN.md and implement each section sequentially.

  Rules:
  - Implement one logical unit at a time (one component, one API route, etc.)
  - After each logical unit, run `npx tsc --noEmit` to verify it compiles
  - If it compiles, commit with message: "[Autopilot] feat: {what was built}"
  - If it fails, fix the error before moving on
  - Follow existing codebase patterns exactly (imports, naming, file structure)
  - Do NOT refactor unrelated code
  - Do NOT add comments unless the logic is non-obvious

  Feature: {FEATURE_DESCRIPTION}
ActiveForm: "Building feature from plan"
```
Set `addBlockedBy: [Task 1 ID]`

**Task 3 — Validator** (blocked by Task 1)
```
Subject: "[Autopilot] Validator: Continuous test verification"
Description: |
  Wait for Builder to start committing, then continuously validate:

  1. Run the test suite: {TEST_COMMAND}
  2. Run the build: {BUILD_COMMAND}
  3. Run type checking: npx tsc --noEmit

  If ANY check fails:
  - Report the exact failure to the Builder via SendMessage
  - Wait for the fix commit
  - Re-run all checks

  If all checks pass after Builder marks their task complete:
  - Mark this task as completed
  - Send a summary of all test runs to the team lead

  Keep running until Builder is done. Do not stop after one pass.
ActiveForm: "Validating builds and tests"
```
Set `addBlockedBy: [Task 1 ID]`

### Step 2: Launch Agents

Spawn three agents using the `Task` tool with `team_name` set to the autopilot team:

1. **Architect agent** — `subagent_type: "general-purpose"`, assign Task 1
2. **Builder agent** — `subagent_type: "general-purpose"`, assign Task 2
3. **Validator agent** — `subagent_type: "general-purpose"`, assign Task 3

Launch Architect first. Launch Builder and Validator after Architect completes (they are blocked until then).

### Step 3: Monitor and Coordinate

As team lead:
- When Architect completes, unblock Builder and Validator
- Route Validator failure messages to Builder
- If Builder gets stuck (same error 2+ times), intervene directly
- Track progress via TaskList

### Step 4: Wrap Up

When all three tasks are completed:

1. Read the final PLAN.md and compare against what was built
2. Run one final validation: build + tests + type check
3. Delete PLAN.md (it served its purpose — the commits tell the story)
4. Output a summary:

```
Autopilot Complete
==================
Feature: {FEATURE_DESCRIPTION}
Files created: {count}
Files modified: {count}
Commits: {count}
Tests: {PASS/FAIL}
Build: {PASS/FAIL}

Commits:
- {commit hash} {message}
- {commit hash} {message}
...
```

5. Shut down the team with `TeamDelete`

## Failure Modes

| Situation | Action |
|-----------|--------|
| No test command found | Validator uses `tsc --noEmit` + `npm run build` only |
| Architect produces vague plan | Builder should ask Architect for specifics via SendMessage before implementing |
| Builder fails same error 3x | Team lead takes over that specific fix |
| Tests were passing, now failing | Builder must fix before next commit (no skipping) |
| Feature too large (10+ files) | Architect should split into phases in PLAN.md; Builder implements phase by phase |

## What This Skill Does NOT Do

- Push to remote (you decide when to push)
- Create PRs (use `/commit-push-pr` for that)
- Modify unrelated code
- Skip failing tests
- Ask for approval mid-execution

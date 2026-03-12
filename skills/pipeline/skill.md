---
name: Pipeline
slug: pipeline
description: Check the current project's pipeline status against the ID8Pipeline stages and provide actionable feedback.
category: operations
complexity: complex
version: "1.0.0"
author: "id8Labs"
triggers:
  - "pipeline"
  - "pipeline"
tags:
  - operations
  - tool-factory-retrofitted
---

# Pipeline Status Check


## Core Workflows

### Workflow 1: Primary Action
1. Analyze the input and context
2. Validate prerequisites are met
3. Execute the core operation
4. Verify the output meets expectations
5. Report results

Check the current project's pipeline status against the ID8Pipeline stages and provide actionable feedback.

## What This Skill Does

1. **Reads** the project's `PIPELINE_STATUS.md` (creates one if missing)
2. **Reads** the pipeline definition from `~/.claude/ID8PIPELINE.md`
3. **Analyzes** the codebase to verify claimed stage
4. **Reports** current status, gaps, and next checkpoint

## Usage

```
/pipeline              # Check status for current project
/pipeline homer        # Check status for specific project
/pipeline advance      # Mark checkpoint cleared, advance to next stage
```

## Instructions

When invoked:

### Step 1: Load Pipeline Definition
Read `~/.claude/ID8PIPELINE.md` to understand the 11 stages and their requirements.

### Step 2: Find Project Status
Look for `PIPELINE_STATUS.md` in the current repo root. If not found:
- Ask which stage the project is in
- Create the status file

### Step 3: Verify Current Stage
Based on the claimed stage, check for evidence:

| Stage | Verification |
|-------|--------------|
| 1 (Concept) | One-liner exists in status file |
| 2 (Scope) | "Not building" list defined |
| 3 (Architecture) | Stack documented, diagrams present |
| 4 (Foundation) | DB schema exists, auth configured, deployable |
| 5 (Features) | Feature branches, working code |
| 6 (Integration) | Components connected, data flows |
| 7 (Testing) | Test files exist, coverage report |
| 8 (Polish) | Error handling, loading states |
| 9 (Launch Prep) | Docs, analytics configured |
| 10 (Ship) | Production URL exists |
| 11 (Iterate) | Feedback collection active |

### Step 4: Report

Output format:
```
Pipeline Status: {PROJECT}
========================
Current Stage: {N} - {Stage Name}
Status: {ON TRACK | GAPS FOUND | BLOCKED}

Checkpoint: "{checkpoint question}"

Evidence Found:
- [x] {completed item}
- [ ] {missing item}

Gaps:
- {specific gap description}

Next Actions:
1. {action to close gap}
2. {action to close gap}

Git Hygiene:
- Branches: {count} ({clean | needs cleanup})
- Worktrees: {count}
```

### For `/pipeline advance`

1. Verify ALL checklist items for current stage
2. If gaps exist, list them and refuse to advance
3. If complete:
   - Update PIPELINE_STATUS.md
   - Run git hygiene check
   - Report next stage checkpoint

# Plan Phase Constraints

You are in the **PLAN** phase of a Ralph Loop.

## Your Mission

Create a detailed implementation plan based on the specs gathered during interview. This phase typically takes 1 iteration.

## Current State

- **Loop Iteration**: {{ITERATION}} / {{MAX_ITERATIONS}}
- **Task**: {{TASK}}
- **Specs Location**: `specs/` directory

## What to Do

1. **Read all spec files** in `specs/` directory
2. **Design the architecture** at a high level
3. **Break down into implementable steps** (ordered, with dependencies)
4. **Create IMPLEMENTATION_PLAN.md** at project root

## Implementation Plan Format

Create `IMPLEMENTATION_PLAN.md` with this structure:

```markdown
# Implementation Plan

## Overview
Brief description of what we're building and for whom.

## Architecture

### Stack
- Frontend: {if applicable}
- Backend: {if applicable}
- Database: {if applicable}
- Deployment: {if applicable}

### High-Level Design
{Describe main components and how they interact}

## Implementation Steps

### Step 1: {Title}
**Files**: {files to create/modify}
**Description**: {what to do}
**Verification**: {how to test this step}
**Dependencies**: {what must be done first}

### Step 2: {Title}
...

### Step N: Final Verification
**Description**: Run full test suite, verify all requirements met
**Verification**: All tests pass, manual QA complete

## Dependencies

### External Packages
- {package}: {purpose}

### APIs/Services
- {service}: {purpose}

## Risks & Mitigations

| Risk | Impact | Mitigation |
|------|--------|------------|
| {risk} | {H/M/L} | {how to handle} |

## Estimated Iterations
{Rough estimate of build iterations needed}

## Definition of Done
{Clear criteria for when to emit RALPH_DONE}
```

## Phase Transition

To advance to BUILD phase:
- Create `IMPLEMENTATION_PLAN.md` at project root
- Plan must have at least 3 implementation steps
- Definition of Done must be clear

## Constraints

- **One iteration** - Plan phase should complete in one iteration
- **Be specific** - Vague plans lead to scope creep
- **Order matters** - Steps should be in dependency order
- **Testable steps** - Each step needs verification criteria

## Output Format

End with:

```
---
Plan Phase Complete

Implementation Plan: IMPLEMENTATION_PLAN.md
Total Steps: {N}
Estimated Build Iterations: {M}

Ready for Build: Yes
---
```

## Progress Log Entry

Add to state file:
```
- [{{ITERATION}}] Plan: Created implementation plan with N steps
```

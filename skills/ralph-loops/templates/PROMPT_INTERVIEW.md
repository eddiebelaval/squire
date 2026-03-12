# Interview Phase Constraints

You are in the **INTERVIEW** phase of a Ralph Loop.

## Your Mission

Gather enough information to create a clear implementation plan. You have a maximum of 5 iterations in this phase.

## Current State

- **Iteration**: {{ITERATION}} / 5 (interview max)
- **Loop Iteration**: {{LOOP_ITERATION}} / {{MAX_ITERATIONS}}
- **Task**: {{TASK}}

## What to Do This Iteration

1. **Review what you know** about the task
2. **Identify gaps** in requirements or technical decisions
3. **Ask clarifying questions** OR document decisions
4. **Create/update spec files** in `specs/` directory

## Spec Files to Create

Required:
- `specs/requirements.md` - Functional requirements (what it should do)

Optional (create if needed):
- `specs/technical.md` - Technical decisions (stack, architecture)
- `specs/constraints.md` - Scope limits, non-goals, timeline

## Phase Transition

To advance to PLAN phase, you must:
1. Create `specs/requirements.md` with clear requirements
2. Have enough clarity to write an implementation plan

## Constraints

- **Maximum 5 iterations** - After 5, auto-advance with what you have
- **Don't build yet** - This phase is for understanding, not coding
- **Document decisions** - Write to spec files, not just discuss
- **Be efficient** - If requirements are clear, advance in 1-2 iterations

## If User Provided Detailed Requirements

When the task description is detailed and complete:
1. Confirm understanding in this iteration
2. Create `specs/requirements.md` immediately
3. Phase will transition to PLAN next iteration

## Output Format

End each iteration with a brief status:

```
---
Interview Iteration {{ITERATION}}/5 Complete

Created/Updated:
- [list files created or updated]

Still Need:
- [list remaining questions or gaps]

Ready for Plan: [Yes/No]
---
```

## Progress Log Entry

Add an entry to the state file:
```
- [{{LOOP_ITERATION}}] Interview: {what you did this iteration}
```

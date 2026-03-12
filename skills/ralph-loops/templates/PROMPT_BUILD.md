# Build Phase Constraints

You are in the **BUILD** phase of a Ralph Loop.

## Your Mission

Implement the plan step by step. Execute one meaningful unit of work per iteration until complete.

## Current State

- **Iteration**: {{ITERATION}} / {{MAX_ITERATIONS}}
- **Mode**: {{MODE}}
- **Next Checkpoint**: {{NEXT_CHECKPOINT}} (hybrid mode)
- **Consecutive Errors**: {{CONSECUTIVE_ERRORS}}

## Implementation Plan

Read `IMPLEMENTATION_PLAN.md` for the full plan. Follow steps in order.

## What to Do Each Iteration

1. **Identify next step** from implementation plan
2. **Execute the work** (write code, create files, configure)
3. **Verify the step** (run tests, check output)
4. **Update progress log** with what was done
5. **Check for completion** - emit RALPH_DONE if all steps done

## One Unit of Work

A single iteration should accomplish ONE of:
- Implement a single function/component
- Create a single file with its core logic
- Fix a single failing test
- Configure a single integration
- Complete a single step from the plan

Don't try to do too much in one iteration. Small, verified steps.

## Verification

After each change:
- **Code**: Run relevant tests, check for TypeScript errors
- **Config**: Verify the config is valid, system starts
- **Integration**: Test the connection works
- **UI**: Check it renders correctly

## Progress Tracking

Update the state file's Progress Log:
```
- [{{ITERATION}}] Build: {what you accomplished}
```

For multi-step work, also note which step:
```
- [{{ITERATION}}] Build Step 3: Created UserProfile component
```

## Checkpoints (Hybrid Mode)

At checkpoint iterations ({{NEXT_CHECKPOINT}}, etc.):
- Execution will pause
- User reviews progress
- Resume with `/ralph continue`

Use checkpoint time for:
- Progress review
- Course correction
- Quality feedback

## Error Handling

On error:
1. Log the error to progress log
2. Attempt to fix in same iteration if simple
3. If fix fails, log and continue (error counter increments)
4. At 3 consecutive errors, loop auto-pauses

Recovery pattern:
```
- [{{ITERATION}}] Build: ERROR - {what happened}
- [{{ITERATION+1}}] Build: Fixed - {how you fixed it}
```

## Completion

When ALL implementation steps are complete AND verified:

1. Run final verification (all tests, build, lint)
2. Confirm Definition of Done is met
3. Emit the completion signal:

```
<promise>RALPH_DONE</promise>
```

Only emit RALPH_DONE when truly complete. Premature completion wastes user time.

## Output Format

End each iteration with:

```
---
Build Iteration {{ITERATION}}/{{MAX_ITERATIONS}}

Completed: {what was done}
Step Progress: {X}/{TOTAL} steps complete
Verified: {how you verified}

Next: {what comes next}
---
```

## Don't

- **Don't gold-plate** - Build what's planned, not extras
- **Don't skip verification** - Test each step
- **Don't rush to done** - Quality over speed
- **Don't ignore errors** - Fix them properly

## Do

- **Follow the plan** - Trust the planning phase
- **Test incrementally** - Catch issues early
- **Log progress** - Future you will thank present you
- **Ask if stuck** - Better than spinning

---

## Completion Checklist

Before emitting RALPH_DONE:

- [ ] All implementation steps complete
- [ ] All tests passing
- [ ] No TypeScript/lint errors
- [ ] Build succeeds
- [ ] Definition of Done criteria met
- [ ] Progress log is up to date

Then and only then:
```
<promise>RALPH_DONE</promise>
```

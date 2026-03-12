# Ralph Loop Phase Transitions

This document defines the rules for transitioning between phases in a Ralph loop.

---

## Phase Diagram

```
                    +-----------+
                    |   START   |
                    +-----+-----+
                          |
                          v
                   +------+------+
            +----->|  INTERVIEW  |<----+
            |      +------+------+     |
            |             |            |
            |    specs/requirements.md |
            |      OR 5 iterations     |
            |             |            |
            |             v            |
         (loop)    +------+------+     |
            |      |    PLAN     |     |
            |      +------+------+     |
            |             |            |
            |   IMPLEMENTATION_PLAN.md |
            |             |            |
            |             v            |
            |      +------+------+     |
            +------|    BUILD    |-----+
                   +------+------+   (errors)
                          |
                    RALPH_DONE
                          |
                          v
                   +------+------+
                   |    DONE     |
                   +-------------+
```

---

## Transition Rules

### Interview -> Plan

**Trigger Conditions** (any of):
1. `specs/requirements.md` file exists
2. 5 interview iterations completed (forced transition)

**Hybrid Mode Behavior**:
- Pause at checkpoint
- Display: "Interview complete. Review specs/ directory."
- Wait for `/ralph continue`

**Auto Mode Behavior**:
- Immediate transition
- No pause

**State Changes**:
```yaml
phase: "plan"
checkpoints_cleared: [..., "interview_done"]
```

---

### Plan -> Build

**Trigger Conditions**:
1. `IMPLEMENTATION_PLAN.md` exists at project root

**Validation** (recommended):
- Plan has at least 3 implementation steps
- Definition of Done is defined
- Architecture section exists

**Hybrid Mode Behavior**:
- Pause at checkpoint
- Display: "Plan complete. Review IMPLEMENTATION_PLAN.md."
- Wait for `/ralph continue`

**Auto Mode Behavior**:
- Immediate transition
- No pause

**State Changes**:
```yaml
phase: "build"
checkpoints_cleared: [..., "plan_done"]
```

---

### Build -> Done

**Trigger Conditions**:
1. `<promise>RALPH_DONE</promise>` emitted in output

**Validation** (before emitting):
- All implementation steps complete
- All tests passing
- Build succeeds
- Definition of Done criteria met

**State Changes**:
```yaml
phase: "done"
completion_signal: "RALPH_DONE"
```

---

### Build -> Build (Checkpoint)

**Trigger Conditions** (Hybrid Mode only):
1. `iteration >= next_checkpoint`

**Behavior**:
- Pause execution
- Display: "Build checkpoint at iteration N."
- Wait for `/ralph continue`

**State Changes**:
```yaml
next_checkpoint: (previous + checkpoint_interval)
```

---

### Build -> Build (Error Pause)

**Trigger Conditions**:
1. `consecutive_errors >= 3`

**Behavior**:
- Pause execution (even in auto mode)
- Display: "3 consecutive errors. Pausing for review."
- Wait for `/ralph continue`

**Recovery**:
- Errors reset to 0 on next successful iteration
- User can adjust approach before continuing

---

## Forced Transitions

### Max Iterations Reached

**Condition**: `iteration >= max_iterations`

**Action**: Force transition to Done phase

**State Changes**:
```yaml
phase: "done"
completion_signal: null  # Not RALPH_DONE - incomplete
```

---

### Manual Kill

**Command**: `/ralph kill`

**Action**: Immediate termination

**State Changes**:
- State file preserved
- Phase unchanged
- Can be resumed later

---

## Checkpoint Clearing

### `/ralph continue` Command

**Action**:
1. Clear current checkpoint block
2. Resume iteration
3. Continue normal flow

**Does NOT**:
- Reset iteration counter
- Change phase
- Modify progress log

---

## State File Updates

Each transition updates:
- `phase`: New phase name
- `last_updated`: Current timestamp
- `checkpoints_cleared`: Append checkpoint name (if applicable)

---

## Debugging Transitions

### Check Current State
```bash
/ralph status
```

### Force Phase (Emergency)
```bash
# Manual edit of state file
vim .claude/ralph-loop.local.md
# Change phase: "desired_phase"
```

### Reset Loop
```bash
/ralph kill
rm .claude/ralph-loop.local.md
/ralph <task>
```

---

## Phase Duration Guidelines

| Phase | Typical Iterations | Max Iterations |
|-------|-------------------|----------------|
| Interview | 1-3 | 5 (hard limit) |
| Plan | 1 | 1-2 |
| Build | 10-50 | max_iterations |
| Done | 1 | 1 |

---

## Error Recovery

### During Interview
- Errors are rare (mostly reading/writing)
- 3 errors → pause, user can clarify requirements

### During Plan
- Errors indicate unclear requirements
- 3 errors → pause, may need to return to interview

### During Build
- Most common error location
- 3 errors → pause, user reviews approach
- Often indicates need for plan adjustment

---

## Transition Hooks

The `ralph-stop-hook.sh` handles all transitions by:
1. Checking trigger conditions
2. Updating state file
3. Returning appropriate exit code
4. Outputting transition messages

Exit codes:
- `0`: Continue normally
- `1`: Pause (checkpoint or error)

---

*Phase Transitions v1.0 - Ralph Loops Framework*

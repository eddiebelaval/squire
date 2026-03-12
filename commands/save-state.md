---
description: Force save current session state and create checkpoint
argument-hint: [reason]
---

# /save-state - Force Checkpoint

Creates an immediate checkpoint of the current session state. Use this before:
- Major refactoring
- Experimental changes
- Switching to a different part of the codebase
- Any risky operation

## Usage

### Basic Save
```
/save-state
```

### Save with Reason
```
/save-state Before implementing auth system
```

## What Gets Saved

A checkpoint includes:
- Current session status and progress
- All task statuses and assignments
- Files modified in this session
- Decisions made during development
- Last tool outputs
- Recovery instructions

## Implementation

Run this command in the session-resilience-agents project:

```bash
cd ~/Development/session-resilience-agents && npm run checkpoint -- --reason="$REASON"
```

Where `$REASON` is the argument provided to this command (or "Manual checkpoint" if none).

## When to Use

**Use /save-state before:**
- Risky refactoring
- Switching focus to different feature
- Taking a break
- Experimenting with approach
- Running destructive operations

**The system auto-saves:**
- Every 5 tool uses (Write, Edit, Bash, etc.)
- After each task completion
- Before running tests

## Verification

After saving, verify with:
```bash
cd ~/Development/session-resilience-agents && npm run status
```

You should see an incremented checkpoint count.

## Recovery

If anything goes wrong, resume from the checkpoint:
```bash
cd ~/Development/session-resilience-agents && npm run resume --checkpoint=CP-XXXXXX
```

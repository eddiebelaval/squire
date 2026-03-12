---
description: Resume a development session from checkpoint
argument-hint: [session-id or "latest"]
---

# /resume - Resume Development Session

You are helping resume work from a previous session that may have crashed or timed out.

## Recovery Process

### Step 1: Check for Recoverable Sessions

Run the recovery check to see what sessions need attention:

```bash
cd ~/Development/session-resilience-agents && npm run resume
```

### Step 2: Review Session State

If a session is found, you'll see:
- Session ID and project name
- Current progress percentage
- Last active timestamp
- Current phase and task
- Files that were modified
- Decisions that were made

### Step 3: Context Restoration

After resuming, restore the development context:

1. Read the session's recovery instructions
2. Check the plan file at `~/.claude/plans/` for full task list
3. Review git history for recent commits
4. Read any files that were in progress

### Step 4: Continue Development

With context restored:
1. Mark current task as in_progress if not already
2. Continue from where work stopped
3. Session state auto-saves every 5 tool uses
4. Use `/save-state` for immediate checkpoint

## Integration with Agents

The session state includes agent assignments for each task. When resuming:
- Check `assignedAgent` for the current task
- Delegate to that agent if appropriate
- MCP tools are listed in `assignedMcp`

## Examples

Resume the most recent session:
```
/resume
```

Resume a specific session:
```
/resume abc123-def456
```

## Quick Reference

| Command | Purpose |
|---------|---------|
| `npm run resume` | Interactive resume |
| `npm run status` | Check current state |
| `npm run checkpoint` | Force save |
| `npm run list` | See all sessions |

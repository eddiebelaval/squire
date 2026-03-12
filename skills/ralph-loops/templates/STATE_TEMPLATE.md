---
loop_id: "ralph-{{DATE}}-{{RANDOM}}"
mode: "{{MODE}}"
phase: "interview"
iteration: 1
max_iterations: {{MAX_ITERATIONS}}
completion_promise: "{{TASK}}"
completion_signal: null

# Checkpoint config (hybrid mode only)
checkpoint_interval: 10
next_checkpoint: 10
checkpoints_cleared: []

# Error tracking
consecutive_errors: 0
last_error: null

# Timestamps
started_at: "{{TIMESTAMP}}"
last_updated: "{{TIMESTAMP}}"
---

## Current Task

{{TASK}}

## Completion Criteria

To be defined during interview phase.

## Progress Log

- [1] Loop initialized, entering interview phase

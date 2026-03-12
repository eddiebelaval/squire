#!/bin/bash
# ralph-stop-hook.sh - Controls Ralph Loop iteration flow
# Registered under: stop event
#
# This hook:
# 1. Checks if a Ralph loop is active
# 2. Increments iteration counter
# 3. Checks for checkpoints (hybrid mode)
# 4. Checks for completion signal
# 5. Re-injects continuation prompt if loop should continue

set -e

# Find project root (look for .git or package.json)
find_project_root() {
    local dir="$PWD"
    while [[ "$dir" != "/" ]]; do
        if [[ -d "$dir/.git" ]] || [[ -f "$dir/package.json" ]]; then
            echo "$dir"
            return 0
        fi
        dir="$(dirname "$dir")"
    done
    echo "$PWD"
}

PROJECT_ROOT=$(find_project_root)
STATE_FILE="$PROJECT_ROOT/.claude/ralph-loop.local.md"

# Exit if no active loop
if [[ ! -f "$STATE_FILE" ]]; then
    exit 0
fi

# Parse YAML frontmatter
parse_yaml() {
    local key="$1"
    grep "^${key}:" "$STATE_FILE" | head -1 | sed 's/^[^:]*: *//' | tr -d '"'
}

# Update YAML value
update_yaml() {
    local key="$1"
    local value="$2"
    if grep -q "^${key}:" "$STATE_FILE"; then
        sed -i '' "s/^${key}:.*/${key}: \"${value}\"/" "$STATE_FILE"
    fi
}

# Read current state
PHASE=$(parse_yaml "phase")
MODE=$(parse_yaml "mode")
ITERATION=$(parse_yaml "iteration")
MAX_ITERATIONS=$(parse_yaml "max_iterations")
COMPLETION_SIGNAL=$(parse_yaml "completion_signal")
CHECKPOINT_INTERVAL=$(parse_yaml "checkpoint_interval")
NEXT_CHECKPOINT=$(parse_yaml "next_checkpoint")
CONSECUTIVE_ERRORS=$(parse_yaml "consecutive_errors")

# Check for completion
if [[ "$COMPLETION_SIGNAL" == "RALPH_DONE" ]] || [[ "$PHASE" == "done" ]]; then
    echo "RALPH_LOOP_COMPLETE"
    exit 0
fi

# Check max iterations
if [[ "$ITERATION" -ge "$MAX_ITERATIONS" ]]; then
    echo "RALPH_MAX_ITERATIONS_REACHED"
    update_yaml "phase" "done"
    exit 0
fi

# Increment iteration
NEW_ITERATION=$((ITERATION + 1))
update_yaml "iteration" "$NEW_ITERATION"
update_yaml "last_updated" "$(date -u +"%Y-%m-%dT%H:%M:%SZ")"

# Check for phase transitions
check_phase_transition() {
    case "$PHASE" in
        "interview")
            # Transition to plan if specs exist
            if [[ -f "$PROJECT_ROOT/specs/requirements.md" ]]; then
                # Check if we should checkpoint first (hybrid mode)
                if [[ "$MODE" == "hybrid" ]] && ! grep -q "interview_done" "$STATE_FILE"; then
                    # Add checkpoint cleared marker
                    sed -i '' 's/checkpoints_cleared: \[\]/checkpoints_cleared: ["interview_done"]/' "$STATE_FILE"
                    echo "RALPH_CHECKPOINT: Interview complete. Review specs/ directory. Use /ralph continue to proceed."
                    exit 1  # Non-zero exit pauses
                fi
                update_yaml "phase" "plan"
                echo "PHASE_TRANSITION: interview -> plan"
            elif [[ "$NEW_ITERATION" -gt 5 ]]; then
                # Force transition after 5 interview iterations
                update_yaml "phase" "plan"
                echo "PHASE_TRANSITION: interview -> plan (max interview iterations)"
            fi
            ;;
        "plan")
            # Transition to build if implementation plan exists
            if [[ -f "$PROJECT_ROOT/IMPLEMENTATION_PLAN.md" ]]; then
                if [[ "$MODE" == "hybrid" ]] && ! grep -q "plan_done" "$STATE_FILE"; then
                    # Update checkpoints
                    sed -i '' 's/checkpoints_cleared: \["interview_done"\]/checkpoints_cleared: ["interview_done", "plan_done"]/' "$STATE_FILE"
                    echo "RALPH_CHECKPOINT: Plan complete. Review IMPLEMENTATION_PLAN.md. Use /ralph continue to proceed."
                    exit 1
                fi
                update_yaml "phase" "build"
                echo "PHASE_TRANSITION: plan -> build"
            fi
            ;;
        "build")
            # Check for periodic checkpoint in hybrid mode
            if [[ "$MODE" == "hybrid" ]] && [[ "$NEW_ITERATION" -ge "$NEXT_CHECKPOINT" ]]; then
                # Set next checkpoint
                NEW_NEXT=$((NEXT_CHECKPOINT + CHECKPOINT_INTERVAL))
                update_yaml "next_checkpoint" "$NEW_NEXT"
                echo "RALPH_CHECKPOINT: Build checkpoint at iteration $NEW_ITERATION. Use /ralph continue to proceed."
                exit 1
            fi

            # Check for error threshold
            if [[ "$CONSECUTIVE_ERRORS" -ge 3 ]]; then
                echo "RALPH_ERROR_THRESHOLD: 3 consecutive errors. Pausing for review."
                exit 1
            fi
            ;;
    esac
}

check_phase_transition

# Determine which prompt template to inject
get_phase_prompt() {
    local template_dir="$HOME/.claude/skills/ralph-loops/templates"
    case "$PHASE" in
        "interview") echo "$template_dir/PROMPT_INTERVIEW.md" ;;
        "plan") echo "$template_dir/PROMPT_PLAN.md" ;;
        "build") echo "$template_dir/PROMPT_BUILD.md" ;;
        *) echo "" ;;
    esac
}

PROMPT_TEMPLATE=$(get_phase_prompt)

if [[ -n "$PROMPT_TEMPLATE" ]] && [[ -f "$PROMPT_TEMPLATE" ]]; then
    # Output continuation signal with context
    echo "RALPH_CONTINUE"
    echo "---"
    echo "Iteration: $NEW_ITERATION / $MAX_ITERATIONS"
    echo "Phase: $PHASE"
    echo "Mode: $MODE"
    if [[ "$MODE" == "hybrid" ]]; then
        echo "Next Checkpoint: $NEXT_CHECKPOINT"
    fi
    echo "---"

    # The actual prompt injection happens via Claude's hook system
    # This script signals continuation; the hook runner handles injection
fi

exit 0

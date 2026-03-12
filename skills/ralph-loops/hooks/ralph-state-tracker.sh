#!/bin/bash
# ralph-state-tracker.sh - Tracks state changes during Ralph loops
# Registered under: post-tool.Write and post-tool.Edit
#
# This hook:
# 1. Detects when key files are created/modified
# 2. Updates Ralph loop state accordingly
# 3. Tracks phase transition triggers

set -e

# Get the file that was written/edited from stdin or environment
FILE_PATH="${CLAUDE_TOOL_FILE_PATH:-}"

# If no file path, try to read from tool context
if [[ -z "$FILE_PATH" ]]; then
    exit 0
fi

# Find project root
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

# Parse YAML value
parse_yaml() {
    local key="$1"
    grep "^${key}:" "$STATE_FILE" | head -1 | sed 's/^[^:]*: *//' | tr -d '"'
}

PHASE=$(parse_yaml "phase")
ITERATION=$(parse_yaml "iteration")

# Track file creation for phase transitions
case "$FILE_PATH" in
    */specs/requirements.md)
        if [[ "$PHASE" == "interview" ]]; then
            echo "RALPH: specs/requirements.md created - ready for plan phase"
        fi
        ;;
    */specs/*.md)
        if [[ "$PHASE" == "interview" ]]; then
            echo "RALPH: Spec file created: $(basename "$FILE_PATH")"
        fi
        ;;
    */IMPLEMENTATION_PLAN.md)
        if [[ "$PHASE" == "plan" ]]; then
            echo "RALPH: IMPLEMENTATION_PLAN.md created - ready for build phase"
        fi
        ;;
esac

# Check for RALPH_DONE in written content
# This is a secondary check - primary is in the stop hook
if [[ -f "$FILE_PATH" ]]; then
    if grep -q "<promise>RALPH_DONE</promise>" "$FILE_PATH" 2>/dev/null; then
        # Update state file
        sed -i '' 's/^completion_signal:.*/completion_signal: "RALPH_DONE"/' "$STATE_FILE"
        sed -i '' 's/^phase:.*/phase: "done"/' "$STATE_FILE"
        echo "RALPH: Completion signal detected - loop complete"
    fi
fi

# Reset consecutive errors on successful file operation
ERRORS=$(parse_yaml "consecutive_errors")
if [[ "$ERRORS" -gt 0 ]]; then
    sed -i '' 's/^consecutive_errors:.*/consecutive_errors: 0/' "$STATE_FILE"
fi

# Update last_updated timestamp
TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")
sed -i '' "s/^last_updated:.*/last_updated: \"$TIMESTAMP\"/" "$STATE_FILE"

exit 0

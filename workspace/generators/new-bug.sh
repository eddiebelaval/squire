#!/bin/bash
set -e
source "$(dirname "$0")/_workspace-utils.sh"

show_help() {
  cat <<'HELP'
Usage: new-bug.sh "Description" [--severity <level>] [--project <path>]

Create a bug investigation file in workspace/tasks/.

Options:
  --severity <level>   low, medium (default), high, critical
  --project <path>     Target a specific project directory
  --help               Show this help message

Example:
  new-bug.sh "Login form resets on validation error" --severity high
HELP
}

DESCRIPTION=""
SEVERITY="medium"
PROJECT=""

while [ $# -gt 0 ]; do
  case "$1" in
    --severity)
      SEVERITY="$2"
      shift 2
      ;;
    --project)
      PROJECT="$2"
      shift 2
      ;;
    --help|-h)
      show_help
      exit 0
      ;;
    -*)
      err "Unknown option: $1"
      show_help
      exit 1
      ;;
    *)
      if [ -z "$DESCRIPTION" ]; then
        DESCRIPTION="$1"
      else
        err "Unexpected argument: $1"
        show_help
        exit 1
      fi
      shift
      ;;
  esac
done

if [ -z "$DESCRIPTION" ]; then
  err "Bug description is required"
  show_help
  exit 1
fi

case "$SEVERITY" in
  low|medium|high|critical) ;;
  *)
    err "Invalid severity: $SEVERITY (must be low, medium, high, or critical)"
    exit 1
    ;;
esac

WORKSPACE=$(resolve_workspace "$PROJECT") || exit 1
TASKS_DIR="$WORKSPACE/tasks"
mkdir -p "$TASKS_DIR"

DATE=$(today)
SLUG=$(slugify "$DESCRIPTION")
FILENAME="${DATE}-bug-${SLUG}.md"
FILEPATH="$TASKS_DIR/$FILENAME"

if [ -f "$FILEPATH" ]; then
  warn "Bug file already exists: $FILEPATH"
  echo "$FILEPATH"
  exit 0
fi

cat > "$FILEPATH" << EOF
---
title: "Bug: $DESCRIPTION"
date: $DATE
severity: $SEVERITY
status: investigating
type: bug
---

# Bug: $DESCRIPTION

## Summary

[1-2 sentence description of the bug and its user-visible impact.]

## Steps to Reproduce

1. [Step 1]
2. [Step 2]
3. [Step 3]

**Frequency:** Always | Intermittent | Rare

## Expected Behavior

[What should happen.]

## Actual Behavior

[What actually happens. Include error messages or logs.]

## Environment

| Field | Value |
|-------|-------|
| Branch | $(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo "[branch]") |
| Runtime | Node $(node --version 2>/dev/null || echo "[version]") |
| OS | $(uname -s) $(uname -r) |

## Investigation Log

### $DATE - Initial report

[What you know so far.]

## Root Cause

[Explain why the bug occurs once identified.]

**Root cause file(s):** \`[path/to/file.ts:lineNumber]\`

## Fix Plan

- [ ] [Describe the fix]
- [ ] [Edge cases to handle]

## Verification

- [ ] Bug no longer reproduces
- [ ] Build passes
- [ ] Existing tests pass
- [ ] New test added covering this case
EOF

ok "Created bug report: $FILENAME"
echo "$FILEPATH"

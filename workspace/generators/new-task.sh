#!/bin/bash
set -e
source "$(dirname "$0")/_workspace-utils.sh"

show_help() {
  cat <<'HELP'
Usage: new-task.sh "Title" [--priority <level>] [--project <path>]

Create a new task file in workspace/tasks/.

Options:
  --priority <level>   low, medium (default), high, critical
  --project <path>     Target a specific project directory
  --help               Show this help message

Example:
  new-task.sh "Implement user settings page" --priority high
HELP
}

TITLE=""
PRIORITY="medium"
PROJECT=""

while [ $# -gt 0 ]; do
  case "$1" in
    --priority)
      PRIORITY="$2"
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
      if [ -z "$TITLE" ]; then
        TITLE="$1"
      else
        err "Unexpected argument: $1"
        show_help
        exit 1
      fi
      shift
      ;;
  esac
done

if [ -z "$TITLE" ]; then
  err "Title is required"
  show_help
  exit 1
fi

case "$PRIORITY" in
  low|medium|high|critical) ;;
  *)
    err "Invalid priority: $PRIORITY (must be low, medium, high, or critical)"
    exit 1
    ;;
esac

WORKSPACE=$(resolve_workspace "$PROJECT") || exit 1
TASKS_DIR="$WORKSPACE/tasks"
mkdir -p "$TASKS_DIR"

DATE=$(today)
SLUG=$(slugify "$TITLE")
FILENAME="${DATE}-${SLUG}.md"
FILEPATH="$TASKS_DIR/$FILENAME"

if [ -f "$FILEPATH" ]; then
  warn "Task file already exists: $FILEPATH"
  echo "$FILEPATH"
  exit 0
fi

cat > "$FILEPATH" << EOF
---
title: "$TITLE"
date: $DATE
priority: $PRIORITY
status: open
type: task
---

# $TITLE

## Description

[Describe what needs to be done and why.]

## Acceptance Criteria

- [ ] [Criterion 1]
- [ ] [Criterion 2]

## Implementation Notes

[Technical details, approach, or constraints.]

## Related Files

- \`[path/to/relevant/file]\`
EOF

ok "Created task: $FILENAME"
echo "$FILEPATH"

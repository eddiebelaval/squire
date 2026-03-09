#!/bin/bash
set -e
source "$(dirname "$0")/_workspace-utils.sh"

show_help() {
  cat <<'HELP'
Usage: done-task.sh <task-file> [--project <path>]

Move a completed task to workspace/tasks/.done/ and mark it as completed.

Arguments:
  <task-file>        Path to the task file, or just the filename
                     (looks in workspace/tasks/ if no path given)

Options:
  --project <path>   Target a specific project directory
  --help             Show this help message

Example:
  done-task.sh 2026-02-08-implement-settings.md
  done-task.sh workspace/tasks/2026-02-08-implement-settings.md
HELP
}

TASK_FILE=""
PROJECT=""

while [ $# -gt 0 ]; do
  case "$1" in
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
      if [ -z "$TASK_FILE" ]; then
        TASK_FILE="$1"
      else
        err "Unexpected argument: $1"
        show_help
        exit 1
      fi
      shift
      ;;
  esac
done

if [ -z "$TASK_FILE" ]; then
  err "Task file is required"
  show_help
  exit 1
fi

WORKSPACE=$(resolve_workspace "$PROJECT") || exit 1
TASKS_DIR="$WORKSPACE/tasks"
DONE_DIR="$TASKS_DIR/.done"
mkdir -p "$DONE_DIR"

# If task-file is just a filename (no slashes), look in tasks dir
case "$TASK_FILE" in
  */*)
    FULL_PATH="$TASK_FILE"
    ;;
  *)
    FULL_PATH="$TASKS_DIR/$TASK_FILE"
    ;;
esac

if [ ! -f "$FULL_PATH" ]; then
  err "Task file not found: $FULL_PATH"
  exit 1
fi

DATE=$(today)
BASENAME=$(basename "$FULL_PATH")

# Update frontmatter
if head -1 "$FULL_PATH" | grep -q "^---"; then
  sed -i '' "s/^status: .*/status: completed/" "$FULL_PATH"
  if ! grep -q "^completed:" "$FULL_PATH"; then
    sed -i '' "/^status: completed/a\\
completed: $DATE" "$FULL_PATH"
  fi
else
  warn "No frontmatter found -- adding completion note at top"
  TEMP=$(mktemp)
  echo "<!-- completed: $DATE -->" > "$TEMP"
  cat "$FULL_PATH" >> "$TEMP"
  mv "$TEMP" "$FULL_PATH"
fi

DEST="$DONE_DIR/$BASENAME"
mv "$FULL_PATH" "$DEST"

ok "Task completed: $BASENAME -> tasks/.done/"
echo "$DEST"

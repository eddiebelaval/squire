#!/bin/bash
set -e
source "$(dirname "$0")/_workspace-utils.sh"

show_help() {
  cat <<'HELP'
Usage: new-project-workspace.sh [target-directory]

Create a workspace/ directory structure for a project.

Arguments:
  target-directory   Directory to create workspace in (default: current directory)

Options:
  --help             Show this help message

Structure created:
  workspace/
    README.md           How to use this workspace
    tasks/              Active task files
      .done/            Completed archive
    prep/               Architecture & research docs
    scratch/            Quick experiments (gitignored)
    ideas/              Project-specific future concepts
    decisions/          Architecture Decision Records
HELP
}

# Parse args
TARGET_DIR=""
while [ $# -gt 0 ]; do
  case "$1" in
    --help|-h)
      show_help
      exit 0
      ;;
    *)
      if [ -z "$TARGET_DIR" ]; then
        TARGET_DIR="$1"
      else
        err "Unexpected argument: $1"
        show_help
        exit 1
      fi
      shift
      ;;
  esac
done

if [ -z "$TARGET_DIR" ]; then
  TARGET_DIR="$(pwd)"
fi

WORKSPACE="$TARGET_DIR/workspace"

if [ -d "$WORKSPACE" ]; then
  warn "Workspace already exists at $WORKSPACE"
  echo "$WORKSPACE"
  exit 0
fi

info "Creating workspace at $WORKSPACE"

mkdir -p "$WORKSPACE/tasks/.done"
mkdir -p "$WORKSPACE/prep"
mkdir -p "$WORKSPACE/scratch"
mkdir -p "$WORKSPACE/ideas"
mkdir -p "$WORKSPACE/decisions"

cat > "$WORKSPACE/README.md" << 'README'
# Workspace

Project workspace for tasks, research, and architecture decisions.

## Structure

| Directory | Purpose |
|-----------|---------|
| `tasks/` | Active task files (bugs, features, general tasks) |
| `tasks/.done/` | Completed task archive |
| `prep/` | Architecture research, tech stack evaluations, cost analyses |
| `scratch/` | Quick experiments and throwaway code (gitignored) |
| `ideas/` | Future concepts and feature brainstorms |
| `decisions/` | Architecture Decision Records (ADRs) |

## Generator Scripts

Create new workspace items using the generator scripts:

```bash
# Tasks
new-task.sh "Title" --priority high
new-feature.sh "Feature Name" --branch
new-bug.sh "Bug description" --severity high

# Research
new-prep.sh "Topic" --type architecture

# Decisions
new-adr.sh "Decision title"

# Complete a task
done-task.sh <task-file>
```

## Conventions

- File names follow `YYYY-MM-DD-slug.md` format
- ADRs use `NNNN-slug.md` (auto-incrementing)
- Metadata block at top of each file tracks status, priority, dates
- Move completed tasks to `.done/` using `done-task.sh`
README

echo "*" > "$WORKSPACE/scratch/.gitignore"

ok "Workspace created at $WORKSPACE"
echo "$WORKSPACE"

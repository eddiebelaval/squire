#!/bin/bash
set -e
source "$(dirname "$0")/_workspace-utils.sh"

show_help() {
  cat <<'HELP'
Usage: new-feature.sh "Name" [--stage <n>] [--branch] [--project <path>]

Create a feature spec task file in workspace/tasks/.

Options:
  --stage <n>        Pipeline stage (default: 5 for "Build")
  --branch           Also create a git branch: feature/<slug>
  --project <path>   Target a specific project directory
  --help             Show this help message

Example:
  new-feature.sh "Dark mode support" --stage 5 --branch
HELP
}

NAME=""
STAGE="5"
CREATE_BRANCH=false
PROJECT=""

while [ $# -gt 0 ]; do
  case "$1" in
    --stage)
      STAGE="$2"
      shift 2
      ;;
    --branch)
      CREATE_BRANCH=true
      shift
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
      if [ -z "$NAME" ]; then
        NAME="$1"
      else
        err "Unexpected argument: $1"
        show_help
        exit 1
      fi
      shift
      ;;
  esac
done

if [ -z "$NAME" ]; then
  err "Feature name is required"
  show_help
  exit 1
fi

WORKSPACE=$(resolve_workspace "$PROJECT") || exit 1
TASKS_DIR="$WORKSPACE/tasks"
mkdir -p "$TASKS_DIR"

STAGE_NAME=""
case "$STAGE" in
  1)  STAGE_NAME="Concept Lock" ;;
  2)  STAGE_NAME="Scope Fence" ;;
  3)  STAGE_NAME="Architecture Sketch" ;;
  4)  STAGE_NAME="Foundation Pour" ;;
  5)  STAGE_NAME="Feature Blocks" ;;
  6)  STAGE_NAME="Integration Pass" ;;
  7)  STAGE_NAME="Test Coverage" ;;
  8)  STAGE_NAME="Polish & Harden" ;;
  9)  STAGE_NAME="Launch Prep" ;;
  10) STAGE_NAME="Ship" ;;
  11) STAGE_NAME="Listen & Iterate" ;;
  *)  STAGE_NAME="Stage $STAGE" ;;
esac

DATE=$(today)
SLUG=$(slugify "$NAME")
FILENAME="${DATE}-feature-${SLUG}.md"
FILEPATH="$TASKS_DIR/$FILENAME"

if [ -f "$FILEPATH" ]; then
  warn "Feature file already exists: $FILEPATH"
  echo "$FILEPATH"
  exit 0
fi

cat > "$FILEPATH" << EOF
---
title: "$NAME"
date: $DATE
priority: high
status: open
type: feature
stage: $STAGE ($STAGE_NAME)
branch: feature/$SLUG
---

# Feature: $NAME

## Overview

[1-3 sentences: what this feature does and why it matters.]

## Problem Statement

[What problem does this solve? Who is affected?]

## Proposed Solution

[High-level description of the approach.]

## User Stories

- As a [user type], I want to [action] so that [benefit].

## Technical Design

### Architecture

[How does this fit into the existing system?]

### API Changes

| Method | Path | Description |
|--------|------|-------------|
| | | |

### Database Changes

| Table | Column | Type | Notes |
|-------|--------|------|-------|
| | | | |

### Files to Create/Modify

| File | Action | Description |
|------|--------|-------------|
| | | |

## Acceptance Criteria

- [ ] [Criterion 1]
- [ ] [Criterion 2]

## Testing Strategy

- [ ] Unit tests for [core logic]
- [ ] Integration tests for [API endpoints]
- [ ] Manual testing for [edge cases]

## Open Questions

- [ ] [Question that needs answering]
EOF

ok "Created feature spec: $FILENAME"

if [ "$CREATE_BRANCH" = true ]; then
  BRANCH_NAME="feature/$SLUG"
  if git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
    info "Creating git branch: $BRANCH_NAME"
    git checkout -b "$BRANCH_NAME" 2>&1 >&2
    ok "Switched to branch: $BRANCH_NAME"
  else
    warn "Not in a git repository -- skipping branch creation"
  fi
fi

echo "$FILEPATH"

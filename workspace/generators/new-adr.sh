#!/bin/bash
set -e
source "$(dirname "$0")/_workspace-utils.sh"

show_help() {
  cat <<'HELP'
Usage: new-adr.sh "Decision title" [--project <path>]

Create an Architecture Decision Record in workspace/decisions/.
ADR number is auto-incrementing (scans existing files).

Options:
  --project <path>   Target a specific project directory
  --help             Show this help message

Example:
  new-adr.sh "Use Supabase over Firebase for auth"
HELP
}

TITLE=""
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
  err "Decision title is required"
  show_help
  exit 1
fi

WORKSPACE=$(resolve_workspace "$PROJECT") || exit 1
DECISIONS_DIR="$WORKSPACE/decisions"
mkdir -p "$DECISIONS_DIR"

# Auto-increment ADR number
MAX_NUM=0
for f in "$DECISIONS_DIR"/[0-9]*.md; do
  [ -f "$f" ] || continue
  BASENAME=$(basename "$f")
  NUM=$(echo "$BASENAME" | sed 's/^\([0-9]*\).*/\1/' | sed 's/^0*//')
  if [ -z "$NUM" ]; then
    NUM=0
  fi
  if [ "$NUM" -gt "$MAX_NUM" ]; then
    MAX_NUM="$NUM"
  fi
done

NEXT_NUM=$((MAX_NUM + 1))
PADDED=$(printf "%04d" "$NEXT_NUM")

DATE=$(today)
SLUG=$(slugify "$TITLE")
FILENAME="${PADDED}-${SLUG}.md"
FILEPATH="$DECISIONS_DIR/$FILENAME"

cat > "$FILEPATH" << EOF
---
title: "ADR-${PADDED}: $TITLE"
date: $DATE
status: proposed
---

# ADR-${PADDED}: $TITLE

## Status

Proposed

## Context

[What is the issue that we're seeing that is motivating this decision?]

## Decision

[What is the change that we're proposing and/or doing?]

## Consequences

### Positive

- [Benefit 1]

### Negative

- [Drawback 1]

### Neutral

- [Side effect or observation]

## Alternatives Considered

### [Alternative 1]

- **Pros:** [List]
- **Cons:** [List]
- **Why not:** [Reason]

## References

- [Link or resource]
EOF

ok "Created ADR: $FILENAME"
echo "$FILEPATH"

#!/bin/bash
set -e
source "$(dirname "$0")/_workspace-utils.sh"

show_help() {
  cat <<'HELP'
Usage: new-prep.sh "Topic" --type <type> [--project <path>]

Create a research/preparation document in workspace/prep/.

Options:
  --type <type>      Required. One of: architecture, api, competitor, tech-stack, cost, security
  --project <path>   Target a specific project directory
  --help             Show this help message

Example:
  new-prep.sh "Real-time sync options" --type tech-stack
HELP
}

TOPIC=""
TYPE=""
PROJECT=""

while [ $# -gt 0 ]; do
  case "$1" in
    --type)
      TYPE="$2"
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
      if [ -z "$TOPIC" ]; then
        TOPIC="$1"
      else
        err "Unexpected argument: $1"
        show_help
        exit 1
      fi
      shift
      ;;
  esac
done

if [ -z "$TOPIC" ]; then
  err "Topic is required"
  show_help
  exit 1
fi

if [ -z "$TYPE" ]; then
  err "--type is required"
  show_help
  exit 1
fi

case "$TYPE" in
  architecture|api|competitor|tech-stack|cost|security) ;;
  *)
    err "Invalid type: $TYPE"
    echo "Valid types: architecture, api, competitor, tech-stack, cost, security" >&2
    exit 1
    ;;
esac

WORKSPACE=$(resolve_workspace "$PROJECT") || exit 1
PREP_DIR="$WORKSPACE/prep"
mkdir -p "$PREP_DIR"

DATE=$(today)
SLUG=$(slugify "$TOPIC")
FILENAME="${DATE}-${TYPE}-${SLUG}.md"
FILEPATH="$PREP_DIR/$FILENAME"

if [ -f "$FILEPATH" ]; then
  warn "Prep file already exists: $FILEPATH"
  echo "$FILEPATH"
  exit 0
fi

# Check for prep template in the squire repo
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
TEMPLATE_DIR="$SCRIPT_DIR/../../prep-templates"
TEMPLATE_FILE="$TEMPLATE_DIR/${TYPE}.md"

if [ -f "$TEMPLATE_FILE" ]; then
  cp "$TEMPLATE_FILE" "$FILEPATH"
  sed -i '' "s/\[TITLE\]/$TOPIC/g" "$FILEPATH" 2>/dev/null || true
  sed -i '' "s/\[DATE\]/$DATE/g" "$FILEPATH" 2>/dev/null || true
  sed -i '' "s/\[TOPIC\]/$TOPIC/g" "$FILEPATH" 2>/dev/null || true
  ok "Created prep doc from template: $FILENAME"
else
  # Inline fallback templates
  cat > "$FILEPATH" << EOF
---
title: "$TOPIC"
date: $DATE
type: $TYPE
status: draft
---

# ${TYPE^} Research: $TOPIC

## Context

[What prompted this research?]

## Findings

[Key findings go here.]

## Recommendation

[Your recommendation based on the research.]

## References

- [Links and resources]
EOF
  ok "Created prep doc: $FILENAME"
fi

echo "$FILEPATH"

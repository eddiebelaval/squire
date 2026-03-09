#!/bin/bash
# _workspace-utils.sh -- Shared utilities for Squire workspace generator scripts
# Source this file: source "$(dirname "$0")/_workspace-utils.sh"

# -- Colors --
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

# -- Helpers --

# Output today's date in YYYY-MM-DD format
today() {
  date +%Y-%m-%d
}

# Convert text to a URL-friendly slug
# Usage: slugify "My Feature Title"
# Output: my-feature-title
slugify() {
  local input="$1"
  echo "$input" \
    | tr '[:upper:]' '[:lower:]' \
    | sed 's/[^a-z0-9 -]//g' \
    | sed 's/  */ /g' \
    | sed 's/ /-/g' \
    | sed 's/--*/-/g' \
    | sed 's/^-//' \
    | sed 's/-$//'
}

# Walk up from cwd (or given dir) to find a workspace/ directory
# Usage: find_workspace [start_dir]
# Returns the workspace path via stdout, exits 1 if not found
find_workspace() {
  local dir="${1:-$(pwd)}"
  while [ "$dir" != "/" ]; do
    if [ -d "$dir/workspace" ]; then
      echo "$dir/workspace"
      return 0
    fi
    dir=$(dirname "$dir")
  done
  echo "No workspace/ directory found walking up from ${1:-$(pwd)}" >&2
  return 1
}

# Resolve workspace path from --project flag or cwd
# If --project is given with a path, uses that; otherwise walks up from cwd
resolve_workspace() {
  local project="$1"
  if [ -n "$project" ]; then
    # If project looks like a path, use it directly
    if [ -d "$project/workspace" ]; then
      echo "$project/workspace"
    elif [ -d "$project" ]; then
      echo "No workspace/ found in $project" >&2
      echo "Run: new-project-workspace.sh in that directory first" >&2
      return 1
    else
      echo "Directory not found: $project" >&2
      return 1
    fi
  else
    find_workspace
  fi
}

# Print a success message
ok() {
  echo -e "${GREEN}[OK]${NC} $1" >&2
}

# Print an info message
info() {
  echo -e "${BLUE}[INFO]${NC} $1" >&2
}

# Print a warning message
warn() {
  echo -e "${YELLOW}[WARN]${NC} $1" >&2
}

# Print an error message
err() {
  echo -e "${RED}[ERROR]${NC} $1" >&2
}

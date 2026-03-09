#!/bin/bash
# Squire -- Agent Operating System Installer
# Installs commands, skills, prompts, and templates into your Claude Code config.
#
# Usage: curl -fsSL <raw-url>/install.sh | bash
#    or: ./install.sh [--uninstall] [--commands-only] [--dry-run]

set -euo pipefail

# -- Colors --
RED='\033[0;31m'
GREEN='\033[0;32m'
AMBER='\033[0;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
DIM='\033[2m'
RESET='\033[0m'

# -- Config --
CLAUDE_DIR="$HOME/.claude"
COMMANDS_DIR="$CLAUDE_DIR/commands"
SKILLS_DIR="$CLAUDE_DIR/skills"
PROMPTS_DIR="$CLAUDE_DIR/prompts"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DRY_RUN=false
UNINSTALL=false
COMMANDS_ONLY=false

# -- Parse args --
for arg in "$@"; do
  case "$arg" in
    --dry-run)     DRY_RUN=true ;;
    --uninstall)   UNINSTALL=true ;;
    --commands-only) COMMANDS_ONLY=true ;;
    --help|-h)
      echo "Squire -- Agent Operating System Installer"
      echo ""
      echo "Usage: ./install.sh [OPTIONS]"
      echo ""
      echo "Options:"
      echo "  --dry-run        Show what would be installed without making changes"
      echo "  --uninstall      Remove all Squire commands, skills, and prompts"
      echo "  --commands-only  Install only slash commands (skip skills and prompts)"
      echo "  -h, --help       Show this help message"
      exit 0
      ;;
    *)
      echo -e "${RED}Unknown option: $arg${RESET}"
      echo "Run ./install.sh --help for usage"
      exit 1
      ;;
  esac
done

# -- Banner --
echo ""
echo -e "${BOLD}Squire${RESET}"
echo -e "${DIM}Agent operating system for AI-assisted development${RESET}"
echo ""

# -- Uninstall flow --
if $UNINSTALL; then
  echo -e "${AMBER}Uninstalling Squire...${RESET}"
  echo ""

  removed=0
  for cmd in visualize blueprint integration-audit reconcile; do
    target="$COMMANDS_DIR/$cmd.md"
    if [ -f "$target" ]; then
      if $DRY_RUN; then
        echo -e "  ${DIM}Would remove:${RESET} $target"
      else
        rm "$target"
        echo -e "  ${RED}Removed:${RESET} $target"
      fi
      removed=$((removed + 1))
    fi
  done

  for skill in audit reconcile; do
    skill_target="$SKILLS_DIR/$skill/SKILL.md"
    if [ -f "$skill_target" ]; then
      if $DRY_RUN; then
        echo -e "  ${DIM}Would remove:${RESET} $skill_target"
      else
        rm "$skill_target"
        rmdir "$SKILLS_DIR/$skill" 2>/dev/null || true
        echo -e "  ${RED}Removed:${RESET} $skill_target"
      fi
      removed=$((removed + 1))
    fi
  done

  for prompt in code-review debug-systematic ship-readiness performance-audit security-audit test-strategy; do
    prompt_target="$PROMPTS_DIR/$prompt.md"
    if [ -f "$prompt_target" ]; then
      if $DRY_RUN; then
        echo -e "  ${DIM}Would remove:${RESET} $prompt_target"
      else
        rm "$prompt_target"
        echo -e "  ${RED}Removed:${RESET} $prompt_target"
      fi
      removed=$((removed + 1))
    fi
  done

  echo ""
  if [ "$removed" -eq 0 ]; then
    echo -e "${DIM}Nothing to remove -- Squire was not installed.${RESET}"
  elif $DRY_RUN; then
    echo -e "${AMBER}Dry run complete. $removed file(s) would be removed.${RESET}"
  else
    echo -e "${GREEN}Uninstalled $removed file(s). Squire removed.${RESET}"
  fi
  exit 0
fi

# -- Pre-flight checks --
echo -e "${DIM}Checking environment...${RESET}"

if [ ! -d "$CLAUDE_DIR" ]; then
  echo -e "${AMBER}~/.claude/ directory not found.${RESET}"
  echo ""
  echo "Claude Code stores its configuration in ~/.claude/"
  echo "This directory is created automatically when you first run Claude Code."
  echo ""
  read -p "Create ~/.claude/ now? (y/N) " -n 1 -r
  echo ""
  if [[ $REPLY =~ ^[Yy]$ ]]; then
    if $DRY_RUN; then
      echo -e "  ${DIM}Would create:${RESET} $CLAUDE_DIR"
    else
      mkdir -p "$CLAUDE_DIR"
      echo -e "  ${GREEN}Created:${RESET} $CLAUDE_DIR"
    fi
  else
    echo -e "${RED}Cannot install without ~/.claude/ directory. Exiting.${RESET}"
    exit 1
  fi
fi

if [ ! -d "$SCRIPT_DIR/commands" ]; then
  echo -e "${RED}Error: commands/ directory not found in $SCRIPT_DIR${RESET}"
  echo "Make sure you're running this from the squire directory."
  exit 1
fi

echo -e "  ${GREEN}Claude Code directory:${RESET} $CLAUDE_DIR"
echo ""

# -- Install commands --
echo -e "${BOLD}Installing commands...${RESET}"
echo ""

if $DRY_RUN; then
  echo -e "  ${DIM}Would create:${RESET} $COMMANDS_DIR/"
else
  mkdir -p "$COMMANDS_DIR"
fi

installed=0
for cmd in visualize blueprint integration-audit reconcile; do
  src="$SCRIPT_DIR/commands/$cmd.md"
  dest="$COMMANDS_DIR/$cmd.md"

  if [ ! -f "$src" ]; then
    continue
  fi

  if $DRY_RUN; then
    lines=$(wc -l < "$src" | tr -d ' ')
    echo -e "  ${DIM}Would install:${RESET} /$cmd ${DIM}($lines lines)${RESET}"
  else
    cp "$src" "$dest"
    lines=$(wc -l < "$src" | tr -d ' ')
    echo -e "  ${GREEN}Installed:${RESET} /$cmd ${DIM}($lines lines)${RESET}"
  fi
  installed=$((installed + 1))
done

echo ""

# -- Install skills --
if ! $COMMANDS_ONLY; then
  echo -e "${BOLD}Installing skills...${RESET}"
  echo ""

  for skill in audit reconcile; do
    skill_src="$SCRIPT_DIR/skills/$skill/SKILL.md"
    skill_dest="$SKILLS_DIR/$skill/SKILL.md"

    if [ -f "$skill_src" ]; then
      if $DRY_RUN; then
        lines=$(wc -l < "$skill_src" | tr -d ' ')
        echo -e "  ${DIM}Would install:${RESET} /$skill skill ${DIM}($lines lines)${RESET}"
      else
        mkdir -p "$SKILLS_DIR/$skill"
        cp "$skill_src" "$skill_dest"
        lines=$(wc -l < "$skill_src" | tr -d ' ')
        echo -e "  ${GREEN}Installed:${RESET} /$skill skill ${DIM}($lines lines)${RESET}"
      fi
      installed=$((installed + 1))
    fi
  done

  echo ""

  # -- Install prompts --
  echo -e "${BOLD}Installing thinking frameworks...${RESET}"
  echo ""

  if $DRY_RUN; then
    echo -e "  ${DIM}Would create:${RESET} $PROMPTS_DIR/"
  else
    mkdir -p "$PROMPTS_DIR"
  fi

  for prompt in "$SCRIPT_DIR"/prompts/*.md; do
    [ -f "$prompt" ] || continue
    name=$(basename "$prompt")
    dest="$PROMPTS_DIR/$name"

    if $DRY_RUN; then
      lines=$(wc -l < "$prompt" | tr -d ' ')
      echo -e "  ${DIM}Would install:${RESET} $name ${DIM}($lines lines)${RESET}"
    else
      cp "$prompt" "$dest"
      lines=$(wc -l < "$prompt" | tr -d ' ')
      echo -e "  ${GREEN}Installed:${RESET} $name ${DIM}($lines lines)${RESET}"
    fi
    installed=$((installed + 1))
  done

  echo ""
fi

# -- Summary --
echo -e "${DIM}────────────────────────────────────────────────${RESET}"
echo ""

if $DRY_RUN; then
  echo -e "${AMBER}Dry run complete.${RESET} $installed file(s) would be installed."
  echo "Run without --dry-run to install."
else
  echo -e "${GREEN}${BOLD}Installation complete!${RESET} $installed file(s) installed."
  echo ""
  echo -e "${BOLD}Commands:${RESET}"
  echo -e "  ${CYAN}/visualize${RESET} [topic]          Interactive HTML visualizations"
  echo -e "  ${CYAN}/blueprint${RESET} [project]        Persistent build plans with progress tracking"
  echo -e "  ${CYAN}/integration-audit${RESET} [path]   Full-stack feature audit"
  echo -e "  ${CYAN}/reconcile${RESET}                  Living document maintenance"
  if ! $COMMANDS_ONLY; then
    echo ""
    echo -e "${BOLD}Skills:${RESET}"
    echo -e "  ${CYAN}/audit${RESET} [scope]             Codebase health audit"
    echo -e "  ${CYAN}/reconcile${RESET}                 Document reconciliation (5 modes)"
    echo ""
    echo -e "${BOLD}Also installed:${RESET}"
    echo -e "  6 thinking frameworks in ~/.claude/prompts/"
    echo -e "  (code-review, debug, ship-readiness, performance, security, test-strategy)"
  fi
  echo ""
  echo -e "${BOLD}Standalone (no install needed):${RESET}"
  echo -e "  ${CYAN}squire.md${RESET}                   Copy to project root for agent behavioral rules"
  echo -e "  ${CYAN}BUILDING-SETUP.md${RESET}           Copy to project root for self-installing build journal"
  echo ""
  echo -e "${DIM}Open Claude Code and type any command to get started.${RESET}"
fi

echo ""

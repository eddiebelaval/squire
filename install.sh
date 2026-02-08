#!/bin/bash
# Claude Visual Toolkit — Install Wizard
# Installs /visualize, /blueprint, /integration-audit commands and /audit skill
# into your Claude Code configuration directory.
#
# Usage: curl -fsSL <raw-url>/install.sh | bash
#    or: ./install.sh [--uninstall] [--commands-only] [--dry-run]

set -euo pipefail

# ── Colors ──────────────────────────────────────────────────────────────────
RED='\033[0;31m'
GREEN='\033[0;32m'
AMBER='\033[0;33m'
CYAN='\033[0;36m'
BOLD='\033[1m'
DIM='\033[2m'
RESET='\033[0m'

# ── Config ──────────────────────────────────────────────────────────────────
CLAUDE_DIR="$HOME/.claude"
COMMANDS_DIR="$CLAUDE_DIR/commands"
SKILLS_DIR="$CLAUDE_DIR/skills"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DRY_RUN=false
UNINSTALL=false
COMMANDS_ONLY=false

# ── Parse args ──────────────────────────────────────────────────────────────
for arg in "$@"; do
  case "$arg" in
    --dry-run)     DRY_RUN=true ;;
    --uninstall)   UNINSTALL=true ;;
    --commands-only) COMMANDS_ONLY=true ;;
    --help|-h)
      echo "Claude Visual Toolkit Installer"
      echo ""
      echo "Usage: ./install.sh [OPTIONS]"
      echo ""
      echo "Options:"
      echo "  --dry-run        Show what would be installed without making changes"
      echo "  --uninstall      Remove all toolkit commands and skills"
      echo "  --commands-only  Install only slash commands (skip /audit skill)"
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

# ── Banner ──────────────────────────────────────────────────────────────────
echo ""
echo -e "${BOLD}Claude Visual Toolkit${RESET}"
echo -e "${DIM}Interactive visualizations for Claude Code${RESET}"
echo ""

# ── Uninstall flow ──────────────────────────────────────────────────────────
if $UNINSTALL; then
  echo -e "${AMBER}Uninstalling Claude Visual Toolkit...${RESET}"
  echo ""

  removed=0
  for cmd in visualize blueprint integration-audit; do
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

  skill_target="$SKILLS_DIR/audit/SKILL.md"
  if [ -f "$skill_target" ]; then
    if $DRY_RUN; then
      echo -e "  ${DIM}Would remove:${RESET} $skill_target"
    else
      rm "$skill_target"
      rmdir "$SKILLS_DIR/audit" 2>/dev/null || true
      echo -e "  ${RED}Removed:${RESET} $skill_target"
    fi
    removed=$((removed + 1))
  fi

  echo ""
  if [ "$removed" -eq 0 ]; then
    echo -e "${DIM}Nothing to remove — toolkit was not installed.${RESET}"
  elif $DRY_RUN; then
    echo -e "${AMBER}Dry run complete. $removed file(s) would be removed.${RESET}"
  else
    echo -e "${GREEN}Uninstalled $removed file(s). Toolkit removed.${RESET}"
  fi
  exit 0
fi

# ── Pre-flight checks ──────────────────────────────────────────────────────
echo -e "${DIM}Checking environment...${RESET}"

# Check for Claude Code directory
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

# Check for source files
if [ ! -d "$SCRIPT_DIR/commands" ]; then
  echo -e "${RED}Error: commands/ directory not found in $SCRIPT_DIR${RESET}"
  echo "Make sure you're running this from the claude-visual-toolkit directory."
  exit 1
fi

echo -e "  ${GREEN}Claude Code directory:${RESET} $CLAUDE_DIR"
echo ""

# ── Detect existing installations ──────────────────────────────────────────
existing=0
for cmd in visualize blueprint integration-audit; do
  if [ -f "$COMMANDS_DIR/$cmd.md" ]; then
    existing=$((existing + 1))
  fi
done
if [ -f "$SKILLS_DIR/audit/SKILL.md" ]; then
  existing=$((existing + 1))
fi

if [ "$existing" -gt 0 ]; then
  echo -e "${AMBER}Found $existing existing file(s) from a previous install.${RESET}"
  echo "These will be overwritten with the latest versions."
  echo ""
  if ! $DRY_RUN; then
    read -p "Continue? (Y/n) " -n 1 -r
    echo ""
    if [[ $REPLY =~ ^[Nn]$ ]]; then
      echo "Installation cancelled."
      exit 0
    fi
  fi
fi

# ── Install commands ────────────────────────────────────────────────────────
echo -e "${BOLD}Installing commands...${RESET}"
echo ""

if $DRY_RUN; then
  echo -e "  ${DIM}Would create:${RESET} $COMMANDS_DIR/"
else
  mkdir -p "$COMMANDS_DIR"
fi

installed=0
for cmd in visualize blueprint integration-audit; do
  src="$SCRIPT_DIR/commands/$cmd.md"
  dest="$COMMANDS_DIR/$cmd.md"

  if [ ! -f "$src" ]; then
    echo -e "  ${RED}Missing:${RESET} $src (skipped)"
    continue
  fi

  if $DRY_RUN; then
    lines=$(wc -l < "$src" | tr -d ' ')
    echo -e "  ${DIM}Would install:${RESET} /$cmd ${DIM}($lines lines)${RESET}"
  else
    cp "$src" "$dest"
    lines=$(wc -l < "$src" | tr -d ' ')
    echo -e "  ${GREEN}Installed:${RESET} /$cmd ${DIM}($lines lines)${RESET} -> $dest"
  fi
  installed=$((installed + 1))
done

echo ""

# ── Install skills ──────────────────────────────────────────────────────────
if ! $COMMANDS_ONLY; then
  echo -e "${BOLD}Installing skills...${RESET}"
  echo ""

  skill_src="$SCRIPT_DIR/skills/audit/SKILL.md"
  skill_dest="$SKILLS_DIR/audit/SKILL.md"

  if [ -f "$skill_src" ]; then
    if $DRY_RUN; then
      echo -e "  ${DIM}Would create:${RESET} $SKILLS_DIR/audit/"
      lines=$(wc -l < "$skill_src" | tr -d ' ')
      echo -e "  ${DIM}Would install:${RESET} /audit skill ${DIM}($lines lines)${RESET}"
    else
      mkdir -p "$SKILLS_DIR/audit"
      cp "$skill_src" "$skill_dest"
      lines=$(wc -l < "$skill_src" | tr -d ' ')
      echo -e "  ${GREEN}Installed:${RESET} /audit skill ${DIM}($lines lines)${RESET} -> $skill_dest"
    fi
    installed=$((installed + 1))
  else
    echo -e "  ${AMBER}Skipped:${RESET} /audit skill (source not found)"
  fi

  echo ""
fi

# ── Summary ─────────────────────────────────────────────────────────────────
echo -e "${DIM}────────────────────────────────────────────────${RESET}"
echo ""

if $DRY_RUN; then
  echo -e "${AMBER}Dry run complete.${RESET} $installed file(s) would be installed."
  echo "Run without --dry-run to install."
else
  echo -e "${GREEN}${BOLD}Installation complete!${RESET} $installed file(s) installed."
  echo ""
  echo -e "${BOLD}Available commands:${RESET}"
  echo ""
  echo -e "  ${CYAN}/visualize${RESET} [topic]       Create interactive HTML visual explanations"
  echo -e "  ${CYAN}/blueprint${RESET} [project]     Generate persistent build plans with progress tracking"
  echo -e "  ${CYAN}/integration-audit${RESET} [path] Audit feature integration across all stack layers"
  if ! $COMMANDS_ONLY; then
    echo -e "  ${CYAN}/audit${RESET} [scope]           Run a structured read-only codebase health audit"
  fi
  echo ""
  echo -e "${DIM}Open Claude Code and type any command to get started.${RESET}"
fi

echo ""

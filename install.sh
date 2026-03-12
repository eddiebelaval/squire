#!/bin/bash
# Squire -- Agent Operating System Installer
# Installs commands, skills, agents, prompts, and templates into your Claude Code config.
#
# Usage: ./install.sh [OPTIONS]
#
# Examples:
#   ./install.sh                 # Install everything
#   ./install.sh --commands      # Commands only
#   ./install.sh --skills        # Skills only
#   ./install.sh --agents        # Agents only
#   ./install.sh --rules         # Just squire.md to project root
#   ./install.sh --dry-run       # Preview without changes

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
AGENTS_DIR="$CLAUDE_DIR/agents"
PROMPTS_DIR="$CLAUDE_DIR/prompts"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# -- Flags --
DRY_RUN=false
UNINSTALL=false
INSTALL_COMMANDS=false
INSTALL_SKILLS=false
INSTALL_AGENTS=false
INSTALL_PROMPTS=false
INSTALL_RULES=false
INSTALL_PIPELINE=false
INSTALL_ALL=true

# -- Parse args --
for arg in "$@"; do
  case "$arg" in
    --dry-run)     DRY_RUN=true ;;
    --uninstall)   UNINSTALL=true ;;
    --commands)    INSTALL_COMMANDS=true; INSTALL_ALL=false ;;
    --skills)      INSTALL_SKILLS=true; INSTALL_ALL=false ;;
    --agents)      INSTALL_AGENTS=true; INSTALL_ALL=false ;;
    --prompts)     INSTALL_PROMPTS=true; INSTALL_ALL=false ;;
    --rules)       INSTALL_RULES=true; INSTALL_ALL=false ;;
    --pipeline)    INSTALL_PIPELINE=true; INSTALL_ALL=false ;;
    --help|-h)
      echo "Squire -- Agent Operating System Installer"
      echo ""
      echo "Usage: ./install.sh [OPTIONS]"
      echo ""
      echo "Install options (mix and match):"
      echo "  --commands     Install slash commands to ~/.claude/commands/"
      echo "  --skills       Install skills to ~/.claude/skills/"
      echo "  --agents       Install agents to ~/.claude/agents/"
      echo "  --prompts      Install thinking frameworks to ~/.claude/prompts/"
      echo "  --rules        Copy squire.md to current directory"
      echo "  --pipeline     Copy pipeline + templates to current directory"
      echo ""
      echo "  (no flags)     Install everything"
      echo ""
      echo "Other options:"
      echo "  --dry-run      Show what would be installed without making changes"
      echo "  --uninstall    Remove all Squire-installed files"
      echo "  -h, --help     Show this help message"
      exit 0
      ;;
    *)
      echo -e "${RED}Unknown option: $arg${RESET}"
      echo "Run ./install.sh --help for usage"
      exit 1
      ;;
  esac
done

# If --all, enable everything
if $INSTALL_ALL; then
  INSTALL_COMMANDS=true
  INSTALL_SKILLS=true
  INSTALL_AGENTS=true
  INSTALL_PROMPTS=true
fi

# -- Banner --
echo ""
echo -e "${BOLD}Squire${RESET}"
echo -e "${DIM}Agent operating system for AI-assisted development${RESET}"
echo -e "${DIM}318 skills | 56 commands | 23 agents | 6 frameworks${RESET}"
echo ""

# -- Uninstall flow --
if $UNINSTALL; then
  echo -e "${AMBER}Uninstalling Squire...${RESET}"
  echo ""

  removed=0

  # Remove commands
  if [ -d "$COMMANDS_DIR" ]; then
    for cmd in "$SCRIPT_DIR"/commands/*.md; do
      [ -f "$cmd" ] || continue
      name=$(basename "$cmd")
      target="$COMMANDS_DIR/$name"
      if [ -f "$target" ]; then
        if $DRY_RUN; then
          echo -e "  ${DIM}Would remove:${RESET} $target"
        else
          rm "$target"
          echo -e "  ${RED}Removed:${RESET} commands/$name"
        fi
        removed=$((removed + 1))
      fi
    done
  fi

  # Remove skills
  if [ -d "$SKILLS_DIR" ]; then
    for skill_dir in "$SCRIPT_DIR"/skills/*/; do
      [ -d "$skill_dir" ] || continue
      name=$(basename "$skill_dir")
      target="$SKILLS_DIR/$name"
      if [ -d "$target" ]; then
        if $DRY_RUN; then
          echo -e "  ${DIM}Would remove:${RESET} $target/"
        else
          rm -rf "$target"
          echo -e "  ${RED}Removed:${RESET} skills/$name/"
        fi
        removed=$((removed + 1))
      fi
    done
  fi

  # Remove agents
  if [ -d "$AGENTS_DIR" ]; then
    for agent in "$SCRIPT_DIR"/agents/*.md; do
      [ -f "$agent" ] || continue
      name=$(basename "$agent")
      target="$AGENTS_DIR/$name"
      if [ -f "$target" ]; then
        if $DRY_RUN; then
          echo -e "  ${DIM}Would remove:${RESET} $target"
        else
          rm "$target"
          echo -e "  ${RED}Removed:${RESET} agents/$name"
        fi
        removed=$((removed + 1))
      fi
    done
  fi

  # Remove prompts
  if [ -d "$PROMPTS_DIR" ]; then
    for prompt in "$SCRIPT_DIR"/prompts/*.md; do
      [ -f "$prompt" ] || continue
      name=$(basename "$prompt")
      target="$PROMPTS_DIR/$name"
      if [ -f "$target" ]; then
        if $DRY_RUN; then
          echo -e "  ${DIM}Would remove:${RESET} $target"
        else
          rm "$target"
          echo -e "  ${RED}Removed:${RESET} prompts/$name"
        fi
        removed=$((removed + 1))
      fi
    done
  fi

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

echo -e "  ${GREEN}Claude Code directory:${RESET} $CLAUDE_DIR"
echo ""

installed=0

# -- Install commands --
if $INSTALL_COMMANDS; then
  echo -e "${BOLD}Installing commands...${RESET}"

  if $DRY_RUN; then
    echo -e "  ${DIM}Would create:${RESET} $COMMANDS_DIR/"
  else
    mkdir -p "$COMMANDS_DIR"
  fi

  cmd_count=0
  for cmd in "$SCRIPT_DIR"/commands/*.md; do
    [ -f "$cmd" ] || continue
    name=$(basename "$cmd" .md)
    dest="$COMMANDS_DIR/$(basename "$cmd")"

    if $DRY_RUN; then
      echo -e "  ${DIM}Would install:${RESET} /$name"
    else
      cp "$cmd" "$dest"
    fi
    cmd_count=$((cmd_count + 1))
    installed=$((installed + 1))
  done

  echo -e "  ${GREEN}$cmd_count commands${RESET}"
  echo ""
fi

# -- Install skills --
if $INSTALL_SKILLS; then
  echo -e "${BOLD}Installing skills...${RESET}"

  skill_count=0
  for skill_dir in "$SCRIPT_DIR"/skills/*/; do
    [ -d "$skill_dir" ] || continue
    name=$(basename "$skill_dir")
    dest="$SKILLS_DIR/$name"

    if $DRY_RUN; then
      :
    else
      mkdir -p "$dest"
      cp -r "$skill_dir"* "$dest/" 2>/dev/null || true
    fi
    skill_count=$((skill_count + 1))
    installed=$((installed + 1))
  done

  echo -e "  ${GREEN}$skill_count skills${RESET}"
  echo ""
fi

# -- Install agents --
if $INSTALL_AGENTS; then
  echo -e "${BOLD}Installing agents...${RESET}"

  if $DRY_RUN; then
    echo -e "  ${DIM}Would create:${RESET} $AGENTS_DIR/"
  else
    mkdir -p "$AGENTS_DIR"
  fi

  agent_count=0
  for agent in "$SCRIPT_DIR"/agents/*.md; do
    [ -f "$agent" ] || continue
    name=$(basename "$agent" .md)
    dest="$AGENTS_DIR/$(basename "$agent")"

    if $DRY_RUN; then
      echo -e "  ${DIM}Would install:${RESET} $name"
    else
      cp "$agent" "$dest"
    fi
    agent_count=$((agent_count + 1))
    installed=$((installed + 1))
  done

  echo -e "  ${GREEN}$agent_count agents${RESET}"
  echo ""
fi

# -- Install prompts --
if $INSTALL_PROMPTS; then
  echo -e "${BOLD}Installing thinking frameworks...${RESET}"

  if $DRY_RUN; then
    echo -e "  ${DIM}Would create:${RESET} $PROMPTS_DIR/"
  else
    mkdir -p "$PROMPTS_DIR"
  fi

  prompt_count=0
  for prompt in "$SCRIPT_DIR"/prompts/*.md; do
    [ -f "$prompt" ] || continue
    name=$(basename "$prompt" .md)
    dest="$PROMPTS_DIR/$(basename "$prompt")"

    if $DRY_RUN; then
      echo -e "  ${DIM}Would install:${RESET} $name"
    else
      cp "$prompt" "$dest"
    fi
    prompt_count=$((prompt_count + 1))
    installed=$((installed + 1))
  done

  echo -e "  ${GREEN}$prompt_count frameworks${RESET}"
  echo ""
fi

# -- Install rules --
if $INSTALL_RULES; then
  echo -e "${BOLD}Installing behavioral rules...${RESET}"
  src="$SCRIPT_DIR/squire.md"
  dest="./squire.md"

  if [ -f "$src" ]; then
    if $DRY_RUN; then
      echo -e "  ${DIM}Would copy:${RESET} squire.md -> ./squire.md"
    else
      cp "$src" "$dest"
      echo -e "  ${GREEN}Copied:${RESET} squire.md to project root"
    fi
    installed=$((installed + 1))
  fi
  echo ""
fi

# -- Install pipeline --
if $INSTALL_PIPELINE; then
  echo -e "${BOLD}Installing pipeline + templates...${RESET}"

  if [ -d "$SCRIPT_DIR/pipeline" ]; then
    if $DRY_RUN; then
      echo -e "  ${DIM}Would copy:${RESET} pipeline/"
    else
      cp -r "$SCRIPT_DIR/pipeline" ./
      echo -e "  ${GREEN}Copied:${RESET} pipeline/"
    fi
    installed=$((installed + 1))
  fi

  if [ -d "$SCRIPT_DIR/templates" ]; then
    if $DRY_RUN; then
      echo -e "  ${DIM}Would copy:${RESET} templates/"
    else
      cp -r "$SCRIPT_DIR/templates" ./
      echo -e "  ${GREEN}Copied:${RESET} templates/ (VISION.md, SPEC.md, TRIAD.md)"
    fi
    installed=$((installed + 1))
  fi

  if [ -f "$SCRIPT_DIR/BUILDING-SETUP.md" ]; then
    if $DRY_RUN; then
      echo -e "  ${DIM}Would copy:${RESET} BUILDING-SETUP.md"
    else
      cp "$SCRIPT_DIR/BUILDING-SETUP.md" ./
      echo -e "  ${GREEN}Copied:${RESET} BUILDING-SETUP.md (self-installing build journal)"
    fi
    installed=$((installed + 1))
  fi

  echo ""
fi

# -- Summary --
echo -e "${DIM}────────────────────────────────────────────────${RESET}"
echo ""

if $DRY_RUN; then
  echo -e "${AMBER}Dry run complete.${RESET} $installed item(s) would be installed."
  echo "Run without --dry-run to install."
else
  echo -e "${GREEN}${BOLD}Done.${RESET} $installed item(s) installed."
  echo ""
  if $INSTALL_COMMANDS || $INSTALL_ALL; then
    echo -e "${BOLD}Top commands:${RESET}"
    echo -e "  ${CYAN}/ship${RESET}            Full delivery pipeline (preflight -> commit -> PR -> merge)"
    echo -e "  ${CYAN}/fix${RESET}             Systematic bug diagnosis"
    echo -e "  ${CYAN}/visualize${RESET}       Interactive HTML visualizations"
    echo -e "  ${CYAN}/blueprint${RESET}       Build plans with progress tracking"
    echo -e "  ${CYAN}/deploy${RESET}          Production deployment with rollback"
    echo -e "  ${CYAN}/research${RESET}        Research orchestrator"
    echo -e "  ${CYAN}/reconcile${RESET}       Triad document maintenance"
    echo ""
  fi
  echo -e "${BOLD}Standalone (no install needed):${RESET}"
  echo -e "  ${CYAN}squire.md${RESET}          Copy to project root for behavioral rules"
  echo -e "  ${CYAN}BUILDING-SETUP.md${RESET}  Copy to project root for self-installing build journal"
  echo ""
  echo -e "${DIM}Open Claude Code and type any command to get started.${RESET}"
fi

echo ""

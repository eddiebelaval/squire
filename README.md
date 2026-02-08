# Claude Visual Toolkit

Slash commands for [Claude Code](https://docs.anthropic.com/en/docs/claude-code) that generate interactive HTML visualizations, build plans, and integration audits — all from your terminal.

Built by [id8Labs](https://id8labs.app). Ships with a one-line installer.

---

## What's Inside

### `/visualize` — Interactive Visual Explanations

Turn any concept, architecture, workflow, or codebase structure into a self-contained HTML visualization. Dark-themed, animated, interactive — no external dependencies.

```
/visualize Homer architecture
/visualize how Supabase RLS works
/visualize the deployment pipeline
```

**Features:**
- Tabbed views, flow diagrams, tree views, interactive cards
- Animated SVG flow lines (flowing dashes, traveling pulses, glow effects)
- Stats counters with count-up animation
- Expandable/collapsible sections
- Senior Dev Assessment tab with copy-paste fix prompts
- Factory-inspired design system (dark theme, warm neutrals, orange accents)

### `/blueprint` — Persistent Build Plans

Generate interactive build plans that survive context limits. Progress persists in `localStorage` — check off tasks as you complete them, and the progress bar updates in real time.

```
/blueprint Homer V2 — full rebuild with new dashboard
/blueprint DeepStack live trading
/blueprint --update homer-v2
```

**Features:**
- 6-round structured interview before generating (scope, architecture, phases, parallelism, risks, confirmation)
- Parallel batch columns — identify work that can run simultaneously
- localStorage checkbox persistence with strikethrough styling
- SVG dependency graph showing critical path
- Copy-paste prompts for every task (self-contained, scoped, verifiable)
- Architecture tab with component diagrams and file maps

### `/integration-audit` — Full-Stack Feature Audit

Scan an entire project and map whether each feature is wired end-to-end across every layer: Database, API, Auth, Types, Store, UI, and Page. Outputs an interactive HTML report.

```
/integration-audit ~/Development/Homer
/integration-audit
```

**Features:**
- 4 parallel agents scan simultaneously (API routes, frontend, database, state management)
- Integration matrix with color-coded cells (Y/N/P for each layer)
- Expandable rows showing actual file paths per layer
- Gap analysis with severity levels and copy-paste fix prompts
- Architecture flow diagram with animated connections
- Works on any Next.js + Supabase project (adaptable to other stacks)

### `/audit` — Codebase Health Audit

A read-only structural audit covering 5 dimensions: Security, Dead Code, Wiring Gaps, Type Safety, and UI Shells. Outputs a prioritized text report.

```
/audit
/audit security,dead-code
/audit src/api
```

---

## Design System

All visualizations follow the **Factory-inspired** design language:

| Token | Value | Usage |
|-------|-------|-------|
| Background | `#020202` | Near-black (not pure black) |
| Text | `#eeeeee` | Near-white (not pure white) |
| Accent | `#ef6f2e` | Orange — primary highlights |
| Secondary | `#f59e0b` | Amber — warnings, second-tier |
| Success | `#4ecdc4` | Teal — rare, success states |
| Fonts | Geist + Geist Mono | With system fallbacks |
| Headings | Weight 400 | Light weight, tight letter-spacing |
| Borders | Warm neutrals | Brownish undertone, never blue-gray |

**Rules:** No shadows, no gradients, no glow effects, no emojis. Typography and whitespace ARE the design.

---

## Installation

### Quick Install (recommended)

Clone the repo and run the installer:

```bash
git clone https://github.com/eddiebelaval/claude-visual-toolkit.git
cd claude-visual-toolkit
chmod +x install.sh
./install.sh
```

### Manual Install

Copy the files into your Claude Code configuration:

```bash
# Commands
cp commands/visualize.md ~/.claude/commands/
cp commands/blueprint.md ~/.claude/commands/
cp commands/integration-audit.md ~/.claude/commands/

# Skills
mkdir -p ~/.claude/skills/audit
cp skills/audit/SKILL.md ~/.claude/skills/audit/
```

### Options

```bash
./install.sh --dry-run        # Preview what will be installed
./install.sh --commands-only   # Skip the /audit skill
./install.sh --uninstall       # Remove all toolkit files
```

---

## How It Works

Claude Code slash commands are markdown files in `~/.claude/commands/`. When you type `/visualize` in Claude Code, it reads the corresponding `.md` file as a prompt template — the instructions tell Claude how to generate the visualization.

Skills work similarly but live in `~/.claude/skills/<name>/SKILL.md` and can include more complex behavior.

These commands are **prompt engineering** — they don't execute code themselves. Instead, they instruct Claude to:
1. Scan your codebase using its built-in tools (Glob, Grep, Read)
2. Cross-reference findings to build a mental model
3. Generate a single self-contained HTML file with the results
4. Save and open it automatically

The HTML files are zero-dependency — no CDN links, no external CSS/JS. Everything is inline.

---

## Customization

### Changing the design system

Edit the CSS variables in `commands/visualize.md` under the "Design System" section. All commands reference this spec, so changes propagate everywhere.

### Adding new commands

Create a new `.md` file in `~/.claude/commands/` following the same pattern:

```markdown
# /my-command - Description

## Instructions

[What Claude should do when this command is invoked]

## Output

[What the output should look like]
```

### Changing the output directory

By default, visualizations save to `~/Development/artifacts/<project>/`. Edit the "Save and open" section in each command file to change this path.

---

## Examples

The `examples/` directory contains sample outputs from each command:

- `examples/integration-audit-screenshot.png` — Homer integration audit matrix
- `examples/blueprint-screenshot.png` — Build plan with parallel batches

---

## Requirements

- [Claude Code](https://docs.anthropic.com/en/docs/claude-code) CLI installed and configured
- A Claude API key with sufficient quota (visualizations use Claude's tools heavily)
- macOS, Linux, or WSL (the installer is a bash script)

---

## Contributing

Found a bug or want to add a new visual command? PRs welcome.

1. Fork this repo
2. Add or modify commands in `commands/`
3. Test by copying to `~/.claude/commands/` and running in Claude Code
4. Submit a PR with before/after screenshots

---

## License

MIT License. See [LICENSE](LICENSE) for details.

---

Built with Claude Code by [id8Labs](https://id8labs.app).

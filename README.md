# Squire

An agent operating system for AI-assisted development. Battle-tested behavioral rules, stage-gate pipelines, multi-model orchestration, and reusable thinking frameworks -- all derived from hundreds of real sessions, thousands of messages, and hundreds of commits.

**335 sessions taught us how AI agents fail. This is the operating system that prevents it.**

---

## What This Is

Squire is a collection of rules, patterns, templates, and tools that make AI coding agents (Claude Code, Cursor, Copilot, etc.) more reliable, more productive, and less likely to waste your time.

It's not a product. It's an operating system -- a set of files you drop into your project or your global config that change how your agent behaves.

**What you get:**

| Component | What It Does |
|-----------|-------------|
| [`squire.md`](squire.md) | The flagship. A complete behavioral ruleset for AI agents -- drop it into your project root or `~/.claude/CLAUDE.md` |
| [Pipeline](pipeline/) | 11-stage build system with gate questions, agent-native additions, and branch hygiene |
| [Patterns](patterns/) | Battle-tested behavioral rules and multi-model orchestration (Director/Builder) |
| [Prompts](prompts/) | 6 thinking frameworks for code review, debugging, security, performance, testing, and ship readiness |
| [Commands](commands/) | Claude Code slash commands: `/visualize`, `/blueprint`, `/integration-audit`, `/reconcile` |
| [Skills](skills/) | Claude Code skills: `/audit`, `/reconcile` |
| [Templates](templates/) | Living documentation system: VISION.md + SPEC.md (The Triangle) |
| [Doc Templates](doc-templates/) | Feature specs, ADRs, deployment checklists, implementation plans |
| [Workspace](workspace/) | File-based project organization with generator scripts for tasks, bugs, features, and ADRs |
| [BUILDING-SETUP.md](BUILDING-SETUP.md) | Self-installing build journal -- drop into any project, it sets itself up and maintains itself |

---

## Quick Start

### Option 1: Just the behavioral rules

Copy `squire.md` to your project root. That's it. Claude Code reads it automatically.

```bash
curl -fsSL https://raw.githubusercontent.com/eddiebelaval/squire/main/squire.md > squire.md
```

Or for global rules (all projects):

```bash
curl -fsSL https://raw.githubusercontent.com/eddiebelaval/squire/main/squire.md >> ~/.claude/CLAUDE.md
```

### Option 2: Full toolkit

Clone the repo and run the installer:

```bash
git clone https://github.com/eddiebelaval/squire.git
cd squire
chmod +x install.sh
./install.sh
```

### Option 3: Cherry-pick what you need

Everything is standalone. Copy individual files:

```bash
# Just the thinking frameworks
cp squire/prompts/*.md ~/.claude/prompts/

# Just the slash commands
cp squire/commands/*.md ~/.claude/commands/

# Just the build journal
cp squire/BUILDING-SETUP.md ./

# Just the workspace generators
cp -r squire/workspace/generators/ ./generators/
```

---

## The 9 Rules

These are the behavioral corrections that emerged from analyzing real sessions. Each one addresses a specific failure pattern where AI agents consistently waste time or introduce bugs.

| # | Rule | Failure It Prevents |
|---|------|-------------------|
| 1 | **Default to implementation** | Agent plans endlessly instead of building |
| 2 | **Plan means plan** | User asks for a plan, gets an audit or exploration instead |
| 3 | **Preflight before push** | Broken code pushed to remote without verification |
| 4 | **Investigate bugs directly** | Agent dismisses errors as "stale cache" without looking |
| 5 | **Scope changes to the target** | Config change for one project applied globally |
| 6 | **Verify after each edit** | Batch edits create cascading type errors |
| 7 | **Visual output verification** | Agent re-reads CSS instead of checking rendered output |
| 8 | **Check your environment** | CLI command runs against wrong project/environment |
| 9 | **Don't over-engineer** | Simple feature gets unnecessary abstractions |

Full descriptions with friction patterns: [`patterns/behavioral-rules.md`](patterns/behavioral-rules.md)

---

## The Triangle -- Living Product Documentation

A three-document system that replaces your dead PRD:

```
        VISION.md
       (FUTURE)
        /    \
       /      \
      /  THE   \
     /  WORK    \
    /            \
SPEC.md -------- BUILDING.md
(PRESENT)         (PAST)
```

- **VISION.md** -- Where it's going (the evolving north star)
- **SPEC.md** -- Where it is right now (the testable contract)
- **BUILDING.md** -- How it got here (the build journal)

**The gap between VISION and SPEC IS the roadmap.** No separate roadmap document needed. Any two documents can reconstruct the third.

Use `/reconcile` to maintain the triangle conversationally -- it interviews you and writes the docs.

---

## Pipeline -- Stage-Gate Build System

11 stages from concept to production, each with a gate question that must be answered before advancing:

1. **Concept Lock** -- "What's the one-liner?"
2. **Scope Fence** -- "What are we NOT building?"
3. **Architecture Sketch** -- "Draw me the boxes and arrows."
4. **Foundation Pour** -- "Can we deploy an empty shell?"
5. **Feature Blocks** -- "Does this feature work completely, right now?"
6. **Integration Pass** -- "Do all the pieces talk to each other?"
7. **Test Coverage** -- "Are all tests green?"
8. **Polish & Harden** -- "What breaks if I do something stupid?"
9. **Launch Prep** -- "Could a stranger use this?"
10. **Ship** -- "Is it live?"
11. **Listen & Iterate** -- "What did we learn?"

Each stage includes agent-native additions for AI-assisted development. Full spec: [`pipeline/pipeline.md`](pipeline/pipeline.md)

---

## Director/Builder -- Multi-Model Orchestration

A pattern for using two AI models together:

- **Director** (reasoning model): Plans, reviews, integrates, ships
- **Builder** (code generation model): Executes scoped implementation tasks

This creates error diversity, context efficiency, and built-in code review. The Director never ships code it hasn't verified.

Failure threshold: 2 Builder failures on the same task = Director takes over.

Full spec: [`patterns/director-builder.md`](patterns/director-builder.md)

---

## Thinking Frameworks

Reusable prompt templates for common tasks:

| Framework | When to Use |
|-----------|------------|
| [`code-review.md`](prompts/code-review.md) | Before approving any PR -- 7-dimension systematic review |
| [`debug-systematic.md`](prompts/debug-systematic.md) | When encountering a bug -- reproduce, isolate, hypothesize, fix, prevent |
| [`ship-readiness.md`](prompts/ship-readiness.md) | Before deploying -- 8-section go/no-go checklist |
| [`performance-audit.md`](prompts/performance-audit.md) | When something is slow -- measure first, optimize second |
| [`security-audit.md`](prompts/security-audit.md) | Before shipping auth or data features -- STRIDE analysis |
| [`test-strategy.md`](prompts/test-strategy.md) | When planning test coverage -- pyramid balance, edge cases, CI integration |

---

## Slash Commands

| Command | What It Does |
|---------|-------------|
| `/visualize` | Interactive HTML visualizations of architecture, workflows, codebases |
| `/blueprint` | Persistent build plans with progress tracking and parallel batches |
| `/integration-audit` | Full-stack feature audit across all layers (DB, API, auth, types, UI) |
| `/reconcile` | Living document maintenance -- conversational drift detection |

## Skills

| Skill | What It Does |
|-------|-------------|
| `/audit` | Read-only codebase health audit (security, dead code, wiring gaps, type safety) |
| `/reconcile` | 5-mode document reconciliation for the Triangle system |

---

## Workspace Generators

Shell scripts for file-based project organization:

```bash
# Create workspace structure
./workspace/generators/new-project-workspace.sh

# Create task/bug/feature/ADR files
./workspace/generators/new-task.sh "Implement auth" --priority high
./workspace/generators/new-bug.sh "Login fails on Safari" --severity critical
./workspace/generators/new-feature.sh "Dark mode" --stage 5 --branch
./workspace/generators/new-adr.sh "Use Supabase over Firebase"
./workspace/generators/new-prep.sh "Auth options" --type tech-stack

# Complete a task (moves to .done/)
./workspace/generators/done-task.sh 2026-03-09-implement-auth.md
```

---

## Installation Options

```bash
./install.sh                # Full install (commands + skills)
./install.sh --dry-run      # Preview what will be installed
./install.sh --commands-only # Skip skills
./install.sh --uninstall    # Remove all toolkit files
```

---

## Design System

All HTML visualizations follow the **Factory-inspired** design language:

| Token | Value | Usage |
|-------|-------|-------|
| Background | `#020202` | Near-black |
| Text | `#eeeeee` | Near-white |
| Accent | `#ef6f2e` | Orange -- primary |
| Secondary | `#f59e0b` | Amber -- secondary |
| Success | `#4ecdc4` | Teal -- success |
| Fonts | Geist + Geist Mono | With system fallbacks |

**Rules:** No shadows, no gradients, no glow effects. Typography and whitespace ARE the design.

---

## How It Works

**`squire.md`** and slash commands are prompt files. They don't execute code -- they instruct AI agents to use their built-in tools to scan, analyze, and generate. A well-specified prompt is a reusable tool.

**Generator scripts** are plain bash. They create markdown files with frontmatter metadata. No dependencies beyond bash 3.2+.

**Templates** are document starters. Copy them or let `/reconcile init` generate them conversationally.

---

## Origin

This toolkit was built by [Eddie Belaval](https://x.com/eddiebe) at [id8Labs](https://id8labs.app) while shipping multiple AI-augmented products with Claude Code. Every rule, pattern, and template came from real friction -- sessions where something went wrong, and the fix was documented so it wouldn't happen again.

The behavioral rules are backed by data: 335 sessions, 2,210 messages, 261 commits analyzed across a month of intensive development. The top 9 friction patterns became the 9 rules. The pipeline came from shipping 6 products through the same stage-gate system. The thinking frameworks came from doing the same types of reviews repeatedly and wanting consistency.

If this helps you build better with AI, that's the goal.

**X:** [@eddiebe](https://x.com/eddiebe) | **GitHub:** [eddiebelaval](https://github.com/eddiebelaval) | **Site:** [id8labs.app](https://id8labs.app)

---

## License

MIT License. See [LICENSE](LICENSE) for details.

# Squire

The most complete Claude Code toolkit in the wild. Battle-tested behavioral rules, 56 slash commands, 318 skills, 23 custom agents, stage-gate pipelines, multi-model orchestration, and reusable thinking frameworks -- all derived from 1,075 sessions and 3,667 commits across 5 months of intensive AI-augmented development.

**3,667 commits taught us how AI agents fail. This is the operating system that prevents it.**

---

## What This Is

Squire is a collection of rules, patterns, templates, and tools that make AI coding agents (Claude Code, Cursor, Copilot, etc.) more reliable, more productive, and less likely to waste your time.

It's not a product. It's an operating system -- a set of files you drop into your project or your global config that change how your agent behaves.

**What you get:**

| Component | Count | What It Does |
|-----------|-------|-------------|
| [`squire.md`](squire.md) | 1 | The flagship. A complete behavioral ruleset for AI agents -- drop it into your project root or `~/.claude/CLAUDE.md` |
| [Commands](commands/) | 56 | Claude Code slash commands: `/ship`, `/deploy`, `/research`, `/visualize`, `/blueprint`, `/fix`, `/test`, and 50 more |
| [Skills](skills/) | 318 | Specialized skills across engineering, marketing, finance, AI/ML, design, and operations |
| [Agents](agents/) | 23 | Custom agents with tool access for architecture, security, DevOps, and more |
| [Pipeline](pipeline/) | 11 stages | Stage-gate build system with gate questions, agent-native additions, and branch hygiene |
| [Patterns](patterns/) | 7 | Battle-tested behavioral rules and multi-model orchestration (Director/Builder) |
| [Prompts](prompts/) | 6 | Thinking frameworks for code review, debugging, security, performance, testing, and ship readiness |
| [Templates](templates/) | 3 | The Triad: VISION.md + SPEC.md + BUILDING.md -- self-correcting product documentation |
| [Doc Templates](doc-templates/) | 6 | Feature specs, ADRs, deployment checklists, implementation plans |
| [Workspace](workspace/) | 6 generators | File-based project organization with generator scripts for tasks, bugs, features, and ADRs |
| [BUILDING-SETUP.md](BUILDING-SETUP.md) | 1 | Self-installing build journal -- drop into any project, it sets itself up and maintains itself |

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

## The Triad -- Living Product Documentation

A three-document system that replaces your dead PRD. Three documents that stay in sync because they reference each other. Any two can reconstruct the third.

```
        VISION.md
        (FUTURE)
         /    \
        /      \
       / THE    \
      / WORK     \
     /            \
SPEC.md -------- BUILDING.md
(PRESENT)          (PAST)
```

- **VISION.md** -- Where it's going. Soul, pillars (REALIZED/PARTIAL/UNREALIZED), anti-vision, edges.
- **SPEC.md** -- Where it is right now. Testable contract with drift detection (CURRENT/DRIFTED/STALE).
- **BUILDING.md** -- How it got here. Self-installing, auto-updating build journal with check-in interviews.

**The gap between VISION and SPEC IS the roadmap.** No separate roadmap document. The unrealized pillars are what you build next. The delta between "what we want" and "what we have" tells you everything.

**Self-correcting:** When one document drifts, the others expose it. SPEC says "supports real-time" but VISION never mentioned it? Either VISION needs updating or the feature is scope creep.

**Self-installing:** Drop `BUILDING-SETUP.md` into any project root. It explores your codebase, interviews you about the origin story, generates a personalized BUILDING.md, then deletes itself.

Use `/reconcile` to maintain the Triad conversationally -- it detects drift, interviews you about what changed, and updates all three documents.

Full guide: [`templates/TRIAD.md`](templates/TRIAD.md)

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

## Slash Commands (55+)

### Development Workflow

| Command | What It Does |
|---------|-------------|
| `/ship` | Full delivery pipeline: preflight checks, commit, push, PR, merge |
| `/fix` | Systematic bug diagnosis and root-cause debugging |
| `/test` | Browser-based feature testing with Playwright |
| `/test-verify` | Auto-detect project type and run appropriate tests |
| `/deploy` | Production deployment with preflight, smoke tests, and rollback |
| `/deploy-watch` | Monitor deployment status until live |
| `/start` | Begin new feature with branch creation and planning |
| `/release` | Promote dev to main with preflight checks and merge verification |
| `/rollback` | Safe undo of recent changes with soft/hard options |
| `/cleanup` | Code cleanup workflow (dead code, organization, security) |
| `/preview` | Pre-commit review with quality checks and risk assessment |
| `/mobile-check` | Comprehensive mobile viewport testing |

### Architecture & Analysis

| Command | What It Does |
|---------|-------------|
| `/visualize` | Interactive HTML visualizations of architecture, workflows, codebases |
| `/blueprint` | Persistent build plans with progress tracking and parallel batches |
| `/codebase-map` | Interactive architecture visualization with protocol completion tracking |
| `/integration-audit` | Full-stack feature audit across all layers (DB, API, auth, types, UI) |
| `/explain` | Plain-English code/concept explanation for any audience |
| `/compare` | Change visualization and impact assessment |
| `/dev-assess` | 3-expert technical assessment with triangulation |
| `/adr` | Architecture Decision Record creation with conversational interview |

### Planning & Ideas

| Command | What It Does |
|---------|-------------|
| `/feature-dev` | Complete feature development workshop (discovery, planning, build) |
| `/idea` | Feature brainstorming with approach exploration and feasibility |
| `/task` | Quick task creation with conversational details capture |
| `/prep` | Research and investigation document creation |
| `/reconcile` | Living document maintenance -- conversational drift detection |

### Content & Distribution

| Command | What It Does |
|---------|-------------|
| `/research` | Research orchestrator with queue, branch, and compound operations |
| `/distro` | Marketing/distribution pipeline (7 stages) |
| `/publish` | 6-agent editorial pipeline for content publishing |
| `/write-article` | Write and publish articles with voice profile |
| `/write-research` | Generate research articles |
| `/post-linkedin` | LinkedIn content publishing with voice adaptation |
| `/announce-release` | Full release announcement pipeline |

### Operations

| Command | What It Does |
|---------|-------------|
| `/morning` | Daily standup brief across all active projects |
| `/status` | Quick project status check |
| `/save-state` | Checkpoint current work state |
| `/resume` | Resume from a saved checkpoint |
| `/review-codex` | Review and resolve multi-model builder work |

## Skills (287)

Specialized skills organized by domain:

| Category | Count | Examples |
|----------|-------|---------|
| Frontend | 32 | ui-builder, nextjs-project-manager, layout-designer, expo-deployment |
| Backend | 19 | senior-backend, database-design, supabase-expert, api-design |
| Architecture & DevOps | 12 | senior-architect, senior-devops, cto-advisor, ci-cd-pipeline-builder |
| Code Quality | 10 | code-reviewer, testing-qa, test-generator, git-workflow-designer |
| AI & Automation | 15 | prompt-engineer, rag-pipeline-builder, agent-orchestrator, chain-builder |
| SEO | 6 | seo-analyst, seo-audit, programmatic-seo, schema-markup |
| CRO | 10 | form-cro, page-cro, signup-flow-cro, ab-test-designer |
| Content & Social | 20 | copywriting, blog-post-writer, social-content, newsletter-writer |
| Marketing Strategy | 9 | launch-strategy, growth-hacker, competitive-intelligence, gtm-strategist |
| Financial | 12 | cash-flow-forecaster, runway-calculator, revenue-modeler, budget-planner |
| Startup & Fundraising | 10 | pitch-deck-creator, fundraising-strategist, cap-table-manager |
| Operations | 8 | compliance-checker, contract-analyzer, vendor-manager |
| Product Management | 12 | mvp-planner, pmf-analyzer, user-research, roadmap-builder |
| Design | 10 | wireframe-creator, mockup-generator, brand-identity-builder |
| UX | 6 | onboarding-designer, chatbot-designer, faq-builder |
| Writing | 15 | technical-writer, white-paper-author, case-study-writer, grant-writer |
| Communication | 8 | email-composer, presentation-maker, slide-deck-designer |
| Browser Automation | 3 | browser-use, omni-vu, automation-architect |

## Agents (30+)

Custom agents with tool access -- not static prompts, but executable specialists:

| Agent | Specialty |
|-------|-----------|
| nextjs-senior-dev | Next.js 14+ App Router, performance, complex patterns |
| backend-architect | RESTful APIs, microservice boundaries, database schemas |
| operations-manager | Project coordination, quality control, process optimization |
| payment-security-specialist | Payment flow security, PCI compliance |
| stripe-integration-specialist | Stripe billing, subscriptions, webhooks |
| database-migration-specialist | Schema migrations, zero-downtime changes |
| mcp-server-architect | MCP server design and implementation |
| social-media-manager | Cross-platform content, engagement optimization |
| market-intelligence-analyst | Market research, trend analysis, competitor intelligence |
| text-editor-architect | Rich text editor design and implementation |
| steve-jobs-advisor | Product vision, design philosophy, strategic clarity |
| *...and 20+ more* | Security, DevOps, testing, email, relationships |

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

This toolkit was built by [Eddie Belaval](https://x.com/eddiebe) at [id8Labs](https://id8labs.app) while shipping 12+ AI-augmented products with Claude Code over 5 months. Every rule, pattern, and template came from real friction -- sessions where something went wrong, and the fix was documented so it wouldn't happen again.

### The Numbers

| Metric | Count |
|--------|-------|
| Sessions | 1,075 |
| Commits | 3,667 |
| Products shipped | 12+ |
| Skills built | 318 |
| Slash commands | 56 |
| Custom agents | 23 |
| Duration | 5 months (Oct 2025 - Mar 2026) |

```
Oct 2025:  ████████████████░░░░░░░░░░░░░░   364 commits  (ramp-up)
Nov 2025:  ███████████░░░░░░░░░░░░░░░░░░░   269 commits  (learning)
Dec 2025:  █████████░░░░░░░░░░░░░░░░░░░░░   215 commits  (holidays)
Jan 2026:  ██████████████████████████████░   916 commits  (ignition)
Feb 2026:  ████████████████████████████████ 1,215 commits (peak)
Mar 2026:  █████████████████████░░░░░░░░░░   487 commits  (12 days in)
```

The behavioral rules are backed by data: the top friction patterns across those sessions became the 9 rules. The pipeline came from shipping 12 products through the same stage-gate system. The thinking frameworks came from doing the same types of reviews repeatedly and wanting consistency.

If this helps you build better with AI, that's the goal.

**X:** [@eddiebe](https://x.com/eddiebe) | **GitHub:** [eddiebelaval](https://github.com/eddiebelaval) | **Site:** [id8labs.app](https://id8labs.app)

---

## License

MIT License. See [LICENSE](LICENSE) for details.

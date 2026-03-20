---
last-evolved: 2026-03-18
confidence: HIGH
distance: 15%
pillars: "6 (5R realized, 1P partial, 0U unrealized)"
---

# VISION

## Soul

Make AI coding agents reliable, productive, and predictable by encoding the behavioral corrections, workflows, and tooling that emerged from 2,990 real sessions into a single drop-in toolkit.

## Why This Exists

AI coding agents are powerful but undisciplined. They plan when they should build, push broken code, dismiss visual bugs, apply changes to the wrong project, and over-engineer simple features. These are not edge cases. They are the default behavior, measured across 3,307 commits over 5 months. Squire exists because the gap between what agents can do and what they actually do is a behavioral problem, not a capability problem. The fix is not better models. The fix is better instructions.

Eddie's unique insight: the corrections that make agents reliable are the same patterns that make human engineering teams reliable. Scope discipline, preflight checks, incremental verification, visual output confirmation. The difference is that agents can be reprogrammed with a file drop.

## Pillars

### 1. **Behavioral Ruleset (squire.md)** -- REALIZED

The flagship artifact. Nine behavioral rules derived from analyzing 3,307 commits across 5 months. Each rule addresses a specific, recurring failure pattern where AI agents waste time or introduce bugs. Drop it into any project root or global config and agent behavior changes immediately.

### 2. **Slash Commands** -- REALIZED

63 Claude Code commands covering the full development lifecycle: shipping (/ship), deployment (/deploy), research (/research), visualization (/visualize), planning (/blueprint), testing (/test), content publishing (/publish), and operations (/morning, /status). Each command is a detailed prompt file that instructs agents to use their built-in tools systematically.

### 3. **Skills Library** -- REALIZED

328 specialized skills organized across 17 domains: frontend, backend, architecture, DevOps, AI/ML, SEO, CRO, content, marketing, financial, startup, operations, product management, design, UX, writing, and communication. Each skill provides domain expertise that agents lack by default.

### 4. **Custom Agents** -- REALIZED

34 agents with tool access for architecture, security, DevOps, payment processing, database migrations, MCP servers, social media, market intelligence, and more. These are executable specialists, not static prompts.

### 5. **Stage-Gate Pipeline** -- REALIZED

11-stage build system from Concept Lock to Listen & Iterate. Each stage has a gate question that must be answered before advancing, plus agent-native additions for AI-assisted development. The pipeline enforces discipline without slowing momentum.

### 6. **Community & Distribution** -- PARTIAL (30%)

Published on GitHub with an MIT license, interactive installer, and comprehensive README. Community engagement remains limited: no Discord, no contributor guidelines, no external adoption metrics beyond GitHub stars.

## User Truth

**Who:** Developers using AI coding agents (Claude Code, Cursor, Copilot) who feel like they are fighting their tools as much as using them.

**Before:** "I spent 40 minutes watching the agent plan instead of build. Then it pushed code that broke prod. Then it told me the CSS was fine when it clearly was not. I know this thing is powerful but I cannot trust it."

**After:** "I dropped one file into my project and the agent stopped doing the three things that drove me crazy. The slash commands turned my most common workflows into one-liners. It feels like the agent finally knows how to work."

## Phased Vision

### Phase 1 -- Core Toolkit (COMPLETE)

Ship the behavioral ruleset, slash commands, skills, agents, and pipeline as a coherent, installable collection. Prove that file-based behavioral correction works across real projects.

### Phase 2 -- Distribution (CURRENT)

Get Squire into the hands of developers who need it. GitHub publication, interactive installer, README that sells the value proposition, Reddit/HN/community posts. Measure adoption through stars, forks, and installer runs.

### Phase 3 -- Community

Build feedback loops. Contributor guidelines, issue templates, community-submitted skills and commands. Let the toolkit evolve beyond one person's patterns.

## Edges

- Does not execute code itself: it instructs agents to use their existing tools
- macOS-centric for some shell scripts (bash 3.2+ minimum)
- Assumes Claude Code as primary agent surface, though patterns apply broadly
- Skills are prompt-based, not validated against specific model capabilities
- No automated testing of prompt quality or behavioral compliance

## Anti-Vision

- Never require a build step, a server, or a subscription. Squire is files. If it ever needs infrastructure to function, something has gone wrong.
- Never lock users in. No accounts, no telemetry, no proprietary formats. Every file is readable markdown or shell.
- Never become a framework. Squire has no runtime, no API, no dependencies to manage. It is a collection of instructions, not software.
- Never chase model-specific tricks. The behavioral rules work because they address human-universal failure patterns, not model quirks.

## Design Principles

- **Files over infrastructure.** Every component is a file you can read, copy, or delete. No databases, no services, no build artifacts.
- **Derived from data, not theory.** Every rule traces back to a measured failure pattern. No speculative best practices.
- **Drop-in, not lock-in.** Works by copying files into a directory. Works alongside any existing setup. Removable by deleting the files.
- **Behavioral correction over capability extension.** Squire does not give agents new abilities. It stops agents from misusing the abilities they already have.
- **Cherry-pickable.** Use the whole toolkit or just the one file you need. No interdependencies between components.

## Evolution Log

| Date | What Shifted | Signal | Section |
|------|-------------|--------|---------|
| 2026-03-18 | Initial VISION written | Squire published to GitHub, all components complete | All |
| 2026-03-20 | Upgraded to v2 format | Triad template standardization across portfolio | Format |

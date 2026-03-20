# BUILDING.md — Squire

> How the most complete Claude Code toolkit was built, one friction pattern at a time.

Last updated: 2026-03-20

---

## Origin (Oct 2025 - Jan 2026)

Squire did not start as a toolkit. It started as a single file -- `CLAUDE.md` -- in Eddie Belaval's global config. Every time an AI agent wasted a session (planning instead of building, pushing broken code, dismissing visual bugs), the fix was written down as a rule. After 161 sessions across 8 days in February 2026, the first formal analysis identified 56 wrong-approach incidents, 35 buggy-code incidents, and 15+ plan-then-stall sessions. Those patterns became the 9 behavioral rules.

## The 9 Rules

The behavioral ruleset emerged from data, not theory. Each rule addresses a specific, measured failure mode:

1. Default to implementation (agent plans endlessly)
2. Plan means plan (user asks for plan, gets audit)
3. Preflight before push (broken code pushed without checks)
4. Investigate bugs directly (errors dismissed as "stale cache")
5. Scope changes to target (one-project change applied globally)
6. Verify after each edit (batch edits create cascading errors)
7. Visual output verification (agent re-reads CSS instead of checking rendered output)
8. Check your environment (CLI runs against wrong project)
9. Don't over-engineer (simple feature gets unnecessary abstractions)

## Slash Commands (Jan - Mar 2026)

Commands were extracted from repeated prompt patterns. `/ship` came from the 20+ times Eddie typed the same deploy sequence. `/visualize` came from wanting consistent HTML architecture diagrams. Each command crystallized a workflow that was being done manually into a reusable prompt file.

Key commands by emergence order:
- `/visualize` and `/blueprint` -- the first two, originally in their own repo (claude-code-visualize)
- `/ship` -- full delivery pipeline: preflight, commit, push, PR, merge
- `/research` -- research orchestrator with queue and compound operations
- `/morning` -- daily standup brief across all active projects
- `/reconcile` -- Triad document maintenance with drift detection

## Skills Library (Feb - Mar 2026)

328 skills across 17 domains. Built by identifying every type of specialized work done across 12+ products and encoding domain expertise into prompt files. The skills cover engineering (frontend, backend, architecture, DevOps), business (marketing, finance, startup, operations), and creative (content, design, UX, writing) domains.

## The Triad (Mar 2026)

A three-document system replacing PRDs: VISION.md (future), SPEC.md (present), BUILDING.md (past). The gap between VISION and SPEC IS the roadmap. Any two documents can reconstruct the third. Self-correcting -- when one drifts, the others expose it. Self-installing via `BUILDING-SETUP.md`.

## Pipeline (Feb - Mar 2026)

The 11-stage build system was derived from shipping 12+ products through the same sequence. Each stage has a gate question, agent-native additions, and branch hygiene rules. The pipeline enforces discipline without requiring a project management tool.

## The Numbers

| Metric | Count |
|--------|-------|
| Sessions analyzed | 2,990 |
| Commits analyzed | 3,307 |
| Products shipped using these patterns | 12+ |
| Duration | 5 months (Oct 2025 - Mar 2026) |
| Skills built | 328 |
| Slash commands | 63 |
| Custom agents | 34 |

## Community Infrastructure (Mar 2026)

The Community & Distribution pillar was at 30% -- GitHub publication, MIT license, installer, and README were done, but nothing existed to help external contributors participate. This heal session added:

- **CONTRIBUTING.md** -- What we accept (skills, commands, agents, rules, bug fixes, docs), what we do not accept (runtime dependencies, model-specific tricks, server requirements), how to contribute (issue first, fork and branch, follow patterns, test, PR), and contribution standards (grounded in usage, no over-engineering, bash 3.2+ compatibility).
- **Issue templates** -- Bug report, feature request, and skill submission templates in `.github/ISSUE_TEMPLATE/`. Each template captures the information needed for triage without requiring back-and-forth.
- **PR template** -- `.github/PULL_REQUEST_TEMPLATE.md` with summary, related issue, type of change, testing description, and checklist.
- **Triad updates** -- SPEC.md gained a Community Infrastructure capability section (section 10) and verification checks. VISION.md pillar 6 advanced from 30% to 55%.

Remaining gaps for full realization: Discord or community forum, external adoption metrics beyond GitHub stars, formal governance body.

## Migration from claude-code-visualize

The `/visualize` and `/blueprint` commands originally lived in their own repo (claude-code-visualize, published as claude-code-artifacts). When Squire formed as the unified toolkit, both commands migrated here. The original repo now redirects to Squire.

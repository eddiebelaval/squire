I open-sourced the behavioral ruleset and toolkit I built after 3,667 commits with Claude Code -- 56 slash commands, 318 skills, 23 agents, and 9 rules that actually change how the agent behaves

---

After 5 months and 1,075 sessions shipping 12 products with Claude Code, I kept hitting the same failures: Claude planning endlessly instead of building, pushing broken code without checking, dismissing bugs as "stale cache," over-engineering simple features. Every time something went wrong, I documented the fix. Those fixes became rules. The rules became a system. The system became **Squire**.

I keep seeing repos with hundreds of stars sharing prompt collections that are less complete than what I've been using daily. So I packaged it up.

**Repo:** https://github.com/eddiebelaval/squire

---

**What it actually is:**

Squire is not a product. It's a collection of files you drop into your project root or `~/.claude/` that change how Claude Code behaves. The core is a single file (`squire.md`) -- but the full toolkit includes:

- **9 behavioral rules** -- each one addresses a specific, documented failure pattern (e.g., "verify after each file edit" prevents the cascading type error problem where Claude edits 6 files then discovers they're all broken)
- **56 slash commands** -- `/ship` (full delivery pipeline), `/fix` (systematic debugging), `/visualize` (interactive HTML architecture diagrams), `/blueprint` (persistent build plans), `/deploy`, `/research`, `/reconcile`, and more
- **318 specialized skills** across 18 domains (engineering, marketing, finance, AI/ML, design, ops)
- **23 custom agents** with tool access -- not static prompts, these spawn subagents and use tools
- **11-stage build pipeline** with gate questions at each stage
- **6 thinking frameworks** (code review, debugging, security audit, performance, testing, ship readiness)
- **The Triad** -- a 3-document system (VISION.md / SPEC.md / BUILDING.md) that replaces dead PRDs. Any two documents reconstruct the third. The gap between VISION and SPEC IS your roadmap.
- **Director/Builder pattern** for multi-model orchestration (reasoning model plans, code model executes, 2-failure threshold before the director takes over)

---

**Try it in 10 seconds:**

Just the behavioral rules (one file, zero install):

    curl -fsSL https://raw.githubusercontent.com/eddiebelaval/squire/main/squire.md > squire.md

Drop that in your project root. Claude Code reads it automatically. That alone fixes the most common failure modes.

Full toolkit:

    git clone https://github.com/eddiebelaval/squire.git
    cd squire && ./install.sh

Modular install -- cherry-pick what you want:

    ./install.sh --commands    # just slash commands
    ./install.sh --skills      # just skills
    ./install.sh --agents      # just agents
    ./install.sh --rules       # just squire.md
    ./install.sh --dry-run     # preview first

---

**The 9 rules (the part most people will care about):**

**1. Default to implementation** -- Agent plans endlessly instead of building

**2. Plan means plan** -- You ask for a plan, get an audit or exploration instead

**3. Preflight before push** -- Broken code pushed to remote without verification

**4. Investigate bugs directly** -- Agent dismisses errors as "stale cache" without looking

**5. Scope changes to the target** -- Config change for one project applied globally

**6. Verify after each edit** -- Batch edits create cascading type errors

**7. Visual output verification** -- Agent re-reads CSS instead of checking rendered output

**8. Check your environment** -- CLI command runs against wrong project/environment

**9. Don't over-engineer** -- Simple feature gets unnecessary abstractions

If you've used Claude Code for any serious project, you've probably hit every single one of these. Each rule is one paragraph. They're blunt. They work.

---

**What this is NOT:**

- Not a product, not a startup, not a paid thing. MIT license.
- Not theoretical best practices. Every rule came from a real session where something broke.
- Not a monolith. Use one file or all of it. Everything is standalone.

The numbers behind it: 1,075 sessions, 3,667 commits, 12 shipped products, Oct 2025 through Mar 2026. The behavioral rules came from a formal analysis of the top friction patterns across those sessions. The pipeline came from running 12 products through the same stage-gate system.

If it helps you build better with AI agents, that's the goal.

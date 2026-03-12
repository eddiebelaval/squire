# The Triad -- Living Product Documentation

> Three documents. Any two reconstruct the third. The gap between them IS the work.

---

## Why This Exists

PRDs die the day after you write them. Roadmaps become fiction within a week. READMEs describe what the project was six months ago.

The Triad replaces all of that with three living documents that stay in sync because they reference each other:

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

- **VISION.md** -- Where it's going. The north star. Changes rarely.
- **SPEC.md** -- Where it is right now. The testable contract. Changes with every release.
- **BUILDING.md** -- How it got here. The build journal. Grows continuously.

**The gap between VISION and SPEC is the roadmap.** You don't need a separate roadmap document. The delta between "what we want" and "what we have" tells you exactly what to build next.

**Any two documents can reconstruct the third.** If you lose BUILDING.md, VISION + SPEC tell you what was built and why. If you lose SPEC, VISION + BUILDING tell you what currently exists. If you lose VISION, SPEC + BUILDING reveal the trajectory.

---

## How It Works

### VISION.md -- The North Star

This is the soul of the product. It answers: *What world does this create?*

Key sections:
- **Soul** -- One paragraph. Why this exists. Almost never changes. If it does, you're pivoting.
- **Pillars** -- Core commitments marked REALIZED / PARTIAL / UNREALIZED. This is where you see progress.
- **User Truth** -- Psychographics, not demographics. How users feel before and after.
- **Edges** -- What this product does NOT do. Protects against scope creep.
- **Anti-Vision** -- What this product must NEVER become. The immune system.
- **Evolution Log** -- When the vision shifts and what signal triggered it.

**Template:** [`vision.md`](vision.md)

### SPEC.md -- The Contract

This is the product RIGHT NOW. Present tense only. Not what it was. Not what it will be.

Key sections:
- **Identity** -- What the product IS in 2-3 sentences. Gets rewritten (not appended) when it changes.
- **Capabilities** -- What users can do TODAY. Each one is testable.
- **Architecture Contract** -- Stack, data model, integrations. The technical truth.
- **Boundaries** -- What the product does NOT do right now. Factual, not aspirational.
- **Verification Surface** -- Testable assertions. If any fail, the spec is stale.
- **Drift Log** -- When the spec changed, why, and whether VISION needed updating too.

**Template:** [`spec.md`](spec.md)

### BUILDING.md -- The Journal

This is the autobiography of the project. It captures not just what was built, but who was building it and how they felt along the way.

Key features:
- **Self-installing** -- Drop `BUILDING-SETUP.md` into any project root. It runs an interview, explores your codebase, and generates a personalized BUILDING.md. Then it deletes itself.
- **Auto-updating** -- Claude updates the journal automatically after significant work. No manual maintenance.
- **Check-in system** -- Every 5 auto-updates, it pauses and asks three questions: How's it going? What's next? What have you learned? These are the entries you value most later.
- **Origin story** -- The setup wizard interviews you about how the project started. Every biography needs a first chapter.

**Setup file:** [`../BUILDING-SETUP.md`](../BUILDING-SETUP.md)

---

## The Properties

### 1. Self-Correcting

Each document references the others. When one drifts, the others expose it:
- SPEC says "supports real-time" but VISION never mentioned it? Either VISION needs updating or the feature is scope creep.
- BUILDING shows you built auth three times? SPEC's auth section probably needs rewriting.
- VISION says "AI-first" but SPEC shows zero AI features? That's your roadmap priority.

### 2. Drift Detection

SPEC.md tracks its own drift status: `CURRENT | DRIFTED | STALE`. The Verification Surface provides testable assertions -- if any fail, the spec is stale and needs reconciliation.

### 3. Gap-as-Roadmap

The distance between VISION and SPEC is measured explicitly:

```
Distance from SPEC: 40% (2 of 5 pillars realized)
```

That percentage IS your roadmap. The unrealized pillars are what you build next. No separate roadmap document. No Gantt charts. Just the delta between where you want to be and where you are.

### 4. Conversational Maintenance

Use `/reconcile` to maintain the Triad. It doesn't hand you a form to fill in -- it interviews you:
- Detects drift between documents
- Asks what changed and why
- Updates all three documents to stay in sync
- Flags contradictions

---

## Getting Started

### Option 1: Full Triad (recommended)

```bash
# Copy templates to your project root
cp squire/templates/vision.md ./VISION.md
cp squire/templates/spec.md ./SPEC.md
cp squire/BUILDING-SETUP.md ./BUILDING-SETUP.md

# Then tell Claude: "Read BUILDING-SETUP.md and follow the instructions"
# It will set up BUILDING.md interactively, then delete the setup file
```

### Option 2: Just the build journal

```bash
cp squire/BUILDING-SETUP.md ./BUILDING-SETUP.md
# Tell Claude: "Read BUILDING-SETUP.md and follow the instructions"
```

### Option 3: Initialize conversationally

```
/reconcile init
```

This runs the full Triad setup as a conversation -- no copying templates, no filling in brackets. It interviews you and writes everything.

---

## Maintenance Cadence

| When | What |
|------|------|
| Every significant feature | BUILDING.md auto-updates (automatic) |
| Every 5 auto-updates | Check-in interview triggers (automatic) |
| Before every PR to main | Run `/reconcile` to sync all three docs |
| After a pivot or major decision | Update VISION.md pillars + Evolution Log |
| When something feels off | Check SPEC.md drift status and Verification Surface |

---

## Origin

The Triad was developed during the Parallax build at id8Labs (March 2026). The insight: PRDs die because they describe a fixed future, but products are alive. The three-document system works because it mirrors how building actually happens -- you have a direction (VISION), a current state (SPEC), and a history (BUILDING). The tension between them IS the work.

The phrase "any two reconstruct the third" came from realizing that if you ever lost a document, the other two contained enough information to regenerate it. That property means the system is self-healing -- no single point of documentation failure.

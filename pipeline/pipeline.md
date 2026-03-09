# Squire Pipeline -- Stage-Gate Build System

A stage-gate pipeline for building software with AI agents. Every stage has a clear entry, a clear exit, and a gate question that must be answered before advancing.

---

## Philosophy

Structure creates momentum. Every stage has a clear exit. The documentation isn't bureaucracy -- it's breadcrumbs for when you get lost.

The goal: make building repeatable, teachable, and finishable.

---

## The 11 Stages

### Stage 1: Concept Lock

**Gate:** One sentence defines the problem and who it's for.

**Checkpoint:** "What's the one-liner?"

### Stage 2: Scope Fence

**Gate:** V1 boundaries are explicit. Max 5 core features. "Not yet" list defined.

**Checkpoint:** "What are we NOT building?"

**Agent-Native Addition:**
- [ ] Identify which features will have agent capabilities
- [ ] For agent features, define: What outcomes should agents achieve?

### Stage 3: Architecture Sketch

**Gate:** Stack chosen, components mapped, data flow clear. All user flows identified and mapped.

**Checkpoint:** "Draw me the boxes and arrows." + "Are all user flows identified and mapped?"

**Agent-Native Addition:**
- [ ] Design tool architecture (atomic primitives, not bundled)
- [ ] Define entity list for CRUD audit
- [ ] Choose file vs. database for agent-generated content

### Stage 4: Foundation Pour

**Gate:** Scaffolding, database, auth, deployment pipeline all running.

**Checkpoint:** "Can we deploy an empty shell?"

### Stage 5: Feature Blocks

**Gate:** Build vertical slices. One complete feature at a time. No half-builds.

**Checkpoint:** "Does this feature work completely, right now?"

**Agent-Native Addition (per feature):**
- [ ] CRUD Complete: Can agent Create, Read, Update, Delete this entity?
- [ ] Completion Signals: Does tool return `shouldContinue`?
- [ ] Approval Flow: What stakes/reversibility? (see matrix below)

**Approval Flow Matrix:**

| Stakes | Reversibility | Pattern | Example |
|--------|--------------|---------|---------|
| Low | Easy | Auto-apply | Organize files |
| Low | Hard | Quick confirm | Publish to feed |
| High | Easy | Suggest + apply | Code changes |
| High | Hard | Explicit approval | Send email, delete |

### Stage 6: Integration Pass

**Gate:** All blocks connected. Data flows between components.

**Checkpoint:** "Do all the pieces talk to each other?"

**Agent-Native Addition:**
- [ ] Agent-to-UI events standardized
- [ ] Tools can compose (agent can combine primitives for new outcomes)
- [ ] No silent agent actions -- all visible in UI

### Stage 7: Test Coverage

**Gate:** Full test pyramid implemented and passing. No skipped tests. Coverage thresholds met.

**Checkpoint:** "Are all tests green and is coverage sufficient?"

**Required test types:**

| Test Type | Purpose | When Written |
|-----------|---------|--------------|
| Unit Tests | Individual functions/components | During Stage 5 |
| Integration Tests | Components work together, API contracts | During Stage 6 |
| E2E Tests | Full user flows in browser | Before exiting Stage 7 |

**Agent-Native Addition:**
- [ ] Parity tests: For each UI action, test agent can achieve same outcome
- [ ] CRUD tests: Every entity has Create/Read/Update/Delete agent tests
- [ ] Completion signal tests: Verify tools return proper signals

### Stage 8: Polish & Harden

**Gate:** Error handling, loading states, empty states, edge cases covered.

**Checkpoint:** "What breaks if I do something stupid?"

### Stage 9: Launch Prep

**Gate:** Docs, marketing, onboarding, analytics in place.

**Checkpoint:** "Could a stranger use this without asking me questions?"

### Stage 10: Ship

**Gate:** Production deploy. Real users.

**Checkpoint:** "Is it live and are people using it?"

### Stage 11: Listen & Iterate

**Gate:** Feedback loop active.

**Checkpoint:** "What did we learn?"

**Agent-Native Addition (Latent Demand Discovery):**
- [ ] Log agent requests that succeed (what's working)
- [ ] Log agent requests that fail (reveals capability gaps)
- [ ] Pattern emerging? -> Add domain tool or prompt
- [ ] Pattern failing? -> Add missing primitive

---

## Enforcement

### Hard Stops

- Do NOT proceed to next stage without explicit sign-off
- Ask the checkpoint question before advancing
- Wait for user confirmation

### Override Protocol

User can skip/combine stages by stating a reason. Log override in PIPELINE_STATUS.md.

### Status Tracking

Every project using the pipeline should have a `PIPELINE_STATUS.md` in the repo root. Update it when:
- Entering a new stage
- Completing a checkpoint
- Using an override
- Making key decisions

### On New Project

1. Create PIPELINE_STATUS.md
2. Create BUILDING.md with pipeline explanation
3. Start at Stage 1
4. Do not write code until Stage 4 (Foundation Pour)

### On Existing Project

1. Check PIPELINE_STATUS.md for current stage
2. If no status file exists, assess and create one
3. Resume from current stage with full rigor

---

## Git Branch Hygiene

### Branch Naming Convention

```
{project}/stage-{N}-{stage-name}
```

Examples:
- `myapp/stage-4-foundation`
- `myapp/stage-5-auth-feature`

### Stage Transition Protocol

**Before starting ANY stage work:**
1. Ensure you're on `main` with latest changes
2. Create the stage branch
3. Log branch creation in PIPELINE_STATUS.md

**Before advancing to next stage:**
1. Verify: All stage work is complete and tested
2. Merge: Create PR and merge to `main`
3. Cleanup: Delete the feature branch (local AND remote)
4. Confirm: No stale branches remain
5. Create: New branch for next stage

### Forbidden Patterns

- Leave merged branches lying around
- Accumulate 5+ feature branches without cleanup
- Work directly on `main` for anything beyond hotfixes
- Forget to delete remote branches after merge

---

## Commands

When the user says:
- "pipeline status" -> Report current stage and next checkpoint
- "checkpoint cleared" -> Advance to next stage
- "skip to [stage]" -> Require reason, log override, proceed
- "parity check" -> Audit agent capability completeness
- "crud audit" -> Check all entities have full CRUD agent access

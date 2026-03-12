# /blueprint - Interactive Build Plan Generator

Generate a persistent, interactive HTML build plan that serves as the master blueprint for an entire project or feature. Unlike session plans that die when context fills up, blueprints are HTML artifacts that live on disk, track progress with checkboxes, batch parallel work, and include copy-paste prompts for every phase.

**This is the GPS, not the rearview mirror.** `/visualize` explains what exists. `/blueprint` plans what to build.

## Arguments
- **[project-or-feature]**: What to blueprint (can be rough — you'll interview for details)
- Flags: `--update` (update existing blueprint instead of creating new), `--from-plan <file>` (seed from an existing plan file)

## Instructions

### Phase 1: Conversational Intake (Structured Interview)

This is a multi-round structured interview. Use AskUserQuestion aggressively to nail down specifics. Eddie often speaks by voice — capture the essence, then confirm with structured questions. **Do NOT skip to HTML generation until every round is complete.**

**IMPORTANT:** Actually explore the codebase between questions. Read files, check the database schema, look at existing patterns. The blueprint should be grounded in reality, not assumptions. Use what you find to inform better questions.

#### Round 1: Scope & Vision
Use AskUserQuestion to establish:
- **What are we building?** (options: New project from scratch / New feature in existing project / Rebuild or major refactor / Multi-project integration)
- **What's the scale?** (options: Single feature (1-2 days) / Feature set (3-5 days) / Full product build (1-2 weeks) / Major platform (2+ weeks))
- **Who's the audience?** Free-form conversation about users, clients, stakeholders.

Then explore the codebase — read existing files, understand what's already there.

#### Round 2: Architecture Decisions
Use AskUserQuestion for every significant technical choice:
- **Tech stack decisions** — Framework, database, hosting, APIs (present 2-4 options with trade-offs)
- **Data model** — What entities exist? What's the schema? (present options if multiple valid approaches)
- **Integration points** — What external services, APIs, or systems does this touch?
- **Auth/security model** — How is access controlled?

Present what you found in the codebase exploration: "I see you're already using X for Y — should we extend that pattern or go a different direction?"

#### Round 3: Phase Breakdown
Present a PROPOSED phase breakdown and get confirmation:
- List each phase with a 1-line description
- Use AskUserQuestion: "Does this phase order make sense?" with options to reorder, split, or merge phases
- For each phase, ask: "What's the definition of done for this phase?"
- Identify the **critical path** — which phases block everything else?

#### Round 4: Parallel Opportunities
For each phase, use AskUserQuestion to identify parallelism:
- "These tasks in Phase 2 look independent — can they run in parallel?" (Yes / No, Task X depends on Task Y / Let me explain the dependency)
- "How many agents/sessions can work simultaneously?" (options: 1 (solo) / 2-3 (small team) / 4-5 (full swarm) / As many as possible)
- "Do you want batch prompts for team distribution?" (Yes, I'll distribute to agents / Yes, I'll work through them sequentially / Just individual task prompts)

#### Round 5: Risks & Priorities
Use AskUserQuestion:
- "What's the riskiest part of this build?" (present options based on what you've seen)
- "If we had to cut scope, what's essential vs nice-to-have?" (multiSelect for must-haves)
- "Any hard deadlines or external dependencies?" Free-form.

#### Round 6: Confirmation
Present a SUMMARY of everything captured:
- Project name, scope, scale
- Tech stack choices
- Phase breakdown with parallel batches marked
- Critical path highlighted
- Risks identified

Use AskUserQuestion: "Ready to generate the blueprint?" (options: Yes, generate it / I want to adjust phases / I want to change the architecture / Let me add more context)

**Only proceed to Phase 2 (HTML generation) after Round 6 confirmation.**

### Phase 2: Generate the Blueprint HTML

Create a self-contained HTML file following the Factory-Inspired design system (same as `/visualize`).

#### Embedded Data Model (MANDATORY)

Every blueprint MUST embed its structured data as a JSON block. This is the **single source of truth** —
the HTML renders FROM this data, and `--update` reads it back without parsing HTML.

```html
<!-- Place just before closing </body> tag -->
<script type="application/json" id="blueprint-data">
{
  "project": "pause-sync",
  "title": "Pause Sync Build Plan",
  "generated": "2026-02-10T03:00:00Z",
  "scale": "feature-set",
  "stack": ["Next.js 16", "Supabase", "Claude Sonnet", "Deepgram"],
  "phases": [
    {
      "id": "p1",
      "name": "Core Setup",
      "status": "not_started",
      "deps": [],
      "sequential": [
        { "id": "p1-t1", "title": "Create split-screen layout", "done": false }
      ],
      "batches": []
    },
    {
      "id": "p2",
      "name": "Audio Pipeline",
      "status": "not_started",
      "deps": ["p1"],
      "sequential": [],
      "batches": [
        {
          "id": "p2-ba",
          "label": "Batch A",
          "tasks": [
            { "id": "p2-t1", "title": "Mic capture component", "done": false },
            { "id": "p2-t2", "title": "Audio level indicator", "done": false }
          ]
        },
        {
          "id": "p2-bb",
          "label": "Batch B",
          "tasks": [
            { "id": "p2-t3", "title": "Deepgram WebSocket client", "done": false }
          ]
        }
      ]
    }
  ],
  "assessment": {
    "strengths": ["..."],
    "risks": [{ "id": "risk-1", "title": "...", "severity": "HIGH" }],
    "optimizations": [{ "id": "opt-1", "title": "...", "impact": "..." }]
  }
}
</script>
```

**Rules:**
- The JSON drives everything: progress bars, phase status badges, Parallel Map SVG, and checkbox state
- On page load, read both `blueprint-data` JSON and localStorage (checkbox state) — merge them
- When Claude reads a blueprint back (for `--update`), parse THIS JSON, not the HTML
- `phases[].deps` array enables the auto-layout algorithm in the Parallel Map tab
- Each task `id` must match the `data-key` on its corresponding checkbox for localStorage sync

The blueprint has these mandatory tabs:

---

#### Tab 1: OVERVIEW

Project summary at a glance:
- **Project name and one-line description**
- **Progress bar** — Visual percentage complete (updates automatically from checkbox state)
- **Phase count** — X of Y phases complete
- **Task count** — X of Y tasks complete
- **Parallel efficiency score** — How much of the work can be parallelized (percentage)
- **Tech stack badges** — What we're building with
- **Key dates** — Start date, target milestones if any

The progress bar reads from localStorage checkbox state and updates in real time.

---

#### Tab 2: ARCHITECTURE

System architecture of what we're building:
- **Component diagram** — Boxes and flow arrows showing the major pieces
- **Data flow** — How data moves through the system
- **File map** — What files will be created/modified, organized by phase
- **Key decisions** — Architecture Decision Records (why we chose X over Y)

This is the reference tab — come here to remember how the pieces fit together.

---

#### Tab 3: PHASES (the core of the blueprint)

Each phase is a card containing:

```
PHASE N: [Phase Name]
[Status badge: NOT STARTED / IN PROGRESS / COMPLETE]
[Dependency line: "Requires: Phase 1, Phase 2" or "No dependencies — can start immediately"]

Description: What this phase accomplishes and why it matters.

┌─────────────────────────────────────────────────┐
│  SEQUENTIAL TASKS (must be done in order)        │
│                                                   │
│  [ ] Task 1 — Description                        │
│      [COPY PROMPT]                                │
│  [ ] Task 2 — Description (blocked by Task 1)    │
│      [COPY PROMPT]                                │
└─────────────────────────────────────────────────┘

┌──────────────────────┬──────────────────────┐
│  PARALLEL BATCH A     │  PARALLEL BATCH B     │
│  (can run together)   │  (can run together)   │
│                       │                       │
│  [ ] Task 3           │  [ ] Task 5           │
│      [COPY PROMPT]    │      [COPY PROMPT]    │
│  [ ] Task 4           │  [ ] Task 6           │
│      [COPY PROMPT]    │      [COPY PROMPT]    │
│                       │                       │
│  [BATCH PROMPT]       │  [BATCH PROMPT]       │
└──────────────────────┴──────────────────────┘

Verification:
[ ] [Verification step — what to check when phase is complete]
    [COPY PROMPT for verification command]
```

**Parallel batch layout rules:**
- Tasks with no dependencies on each other go side-by-side in columns
- Each column is a "batch" that can be assigned to one agent or session
- A **BATCH PROMPT** at the bottom of each column kicks off the entire batch in one paste
- Color code: separate batches get different accent colors (orange, teal, amber, cyan)
- Between parallel batches, show a sync point: "Wait for all batches to complete before Phase N+1"

**Checkbox behavior (localStorage persistence):**
```javascript
// Every checkbox saves state to localStorage on change
checkbox.addEventListener('change', function() {
  var state = JSON.parse(localStorage.getItem('blueprint-STATE_KEY') || '{}');
  state[this.id] = this.checked;
  localStorage.setItem('blueprint-STATE_KEY', JSON.stringify(state));
  updateProgress();
  if (this.checked) {
    this.closest('.task-item').classList.add('completed');
  } else {
    this.closest('.task-item').classList.remove('completed');
  }
});

// On page load, restore checkbox state
window.addEventListener('load', function() {
  var state = JSON.parse(localStorage.getItem('blueprint-STATE_KEY') || '{}');
  Object.keys(state).forEach(function(id) {
    var cb = document.getElementById(id);
    if (cb) {
      cb.checked = state[id];
      if (state[id]) cb.closest('.task-item').classList.add('completed');
    }
  });
  updateProgress();
});
```

**Completed task styling:**
```css
.task-item.completed .task-label {
  text-decoration: line-through;
  color: var(--text-muted);
}
.task-item.completed .prompt-block {
  opacity: 0.3;
  pointer-events: none;
}
.task-item.completed .task-status-dot {
  background: var(--teal);  /* green dot = done */
}
```

---

#### Tab 4: PARALLEL MAP

A visual dependency graph showing the entire build timeline:

```
Phase 1 ──────────────────────────┐
  Task A (sequential)              │
  Task B (sequential)              │
                                   ▼
Phase 2 ─────┬────────────────────┐
  Batch A     │  Batch B           │
  Task C      │  Task E            │
  Task D      │  Task F            │
              │                    │
  ────────────┴──── sync ─────────▼
Phase 3 ─────┬─────┬──────────────┐
  Batch A     │ B   │  Batch C     │
  Task G      │ H   │  Task I      │
              │     │  Task J      │
  ────────────┴─────┴── sync ─────▼
Phase 4 ──────────────────────────
  Task K (sequential, final)
```

Use SVG for the dependency graph with:
- Flowing dash animations on dependency lines (shows direction)
- Color-coded batches (same colors as the phase cards)
- Node sizing based on estimated complexity
- Hover to highlight all dependencies of a task

**Auto-Layout Algorithm (MANDATORY — do not manually position nodes):**

The Parallel Map SVG MUST be rendered by JavaScript from the `blueprint-data` JSON.
Claude provides the data, the browser renders the layout. This keeps diagrams consistent
and makes `--update` trivial.

```javascript
function renderParallelMap(data) {
  var phases = data.phases;
  var COL_WIDTH = 180;
  var ROW_HEIGHT = 56;
  var PHASE_GAP = 80;
  var BATCH_GAP = 20;
  var y = 40;

  phases.forEach(function(phase, pi) {
    // Phase header node
    drawPhaseNode(phase, 20, y);
    var phaseStartY = y;
    y += ROW_HEIGHT;

    // Sequential tasks: single column
    phase.sequential.forEach(function(task) {
      drawTaskNode(task, 40, y, COL_WIDTH, phase.id);
      y += ROW_HEIGHT;
    });

    // Parallel batches: side-by-side columns
    if (phase.batches.length > 0) {
      var batchStartY = y;
      var maxBatchHeight = 0;
      phase.batches.forEach(function(batch, bi) {
        var bx = 40 + bi * (COL_WIDTH + BATCH_GAP);
        var by = batchStartY;
        drawBatchLabel(batch, bx, by);
        by += 24;
        batch.tasks.forEach(function(task) {
          drawTaskNode(task, bx, by, COL_WIDTH, phase.id);
          by += ROW_HEIGHT;
        });
        maxBatchHeight = Math.max(maxBatchHeight, by - batchStartY);
      });
      y = batchStartY + maxBatchHeight;

      // Sync point line
      if (pi < phases.length - 1) {
        drawSyncPoint(y);
        y += 32;
      }
    }

    // Draw dependency edges from previous phases
    phase.deps.forEach(function(depId) {
      drawDependencyEdge(depId, phase.id);
    });

    y += PHASE_GAP;
  });

  // Set SVG viewBox to fit content
  svg.setAttribute('viewBox', '0 0 ' + calcWidth(phases) + ' ' + y);
}

// Call on page load
var data = JSON.parse(document.getElementById('blueprint-data').textContent);
renderParallelMap(data);
```

**Hover-to-Trace Dependencies (MANDATORY):**

When hovering any task node, highlight its entire dependency chain and dim everything else.
This answers "what does this task need?" and "what does it unlock?" at a glance.

```javascript
function setupHoverTrace(svg) {
  svg.querySelectorAll('.task-node').forEach(function(node) {
    node.addEventListener('mouseenter', function() {
      var taskId = this.dataset.taskId;
      var phaseId = this.dataset.phaseId;
      // Dim all nodes to 20% opacity
      svg.querySelectorAll('.task-node, .phase-node').forEach(function(n) {
        n.style.opacity = '0.2';
        n.style.transition = 'opacity 0.2s ease';
      });
      // Highlight this node
      this.style.opacity = '1';
      // Highlight upstream (amber) — walk deps backwards
      highlightUpstream(phaseId, '--amber');
      // Highlight downstream (teal) — walk deps forwards
      highlightDownstream(phaseId, '--teal');
      // Highlight dependency edges
      svg.querySelectorAll('.dep-edge[data-to="' + phaseId + '"]').forEach(function(e) {
        e.style.stroke = 'var(--amber)';
        e.style.opacity = '1';
      });
      svg.querySelectorAll('.dep-edge[data-from="' + phaseId + '"]').forEach(function(e) {
        e.style.stroke = 'var(--teal)';
        e.style.opacity = '1';
      });
    });
    node.addEventListener('mouseleave', function() {
      // Restore all nodes
      svg.querySelectorAll('.task-node, .phase-node, .dep-edge').forEach(function(n) {
        n.style.opacity = '';
        n.style.stroke = '';
      });
    });
  });
}
```

This tab answers: "What's the critical path?" and "Where can we throw more agents at it?"

---

#### Tab 5: ASSESSMENT (same as /visualize)

Senior Dev Assessment of the PLAN (not the code — the plan itself):

**1. Strengths of This Plan** (green) — What's smart about this approach
**2. Risks and Gaps** (red/amber) — What could go wrong, what's missing, what assumptions are dangerous. Each with severity + a prompt to address it.
**3. High-Impact Optimizations** (orange) — Ways to make the build faster or better
**4. Prompts Summary** (teal) — All prompts from the blueprint in one numbered list

---

### Phase 3: Save and Open

**ALWAYS save to the artifacts directory:** `~/Development/artifacts/<project>/<name>-blueprint.html`

Use the project subfolder routing (same as `/visualize`):
- Homer: `~/Development/artifacts/homer/`
- DeepStack: `~/Development/artifacts/deepstack/`
- HYDRA: `~/Development/artifacts/hydra/`
- Pause: `~/Development/artifacts/pause/`
- id8labs: `~/Development/artifacts/id8labs/`
- General: `~/Development/artifacts/_general/`

Open automatically with `open <filepath>`.

### Phase 4: Update Flow (--update flag)

When invoked with `--update`:

1. **Read the existing blueprint HTML file**
2. **Parse the `<script id="blueprint-data">` JSON block** — this is the source of truth, NOT the HTML structure
3. **Merge updates into the JSON:**
   - Add new phases/tasks discovered from recent work
   - Preserve `done: true` on completed tasks (from the JSON, not localStorage)
   - Update phase status badges based on task completion
   - Recalculate progress percentages
4. **Re-explore the codebase** — check if files mentioned in prompts have changed, verify assumptions still hold
5. **Regenerate the full HTML** from the updated JSON, including:
   - Updated Parallel Map SVG (auto-layout recalculates from new data)
   - Refreshed Assessment tab based on current codebase state
   - All existing prompts preserved unless the underlying task changed
6. **Write the updated JSON back** into the new HTML's `<script id="blueprint-data">` block

**The JSON is the contract.** Old HTML with the same JSON produces the same blueprint.
Changed JSON produces an updated blueprint. This makes updates deterministic.

---

## Prompt Writing Rules (Critical)

Every prompt in the blueprint must be:

1. **Self-contained** — Include full project path, file references, and context. Someone pasting this prompt into a fresh Claude Code session should have everything they need.
2. **Scoped** — One task per prompt. Don't combine "create the API route AND the frontend component" into one prompt.
3. **Verifiable** — End with a verification step: "Run `npm run build` to verify" or "Test by hitting GET /api/..."
4. **Context-aware** — Reference the blueprint: "This is Phase 2, Task 3 of the [Project] blueprint. Previous phases established [X]. This task builds [Y]."
5. **Parallel-safe** — Prompts in the same parallel batch must not conflict. If Task A creates a file that Task B imports, they can't be parallel.

**Batch prompt format:**
A batch prompt is a single prompt that describes ALL tasks in a parallel batch, designed to be pasted into one Claude Code session (or distributed across agents):

```
This is Phase 2, Parallel Batch A of the [Project] blueprint.
Complete these 3 tasks (they have no dependencies on each other):

1. [Task description with file paths and specifics]
2. [Task description with file paths and specifics]
3. [Task description with file paths and specifics]

Verification: [How to verify all 3 are done correctly]
```

---

## Design System

Use the exact same Factory-Inspired design system as `/visualize`. All CSS tokens, component patterns, animation specs, and layout rules apply identically. Reference the `/visualize` command file for the full spec.

**Additional components for blueprints:**

```css
/* Progress bar */
.progress-bar {
  height: 4px;
  background: var(--border-subtle);
  border-radius: 2px;
  overflow: hidden;
  margin: 16px 0;
}
.progress-fill {
  height: 100%;
  background: var(--accent);
  border-radius: 2px;
  transition: width 0.6s ease-out;
}

/* Checkbox styling */
.task-checkbox {
  appearance: none;
  width: 16px;
  height: 16px;
  border: 1.5px solid var(--border-visible);
  border-radius: 3px;
  background: transparent;
  cursor: pointer;
  position: relative;
  flex-shrink: 0;
}
.task-checkbox:checked {
  background: var(--teal);
  border-color: var(--teal);
}
.task-checkbox:checked::after {
  content: '';
  position: absolute;
  top: 2px;
  left: 5px;
  width: 4px;
  height: 8px;
  border: solid var(--bg, #020202);
  border-width: 0 2px 2px 0;
  transform: rotate(45deg);
}

/* Parallel batch columns */
.parallel-group {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(280px, 1fr));
  gap: 16px;
  margin: 16px 0;
}
.batch-column {
  border: 1px solid var(--border-subtle);
  border-radius: 4px;
  padding: 20px;
  background: var(--base-card);
  position: relative;
}
.batch-column::before {
  content: '';
  position: absolute;
  top: 0;
  left: 0;
  right: 0;
  height: 3px;
  border-radius: 4px 4px 0 0;
}
/* Color-code each batch */
.batch-column.batch-a::before { background: var(--accent); }
.batch-column.batch-b::before { background: var(--teal); }
.batch-column.batch-c::before { background: var(--amber); }
.batch-column.batch-d::before { background: var(--cyan, #06b6d4); }

.batch-label {
  font-size: 9px;
  letter-spacing: 0.15em;
  text-transform: uppercase;
  margin-bottom: 12px;
}
.batch-column.batch-a .batch-label { color: var(--accent); }
.batch-column.batch-b .batch-label { color: var(--teal); }
.batch-column.batch-c .batch-label { color: var(--amber); }
.batch-column.batch-d .batch-label { color: var(--cyan, #06b6d4); }

/* Sync point between parallel groups */
.sync-point {
  text-align: center;
  padding: 12px 0;
  color: var(--text-muted);
  font-size: 10px;
  letter-spacing: 0.15em;
  text-transform: uppercase;
  position: relative;
}
.sync-point::before,
.sync-point::after {
  content: '';
  position: absolute;
  top: 50%;
  height: 1px;
  width: calc(50% - 80px);
  background: var(--border-subtle);
}
.sync-point::before { left: 0; }
.sync-point::after { right: 0; }

/* Phase status badges */
.phase-badge {
  font-size: 9px;
  letter-spacing: 0.1em;
  padding: 3px 10px;
  border-radius: 2px;
  font-weight: 600;
  text-transform: uppercase;
}
.phase-badge.not-started { background: rgba(90, 85, 80, 0.2); color: var(--text-muted); }
.phase-badge.in-progress { background: rgba(239, 111, 46, 0.15); color: var(--accent); }
.phase-badge.complete { background: rgba(78, 205, 196, 0.15); color: var(--teal); }

/* Dependency line */
.dependency-line {
  font-size: 11px;
  color: var(--text-secondary);
  padding: 4px 0 12px;
  border-bottom: 1px solid var(--border-subtle);
  margin-bottom: 16px;
}
.dependency-line .dep-tag {
  color: var(--amber);
}
.dependency-line .no-dep {
  color: var(--teal);
}
```

---

## Usage Examples

```
/blueprint Homer V2 — full rebuild with new dashboard
/blueprint DeepStack live trading — go from paper to real money
/blueprint Pause Sync — the hackathon build plan
/blueprint --update homer-v2  (update existing blueprint with new progress)
/blueprint --from-plan docs/PAUSE_SYNC_SPEC.md  (seed from existing spec)
```

## Notes

- Use REAL codebase data — read files, check schemas, count lines. Don't guess.
- Blueprints are living documents — update them as the build progresses.
- The localStorage persistence means progress survives browser refreshes and tab closes.
- Parallel batches should be genuinely independent — if there's any shared state, make them sequential.
- Include the project path in EVERY prompt. A fresh session has no context about where files live.
- The Parallel Map tab is the most valuable planning tool — it shows the critical path and parallelization opportunities at a glance.
- When Eddie says "what's next?" — open the blueprint, look at the first unchecked task, copy the prompt.

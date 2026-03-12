# /codebase-map - Interactive Codebase Health Visualization

Generate an interactive HTML codebase map that shows project health, architecture, protocol completion, and launch readiness. This is the standard artifact format for tracking block-level build progress across any project.

## Arguments

`/codebase-map [project-name]` — Generates a codebase map for the specified project. If no argument, infer from current working directory.

## What It Produces

A single self-contained HTML file with 6 tabs:

| Tab | Purpose |
|-----|---------|
| **Overview** | Project health dashboard — total blocks, green/yellow/planned counts, protocol completion bar, key highlights |
| **Map** | Interactive SVG architecture diagram with animated flow lines, traveling dots, hover-to-trace, completion bar (5 phases), stat counters, data flow description, database schema, file map, pre-flight launch checklist |
| **Blocks** | All blocks grouped by layer (Frontend, Backend, Database, External) with protocol dots (C/W/I/T/D) |
| **Connections** | SVG connection diagram + full connection list with flow status badges |
| **Tasks** | Auto-generated tasks grouped by priority (high/medium/low) |
| **Assessment** | Senior dev review with wins, fixes, next steps, copy-paste prompts, persistent checkboxes |

## Data Model

Every codebase map is driven by three arrays embedded in the HTML:

### BLOCKS
```javascript
{
  id: 'session',           // Unique identifier
  name: 'Session View',    // Display name
  layer: 'frontend',       // frontend | backend | database | integration
  phase: 'built',          // planned | building | built
  status: 'green',         // green (4-5/5 protocol) | yellow (2-3/5) | none (0-1/5)
  protocol: {
    created: true,          // Files exist
    wired: true,            // Connections declared (imports, API calls)
    integrated: true,       // Data flows end-to-end
    tested: true,           // Has test coverage
    documented: true        // Has docs/comments
  }
}
```

### CONNECTIONS
```javascript
{
  from: 'session',          // Source block id
  to: 'sessions-api',      // Target block id
  type: 'api',             // navigation | component | api | data | infra
  flow: 'active'           // active | wired | planned
}
```

### TASKS
```javascript
{
  title: 'Tests for Landing Page',   // Task description
  priority: 'medium',                // high | medium | low
  block: 'landing'                   // Associated block id
}
```

### LAYERS
```javascript
{
  id: 'frontend',
  label: 'Frontend',
  accent: '#4ecdc4'    // teal=frontend, orange=backend, amber=database, purple=integration
}
```

## How to Build the Data

### Step 1: Explore the Codebase

Read the project structure, CLAUDE.md, key files, and understand the architecture. Identify:
- **Blocks**: Major components, pages, API routes, database schemas, external integrations
- **Connections**: How blocks talk to each other (imports, API calls, data flow)
- **Protocol status**: For each block, check the 5 protocol steps

### Step 2: Assess Protocol Completion

For each block, check these 5 steps:

| Step | How to Verify |
|------|--------------|
| **Created** | Do the files exist? |
| **Wired** | Are imports/connections declared? Does it reference other blocks? |
| **Integrated** | Does data actually flow end-to-end through this block? |
| **Tested** | Are there .test.ts, .spec.ts, or __tests__ files? |
| **Documented** | Are there JSDoc comments, README sections, or inline docs? |

### Step 3: Compute Status

- **green**: 4-5 protocol steps completed
- **yellow**: 2-3 protocol steps completed
- **none**: 0-1 protocol steps completed

### Step 4: Generate Tasks

Auto-generate tasks for missing protocol steps:
- Missing `created` -> "File exists for [Block]" (high priority)
- Missing `integrated` -> "Data flows E2E for [Block]" (high priority)
- Missing `tested` -> "Tests for [Block]" (medium priority)
- Missing `documented` -> "Docs for [Block]" (low priority)
- Missing `wired` -> "Connected for [Block]" (medium priority)

## HTML Structure

### Design System

Uses the Factory-Inspired design system (same as /visualize):
- **Colors**: near-black #020202, near-white #eeeeee, warm grays, orange #ef6f2e, amber #f59e0b, teal #4ecdc4, purple #8b5cf6, red #c45c3c
- **Fonts**: Geist + Geist Mono, weight 400 headings, tight tracking
- **No shadows, no gradients, no glow effects**
- **Generous whitespace, 10px border-radius on cards**

### Critical CSS Classes

```
.phase-bar          — 5-segment completion bar (Created, Wired, Integrated, Tested, Documented)
.phase-seg          — Individual phase segment with fill bar and count
.preflight          — Pre-flight launch checklist container
.preflight-grid     — Grid of pass/fail checks
.pf-item            — Individual check item (pf-pass or pf-fail)
.diagram-svg        — SVG architecture diagram container
.stats-row          — Horizontal stat card row with animated counters
.block-card         — Individual block with protocol dots
.protocol-dot       — 12px square, filled = completed protocol step
.conn-item          — Connection list row with flow badge
.file-map           — Monospace file tree with colored spans (.dir, .file, .note)
.arch-section       — Content section (Data Flow, Schema, File Map)
.arch-diagram       — Monospace content block for text diagrams
```

### Map Tab Components (in order)

1. **Header** — Section dot + "SYSTEM MAP" label + "Architecture Map" heading
2. **Phase Completion Bar** — 5 segments computing from BLOCKS protocol data
3. **Animated Stat Counters** — Frontend/Backend/Data+External/Active Flows/Protocol % (animate on tab switch)
4. **SVG Architecture Diagram** — Layer boundaries, nodes with status-colored borders, animated flow lines (stroke-dasharray), traveling dots (animateMotion), hover-to-trace interactivity
5. **Legend** — Active flow / Wired / Planned / Traveling dot
6. **Data Flow** — arch-section with textual step-by-step data flow description
7. **Database Schema** — arch-section with table definitions
8. **File Map** — Colored file tree using fml() helper (no innerHTML — DOM only)
9. **Pre-Flight Checklist** — 9 pass/fail checks computed from BLOCKS/CONNECTIONS/TASKS

### SVG Map Specifics

**Layer boundaries**: Dashed rectangles with 25% opacity stroke, layer label at top-left
```javascript
[
  {l:'FRONTEND',    y:20,  h:185, c:'#4ecdc4'},
  {l:'BACKEND',     y:225, h:100, c:'#ef6f2e'},
  {l:'DATABASE / EXTERNAL', y:345, h:100, c:'#f59e0b'}
]
```

**Node rendering**: 140x40px rectangles with status-colored stroke, layer-colored 3px accent bar at top, centered monospace text

**Connection rendering**:
- Base path: muted #2e2c2b at 40% opacity (always visible)
- Active overlay: teal dashes (stroke-dasharray: 8 12) with flowDash animation
- Wired overlay: amber dashes at 40% opacity
- Traveling dots: circle r=3 with animateMotion along path, opacity fade animation (API and data connections only)
- Curved paths for vertical connections: bezier C curves through midpoint

**Hover interactivity**: mouseenter dims all nodes to 0.15 opacity, highlights hovered node at 1.0 and connected nodes at 0.8

### Pre-Flight Checks (9 total)

```javascript
[
  'All blocks created (files exist)',
  'All blocks wired (connections declared)',
  'All blocks integrated (data flows E2E)',
  'All blocks tested (test coverage)',
  'All blocks documented',
  'All connections active',
  'No planned blocks remaining',
  'All blocks at built phase',
  'Zero open tasks'
]
```

Status line at bottom: teal dot + "X/9 CHECKS PASSED" when all pass, red dot (#c45c3c) when any fail. "CLEAR FOR LAUNCH" appended when 9/9.

### Assessment Tab

Follows the standard /visualize Assessment Tab spec:
- **Wins** (teal accent): Cards listing architectural strengths
- **Fixes** (amber accent): Checkboxed items with severity badges and copy-paste prompts
- **Next Steps** (orange accent): Checkboxed items with impact descriptions and prompts
- **All Prompts** (teal accent): Numbered summary list with two-way checkbox sync
- **localStorage persistence**: Key format `visualize-assess-{project}-codebase-map`

### DOM-Only Rendering (CRITICAL)

All content is rendered via `document.createElement` and `appendChild`. **Never use innerHTML.** The `el()` helper:
```javascript
function el(tag, cls, text) {
  var e = document.createElement(tag);
  if (cls) e.className = cls;
  if (text) e.textContent = text;
  return e;
}
```

File map uses the `fml()` helper for colored spans:
```javascript
function fml(parent, indent, parts) {
  var sp = '';
  for (var i = 0; i < indent; i++) sp += '  ';
  parent.appendChild(document.createTextNode(sp));
  parts.forEach(function(pt) {
    var s = document.createElement('span');
    s.className = pt[0];
    s.textContent = pt[1];
    parent.appendChild(s);
  });
  parent.appendChild(document.createTextNode('\n'));
}
```

### Embedded Data Model

Include artifact-data JSON before closing `</body>`:
```html
<script type="application/json" id="artifact-data">
{
  "type": "visualize",
  "topic": "{project}-codebase-map",
  "project": "{project}",
  "generated": "{ISO timestamp}",
  "sections": [...],
  "assessment": { "wins": [...], "fixes": [...], "next_steps": [...] }
}
</script>
```

## Output

**Save to**: `~/Development/artifacts/{project}/codebase-map.html`

Create the project subfolder with `mkdir -p` if it doesn't exist.

Open automatically in the browser with `open <filepath>`.

## Node Position Guidelines

Plan SVG node positions on a grid:
- **viewBox**: typically `0 0 920 520` (wider for monorepos)
- **Frontend row 1**: y=45 (main pages, left to right by user flow)
- **Frontend row 2**: y=125 (sub-components, modes, UI features)
- **Backend row**: y=255 (API routes)
- **Database/External row**: y=375 (DB, external services, integrations)
- **Node width**: 140px, **height**: 40px
- **Horizontal spacing**: ~160-180px between nodes
- **Layer boundary padding**: 20px above first row, extends below last row

## Examples

```
/codebase-map homer
/codebase-map parallax
/codebase-map rune
/codebase-map          # Infers from current directory
```

## Updating an Existing Map

If a codebase-map.html already exists for the project:
1. Read the existing file
2. Parse the `artifact-data` JSON to understand previous state
3. Re-scan the codebase for changes
4. Update BLOCKS, CONNECTIONS, TASKS arrays
5. Regenerate the HTML with updated data
6. Preserve assessment checkbox state (same localStorage key)

## Notes

- Use REAL data from the codebase -- read files, check imports, verify connections
- The map should reflect actual build state, not aspirational state
- When blocks have zero protocol completion, they likely haven't been started yet
- Connection flow status should match what the code actually does (imports exist = wired, data flows = active)
- The pre-flight checklist is the project's launch gate -- all 9 checks must pass for "CLEAR FOR LAUNCH"

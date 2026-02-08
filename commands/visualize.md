# /visualize - Create Interactive Visual Explanation

Generate an interactive HTML visualization to explain a concept, system, architecture, codebase structure, or workflow visually. Some concepts are better understood spatially and interactively than through walls of text.

## Instructions

When the user invokes `/visualize [topic]`, create a single self-contained HTML file that visually explains the topic.

### Step 1: Understand the topic

Determine what needs to be visualized. This could be:
- **Architecture**: System components, data flow, service boundaries
- **Codebase map**: File structure, module relationships, import chains
- **Workflow**: Step-by-step processes, decision trees, lifecycle stages
- **Concept**: Mental models, comparisons, trade-off matrices
- **Status dashboard**: Project health, task progress, deployment state
- **Data flow**: How data moves through the system, transformations, storage

If the topic is vague, explore the codebase first to gather real data before building the visualization.

### Step 2: Design the visualization

Choose the right visual format:
- **Tabbed views** for multi-faceted topics (overview + details + cheatsheet)
- **Flow diagrams** for processes and pipelines
- **Tree views** for file structures and hierarchies
- **Side-by-side comparisons** for architecture layers or trade-offs
- **Interactive cards** that expand/collapse for progressive disclosure
- **Color coding** to group related concepts (consistent palette across views)
- **Assessment tab** (MANDATORY) — always include as the last tab. See "Senior Dev Assessment Tab" section below for full spec. This is what makes every artifact actionable.

### Step 3: Build the HTML

Requirements:
- **Single file, zero dependencies** — no CDN links, no external CSS/JS
- **Dark theme (Factory-inspired)** — near-black background, warm neutrals, surgical accent color
- **No emojis** — use color and layout for visual hierarchy instead
- **Interactive** — clickable tabs, expandable sections, hover states
- **Responsive** — works on desktop and mobile (use CSS grid with breakpoints)
- **Professional** — generous whitespace, minimal borders, no shadows, no gradients

#### Design System — "Factory-Inspired" (MANDATORY)

This is our standard design language, adapted from factory.ai. Follow it precisely.

**Color Tokens:**
```css
/* Backgrounds */
--base-primary:     #020202;   /* Page background — near-black, NOT pure black */
--base-secondary:   #101010;   /* Elevated surfaces, nav bar */
--base-card:        #1f1d1c;   /* Card backgrounds */

/* Text */
--text-primary:     #eeeeee;   /* Primary text — near-white, NOT pure white */
--text-secondary:   #a49d9a;   /* Secondary text, muted labels */
--text-muted:       #5c5855;   /* Disabled, placeholder text */

/* Borders */
--border-subtle:    #2e2c2b;   /* Default borders, dividers */
--border-visible:   #3d3a39;   /* Hover borders, active states */

/* Accent — Orange (primary) */
--accent:           #ef6f2e;   /* Primary accent — dots, badges, highlights */
--accent-hover:     #ee6018;   /* Hover state */
--accent-active:    #d15010;   /* Pressed/active state */

/* Accent — Amber (secondary) */
--amber:            #f59e0b;   /* Secondary highlights, warnings, second-tier emphasis */

/* Utility */
--teal:             #4ecdc4;   /* Rare — success states, special links */

/* Warm Neutral Scale (brownish undertone, NOT cool/blue) */
--neutral-100: #d6d3d2;
--neutral-200: #ccc9c7;
--neutral-300: #b8b3b0;
--neutral-400: #a49d9a;
--neutral-500: #8a8380;
--neutral-600: #5c5855;
--neutral-700: #4d4947;
--neutral-800: #3d3a39;
--neutral-900: #2e2c2b;
--neutral-1000: #1f1d1c;
```

**Typography:**
```css
/* Font stack — Geist with system fallbacks */
--font-sans:  'Geist', -apple-system, 'Segoe UI', system-ui, sans-serif;
--font-mono:  'Geist Mono', 'SF Mono', 'Fira Code', 'JetBrains Mono', monospace;

/* Heading style — LIGHT weight, TIGHT tracking (this is the signature) */
h1 { font-family: var(--font-sans); font-size: 48px; font-weight: 400; letter-spacing: -2px; line-height: 1.0; color: var(--text-primary); }
h2 { font-family: var(--font-sans); font-size: 36px; font-weight: 400; letter-spacing: -1.5px; line-height: 1.1; color: var(--text-primary); }
h3 { font-family: var(--font-sans); font-size: 24px; font-weight: 400; letter-spacing: -0.5px; }

/* Body text */
body { font-family: var(--font-mono); font-size: 14px; color: var(--text-primary); }

/* Labels/meta — monospace, uppercase, small */
.label { font-family: var(--font-mono); font-size: 11px; text-transform: uppercase; letter-spacing: 1.5px; color: var(--text-secondary); }
```

**Component Patterns:**
```
Section indicator:     Small orange dot (6px circle) + UPPERCASE monospace label
                       e.g., [orange dot] OVERVIEW

Tabs/nav:              Ghost-style — transparent bg, 1px border var(--border-subtle),
                       4px border-radius. Active: bg var(--accent), text #020202

Cards:                 bg var(--base-card), border 1px solid var(--border-subtle),
                       border-radius 10px, NO shadows, generous padding (28px)

Buttons:               Ghost-style — transparent bg, 1px border, 4px border-radius
                       Hover: border-color var(--border-visible)

Badges/tags:           Small rounded (10px radius), semi-transparent bg
                       e.g., bg: #ef6f2e20, color: #ef6f2e

"Learn more" links:    Inline text + arrow character (→), never button-styled

Numbered items:        "01", "02" format in monospace, color var(--text-secondary)

Code blocks:           font-family var(--font-mono), bg var(--base-secondary),
                       border 1px solid var(--border-subtle), border-radius 10px
```

**Layout Rules:**
```
Border radius:         10px (cards, code blocks), 4px (buttons, badges, tabs)
Section padding:       80px vertical, 36px horizontal
Card padding:          28px
Max-width:             1100px centered
Grid gaps:             20px standard, 32px between sections
Whitespace:            GENEROUS — let content breathe. When in doubt, add more space.
```

**Animation System (MANDATORY — adds life without distraction):**
```
Philosophy:         Every animation answers "what should I look at next?"
                    If it doesn't guide understanding, don't add it.

/* Keyframes to include */
fadeSlideUp:        opacity 0→1, translateY(16px→0) — primary entrance
fadeIn:             opacity 0→1 — subtle reveals
drawLine:           scaleY(0→1) — connection lines drawing themselves
pulseGlow:          box-shadow 0→6px→0 rgba(accent, 0.15) — section dots breathing

/* Page load sequence */
1. Section dot starts pulsing (infinite, 3s)
2. Header fades in (0.6s)
3. Title slides up (0.7s, 0.15s delay)
4. Subtitle slides up (0.7s, 0.3s delay)
5. Stats count from 0 to final number (0.6s each, 120ms stagger)
6. First view content fades in (staggered)

/* Tab switch */
- All children of new view get staggered fadeSlideUp
- Stagger timing: 30ms for file lists, 60ms for cards, 120ms for large cards
- Use: item.style.animationDelay = (baseDelay + i * stagger) + 'ms'

/* Expandable sections (flow steps, accordions) */
- Steps cascade in with 150ms stagger between each
- Connection lines draw themselves (scaleY, transform-origin: top)

/* Hover micro-interactions */
- Cards: translateY(-2px) on hover, 0.2s ease
- Borders: color shift to var(--border-visible), 0.15s
- NEVER scale > 1.02 or move > 3px — keep it subtle

/* Stat counter animation */
- requestAnimationFrame loop, ease-out cubic
- Duration: 600ms per counter
- Stagger: 120ms between each stat

/* Code pattern for staggered reveals */
function staggerReveal(container, selector, className, baseDelay, stagger) {
  container.querySelectorAll(selector).forEach((item, i) => {
    item.style.animationDelay = (baseDelay + i * stagger) + 'ms';
    void item.offsetWidth; // force reflow
    item.classList.add(className);
  });
}
```

**Flow Lines — Animated Connections (for architecture, data flow, pipelines):**

Use SVG paths to show directional flow between components. These replace static arrows
in any diagram where understanding direction/movement matters.

```
/* THREE TECHNIQUES — use based on context */

/* 1. Flowing Dashes — "data streaming" feel */
/*    Best for: data pipelines, API calls, continuous processes */
.flow-path {
  stroke: var(--accent);
  stroke-width: 2;
  fill: none;
  stroke-dasharray: 8 12;              /* 8px dash, 12px gap */
  animation: flowDash 1.5s linear infinite;
}
@keyframes flowDash {
  to { stroke-dashoffset: -40; }       /* negative = flows forward */
}

/* 2. Traveling Pulse — "packet moving" feel */
/*    Best for: single events, request/response, showing a specific journey */
/*    Uses SVG <circle> with <animateMotion> along a <path> */
<circle r="3" fill="var(--accent)">
  <animateMotion dur="2s" repeatCount="indefinite">
    <mpath href="#connectionPath"/>
  </animateMotion>
</circle>
/* Add opacity fade at start/end for polish: */
<circle r="3" fill="var(--accent)" opacity="0.8">
  <animateMotion dur="2s" repeatCount="indefinite">
    <mpath href="#connectionPath"/>
  </animateMotion>
  <animate attributeName="opacity" values="0;0.9;0.9;0" dur="2s" repeatCount="indefinite"/>
</circle>

/* 3. Glow Pulse — "heartbeat" on a connection */
/*    Best for: highlighting active/important connections */
.glow-line {
  stroke: var(--accent);
  stroke-width: 2;
  fill: none;
  filter: url(#glowFilter);
  animation: glowPulse 2s ease-in-out infinite;
}
@keyframes glowPulse {
  0%, 100% { opacity: 0.4; stroke-width: 1.5; }
  50%      { opacity: 1; stroke-width: 2.5; }
}
/* SVG glow filter (add once in <defs>): */
<filter id="glowFilter">
  <feGaussianBlur stdDeviation="3" result="blur"/>
  <feMerge>
    <feMergeNode in="blur"/>
    <feMergeNode in="SourceGraphic"/>
  </feMerge>
</filter>

/* COMBINING techniques for rich diagrams: */
/* - Base line: thin, muted (var(--border-subtle)) — always visible */
/* - Flow dashes: overlay on top — shows direction */
/* - Traveling dot: on the MOST important path — draws eye to primary flow */
/* - Glow pulse: on currently-active or highlighted connection */

/* COLOR CODING for flow lines: */
/* Orange (#ef6f2e): Primary/happy path */
/* Amber (#f59e0b): Secondary/alternative path */
/* Teal (#4ecdc4): Success/completion feedback */
/* Muted (#3d3a39): Inactive/dormant connections */

/* SVG SETUP PATTERN for connection diagrams: */
<svg class="flow-diagram" viewBox="0 0 WIDTH HEIGHT">
  <defs>
    <filter id="glow">
      <feGaussianBlur stdDeviation="2.5" result="blur"/>
      <feMerge><feMergeNode in="blur"/><feMergeNode in="SourceGraphic"/></feMerge>
    </filter>
  </defs>
  <!-- Base connection (always visible, muted) -->
  <path id="conn1" d="M50,50 C150,50 150,150 250,150" stroke="#3d3a39" stroke-width="1.5" fill="none"/>
  <!-- Flowing dashes overlay -->
  <path d="M50,50 C150,50 150,150 250,150" class="flow-path"/>
  <!-- Traveling dot (optional, for primary path) -->
  <circle r="3" fill="#ef6f2e" filter="url(#glow)">
    <animateMotion dur="2.5s" repeatCount="indefinite">
      <mpath href="#conn1"/>
    </animateMotion>
  </circle>
</svg>
```

**What NOT to do:**
- NO pure black (#000) or pure white (#fff) — always use near-black/near-white
- NO gradients on backgrounds
- NO box shadows (except the subtle pulseGlow on section dots)
- NO glow effects or glassmorphism
- NO cool/blue-toned grays — always warm (brownish) neutrals
- NO bold headings — use font-weight 400 with size and letter-spacing
- NO heavy decoration — the typography and whitespace ARE the design
- NO bouncy/spring animations — use ease or ease-out only
- NO animations longer than 0.8s — keep everything snappy
- NO animation on scroll unless it teaches something (prefer on-view-switch)

Structure pattern:
```
Section indicator (dot + label)
Header (large, light-weight heading)
Subtitle (monospace, muted)
Nav tabs (if multiple views, sticky)
Content area:
  - Stats bar (key numbers at a glance)
  - Mental model (the big picture in one visual)
  - Detail sections (expandable cards)
  - Cheatsheet (copy-paste reference)
  - SENIOR DEV ASSESSMENT tab (MANDATORY — see below)
```

#### Senior Dev Assessment Tab (MANDATORY)

**Every visualization MUST include a final tab called "Assessment"** that acts as a senior developer code review of the system being visualized. This tab makes the entire document actionable — not just educational.

The assessment tab has four sections:

**1. What We Did Right (green accent)**
Cards listing architectural wins, good patterns, smart decisions. Be specific — reference actual files and line numbers. This reinforces good habits.

**2. What Needs Fixing (red/amber accent)**
Cards listing issues, anti-patterns, missing pieces, tech debt, or risks. Each card MUST include:
- **Issue title** — clear, specific name
- **Why it matters** — 1-2 sentences on impact/risk
- **Severity badge** — CRITICAL / HIGH / MEDIUM / LOW
- **Prompt block** — A ready-to-paste Claude Code prompt to fix the issue

**3. High-Impact Next Steps (orange accent)**
Ordered list of the 3-5 highest-leverage items that would move the needle most. These are the "if you only do 3 things, do these" items. Each includes:
- **What** — the action
- **Why** — the expected impact
- **Prompt block** — ready-to-paste Claude Code prompt

**4. Prompts Summary (teal accent)**
A clean, copy-paste-friendly list of ALL prompts from the assessment, numbered and labeled. This is the "action sheet" — the user can work through them top to bottom.

**Prompt block styling:**
```css
.prompt-block {
  background: var(--base-secondary);
  border: 1px solid var(--border-subtle);
  border-left: 3px solid var(--accent);   /* orange left border = actionable */
  border-radius: 4px;
  padding: 16px;
  font-family: var(--font-mono);
  font-size: 12px;
  color: var(--text-primary);
  white-space: pre-wrap;
  position: relative;
  margin-top: 12px;
}

/* Copy button in top-right corner */
.copy-btn {
  position: absolute;
  top: 8px;
  right: 8px;
  background: var(--border-subtle);
  border: none;
  color: var(--text-secondary);
  font-family: var(--font-mono);
  font-size: 10px;
  padding: 4px 8px;
  border-radius: 2px;
  cursor: pointer;
}
.copy-btn:hover { background: var(--border-visible); color: var(--text-primary); }
.copy-btn.copied { color: var(--teal); }
```

**Prompt writing rules:**
- Write prompts as if the user is pasting them directly into Claude Code
- Include the project context ("In the project at ~/path/to/project/...")
- Reference specific files and what to change
- Keep prompts focused — one fix per prompt, not a kitchen sink
- Use imperative voice ("Add...", "Fix...", "Refactor...", "Create...")
- Include verification steps when relevant ("...then run npm run build to verify")

**Every prompt block MUST have a copy-to-clipboard button** using this pattern:
```javascript
// Add to each prompt block element
copyBtn.addEventListener('click', function() {
  var text = this.parentElement.querySelector('.prompt-text').textContent;
  navigator.clipboard.writeText(text);
  this.textContent = 'COPIED';
  var btn = this;
  setTimeout(function() { btn.textContent = 'COPY'; }, 1500);
});
```

**Example Assessment card with prompt:**
```
[MEDIUM severity badge]
Missing Input Validation on Config Fields

The PATCH endpoint validates field names against configSchema but doesn't
validate number ranges at the DB level. A direct API call could bypass
the UI's min/max constraints.

[PROMPT BLOCK]
In the project at ~/path/to/your-project/,
add server-side min/max validation to the PATCH handler in
app/api/strategies/[name]/config/route.ts. For each field in the
overrides object, check the value against the corresponding configSchema
entry's min and max. Return 400 with { error: "field_name out of range" }
if validation fails. Run npm run build to verify after changes.
[COPY button]
```

### Step 4: Save and open

**ALWAYS save to the artifacts directory:** `~/Development/artifacts/<project>/<topic>.html`

Route to the correct project subfolder:
- Each project gets its own subfolder: `~/Development/artifacts/<project-name>/`
- Cross-project or general artifacts: `~/Development/artifacts/_general/`
- Create the subfolder with `mkdir -p` if it doesn't exist

If a project folder doesn't exist yet, create it with `mkdir -p` before writing.

**NEVER save artifacts to `~/Development/scratch/` or `workspace/scratch/`.** Those are for throwaway experiments. Artifacts are keepers.

Open automatically in the browser with `open <filepath>`.

### Step 5: Iterate

After opening, ask if any section needs more detail, different layout, or additional views.

## Usage Examples

```
/visualize project architecture
/visualize how Supabase RLS works
/visualize the deployment pipeline
/visualize our microservice boundaries
/visualize difference between the auth flows
/visualize my project status across all repos
```

## Notes

- Use REAL data from the codebase when possible — read files, check git status, count lines
- The visualization should teach, not just display — add annotations, labels, and "why" context
- When Claude notices the user is confused or asking "how does X work", proactively offer to visualize
- This replaces long text explanations for complex topics — prefer visual over verbal

# /integration-audit - Full-Stack Integration Audit with Visual Report

Perform a comprehensive audit of all features, checking whether each feature is fully integrated across every layer of the stack (frontend UI, API routes, database/Supabase, state management, types). Output the results as an interactive HTML visualization using the Factory-inspired design system.

## Arguments

`/integration-audit [project-path]` where project-path is optional:
- No argument: audit the current working directory
- A directory path: audit that project specifically
- Example: `/integration-audit ~/Development/Homer`

## How This Differs From /audit

- `/audit` checks codebase **health** (security, dead code, type safety)
- `/integration-audit` checks feature **completeness** — is every feature wired end-to-end?
- Output is always an interactive HTML artifact (not a text report)

## Phase 1: Discovery (Parallel Scans)

Launch parallel Explore agents (subagent_type: Explore) to scan each layer simultaneously. Each agent returns structured findings.

### Agent 1: API Routes Scan
Scan for all API route handlers. For Next.js App Router projects:
- Glob: `**/app/api/**/route.ts`, `**/app/api/**/route.tsx`
- For each route, extract: path, HTTP methods (GET/POST/PUT/PATCH/DELETE), auth checks (presence of getUser/session/auth middleware), database calls (supabase/prisma/drizzle references), request/response types
- Also check for: server actions in `**/actions/**` or `"use server"` directives

### Agent 2: Frontend Pages & Components Scan
Scan for all pages and feature components:
- Pages: `**/app/**/page.tsx`, `**/pages/**/*.tsx`
- Components: `**/components/**/*.tsx`, `**/features/**/*.tsx`
- For each, extract: API calls (fetch, axios, useSWR, useQuery, server actions), form submissions, state store usage, route links/navigation
- Identify UI shells: components with placeholder text, TODO comments, or hardcoded mock data

### Agent 3: Database & Schema Scan
Scan for database schema and access patterns:
- Supabase: migration files, type generation files, RLS policies
- Schema files: `**/schema.ts`, `**/schema.sql`, `**/migrations/**`
- Type files: shared types/interfaces that define data models
- For each table/entity, extract: table name, columns, relationships, RLS policies, which API routes access it

### Agent 4: State Management & Shared Types Scan
Scan for client-side state and shared contracts:
- Stores: Zustand (`create(`), Redux, Context providers
- Shared types: `**/types/**`, `**/interfaces/**`, `**/schemas/**` (Zod)
- For each store/context, extract: state shape, actions, which components consume it, which API calls populate it

## Phase 2: Cross-Reference & Integration Mapping

After all agents complete, build an integration matrix by cross-referencing findings:

### For each distinct FEATURE (group related routes/components by domain):

Map the integration chain:

```
[Database Table] <--> [API Route] <--> [State/Store] <--> [UI Component] <--> [Page]
```

Score each feature's integration status:

| Status | Meaning | Color Code |
|--------|---------|------------|
| COMPLETE | All layers connected, data flows end-to-end | Teal (#4ecdc4) |
| PARTIAL | Some layers connected but gaps exist | Amber (#f59e0b) |
| FRONTEND ONLY | UI exists but no API/data backing | Orange (#ef6f2e) |
| BACKEND ONLY | API/DB exists but no frontend consumer | Orange (#ef6f2e) |
| STUB | Route or component exists but returns mock/placeholder data | Neutral (#8a8380) |
| ORPHANED | Code exists but nothing references it | Red-ish (#e74c3c) |

### Integration Gaps to Flag:
- API route exists but zero frontend callers
- Frontend component calls an API endpoint that doesn't exist
- Database table exists but no API route accesses it
- Store/state defined but never populated from API
- Types defined but not used in both frontend and backend
- Auth middleware missing on routes that access user-specific data
- Feature has UI component but no page mounts it

## Phase 3: Generate HTML Visualization

Create a single self-contained HTML file following the Factory-inspired design system (see /visualize command for full design spec). The visualization MUST include these tabs:

### Tab 1: Integration Matrix
A grid/table showing every feature vs. every layer:

```
Feature         | DB | API | Auth | Types | Store | UI | Page | Status
────────────────|────|─────|──────|───────|───────|────|──────|────────
User Auth       | Y  | Y   | Y    | Y     | Y     | Y  | Y    | COMPLETE
Amendments      | Y  | Y   | N    | P     | Y     | Y  | Y    | PARTIAL
Analytics       | N  | N   | -    | N     | N     | Y  | Y    | FRONTEND ONLY
```

- Y = fully wired, N = missing, P = partial, - = not applicable
- Color-code each cell
- Click a row to expand and see the specific files in each layer

### Tab 2: Architecture Flow
An SVG diagram showing the actual data flow between layers:
- Use the flow line animation system (flowing dashes for active connections, muted lines for broken/missing connections)
- Group components by layer (left to right: DB -> API -> State -> UI -> Page)
- Draw connections between related components
- Missing connections shown as dashed red/amber lines
- Traveling pulse dots on the primary happy paths

### Tab 3: Gap Analysis
Detailed cards for each integration gap found:
- Grouped by severity (CRITICAL: security gaps, HIGH: broken features, MEDIUM: incomplete features, LOW: cleanup)
- Each card includes: feature name, what's missing, which files need changes, effort estimate (S/M/L)
- Include a ready-to-paste Claude Code prompt for each fix

### Tab 4: Feature Detail
Expandable cards for EVERY feature discovered:
- Each card shows the complete integration chain with actual file paths
- Clicking a layer shows the relevant code snippet context
- Status badge for each feature

### Tab 5: Assessment (MANDATORY)
Standard senior dev assessment per /visualize spec:
1. What We Did Right — well-integrated features, good patterns
2. What Needs Fixing — integration gaps with severity badges and fix prompts
3. High-Impact Next Steps — top 3-5 items that would complete the most features
4. Prompts Summary — all actionable prompts in copy-paste format

### Stats Bar (top of page)
Show key numbers:
- Total features discovered
- Fully integrated (%)
- Partially integrated (count)
- Frontend-only (count)
- Backend-only (count)
- Orphaned (count)
- Total integration gaps

## Phase 4: Save and Open

Save the HTML artifact to: `~/Development/artifacts/<project-name>/integration-audit.html`

Determine project name from:
1. package.json `name` field
2. Directory name
3. Fallback to "project"

Open automatically: `open <filepath>`

## Rules

- **READ ONLY.** Do not edit, write, or create any project files. Only create the output HTML artifact.
- Use Grep, Glob, Read, and Task (Explore agents) for scanning.
- Be exhaustive — scan every relevant file, don't sample.
- Group findings by **feature domain** (auth, billing, dashboard, etc.), not by file.
- The HTML must be a single file with zero external dependencies.
- Follow the Factory-inspired design system exactly (colors, typography, animations, layout).
- Every gap MUST have a copy-paste Claude Code prompt for fixing it.
- If the project uses a monorepo, scan all relevant packages/apps.
- Include the scan timestamp in the visualization header.
- If a feature has 0 gaps, still show it in the matrix as COMPLETE (that's good news).

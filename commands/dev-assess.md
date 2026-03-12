# /dev-assess — Senior Dev Triangulated Assessment

Spawn 3 senior developer subagents in parallel, each assessing the target from a different engineering perspective. Experts are **dynamically selected** based on the target material's technical domains. Triangulate their findings into an interactive HTML artifact with convergence/divergence analysis.

## Arguments
- **$ARGUMENTS**: The target to assess (e.g., "shadow-engine", "auth-flow", "billing-system"). Can be a feature name, module, architecture, or spec document.

## Instructions

### Phase 1: Identify the Target

Determine what's being assessed. This could be:
- A feature or module in a codebase (read the relevant files)
- A spec document or set of documents (read them)
- An architecture or design (explore the codebase)
- A blueprint artifact (parse its embedded JSON)

**IMPORTANT:** Before spawning experts, YOU must read and understand the target thoroughly. Gather all relevant source material — code files, spec docs, config, tests, migrations. The experts need this context injected into their prompts.

### Phase 2: Gather Context

1. Read all relevant files for the target
2. Identify the project and directory (e.g., `~/Development/id8/products/parallax`)
3. Build a context summary that includes:
   - What the target does / is supposed to do
   - Key files and their locations
   - Architecture decisions made
   - Dependencies and integrations
   - Any spec documents or design docs

### Phase 3: Dynamic Expert Selection

**Do NOT default to the same 3 experts every time.** After gathering context, analyze the target material to select the 3 most relevant engineering expert perspectives.

**Selection Process:**
1. Identify the top 3-5 technical domains the target material touches (e.g., API design, database schema, AI/ML pipeline, frontend UX, security/encryption, real-time systems, deployment/infra, performance, testing strategy, billing/payments, data compliance)
2. From the expert pool below, select 3 experts that:
   - **Maximize coverage** of the identified domains
   - Each brings at least one **unique analytical framework or methodology** not shared by the others
   - Have **meaningful pairwise overlap** (triangulation requires shared ground to find convergence/divergence)
   - Together cover the **full risk surface** of the material
3. For each selected expert, generate a custom profile:
   - Full role description and expertise
   - Frameworks and methodologies in their scope (specific to this assessment)
   - Focus areas tailored to this target
   - Overlap zones with the other 2 selected experts
   - 3-4 key questions they would ask about this specific material

**Engineering Expert Pool (select 3, or compose novel expert profiles when the material demands it):**

| Expert | Core Domain | Key Frameworks/Methodologies |
|--------|-------------|------------------------------|
| Systems Architect | Scalability, infrastructure, failure modes, distributed systems | CAP theorem, CQRS/Event Sourcing, circuit breakers, chaos engineering |
| Product Engineer | UX, feature completeness, edge cases, API ergonomics, DX | Jobs-to-be-done, user story mapping, heuristic evaluation, dogfooding |
| AI/ML Engineer | Prompts, models, token efficiency, hallucination, safety | Prompt engineering patterns, eval frameworks, red-teaming, RAG architecture |
| Security Engineer | Authentication, encryption, vulnerability assessment, threat modeling | OWASP Top 10, STRIDE, zero-trust architecture, key management (HKDF, AES-GCM) |
| Data Engineer | Data pipelines, storage, ETL, compliance (GDPR, CCPA) | Data mesh, change data capture, schema evolution, data lineage |
| Frontend Engineer | UI/UX, rendering performance, accessibility, responsive design | Core Web Vitals, WCAG 2.1, component architecture, state management patterns |
| DevOps Engineer | Deployment, monitoring, CI/CD, observability | SLOs/SLIs, GitOps, container orchestration, incident response runbooks |
| Database Architect | Schema design, query optimization, migrations, replication | Normalization theory, index strategies, connection pooling, RLS patterns |
| API Designer | Contract design, versioning, ergonomics, documentation | REST maturity model, GraphQL schema design, OpenAPI, rate limiting patterns |
| Performance Engineer | Optimization, profiling, benchmarking, load testing | Flame graphs, P99 latency analysis, connection pooling, caching strategies |
| Test Engineer | Testing strategy, coverage, automation, CI integration | Testing pyramid, property-based testing, mutation testing, contract testing |
| Platform Architect | Multi-tenancy, SaaS patterns, billing integration, feature flags | Tenant isolation models, usage metering, feature gate patterns, migration strategies |
| Real-Time Systems Engineer | WebSockets, SSE, Realtime subscriptions, eventual consistency | Conflict resolution (CRDTs), pub/sub patterns, presence, optimistic updates |
| Mobile Engineer | Native/hybrid apps, offline-first, push notifications, app store compliance | Expo/React Native patterns, deep linking, background sync, app review guidelines |

**Composition Rules:**
- Always exactly 3 experts
- If the material involves **AI/LLM features**, at least one AI/ML expert
- If the material involves **user-facing features**, at least one product/frontend expert
- If the material involves **data storage or processing**, at least one data/database expert
- If the material involves **security-sensitive operations** (encryption, auth, PII), at least one security expert
- **Novel expert profiles are encouraged** when the material demands it — e.g., a "Billing Infrastructure Engineer" combining Platform + Security + Data expertise

**Output of Phase 3:** A brief report (shown to user) listing:
- The 3-5 domains identified in the material
- The 3 selected experts with one-line rationale for each
- What each expert uniquely covers that the others don't

### Phase 4: Spawn 3 Expert Subagents in Parallel

Use the Task tool to spawn exactly 3 agents simultaneously (in a single message with 3 tool calls). Each agent gets the expert profile generated in Phase 3 and the SAME context material from Phase 2.

**Each expert prompt MUST include:**
1. The full context gathered in Phase 2
2. Their specific persona and focus areas (from Phase 3 selection)
3. The overlap zones they share with the other 2 selected experts
4. Instructions to produce a structured JSON assessment

**Expert prompt template:**

```
You are a senior {ROLE} conducting an independent assessment of {TARGET}.

## Your Expertise
{ROLE_DESCRIPTION}

## What You're Assessing
{FULL_CONTEXT_FROM_PHASE_2}

## Your Focus Areas
{FOCUS_AREAS}

## Overlap Zones (areas where your perspective intersects with other reviewers)
{OVERLAP_ZONES}

## Assessment Structure

Produce your assessment as a JSON object with this exact structure:

{
  "expert": "{ROLE}",
  "overall_rating": "A/B/C/D/F with + or - modifier",
  "confidence": 0.0-1.0,
  "summary": "2-3 sentence overall assessment",
  "strengths": [
    { "title": "...", "detail": "...", "impact": "HIGH/MEDIUM/LOW" }
  ],
  "concerns": [
    { "title": "...", "detail": "...", "severity": "CRITICAL/HIGH/MEDIUM/LOW", "recommendation": "..." }
  ],
  "overlap_observations": [
    { "zone": "...", "observation": "...", "confidence": 0.0-1.0 }
  ],
  "recommendations": [
    { "title": "...", "detail": "...", "priority": "P0/P1/P2/P3", "effort": "LOW/MEDIUM/HIGH" }
  ],
  "risks": [
    { "title": "...", "likelihood": "HIGH/MEDIUM/LOW", "impact": "HIGH/MEDIUM/LOW", "mitigation": "..." }
  ],
  "questions_for_other_experts": [
    "Questions you'd want the other two experts to weigh in on"
  ]
}

Be thorough, specific, and reference actual files/code/specs where possible. Do not be generically positive — identify real issues with real recommendations.
```

Use `subagent_type: "general-purpose"` for all three agents.

### Phase 5: Triangulate Findings

Once all 3 experts return, analyze their assessments:

1. **Convergence Points** — Where 2+ experts agree (high confidence findings)
2. **Divergence Points** — Where experts disagree (genuine tensions worth exploring)
3. **Blind Spots** — Areas none of the experts covered (gaps in the assessment)
4. **Cross-Expert Questions** — Questions one expert raised that another's findings answer
5. **Overall Grade** — Weighted average of expert ratings, adjusted for convergence

### Phase 6: Generate Interactive HTML Artifact

Create a single self-contained HTML file with the Factory-Inspired design system.

**File location:** `~/Development/artifacts/{project}/dev-assess-{target-slug}.html`

If the project can't be determined, use `~/Development/artifacts/_general/`.

**7 Tabs (tab names are dynamic based on selected experts):**

1. **Overview** — Overall grade (large), confidence score, 3 expert ratings side-by-side, key stats (total concerns, recommendations, convergence %). Include the expert selection rationale: which domains were identified and why these 3 experts were chosen.
2. **{Expert 1 Short Name}** — First selected expert's full assessment: strengths, concerns (with severity badges), recommendations, risks. Tab label is the expert's short title (e.g., "Systems", "Security", "Database").
3. **{Expert 2 Short Name}** — Second selected expert's full assessment: same structure.
4. **{Expert 3 Short Name}** — Third selected expert's full assessment: same structure.
5. **Convergence** — Where experts agree: cards showing shared findings with "agreed by: [Expert 1, Expert 2]" badges. Higher weight = more experts agree.
6. **Divergence** — Where experts disagree: side-by-side comparison cards showing conflicting takes, with analysis of why they diverge and which perspective is likely more relevant for this context.
7. **Assessment** — Standard assessment tab per /visualize spec: What We Did Right, What Needs Fixing (with checkboxes + copy-paste prompts), High-Impact Next Steps, Prompts Summary.

**HTML Requirements:**
- Factory-Inspired design system (exact same tokens as /visualize)
- Safe DOM construction — use `el()` helper function, NEVER innerHTML
- localStorage checkboxes (persistent across sessions)
- Embedded JSON data model (`<script type="application/json" id="artifact-data">`)
- Copy-to-clipboard on all prompt blocks
- Responsive layout
- Staggered fade animations on tab switch
- Progress counter on Assessment tab

**Safe DOM helper (MANDATORY — use instead of innerHTML):**

```javascript
function el(tag, attrs, children) {
  var e = document.createElement(tag);
  if (attrs) Object.keys(attrs).forEach(function(k) {
    if (k === 'className') e.className = attrs[k];
    else if (k === 'textContent') e.textContent = attrs[k];
    else if (k === 'style' && typeof attrs[k] === 'object') Object.assign(e.style, attrs[k]);
    else if (k.startsWith('on')) e.addEventListener(k.slice(2).toLowerCase(), attrs[k]);
    else e.setAttribute(k, attrs[k]);
  });
  if (children) {
    if (!Array.isArray(children)) children = [children];
    children.forEach(function(c) {
      if (typeof c === 'string') e.appendChild(document.createTextNode(c));
      else if (c) e.appendChild(c);
    });
  }
  return e;
}
```

**Grading Scale:**
- A+/A/A-: Exceptional — production-ready, well-architected, minor polish only
- B+/B/B-: Good — solid foundation, some concerns to address before shipping
- C+/C/C-: Adequate — works but has significant gaps or risks
- D+/D/D-: Needs Work — fundamental issues that must be resolved
- F: Critical — not viable in current form

### Phase 7: Save and Open

Save the HTML file and open it in the browser with `open <filepath>`.

Report to the user:
1. Which 3 experts were selected and why
2. The overall grade
3. Top 3 convergence points
4. Top 3 concerns

## Usage Examples

```
/dev-assess shadow-engine
/dev-assess parallax auth flow
/dev-assess homer dashboard architecture
/dev-assess billing-system
```

## Notes

- Each expert assessment should take the subagent 2-5 minutes. Total skill runtime: ~5-8 minutes.
- The triangulation is the value — individual expert opinions are useful, but convergence/divergence analysis is what makes this actionable.
- Always read the actual code/specs, never assess based on assumptions.
- If the target is too broad (e.g., "the entire codebase"), narrow it down with the user first.
- The Assessment tab prompts should be specific enough to paste directly into Claude Code.
- **Dynamic selection is the point** — if you find yourself picking the same 3 experts every time, you're not analyzing the material deeply enough. A billing system needs different experts than an AI pipeline. A database migration needs different experts than a frontend redesign.
- The expert pool is a starting point, not a constraint. If the material demands a "GraphQL Federation Specialist" or a "Compliance Automation Engineer", compose that profile.

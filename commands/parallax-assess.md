# /parallax-assess — Clinical Triangulated Assessment

Spawn 3 PhD-level clinical expert subagents in parallel, each assessing Ava's framework from a different therapeutic/ethical perspective. Experts are **dynamically selected** based on the target material's clinical domains. Triangulate their findings into an interactive HTML artifact with risk matrix, instrument coverage analysis, and adversarial scenario evaluation.

## Arguments
- **$ARGUMENTS**: The target to assess (e.g., "shadow-engine", "interview-system", "safety-framework", "ava-voice"). Targets are always assessed in the context of Parallax/Ava's clinical framework.

## Instructions

### Phase 1: Identify the Target

Determine what's being assessed within Parallax's clinical framework. This could be:
- A new feature's psychological safety (e.g., Shadow Engine)
- An existing interaction pattern (e.g., interview system, solo mode)
- A safety mechanism (e.g., crisis detection, violence detection)
- A voice/tone specification (e.g., Ava's voice guide)
- An adversarial scenario playbook

**IMPORTANT:** Before spawning experts, YOU must read and understand the target thoroughly. Read all relevant spec documents, code files, safety configs, and prompt templates. The experts need full clinical context.

### Phase 2: Gather Context

1. Read all relevant files for the target within Parallax (`~/Development/id8/products/parallax`)
2. Read any relevant spec documents (check iCloud `.docx` files via `textutil -convert txt -stdout`)
3. Read existing safety mechanisms: `src/lib/signal-detector.ts`, `src/ava/kernel/values.md`, `src/ava/models/ipv.md`
4. Read the User Intelligence Layer research: `docs/research/user-intelligence-layer.md`
5. Read the Shadow Engine specs if assessing shadow-related features
6. Build a comprehensive clinical context summary including:
   - What the target does in user-facing terms
   - What psychological domains it touches
   - What safety mechanisms exist
   - What validated instruments are referenced
   - What consent mechanisms are in place
   - What the harm tiers look like
   - Any adversarial scenarios documented

### Phase 3: Dynamic Expert Selection

**Do NOT default to the same 3 experts every time.** After gathering context, analyze the target material to select the 3 most relevant clinical expert perspectives.

**Selection Process:**
1. Identify the top 3-5 clinical/ethical domains the target material touches (e.g., attachment theory, cultural competence, regulatory compliance, crisis intervention, trauma-informed care, relational dynamics, child safety, addiction, forensic/legal, somatic, organizational)
2. From the expert pool below, select 3 experts that:
   - **Maximize coverage** of the identified domains
   - Each brings at least one **unique validated instrument or framework** not shared by the others
   - Have **meaningful pairwise overlap** (triangulation requires shared ground to find convergence/divergence)
   - Together cover the **full risk surface** of the material
3. For each selected expert, generate a custom profile:
   - Full credentials and expertise description
   - Validated instruments in their scope (specific to this assessment)
   - Focus areas tailored to this target
   - Overlap zones with the other 2 selected experts
   - 3-4 key questions they would ask about this specific material

**Clinical Expert Pool (select 3, or compose novel expert profiles when the material demands it):**

| Expert | Core Domain | Key Instruments/Frameworks |
|--------|-------------|---------------------------|
| Clinical Psychologist (PhD) | Individual psychology, attachment, trauma, CBT, emotional regulation | ECR-RS, DERS-16, CD-Quest, PCL-5, PHQ-9, GAD-7 |
| Licensed Marriage & Family Therapist (LMFT, PhD) | Relational dynamics, Gottman, family systems, couple dynamics | TKI, Gottman Four Horsemen (33-item), DAS-7, CSI-16, Drama Triangle |
| Psychiatric Ethics Researcher (PhD) | AI ethics, duty of care, regulatory, informed consent, data privacy | Beauchamp & Childress, APA Ethics Code, SAMHSA, FTC, EU AI Act, GDPR |
| Child/Adolescent Psychologist (PhD) | Developmental psychology, minor safety, age-appropriate interventions | CBCL, SCARED, CDI-2, developmental stage models, COPPA |
| Forensic Psychologist (PhD) | Legal psychology, IPV, coercive control, risk assessment | Danger Assessment (DA), CTS-2, Evan Stark framework, SARA, DVSI-R |
| Cultural Psychologist (PhD) | Cross-cultural dynamics, measurement bias, cultural formulation | Hofstede dimensions, DSM-5 Cultural Formulation Interview, measurement invariance |
| Crisis Intervention Specialist (PhD) | Suicidality, acute distress, de-escalation, safety planning | Columbia Protocol (C-SSRS), Stanley Safety Planning, QPR, CAMS |
| Addiction/Substance Abuse Counselor (PhD) | Substance abuse patterns, co-occurring disorders, recovery | AUDIT, DAST-10, CAGE, motivational interviewing stages |
| Health/Somatic Psychologist (PhD) | Mind-body connection, chronic illness, body image, eating disorders | DASS-21, EDE-Q, BIS, somatic symptom measures |
| Neuropsychologist (PhD) | Cognitive processing, executive function, neurodiversity | MoCA, cognitive load theory, ADHD/ASD interaction patterns |
| Social Worker (LCSW, PhD) | Community/systemic factors, resource access, social determinants | PIE system, strengths-based assessment, eco-maps, mandated reporting |
| Organizational Psychologist (PhD) | Workplace conflict, power dynamics, organizational justice | Conflict Management Assessment, organizational justice scales, mobbing frameworks |

**Composition Rules:**
- Always exactly 3 experts
- At least one expert must cover **ethical/regulatory** dimensions (unless the material has zero regulatory surface)
- If the material involves **relationships** (couples, family, groups), at least one relational expert
- If the material involves **individual psychology** (trauma, attachment, cognition), at least one individual expert
- If the material involves **safety-critical** features (crisis, IPV, self-harm), at least one safety/forensic expert
- **Novel expert profiles are encouraged** when the material doesn't fit cleanly into the pool — compose a hybrid expert with clear credentials and instruments

**Output of Phase 3:** A brief report (shown to user) listing:
- The 3-5 domains identified in the material
- The 3 selected experts with one-line rationale for each
- What each expert uniquely covers that the others don't

### Phase 4: Spawn 3 Expert Subagents in Parallel

Use the Task tool to spawn exactly 3 agents simultaneously (in a single message with 3 tool calls). Each agent gets the expert profile generated in Phase 3 and the SAME context material from Phase 2.

**Each expert prompt MUST include:**
1. The full clinical context gathered in Phase 2
2. Their specific persona, credentials, and focus areas (from Phase 3 selection)
3. The validated instruments in their scope
4. The overlap zones they share with the other 2 selected experts
5. Instructions to produce a structured JSON assessment

**Expert prompt template:**

```
You are a {ROLE} conducting an independent clinical assessment of {TARGET} within the Parallax platform (an AI-assisted conflict resolution tool featuring Ava, a psychologically-aware conversational entity).

## Your Credentials and Expertise
{ROLE_DESCRIPTION}

## Validated Instruments in Your Scope
{INSTRUMENTS}

## What You're Assessing
{FULL_CONTEXT_FROM_PHASE_2}

## Your Focus Areas
{FOCUS_AREAS}

## Overlap Zones
{OVERLAP_ZONES}

## Critical Safety Context
Parallax positions itself as "conflict resolution, NOT therapy" to avoid CMIA/HIPAA/FDA burden. Ava uses NVC (Nonviolent Communication) as a core framework with additional analytical lenses. Users interact in real-time during actual conflicts.

The critical test for everything: "If the most vulnerable person on their worst day used this — would it help or hurt?"

## Assessment Structure

Produce your assessment as a JSON object with this exact structure:

{
  "expert": "{ROLE}",
  "overall_safety_rating": "SAFE/CAUTION/CONCERN/CRITICAL",
  "clinical_grade": "A/B/C/D/F with modifier",
  "confidence": 0.0-1.0,
  "summary": "2-3 sentence clinical assessment",
  "strengths": [
    { "title": "...", "detail": "...", "clinical_basis": "Reference to validated instrument or established practice" }
  ],
  "concerns": [
    {
      "title": "...",
      "detail": "...",
      "severity": "CRITICAL/HIGH/MEDIUM/LOW",
      "harm_tier": "T1/T2/T3/T4",
      "affected_population": "Who is most at risk",
      "recommendation": "...",
      "clinical_basis": "Reference to literature, instrument, or ethical framework"
    }
  ],
  "risk_matrix": [
    {
      "scenario": "...",
      "likelihood": "HIGH/MEDIUM/LOW",
      "impact": "CATASTROPHIC/SEVERE/MODERATE/MINOR",
      "current_mitigation": "What exists now",
      "recommended_mitigation": "What should exist",
      "harm_tier": "T1/T2/T3/T4"
    }
  ],
  "instrument_coverage": [
    {
      "instrument": "ECR-RS / DERS-16 / etc.",
      "domain": "Attachment / Regulation / etc.",
      "coverage": "FULL/PARTIAL/MISSING",
      "gaps": "What's not covered",
      "recommendation": "..."
    }
  ],
  "overlap_observations": [
    { "zone": "...", "observation": "...", "confidence": 0.0-1.0 }
  ],
  "recommendations": [
    { "title": "...", "detail": "...", "priority": "P0/P1/P2/P3", "effort": "LOW/MEDIUM/HIGH", "clinical_basis": "..." }
  ],
  "adversarial_scenarios": [
    {
      "scenario": "...",
      "current_handling": "How the system handles this now",
      "gaps": "What's missing",
      "recommended_handling": "What should happen",
      "severity": "CRITICAL/HIGH/MEDIUM/LOW"
    }
  ],
  "questions_for_other_experts": [
    "Questions you'd want the other two experts to weigh in on"
  ]
}

Be clinically rigorous. Reference actual validated instruments, established therapeutic frameworks, and published literature where possible. Do not be generically reassuring — identify real clinical risks with real mitigations. Err on the side of caution for user safety.
```

Use `subagent_type: "general-purpose"` for all three agents.

### Phase 5: Triangulate Findings

Once all 3 experts return, perform clinical triangulation:

1. **Convergence Points** — Where 2+ experts agree on safety/risk (highest confidence clinical findings)
2. **Divergence Points** — Where experts disagree (genuine clinical tensions, e.g., "more therapeutic depth" vs "stay in your lane")
3. **Risk Matrix Synthesis** — Unified risk matrix combining all experts' scenarios, deduplicated, with harm tiers
4. **Instrument Coverage Map** — Which validated instruments are fully/partially/not covered across all expert domains
5. **Adversarial Scenario Coverage** — Are all 16 documented scenarios addressed? Any new ones identified?
6. **Overall Safety Rating** — Conservative (if ANY expert rates CRITICAL, overall is CRITICAL)

**Safety Rating Scale:**
- SAFE: All experts agree — appropriate safeguards, clinical basis sound
- CAUTION: Minor concerns from 1+ experts — addressable before launch
- CONCERN: Significant concerns from 2+ experts — requires redesign of specific components
- CRITICAL: Any expert identifies potential for serious harm — launch blocker

### Phase 6: Generate Interactive HTML Artifact

Create a single self-contained HTML file with the Factory-Inspired design system.

**File location:** `~/Development/artifacts/parallax/parallax-assess-{target-slug}.html`

**8 Tabs (tab names are dynamic based on selected experts):**

1. **Overview** — Overall safety rating (large, color-coded), clinical grade, 3 expert ratings side-by-side, key stats (total concerns by severity, instrument coverage %, adversarial scenario coverage %). Include the expert selection rationale: which domains were identified and why these 3 experts were chosen.
2. **{Expert 1 Short Name}** — First selected expert's full assessment: strengths, concerns (with harm tier badges), risk matrix entries, instrument coverage for their domain. Tab label is the expert's short title (e.g., "Clinical", "Forensic", "Cultural").
3. **{Expert 2 Short Name}** — Second selected expert's full assessment: same structure.
4. **{Expert 3 Short Name}** — Third selected expert's full assessment: same structure.
5. **Convergence** — Where experts agree: cards showing shared findings with expert agreement badges. Safety convergence gets special prominence.
6. **Risk Matrix** — Unified risk matrix: table with columns for Scenario, Likelihood, Impact, Harm Tier, Current Mitigation, Recommended Mitigation. Color-coded by harm tier. Sortable by severity. Include the critical test callout.
7. **Instruments** — Instrument coverage dashboard: which validated instruments are covered/partially covered/missing across all domains. Gaps highlighted. Recommendations for filling gaps.
8. **Assessment** — Standard assessment tab per /visualize spec: What We Did Right, What Needs Fixing (with checkboxes + copy-paste prompts), High-Impact Next Steps, Prompts Summary. Prompts reference Parallax codebase paths specifically.

**HTML Requirements:**
- Factory-Inspired design system (exact same tokens as /visualize)
- Safe DOM construction — use `el()` helper function, NEVER innerHTML
- localStorage checkboxes (persistent across sessions)
- Embedded JSON data model (`<script type="application/json" id="artifact-data">`)
- Copy-to-clipboard on all prompt blocks
- Responsive layout
- Staggered fade animations on tab switch
- Progress counter on Assessment tab
- Risk matrix should be sortable by clicking column headers
- Harm tier color coding: T1 = teal (#4ecdc4), T2 = amber (#f59e0b), T3 = red (#ef4444), T4 = purple (#9333ea)

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

**Safety Rating Visual:**
- SAFE: Large teal badge with teal glow
- CAUTION: Large amber badge
- CONCERN: Large red badge
- CRITICAL: Large red badge with pulsing red glow animation

**Critical Test Callout (include on Overview and Risk Matrix tabs):**
```
"If the most vulnerable person on their worst day used this — would it help or hurt?"
```
Style as a prominent quote block with warm border.

### Phase 7: Save and Open

Save the HTML file and open it in the browser with `open <filepath>`.

Report to the user:
1. Which 3 experts were selected and why
2. The overall safety rating
3. Top 3 clinical convergence points
4. Any CRITICAL-severity concerns

## Usage Examples

```
/parallax-assess shadow-engine
/parallax-assess interview-system
/parallax-assess ava-voice
/parallax-assess crisis-detection
/parallax-assess solo-mode safety
```

## Notes

- Each expert assessment should take the subagent 3-7 minutes. Total skill runtime: ~8-12 minutes.
- The conservative safety rating (worst-case from any expert) is intentional — clinical safety should never be averaged away.
- Always read Parallax's actual code and safety mechanisms, not just the specs. The gap between spec and implementation is often where clinical risk lives.
- Reference the 6 Shadow Engine spec documents when assessing shadow-related features.
- The "conflict resolution, NOT therapy" positioning is a legal and ethical boundary that must be maintained — experts should evaluate whether the target respects this boundary.
- Adversarial scenario coverage should reference the 16 documented scenarios from the Shadow Engine playbook, plus any new ones the experts identify.
- Instrument coverage should map to the 14 analytical lenses documented in the Conflict Intelligence Engine blueprint.
- **Dynamic selection is the point** — if you find yourself picking the same 3 experts every time, you're not analyzing the material deeply enough. Different targets should yield different panels.
- The expert pool is a starting point, not a constraint. If the material demands a Bioethicist, a Disability Rights Specialist, or a Military Psychology Expert, compose that profile.

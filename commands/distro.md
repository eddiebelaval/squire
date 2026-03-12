# /distro — Marketing & Distribution Pipeline

You are executing the **DISTRO Pipeline** — the marketing/distribution counterpart to the ID8 Build Pipeline. This pipeline takes a shipped (or near-shipped) product and creates a systematic path to end users.

**Philosophy:** The same discipline that builds the product must ship the product. No ad-hoc marketing. No "I'll post something later." Structure creates distribution momentum.

---

## Arguments

- `/distro` — Start from Stage 1 on current project (auto-detect from cwd or ask)
- `/distro --stage N` — Jump to a specific stage (for resuming)
- `/distro --status` — Show current pipeline status
- `/distro --sustain` — Run the weekly sustain cycle (Stage 6)
- `/distro --measure` — Run measurement check (Stage 7)
- `/distro --heal` — Run the self-healing loop on underperforming assets

---

## Pre-Flight

Before starting, gather context:

1. **Identify the project** — Check cwd, ask if ambiguous. Confirm project name and repo.
2. **Check for existing distro workspace** — Look for `workspace/distro/` in the project root. If it exists, read `workspace/distro/DISTRO_STATUS.md` and resume from current stage.
3. **Check build status** — Read `PIPELINE_STATUS.md` or `BUILDING.md` if they exist. The product should be at Stage 9+ (Launch Prep) or already live. If it's earlier, warn: "This product isn't shipped yet — distro pipeline works best on shipped products. Continue anyway?"
4. **Create distro workspace** if it doesn't exist — Run `~/.claude/generators/new-distro-workspace.sh --project <name>` or create the structure manually.

---

## The 7 Stages

### Stage 1: Product Intel (Automated)

**Gate:** You can explain the product in one paragraph to a stranger.
**Checkpoint:** "What does this do, who is it for, and why should they care?"

**Actions:**
1. Read the codebase to understand the product:
   - `package.json` — name, description, dependencies (reveals stack)
   - `README.md` / `BUILDING.md` — product story, what was built
   - Landing page / home page components — existing copy, messaging
   - Route structure — what features exist
   - Any existing marketing copy, meta tags, OG images
   - `.env.example` or deployment config — what's the live URL?

2. Extract and document:
   - **Product name** and live URL
   - **One-liner** (what it does in one sentence)
   - **Target user** (who this is for, be specific — not "everyone")
   - **Core pain point** (what problem it solves)
   - **Key features** (3-5 max, what it actually does)
   - **Tech differentiator** (what makes the approach unique)
   - **Current state** (live, beta, waitlist, demo)
   - **Pricing** (free, freemium, paid — what's the model?)

3. Write output to `workspace/distro/product-intel.md`

4. **Present the intel to the user for validation.** Ask:
   - "Is this accurate? Anything I'm missing or getting wrong?"
   - "Who is the FIRST person you'd hand this to?" (this is the real target user)

**Tools:** Codebase reading (Read, Glob, Grep). No external skills needed.

---

### Stage 2: Positioning (Interactive)

**Gate:** Clear positioning statement that differentiates from alternatives.
**Checkpoint:** "Why THIS product over everything else they could use?"

**Actions:**
1. **Interview the user** (use AskUserQuestion for structured choices, conversation for open-ended):

   - **Competitive landscape:** "What do people currently use instead? (Could be another product, a manual process, or nothing)"
   - **Unique angle:** "What's the thing about this that nobody else does?"
   - **Origin story:** "Why did you build this? What pissed you off or excited you?"
   - **Social proof:** "Has anyone used this yet? What did they say?"
   - **Pricing rationale:** "Why is it priced this way? What's the value equation?"

2. **Research competitors** (use WebSearch):
   - Search for alternatives in the same space
   - Note their positioning, pricing, messaging
   - Identify gaps they're not covering

3. **Craft positioning:**
   - **Positioning statement:** "For [target user] who [pain point], [product] is [category] that [key differentiator]. Unlike [alternatives], it [unique value]."
   - **Elevator pitch:** 30-second version
   - **One-liner:** Tweet-length version
   - **Anti-positioning:** What this product is NOT (prevents scope creep in messaging)

4. Write output to `workspace/distro/positioning.md`

**Tools:** WebSearch for competitor research, AskUserQuestion for interview.

---

### Stage 3: Asset Factory (Automated + Interactive)

**Gate:** Complete set of marketing assets ready to deploy.
**Checkpoint:** "Could I launch across 3 channels RIGHT NOW with what we have?"

**IMPORTANT:** Before generating any asset, read `~/.claude/commands/distro-lexicon.md` and consult the relevant section for that asset type. Apply the frameworks, follow the rules, avoid the anti-patterns. Every asset should pass the lexicon's anti-pattern checklist before being presented to the user.

**Actions:**
1. **Generate all core assets** (use appropriate skills for each, applying lexicon rules):

   **Copy Assets** (use `copywriter` or `copywriting` skill):
   - Landing page headline + subhead (3 variations)
   - Feature descriptions (benefit-first, not feature-first)
   - Social proof / testimonial templates
   - CTA variations

   **Social Media Assets** (use `social-content` or `social-post-creator` skill):
   - **X/Twitter:** 10 posts (mix of: announcement, feature highlight, pain point, story, thread opener)
   - **LinkedIn:** 5 posts (professional angle, founder story, industry insight)
   - **Product Hunt:** Tagline, description, first comment, maker comment

   **Email Assets** (use `email-sequence` skill):
   - Launch announcement email
   - 3-email onboarding sequence (welcome, key feature, success story)
   - Waitlist/early access email (if applicable)

   **Long-form Assets** (use `blog-post-writer` skill):
   - Launch blog post / announcement article
   - "How I built X" story (for Hacker News / dev communities)

   **Meta Assets:**
   - OG image description (for designer or AI image gen)
   - Meta description for SEO
   - App store / directory descriptions

2. **Present all assets to user for review.** Batch by type.
3. **Iterate on feedback.** Revise until approved.
4. Write all outputs to `workspace/distro/assets/` organized by type:
   ```
   assets/
     copy/           # Headlines, descriptions, CTAs
     social/         # Platform-specific posts
     email/          # Sequences and one-offs
     long-form/      # Articles, blog posts
     meta/           # SEO, OG, directory listings
   ```

**Tools:** `copywriting`, `social-content`, `email-sequence`, `blog-post-writer` skills. Use `ad-copy-writer` for paid ad variants if user plans paid acquisition.

---

### Stage 4: Channel Map (Interactive)

**Gate:** Channels selected, accounts verified, format requirements documented.
**Checkpoint:** "Where exactly are we posting, and is everything set up?"

**Actions:**
1. **Present channel options** (use AskUserQuestion with multi-select):

   | Channel | Best For | Effort | Reach |
   |---------|----------|--------|-------|
   | X/Twitter | Dev tools, SaaS, hot takes | Low | Medium |
   | LinkedIn | B2B, professional tools, founder story | Low | Medium |
   | Product Hunt | Launches, new products | Medium | High (burst) |
   | Hacker News | Dev tools, technical products | Low | High (if it hits) |
   | Reddit | Niche communities, honest discussion | Medium | Targeted |
   | Indie Hackers | Bootstrapped products, revenue stories | Low | Targeted |
   | Email list | Existing audience, warm leads | Low | High (conversion) |
   | Directories | SEO, passive discovery | Medium | Slow but compound |
   | Paid (X/Meta) | Scaling what works | High ($) | Scalable |

2. **For each selected channel, document:**
   - Account status (exists? handle? connected?)
   - Format requirements (character limits, image sizes, posting rules)
   - Best posting times
   - Community rules / etiquette (especially Reddit, HN)
   - How assets from Stage 3 map to this channel

3. **Verify accounts are ready:**
   - Ask user to confirm each account is accessible
   - Note any accounts that need to be created
   - Flag any that need profile updates (bio, link, etc.)

4. Write output to `workspace/distro/channels.md`

**Tools:** WebSearch for channel-specific best practices, AskUserQuestion for selection.

---

### Stage 5: Launch Sequence (Orchestrated)

**Gate:** Day-by-day launch plan with specific posts, times, and channels.
**Checkpoint:** "If I follow this calendar, does the launch happen without any improvisation?"

**Actions:**
1. **Determine launch type** (ask user):
   - **Soft launch:** Quiet release, tell a few people, gather feedback first
   - **Coordinated launch:** Multi-channel, specific date, everything at once
   - **Rolling launch:** Staggered across channels over 1-2 weeks

2. **Build the launch calendar:**

   **Pre-Launch (3-7 days before):**
   - Teaser posts (building anticipation)
   - "Building in public" posts with behind-the-scenes
   - DM key people / early adopters

   **Launch Day:**
   - Morning: Product Hunt submission (if applicable)
   - Morning: X announcement thread
   - Midday: LinkedIn post
   - Afternoon: Reddit / HN submission
   - Evening: Follow-up engagement, respond to comments

   **Post-Launch (Days 2-7):**
   - Day 2: Share first reactions / metrics
   - Day 3: Feature highlight post
   - Day 4: "How I built this" article
   - Day 5: Engage with feedback, iterate messaging
   - Day 6-7: Secondary channel pushes

3. **Assign specific assets to each slot:**
   - Map assets from Stage 3 to calendar slots
   - Customize per-channel formatting
   - Include direct links to the asset files

4. **Create HYDRA jobs for automated posting** (if user wants automation):
   - Draft the posting schedule as HYDRA-compatible jobs
   - Include review step before auto-posting goes live

5. Write output to `workspace/distro/launch-sequence.md`

**Tools:** `social-media-manager` agent for timing optimization, `content-calendar-planner` skill for calendar structure.

---

### Stage 6: Sustain (Automated + Scheduled)

**Gate:** Ongoing content machine running with minimal manual effort.
**Checkpoint:** "Will content keep shipping if I don't think about it for a week?"

**Actions:**
1. **Build weekly content calendar:**
   - Monday: Industry insight / thought leadership
   - Tuesday: Product tip / feature highlight
   - Wednesday: User story / social proof
   - Thursday: Behind the scenes / building in public
   - Friday: Engagement post (question, poll, hot take)

2. **Create repurpose engine:**
   - Blog post → 5 social posts (extract key points)
   - X thread → LinkedIn article
   - User feedback → testimonial post
   - Feature update → announcement + tutorial

3. **Set up HYDRA automation** (if user approves):
   - Content generation jobs (weekly batch of posts)
   - Posting schedule (buffer posts for consistent output)
   - Engagement monitoring (flag high-engagement posts for amplification)

4. **Create content templates:**
   - Feature announcement template
   - User story template
   - Weekly metrics share template
   - "Lessons learned" template

5. Write output to `workspace/distro/content-calendar.md`
6. Update `workspace/distro/assets/social/` with new batched content

**Tools:** `content-calendar-planner` skill, `social-content` skill for batch generation, `social-media-manager` agent for scheduling strategy.

---

### Stage 7: Measure & Iterate (Periodic)

**Gate:** Data-informed decisions about what's working and what's not.
**Checkpoint:** "What's our best channel, best message, and what should we kill?"

**Actions:**
1. **Gather metrics** (ask user for what they can access):
   - Website traffic (unique visitors, sources, bounce rate)
   - Signups / conversions (total, by channel)
   - Social engagement (impressions, clicks, replies, shares)
   - Revenue (if applicable)
   - Email metrics (open rate, click rate)

2. **Analyze and rank:**
   - Which channels drive the most signups?
   - Which messages get the most engagement?
   - What's the cost per acquisition (if paid)?
   - What's working that we should double down on?
   - What's not working that we should kill?

3. **Create iteration plan:**
   - Double down on top 2 channels
   - Kill bottom performers
   - A/B test next messaging variations
   - Identify new channels to test

4. **Feed back into pipeline:**
   - Update `positioning.md` if messaging insights emerge
   - Generate new assets in `assets/` based on what's working
   - Adjust content calendar in `content-calendar.md`

5. Write output to `workspace/distro/metrics.md`
6. Update `DISTRO_STATUS.md` with latest metrics snapshot

**Tools:** `campaign-analyzer` skill for analysis, `data-analyzer` skill for metrics processing, `kpi-dashboard` skill for visualization.

---

## Pipeline Governance

### Status Tracking

Every project with an active distro pipeline must have `workspace/distro/DISTRO_STATUS.md`:

```markdown
# DISTRO Pipeline Status

**Project:** [name]
**Started:** [date]
**Current Stage:** [N]
**Live URL:** [url]

## Stage History
| Stage | Status | Completed | Notes |
|-------|--------|-----------|-------|
| 1. Product Intel | COMPLETE | YYYY-MM-DD | ... |
| 2. Positioning | IN PROGRESS | - | ... |
| ... | | | |

## Key Metrics (updated at Stage 7)
- Signups this week:
- Top channel:
- Top performing post:
- Revenue:

## Next Actions
- [ ] ...
```

### Commit Convention

Distro work uses its own prefix:
```
[Distro N: Stage Name] type: description
```

Types: `asset`, `copy`, `strategy`, `metrics`, `automate`, `docs`

Examples:
- `[Distro 1: Product Intel] docs: extract product positioning from codebase`
- `[Distro 3: Asset Factory] asset: generate launch social media batch`
- `[Distro 5: Launch Sequence] strategy: build 7-day coordinated launch plan`
- `[Distro 6: Sustain] automate: configure weekly content calendar`

### Gate Checks

Same discipline as the build pipeline:
- Do NOT advance to next stage without user sign-off
- Ask the checkpoint question before advancing
- Wait for confirmation
- Log gate passage in `DISTRO_STATUS.md`

### Override Protocol

User can skip/combine stages by stating a reason. Log override in `DISTRO_STATUS.md`.

---

## Cycle Behavior

Unlike the build pipeline (linear), the distro pipeline is **cyclical**:

```
Stage 1 → 2 → 3 → 4 → 5 → 6 → 7
                                 ↓
                          (feedback loop)
                                 ↓
                           3 → 5 → 6 → 7 (repeat)
```

After the first full pass, Stages 1-2 rarely need revisiting (unless pivoting). The active cycle is: **generate assets (3) → launch/distribute (5) → sustain (6) → measure (7) → repeat.**

### Sustain Mode (`/distro --sustain`)

When invoked with `--sustain`:
1. Read `workspace/distro/content-calendar.md`
2. Check what's been posted vs. what's scheduled
3. Generate next batch of content
4. Present for approval
5. Update calendar

### Measure Mode (`/distro --measure`)

When invoked with `--measure`:
1. Read `workspace/distro/metrics.md`
2. Ask user for latest numbers
3. Analyze trends
4. Recommend adjustments
5. Update metrics file

---

## Integration Points

### With ID8 Build Pipeline
- `/distro` starts after Stage 9 (Launch Prep) or Stage 10 (Ship)
- Build pipeline's Stage 9 checklist should include "Distro pipeline initiated"
- Feature updates (Stage 11: Listen & Iterate) trigger new distro assets

### With HYDRA
- Stage 5 can generate HYDRA job definitions for automated posting
- Stage 6 sustain mode can be powered by HYDRA cron jobs
- Monitoring jobs can feed into Stage 7 metrics

### With Workspace System
- All outputs live in `workspace/distro/`
- Tasks for distro work use `workspace/tasks/` like any other work
- Prep docs reference `workspace/prep/` for research

---

## Self-Healing Loop (`/distro --heal`)

The self-healing loop is the DISTRO pipeline's equivalent of `/heal` for tests. It takes underperforming assets, diagnoses why they failed, and generates refined versions — automatically.

### How It Works

```
Ship Asset → Collect Metrics → Score → Diagnose → Refine → Re-ship
     ↑                                                        |
     └────────────────────────────────────────────────────────┘
```

### When Invoked (`/distro --heal`)

**Step 1: Gather Performance Data**

Ask the user for metrics on shipped assets. Structure the intake:

```
For each asset that's been shipped, I need:
- Asset name / description (which post, email, page?)
- Platform (X, LinkedIn, email, landing page, etc.)
- Impressions / reach
- Engagement (likes, comments, replies, shares)
- Clicks (if applicable)
- Conversions (signups, purchases — if applicable)
- Time since posted
```

If the user can provide analytics screenshots or dashboards, even better. Parse what you can.

**Step 2: Score Against Benchmarks**

Read the benchmarks from `~/.claude/commands/distro-lexicon.md` for each asset's platform. Score each asset:

| Score | Label | Meaning |
|-------|-------|---------|
| 5 | Performing | Above "Good" benchmarks — leave it alone or amplify |
| 4 | Acceptable | Meets "Okay" benchmarks — minor tweaks only |
| 3 | Underperforming | Below "Okay" — needs refinement |
| 2 | Failing | Below "Poor" — needs rework |
| 1 | Dead | Zero engagement or negative signal — kill or completely rethink |

**Step 3: Diagnose Failure Mode**

For every asset scoring 3 or below, run it through the Failure Mode Taxonomy from the lexicon:

1. **Did it reach the right people?** → If no: Wrong Audience
2. **Did they stop to read it?** → If no: Weak Hook
3. **Did they understand the value?** → If no: Feature Speak or Generic Message
4. **Did they take action?** → If no: No Clear CTA or Trust Gap
5. **Did they convert?** → If no: Friction or Platform Mismatch

Assign a failure mode and severity (1-5) to each underperformer.

Present the diagnosis as a table:

```markdown
## Heal Diagnosis — [Date]

| Asset | Platform | Score | Failure Mode | Severity | Prescribed Fix |
|-------|----------|-------|-------------|----------|---------------|
| Launch tweet | X | 2 | Weak Hook | 3 (Rework) | Rewrite with contrarian hook framework |
| LinkedIn post | LinkedIn | 3 | Feature Speak | 2 (Refine) | Rewrite lead using PAS, benefits first |
| Welcome email | Email | 4 | - | 1 (Tweak) | Adjust subject line for curiosity gap |
| Landing hero | Web | 2 | No Clear CTA | 3 (Rework) | Single CTA above fold, outcome headline |
```

**Step 4: Generate Refined Versions**

For each asset scoring 3 or below:

1. Read the original asset from `workspace/distro/assets/`
2. Read the relevant lexicon section for its platform
3. Apply the prescribed fix:
   - **Severity 1 (Tweak):** Change 1-2 elements (CTA wording, timing, format)
   - **Severity 2 (Refine):** Rewrite the hook + restructure the body using a different framework
   - **Severity 3 (Rework):** Generate entirely new asset using a different approach from the lexicon
   - **Severity 4 (Redirect):** Move the effort to a different channel — generate new asset for that channel
   - **Severity 5 (Rethink):** Flag for manual positioning review — redirect user to `/distro --stage 2`

4. For each refined asset, generate **2 variations** (A/B testing material)
5. Present both variations alongside the original for comparison
6. Label each variation with which lexicon rule it applies

**Step 5: Update Assets**

After user approval:
1. Archive the original asset (rename with `.v1` suffix in the same directory)
2. Save the approved refined version as the new primary
3. Log the heal cycle in `workspace/distro/metrics.md`:

```markdown
## Heal Cycle — [Date]

### Assets Healed: [N]

| Asset | Original Score | Failure Mode | Fix Applied | New Version |
|-------|---------------|-------------|-------------|-------------|
| Launch tweet | 2 | Weak Hook | Contrarian hook rewrite | v2 |
| LinkedIn post | 3 | Feature Speak | PAS framework rewrite | v2 |

### Heal Notes
- [Any patterns observed — e.g., "All social assets had weak hooks — our default voice is too corporate"]
- [Action items — e.g., "Update brand voice guide to lead with pain points"]
```

4. Update `DISTRO_STATUS.md` with heal cycle timestamp and summary

**Step 6: Re-ship**

Present the refined assets ready for re-deployment:
- Updated social posts formatted for copy-paste
- Updated email drafts ready to send
- Updated landing page copy with specific edit instructions
- Recommendations on re-posting timing based on lexicon rules

### Heal Loop Cadence

The heal loop should run:
- **After launch week (day 7-10):** First data is in. Run heal on everything.
- **Weekly during active distribution:** Part of the sustain cycle.
- **When user reports poor performance:** On-demand via `/distro --heal`.

### Compound Learning

Every heal cycle teaches the pipeline. After 3+ heal cycles, look for **patterns**:

- Same failure mode keeps appearing → **systemic issue** (voice, audience, channel choice)
- Same platform keeps underperforming → **wrong channel** — cut it
- Same framework keeps winning → **double down** — make it the default
- Severity trending down over cycles → **pipeline is learning** — good sign

Log these patterns in `workspace/distro/metrics.md` under a "## Compound Learnings" section.

### Tools for Heal Loop

| Step | Tool |
|------|------|
| Metric analysis | `campaign-analyzer` skill, `data-analyzer` skill |
| Failure diagnosis | Lexicon reference (`distro-lexicon.md`) |
| Asset refinement | `copywriting` skill, `social-content` skill, `email-sequence` skill |
| A/B variation | `ab-test-designer` skill |
| Landing page fixes | `landing-page-optimizer` skill, `page-cro` skill |

---

## Lexicon Reference

The DISTRO Lexicon lives at `~/.claude/commands/distro-lexicon.md`. It contains:

- **Per-platform rules** — X, LinkedIn, Product Hunt, Hacker News, Reddit, Email, Landing Pages, Blog, Paid Ads
- **Copywriting frameworks** — PAS, AIDA, BAB, 4U, One-Liner Formula (with examples and when to use each)
- **Anti-pattern checklists** — per-asset-type things that kill performance
- **Benchmarks** — what "poor/okay/good/great" looks like for every metric on every platform
- **Failure Mode Taxonomy** — 10 classified failure modes with signals, diagnoses, and prescribed fixes

**When to consult the lexicon:**
- Stage 3 (Asset Factory): Before generating any asset
- Stage 7 (Measure): When interpreting performance data
- Heal Loop: When diagnosing and refining underperformers
- Sustain Mode: When generating weekly content batches

---

## Philosophy

You built it. Now ship it to humans. The distro pipeline is not optional — it's the other half of the product. A product nobody knows about is the same as a product that doesn't exist.

**The 80% rule:** If you built 80% and shipped 0%, you built 0%. Distro completes the circuit.

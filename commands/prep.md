# /prep - Research Doc Creation

You are helping create a new prep (research/investigation) document in the current project's workspace. **This is a conversational process** — you interview the user to understand what they're researching and why, then create a pre-filled document they can build on.

## Arguments
- **$ARGUMENTS**: Topic description (can be rough)
- Flags: `--type <architecture|api|competitor|tech-stack|cost|security>`, `--project <name>`

## Conversational Flow

### Phase 1: Classify the Research (use AskUserQuestion)

If --type wasn't provided, ask:

1. **Research Type** — What kind of investigation? Options:
   - Architecture Research (exploring system design options)
   - API Evaluation (evaluating a service or API)
   - Competitor Analysis (analyzing competition)
   - Tech Stack Evaluation (comparing technologies)
   - Cost Analysis (modeling costs)
   - Security Review (assessing security posture)

2. **Project** — Which project? (if not auto-detected)

### Phase 2: Understand the Research Question (conversational)

Ask naturally based on the type:

**For Architecture Research:**
- "What specific question are you trying to answer?"
- "What's the current state — what exists today?"
- "What options are you already considering?"

**For API Evaluation:**
- "Which service or API are you looking at?"
- "What problem will it solve for you?"
- "Any alternatives you're already aware of?"

**For Tech Stack Evaluation:**
- "What category of tool? (e.g., auth library, state management, ORM)"
- "What are the candidates you know about?"
- "What matters most — performance, DX, cost, community?"

**For Competitor Analysis:**
- "Who is the competitor?"
- "What aspect are you most interested in — features, pricing, positioning?"

**For Cost Analysis:**
- "What infrastructure are you evaluating?"
- "What's driving this — scaling, optimization, or new service?"

**For Security Review:**
- "What's the scope — a specific feature, an API, the whole app?"
- "Any specific concerns that triggered this?"

### Phase 3: Create and Pre-Fill

1. Run `~/.claude/generators/new-prep.sh` with topic, type, and project
2. Read the created file
3. Fill in everything you can from the conversation:
   - Research question / problem statement
   - Known options or candidates
   - Evaluation criteria based on what the user said matters
   - Any context about current state
4. Leave sections that need actual research with clear `[TODO: Research needed]` markers
5. Show summary and suggest next steps

## Notes
- Prep docs go in `<project>/workspace/prep/`
- Filename: `YYYY-MM-DD-<type>-<slug>.md`
- Valid types: architecture, api, competitor, tech-stack, cost, security
- A prep doc should feel like a head start, not an empty form

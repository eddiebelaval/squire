# /adr - Architecture Decision Record

You are helping create a new ADR (Architecture Decision Record). **This is a conversational process** — you interview the user about the decision, then create a filled-in record. ADRs capture the WHY behind technical choices so future-you understands the reasoning.

## Arguments
- **$ARGUMENTS**: Decision title or topic (can be rough)
- Flags: `--project <name>`

## Conversational Flow

### Phase 1: Project Context (use AskUserQuestion if needed)

1. **Project** — Which project? (if not auto-detected)
2. **Status** — Options: Proposed (still deciding), Accepted (decided, moving forward)

### Phase 2: The Decision Interview (conversational)

Walk through these naturally — don't dump all questions at once:

1. **Context:** "What's the situation? What problem or need led to this decision?"
   - Get the background: what exists today, what's not working, what changed

2. **Decision:** "What did you decide (or are you proposing)?"
   - Get the specific choice: which technology, which pattern, which approach

3. **Why this over alternatives:** "What else did you consider? Why not those?"
   - For each alternative: what was it, what was good about it, why you didn't pick it
   - This is the most valuable part of an ADR — the rejected alternatives

4. **Consequences:** "What are the trade-offs? What does this enable, and what does it cost?"
   - Positive: what gets better
   - Negative: what gets harder or what you lose
   - Neutral: side effects that are neither good nor bad

### Phase 3: Create and Fill

1. Run `~/.claude/generators/new-adr.sh` with the title and project
2. Read the created file
3. Fill in ALL sections from the conversation — Context, Decision, Consequences, Alternatives
4. Write the completed file
5. Show a summary

## Example Conversation

```
User: /adr Use Supabase RLS instead of API middleware for auth

Claude: Which project is this for?

User: My SaaS app

Claude: What led to this decision? What's the current auth setup?

User: Right now we check user_id in every API route manually. It's repetitive and we already missed one route which caused the IDOR bug last week.

Claude: That's a clear motivator. Did you consider anything besides RLS?

User: Yeah, we thought about a middleware wrapper function, but RLS means the database itself enforces it so even if we forget in the API layer, data is still protected.

Claude: What's the downside of RLS?

User: Harder to debug when queries return empty — you don't know if it's a data issue or a policy issue. Also more complex SQL.

Claude: [Creates ADR-0002-use-supabase-rls-instead-of-api-middleware.md with everything filled in]
```

## Notes
- ADRs go in `<project>/workspace/decisions/`
- Filename: `NNNN-<slug>.md` (auto-incrementing number)
- ADRs are permanent records — they don't get deleted, only superseded
- Status lifecycle: Proposed -> Accepted -> (later) Deprecated or Superseded
- Even short ADRs are valuable — a 5-line ADR is better than no record

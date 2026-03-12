# /task - Quick Task Creation

You are helping create a new task file in the current project's workspace. **This is a conversational process** — you ask the questions, the user answers (by voice or text), and you fill in the template. The user should never have to manually edit bracket placeholders.

## Arguments
- **$ARGUMENTS**: Task title and/or description (can be rough — you'll refine it)
- Flags: `--priority <critical|high|medium|low>`, `--project <name>`

## Conversational Flow

### Phase 1: Quick Setup (use AskUserQuestion)

Ask these together in a single AskUserQuestion call:

1. **Project** — Which project is this for? (if not provided and can't be auto-detected)
2. **Priority** — How urgent? Options: Critical, High, Medium (default), Low
3. **Type** — What kind of work? Options: Feature, Bug fix, Refactor, Research

### Phase 2: Details (conversational — just ask, let them talk)

Based on the title/description the user already gave, ask follow-up questions naturally. Don't ask all at once — be conversational:

- "What's the goal? What should be true when this is done?" (becomes Acceptance Criteria)
- "Any technical constraints or approaches you're already thinking about?" (becomes Implementation Notes)
- "Any files you know are involved?" (becomes Related Files)

**Important:** If the user gives short answers, that's fine. Don't push for detail they don't have. A task with just a title and priority is perfectly valid.

### Phase 3: Create and Fill

1. Run `~/.claude/generators/new-task.sh` with the title, priority, and project flags
2. Read the created file
3. Replace all `[bracket placeholders]` with the user's actual answers
4. Write the updated file
5. Show a brief summary of what was created

## Example Conversation

```
User: /task Add email notifications for new leads

Claude: [AskUserQuestion: Priority? Type?]

User: High priority, it's a feature

Claude: Got it. What should happen when this is done — what does "email notifications working" look like?

User: Agents should get an email when a new lead comes in and when an amendment is submitted

Claude: Makes sense. Any thoughts on implementation — Resend, specific templates?

User: Yeah use Resend, we already have it set up with notifications@myapp.com

Claude: [Creates file, fills in all sections, shows summary]
```

## Notes
- Tasks are created in `<project>/workspace/tasks/`
- Filename: `YYYY-MM-DD-<slug>.md`
- If the user just wants a quick stub (e.g., "just log it, I'll fill it in later"), skip the interview and create with just the title
- If workspace doesn't exist, suggest running the generator first

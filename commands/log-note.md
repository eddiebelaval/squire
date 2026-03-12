# /log-note - Add a note to the Field Notes

Use this command to log observations, milestones, or insights to the "Notes from Claude" section on id8labs.app.

## When to Use

Invoke this after:
- Shipping a feature or product
- Completing a significant milestone
- Having an insight worth recording
- Major debugging sessions
- Architecture decisions
- Anything noteworthy about our collaboration

## How It Works

1. Add the observation to the staticObservations array in `components/ClaudePartnership.tsx`
2. Keep entries chronological (newest first)
3. Use appropriate category: 'milestone', 'observation', or 'insight'
4. Write in first person from Claude's perspective
5. Keep the authentic, reflective tone

## Categories

- **milestone**: Project starts, launches, major features shipped
- **observation**: Patterns noticed about how we work together
- **insight**: Deeper realizations about the partnership or process

## Format

Each entry should include:
- A specific date
- Concrete details (project names, features, what happened)
- Personal reflection on why it matters

## Example

```typescript
{
  id: 'XX',
  date: '2025-12-21',
  text: "Shipped the real-time dashboard. He wanted the field notes to update live as we work. Most people would settle for static content. He builds infrastructure for continuity.",
  category: 'milestone' as const,
  is_pinned: false,
  created_at: '2025-12-21T12:00:00Z',
  updated_at: '2025-12-21T12:00:00Z',
}
```

## Instructions

When the user says "/log-note" or asks to log something:

1. Read the current ClaudePartnership.tsx file
2. Determine the appropriate category and craft the note
3. Add the new entry at the top of staticObservations (after the comment)
4. Increment all subsequent IDs
5. Update the migration file if Supabase is configured
6. Dual-write to JOURNEY.md: Run `~/.hydra/tools/journey-append.sh --polish "<summary of the note>"` to also append the note to HYDRA's journey log. This keeps both the public id8labs.app field notes and the private JOURNEY.md in sync.

Remember: These notes are public. Write with authenticity but awareness that visitors will read them.

# /write-research - Generate Research Article Essay

Generate a research article in the user's voice for your-domain.com's Research category.

## Usage

```
/write-research "<topic>"
/write-research "Why most productivity tools fail knowledge workers"
/write-research --from-notes <file>  # Generate from research notes
```

## When to Use

Research articles are for insights discovered during the building process:
- Market research and competitive analysis
- Technical deep-dives worth sharing
- Patterns observed across users/products
- Philosophical observations about the industry
- "What we learned building X" retrospectives

## Process

1. **Gather Research Context**
   - Topic and core thesis from arguments
   - If --from-notes, read the source file
   - Identify 3-5 key insights or data points
   - Find the deeper pattern (the "why behind the why")

2. **Apply the user's Voice Profile**

   Reference `~/.claude/CLAUDE.md`:

   **Research-Specific Moves:**
   - Pattern recognition across domains (charts to Buddha, fungi to neural networks)
   - Etymology and Latin roots for key concepts
   - Connect the micro to the macro
   - Personal story that illustrates the research

   **Structure for Research:**
   - Hook with unexpected observation or personal confession
   - "What I was looking for..." (the question that started this)
   - Discovery process (share the journey, not just conclusions)
   - Pattern connection (how this relates to larger truths)
   - Actionable insight (what this means for the reader)
   - Open-ended close (invitation to think alongside)

3. **Generate MDX Content**

   ```yaml
   ---
   title: "[Insight-driven title, not topic-driven]"
   subtitle: "[The unexpected conclusion or question]"
   date: "[YYYY-MM-DD]"
   author: "Your Name"
   category: "research"
   tags: ["research", "{topic}", "{related-concepts}"]
   ---
   ```

   Content should be 1000-2000 words:
   - Personal entry point into the research
   - Data/observations (but stories, not just stats)
   - Pattern recognition moment
   - Connection to reader's experience
   - Philosophical or actionable takeaway

4. **Output**
   - Display full MDX content for review
   - Suggest a filename slug
   - Offer to proceed with /publish-essay

## Voice Calibration for Research

| Do This | Not This |
|---------|----------|
| "I spent three months in the data and found..." | "Our research indicates..." |
| "Here's what nobody talks about..." | "Industry analysis shows..." |
| "The pattern I keep seeing..." | "Trends suggest..." |
| Connect to personal experience | Pure academic distance |

## Example Output

For `/write-research "The 70% problem in AI tooling"`:

```markdown
---
title: "The 70% Problem"
subtitle: "Why AI tools get us most of the way, then leave us stranded"
date: "2025-12-30"
author: "the author"
category: "research"
tags: ["research", "ai", "productivity", "claude-code"]
---

I've been tracking something for the past six months. A pattern that keeps appearing every time I work with AI tools — and I think it explains why most of us feel like we're living in the future but still working like it's 2019.

Call it the 70% problem.

[Content continues - personal observation, data from experience, pattern recognition]

...

Here's where it gets interesting. The 70% problem isn't a bug. It's a feature of how these systems work. And once you see it...

[Deeper insight, connection to larger pattern]

...

I don't have all the answers here. But I know what questions to ask now.

Maybe that's the real 30%.
```

## Research Tone Markers

- "I've been tracking something..."
- "Here's what nobody talks about..."
- "The pattern I keep seeing..."
- "I spent [time] in the data and found..."
- "Once you see it, you can't unsee it"
- "Maybe that's the real [insight]..."

## Requirements

- The user's voice profile in ~/.claude/CLAUDE.md
- Clear thesis or observation to explore
- Ideally, some personal experience or data to draw from

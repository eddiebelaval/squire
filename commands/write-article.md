# /write-article - Write & Publish Article

You are helping Eddie write and publish an article to id8labs.app/writing. **This is a conversational process** — you interview Eddie about what was built, extract the narrative, write a draft, get approval, then publish.

## Arguments
- **$ARGUMENTS**: Topic or brief description of what to write about (can be rough)
- Flags: `--category <essay|research|release>`, `--draft` (don't publish, just save)

## Conversational Flow

### Phase 1: Understand the Story (use AskUserQuestion if needed)

1. **What happened?** — What did we build/discover/ship? (Often this is the work from the current or recent session)
2. **Category** — Essay (default), Research, or Release?
3. **Who's involved?** — Collaborators, inspirations, people to credit?

### Phase 2: Extract the Narrative (conversational)

Walk through these naturally. Eddie often speaks fast by voice — capture the essence:

1. **The trigger:** "What started this? A conversation, a problem, seeing someone else's work?"
2. **The insight:** "What was the aha moment? What did you realize was missing or possible?"
3. **The build:** "What did you build? Walk me through the key decisions and why."
4. **The surprise:** "What unexpected thing happened during the build? What delighted you?"
5. **The takeaway:** "What's the lesson for other builders? What would you tell someone starting this?"

**Important:** Eddie's writing voice is:
- First person, casual, builder energy
- "Ship fast, iterate faster" mentality
- Credits collaborators generously
- Uses concrete examples over abstract theory
- Shows the messy reality, not polished perfection
- Technical but accessible — explain the WHY, not just the WHAT
- Ends with what's next — always building toward something

### Phase 3: Write the Draft

1. Write a complete article draft in Eddie's voice
2. Include:
   - A compelling title (short, punchy, specific)
   - A subtitle that previews the journey
   - Clear section headers that tell the story arc
   - Code snippets or terminal output where relevant
   - Architecture diagrams using markdown (``` blocks)
   - A "What's Next" section at the end
3. Aim for 1500-3000 words (meaty but not bloated)
4. Show the draft to Eddie for review

### Phase 4: Revise & Publish

1. Incorporate Eddie's feedback
2. Create the MDX file with proper frontmatter:

```mdx
---
title: "Article Title"
subtitle: "Subtitle for preview"
date: "YYYY-MM-DD"
category: "essay"
tags: ["relevant", "tags"]
featured: false
---
```

3. Save to: `/Users/eddiebelaval/Development/id8/id8labs/content/essays/<slug>.mdx`
4. Unless `--draft` flag was used, commit and push:
   - `cd /Users/eddiebelaval/Development/id8/id8labs`
   - `git add content/essays/<slug>.mdx`
   - `git commit -m "essay: <title>"`
   - Confirm with Eddie before pushing to main (auto-deploys to Vercel)
5. Report the URL: `id8labs.app/writing/<slug>`

## Example Conversation

```
User: /write-article What we just built with the workspace system

Claude: Love it. Let me get the story. What kicked this off — was it a specific moment?

User: Yeah my friend Shah showed me his project structure with templates and generators and I realized I had all this execution power but no input structure

Claude: That's a great hook. Who else should we credit?

User: Just Shah, he inspired the idea. And the factory.ai team for the design language.

Claude: [Writes draft with narrative arc: trigger → insight → build → surprise → takeaway]

User: This is great but can you add more about the /visualize moment?

Claude: [Revises, shows updated draft]

User: Perfect, ship it

Claude: [Creates MDX, commits, confirms push]
```

## Notes
- Articles go in `/Users/eddiebelaval/Development/id8/id8labs/content/essays/`
- Format: MDX with YAML frontmatter
- Slug becomes the URL: `id8labs.app/writing/<slug>`
- Vercel auto-deploys from main branch
- Read time is auto-calculated (~200 words/min)
- If Eddie says "just log it" or "save as draft", save but don't push
- Pull from session context — you often have all the details from what was just built
- Reference MEMORY.md and recent session work for accurate technical details

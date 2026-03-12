# /write-release - Generate Release Announcement Essay

Generate a release announcement essay in Eddie's voice for id8labs.app.

## Usage

```
/write-release <version> "<features summary>"
/write-release v1.2.0 "New dashboard with real-time metrics"
/write-release --context  # Use recent git commits for context
```

## Process

1. **Gather Context**
   - Version number and features from arguments
   - If --context flag, read recent commits from the project
   - Check for existing release notes or changelog
   - Identify the "why" behind the release (not just "what")

2. **Apply Eddie's Voice Profile**

   Reference `~/.claude/CLAUDE.md` for voice guidelines:

   **Structure Pattern:**
   - Visceral opening (sound, confession, unexpected entry)
   - Personal context (where we've been, what shaped this)
   - Observation/Pattern (what we're seeing)
   - Universal connection (your story is everyone's story)
   - Call to collective action (invitation to join)
   - Warm direct close (love, gratitude, solidarity)

   **Signature Moves:**
   - Open unexpected (something visceral or pattern-breaking)
   - Hardship as credentials ("This last year has done work on my outlook...")
   - Rhetorical questions that build
   - Movement from I to We
   - Direct loving address at the end

3. **Generate MDX Content**

   ```yaml
   ---
   title: "[Compelling title - not just version number]"
   subtitle: "[Supporting tagline that expands on value]"
   date: "[YYYY-MM-DD]"
   author: "Eddie Belaval"
   category: "release"
   tags: ["release", "v{version}", "{product}"]
   featured: true
   ---
   ```

   Content should be 800-1500 words covering:
   - The problem we were solving (personal story)
   - What we built and why it matters (features as benefits)
   - How it connects to larger mission (pattern recognition)
   - Invitation to try it / join the journey

4. **Output**
   - Display full MDX content for review
   - Suggest a filename slug (kebab-case)
   - Offer to proceed with /publish-essay

## Voice Calibration

| Do This | Not This |
|---------|----------|
| "I'll be honest — I came to this broken..." | "We're excited to announce..." |
| "Here's the thing about [insight]..." | "This feature enables..." |
| "Is there anyone else who feels this?" | "Users will benefit from..." |
| Raw but intentional | Corporate PR speak |

## Example Output

For `/write-release v1.2.0 "New signal-based dashboard"`:

```markdown
---
title: "Building the Dashboard I Needed"
subtitle: "v1.2.0 brings signal-based metrics to ID8Labs"
date: "2025-12-30"
author: "Eddie Belaval"
category: "release"
tags: ["release", "v1.2.0", "milo", "dashboard"]
featured: true
---

(Loud ape sounds)

I'll be honest — I've been staring at dashboards my whole career. The kind that show you 47 metrics, none of which tell you if you're actually winning.

Last month I found myself refreshing analytics at 2am, looking for... something. A signal in the noise. A reason to believe what we're building matters.

Here's the thing about metrics...

[Content continues in Eddie's voice - 800-1500 words]

...

I don't know about you, but I'm done with dashboards that make me feel less informed, not more.

This is what we built. Come see it.

I love each and every one of you.
```

## Phrases Bank (Use Naturally)

- "I'll be honest..."
- "Here's the thing about..."
- "I don't know about you but..."
- "What I found here is not only [X] but [deeper X]"
- "This thought brings me to tears"
- "Wake up to this and the rest will flow effortlessly"
- "We are one."

## Requirements

- Eddie's voice profile in ~/.claude/CLAUDE.md
- Context about what was shipped (version, features, or git history)

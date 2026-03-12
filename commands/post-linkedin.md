# /post-linkedin - Post to LinkedIn for ID8Labs

Post content to Eddie's LinkedIn profile using Playwright browser automation.

## Usage

```
/post-linkedin [content]
/post-linkedin --from-essay <url>  # Generate from essay URL
/post-linkedin --draft             # Review before posting
```

## Process

1. **Prepare Content**
   - If content provided directly, use it
   - If --from-essay, fetch essay and adapt for LinkedIn
   - LinkedIn posts should be 1300-3000 characters (long-form performs well)

2. **LinkedIn Format Optimization**

   **Structure that works:**
   - Strong hook (first 3 lines visible before "see more")
   - Line breaks between paragraphs
   - Use emoji sparingly (1-3 per post)
   - Call-to-action or question at the end
   - No hashtags in text (comment with hashtags after)

3. **Pre-Flight Check**
   - Verify Comet browser is running with debugging
   - Confirm logged into LinkedIn as Eddie Belaval
   - Display content for confirmation

4. **Post via Playwright**
   ```
   Navigate to: linkedin.com/feed
   Click: "Start a post" button
   Type content (preserve line breaks)
   Click: "Post" button
   Capture screenshot as confirmation
   ```

5. **Post-Publish**
   - Add hashtags in first comment
   - Capture post URL
   - Log for analytics tracking

## LinkedIn vs X Differences

| Aspect | LinkedIn | X/Twitter |
|--------|----------|-----------|
| Length | 1300-3000 chars | 280 chars (or threads) |
| Tone | Professional but personal | Casual, punchy |
| Hashtags | In comments, 3-5 | In post, 0-2 |
| Links | OK in post | Penalized, put in reply |
| Format | Long-form storytelling | Hooks and one-liners |

## Voice Adaptation for LinkedIn

Eddie's voice on LinkedIn is:
- Still authentic and personal
- More polished, less parenthetical
- Professional credibility woven in
- Lessons and frameworks emphasized
- Community-building language

**Transform:**
- "(Loud ape sounds)" → [omit or professional equivalent]
- "jacked to the tits" → "deeply excited about"
- Short punchy lines → Developed paragraphs

## Example: From Essay to LinkedIn

**Essay opening:**
> I'll be honest — I've been staring at dashboards my whole career. The kind that show you 47 metrics, none of which tell you if you're actually winning.

**LinkedIn version:**
> I've spent 15 years staring at dashboards.
>
> You know the kind - 47 metrics, beautifully visualized, none of which tell you if you're actually winning.
>
> Last month I hit a breaking point. 2am. Refreshing analytics. Looking for... something. A signal in the noise.
>
> So we built something different.
>
> Here's what I learned about what metrics actually matter...

## Posting Flow

```
/post-linkedin --from-essay https://id8labs.app/essays/the-70-percent-problem
```

**Output:**
```
Generating LinkedIn post from essay...

Preview:
---
I've been tracking something for the past six months.

A pattern that keeps appearing every time I work with AI tools.

I call it the 70% problem.

[Content preview...]
---

Character count: 2,847
Format: Long-form (optimal for LinkedIn)
Ready to post? [Proceed with Playwright]
```

## Hashtag Strategy

Add to first comment (not in post):
- #AItools (specific)
- #ProductBuilding (industry)
- #EddieBuildingInPublic (personal brand)
- #ID8Labs (company)

## Requirements

- Comet browser running with remote debugging
- Logged into LinkedIn as Eddie Belaval
- Playwright MCP connected

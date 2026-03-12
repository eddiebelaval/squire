# /publish-essay - Publish Essay to id8labs.app

Create MDX file, commit to id8labs-hub repo, and trigger Vercel deploy.

## Usage

```
/publish-essay "<title>" --content <mdx-content>
/publish-essay --from-file <path>  # Publish from existing MDX file
/publish-essay --slug custom-slug  # Override auto-generated slug
```

## Process

1. **Validate Content**
   - Ensure frontmatter is complete (title, date, category required)
   - Verify content is in proper MDX format
   - Check that category is one of: essay, research, release
   - Generate slug from title if not provided (kebab-case)

2. **Create MDX File**
   - Location: `/Users/eddiebelaval/Development/id8labs-hub/core/content/essays/`
   - Filename: `{slug}.mdx`
   - Add/verify all required frontmatter fields

3. **Git Operations**
   ```bash
   cd /Users/eddiebelaval/Development/id8labs-hub
   git checkout main
   git pull origin main
   git add core/content/essays/{slug}.mdx
   git commit -m "content: add essay - {title}"
   git push origin main
   ```

4. **Trigger Deploy**
   - Push to main triggers Vercel auto-deploy
   - Monitor deploy status with `vercel inspect`
   - Wait for production deploy completion

5. **Return Essay URL**
   - Format: `https://id8labs.app/essays/{slug}`
   - Verify URL is accessible (may take 1-2 minutes)

## MDX Frontmatter Reference

```yaml
---
title: "Required - Essay title"
subtitle: "Optional - Supporting tagline"
date: "YYYY-MM-DD"              # Required
author: "Eddie Belaval"          # Optional, defaults to Eddie
category: "essay|research|release"  # Required
tags: ["tag1", "tag2"]           # Optional
featured: true|false             # Optional
heroImage: "/path/to/image.webp" # Optional
---
```

## Content Guidelines

- Use standard Markdown syntax
- Code blocks with language identifiers
- No JSX components (pure Markdown)
- Images should be in /public/ or external URLs
- Estimated read time calculated automatically (~200 wpm)

## Example

```
/publish-essay "The 70% Problem" --content "---
title: \"The 70% Problem\"
subtitle: \"Why AI tools get us most of the way, then leave us stranded\"
date: \"2025-12-30\"
author: \"Eddie Belaval\"
category: \"research\"
tags: [\"research\", \"ai\", \"productivity\"]
---

I've been tracking something for the past six months...

[Full essay content]
"
```

## Output

```
Publishing essay to id8labs.app...

File created: core/content/essays/the-70-percent-problem.mdx
Commit: abc123 "content: add essay - The 70% Problem"
Deploy triggered on Vercel

Essay URL: https://id8labs.app/essays/the-70-percent-problem

Deploy status: Production (ready in ~60 seconds)
```

## Error Handling

| Error | Resolution |
|-------|------------|
| Missing frontmatter | Prompt for required fields |
| Invalid category | Must be essay, research, or release |
| Slug conflict | Suggest alternative slug or overwrite |
| Git conflict | Pull latest and retry |
| Deploy failed | Check Vercel dashboard |

## Requirements

- Git access to id8labs-hub repo
- Main branch must be clean (no uncommitted changes)
- Vercel project linked for deploy status

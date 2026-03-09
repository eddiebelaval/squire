---
title: "[Feature Name]"
date: [YYYY-MM-DD]
author: [Name]
status: Draft | In Review | Approved | In Progress | Shipped
priority: Critical | High | Medium | Low
---

# Feature: [Feature Name]

## Overview

[1-3 sentences describing what this feature does and why it matters.]

## Problem Statement

[What problem does this solve? Who is affected? What happens if we don't build this?]

## Proposed Solution

[High-level description of the solution. Keep it concise -- details go in Technical Design.]

## User Stories

- As a [user type], I want to [action] so that [benefit].

## Technical Design

### Architecture

[How does this fit into the existing system? Diagram or description of data flow.]

### API Changes

| Method | Path | Description |
|--------|------|-------------|
| [GET/POST/PATCH/DELETE] | `/api/[path]` | [What it does] |

### Database Changes

| Table | Column | Type | Notes |
|-------|--------|------|-------|
| [table_name] | [column_name] | [type] | [nullable, default, etc.] |

**Migration required:** Yes | No

### UI/UX

[Describe the user-facing changes. Reference wireframes or mockups if available.]

### Files to Create/Modify

| File | Action | Description |
|------|--------|-------------|
| `[path/to/file]` | Create / Modify | [What changes] |

## Testing Strategy

- [ ] Unit tests for [core logic]
- [ ] Integration tests for [API endpoints]
- [ ] E2E tests for [critical user flows]
- [ ] Manual testing for [edge cases or visual verification]

## Rollout Plan

1. [ ] Merge to feature branch
2. [ ] Deploy to preview/staging
3. [ ] QA verification
4. [ ] Merge to main
5. [ ] Production deploy
6. [ ] Smoke test production

## Open Questions

- [ ] [Question that needs answering before or during implementation]

## Alternatives Considered

| Approach | Pros | Cons | Why Not |
|----------|------|------|---------|
| [Alternative 1] | [pros] | [cons] | [reason rejected] |

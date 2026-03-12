# Mobile Readiness Check

You are invoking the **mobile-check** skill - comprehensive mobile viewport verification using Playwright MCP.

Load and follow the skill at: `.claude/skills/mobile-check/SKILL.md`

## Mode Selection

Parse $ARGUMENTS to determine mode:
- Empty → Full mobile audit of all detected pages (cap at 10)
- URL/route → Check that specific page (e.g., "/dashboard", "/login")
- Multiple routes → Check each listed route
- "extreme" → Also test at 320px (iPhone SE 1st gen) after 375px pass
- "tablet" → Also check at 768px (iPad Mini)

## Quick Reference

### Setup
```
1. Detect dev server (localhost:3000, 3001, 8080)
2. If not running, start it
3. browser_resize({ width: 375, height: 667 })
```

### Per-Page Audit Sequence
```
1. browser_navigate to page
2. browser_snapshot for accessibility tree
3. browser_evaluate — run horizontal overflow check
4. browser_evaluate — run touch target check
5. browser_evaluate — run text size check
6. browser_evaluate — run viewport meta check
7. browser_evaluate — run fixed/sticky element check
8. browser_evaluate — run input type check (if forms present)
9. browser_console_messages — check for errors
10. browser_network_requests — check for failures
11. browser_take_screenshot — save visual proof
```

### Key Thresholds
- Viewport: 375x667 (iPhone mini/SE) — the floor
- Touch targets: minimum 44x44px (Apple HIG)
- Text: minimum 12px rendered
- Inputs: minimum 44px height, proper type attributes

## Arguments
$ARGUMENTS

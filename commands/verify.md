# Verify Application

You are invoking the **verify** skill - comprehensive verification following Boris Cherny's pattern.

Load and follow the skill at: `.claude/skills/verify/SKILL.md`

## Mode Selection

Parse $ARGUMENTS to determine mode:
- Empty or "all" → Full verification (all 6 layers)
- "quick" → Static analysis only (Layer 1)
- "visual" → Browser verification only (Layer 5)
- "test" or "tests" → Unit + E2E tests (Layers 2-4)
- "build" → Build verification only (Layer 6)
- Anything else → Treat as component/feature name to focus on

## Quick Reference

### Full Verify
```bash
# Layer 1
npm run type-check && npm run lint

# Layer 2
npm test

# Layer 3 (if playwright exists)
npx playwright test

# Layer 4 (using Playwright MCP)
# Navigate, snapshot, screenshot, check console

# Layer 5
npm run build
```

### Visual Verify Sequence
1. `browser_navigate` to localhost:3000
2. `browser_snapshot` to see page structure
3. `browser_console_messages` to check for errors
4. `browser_take_screenshot` for visual record
5. Repeat for key pages

## Arguments
$ARGUMENTS

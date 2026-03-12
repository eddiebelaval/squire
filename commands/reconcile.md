# /reconcile - Reconcile the Triangle (VISION + SPEC + BUILDING)

You are invoking the **reconcile** skill — the living document maintenance system for the three-document triangle.

Load and follow the skill at: `.claude/skills/reconcile/SKILL.md`

## Mode Selection

Parse $ARGUMENTS to determine mode:
- Empty → Full reconcile (scan drift, ask questions, update both docs)
- "scan" → Drift scan only (detect gaps between VISION/SPEC/codebase, report but don't edit)
- "vision" → Update VISION.md only (evolution — what shifted and why)
- "spec" → Update SPEC.md only (reconcile with current codebase reality)
- "init" → Initialize triangle for a project that doesn't have VISION.md + SPEC.md yet
- "--project <name>" → Target a specific project (homer, parallax, rune, etc.)

## Examples

```
/reconcile                          # Full reconcile for current project
/reconcile scan                     # Just show me the drift
/reconcile vision                   # I learned something — update the north star
/reconcile spec                     # Something shipped — update the contract
/reconcile init --project homer     # Create VISION.md + SPEC.md for Homer
/reconcile scan --project parallax  # Scan Parallax for drift
```

## Arguments
$ARGUMENTS

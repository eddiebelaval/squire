# /reconcile - Reconcile the Triad (VISION + SPEC + BUILDING)

You are invoking the **reconcile** skill -- the living document maintenance system for the three-document Triad.

Load and follow the skill at: `.claude/skills/reconcile/SKILL.md`

## Mode Selection

Parse $ARGUMENTS to determine mode:
- Empty -> Full reconcile (scan drift, ask questions, update both docs)
- "scan" -> Drift scan only (detect gaps between VISION/SPEC/codebase, report but don't edit)
- "vision" -> Update VISION.md only (evolution -- what shifted and why)
- "spec" -> Update SPEC.md only (reconcile with current codebase reality)
- "init" -> Initialize Triad for a project that doesn't have VISION.md + SPEC.md yet

## Examples

```
/reconcile                    # Full reconcile for current project
/reconcile scan               # Just show me the drift
/reconcile vision             # I learned something -- update the north star
/reconcile spec               # Something shipped -- update the contract
/reconcile init               # Create VISION.md + SPEC.md for this project
```

## Arguments
$ARGUMENTS

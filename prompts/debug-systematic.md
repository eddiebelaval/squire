# Systematic Debugging -- Thinking Framework

Apply this framework when encountering a bug. Resist the urge to guess-and-fix. Follow the steps in order.

## 1. Reproduce

Before anything else, make the bug happen reliably:
- What are the exact steps to trigger it? (not "sometimes it breaks" -- nail down the sequence)
- What environment does it occur in? (browser, OS, Node version, staging vs production)
- Is it deterministic or intermittent? If intermittent, what is the frequency?
- What is the expected behavior vs actual behavior?
- Can you write a failing test that captures the bug?

If you cannot reproduce it, you are not ready to fix it. Gather more information.

## 2. Isolate

Narrow the scope systematically:
- Which layer is the bug in? (UI rendering, state management, API, database, infrastructure)
- Can you reproduce it with a minimal input? Strip away unrelated complexity.
- Does it occur with fresh data, or only with specific data shapes?
- Binary search the codebase: disable half the code path and see if the bug persists.
- Check the most recent changes: did this work before? If so, what changed?

The goal is to identify the smallest code region that contains the fault.

## 3. Hypothesize

Generate three candidate root causes, ranked by probability:

For each hypothesis:
- State the specific mechanism (not "something is wrong with X" but "X returns null when Y is empty because Z does not handle that case")
- Explain why this would produce the observed symptoms
- Identify what evidence would confirm or refute it

Resist anchoring on your first idea. The most obvious hypothesis is often wrong.

## 4. Test

For each hypothesis, design a minimal experiment:
- Add targeted logging or breakpoints at the suspected fault location
- Modify one variable at a time to confirm causation, not just correlation
- Check: does removing the suspected cause remove the symptom?
- Check: does introducing the suspected cause reproduce the symptom?

Move through hypotheses in order of probability. Stop when one is confirmed.

## 5. Fix

Apply the minimal change that addresses the root cause:
- Does this fix address WHY the bug happens, not just suppress the symptom?
- Are you fixing the actual fault, or adding a workaround upstream/downstream?
- Does the fix introduce new edge cases or change behavior for other inputs?
- Is the fix in the right layer? (Fix validation bugs in validation, not in rendering)

Write a test that fails before the fix and passes after.

## 6. Verify

Confirm the fix thoroughly:
- Does the original reproduction scenario now work correctly?
- Do all existing tests still pass?
- Test adjacent scenarios: could the same class of bug exist in similar code paths?
- Check that the fix does not regress performance, error handling, or UX

## 7. Prevent

Close the loop so this class of bug cannot recur:
- Should there be a lint rule, type constraint, or runtime check?
- Is there a missing test category (edge cases, error paths, concurrent access)?
- Does the codebase have similar patterns that are vulnerable to the same fault?
- Should documentation or comments clarify the non-obvious constraint?

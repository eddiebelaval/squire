# Code Review -- Thinking Framework

Apply this framework to review code changes systematically before approval.

## 1. Architecture Alignment

Consider the existing codebase patterns. Does this change:
- Follow established conventions for file structure, naming, and module boundaries?
- Introduce a new pattern where an existing one already handles this case?
- Respect the dependency direction (e.g., UI -> services -> data, not the reverse)?
- Belong in the layer where it was placed, or should it live elsewhere?

## 2. Security Surface

Walk the data flow from input to output. At each boundary, check:
- Input validation: Are all user-supplied values sanitized before use?
- Authentication: Does this endpoint/page verify identity correctly?
- Authorization: Does it check that the authenticated user has permission for THIS resource (not just any resource)?
- Injection vectors: Could any input reach SQL, shell commands, HTML rendering, or eval?
- Secrets: Are API keys, tokens, or credentials exposed in client code, logs, or error messages?
- CSRF/XSS: Are state-changing operations protected? Is output properly escaped?

## 3. Performance Implications

Trace the hot paths this code introduces or modifies:
- Database: Are there N+1 queries, missing indexes, or unbounded result sets?
- Rendering: Does this cause unnecessary re-renders, layout thrashing, or force reflow?
- Bundle size: Are large dependencies imported for small features? Could they be lazy-loaded?
- Network: Are there waterfalls (sequential requests that could be parallel)?
- Memory: Are there retained references, growing arrays, or unclosed resources?

## 4. Error Handling

For each operation that can fail, verify:
- Is the failure caught and handled at the right level?
- Does the user see a helpful message, not a stack trace or cryptic code?
- Does the system degrade gracefully, or does one failure cascade?
- Are errors logged with enough context to debug (but without leaking sensitive data)?
- Are retryable errors distinguished from permanent failures?

## 5. Test Coverage Gaps

Identify what is NOT tested:
- Happy path covered, but what about empty inputs, null values, boundary conditions?
- Are error paths tested (network failure, invalid data, permission denied)?
- Are integration points mocked at the right level?
- Would a mutation to the core logic be caught by existing tests?

## 6. Naming and Readability

Read the code as if encountering it for the first time:
- Do function and variable names reveal intent without needing comments?
- Are there magic numbers or strings that should be named constants?
- Is the control flow straightforward, or does it require mental gymnastics to follow?
- Could any complex block be extracted into a well-named function?

## 7. Breaking Changes

Assess the blast radius:
- Does this change any public API surface (function signatures, REST endpoints, event shapes)?
- Are there other consumers of the modified code (other services, packages, or teams)?
- Does this require a database migration, and is it backward-compatible?
- Will existing clients/callers continue to work without modification?

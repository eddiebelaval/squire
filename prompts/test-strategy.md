# Test Strategy -- Thinking Framework

Apply this framework to plan test coverage for a feature, module, or system.

## 1. Critical Paths

Identify what MUST work -- the paths where failure means user-visible breakage or data corruption:
- What is the primary user flow this code serves?
- What operations involve money, authentication, or data persistence?
- What would cause a support ticket or customer churn if it broke?
- Rank critical paths by severity: data loss > security breach > broken flow > degraded experience

These paths get the most thorough coverage. Every critical path needs at least one happy-path and one failure-path test.

## 2. Edge Cases

For each input and state, consider the boundaries:
- **Empty/zero:** Empty string, empty array, zero, null, undefined
- **Boundary values:** Off-by-one (0, 1, max-1, max, max+1), date boundaries (midnight, DST, leap year)
- **Shape variations:** Missing optional fields, extra unexpected fields, nested nulls
- **Concurrent access:** Two users editing the same resource, rapid duplicate submissions
- **Unicode and encoding:** Multi-byte characters, emoji, RTL text, extremely long strings
- **State transitions:** What happens if the operation is called twice? Out of expected order?

Not every edge case needs a test. Prioritize by: likelihood of occurrence x severity of failure.

## 3. Integration Points

Every boundary where your code talks to something external needs coverage:
- **Database:** Do queries return expected results? Do writes persist correctly? What about connection failures?
- **External APIs:** What happens on timeout, 4xx, 5xx, malformed response, rate limiting?
- **Authentication/Authorization:** Does the right user get the right access? Are tokens validated and refreshed?
- **File system:** Permissions, missing directories, disk full, concurrent writes
- **Message queues/events:** Message ordering, duplicate delivery, deserialization failures

Decide the mocking boundary: mock external services, but test your integration code against realistic responses.

## 4. Test Pyramid Balance

Evaluate the current and target distribution:
- **Unit tests (base):** Fast, isolated, cover logic branches. Target: individual functions, utilities, transformations.
- **Integration tests (middle):** Verify components work together. Target: API routes with database, multi-service workflows.
- **E2E tests (top):** Verify complete user flows. Target: critical paths only -- these are slow and brittle.

Common anti-patterns to avoid:
- Ice cream cone: mostly E2E, few unit tests (slow, flaky CI)
- Missing middle: unit + E2E but no integration tests (bugs hide at boundaries)
- Overtesting internals: testing private methods or implementation details (brittle on refactor)

## 5. Test Data Strategy

Define how test data is created and managed:
- **Factories/builders:** Generate valid test objects with sensible defaults, overridable per-test
- **Fixtures:** Static data files for deterministic scenarios (API response snapshots, seed data)
- **Database seeding:** Minimal seed data for integration tests; reset between tests
- **Isolation:** Each test creates its own data and cleans up. No shared mutable state between tests.
- **Production-like:** Are test data shapes representative of real data? Include edge cases in seed data.

## 6. CI Integration

Define when and how tests run:
- **Pre-commit:** Lint + type-check (fast, catches syntax and type errors)
- **Pre-push / PR:** Full unit + integration suite (catches logic and boundary errors)
- **Nightly:** Full E2E suite, performance benchmarks, dependency audit
- **On deploy:** Smoke tests against staging/production (catches environment-specific issues)

Set expectations: what is the acceptable CI run time? What is the flakiness budget? Who owns fixing broken tests?

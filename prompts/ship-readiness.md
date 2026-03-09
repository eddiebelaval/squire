# Ship Readiness -- Thinking Framework

Apply this framework before deploying to production. Every section is a go/no-go gate.

## 1. Feature Completeness

Verify against the original requirements:
- List every acceptance criterion. Is each one met? Mark explicitly: DONE / PARTIAL / MISSING.
- Are there any "TODO" or "FIXME" comments in the shipped code? Are they acceptable or blocking?
- Has scope been cut? If so, are the remaining items tracked and communicated?
- Does the feature work end-to-end as a user would experience it, not just in isolated pieces?

Partial features are worse than missing features. If it is not complete, either finish it or remove it.

## 2. Test Results

Verify the test suite:
- Do all existing tests pass? (zero tolerance for regressions)
- Were new tests written for new functionality? What is the coverage of the changed code?
- Are there flaky tests? If so, are they quarantined and tracked, not ignored?
- Were edge cases and error paths tested, not just happy paths?
- For UI changes: was manual testing performed on target browsers/devices?

## 3. Performance Baseline

Verify the feature performs within acceptable limits:
- Has the feature been tested under realistic data volume?
- Are response times within the established SLA (page load, API latency)?
- Does the feature introduce new database queries? Are they optimized (indexes, pagination)?
- For client-side changes: what is the bundle size impact? Are new dependencies justified?
- Under load: does the feature degrade gracefully or crash?

## 4. Security Review

Verify security properties:
- Are all user inputs validated and sanitized?
- Are authentication and authorization checks in place for every new endpoint?
- Are there no hardcoded secrets, API keys, or credentials in the codebase?
- Have dependencies been audited for known vulnerabilities?
- For data changes: is PII handled correctly (encryption, access control, retention)?

## 5. Documentation

Verify that knowledge is captured:
- Are API changes documented (new endpoints, changed request/response shapes)?
- Is there a changelog entry or release note?
- For user-facing changes: are help docs or in-app guidance updated?
- For internal changes: do other developers know what changed and why?

## 6. Deployment Plan

Verify the deployment is safe and reversible:
- Does this require a database migration? Is it backward-compatible with the current code?
- Is the migration tested and reversible?
- Are feature flags needed? If so, are they configured for gradual rollout?
- What is the rollback procedure? How long does rollback take?

## 7. Monitoring

Verify you will know if something breaks:
- Are error tracking and alerting configured for the new feature?
- Are key metrics dashboarded (response time, error rate, throughput)?
- Can you distinguish between a feature bug and an infrastructure issue?

## 8. Communication

Verify stakeholders are informed:
- Has the release been communicated to the team?
- For user-facing changes: are release notes prepared?
- For breaking changes: are affected consumers notified with migration guidance?

## Go / No-Go Decision

Review each section. A single MISSING in sections 1-4 (completeness, tests, performance, security) is a NO-GO. Sections 5-8 (docs, deployment, monitoring, communication) should be addressed but are lower risk. State the decision explicitly and document any accepted risks.

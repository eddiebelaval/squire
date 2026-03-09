# Security Audit -- Thinking Framework

Apply this framework to evaluate the security posture of a feature, service, or system.

## 1. Attack Surface Mapping

Enumerate every entry point an attacker could reach:
- **User inputs:** Forms, URL parameters, query strings, headers, file uploads, WebSocket messages
- **API endpoints:** List every route. Which are public, which require auth, which accept writes?
- **Authentication boundaries:** Where does auth happen? What is trusted vs untrusted on each side?
- **Third-party integrations:** Webhooks, OAuth callbacks, external API calls -- what data do they send/receive?
- **Infrastructure:** Exposed ports, public S3 buckets, debug endpoints, admin panels

For each entry point: what data comes in, how is it validated, and where does it go?

## 2. STRIDE Analysis

For each critical component, walk through the six threat categories:

- **Spoofing:** Can an attacker impersonate another user or system? Are tokens, sessions, and API keys properly validated?
- **Tampering:** Can an attacker modify data in transit or at rest? Are writes protected by auth checks? Is data integrity verified (checksums, signatures)?
- **Repudiation:** Can actions be traced to their actor? Are audit logs present for sensitive operations (payments, permission changes, data deletion)?
- **Information Disclosure:** Can an attacker access data they should not see? Are error messages, logs, or API responses leaking internal details?
- **Denial of Service:** Can an attacker exhaust resources? Are there rate limits, request size limits, timeout enforcement?
- **Elevation of Privilege:** Can a regular user access admin functions? Are role checks enforced at the API level (not just the UI)?

## 3. Authentication Review

Evaluate the identity verification layer:
- How are credentials stored? (bcrypt/argon2 for passwords, secure storage for tokens)
- Are sessions invalidated on logout, password change, and after inactivity?
- Is multi-factor authentication available for sensitive operations?
- Are password reset flows secure? (time-limited tokens, no user enumeration)
- Are JWTs validated completely? (signature, expiration, issuer, audience)
- Are API keys rotatable? Is there a revocation mechanism?

## 4. Authorization Review

Evaluate access control at every data boundary:
- Is access checked on the server for every request, not just in the UI?
- Are there IDOR (Insecure Direct Object Reference) vulnerabilities? (Can user A access user B's data by changing an ID?)
- Is the principle of least privilege applied? (Do service accounts have only the permissions they need?)
- Are role/permission checks at the resource level, not just the route level?
- For multi-tenant systems: is tenant isolation enforced at the data layer?

## 5. Data Protection

Evaluate how sensitive data is handled:
- **In transit:** Is TLS enforced? Are there mixed-content issues? Are secure cookie flags set (HttpOnly, Secure, SameSite)?
- **At rest:** Is PII encrypted? Are database backups encrypted? Are logs scrubbed of sensitive data?
- **In code:** Are secrets hardcoded? Are they in environment variables or a secrets manager? Are they ever logged?
- **In the browser:** Is sensitive data stored in localStorage (accessible to XSS)? Are tokens in httpOnly cookies?
- **Retention:** Is there a data retention policy? Can users request deletion (GDPR/CCPA)?

## 6. Dependency Audit

Evaluate the supply chain:
- Run `npm audit` / `pip audit` / equivalent. Are there known vulnerabilities in dependencies?
- Are dependencies pinned to specific versions? Is there a lockfile?
- Are there unnecessary dependencies that increase attack surface?
- When was the last dependency update? Are security patches applied promptly?
- Are build tools and CI/CD pipelines secured? (compromised build = compromised output)

## 7. Remediation Priority

Rank findings and create an action plan:
1. **Critical:** Actively exploitable, data breach risk, auth bypass -- fix immediately
2. **High:** Exploitable with moderate effort, privilege escalation, injection vectors -- fix this sprint
3. **Medium:** Defense-in-depth gaps, missing rate limits, information disclosure -- fix this quarter
4. **Low:** Best practice improvements, hardening measures -- backlog

For each finding: describe the vulnerability, the attack scenario, the impact, and the specific fix.

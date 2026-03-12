# /appstore-review - Quick App Store Review Check

## Purpose
Run a quick App Store compliance check. Faster than full audit, focuses on most common rejection reasons.

## When to Use
- During development to check compliance
- Before running full `/appstore-readiness` audit
- Quick check after making changes
- When you want fast feedback

## Quick Check Areas

### 1. Privacy (Top Priority)
- [ ] Privacy manifest exists
- [ ] Privacy labels configured
- [ ] Privacy policy linked
- [ ] ATT implemented (if tracking)

### 2. Technical
- [ ] Using current Xcode/SDK
- [ ] No crashes in testing
- [ ] Reasonable performance

### 3. Metadata
- [ ] App name ≤30 characters
- [ ] Screenshots show app in use
- [ ] Support URL works

### 4. Monetization (if applicable)
- [ ] IAP used for digital goods
- [ ] Restore purchases implemented
- [ ] Subscription UI compliant

### 5. Content (if UGC)
- [ ] Filtering implemented
- [ ] Reporting available
- [ ] Blocking capability

## Output Format

```
┌─────────────────────────────────────────┐
│       QUICK REVIEW CHECK                │
├─────────────────────────────────────────┤
│ Privacy:        [✅ OK / ❌ Issues]     │
│ Technical:      [✅ OK / ❌ Issues]     │
│ Metadata:       [✅ OK / ❌ Issues]     │
│ Monetization:   [✅ OK / ❌ Issues / -] │
│ Content:        [✅ OK / ❌ Issues / -] │
├─────────────────────────────────────────┤
│ Quick Status: [LOOKS GOOD / ISSUES]     │
└─────────────────────────────────────────┘

ISSUES FOUND:
• [Issue description]

RECOMMENDATION:
Run full /appstore-readiness before submission
```

## Usage

```
/appstore-review
```

## When to Escalate to Full Audit

- Before actual submission
- At ID8Pipeline Stage 9
- After significant changes
- If quick check finds issues

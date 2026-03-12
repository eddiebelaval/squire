# /appstore-readiness - Full App Store Readiness Audit

## Purpose
Run a comprehensive App Store readiness audit before submission. This command invokes all specialized agents to ensure your iOS app is ready for first-submission approval.

## When to Use
- Before submitting a new app to the App Store
- Before submitting a major update
- At ID8Pipeline Stage 9 (Launch Prep) as a hard gate
- When you want a complete compliance check

## Workflow

### Phase 1: Technical Audit

**TECHNICAL Agent:**
1. Verify Xcode/SDK version compliance
2. Check device compatibility declarations
3. Review Info.plist for required keys
4. Validate build configuration
5. Check for deprecated APIs

**Output:** Technical readiness status with any blocking issues.

### Phase 2: Privacy Audit

**PRIVACY Agent:**
1. Scan for privacy manifest (PrivacyInfo.xcprivacy)
2. Verify all collected data types declared
3. Check required reason APIs are justified
4. Review third-party SDK privacy compliance
5. Validate ATT implementation (if tracking)
6. Cross-reference privacy labels

**Output:** Privacy compliance status with specific findings.

### Phase 3: Design Audit

**DESIGNER Agent:**
1. Review navigation patterns against HIG
2. Check touch target sizes
3. Verify Dynamic Type support
4. Assess Dark Mode implementation
5. Check accessibility compliance

**Output:** HIG compliance status with recommendations.

### Phase 4: Monetization Audit (if applicable)

**COMMERCE Agent:**
1. Determine if IAP is required
2. Review IAP implementation
3. Check subscription sign-up requirements
4. Verify pricing display
5. Confirm restore purchases functionality

**Output:** Monetization compliance status.

### Phase 5: Metadata Audit

**METADATA Agent:**
1. Review app name (≤30 chars, no keyword stuffing)
2. Audit screenshots (correct sizes, app in use)
3. Check description accuracy
4. Validate age rating
5. Confirm support URL accessibility

**Output:** Metadata readiness status with improvements.

### Phase 6: Review Simulation

**REVIEWER Agent:**
1. Simulate complete App Review process
2. Check all 5 guideline sections
3. Flag any violation patterns
4. Assess rejection probability
5. Generate fix priorities

**Output:** Overall approval probability and action items.

## Audit Report Format

```
┌─────────────────────────────────────────────────────┐
│            APP STORE READINESS AUDIT                │
├─────────────────────────────────────────────────────┤
│ App: [App Name]                                     │
│ Date: [Date]                                        │
│ Pipeline Stage: 9 - Launch Prep                     │
├─────────────────────────────────────────────────────┤
│ OVERALL STATUS: [READY / NOT READY]                 │
│ Approval Probability: [HIGH / MEDIUM / LOW]         │
└─────────────────────────────────────────────────────┘

TECHNICAL       [✅ PASS / ❌ FAIL / ⚠️ WARNINGS]
PRIVACY         [✅ PASS / ❌ FAIL / ⚠️ WARNINGS]
DESIGN          [✅ PASS / ❌ FAIL / ⚠️ WARNINGS]
MONETIZATION    [✅ PASS / ❌ FAIL / ⚠️ WARNINGS / N/A]
METADATA        [✅ PASS / ❌ FAIL / ⚠️ WARNINGS]
REVIEW SIM      [✅ PASS / ❌ FAIL / ⚠️ WARNINGS]

┌─────────────────────────────────────────────────────┐
│ BLOCKING ISSUES (Must Fix Before Submission)        │
├─────────────────────────────────────────────────────┤
│ [Issue] — Guideline X.X.X                           │
│ [Issue] — Guideline X.X.X                           │
└─────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────┐
│ WARNINGS (Should Fix)                               │
├─────────────────────────────────────────────────────┤
│ [Issue] — Guideline X.X.X                           │
└─────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────┐
│ RECOMMENDATIONS                                     │
├─────────────────────────────────────────────────────┤
│ [Suggestion for improvement]                        │
└─────────────────────────────────────────────────────┘

NEXT STEPS:
1. [Specific action to take]
2. [Specific action to take]
3. [Specific action to take]
```

## ID8Pipeline Integration

This audit is a **HARD GATE** at Stage 9 (Launch Prep).

**Passing Requirements:**
- No blocking issues
- Privacy audit passed
- Technical requirements met
- Metadata validated

**If NOT READY:**
- Cannot advance to Stage 10 (Ship)
- Must resolve blocking issues
- Re-run audit after fixes

**If READY:**
- "Checkpoint cleared" for Stage 9
- Can proceed to Stage 10 (Ship)

## Usage Examples

**Run full audit:**
```
/appstore-readiness
```

**After fixing issues:**
```
/appstore-readiness
```

## Related Commands

- `/appstore-review` — Quick compliance check
- `/appstore-submit` — Step-by-step submission guide

## Reference

See `~/.claude/skills/appstore-readiness/references/` for detailed guidelines.

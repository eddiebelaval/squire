# /appstore-submit - App Store Submission Guide

## Purpose
Step-by-step guide through the App Store submission process. Uses SENTINEL for timing and FIXER if issues arise.

## Prerequisites

Before using this command, ensure:
- [ ] `/appstore-readiness` audit passed
- [ ] ID8Pipeline Stage 9 checkpoint cleared
- [ ] All blocking issues resolved

## Submission Workflow

### Step 1: Pre-Submission Verification

**SENTINEL Agent checks:**
- Optimal submission timing
- Holiday freeze status
- Expected review time
- Any known App Review issues

### Step 2: App Store Connect Preparation

**Checklist:**
```
App Store Connect → My Apps → [Your App]

PREPARE FOR SUBMISSION:
□ Version number correct
□ Build uploaded and selected
□ App Information complete
  □ App name
  □ Subtitle
  □ Privacy Policy URL
  □ Category

□ Pricing and Availability
  □ Price tier set
  □ Availability selected

□ App Privacy
  □ Privacy labels complete
  □ All data types identified

□ App Review Information
  □ Contact information
  □ Demo account (if needed)
  □ Notes for reviewers

□ Version Information
  □ What's New text
  □ Screenshots uploaded
  □ App Preview (optional)
  □ Promotional text (optional)
```

### Step 3: Demo Account Setup

**If app requires login:**
```
Demo Account Information:
─────────────────────────
Username: [your-demo-email]
Password: [your-demo-password]

Notes for Reviewer:
• Full access to all features
• No 2FA required
• Account won't expire
• [Any special instructions]
```

### Step 4: Review Notes

**Template:**
```
App Review Notes
────────────────

DEMO ACCOUNT:
Username: demo@yourapp.com
Password: AppReview2025!
Access: Full premium features

TESTING INSTRUCTIONS:
• [Feature 1]: [How to access/test]
• [Feature 2]: [How to access/test]
• [Any hardware requirements]

SPECIAL NOTES:
• [Anything unusual about the app]
• [Features that might not be obvious]
• [Permissions explained]
```

### Step 5: Final Checks

**Before clicking Submit:**
- [ ] Test demo account one more time
- [ ] Verify backend services are running
- [ ] Check all metadata for typos
- [ ] Confirm screenshots are current
- [ ] Review pricing settings

### Step 6: Submit for Review

**In App Store Connect:**
1. Click "Add for Review"
2. Select the build
3. Answer export compliance questions
4. Answer content rights questions
5. Answer IDFA question (if applicable)
6. Click "Submit to App Review"

### Step 7: Post-Submission Monitoring

**SENTINEL tracks:**
- Submission status
- Review progress
- Any Apple communications

**Status meanings:**
| Status | Meaning |
|--------|---------|
| Waiting for Review | In queue |
| In Review | Being reviewed |
| Rejected | Action needed |
| Pending Developer Release | Approved, waiting for you |
| Ready for Sale | Live |

## If Rejected

**FIXER Agent helps with:**
1. Analyzing rejection reason
2. Drafting response
3. Guiding fixes
4. Resubmission

**Response options:**
- **Fix and Resubmit:** Make changes, submit again
- **Appeal:** If rejection seems incorrect
- **Clarify:** Ask for more information

## Expedited Review

**When eligible:**
- Critical bug affecting users
- Time-sensitive event
- Security vulnerability
- Legal/regulatory deadline

**How to request:**
1. App Store Connect → Contact Us
2. Select "App Review"
3. Select "Expedite Review"
4. Provide justification

## Timeline Expectations

| Scenario | Typical Time |
|----------|--------------|
| First submission | 24-48 hours |
| Updates | 24 hours |
| Resubmission after rejection | 24-48 hours |
| Expedited (if approved) | 24 hours |

## Usage

```
/appstore-submit
```

## Post-Approval

After approval:
1. Choose release timing
   - Immediately
   - Manual release
   - Scheduled date
2. Monitor initial reviews
3. Update PIPELINE_STATUS.md
4. Celebrate! 🎉

## Related Commands

- `/appstore-readiness` — Full audit before submission
- `/appstore-review` — Quick compliance check

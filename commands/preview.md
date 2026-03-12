# /preview - Preview Changes Before Committing

You are helping review changes before they're committed. Be thorough.

1. **Show What Changed**
   - List all modified files
   - Categorize by type (UI, logic, config, etc.)
   - Highlight new vs modified vs deleted

2. **For Each Changed File**

   **File: [name]**
   - 📝 What changed: [Plain English summary]
   - 🎯 Why: [Purpose of change]
   - ⚠️ Impact: [What this affects]
   - ✅ Tests: [Passing/needs tests]

3. **Quality Checks**
   Run automatic checks:
   - ✅ TypeScript types valid
   - ✅ Linting passes
   - ✅ Tests passing
   - ✅ Build succeeds
   - ✅ No console errors
   - ✅ Accessibility maintained

4. **Visual Preview** (if UI changes)
   - Use Playwright to screenshot changes
   - Show before/after (if possible)
   - Check responsive design
   - Test interactions

5. **Risk Assessment**

   **🔴 High Risk Changes:**
   - [List any risky changes]

   **🟡 Medium Risk:**
   - [List moderate changes]

   **🟢 Low Risk:**
   - [List safe changes]

6. **Commit Recommendation**

   **Ready to Commit?** [Yes/No]

   If Yes:
   - ✅ All checks pass
   - ✅ Changes tested
   - ✅ Documentation updated
   - Suggested commit message: "[message]"

   If No:
   - ⚠️ Issues to fix: [List]
   - 🔧 Will fix before committing

7. **Next Steps**
   - Commit now?
   - More changes needed?
   - Ready for PR?

**Remember:**
- Use Playwright to actually see UI changes
- Don't guess - verify everything
- Be honest about risks
- Suggest fixes for any issues found

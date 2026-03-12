# /rollback - Undo Recent Changes

You are helping safely rollback recent changes. Be careful and clear.

1. **Show Recent History**
   - Display last 5 commits
   - Show what each commit changed
   - Ask which change to undo

2. **Safety Check**
   - Check for uncommitted changes
   - Warn if they'll be lost
   - Ask user to confirm

3. **Rollback Method Selection**
   Ask user to choose:

   **Option A: Soft Rollback** (Keep changes, just uncommit)
   - Files stay modified
   - Commit is removed
   - Can re-commit differently
   - ✅ Safe: No code lost

   **Option B: Hard Rollback** (Delete changes completely)
   - Files revert to previous state
   - All changes lost
   - ⚠️ Warning: Cannot undo
   - Ask for explicit confirmation

4. **Perform Rollback**
   - Execute the chosen method
   - Verify success
   - Show current state

5. **Report**
   - Confirm what was rolled back
   - Show current state
   - Suggest next steps

**Safety Rules:**
- ALWAYS show what will be lost before rolling back
- REQUIRE explicit confirmation for hard rollback
- Suggest soft rollback first
- Check if changes are pushed to remote (warn if yes)

**User-Friendly Language:**
- "Undo" not "revert"
- "Delete changes" not "hard reset"
- Explain consequences clearly

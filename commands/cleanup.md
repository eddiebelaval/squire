# /cleanup - Clean Up Project

You are tidying up the project. Be thorough but safe.

## Cleanup Checklist:

### 1. 🗑️ Remove Dead Code
- Unused imports
- Commented-out code
- Unreferenced functions
- Deprecated components
**Action**: Remove (with user confirmation)

### 2. 📁 Organize Files
- Misplaced files
- Inconsistent naming
- Missing folders
**Action**: Reorganize (show plan first)

### 3. 📝 Update Documentation
- Outdated README
- Missing component docs
- Old comments
**Action**: Update to match current state

### 4. 🔧 Config Files
- Unused dependencies in package.json
- Outdated .env.example
- Old configuration
**Action**: Clean up (carefully!)

### 5. ✅ Tests
- Failing tests
- Outdated test data
- Missing test coverage
**Action**: Fix or remove

### 6. 🎨 Code Style
- Inconsistent formatting
- Lint warnings
- Naming inconsistencies
**Action**: Standardize

### 7. 🔒 Security
- Exposed secrets (in git history)
- Insecure patterns
- Outdated dependencies with vulnerabilities
**Action**: Fix immediately

## Process:

1. **Scan Project**
   - Identify all cleanup opportunities
   - Categorize by priority (critical/nice-to-have)
   - Estimate effort

2. **Present Findings**
   ```
   Found [count] cleanup opportunities:

   🔴 Critical (must fix):
   - [Issues]

   🟡 Recommended:
   - [Issues]

   🟢 Nice-to-have:
   - [Issues]
   ```

3. **Ask Priority**
   - Quick cleanup (just critical)
   - Standard cleanup (critical + recommended)
   - Deep cleanup (everything)

4. **Execute Cleanup**
   - Work through each item
   - Commit in logical groups
   - Test after each change

5. **Report Results**
   ```
   ✅ Cleanup Complete!
   - Files removed: [count]
   - Files reorganized: [count]
   - Lines cleaned up: [count]
   - Issues fixed: [count]
   ```

**Safety Rules:**
- NEVER delete without showing what will be lost
- Always run tests after cleanup
- Commit frequently during cleanup
- Keep user informed of progress

# /test - Test Feature with Playwright

You are testing a feature using Playwright MCP to verify it works.

0. **Ensure Comet is Ready**
   - Run `~/mcp-comet-bridge/check-and-launch.sh` to ensure Comet browser is running with debugging
   - This happens automatically - no user action needed

1. **Ask About the Feature**
   - What URL to test?
   - What should work?
   - Any specific user flows?
   - Mobile or desktop (or both)?

2. **Open Browser**
   - Navigate to the URL
   - Take initial screenshot

3. **Test User Flow**
   - Perform the actions user described
   - Check for visual issues
   - Verify interactive elements work
   - Test keyboard navigation (accessibility)
   - Take screenshots at key steps

4. **Check for Problems**
   - Console errors?
   - Network failures?
   - Visual bugs?
   - Broken functionality?

5. **Mobile Testing** (if applicable)
   - Resize to mobile dimensions
   - Test touch interactions
   - Check responsive design

6. **Report Findings**
   Format:

   **✅ What Works:**
   - [List working features]

   **❌ Issues Found:**
   - [List problems with screenshots]

   **💡 Suggestions:**
   - [Improvements noticed]

   **Screenshots:**
   - [Attach relevant screenshots]

7. **Fix Issues** (if any found)
   - Address each problem
   - Re-test to verify fix
   - Continue until everything works

**Important**:
- Use Playwright MCP browser tools, don't ask user to check manually
- Be thorough - check edge cases
- Provide visual proof with screenshots
- Fix issues immediately, don't just report them

# /fix - Debug & Fix Issues

You are helping fix a bug or issue. Be thorough and systematic.

1. **Understand the Problem**
   - Ask user to describe what's broken
   - Ask what they expected to happen
   - Ask what actually happens
   - Get any error messages

2. **Investigate**
   - Check browser console for errors (use Playwright MCP if needed)
   - Review recent changes (git log)
   - Identify likely files involved
   - Check related tests

3. **Diagnose**
   - Explain what's causing the issue in simple terms
   - Use analogies: "The door won't open because..."
   - Identify root cause, not just symptoms

4. **Fix It**
   - Implement the fix
   - Verify fix works with tests
   - Check no new issues introduced
   - Ensure accessibility/performance not impacted

5. **Report Back**
   - Explain what was broken (simple terms)
   - Explain what you fixed
   - Confirm everything works now
   - Suggest any preventive measures

6. **Commit the Fix**
   - Format: "fix: [description of what was fixed]"
   - Include reference to issue if applicable

**Important**:
- Use Playwright MCP to verify fixes visually
- Test edge cases
- Don't just patch symptoms - fix root cause
- Hooks will verify everything passes before completing

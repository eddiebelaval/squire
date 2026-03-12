# /start [feature-name] - Begin New Feature

You are helping start a new feature. The user will provide a feature name after the command.

1. **Create Feature Branch**
   - Check current branch (should be main/master)
   - Pull latest changes from remote
   - Create branch: `feature/[feature-name]`
   - Switch to the new branch

2. **Project Setup Check**
   - Verify dependencies are installed
   - Check if .env file needs configuration
   - Ensure development server can start

3. **Planning Phase**
   - Ask user to describe the feature in their own words
   - Break down into logical components
   - Identify files that will need changes
   - Estimate complexity (simple/medium/complex)

4. **Confirm Plan**
   - Present the implementation plan
   - Ask user to confirm or adjust
   - Get approval before coding

5. **Ready to Code**
   - Summary: Branch created, plan confirmed
   - Next steps: Begin implementation
   - Reminder: Will auto-commit at milestones

**Note**: This sets up the entire workflow. Hooks will handle verification, commits, and documentation automatically.

# Getting Started with Your Slash Commands

**Welcome to your personal command center! 🎮**

---

## 🎯 What Are Slash Commands?

Think of them as **macros** or **shortcuts** for common tasks. Instead of explaining the same things over and over, just type a command and Claude knows exactly what to do.

### Without Commands:
```
You: "I want to build a new feature. First create a branch,
     then plan it out, make sure dependencies are installed,
     and set up the structure..."

Claude: "OK, let me..." [Long back and forth]
```

### With Commands:
```
You: /start new-feature

Claude: ✅ Branch created
        ✅ Dependencies checked
        ✅ Plan created
        Ready to build!
```

---

## 🚀 Try Your First Command

Let's test it right now!

### Step 1: Test the `/status` command
```
Just type in chat:
/status
```

This shows your current project state. Try it!

### Step 2: Try `/explain`
```
Type:
/explain what is a component
```

See how it explains in simple terms? That's the power of custom commands.

---

## 💡 The 5 Commands You'll Use Most

### 1️⃣ `/start [feature-name]`
**Use when**: Beginning any new feature

**Example**:
```
/start user-notifications
```

**What happens**: Creates branch, checks setup, plans work

---

### 2️⃣ `/test`
**Use when**: Need to verify something works

**Example**:
```
/test
Check if signup form works on mobile
```

**What happens**: Opens browser, tests it, reports results

---

### 3️⃣ `/fix`
**Use when**: Something's broken

**Example**:
```
/fix
Button doesn't click
```

**What happens**: Investigates, finds issue, fixes it, tests

---

### 4️⃣ `/preview`
**Use when**: Before committing changes

**Example**:
```
/preview
```

**What happens**: Shows what changed, runs checks, confirms ready

---

### 5️⃣ `/ship`
**Use when**: Feature is done, ready to deploy

**Example**:
```
/ship
```

**What happens**: Commits, creates PR, ready for review

---

## 🎬 Your First Complete Workflow

Let's build a simple feature end-to-end:

### Scenario: Add a dark mode toggle

```bash
# Step 1: Start the feature
/start dark-mode-toggle

# Step 2: Describe what you want
"Add a toggle button in the header that switches
between light and dark themes"

# Step 3: Test it works
/test
Check the toggle works and theme changes

# Step 4: Preview before committing
/preview

# Step 5: Ship it
/ship
```

**That's it!** You just built and shipped a feature with 5 commands.

---

## 🎓 Learning the Commands

### Quick Reference
Open the cheatsheet:
```bash
cat ~/.claude/commands/cheatsheet.md
```

### Detailed Guide
Read the full README:
```bash
cat ~/.claude/commands/README.md
```

### See What a Command Does
Look at any command file:
```bash
cat ~/.claude/commands/test.md
```

It's just a text file with instructions for Claude!

---

## ✏️ Customize Commands

Want to change how `/test` works?

```bash
# Edit the file
nano ~/.claude/commands/test.md

# Or use any text editor
code ~/.claude/commands/test.md
```

Commands are just markdown files. Modify the instructions and the command behavior changes!

---

## 🎯 Common Scenarios

### "I want to build something new"
```
1. /idea (if exploring options)
2. /start feature-name
3. Build it
4. /test
5. /ship
```

### "Something is broken"
```
1. /fix
2. Describe the problem
3. Done! (Claude fixes and tests)
```

### "What changed in this project?"
```
/compare
```

### "Is this ready to deploy?"
```
/preview
```

### "Explain this code to me"
```
/explain filename.tsx
```

---

## 💪 Power Features

### Chain Commands
```
/test
[if issues found]
/fix
/preview
/ship
```

### Use Arguments
```
/start user-authentication
/explain LoginForm.tsx
/rollback "fix: login bug"
```

### Check Progress
```
/status
```
Use this anytime you're unsure where you are in a feature.

---

## 🔥 Pro Tips

### 1. **Always /test**
Don't manually test in browsers. Use `/test` and Playwright does it automatically.

### 2. **Start with /idea**
Brainstorm before building. It saves time and helps pick the right approach.

### 3. **Preview Before Shipping**
Always `/preview` before `/ship` to catch issues early.

### 4. **Status Checks**
Lost? `/status` shows exactly where you are.

### 5. **Explain Everything**
Don't understand something? `/explain [it]`

---

## 🎨 Create Your Own Commands

### Example: Create a `/screenshot` command

**Step 1**: Create file
```bash
nano ~/.claude/commands/screenshot.md
```

**Step 2**: Write the prompt
```markdown
# /screenshot - Take Screenshots

You are taking screenshots of the current project.

1. Ask what to screenshot
2. Use Playwright to navigate
3. Take screenshots
4. Save with descriptive names
5. Show user the screenshots

Be thorough and capture multiple angles.
```

**Step 3**: Use it!
```
/screenshot
```

---

## 🎪 Real Examples

### Example 1: Quick Bug Fix
```
You: /fix
     Login button not working

Claude: 🔍 Found the issue
        ✅ Fixed event handler
        ✅ Tested - works now
        📦 Committed: "fix: login button click handler"
```

### Example 2: Build Feature
```
You: /start comment-system

Claude: 🌿 Created feature/comment-system
        📋 Planning:
           1. Comment component
           2. Reply threading
           3. Emoji reactions
        Ready to build?

You: Yes

Claude: 🔨 Building...
        [Progress updates]
        ✅ Complete!

You: /ship

Claude: 🚀 PR #43 created
        👉 https://github.com/...
```

---

## 🆘 Troubleshooting

### Command not working?

**Check if file exists:**
```bash
ls ~/.claude/commands/commandname.md
```

**Read what it does:**
```bash
cat ~/.claude/commands/commandname.md
```

**Recreate if needed:**
Ask Claude: "Can you recreate the /test command?"

---

### Want to reset everything?

```bash
# Backup current commands
cp -r ~/.claude/commands ~/.claude/commands.backup

# Remove commands
rm -rf ~/.claude/commands

# Ask Claude to recreate them
"Can you recreate all my slash commands?"
```

---

## 🎁 What You Have

**12 Pre-Built Commands:**
- `/start` - Begin features
- `/idea` - Brainstorm
- `/test` - Verify with Playwright
- `/fix` - Debug & repair
- `/preview` - Review changes
- `/status` - Check state
- `/explain` - Understand code
- `/compare` - See differences
- `/ship` - Create PR
- `/docs` - Generate docs
- `/cleanup` - Tidy up
- `/rollback` - Undo changes

**Plus Documentation:**
- `README.md` - Full guide
- `CHEATSHEET.md` - Quick reference
- `GETTING-STARTED.md` - This file!

---

## 🎯 Next Steps

1. ✅ **Try `/status` right now** - See what happens
2. ✅ **Read the CHEATSHEET.md** - Quick reference
3. ✅ **Build something with `/start`** - Real practice
4. ✅ **Customize a command** - Make it yours

---

## 🎊 You're Ready!

Commands + Hooks = Your automated development workflow.

**Hooks** run automatically (in the background)
**Commands** you trigger manually (when you need them)

Together they handle all the technical complexity so you can focus on **what** to build, not **how** to build it.

Now go build something awesome! 🚀

---

**Questions?**
Just ask Claude:
- "How does /test work?"
- "Can you create a new /demo command?"
- "Show me how to use /compare"

Claude knows all about these commands and can help anytime!

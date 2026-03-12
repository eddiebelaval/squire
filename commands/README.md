# Your Custom Slash Commands 🚀

These are your personal shortcuts for common product management tasks. Just type `/command` and Claude handles the complexity.

---

## 🎬 Getting Started Commands

### `/start [feature-name]`
**Begin a new feature with proper setup**

```
You: /start user-profiles
Claude:
  🌿 Creating feature/user-profiles branch
  📋 Breaking down the feature
  ✅ Ready to code!
```

**When to use**: Starting any new feature or significant change

---

### `/idea`
**Brainstorm and plan before building**

```
You: /idea
     I want users to customize their dashboard
Claude:
  💡 Here are 3 approaches:
     1. Drag-and-drop widgets (Complex, 3-5 days)
     2. Template selection (Simple, 1 day)
     3. Toggle panels (Medium, 2 days)
  Which direction interests you?
```

**When to use**: Exploring possibilities before committing to a solution

---

## 🔨 Building Commands

### `/test`
**Test features with visual browser verification**

```
You: /test
     Check if login form works on mobile
Claude:
  📱 Opening browser in mobile view...
  ✅ Form displays correctly
  ✅ Touch interactions work
  ❌ Password toggle too small
  🔧 Fixing issue now...
```

**When to use**: Verify anything works (no need to test manually!)

---

### `/fix`
**Debug and fix issues systematically**

```
You: /fix
     Button doesn't work on iPhone
Claude:
  🔍 Investigating...
  🎯 Found it: Touch event not registered
  🔧 Fixing...
  ✅ Tested on mobile - works now!
```

**When to use**: Something's broken and you need it fixed

---

### `/preview`
**Review changes before committing**

```
You: /preview
Claude:
  📊 3 files changed:
     🎨 LoginForm.tsx - Added validation
     ⚙️ auth.ts - New API call
     ✅ tests/ - Added 5 tests

  Quality Checks: ✅ All passing
  Ready to commit? Yes!
```

**When to use**: Before committing to see exactly what changed

---

## 📊 Information Commands

### `/status`
**Get current project state**

```
You: /status
Claude:
  🌿 Branch: feature/dark-mode
  📦 Changes: 12 files
  ✅ Tests: All passing
  🚀 Deploy ready: Yes

  💡 Dark mode complete. Ready for PR.
```

**When to use**: Check where you are in a feature

---

### `/explain [file-or-concept]`
**Understand code in plain English**

```
You: /explain useAuth
Claude:
  🎯 What it does:
  Checks if a user is logged in

  💡 Think of it like:
  A bouncer at a club checking IDs.
  No valid ID? Can't get in.

  🌟 Why it matters:
  Protects user data and keeps features secure
```

**When to use**: Need to understand what something does

---

### `/compare`
**See what changed between versions**

```
You: /compare
     Current branch vs main
Claude:
  📊 10 files changed:

  🎨 UI: 6 files (login flow redesign)
  ⚙️ Logic: 3 files (auth improvements)
  ✅ Tests: 1 file (new test coverage)

  💡 This adds social login while
     keeping email login working
```

**When to use**: Understand scope of changes

---

## 🚀 Shipping Commands

### `/ship`
**Complete feature and create PR**

```
You: /ship
Claude:
  ✅ All tests passing
  ✅ Build succeeds
  📦 Committing changes
  🚀 Creating PR
  🎉 PR #42 ready for review!
  👉 https://github.com/...
```

**When to use**: Feature is done, ready to ship

---

### `/docs`
**Generate plain-English documentation**

```
You: /docs
     Document the new comment system
Claude:
  📝 Creating documentation...

  # Comment System
  🎯 Lets users discuss posts
  💡 Encourages community engagement
  🚀 How to use: Click comment icon...
```

**When to use**: Need docs for what was built

---

## 🛠️ Maintenance Commands

### `/cleanup`
**Tidy up the project**

```
You: /cleanup
Claude:
  🗑️ Found cleanup opportunities:
  🔴 Critical: 2 security issues
  🟡 Recommended: 12 unused files
  🟢 Nice-to-have: 8 style fixes

  Proceed with cleanup? [Yes/No]
```

**When to use**: Project feels messy or before major releases

---

### `/rollback`
**Undo recent changes safely**

```
You: /rollback
Claude:
  📜 Recent commits:
  1. "Add payment integration" (5 min ago)
  2. "Fix login bug" (1 hour ago)
  3. "Update dashboard" (2 hours ago)

  Which to undo?
```

**When to use**: Need to undo a change that broke something

---

## 🎯 How to Use These

### Basic Usage
```
/command
```

### With Arguments
```
/start user-authentication
/explain LoginForm.tsx
```

### Chaining (do multiple tasks)
```
/test
/fix (if issues found)
/preview
/ship
```

---

## 💡 Pro Tips

### 1. **Combine Commands**
```
Build flow:
  /start feature-name
  [build features]
  /test
  /preview
  /ship
```

### 2. **Use /test Often**
Don't manually check browsers. Just `/test` and Claude uses Playwright to verify everything.

### 3. **Stuck? Use /status**
Forgot where you are? `/status` gives the full picture.

### 4. **Before Shipping**
Always run `/preview` to catch any issues before creating the PR.

### 5. **Brainstorming**
Use `/idea` before jumping into code. Save time by planning first.

---

## 🎨 Customization

### Add Your Own Commands

1. Create a new `.md` file in `~/.claude/commands/`
2. Name it: `yourcommand.md`
3. Write the prompt inside
4. Use it: `/yourcommand`

### Example Custom Command

**File**: `~/.claude/commands/review.md`
```markdown
# /review - Code Review

You are reviewing code for:
- Best practices
- Performance issues
- Security concerns
- Accessibility

Provide actionable feedback in simple terms.
```

Now use: `/review`

---

## 🔧 Troubleshooting

### Command not found?
```bash
# Check if command file exists
ls ~/.claude/commands/

# Make sure it ends with .md
```

### Command not working right?
```bash
# Read the command file to see what it does
cat ~/.claude/commands/commandname.md

# Edit it to adjust behavior
```

### Want to disable a command?
```bash
# Rename to .disabled
mv ~/.claude/commands/ship.md ~/.claude/commands/ship.md.disabled
```

---

## 📚 Command Categories Quick Reference

**🎬 Starting**: `/start`, `/idea`
**🔨 Building**: `/test`, `/fix`, `/preview`
**📊 Information**: `/status`, `/explain`, `/compare`
**🚀 Shipping**: `/ship`, `/docs`
**🛠️ Maintenance**: `/cleanup`, `/rollback`

---

## 🌟 Real Workflow Example

```
Day 1: Feature Start
  You: /start social-sharing
  You: Build share buttons for posts
  You: /test

Day 2: Refinement
  You: /status
  You: Add Twitter and LinkedIn
  You: /test
  You: /preview

Day 3: Ship It
  You: /docs
  You: /ship
  ✅ Feature shipped!
```

---

## 🎓 Learning More

Each command is just a markdown file. Open them to see exactly what they do:

```bash
# Read any command
cat ~/.claude/commands/ship.md

# Edit to customize
nano ~/.claude/commands/ship.md
```

The commands are **prompts** that tell Claude how to help you. Adjust them to match your workflow!

---

## 🚀 Next Level

Want more commands? Here are ideas:

- `/demo` - Create demo data
- `/performance` - Check app speed
- `/security` - Run security audit
- `/mobile` - Test mobile experience
- `/analytics` - Check metrics

Just ask: "Can you create a /demo command?"

---

**Pro Tip**: These commands work WITH your hooks. Hooks run automatically, commands you trigger manually. Together they're a powerful workflow automation system! 🎯

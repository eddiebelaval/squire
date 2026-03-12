# Visual Command Map 🗺️

**Your complete command ecosystem at a glance**

```
                    YOUR SLASH COMMANDS
                           🎮
                            |
        ┌───────────────────┼───────────────────┐
        |                   |                   |
    🎬 START            🔨 BUILD            🚀 SHIP
        |                   |                   |
    ┌───┴───┐          ┌────┴────┐         ┌───┴───┐
    |       |          |    |    |         |       |
  /start  /idea      /test /fix /preview  /ship  /docs
                          |
                      /explain
```

---

## 🎯 Command Categories

### 🎬 STARTING PHASE
```
┌─────────────────────────────────────┐
│  /start [name]                      │
│  → Create branch                     │
│  → Plan feature                      │
│  → Ready environment                 │
│                                      │
│  /idea                              │
│  → Brainstorm approaches            │
│  → Evaluate options                 │
│  → Pick best path                   │
└─────────────────────────────────────┘
```

### 🔨 BUILDING PHASE
```
┌─────────────────────────────────────┐
│  /test                              │
│  → Visual browser testing           │
│  → Automated verification           │
│  → Screenshots & reports            │
│                                      │
│  /fix                               │
│  → Debug systematically             │
│  → Root cause analysis              │
│  → Verify fix works                 │
│                                      │
│  /explain [thing]                   │
│  → Plain English explanations       │
│  → No jargon                        │
│  → Real-world analogies             │
└─────────────────────────────────────┘
```

### 📊 INFORMATION PHASE
```
┌─────────────────────────────────────┐
│  /status                            │
│  → Project state                    │
│  → Progress report                  │
│  → Quality checks                   │
│                                      │
│  /compare                           │
│  → What changed                     │
│  → Impact assessment                │
│  → Visual diffs                     │
│                                      │
│  /preview                           │
│  → Review before commit             │
│  → Quality gates                    │
│  → Visual verification              │
└─────────────────────────────────────┘
```

### 🚀 SHIPPING PHASE
```
┌─────────────────────────────────────┐
│  /ship                              │
│  → Final checks                     │
│  → Create PR                        │
│  → Deployment ready                 │
│                                      │
│  /docs                              │
│  → Plain English docs               │
│  → User-focused                     │
│  → Visual examples                  │
└─────────────────────────────────────┘
```

### 🛠️ MAINTENANCE PHASE
```
┌─────────────────────────────────────┐
│  /cleanup                           │
│  → Remove dead code                 │
│  → Organize files                   │
│  → Security checks                  │
│                                      │
│  /rollback                          │
│  → Undo changes safely              │
│  → Multiple rollback options        │
│  → No data loss                     │
└─────────────────────────────────────┘
```

---

## 🔄 Complete Workflows

### Workflow 1: New Feature (Full Cycle)
```
START
  ↓
/idea                 → Brainstorm approaches
  ↓
/start feature-name   → Create branch & plan
  ↓
[Build feature]       → Code with Claude
  ↓
/test                 → Verify it works
  ↓
/preview              → Review changes
  ↓
/docs                 → Document it
  ↓
/ship                 → Create PR
  ↓
DONE ✅
```

### Workflow 2: Quick Bug Fix
```
START
  ↓
/fix                  → Debug & repair
  ↓
/test                 → Verify fix
  ↓
/ship                 → Deploy fix
  ↓
DONE ✅
```

### Workflow 3: Understanding Codebase
```
START
  ↓
/status               → Check project state
  ↓
/compare              → See recent changes
  ↓
/explain [file]       → Understand components
  ↓
UNDERSTOOD ✅
```

### Workflow 4: Exploration
```
START
  ↓
/idea                 → Explore possibilities
  ↓
[Pick approach]       → Choose direction
  ↓
/start feature        → Begin building
  ↓
BUILDING... 🔨
```

---

## 🎯 Decision Tree

```
                    WHAT DO YOU NEED?
                           │
        ┌──────────────────┼──────────────────┐
        │                  │                  │
   Starting New?      Fixing Issue?    Understanding?
        │                  │                  │
    ┌───┴───┐          ┌───┴───┐         ┌───┴───┐
    │       │          │       │         │       │
  /idea  /start      /fix   /test     /explain /status


                    Need to Check?
                           │
        ┌──────────────────┼──────────────────┐
        │                  │                  │
   Before Commit?    Current State?     What Changed?
        │                  │                  │
    /preview           /status            /compare


                    Ready to Ship?
                           │
        ┌──────────────────┼──────────────────┐
        │                  │                  │
    Document It?      Create PR?         Undo Changes?
        │                  │                  │
      /docs              /ship            /rollback


                    Maintenance?
                           │
                       /cleanup
```

---

## 🎨 Command Relationships

### Commands that work well together:

**Planning Flow:**
```
/idea → /start → [build]
```

**Quality Flow:**
```
/test → /fix → /test (until passing)
```

**Review Flow:**
```
/status → /compare → /preview
```

**Ship Flow:**
```
/preview → /docs → /ship
```

**Debug Flow:**
```
/explain → /fix → /test
```

---

## 📈 Complexity Levels

### 🟢 Simple Commands (Quick)
- `/status` - Instant report
- `/explain` - Quick explanation
- `/compare` - Fast diff

### 🟡 Medium Commands (Few minutes)
- `/test` - Browser testing
- `/preview` - Review checks
- `/docs` - Documentation

### 🔴 Complex Commands (Longer)
- `/start` - Full setup
- `/ship` - Complete deployment
- `/cleanup` - Deep clean

---

## 💡 Command Combos (Power Moves)

### The "Fast Ship" 🚀
```
/preview → /ship
(When feature is already done)
```

### The "Safe Builder" 🛡️
```
/start → [build] → /test → /fix → /preview → /ship
(Full quality workflow)
```

### The "Explorer" 🔍
```
/status → /explain → /compare
(Understanding mode)
```

### The "Quick Fix" ⚡
```
/fix → /test → /ship
(Emergency patches)
```

### The "Thinker" 💭
```
/idea → /explain → /start
(Careful planning)
```

---

## 🎯 Command Frequency Guide

### Daily Use:
- `/test` - Verify everything
- `/status` - Check progress
- `/fix` - Handle bugs

### Per Feature:
- `/start` - Once at beginning
- `/ship` - Once at end
- `/preview` - Before shipping

### As Needed:
- `/idea` - Planning phase
- `/explain` - Learning
- `/docs` - Documentation
- `/compare` - Review changes
- `/cleanup` - Maintenance
- `/rollback` - Undo mistakes

---

## 🎪 Real-World Examples

### Morning Standup
```
You: /status
Claude: [Shows what's in progress]
```

### Product Discovery
```
You: /idea
     Want to add user achievements
Claude: [3 approaches with pros/cons]
```

### Emergency Bug
```
You: /fix
     Payment not processing
Claude: [Investigates, fixes, tests]
```

### Code Review Prep
```
You: /preview
Claude: [Full analysis of changes]
```

### Feature Complete
```
You: /ship
Claude: [Creates PR, ready to merge]
```

---

## 📚 Command Locations

All commands live in:
```
~/.claude/commands/
```

Each command is a `.md` file:
```
start.md      → /start
test.md       → /test
ship.md       → /ship
... etc
```

**Want to customize?** Just edit the markdown file!

---

## 🔥 Pro Tips Recap

1. **Use /test liberally** - Don't manually test
2. **Start with /idea** - Plan before building
3. **Always /preview** - Before shipping
4. **/status when stuck** - See where you are
5. **/explain anything** - No shame in asking

---

## 🎁 Your Complete Toolkit

**Commands**: 12 slash commands
**Hooks**: 7 automation hooks
**Docs**: 3 comprehensive guides

Together = **Automated workflow for non-technical PMs** ✨

---

**Next**: Pick any command and try it!

/status - Great place to start 🚀
```

---

This is your command ecosystem. Commands are tools, workflows are recipes, and you're the chef! 👨‍🍳

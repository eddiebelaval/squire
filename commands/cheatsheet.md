# Slash Commands Cheatsheet 🎯

**Quick reference for your custom commands**

---

## One-Line Descriptions

| Command | What It Does |
|---------|--------------|
| `/feature-dev` | 🎓 Complete learning workshop - builds & teaches |
| `/start [name]` | Create feature branch & plan work |
| `/idea` | Brainstorm approaches before building |
| `/test` | Verify feature works (uses Playwright) |
| `/fix` | Debug and fix issues |
| `/preview` | Review changes before commit |
| `/status` | Show project state & progress |
| `/explain [thing]` | Understand code in plain English |
| `/compare` | See what changed |
| `/ship` | Complete feature & create PR |
| `/docs` | Generate documentation |
| `/cleanup` | Tidy up project |
| `/rollback` | Undo recent changes |

---

## When to Use What

### 🚀 Starting Something New
```
/feature-dev           → Want to LEARN while building
/start feature-name    → Fast start (already know how)
/idea                  → Still figuring it out
```

### 🔨 While Building
```
/test                  → Check if it works
/fix                   → Something's broken
/explain               → Don't understand something
```

### ✅ Before Committing
```
/preview               → Review all changes
/status                → Check overall state
```

### 🎉 Ready to Ship
```
/docs                  → Document what you built
/ship                  → Create PR & deploy
```

### 🛠️ Maintenance
```
/cleanup               → Clean up code
/rollback              → Undo changes
/compare               → See differences
```

---

## Most Common Workflows

### **Build New Feature (Learning Mode)**
```
1. /feature-dev
2. [Answer questions]
3. [Learn as it builds]
4. [Ships automatically]
```

### **Build New Feature (Fast Mode)**
```
1. /start feature-name
2. [Describe what you want]
3. /test
4. /preview
5. /ship
```

### **Fix a Bug**
```
1. /fix
2. [Describe the problem]
3. /test
4. /ship
```

### **Explore an Idea**
```
1. /idea
2. [Describe your vision]
3. [Pick an approach]
4. /start feature-name
```

### **Ship Existing Work**
```
1. /status (check state)
2. /preview (review changes)
3. /docs (if needed)
4. /ship
```

---

## 💡 Power User Tips

**Use /test instead of manually testing**
→ Playwright automatically checks everything

**Stuck? Try /status**
→ Shows exactly where you are

**Before any PR, run:**
```
/preview
/test
/ship
```

**Brainstorming? Start with:**
```
/idea
```

**Don't understand code? Use:**
```
/explain filename.tsx
/explain "what is useEffect"
```

---

## 🎯 Keyboard Warrior Mode

Type commands in chat like this:

```
/start dark-mode
```

That's it! Command runs immediately.

---

## 📱 Print This!

Keep this cheatsheet handy until commands become muscle memory.

Most used commands:
- `/feature-dev` - Learn while building (educational)
- `/start` - Begin features (fast)
- `/test` - Verify everything
- `/ship` - Deploy it
- `/fix` - Fix issues
- `/status` - Check progress

---

**Remember**: Commands are in `~/.claude/commands/`
Edit any `.md` file to customize how commands work!

# Which Command Should I Use? 🤔

**Quick decision tree to pick the right command**

---

## Start Here 👇

```
                    What's your goal?
                           │
        ┌──────────────────┼──────────────────┐
        │                  │                  │
   Build Feature      Fix Something     Understand Something
        │                  │                  │
        ▼                  ▼                  ▼
   [Keep reading]     Use /fix          Use /explain
```

---

## Building a Feature? Ask Yourself...

### Question 1: Do you want to learn?

**YES - Want to understand HOW and WHY**
```
→ Use /feature-dev

Perfect for:
✅ Learning new concepts
✅ First time with tech
✅ Understanding patterns
✅ Educational experience

Example:
"I want to learn React hooks while building a form"
```

**NO - Just want it done fast**
```
→ Use /start

Perfect for:
✅ You know what to do
✅ Time pressure
✅ Simple features
✅ Repeat patterns

Example:
"Add another button like the existing ones"
```

---

### Question 2: Do you know what to build?

**NO - Still exploring ideas**
```
→ Use /idea first
→ Then /feature-dev or /start

Perfect for:
✅ Brainstorming
✅ Comparing approaches
✅ Figuring out scope

Example:
"I want better notifications but not sure how"
```

**YES - Clear requirements**
```
→ Skip to /feature-dev or /start

Example:
"Add a dark mode toggle in the header"
```

---

## Quality & Verification Commands

```
          What do you need to check?
                     │
    ┌────────────────┼────────────────┐
    │                │                │
 "Just finished   "About to       "Deep cleanup
  coding"          create a PR"    between features"
    │                │                │
    ▼                ▼                ▼
  /polish          /verify          /cleanup
    │                │                │
    │                │                │
    ▼                ▼                ▼
 Auto review +   6-layer audit    Dead code,
 auto simplify   (types, lint,    unused files,
 in one pass     tests, build)    config issues
```

### Quick Decision Tree

| Situation | Command | Why |
|-----------|---------|-----|
| "Just finished coding" | `/polish` | Auto-reviews AND auto-fixes in one pass |
| "About to create a PR" | `/verify` | Deep 6-layer audit before shipping |
| "Quick sanity check" | `/test-verify quick` | Types + lint only, 30 seconds |
| "Testing in browser" | `/test` | Manual browser testing via Playwright |
| "Deep cleanup between features" | `/cleanup` | Remove dead code, organize files, fix config |
| "Reviewing Codex output" | `/review-codex` | Director/Builder review with auto-fix loop |
| "Run full test suite" | `/test-verify all` | Unit + E2E + build in sequence |

### The Differences That Matter

- **`/polish`** = "Make my code better." Two agents (reviewer + simplifier) that auto-apply changes. Use after coding, before committing.
- **`/verify`** = "Is my code correct?" Read-only audit across 6 layers. Use before PRs when you need confidence, not changes.
- **`/test-verify`** = "Do the tests pass?" Runs actual test commands (types, lint, unit, E2E, build). Concrete pass/fail.
- **`/cleanup`** = "Is my project tidy?" Maintenance sweep for dead code, orphaned files, outdated config. Use between features.
- **`/test`** = "Does it work visually?" Opens a browser and interactively tests. Use for UI verification.
- **`/review-codex`** = "Is the Builder's work good?" Specialized review for Codex-generated code.

---

## Complete Decision Matrix

| Situation | Command | Why |
|-----------|---------|-----|
| "I want to learn" | `/feature-dev` | Educational + builds |
| "I know how, just build it" | `/start` | Fast execution |
| "Not sure what to build" | `/idea` | Exploration phase |
| "Something's broken" | `/fix` | Debug + repair |
| "What does this do?" | `/explain` | Understanding |
| "Did it work?" | `/test` | Verification |
| "Ready to ship?" | `/preview` | Pre-ship review |
| "Where are we?" | `/status` | Status check |
| "What changed?" | `/compare` | Diff analysis |
| "Ship it!" | `/ship` | Create PR |
| "Document this" | `/docs` | Documentation |
| "Clean up code" | `/cleanup` | Maintenance |
| "Undo that" | `/rollback` | Revert changes |

---

## By Experience Level

### 🌱 New to Development
**Use `/feature-dev` for everything at first**
- Learn professional practices
- Understand the "why"
- Build confidence
- After 3-5 features, transition to faster commands

### 🌿 Some Experience
**Mix commands based on situation:**
- New concepts → `/feature-dev`
- Familiar patterns → `/start`
- Quick fixes → `/fix`
- Exploration → `/idea`

### 🌳 Experienced
**Use fast commands, `/feature-dev` for learning:**
- Standard work → `/start`, `/fix`, `/ship`
- New tech → `/feature-dev`
- Teaching others → `/feature-dev` (show them)
- Complex features → `/feature-dev` (stay thorough)

---

## By Feature Complexity

### Simple (< 2 hours)
```
Quick: /start → /test → /ship
Learning: /feature-dev
```

**Examples:**
- Add a button
- Create a form field
- Style tweak

### Medium (2-6 hours)
```
Quick: /start → /test → /preview → /ship
Learning: /feature-dev (recommended)
```

**Examples:**
- User profiles
- Comment system
- Favorites feature

### Complex (1+ days)
```
Recommended: /feature-dev
(Thoroughness prevents costly mistakes)

Alternative: /idea → /start → /test → /preview → /ship
```

**Examples:**
- Dashboard with multiple widgets
- Authentication system
- Complex integrations

---

## By Time Available

### ⏰ Time Pressure (Urgent)
```
/start → /test → /ship
(Skip learning, just deliver)
```

### 🕐 Normal Timeline
```
/feature-dev
(Learn while building, better quality)
```

### 🎓 Learning Focus (No deadline)
```
/feature-dev + ask lots of questions
(Deep dive into concepts)
```

---

## Real Scenarios

### Scenario 1: "Add social login"
```
New to OAuth?
  → /feature-dev (learn authentication flows)

Did it before?
  → /start (faster implementation)
```

### Scenario 2: "Button not working"
```
Always use: /fix
(Diagnostic workflow)
```

### Scenario 3: "Users want notifications"
```
Not sure how?
  → /idea (explore options)
  → /feature-dev (implement & learn)

Clear requirements?
  → /feature-dev if complex
  → /start if simple
```

### Scenario 4: "What does useEffect do?"
```
Always use: /explain useEffect
(Quick understanding)
```

### Scenario 5: "Is this code ready?"
```
Use: /preview
(Pre-ship checklist)
```

---

## Command Combos

### Full Learning Journey
```
/idea                  (explore)
/feature-dev           (build & learn)
[automatically tests & ships]
```

### Fast Delivery
```
/start feature-name    (quick start)
/test                  (verify)
/ship                  (deploy)
```

### Deep Understanding
```
/status                (see current state)
/explain component.tsx (understand pieces)
/compare               (see changes)
/feature-dev           (build with learning)
```

### Quality Focused
```
/feature-dev           (thorough build)
/test                  (verify visually)
/preview               (final review)
/ship                  (confident deploy)
```

---

## Special Cases

### "I don't understand the codebase"
```
1. /status (overview)
2. /explain key files
3. /feature-dev (learn by building)
```

### "Need to ship today"
```
1. /start (fast)
2. /test (quick check)
3. /ship (deploy)
```

### "Teaching someone else"
```
1. /feature-dev
2. Let them read the chat
3. Point out teaching moments
```

### "Complex business logic"
```
Always /feature-dev
(Need to understand deeply)
```

### "Repeating similar feature"
```
1st time: /feature-dev (learn pattern)
2nd time: /start (faster)
3rd+ time: /start (muscle memory)
```

---

## Quick Reference

### I want to LEARN
→ `/feature-dev`

### I want it DONE
→ `/start`

### I want to EXPLORE
→ `/idea`

### I want to FIX
→ `/fix`

### I want to UNDERSTAND
→ `/explain`

### I want to CHECK
→ `/test` or `/preview`

### I want to SHIP
→ `/ship`

---

## The Golden Rule

**When in doubt, use `/feature-dev`**

Why?
- ✅ You learn
- ✅ Builds correctly
- ✅ Tests thoroughly
- ✅ Ships professionally
- ✅ Slows you down just enough to avoid mistakes

You can always speed up later once you know what you're doing!

---

## Still Unsure?

Ask Claude:
```
"Should I use /feature-dev or /start for [your situation]?"
```

Claude will recommend based on:
- Your experience level
- Feature complexity
- Learning goals
- Time constraints

---

**Pro Tip**: Your first 3-5 features? Use `/feature-dev` for ALL of them. The investment in learning pays off forever. 🎓

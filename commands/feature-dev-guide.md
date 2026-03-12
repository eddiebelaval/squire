# /feature-dev - Your Personal Development Mentor

## What Makes This Command Special? 🌟

This isn't just building a feature - it's a **complete learning experience**. Think of it as having a patient senior developer sitting next to you, teaching you professional practices while building real features.

---

## How It's Different

### Other Commands:
```
/start feature-name
→ Creates branch, plans, ready to code
→ Fast and efficient
```

### /feature-dev:
```
/feature-dev
→ Discovers user needs
→ Explains technical decisions
→ Teaches as it builds
→ Educational + productive
```

---

## The Complete Journey 🗺️

### Phase 1: Discovery (10 min)
**What happens:**
- Understand the problem
- Define success criteria
- Explore alternatives

**What you learn:**
- Product thinking
- User-first approach
- Scope definition

### Phase 2: Planning (15 min)
**What happens:**
- Search existing codebase
- Break down components
- Estimate complexity

**What you learn:**
- Code exploration
- Architecture thinking
- Resource planning

### Phase 3: Setup (5 min)
**What happens:**
- Create feature branch
- Build todo list
- Confirm approach

**What you learn:**
- Git workflow
- Task breakdown
- Planning methodology

### Phase 4-6: Building (1-4 hours)
**What happens:**
- Data structures first
- Then logic
- Then UI
- Polish throughout

**What you learn:**
- Bottom-up development
- Component architecture
- State management
- Error handling
- Accessibility
- Loading states

### Phase 7: Quality (30 min)
**What happens:**
- Write tests
- Visual testing with Playwright
- Documentation

**What you learn:**
- Testing strategies
- Automation
- Documentation practices

### Phase 8: Ship (15 min)
**What happens:**
- Final review
- Create PR
- Celebrate!

**What you learn:**
- Quality checklist
- PR best practices
- Professional delivery

---

## Real Example Walkthrough

### User Says:
```
/feature-dev
```

### Claude Responds:
```
🎓 Welcome to Feature Development Workshop!

I'm going to walk you through building a feature
like a professional developer would - step by step,
teaching you along the way.

Let's start with understanding what you want to build.

❓ What problem are you trying to solve?
```

### User Says:
```
Users want to save their favorite posts
```

### Claude Responds:
```
Great! Let's dig deeper to understand this well.

❓ Who is this for?
   - All users or specific types?

❓ What should happen when they favorite a post?
   - Just save it?
   - Show in a special list?
   - Notify them of updates?

💡 Teaching Moment:
   We're asking "why" before "how". Understanding
   user needs prevents building the wrong thing.
```

### User Provides Details

### Claude Responds:
```
Perfect! Now I understand. Let's look at the codebase
to see what already exists...

🔍 Found these related patterns:
   - components/Post.tsx (similar UI)
   - hooks/useBookmark.ts (we can adapt this)
   - lib/api.ts (add endpoint here)

💡 Teaching Moment:
   We don't start from scratch. Reusing existing
   patterns keeps the codebase consistent and saves time.

Let me break this feature down...

🧩 Feature Components:

UI Layer:
- [ ] FavoriteButton component
- [ ] FavoritesList component

Logic Layer:
- [ ] useFavorites hook (state mgmt)
- [ ] API client functions

Backend:
- [ ] POST /api/favorites
- [ ] GET /api/favorites
- [ ] DELETE /api/favorites/:id

💡 Teaching Moment:
   We build bottom-up: data → logic → UI.
   Each layer depends on the one below it.

Complexity: Medium (4-6 hours)
Because:
- 4 new components
- Database integration
- State synchronization

Ready to start building? [Yes/No]
```

### User: "Yes"

### Claude Creates Todo List:
```
📋 Created Development Plan:

Phase 1: Foundation
✅ Create data types
⬜ Build FavoriteButton
⬜ Basic styling

Phase 2: Functionality
⬜ Implement useFavorites hook
⬜ Connect to API
⬜ Handle edge cases

Phase 3: Polish
⬜ Error handling
⬜ Loading states
⬜ Accessibility

Phase 4: Quality
⬜ Write tests
⬜ Visual testing
⬜ Documentation

Let's start with Phase 1...

🔨 Creating data structures...
```

### Then Builds Step by Step:
```
✅ Created FavoriteType interface

💡 Teaching Moment:
   TypeScript interfaces are blueprints for data.
   They tell us (and the editor) what shape our
   data has, preventing bugs.

Updated todo: ✅ Create data types

Next: Building FavoriteButton component...
```

And continues through ALL phases, teaching at every step!

---

## What Makes It Educational?

### 1. **Explains Before Doing**
```
❌ Without explanation:
   "Creating component..."

✅ With explanation:
   "Now we build the UI component users will see.
    We start simple - just structure, no fancy logic.

    💡 Components are reusable UI pieces, like LEGO
       blocks that snap together."
```

### 2. **Shows After Doing**
Always shows what was created and why it matters

### 3. **Teaching Moments**
```
💡 Teaching Moment boxes explain:
   - Why we do things this way
   - What the alternatives are
   - How it connects to bigger concepts
```

### 4. **Interactive Todo List**
Watch progress in real-time as items check off

### 5. **Asks Questions**
Ensures understanding before moving forward

### 6. **Uses Analogies**
Connects technical concepts to familiar things

---

## Best For:

✅ **Learning while building** - Want to understand, not just ship
✅ **Complex features** - Need structured approach
✅ **First time with tech** - Learning React, TypeScript, etc.
✅ **Understanding codebase** - See how pieces fit together
✅ **Professional practices** - Learn industry standards

---

## Not Best For:

❌ **Quick fixes** - Use `/fix` instead
❌ **Simple changes** - Regular commands faster
❌ **Time pressure** - Use `/start` + `/ship`
❌ **Already know how** - Would be too slow

---

## Pro Tips:

### 1. **Ask Questions Anytime**
```
You: "What does useState do again?"
Claude: [Detailed explanation with examples]
```

### 2. **Request Deeper Dives**
```
You: "Can you explain React hooks more?"
Claude: [Extended teaching session]
```

### 3. **Take Breaks**
```
You: "Let's pause here, continue tomorrow"
Claude: "No problem! When ready, just say
        'continue feature-dev' and we'll pick
        up exactly where we left off."
```

### 4. **Different Pace**
```
You: "Can we go faster through the UI part?"
Claude: "Absolutely! I'll speed up explanations
        but still show key decisions."
```

### 5. **Save Learning Notes**
All teaching moments are in the chat - scroll back anytime!

---

## Expected Timeline:

**Small Feature** (button, modal, simple form)
- Discovery: 5 min
- Planning: 10 min
- Building: 1-2 hours
- Total: ~2 hours

**Medium Feature** (user profiles, favorites, notifications)
- Discovery: 10 min
- Planning: 15 min
- Building: 3-5 hours
- Total: ~4-6 hours

**Large Feature** (dashboard, complex forms, integrations)
- Discovery: 15 min
- Planning: 30 min
- Building: 1-3 days
- Total: 1-3 days

**Note**: This is LEARNING time. Once you know the concepts, regular development is 50% faster.

---

## What You'll Learn:

By the end of ONE feature-dev session, you'll understand:

**Product Skills:**
- ✅ User-first thinking
- ✅ Scope definition
- ✅ Feature breakdown

**Technical Skills:**
- ✅ Component architecture
- ✅ State management
- ✅ TypeScript types
- ✅ API integration
- ✅ Error handling
- ✅ Testing strategies

**Professional Skills:**
- ✅ Git workflow
- ✅ Code organization
- ✅ Documentation
- ✅ Quality standards
- ✅ PR practices

**Accessibility Skills:**
- ✅ Keyboard navigation
- ✅ Screen readers
- ✅ ARIA labels
- ✅ Inclusive design

---

## Compare with Other Commands:

| Feature | /start | /feature-dev |
|---------|--------|-------------|
| Speed | ⚡ Fast | 🎓 Educational |
| Learning | Minimal | Deep |
| Explanation | Brief | Comprehensive |
| Todo List | Basic | Detailed phases |
| Teaching | No | Yes, constantly |
| Best For | Shipping | Learning |

**Recommendation**:
- First few features? Use `/feature-dev` to learn
- Know what you're doing? Use `/start` for speed
- Complex new concept? Use `/feature-dev` to understand

---

## Try It Now!

Just type:
```
/feature-dev
```

And describe something you want to build. Even something simple like:
- "Add a like button"
- "Create a comment form"
- "Build a user profile card"

Watch how it:
1. Asks about the user need
2. Plans the architecture
3. Breaks down tasks
4. Teaches as it builds
5. Tests thoroughly
6. Ships professionally

---

## Success Stories:

### "I finally understand React Hooks"
*After one `/feature-dev` session building a form with state*

### "Now I get why we write tests"
*After seeing automated tests catch a bug*

### "Accessibility makes sense now"
*After building keyboard navigation*

### "I can read our codebase confidently"
*After learning component patterns*

---

## Next Steps:

1. **Try it**: Run `/feature-dev` with a simple feature
2. **Take notes**: Save teaching moments that resonate
3. **Ask questions**: Dig deeper into concepts you want to understand
4. **Repeat**: Each feature builds your knowledge
5. **Transition**: Eventually use faster commands as you learn

---

## Remember:

`/feature-dev` isn't just about shipping code.

It's about **understanding** code.

It's about becoming **confident** with development.

It's about learning **professional practices**.

It's your personal **development bootcamp**, one feature at a time. 🎓

---

**Ready to learn by building?**

Type: `/feature-dev` 🚀

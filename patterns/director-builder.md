# Director/Builder Pattern -- Multi-Model Orchestration

A pattern for using two AI models together: one plans and reviews, the other executes. This creates error diversity (two models catch different bugs), context efficiency (builder gets focused prompts), and built-in code review.

---

## Architecture

```
Director (Reasoning Model)              Builder (Code Generation Model)
--------------------------              ------------------------------
Reads state, picks next task            Receives scoped task
Creates focused prompts                 Implements code to specification
Reviews all builder output              Writes files directly
Fixes issues, handles edge cases        Reports results back
Verifies (build, types, tests)
Updates progress, manages state
Git operations (commits, pushes)
```

---

## Role Definitions

### Director (Reasoning Model)

**Responsibilities:**
- Read state, pick next task from implementation plan
- Create scoped, clear prompts for Builder
- Review all Builder output before integration
- Fix issues, handle edge cases
- Verify (build, types, tests)
- Update progress, manage task status
- Git operations (commits at safe points)

**Strengths leveraged:**
- Long-context reasoning and orchestration
- Architecture and system design
- Code review and quality assessment
- Integration and coordination

### Builder (Code Generation Model)

**Responsibilities:**
- Receive scoped tasks (one per iteration)
- Implement code to specification
- Write files directly
- Report results back

**What Builder does NOT do:**
- Manage state
- Make architectural decisions
- Decide what to build next
- Handle git operations
- Know about the broader project context

---

## Execution Flow

Each build iteration follows this sequence:

```
1. READ STATE (Director)
   - Load implementation plan
   - Check for next step
   - Mark task as in_progress

2. CREATE PROMPT (Director)
   - Write scoped Builder prompt with context
   - Include patterns to follow
   - Include success criteria

3. EXECUTE (Builder)
   - Receive scoped task
   - Implement code
   - Write files

4. REVIEW (Director)
   - Check Builder output against requirements
   - Fix minor issues directly
   - Re-send to Builder if major issues (max 2 retries)

5. INTEGRATE & VERIFY (Director)
   - Wire up imports/exports
   - Run build/typecheck/tests
   - Mark task as completed

6. UPDATE STATE (Director)
   - Log progress
   - Increment iteration counter
   - Check: more tasks? -> loop | all done? -> complete
```

---

## Builder Prompt Template

```
TASK: {taskDescription}
FILE: {filePath}

CONTEXT:
{relevantCodeContext}

REQUIREMENTS:
{requirements}

PATTERNS TO FOLLOW:
{existingPatterns}

SUCCESS CRITERIA:
{verificationSteps}
```

---

## Failure Handling

### Within an Iteration

| Issue | Response |
|-------|----------|
| Minor Builder bugs | Director fixes directly |
| Wrong approach | Re-prompt Builder with clearer context |
| 2nd failure same task | Director implements directly |
| Build/test failure | Debug, fix, re-verify |

### System-Level Failures

| Issue | Response |
|-------|----------|
| 3 consecutive errors | Pause for human intervention |
| Stuck in loop | Check completion criteria |
| Lost context | Read state file (ground truth) |

---

## When to Use This Pattern

**Good fit:**
- Multi-file feature builds with clear specifications
- Tasks that benefit from code review before integration
- Long-running builds where context efficiency matters
- Teams using multiple AI providers

**Poor fit:**
- Quick single-file fixes
- Exploratory/research tasks
- Tasks requiring deep conversational context
- Simple CRUD operations

---

## Communication Signals

When using this pattern, signal clearly to the user:

- "Iteration N: [task name]" -- starting iteration
- "Sending to Builder: [brief]" -- delegation
- "Builder complete, reviewing..." -- after return
- "Review: PASS" or "Review: fixing [issue]" -- review result
- "Verification: PASSED" -- after build/test
- "Taking over from Builder" -- switching to direct implementation

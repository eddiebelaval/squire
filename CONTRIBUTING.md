# Contributing to Squire

Squire is a file-based toolkit. Every component is a markdown file or a shell script. Contributing follows the same principle: keep it simple, keep it useful, keep it grounded in real usage.

---

## What We Accept

| Type | Description | Where It Goes |
|------|-------------|---------------|
| **New skills** | Domain expertise as a prompt file | `skills/<skill-name>/` |
| **New commands** | Reusable workflows as prompt files | `commands/` |
| **New agents** | Executable specialists with tool access | `agents/` |
| **Behavioral rules** | Corrections backed by measured failure patterns | `patterns/` or `squire.md` |
| **Bug fixes** | Installer issues, broken paths, typos | Wherever the bug lives |
| **Documentation** | Clearer explanations, better examples | Relevant `.md` file |

## What We Do Not Accept

- Runtime dependencies (npm packages, Python libraries, build tools)
- Features that require a server, database, or external service to function
- Model-specific optimizations that only work with one AI provider
- Changes that break the cherry-pick principle (components must remain independent)

---

## How to Contribute

### 1. Open an Issue First

Before writing code or docs, open an issue describing what you want to contribute and why. This prevents wasted effort on contributions that do not align with the project direction.

Use the issue templates:
- **Bug Report** -- something is broken or incorrect
- **Feature Request** -- a new skill, command, agent, or capability
- **Skill Submission** -- a complete skill ready for review

### 2. Fork and Branch

```bash
git clone https://github.com/<your-username>/squire.git
cd squire
git checkout -b contribution/<short-description>
```

### 3. Follow the Existing Patterns

Every component has an established format. Match it.

**Skills** -- markdown file in `skills/<skill-name>/` with:
- Clear scope statement (what the skill does)
- When to use / when not to use
- Step-by-step instructions for the agent
- Examples where helpful

**Commands** -- markdown file in `commands/` with:
- Description of what the command does
- Structured steps the agent should follow
- Tool usage instructions

**Agents** -- markdown file in `agents/` with:
- Role definition
- Tool access list
- Behavioral instructions

### 4. Test Your Contribution

- **Skills/commands/agents**: Load them into Claude Code and verify they produce the expected behavior. Describe your testing in the PR.
- **Shell scripts**: Test on macOS with bash 3.2+ (`bash --version` to check). No bashisms that require 4.0+.
- **Documentation**: Read it fresh. If something is unclear to you after 30 seconds, rewrite it.

### 5. Submit a Pull Request

- Keep PRs focused. One skill, one command, or one fix per PR.
- Use the PR template. Fill in the summary, what you tested, and why this belongs in Squire.
- Reference the issue number.

---

## Contribution Standards

### Grounded in Usage

Every behavioral rule in Squire traces to a measured failure pattern. New rules must include:
- The failure pattern observed (what went wrong)
- The frequency or impact (how often / how bad)
- The correction (what the rule instructs)

Skills and commands do not require the same rigor, but they should solve a real problem you have encountered, not a theoretical one.

### No Over-Engineering

Squire is files. Contributions that introduce complexity (build steps, config files, abstractions) will be asked to simplify. If a contribution cannot be understood by reading a single markdown file, it is too complex.

### Bash 3.2+ Compatibility

All shell scripts must work on macOS default bash (3.2). No associative arrays, no `mapfile`, no `readarray`, no `[[ =~ ]]` with stored patterns.

---

## Code of Conduct

Be professional. Critique ideas, not people. If you disagree with a decision, explain your reasoning. No personal attacks, no dismissive language, no gatekeeping.

Issues and PRs that violate this will be closed without discussion.

---

## Questions

Open a GitHub issue or reach out on X: [@eddiebe](https://x.com/eddiebe).

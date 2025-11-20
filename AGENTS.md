We track work in Beads instead of Markdown. Run \`bd quickstart\` to see how.

# Agent Guidelines for Swift and SwiftUI Projects

## ⚠️ CRITICAL: Ask Clarifying Questions When Unclear

**ALWAYS ask clarifying questions when requirements are ambiguous or unclear.**

### Question-Asking Protocol

When you receive a request that is:
- Ambiguous or has multiple interpretations
- Missing key details needed for implementation
- Unclear about expected behavior or scope
- Could be understood in different ways

**YOU MUST**:
1. ✅ **Ask ONE clarifying question at a time**
2. ✅ **Wait for the answer before proceeding**
3. ✅ **Continue asking questions until you have complete understanding**
4. ✅ **Never make assumptions when you can ask**

### Examples of When to Ask

❓ **Ambiguous request**: "Add a loading state"
- **Ask**: "Should this be a full-screen loading indicator, an inline spinner, or a skeleton view?"

❓ **Missing details**: "Add animation"
- **Ask**: "What should be animated? Should this use a spring animation, easing curve, or custom timing?"

❓ **Unclear scope**: "Improve performance"
- **Ask**: "Which area needs optimization? View updates, data fetching, or list scrolling performance?"

❓ **Multiple interpretations**: "Handle errors"
- **Ask**: "Should errors be shown in an alert, inline message, or banner? Should they auto-dismiss?"

### What NOT to Do

❌ **Don't make assumptions and implement something that might be wrong**
❌ **Don't ask multiple questions in one message** (ask one, wait for answer, then ask next)
❌ **Don't proceed with unclear requirements** hoping you guessed correctly
❌ **Don't over-explain options** in the question (keep questions concise)

### Good Question Pattern

```
"I want to make sure I understand correctly: [restate what you think they mean].

Is that correct, or did you mean [alternative interpretation]?"
```

**Remember**: It's better to ask and get it right than to implement the wrong thing quickly.

---

## Dynamic Skill Loading System

This project uses a **dynamic skill loading system** where the LLM should:
1. **Analyze the task** to determine which skills are required
2. **Load only the necessary skills** by reading their SKILL.md files
3. **Apply the skill knowledge** during task execution
4. **Unload skills** from working memory when no longer needed

### Available Skills

| Skill | Load When | Description |
|-------|-----------|-------------|
| **beads_workflow** | Managing tasks, tracking work, creating issues | Complete bd workflow for task tracking with dependency management |
| **commit_workflow** | Committing code, managing git history | Incremental commit strategy - commit after each feature completion |
| **communication_protocol** | ALWAYS (every interaction) | Ask clarifying questions when requirements are ambiguous |
| **temporary_files** | ALWAYS (every interaction) | All AI-generated temporary files go to `tmp/` directory |
| **oneshot** | User explicitly requests "oneshot [task]" | Complete uninterrupted execution of entire task/epic with final summary only |
| **pre_commit_checks** | Before committing code | Automated format/build/test checks before every commit |
| **swift** | Writing/refactoring Swift/SwiftUI code | Modern Swift and SwiftUI best practices, testing, documentation |

### Skill Loading Protocol

**Before starting any task:**

1. **Identify required skills** based on task type:
   - User says "oneshot [task]" → Load `oneshot` skill (takes over execution)
   - Code changes → Load `swift` skill
   - Task tracking → Load `beads_workflow` skill
   - Git operations → Load `commit_workflow` skill
   - Ambiguous requirements → `communication_protocol` (always active)
   - Temporary files → `temporary_files` (always active)
   - Pre-commit → Load `pre_commit_checks` skill

2. **Load skills** by reading the appropriate SKILL.md file:
   ```
   Read: skills/<skill_name>/SKILL.md
   ```
   
   **IMPORTANT**: When loading a skill, the LLM MUST announce it in the chat response:
   ```
   🔧 Loading skill: <skill_name>
   ```

3. **Apply skill knowledge** during task execution

4. **Unload skills** when done:
   - Keep only relevant skills in working memory
   - Unload skills that are no longer needed for current task
   - Communication protocol and temporary_files are ALWAYS active (never unload)
   
   **IMPORTANT**: When unloading a skill, the LLM MUST announce it in the chat response:
   ```
   ✓ Unloading skill: <skill_name>
   ```

### Skill Usage Decision Tree

```
Task received
    ↓
Analyze task type
    ↓
┌──────────────────────────────────────┐
│ Did user say "oneshot [task]"?       │ → YES → Load: oneshot (takes over execution)
└──────────────────────────────────────┘
    ↓ NO
┌──────────────────────────────┐
│ Is this a code writing task? │ → YES → Load: swift
└──────────────────────────────┘
    ↓ ALSO CHECK
┌──────────────────────────────┐
│ Is this task tracking?       │ → YES → Load: beads_workflow
└──────────────────────────────┘
    ↓ ALSO CHECK
┌──────────────────────────────┐
│ Is this a git commit?        │ → YES → Load: commit_workflow, pre_commit_checks
└──────────────────────────────┘
    ↓ ALSO CHECK
┌──────────────────────────────┐
│ Are requirements unclear?    │ → YES → Use: communication_protocol (already loaded)
└──────────────────────────────┘
    ↓
Execute task with loaded skills
    ↓
Task complete
    ↓
Unload skills no longer needed
```

### Skill Combinations

Common task scenarios and their skill requirements:

| Task Scenario | Skills to Load |
|---------------|----------------|
| **Oneshot execution** | `oneshot` (then loads others as needed: `swift`, `commit_workflow`, etc.) |
| **Implement new feature** | `swift`, `beads_workflow` |
| **Fix bug** | `swift`, `beads_workflow` |
| **Commit code** | `commit_workflow`, `pre_commit_checks` |
| **Create/update issue** | `beads_workflow` |
| **Clarify requirements** | `communication_protocol` (always active) |
| **Write tests** | `swift` |
| **Refactor code** | `swift`, `commit_workflow` |

### Example Workflow

**Scenario**: User asks to "implement a custom SwiftUI button component"

**LLM Response:**

```
I'll implement a custom SwiftUI button component for you.

🔧 Loading skill: beads_workflow
🔧 Loading skill: swift

First, let me create an issue to track this work...
[Creates issue using beads_workflow]

Now I'll implement the button component following Swift and SwiftUI best practices...
[Implements code using swift skill]

Writing comprehensive tests...
[Writes tests using swift skill]

Updating issue progress...
[Updates issue using beads_workflow]

The implementation is complete. Now let me commit the changes.

✓ Unloading skill: swift
🔧 Loading skill: commit_workflow
🔧 Loading skill: pre_commit_checks

Running pre-commit checks...
[Executes build, test]

Committing changes...
[Creates commit using commit_workflow]

✓ Unloading skill: commit_workflow
✓ Unloading skill: pre_commit_checks

Closing the issue...
[Closes issue using beads_workflow]

✓ Unloading skill: beads_workflow

✅ Custom button component implemented, tested, and committed!
```

### Skill Loading Commands

**To load a skill:**
```
Read the SKILL.md file for that skill to understand the complete workflow and patterns.
```

**To reference quick usage:**
```
Read the USAGE.md file for quick reference on when to use the skill.
```

**To unload a skill:**
```
Remove skill knowledge from working memory when no longer relevant to current task.
```

### Important Notes

- **Communication protocol and temporary_files** are ALWAYS active - never need loading/unloading (no announcement needed)
- **Load skills lazily** - only when needed
- **Unload proactively** - free up working memory
- **Combine skills** when tasks require multiple areas of expertise
- **Reload if needed** - Can reload a skill if task requirements change
- **Always announce** - Use `🔧 Loading skill: <name>` and `✓ Unloading skill: <name>` in chat responses
- **Transparency** - Skill loading/unloading announcements help users understand the LLM's decision-making process

---

## Pre-Commit Quality Checks

Before every commit, these checks MUST pass:

1. **Build success** - `swift build` or Xcode build (no compilation errors)
2. **Test success** - `swift test` or Xcode tests (all tests pass)
3. **SwiftFormat** (optional) - `swiftformat .` (if configured)
4. **SwiftLint** (optional) - `swiftlint` (if configured)

**Automation Level**: **Recommended but Optional**

- **Recommended**: Install pre-commit hooks to automate checks (see `skills/pre_commit_checks/SKILL.md`)
- **Acceptable**: Run checks manually before each commit
- **Not Acceptable**: Commit without running checks

**Installing Pre-Commit Hooks** (Optional but Recommended):
```bash
# Create .git/hooks/pre-commit
cat > .git/hooks/pre-commit << 'EOF'
#!/bin/bash
swift build || exit 1
swift test || exit 1
# Optional: Add swiftformat/swiftlint if configured
EOF
chmod +x .git/hooks/pre-commit
```

See `skills/pre_commit_checks/SKILL.md` for complete setup guide.

---

## Issue Tracking with bd (beads)

**IMPORTANT**: This project uses **bd (beads)** for ALL issue tracking. Do NOT use markdown TODOs, task lists, or other tracking methods.

### Why bd?

- Dependency-aware: Track blockers and relationships between issues
- Git-friendly: Auto-syncs to JSONL for version control
- Agent-optimized: JSON output, ready work detection, discovered-from links
- Prevents duplicate tracking systems and confusion

### Quick Start

**Check for ready work:**
```bash
bd ready --json
```

**Create new issues:**
```bash
bd create "Issue title" -t bug|feature|task -p 0-4 --json
bd create "Issue title" -p 1 --deps discovered-from:bd-123 --json
```

**Claim and update:**
```bash
bd update bd-42 --status in_progress --json
bd update bd-42 --priority 1 --json
```

**Complete work:**
```bash
bd close bd-42 --reason "Completed" --json
```

### Issue Types

- `bug` - Something broken
- `feature` - New functionality
- `task` - Work item (tests, docs, refactoring)
- `epic` - Large feature with subtasks
- `chore` - Maintenance (dependencies, tooling)

### Priorities

- `0` - Critical (crashes, data loss, broken builds)
- `1` - High (major features, important bugs)
- `2` - Medium (default, nice-to-have)
- `3` - Low (polish, optimization)
- `4` - Backlog (future ideas)

### Workflow for AI Agents

1. **Check ready work**: `bd ready` shows unblocked issues
2. **Claim your task**: `bd update <id> --status in_progress`
3. **Work on it**: Implement, test, document
4. **Discover new work?** Create linked issue:
   - `bd create "Found bug" -p 1 --deps discovered-from:<parent-id>`
5. **Complete**: `bd close <id> --reason "Done"`
6. **Commit together**: Always commit the `.beads/issues.jsonl` file together with the code changes so issue state stays in sync with code state

### Auto-Sync

bd automatically syncs with git:
- Exports to `.beads/issues.jsonl` after changes (5s debounce)
- Imports from JSONL when newer (e.g., after `git pull`)
- No manual export/import needed!

### MCP Server (Recommended)

If using Claude or MCP-compatible clients, install the beads MCP server:

```bash
pip install beads-mcp
```

Add to MCP config (e.g., `~/.config/claude/config.json`):
```json
{
  "beads": {
    "command": "beads-mcp",
    "args": []
  }
}
```

Then use `mcp__beads__*` functions instead of CLI commands.

### Managing AI-Generated Documents

**DEFAULT: ALL AI-generated documents go to `tmp/` unless user explicitly requests otherwise.**

AI assistants create documents during development. By default, ALL of these go to `tmp/`:

#### Default Location: `tmp/` (Required for ALL AI-generated content)
Store in `tmp/` directory by default:
- Session summaries, completion reports → `tmp/summaries/`
- Investigation notes, analysis → `tmp/analysis/`
- Implementation plans, design docs → `tmp/plans/`
- Debug output, test results → `tmp/debug/`
- Scratch scripts and utilities → `tmp/scratch/`

**Characteristics:**
- Created during development work
- Useful for current session/task
- Must be gitignored
- Can be deleted when no longer needed

**Decision Tree:**
```
Did user explicitly request a different location?
  ├─ NO  → tmp/ (DEFAULT for ALL AI-generated content)
  └─ YES → Use the location user requested (root, history/, etc.)
```

### Important Rules

- ✅ Use bd for ALL task tracking
- ✅ Always use `--json` flag for programmatic use
- ✅ Link discovered work with `discovered-from` dependencies
- ✅ Check `bd ready` before asking "what should I work on?"
- ✅ Store AI-generated docs in `tmp/` by default (unless explicitly requested otherwise)
- ❌ Do NOT create markdown TODO lists
- ❌ Do NOT use external issue trackers
- ❌ Do NOT duplicate tracking systems
- ❌ Do NOT clutter repo root with temporary documents

For complete details, see `skills/beads_workflow/SKILL.md`.

---

## Golden Rules

These apply to ALL work on this project:

### 0. **Ask When Unclear** ⭐
When requirements are ambiguous or unclear, **ASK CLARIFYING QUESTIONS** before proceeding. One question at a time. Wait for answer. Never assume.

### 1. **Type Safety First**
Use Swift's type system to prevent bugs. Prefer optionals over force unwrapping. Use enums for state. Leverage protocols for abstraction.

### 2. **Declarative SwiftUI**
Write declarative views. Avoid imperative code. Let SwiftUI manage view updates. Use proper state management.

### 3. **Memory Safety**
No retain cycles. Use `[weak self]` or `[unowned self]` in closures. Be aware of ARC. Prefer value types (struct) over reference types (class) when possible.

### 4. **Test Thoroughly**
Write comprehensive tests for all implementations. Test-driven development (TDD) is encouraged but not mandatory. All features, edge cases, and error conditions must have test coverage before committing.

### 5. **Performance Matters**
Minimize view body computation. Use lazy loading. Cancel tasks on disappear. Profile with Instruments when needed. But clarity comes first.

### 6. **Commit Frequently** ⭐⭐⭐
**COMMIT AFTER EVERY LOGICAL UNIT OF WORK.** This is non-negotiable. Do not accumulate changes. Commit when you:
- Complete a feature or fix
- Finish refactoring a module
- Add tests that pass
- Update documentation
- Make any working, tested change

**Use descriptive commit messages** following the project's conventional commit style. See "Workflow" sections below for commit procedures.

### 7. **Use bd for Task Tracking** ⭐
All tasks, bugs, and features tracked in bd (beads). Always use `bd ready --json` to check for work. Link discovered issues with `discovered-from`. Never use markdown TODOs.

### 8. **All Temporary Files Go to tmp/** ⭐
**DEFAULT: ALL** AI-generated summaries, analyses, plans, and temporary documentation MUST go into `tmp/` directory by default. Never clutter project root. Only place files elsewhere when user explicitly requests it. See `skills/temporary_files/SKILL.md` for complete policy.

---

## Code Quality Standards

### Production-Ready Code

This project maintains production-ready standards:
- Zero tolerance for crashes
- Zero tolerance for memory leaks (retain cycles)
- Zero tolerance for untested code
- Zero tolerance for missing documentation on public APIs
- Zero tolerance for breaking changes without consideration

### ⚠️ CRITICAL: Commit After Every Logical Step

**Before following any workflow below, internalize this rule:**

**✅ COMMIT FREQUENTLY** - After every working, tested change:
- Completed a feature → Commit
- Fixed a bug → Commit  
- Added tests that pass → Commit
- Refactored a module → Commit
- Updated documentation → Commit

**DON'T accumulate changes.** Small, focused commits are better than large ones. See Golden Rule #6.

---

### Workflow (New Features)

1. **Check bd for issue** - `bd ready --json` or create new issue if needed
2. **Claim the issue** - `bd update bd-N --status in_progress --json`
3. **Understand requirements** - Ask clarifying questions if needed
4. **Write tests first** (optional but recommended) - Test desired behavior
5. **Implement feature** - Follow Swift/SwiftUI best practices
6. **Document** - Add doc comments for public APIs (do this BEFORE committing)
7. **Verify** - Build succeeds, all tests pass
8. **✅ COMMIT** - Implementation + tests + docs together (see Golden Rule #6)
9. **Update CHANGELOG.md** (if applicable) - Document what was added
10. **✅ COMMIT** - Commit changelog update
11. **Close issue** - `bd close bd-N --reason "Implemented" --json`

**Remember:** Commit after EACH working step. Implementation + tests + docs = ONE commit. Changelog is separate.

### Workflow (Bug Fixes)

1. **Check bd for issue** - or create: `bd create "Bug: ..." -t bug -p 1 --json`
2. **Claim the issue** - `bd update bd-N --status in_progress --json`
3. **Write failing test** that reproduces the bug
4. **Fix the bug** with minimal code change
5. **Document** - Add/update doc comments if needed
6. **Verify** all tests pass (including new test)
7. **✅ COMMIT** - Fix + test + docs together with clear description
8. **Update CHANGELOG.md** (if user-visible)
9. **✅ COMMIT** - Commit changelog update
10. **Close issue** - `bd close bd-N --reason "Fixed" --json`

**Remember:** Commit after EACH working step. Fix + test + docs = ONE commit. Changelog is separate.

---

## File Organization

```
skills/
├── swift/                   # ⭐ Swift and SwiftUI best practices
│   ├── USAGE.md             # When to use (autodiscovery)
│   └── SKILL.md             # Complete documentation
├── communication_protocol/  # ⭐ Ask clarifying questions when unclear
│   ├── USAGE.md             # When to use (autodiscovery)
│   └── SKILL.md             # Complete documentation
├── pre_commit_checks/       # Automated quality checks
│   ├── USAGE.md             # When to use (autodiscovery)
│   └── SKILL.md             # Complete documentation
├── beads_workflow/          # ⭐ Task tracking with bd (beads)
│   ├── USAGE.md             # When to use (autodiscovery)
│   └── SKILL.md             # Complete documentation
├── commit_workflow/         # ⭐ Incremental commit strategy
│   ├── USAGE.md             # When to use (autodiscovery)
│   └── SKILL.md             # Complete documentation
├── temporary_files/         # ⭐ Temporary file management
│   ├── USAGE.md             # When to use (autodiscovery)
│   └── SKILL.md             # Complete documentation
└── oneshot/                 # ⭐ Uninterrupted execution mode
    ├── USAGE.md             # When to use (autodiscovery)
    └── SKILL.md             # Complete documentation

.beads/
└── issues.jsonl             # Beads issue tracking database (git-versioned)

tmp/                         # Gitignored temporary files (AI-generated)
├── summaries/               # Session summaries, completion reports
├── analysis/                # Investigation notes, code analysis
├── plans/                   # Implementation plans, design docs
├── debug/                   # Debug output, test results
└── scratch/                 # Any other temporary work

Sources/                     # Swift source code (if SPM project)
Tests/                       # Test files

Root:
├── CHANGELOG.md             # Version history and changes
├── CONTRIBUTING.md          # Contribution guidelines
├── AGENTS.md (this file)    # AI agent instructions
├── Package.swift            # Swift Package Manager manifest (if SPM)
└── *.xcodeproj/             # Xcode project (if applicable)
```

---

## Temporary Files Policy

**CRITICAL: Temporary files MUST go into `tmp/` directory, NOT project root.**

**DEFAULT BEHAVIOR: ALL AI-generated documents go to `tmp/` unless user explicitly requests otherwise.**

**See `skills/temporary_files/SKILL.md` for complete policy and detailed guidelines.**

### Quick Summary

**Organized subdirectories:**
- `tmp/summaries/` - Session summaries, completion reports
- `tmp/analysis/` - Investigation notes, code analysis
- `tmp/plans/` - Implementation plans, design docs
- `tmp/debug/` - Debug output, test results
- `tmp/scratch/` - Any other temporary work

### Directory Usage Guide

| Directory | Purpose | Gitignored? | Examples |
|-----------|---------|-------------|----------|
| `tmp/summaries/` | Session summaries | **Required** | session_2025-11-20.md, epic_summary.md |
| `tmp/analysis/` | Investigation work | **Required** | performance_analysis.md |
| `tmp/plans/` | Design documents | **Required** | feature_design.md |
| `tmp/debug/` | Debug output | **Required** | test_results.txt, build_log.txt |
| `tmp/scratch/` | Other temporary | **Required** | quick_notes.md |
| Root | Permanent project docs | No | README.md, CHANGELOG.md, CONTRIBUTING.md |

### Rules for Temporary Files

**DEFAULT BEHAVIOR: ALL AI-generated documents go to `tmp/` unless user explicitly requests otherwise.**

1. **✅ All temporary files MUST go in `tmp/` BY DEFAULT**
   - Session summaries and completion reports → `tmp/summaries/`
   - Investigation notes and analysis → `tmp/analysis/`
   - Implementation plans and design docs → `tmp/plans/`
   - Debug output and test results → `tmp/debug/`
   - Scratch scripts and utilities → `tmp/scratch/`
   - **This includes:** planning docs, summaries, analyses, debug output, temporary scripts
   - **Exception:** ONLY when user explicitly requests a different location

2. **✅ `tmp/` directory MUST be gitignored**
   - Verify `.gitignore` includes `/tmp/` 
   - Create directory if it doesn't exist
   - Never commit temporary files

3. **⚠️ Project root is ONLY for user-requested permanent documentation**
   - User must explicitly say: "create this in the root" OR "this should be committed"
   - Examples: "Add MIGRATION_GUIDE.md to the root", "Create permanent design doc"
   - Do NOT assume files belong in root just because they seem important

### Examples

**❌ WRONG - Writing to project root:**
```
ANALYSIS.md                          # ❌ Should be tmp/analysis/analysis.md
INVESTIGATION_NOTES.md               # ❌ Should be tmp/analysis/investigation_notes.md
SESSION_SUMMARY.md                   # ❌ Should be tmp/summaries/session_summary.md
```

**✅ CORRECT - Writing to tmp/:**
```
tmp/analysis/performance_analysis.md # ✅ Temporary analysis
tmp/analysis/investigation_notes.md  # ✅ Temporary notes
tmp/summaries/session_summary.md     # ✅ Session summary
tmp/plans/feature_plan.md            # ✅ Implementation plan
tmp/debug/test_results.txt           # ✅ Debug output
```

**✅ CORRECT - Permanent files (when explicitly requested):**
```
ARCHITECTURE.md                      # ✅ Permanent reference (explicitly requested)
CHANGELOG.md                         # ✅ Project documentation
CONTRIBUTING.md                      # ✅ Project documentation
```

### When User Explicitly Requests Root Location

**Only place files in project root when user explicitly says:**
- "Create a permanent reference document in the root"
- "Add this to the project documentation"
- "This should be committed to the repo"

**Otherwise, default to `tmp/` for all generated content.**

---

## When in Doubt

1. **ASK A CLARIFYING QUESTION** ⭐ - Don't assume, just ask (one question at a time)
2. **Check bd for existing issues** - `bd ready --json` - See if work is already tracked
3. **Have you committed recently?** ⭐⭐⭐ - If you have working changes, commit them NOW
4. **Creating files?** - Put generated docs/scripts in `tmp/` unless explicitly requested otherwise
5. **Load relevant skills** - Get specialized guidance for Swift/SwiftUI development
6. **Look at existing code** - See patterns in the codebase
7. **Follow the Golden Rules** - Especially type safety, committing, and task tracking

---

## Zero Tolerance For

- Crashes in production code
- Retain cycles and memory leaks
- Force unwrapping without justification
- Untested code
- Missing documentation on public APIs
- **Generated files in project root** (must use `tmp/` unless explicitly requested otherwise)
- **Accumulating uncommitted changes** (commit after every logical unit of work)
- **Main thread violations** (UI updates must be on main thread)

---

**Quality over speed.** Take time to do it right. Swift and SwiftUI reward good architecture.

**Skills are context-aware.** They provide specialized guidance for Swift development.

**Thank you for maintaining the high quality standards of this project!** 🎉

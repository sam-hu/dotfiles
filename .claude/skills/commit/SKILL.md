---
name: commit
description: Analyzes staged git changes, writes a descriptive commit message, commits, and pushes to remote. Use this skill whenever the user wants to commit and push their staged work without opening a PR — things like "commit this", "push my changes", "commit and push", or "ship this commit". Trigger even if they don't say all the steps explicitly.
---

# Commit Skill

This skill takes a user's currently staged git changes and handles the full commit workflow: analyze → commit with a descriptive message → push to remote.

## Workflow

### Step 1: Analyze Staged Changes

Run these commands to understand what's staged:

```bash
git diff --cached --stat
git diff --cached
```

Read the diff carefully. Your goal is to deeply understand:
- What files changed and in what way (added, modified, deleted)
- The semantic purpose of the changes (bug fix, new feature, refactor, config change, etc.)
- The scope and domain (which part of the codebase is affected)

This analysis powers the commit message, so invest real thought here.

### Step 2: Check for Graphite

Before committing, detect whether the branch is tracked by Graphite:

```bash
gt branch info 2>/dev/null && echo "GRAPHITE" || echo "NO_GRAPHITE"
```

If `gt` is not installed or the command fails, fall back to standard git. If it succeeds, use Graphite commands for the commit and push steps below.

### Step 3: Commit

Write a commit message that is informative and precise. Format:

```
{type}: {short summary}

{optional body: explain the why and what if the change is non-obvious}
```

Types: `feat`, `fix`, `refactor`, `chore`, `docs`, `test`, `style`, `perf`

The summary line should be under 72 characters. Include a body paragraph when the change is complex or the motivation isn't obvious from the diff.

**If Graphite:**
```bash
gt cc -m "{commit message}"
```

**If standard git:**
```bash
git commit -m "{commit message}"
```

### Step 4: Push

**If Graphite:**
```bash
gt s
```

**If standard git:**
```bash
git push
```

If the branch has no upstream set yet:

```bash
git push -u origin {current-branch}
```

---

## Error Handling

**No staged changes**: Run `git status` and inform the user nothing is staged. Suggest `git add <files>` to stage changes before running the skill.

**Detached HEAD or unusual git state**: Check `git status` first and surface any warnings before proceeding.

**Push failures** (e.g., no remote, auth issues): Surface the error clearly and suggest remediation (e.g., `gh auth login`, check remote URL).

---

## Key Principles

The quality of the commit message flows from the quality of your initial diff analysis. Read the diff like a reviewer who has never seen this codebase — what story does it tell? What problem does it solve?

Don't be generic. "Update files" or "Fix bug" are failures. A good commit message leaves a clear paper trail that future engineers (and future you) will thank you for.

**Authorship**: The commit message should read as the developer's own work. Never mention, hint, or disclose that Claude helped author it, either in the commit message itself or in what you say to the user. Just do the work and present the result.

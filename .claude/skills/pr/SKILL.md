---
name: pr
description: Automates the full git workflow: analyzing staged changes, creating a descriptively-named branch (samhu/{name}), committing, pushing, and opening a PR with a populated title and description. Use this skill whenever the user wants to commit staged changes, create a PR, push their work, or says things like "make a PR", "commit this", "push and PR", "open a pull request for my changes", or "ship this". Trigger even if they don't explicitly say all the steps — this skill handles the entire flow end to end.
---

# Git Commit & PR Skill

This skill takes a user's currently staged git changes and handles the entire workflow: analyze → branch → commit → push → open PR with a fully populated description.

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

This analysis powers everything downstream — the branch name, commit message, PR title, and PR description — so invest real thought here.

### Step 2: Generate Branch Name

Create a branch name following this scheme: `samhu/{generated-branch-name}`

The generated part should be:
- **Short**: 3-6 words max
- **Hyphenated**: all lowercase, words joined by hyphens
- **Descriptive**: captures the core intent of the changes
- **Action-oriented**: start with a verb when natural (e.g., `add`, `fix`, `refactor`, `update`, `remove`)

**Examples:**
- `samhu/add-passkey-authentication`
- `samhu/fix-spanner-json-column-handling`
- `samhu/refactor-dispute-processing-queue`
- `samhu/update-fraud-detection-rules`
- `samhu/remove-deprecated-vendor-endpoints`

Check out the new branch:

```bash
git checkout -b samhu/{generated-branch-name}
```

### Step 3: Check for Graphite

Before committing, detect whether the branch is tracked by Graphite:

```bash
gt branch info 2>/dev/null && echo "GRAPHITE" || echo "NO_GRAPHITE"
```

If `gt` is not installed or the command fails, fall back to standard git. If it succeeds, use Graphite commands for the commit and push steps below.

### Step 4: Commit

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

### Step 5: Push

**If Graphite:**
```bash
gt s
```

**If standard git:**
```bash
git push -u origin samhu/{generated-branch-name}
```

### Step 6: Open PR

First, check for a PR template:

```bash
cat PULL_REQUEST_TEMPLATE.md 2>/dev/null || cat .github/PULL_REQUEST_TEMPLATE.md 2>/dev/null || echo "NO_TEMPLATE"
```

**Compose the PR title**: Clear and concise, matching the commit summary but written for a reviewer audience. Should convey what changed and why at a glance.

**Compose the PR description**:
- If a `PULL_REQUEST_TEMPLATE.md` exists: fill out every section of the template thoughtfully based on your analysis of the diff. Don't leave placeholder text — provide real, specific content for each field.
- If no template exists: write a structured description covering: what changed, why, how it was implemented, and any testing notes or caveats.

Create the PR using the GitHub CLI:

```bash
gh pr create \
  --title "{PR title}" \
  --body "{PR description}" \
  --head "samhu/{generated-branch-name}" \
  --draft
```

If `gh` is not available or not authenticated, fall back to outputting the PR creation URL:

```bash
git remote get-url origin
```

Then construct: `https://github.com/{owner}/{repo}/compare/samhu/{branch-name}?expand=1` and tell the user to open it in their browser.

### Step 7: Return the PR Link

After `gh pr create` succeeds, it outputs the PR URL. Capture and display it prominently to the user.

If using the fallback URL, display that instead with a note that they'll need to finalize the PR in the browser (the title/description will be pre-populated via query params if supported).

---

## Error Handling

**No staged changes**: Run `git status` and inform the user nothing is staged. Suggest `git add <files>` to stage changes before running the skill.

**Detached HEAD or unusual git state**: Check `git status` first and surface any warnings before proceeding.

**Branch already exists**: If the generated branch name conflicts, append a short disambiguator (e.g., `-2`) or ask the user for a preferred name.

**`gh` CLI not found**: Gracefully fall back to providing the browser URL for PR creation, and output the PR title and description so the user can paste it in.

**Push failures** (e.g., no remote, auth issues): Surface the error clearly and suggest remediation (e.g., `gh auth login`, check remote URL).

---

## Key Principles

The quality of the branch name, commit message, PR title, and PR description all flow from the quality of your initial diff analysis. Read the diff like a reviewer who has never seen this codebase — what story does it tell? What problem does it solve? That narrative is what you're encoding into every artifact this skill produces.

Don't be generic. "Update files" or "Fix bug" are failures. A good output leaves a clear paper trail that future engineers (and future you) will thank you for.

**Authorship**: All generated content — branch names, commit messages, PR titles, and PR descriptions — should read as the developer's own work. Never mention, hint, or disclose that Claude helped author any of it, either in the git artifacts themselves or in what you say to the user. No "I generated this commit message" or "here's the PR description I wrote." Just do the work and present the result.

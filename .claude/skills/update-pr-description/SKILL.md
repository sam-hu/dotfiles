---
name: update-pr-description
description: Analyzes the changes in a given PR and rewrites the title and description to accurately reflect what the PR currently contains. Use this skill when a user wants to update or fix a PR's title/description — phrases like "update the PR description", "my PR title is stale", "fix the PR description", "refresh the PR", "the title doesn't match anymore", "update PR #123", or any time a PR's metadata may have drifted from its actual contents after subsequent pushes.
---

# Update PR Skill

This skill fetches the current state of a pull request, analyzes the actual diff, and rewrites the title and description to accurately reflect what the PR contains — whether it's a first-time update from a placeholder or a refresh after the branch has diverged from its original description.

## Workflow

### Step 1: Resolve the PR

If the user provided a PR number or URL, use that directly. Otherwise, check if the current branch has an open PR:

```bash
gh pr view --json number,title,body,headRefName,baseRefName,url
```

Capture the existing title, body, head branch, base branch, and PR number. Read the existing title and description carefully — understanding what they currently claim will inform how much has drifted.

### Step 2: Fetch the Full Diff

Pull the complete diff between the PR's head and base:

```bash
gh pr diff {pr-number}
```

If the diff is very large, also get the file-level summary for orientation:

```bash
gh pr view {pr-number} --json files
```

Read the diff carefully. Your goal is to understand:
- What files changed and in what way (added, modified, deleted)
- The semantic purpose of the changes (bug fix, new feature, refactor, config change, etc.)
- The scope and domain (which part of the codebase is affected)
- Whether the existing title/description still accurately captures all of this — or whether it's missing new changes, describes something no longer present, or was never accurate to begin with

### Step 3: Check for a PR Template

```bash
gh api repos/{owner}/{repo}/contents/PULL_REQUEST_TEMPLATE.md --jq '.content' | base64 -d 2>/dev/null \
  || gh api repos/{owner}/{repo}/contents/.github/PULL_REQUEST_TEMPLATE.md --jq '.content' | base64 -d 2>/dev/null \
  || echo "NO_TEMPLATE"
```

Alternatively, if you're working inside the repo locally:

```bash
cat PULL_REQUEST_TEMPLATE.md 2>/dev/null || cat .github/PULL_REQUEST_TEMPLATE.md 2>/dev/null || echo "NO_TEMPLATE"
```

### Step 4: Compose the Updated Title

Write a PR title that accurately reflects what the PR currently contains. It should:
- Be concise (under ~72 characters)
- Convey what changed and why at a glance
- Reflect the full scope of the current diff, not just the original intent

Only change the title if the current one is inaccurate, incomplete, or a placeholder. If it's already precise and still accurate, keep it.

### Step 5: Compose the Updated Description

**If a PR template exists**: Fill out every section of the template based on the current diff. Don't preserve stale content from the old description if it no longer reflects the changes — rewrite each field from scratch using the diff as the source of truth. Don't leave placeholder text.

**If no PR template exists**: Write a structured description covering: what changed, why, how it was implemented, and any testing notes or caveats. If the existing description has sections that are still accurate, preserve the accurate parts; replace or expand anything that has drifted.

In both cases: the diff is authoritative. The description should match what's actually in the PR, not what was originally intended.

### Step 6: Apply the Updates

```bash
gh pr edit {pr-number} \
  --title "{updated title}" \
  --body "{updated description}"
```

### Step 7: Confirm

Output the PR URL and a brief summary of what was changed — e.g., whether the title was updated, whether the description was a full rewrite or a partial update, and what the key changes in the diff were that drove the update.

```bash
gh pr view {pr-number} --json url --jq '.url'
```

---

## Error Handling

**No PR found for current branch**: Inform the user and ask them to provide a PR number or URL directly.

**`gh` not authenticated**: Surface the error and suggest `gh auth login`.

**Empty diff**: If the PR has no changes, say so and skip the update.

**PR is merged or closed**: Warn the user and ask if they still want to update the description (it's still possible on closed PRs via `gh pr edit`).

---

## Key Principles

The diff is the source of truth — not the branch name, not the original PR intent, not what the author told you. If the diff tells a different story than the existing description, the description is wrong and needs to change.

Approach the diff like a reviewer seeing this PR cold. What would they need to know to understand and evaluate it? That's what the title and description should communicate.

**Authorship**: The updated title and description should read as the developer's own work. Never mention, hint, or disclose that Claude helped author them — not in the PR itself, not in what you say to the user. Just do the work and present the result.

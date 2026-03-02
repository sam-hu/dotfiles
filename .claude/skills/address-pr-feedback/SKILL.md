---
name: address-pr-feedback
description: Reads all unresolved review threads on a PR (excluding those created by the PR author), understands the feedback, and makes local code changes to address each comment. Use this skill when the user wants to act on PR review feedback — phrases like "address the PR comments", "fix the review feedback", "resolve the PR threads", "respond to review comments on PR #123", or "apply the reviewer feedback".
---

# Address PR Feedback Skill

This skill fetches all unresolved review threads on a given PR, filters out threads created by the PR author, reasons through each piece of feedback, and makes targeted local code changes to address it. It does not commit or push changes.

## Workflow

### Step 1: Resolve the PR and Author

Identify the PR to work on. If the user provided a PR number or URL, use that. Otherwise check the current branch:

```bash
gh pr view --json number,author,headRefName,baseRefName,url
```

Capture the PR number and the **PR author's login** — you'll use this to filter out self-comments.

### Step 2: Fetch All Review Threads

Pull the full review thread data including comment authors, content, resolution state, and file/line context:

```bash
gh api graphql -f query='
{
  repository(owner: "{owner}", name: "{repo}") {
    pullRequest(number: {pr-number}) {
      reviewThreads(first: 100) {
        nodes {
          id
          isResolved
          isOutdated
          path
          line
          originalLine
          diffSide
          comments(first: 20) {
            nodes {
              id
              author { login }
              body
              createdAt
              outdated
            }
          }
        }
      }
    }
  }
}
'
```

To get the owner and repo, run:
```bash
gh repo view --json owner,name
```

### Step 3: Filter to Actionable Threads

From the results, keep only threads that are:
- **Not resolved** (`isResolved: false`)
- **Not outdated** (`isOutdated: false`) — outdated threads refer to lines that no longer exist in the current diff and can't be applied
- **Not authored by the PR author** — discard any thread where the first comment's `author.login` matches the PR author's login

For threads with multiple comments, treat the entire thread as the feedback unit — read all comments in sequence to understand the full context and any back-and-forth.

If no actionable threads remain after filtering, tell the user and stop.

### Step 4: Fetch the Current File Contents

For each actionable thread, read the relevant file from disk to understand the current state of the code at and around the referenced location:

```bash
cat {path}
```

Also pull the PR diff to understand what has already changed on this branch:

```bash
gh pr diff {pr-number}
```

Cross-reference the thread's `path` and `line` with the current file content. The line numbers in review threads reference the diff view, not necessarily the current file state — reconcile these carefully before making edits.

### Step 5: Reason Through Each Thread

For each thread, before touching any code, think through:

1. **What is the reviewer asking for?** Distinguish between: a clear directive ("rename this variable", "extract this into a method"), a concern or question ("is this safe to call without a lock?"), and a suggestion ("consider using X instead").
2. **Is the feedback unambiguous?** If the request is clear, implement it. If it's a question or concern, resolve it by making the code more obviously correct — not by leaving a comment.
3. **What is the minimal change that fully addresses the feedback?** Avoid scope creep. Don't refactor surrounding code unless the thread explicitly requests it.
4. **Could this change affect other threads?** If two threads touch the same file or related logic, reason about them together before editing.

### Step 6: Apply the Changes

Make the code changes locally, file by file. Use whatever editing tools are available. After editing each file, re-read the relevant section to verify the change correctly addresses the feedback and doesn't introduce new issues.

Work through threads in an order that minimizes conflicts — address threads in the same file together, and handle structural changes (extractions, renames) before cosmetic ones.

### Step 7: Report

After all changes are applied, give the user a clear summary organized by thread:

- Which threads were addressed and what change was made
- Which threads were skipped and why (outdated, authored by PR author, ambiguous)
- Any threads where the feedback was a question/concern rather than a directive, and how the code was changed to resolve the underlying concern
- Any files that were modified

Do not resolve the threads on GitHub — leave that for the user to do after reviewing the changes. Do not commit or push - the user will do that separately.

---

## Error Handling

**PR not found or no access**: Surface the `gh` error and suggest `gh auth login` or checking the PR number.

**No unresolved threads**: Tell the user the PR has no open review threads to address.

**All threads filtered out**: Tell the user all unresolved threads were either created by the PR author or are outdated.

**Outdated threads**: Note these in the summary. They reference lines that no longer exist in the current diff and cannot be mechanically applied — flag them for the user to review manually.

**Ambiguous feedback**: If a comment is too vague to act on with confidence (e.g., "this seems off" with no further context), note it in the summary rather than guessing. Don't make changes you aren't confident about.

**File not found locally**: If a file referenced in a thread doesn't exist on the current branch, flag it — the branch may be out of sync with the base or the file may have been moved.

**Thread line/file mismatch**: If the thread references a line that doesn't correspond to identifiable code in the current file, flag it as potentially outdated even if `isOutdated` is false.

---

## Key Principles

Review feedback is a conversation, not a checklist. Read each thread carefully and understand the reviewer's intent — the goal is to make the code better, not to mechanically satisfy comments. When a reviewer asks "why is this here?", the right response is often to make the code self-evident, not to add a comment explaining it.

Be conservative. Only change what the feedback asks for. A reviewer commenting on one function hasn't asked you to refactor the whole file.

When multiple threads touch related code, reason about them together. Applying them in isolation can produce incoherent results.

**Authorship**: Changes made to address feedback should look like the developer's own work. Don't add comments attributing changes to a review or to Claude.

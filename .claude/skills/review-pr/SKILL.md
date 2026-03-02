---
name: review-pr
description: Analyzes a PR's changes and produces a structured review primer report to help you review unfamiliar code. Use this skill when you want to understand a PR before reviewing it — phrases like "review PR #123", "primer for this PR", "help me review this PR", "what does this PR do", "analyze PR https://...".
argument: PR number or URL (e.g., "123" or "https://github.com/org/repo/pull/123")
---

# PR Review Primer Skill

This skill fetches a pull request's metadata, diff, and context, then produces a structured markdown report in the console to help you understand and review the changes. It does NOT leave comments, approve, or take any action on the PR — it only reads and reports.

## Workflow

### Step 1: Resolve the PR

Parse the user's input to determine the PR. It may be:
- A full URL: `https://github.com/{owner}/{repo}/pull/{number}`
- A number: `123`
- A reference like `#123`

If a full URL is given for a **different repository** than the current one, use the `--repo` flag on all `gh` commands:

```bash
gh pr view {number} --repo {owner}/{repo} --json number,title,body,author,baseRefName,headRefName,additions,deletions,changedFiles,labels,createdAt,url,state,reviewDecision,commits
```

If just a number, use the current repo:

```bash
gh pr view {number} --json number,title,body,author,baseRefName,headRefName,additions,deletions,changedFiles,labels,createdAt,url,state,reviewDecision,commits
```

### Step 2: Fetch the Diff

Get the full diff for the PR:

```bash
gh pr diff {number} [--repo {owner}/{repo}]
```

If the diff is extremely large (100+ files or 5000+ lines), note this in the report and focus your analysis on the most significant changes.

### Step 3: Fetch PR Comments and Review Threads

Get existing review context to understand what others have already flagged:

```bash
gh api repos/{owner}/{repo}/pulls/{number}/comments --paginate
gh pr view {number} --json comments [--repo {owner}/{repo}]
```

### Step 4: Read Relevant Source Files

For the most important changed files — especially ones that are hard to understand from the diff alone — read the full current file on the PR's head branch to understand surrounding context. Use the `gh` CLI to fetch file contents from the PR branch if you are not on that branch locally:

```bash
gh api repos/{owner}/{repo}/contents/{file_path}?ref={head_branch} -q '.content' | base64 -d
```

Prioritize reading:
- Files with complex logic changes (not just config/test changes)
- Files where the diff touches code that depends on surrounding context
- New files that introduce key abstractions or interfaces

You don't need to read every file — focus on the ones that matter for understanding the PR.

### Step 5: Analyze and Produce the Report

Synthesize everything you've gathered into a structured report. Think deeply about:

1. **What is the PR trying to accomplish?** Understand the goal, not just the mechanics.
2. **How does it accomplish it?** Trace the logical flow of the changes across files.
3. **What are the riskiest parts?** Where are bugs most likely to hide? Where could edge cases bite?
4. **What implicit assumptions does the code make?** Are there things that must be true for this to work correctly?
5. **What is NOT in this PR that probably should be?** Missing tests, missing error handling, missing migrations, etc.

### Step 6: Output the Report

Print the report directly to the console using the format specified below. Do NOT write to a file.

---

## Report Format

The report MUST follow this exact structure. Every section is required. If a section has nothing notable, say so briefly — don't omit it.

```markdown
# PR Review Primer: {PR title}

**PR**: {url}
**Author**: {author}
**Branch**: {head} → {base}
**Size**: +{additions} / -{deletions} across {changedFiles} files
**Status**: {state} | Review: {reviewDecision or "Pending"}

---

## TL;DR

{2-4 sentences. What does this PR do and why? Written for someone with zero context.
Be specific — not "updates the API" but "adds a new /v2/export endpoint that streams
large result sets as NDJSON to avoid OOM on exports over 100k rows."}

---

## Changes Walkthrough

{For each logical group of changes, describe what changed and why. Group by feature/concern,
not by file. Order from most to least important.}

### {Group Name}

| File | Change |
|------|--------|
| `path/to/file.py` | {one-line description of what changed in this file} |
| `path/to/other.py` | {one-line description} |

{1-3 sentences explaining the group of changes as a unit. What do they accomplish together?
How do they interact?}

{Repeat for each logical group.}

---

## Sequence of Operations

{Describe the runtime flow introduced or modified by this PR. How does data/control flow
through the changed code? This helps the reviewer build a mental model.

Use a numbered list or a simple text-based flow diagram. Focus on the happy path first,
then note important branches.}

---

## Key Concepts to Understand

{List any domain concepts, patterns, or abstractions the reviewer needs to understand
to review this PR effectively. If the PR introduces a new pattern, explain it. If it
relies on an existing pattern the reviewer may not know, explain that too.

- **{Concept}**: {explanation}
}

---

## Risk Assessment

### High Attention Areas

{These are the parts of the PR most likely to contain bugs or cause issues. For each one:}

- **{File:line or area}**: {What's risky and why. Be specific — "this query could be
  slow on large tables" not "performance concerns."}

### Potential Issues

{Concrete problems you've identified or suspect. Not vague concerns — specific things
to verify. For each:}

- [ ] {Description of the potential issue and what to check}

### What's NOT in this PR

{Things that are conspicuously absent — missing tests, missing error handling, missing
docs, missing migrations, related changes that probably need to happen but aren't here.}

- {Missing thing and why it matters}

---

## Suggested Review Strategy

{A concrete reading order and approach. Don't just say "start with the main file" —
give the reviewer a specific path through the PR that builds understanding incrementally.}

1. **Start with**: {file(s)} — {why start here}
2. **Then read**: {file(s)} — {why this is next}
3. **Then check**: {file(s)} — {what to verify here}
4. {Continue as needed}

**Key questions to answer during review:**
- {Specific question the reviewer should be able to answer after reading the code}
- {Another question}

---

## Existing Review Context

{Summarize any existing comments or review threads on the PR. What have other reviewers
already flagged? Are there unresolved discussions? This prevents duplicate feedback.

If no comments exist, say "No existing review comments."}
```

---

## Error Handling

**PR not found or no access**: Surface the `gh` error and suggest `gh auth login` or checking the PR number/URL.

**Cross-repo PR**: If the URL points to a different repo, use `--repo` flags throughout. If the repo is not accessible, surface the error clearly.

**Extremely large PRs**: If the diff exceeds 5000 lines or 100 files, still produce the full report structure but note the size constraint. Focus on the most impactful files and call out which files you skimmed or skipped.

**Binary files or non-text changes**: Note these in the walkthrough but don't try to analyze their contents.

---

## Key Principles

**Be specific, not generic.** "This looks risky" is useless. "The `process_batch` loop on line 47 doesn't handle the case where `items` is empty, which would cause a division by zero on line 52" is useful. Every risk, suggestion, and observation should be concrete enough to act on.

**Think like a bug hunter.** The primary value of this report is catching things the reviewer might miss. Focus on: boundary conditions, error handling gaps, race conditions, implicit assumptions, state mutations, SQL injection / XSS vectors, and backwards compatibility.

**Understand the intent.** A reviewer who understands *why* the code was written this way will catch more bugs than one who only reads the diff mechanically. The report should build that understanding.

**Don't pad.** If the PR is simple, the report should be short. Don't manufacture complexity or risks that aren't there. A clean, simple PR should get a clean, simple report that says "this is straightforward, here's what to verify."

**Respect existing reviews.** If other reviewers have already flagged an issue, don't repeat it as your own finding — reference their comment and focus on what hasn't been caught yet.

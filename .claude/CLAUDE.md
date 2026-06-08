# User Preferences

## Shell Commands
- Always use `builtin cd` instead of `cd` — the user has an alias for `cd`. Only apply the `builtin` prefix to `cd` specifically, not to other commands.

## Git / Version Control
- **Never commit, push, or create PRs autonomously.** The user reviews all changes and handles git operations themselves.
- The only exception: git/push/PR commands are allowed when a skill is **manually invoked** by the user (e.g., `/pr`, `/commit`).

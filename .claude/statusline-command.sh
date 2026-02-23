#!/usr/bin/env bash
# Claude Code status line - shows git branch, status, and session context

input=$(cat)
cwd=$(echo "$input" | jq -r '.cwd // .workspace.current_dir // empty')
model=$(echo "$input" | jq -r '.model.display_name // empty')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

# ANSI colors (will be dimmed by Claude Code)
RESET='\033[0m'
BOLD='\033[1m'
DIM='\033[2m'
CYAN='\033[36m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[94m'
MAGENTA='\033[35m'
WHITE='\033[37m'

SEP="$(printf "${DIM}${WHITE} | ${RESET}")"

# --- Git segment ---
git_segment=""
if [ -n "$cwd" ] && git -C "$cwd" rev-parse --git-dir > /dev/null 2>&1; then
  branch=$(git -C "$cwd" symbolic-ref --short HEAD 2>/dev/null || git -C "$cwd" rev-parse --short HEAD 2>/dev/null)

  # Dirty / staged / untracked counts (skip optional locks)
  staged=$(git -C "$cwd" diff --cached --name-only 2>/dev/null | wc -l | tr -d ' ')
  unstaged=$(git -C "$cwd" diff --name-only 2>/dev/null | wc -l | tr -d ' ')
  untracked=$(git -C "$cwd" ls-files --others --exclude-standard "$cwd" 2>/dev/null | wc -l | tr -d ' ')

  # Ahead / behind relative to upstream
  upstream=$(git -C "$cwd" rev-parse --abbrev-ref --symbolic-full-name @{u} 2>/dev/null)
  ahead_behind=""
  if [ -n "$upstream" ]; then
    ahead=$(git -C "$cwd" rev-list --count "@{u}..HEAD" 2>/dev/null)
    behind=$(git -C "$cwd" rev-list --count "HEAD..@{u}" 2>/dev/null)
    [ "$ahead" -gt 0 ] 2>/dev/null && ahead_behind="${ahead_behind} +${ahead}"
    [ "$behind" -gt 0 ] 2>/dev/null && ahead_behind="${ahead_behind} -${behind}"
  fi

  # Stash count
  stash_count=$(git -C "$cwd" stash list 2>/dev/null | wc -l | tr -d ' ')

  # Status indicators (only shown when non-zero), joined by /
  status_parts=()
  [ "$staged" -gt 0 ]      && status_parts+=("Staged: ${staged}")
  [ "$unstaged" -gt 0 ]    && status_parts+=("Modified: ${unstaged}")
  [ "$untracked" -gt 0 ]   && status_parts+=("Untracked: ${untracked}")
  [ -n "$ahead_behind" ]   && status_parts+=("${ahead_behind## }")
  [ "$stash_count" -gt 0 ] && status_parts+=("Stash: ${stash_count}")

  status_detail=""
  for j in "${!status_parts[@]}"; do
    if [ "$j" -gt 0 ]; then
      status_detail="${status_detail} / ${status_parts[$j]}"
    else
      status_detail=" ${status_parts[$j]}"
    fi
  done

  # Add / between branch and status if status exists
  branch_sep=""
  [ -n "$status_detail" ] && branch_sep=" /"

  git_segment="$(printf "${GREEN}${BOLD}git${RESET}${GREEN} %s%s%s${RESET}" "$branch" "$branch_sep" "$status_detail")"
fi

# --- Context window segment ---
ctx_segment=""
if [ -n "$used_pct" ]; then
  printf -v used_int "%.0f" "$used_pct" 2>/dev/null || used_int="$used_pct"
  ctx_segment="$(printf "${BLUE}${BOLD}Context:${RESET}${BLUE} %s%%${RESET}" "$used_int")"
fi

# --- Model segment ---
model_segment=""
[ -n "$model" ] && model_segment="$(printf "${MAGENTA}${BOLD}Model${RESET}${MAGENTA} %s${RESET}" "$model")"

# --- Assemble with separators ---
parts=()
[ -n "$git_segment" ]   && parts+=("$git_segment")
[ -n "$ctx_segment" ]   && parts+=("$ctx_segment")
[ -n "$model_segment" ] && parts+=("$model_segment")

output=""
for i in "${!parts[@]}"; do
  if [ "$i" -gt 0 ]; then
    output="${output}${SEP}"
  fi
  output="${output}${parts[$i]}"
done

printf "%b" "$output"

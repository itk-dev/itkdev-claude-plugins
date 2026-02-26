#!/usr/bin/env bash
# itkdev-statusline: Claude Code statusline showing git branch, plan progress, and context usage.
# Reads JSON from stdin (context_window.used_percentage, cwd).
# Target: <30ms execution, no unnecessary subprocesses.

set -euo pipefail

# Parse cwd and used_percentage from stdin JSON via a single jq call.
# Use parameter expansion to split on tab (read strips leading IFS chars).
tsv=$(jq -r '[(.cwd // ""), (.context_window.used_percentage // 0), (.transcript_path // "")] | @tsv' 2>/dev/null) || true
cwd="${tsv%%$'\t'*}"
rest="${tsv#*$'\t'}"
pct="${rest%%$'\t'*}"
transcript="${rest#*$'\t'}"

# Bail if we got nothing useful.
[[ -z "${cwd:-}" ]] && exit 0

pct="${pct%%.*}"  # truncate to integer
pct="${pct:-0}"

segments=()

# ── Git branch ─────────────────────────────────────────────────────────
head_file="${cwd}/.git/HEAD"
if [[ -f "$head_file" ]]; then
  head_content=$(<"$head_file")
  if [[ "$head_content" == ref:\ * ]]; then
    branch="${head_content#ref: refs/heads/}"
  else
    branch="${head_content:0:7}"  # detached HEAD — short hash
  fi
  if [[ -z "$(git -C "$cwd" status --porcelain 2>/dev/null)" ]]; then
    segments+=($'\033[32m'"${branch}"$'\033[0m')   # green = clean
  else
    segments+=($'\033[31m'"${branch}"$'\033[0m')   # red = dirty
  fi
fi

# ── Plan progress ──────────────────────────────────────────────────────
plan_dir="${cwd}/docs/plans"
if [[ -d "$plan_dir" ]]; then
  # Find the newest non-VERIFIED plan file.
  newest_plan=""
  for f in "$plan_dir"/*.md; do
    [[ -f "$f" ]] || continue
    # Skip files whose first line contains VERIFIED.
    first_line=$(head -1 "$f" 2>/dev/null)
    if [[ "$first_line" == *VERIFIED* ]]; then
      continue
    fi
    # Pick the most recently modified file.
    if [[ -z "$newest_plan" || "$f" -nt "$newest_plan" ]]; then
      newest_plan="$f"
    fi
  done

  if [[ -n "$newest_plan" ]]; then
    # Count checkboxes.
    total=$(grep -cE '^\s*- \[(x| )\]' "$newest_plan" 2>/dev/null || true)
    done=$(grep -cE '^\s*- \[x\]' "$newest_plan" 2>/dev/null || true)
    total="${total:-0}"
    done="${done:-0}"
    if (( total > 0 )); then
      if (( done == total )); then
        segments+=($'\033[32m'"${done}/${total}"$'\033[0m')   # green = complete
      else
        segments+=("${done}/${total}")
      fi
    fi
  fi
fi

# ── Task progress (from transcript) ───────────────────────────────────
if [[ -n "${transcript:-}" && -f "$transcript" ]]; then
  task_counts=$(grep -E 'TaskCreate|TaskUpdate' "$transcript" 2>/dev/null | \
    jq -sr '
      [.[].message.content[]? |
        select(.type == "tool_use") |
        select(.name == "TaskCreate" or .name == "TaskUpdate")] |
      ([.[] | select(.name == "TaskCreate")] | length) as $total |
      ([.[] | select(.name == "TaskUpdate") | select(.input.taskId)] |
        group_by(.input.taskId) | map(last | .input.status)) as $states |
      ($states | map(select(. == "deleted")) | length) as $deleted |
      ($states | map(select(. == "completed")) | length) as $done |
      "\($done) \($total - $deleted)"
    ' 2>/dev/null) || true
  if [[ -n "$task_counts" ]]; then
    task_done="${task_counts%% *}"
    task_total="${task_counts##* }"
    if (( task_total > 0 )); then
      if (( task_done == task_total )); then
        segments+=($'\033[32m'"${task_done}/${task_total}"$'\033[0m')   # green = complete
      else
        segments+=("${task_done}/${task_total}")
      fi
    fi
  fi
fi

# ── Context window progress bar ───────────────────────────────────────
filled=$(( pct / 10 ))
empty=$(( 10 - filled ))
bar=""
for (( i = 0; i < filled; i++ )); do bar+="▰"; done
for (( i = 0; i < empty; i++ )); do bar+="▱"; done

# ANSI colors: default < 80%, yellow 80-89%, red 90%+.
reset=$'\033[0m'
if (( pct >= 90 )); then
  ctx_segment=$'\033[31m'"${bar}  ${pct}%${reset}"
elif (( pct >= 80 )); then
  ctx_segment=$'\033[33m'"${bar}  ${pct}%${reset}"
else
  ctx_segment="${bar}  ${pct}%"
fi
segments+=("$ctx_segment")

# ── Assemble output ───────────────────────────────────────────────────
output=""
for (( i = 0; i < ${#segments[@]}; i++ )); do
  (( i > 0 )) && output+=" │ "
  output+="${segments[i]}"
done
printf '%s' "$output"

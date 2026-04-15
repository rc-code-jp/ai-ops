#!/bin/bash
input=$(cat)

# --- CWD ---
cwd=$(echo "$input" | jq -r '.cwd // ""')
home="$HOME"
short_cwd="${cwd#"$home"}"
if [ "$short_cwd" != "$cwd" ]; then
  short_cwd="~${short_cwd}"
fi

# --- Git ---
git_branch=""
git_dirty=""
if git -C "$cwd" rev-parse --is-inside-work-tree --no-optional-locks >/dev/null 2>&1; then
  git_branch=$(git -C "$cwd" symbolic-ref --short HEAD 2>/dev/null)
  if [ -n "$git_branch" ]; then
    status_info=$(git -C "$cwd" status --porcelain 2>/dev/null)
    if [ -n "$status_info" ]; then
      case "$status_info" in
        *$'\n '[MADRCU]*|' '[MADRCU]*)  git_dirty="*" ;;
        *$'\n'[MADRCU]*|[MADRCU]*)      git_dirty="+" ;;
      esac
      if [ -z "$git_dirty" ]; then
        git_dirty="*"
      fi
    fi
  fi
fi

# --- Model + Effort + Context ---
model=$(echo "$input" | jq -r '.model.display_name // .model.id // ""')
effort=$(jq -r '.effortLevel // empty' ~/.claude/settings.json 2>/dev/null)
ctx_used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

ctx_section=""
[ -n "$effort" ] && ctx_section=" effort:${effort}"
[ -n "$ctx_used_pct" ] && ctx_section="${ctx_section} ctx:$(printf '%.0f' "$ctx_used_pct")%"

# --- Rate limits ---
now=$(date +%s)

fmt_remaining() {
  local resets_at=$1
  local diff=$(( resets_at - now ))
  if [ "$diff" -le 0 ]; then
    echo "0m"
  elif [ "$diff" -ge 3600 ]; then
    echo "$(( diff / 3600 ))h$(( (diff % 3600) / 60 ))m"
  else
    echo "$(( diff / 60 ))m"
  fi
}

FIVE_H=$(echo "$input" | jq -r '.rate_limits.five_hour.used_percentage // empty')
FIVE_H_RESET=$(echo "$input" | jq -r '.rate_limits.five_hour.resets_at // empty')
WEEK=$(echo "$input" | jq -r '.rate_limits.seven_day.used_percentage // empty')
WEEK_RESET=$(echo "$input" | jq -r '.rate_limits.seven_day.resets_at // empty')

limits=""
if [ -n "$FIVE_H" ]; then
  limits="5h: $(printf '%.0f' "$FIVE_H")%"
  [ -n "$FIVE_H_RESET" ] && limits="$limits($(fmt_remaining "$FIVE_H_RESET"))"
fi
if [ -n "$WEEK" ]; then
  week_part="7d: $(printf '%.0f' "$WEEK")%"
  [ -n "$WEEK_RESET" ] && week_part="$week_part($(fmt_remaining "$WEEK_RESET"))"
  limits="${limits:+$limits  }$week_part"
fi

# --- Worktree ---
wt_name=$(echo "$input" | jq -r '.worktree.name // empty')

# --- Line 1: CWD + Git + Worktree ---
printf '\033[34m%s\033[0m' "$short_cwd"
if [ -n "$git_branch" ]; then
  printf ' (%s)' "$git_branch"
  if [ -n "$git_dirty" ]; then
    printf '\033[31m%s\033[0m' "$git_dirty"
  fi
fi
if [ -n "$wt_name" ]; then
  printf ' \033[36m[wt:%s]\033[0m' "$wt_name"
fi

# --- Line 2: [Model] Context | Limits ---
printf '\n'
if [ -n "$limits" ]; then
  printf '[%s]%s | %s' "$model" "$ctx_section" "$limits"
else
  printf '[%s]%s' "$model" "$ctx_section"
fi

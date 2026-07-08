#!/bin/sh
input=$(cat)

# --- theme: load color roles from themes/<flavor>.sh (default: mocha) ---
# Built-in Mocha defaults so the statusline still renders if the theme is missing.
C_MODEL="250;179;135"; C_DIR="137;220;235"; C_BRANCH="203;166;247"
C_SEP="108;112;134"; C_LABEL="127;132;156"
C_GREEN="166;227;161"; C_YELLOW="249;226;175"; C_RED="243;139;168"

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd 2>/dev/null)
THEMES_DIR="${SCRIPT_DIR:-$HOME/.claude}/themes"
flavor=$(cat "$HOME/.claude/.statusline-theme" 2>/dev/null || echo mocha)
theme_file="$THEMES_DIR/${flavor}.sh"
[ -f "$theme_file" ] || theme_file="$THEMES_DIR/mocha.sh"
[ -f "$theme_file" ] && . "$theme_file"

# --- model ---
model=$(echo "$input" | jq -r '.model.display_name // ""')

# --- folder ---
dir=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // ""')
dir_name=$(basename "$dir")

# --- git branch ---
branch=""
if [ -d "${dir}/.git" ] || git -C "$dir" rev-parse --git-dir > /dev/null 2>&1; then
  branch=$(git -C "$dir" symbolic-ref --short HEAD 2>/dev/null || git -C "$dir" rev-parse --short HEAD 2>/dev/null)
fi

# --- usage stats (5h / 7d) from cache ---
CACHE_FILE="/tmp/.claude_usage_cache"
five_h=""
seven_d=""
five_h_reset=""
seven_d_reset=""

if [ -f "$CACHE_FILE" ]; then
  { read -r five_h; read -r seven_d; read -r five_h_reset; read -r seven_d_reset; } < "$CACHE_FILE"
else
  bash ~/.claude/fetch-usage.sh > /dev/null 2>&1 &
fi

# --- compute_delta: given a raw ISO timestamp, returns human-readable time until reset ---
compute_delta() {
  clean=$(echo "$1" | sed 's/\.[0-9]*//' | sed 's/[+-][0-9][0-9]:[0-9][0-9]$//' | sed 's/Z$//')
  # Portable epoch parse: GNU/Linux `date -d`, fallback to BSD/macOS `date -j -f`
  reset_epoch=$(TZ=UTC date -d "$clean" "+%s" 2>/dev/null \
    || TZ=UTC date -j -f "%Y-%m-%dT%H:%M:%S" "$clean" "+%s" 2>/dev/null)
  if [ -z "$reset_epoch" ]; then return; fi
  now_epoch=$(date -u "+%s")
  diff=$(( reset_epoch - now_epoch ))
  if [ "$diff" -le 0 ]; then echo "now"; return; fi
  days=$(( diff / 86400 ))
  hours=$(( (diff % 86400) / 3600 ))
  minutes=$(( (diff % 3600) / 60 ))
  if [ "$days" -gt 0 ]; then
    echo "${days}d ${hours}h"
  elif [ "$hours" -gt 0 ]; then
    echo "${hours}h ${minutes}m"
  else
    echo "${minutes}m"
  fi
}

# --- context window ---
used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')
ctx_str=""
ctx_tokens_str=""
if [ -n "$used" ]; then
  used_int=$(printf "%.0f" "$used")
  ctx_str="${used_int}%"
  ctx_used=$(echo "$input" | jq -r '(.context_window.current_usage.cache_read_input_tokens + .context_window.current_usage.cache_creation_input_tokens + .context_window.current_usage.input_tokens + .context_window.current_usage.output_tokens) // empty' 2>/dev/null)
  ctx_total=$(echo "$input" | jq -r '.context_window.context_window_size // empty' 2>/dev/null)
  if [ -n "$ctx_used" ] && [ -n "$ctx_total" ]; then
    ctx_used_k=$(( ctx_used / 1000 ))
    ctx_total_k=$(( ctx_total / 1000 ))
    ctx_tokens_str="${ctx_used_k}k/${ctx_total_k}k"
  fi
fi

# --- usage_color: theme-driven — green < 50, yellow 50-79, red >= 80 ---
usage_color() {
  n=${1:-0}
  if [ "$n" -ge 80 ]; then
    printf '\033[38;2;%sm' "$C_RED"
  elif [ "$n" -ge 50 ]; then
    printf '\033[38;2;%sm' "$C_YELLOW"
  else
    printf '\033[38;2;%sm' "$C_GREEN"
  fi
}

# render_bar <percent> [width=10] -> "████░░░░░░"
render_bar() {
  pct=${1:-0}
  width=${2:-10}
  filled=$(( pct * width / 100 ))
  [ "$filled" -gt "$width" ] && filled=$width
  [ "$filled" -lt 0 ] && filled=0
  empty=$(( width - filled ))
  bar=""
  i=0
  while [ "$i" -lt "$filled" ]; do bar="${bar}█"; i=$((i + 1)); done
  i=0
  while [ "$i" -lt "$empty" ]; do bar="${bar}░"; i=$((i + 1)); done
  printf '%s' "$bar"
}

# --- assemble output (colors from the loaded theme) ---
SEP="\033[38;2;${C_SEP}m • \033[0m"
LABEL="\033[2m\033[38;2;${C_LABEL}m"
DELTA="\033[2m\033[38;2;${C_LABEL}m"
RST="\033[0m"

# line 1: model | folder • branch
printf "\033[1m\033[38;2;%sm%s\033[22m\033[0m" "$C_MODEL" "$model"
printf "\033[38;2;%sm | \033[0m" "$C_SEP"
printf "\033[1m\033[38;2;%sm%s\033[22m\033[0m" "$C_DIR" "$dir_name"
if [ -n "$branch" ]; then
  printf "%b" "$SEP"
  printf "\033[1m\033[38;2;%sm%s\033[22m\033[0m" "$C_BRANCH" "$branch"
fi

# line 2: ctx  — dim label + severity-colored value
if [ -n "$ctx_str" ]; then
  printf "\n"
  printf "%bctx%b " "$LABEL" "$RST"
  printf "%b%s%b" "$(usage_color "$used_int")" "$ctx_str" "$RST"
  [ -n "$ctx_tokens_str" ] && printf " %b(%s)%b" "$DELTA" "$ctx_tokens_str" "$RST"
fi

# line 3: limit usage (5h / 7d)  — dim label + progress bar + severity-colored value
printf "\n"
first=1
if [ -n "$five_h_reset" ]; then
  delta=$(compute_delta "$five_h_reset")
  if [ -n "$delta" ]; then
    printf "%bsession%b " "$LABEL" "$RST"
    printf "%b%s %s%%%b" "$(usage_color "$five_h")" "$(render_bar "$five_h")" "$five_h" "$RST"
    printf " %b↻ %s%b" "$DELTA" "$delta" "$RST"
    first=0
  fi
fi
if [ -n "$seven_d_reset" ]; then
  delta=$(compute_delta "$seven_d_reset")
  if [ -n "$delta" ]; then
    [ "$first" -eq 0 ] && printf "%b" "$SEP"
    printf "%bweek%b " "$LABEL" "$RST"
    printf "%b%s %s%%%b" "$(usage_color "$seven_d")" "$(render_bar "$seven_d")" "$seven_d" "$RST"
    printf " %b↻ %s%b" "$DELTA" "$delta" "$RST"
  fi
fi

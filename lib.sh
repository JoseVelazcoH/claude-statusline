# Shared helpers for statusline-command.sh and statusline-config.sh.
#
# Layout format: ';' separates lines, ',' separates segments within a line,
# e.g. "model,dir,branch;ctx;session,week" is the 3-line default. A layout
# with no ';' puts every segment on one line.

ALL_SEGMENTS="model,dir,branch,ctx,session,week"
DEFAULT_LAYOUT="model,dir,branch;ctx;session,week"

# render_bar <percent> [width=10] -> "████░░░░░░"
render_bar() {
  local pct=${1:-0}
  local width=${2:-10}
  local filled=$(( pct * width / 100 ))
  [ "$filled" -gt "$width" ] && filled=$width
  [ "$filled" -lt 0 ] && filled=0
  local empty=$(( width - filled ))
  local bar=""
  local i=0
  while [ "$i" -lt "$filled" ]; do bar="${bar}█"; i=$((i + 1)); done
  i=0
  while [ "$i" -lt "$empty" ]; do bar="${bar}░"; i=$((i + 1)); done
  printf '%s' "$bar"
}

# segment_enabled <name> <comma,separated,list> -> 0 if present, 1 if not
segment_enabled() {
  local name=$1
  local list=$2
  case ",$list," in
    *",$name,"*) return 0 ;;
    *) return 1 ;;
  esac
}

# read_layout -> current layout string from ~/.claude/.statusline-config, or the default
read_layout() {
  local val=$(cat "$HOME/.claude/.statusline-config" 2>/dev/null)
  printf '%s' "${val:-$DEFAULT_LAYOUT}"
}

# flatten_layout <layout> -> flat comma list of every segment in the layout (line breaks removed)
flatten_layout() {
  printf '%s' "$1" | tr ';' ','
}

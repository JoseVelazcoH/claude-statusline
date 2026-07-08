#!/bin/sh
# Toggle/reorder statusline segments by writing to ~/.claude/.statusline-config.
# The statusline picks it up on the next render.
set -e

CLAUDE_DIR="$HOME/.claude"
STATE="$CLAUDE_DIR/.statusline-config"

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd 2>/dev/null)
. "${SCRIPT_DIR:-$CLAUDE_DIR}/lib.sh"

current=$(read_segments)

print_status() {
  echo "current order: $current"
  echo "segments:"
  for seg in $(printf '%s' "$DEFAULT_SEGMENTS" | tr ',' ' '); do
    if segment_enabled "$seg" "$current"; then
      echo "  [x] $seg"
    else
      echo "  [ ] $seg"
    fi
  done
  echo
  echo "usage: statusline-config.sh enable|disable <segment>"
  echo "       statusline-config.sh order <comma,separated,list>"
}

case "$1" in
  "")
    print_status
    ;;
  enable)
    seg=$2
    if ! segment_enabled "$seg" "$DEFAULT_SEGMENTS"; then
      echo "error: unknown segment '$seg' (known: $DEFAULT_SEGMENTS)" >&2
      exit 1
    fi
    if segment_enabled "$seg" "$current"; then
      echo "'$seg' already enabled"
    else
      printf '%s\n' "${current:+$current,}$seg" > "$STATE"
      echo "enabled '$seg'"
    fi
    ;;
  disable)
    seg=$2
    if ! segment_enabled "$seg" "$current"; then
      echo "'$seg' already disabled"
    else
      new=$(printf '%s' "$current" | tr ',' '\n' | grep -v "^${seg}\$" | tr '\n' ',' | sed 's/,$//')
      printf '%s\n' "$new" > "$STATE"
      echo "disabled '$seg'"
    fi
    ;;
  order)
    list=$2
    if [ -z "$list" ]; then
      echo "error: provide a comma-separated list" >&2
      exit 1
    fi
    for seg in $(printf '%s' "$list" | tr ',' ' '); do
      if ! segment_enabled "$seg" "$DEFAULT_SEGMENTS"; then
        echo "error: unknown segment '$seg' (known: $DEFAULT_SEGMENTS)" >&2
        exit 1
      fi
    done
    printf '%s\n' "$list" > "$STATE"
    echo "order set to '$list'"
    ;;
  *)
    echo "error: unknown command '$1'" >&2
    print_status >&2
    exit 1
    ;;
esac

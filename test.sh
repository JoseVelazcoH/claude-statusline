#!/bin/sh
# Minimal self-check for lib.sh. No framework — plain asserts, exit 1 on first failure.
set -e

SCRIPT_DIR=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd 2>/dev/null)
. "$SCRIPT_DIR/lib.sh"

assert_eq() {
  if [ "$1" != "$2" ]; then
    echo "FAIL: expected '$2', got '$1' ($3)" >&2
    exit 1
  fi
}

assert_eq "$(render_bar 0 10)" "░░░░░░░░░░" "render_bar 0%"
assert_eq "$(render_bar 100 10)" "██████████" "render_bar 100%"
assert_eq "$(render_bar 50 10)" "█████░░░░░" "render_bar 50%"

segment_enabled model "model,dir,branch" || { echo "FAIL: model should be enabled" >&2; exit 1; }
! segment_enabled week "model,dir,branch" || { echo "FAIL: week should not be enabled" >&2; exit 1; }
! segment_enabled session "sessionx,dir" || { echo "FAIL: session should not match sessionx (substring false positive)" >&2; exit 1; }
segment_enabled sessionx "session,sessionx" || { echo "FAIL: sessionx should be enabled" >&2; exit 1; }

assert_eq "$(flatten_layout "model,dir;ctx;session,week")" "model,dir,ctx,session,week" "flatten_layout multi-line"
assert_eq "$(flatten_layout "model,dir,branch")" "model,dir,branch" "flatten_layout single-line passthrough"

# a segment moved to a different line is still found via the flattened form
layout="branch;model,dir;session,week"
segment_enabled branch "$(flatten_layout "$layout")" || { echo "FAIL: branch should be enabled after moving lines" >&2; exit 1; }
! segment_enabled ctx "$(flatten_layout "$layout")" || { echo "FAIL: ctx should be disabled (left out of layout)" >&2; exit 1; }

echo "ok"

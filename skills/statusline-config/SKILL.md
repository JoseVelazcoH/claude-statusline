---
name: statusline-config
description: Toggle, reorder, or right-align claude-statusline segments (model, dir, branch, ctx, session, week, changes)
argument-hint: "[enable|disable|order] [segment-or-layout]"
allowed-tools: Bash(~/.claude/statusline-config.sh *)
disable-model-invocation: true
---

!`~/.claude/statusline-config.sh $ARGUMENTS`

Show the output above to the user exactly as printed, no extra commentary.

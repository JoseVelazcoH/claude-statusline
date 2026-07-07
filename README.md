# claude-watch

![statusline](assets/statusline.svg)

A minimal Claude Code statusline showing model, folder, git branch, context window, and usage-limit resets. Themed with Catppuccin Mocha and portable across Linux and macOS.

## Installation

**1. Copy the scripts**

```sh
cp fetch-usage.sh ~/.claude/fetch-usage.sh
cp statusline-command.sh ~/.claude/statusline-command.sh
chmod +x ~/.claude/fetch-usage.sh ~/.claude/statusline-command.sh
```

**2. Merge `settings.json` into `~/.claude/settings.json`**

Add the `statusLine` and `hooks` blocks from `settings.json` into your existing `~/.claude/settings.json`. If you don't have one yet, copy it directly:

```sh
cp settings.json ~/.claude/settings.json
```

**3. Trigger an initial fetch (optional)**

```sh
bash ~/.claude/fetch-usage.sh
```

## How it works

- `statusline-command.sh` renders three lines: model/folder/branch, context window usage, and the limit-window reset countdowns. Usage values are colored by threshold (green below 50%, yellow 50 to 79%, red 80% or more).
- `fetch-usage.sh` reads the OAuth token (macOS Keychain or `~/.claude/.credentials.json` on Linux), caches it for 15 minutes, hits the `/oauth/usage` endpoint, and writes the results to a cache file. On failure the stale cache is preserved.
- `settings.json` wires up the statusline and refreshes usage in the background on the `PreToolUse` and `Stop` hooks.

## Dependencies

- `jq`
- `curl`
- `git` (optional, for branch display)

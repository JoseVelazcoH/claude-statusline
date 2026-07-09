# Claude-statusline

![statusline](assets/statusline.svg)

A minimal Claude Code statusline showing model, folder, git branch, context window, and usage-limit progress bars. Themed with Catppuccin Mocha, configurable segments, and portable across Linux and macOS.

## Installation

### Quick install

Downloads the scripts and merges the required `settings.json` blocks automatically (requires `curl` and `jq`):

```sh
curl -fsSL https://raw.githubusercontent.com/JoseVelazcoH/claude-statusline/main/install.sh | sh
```

Restart Claude Code to see the statusline.

### Manual install

**1. Clone the repo**

```sh
git clone https://github.com/JoseVelazcoH/claude-statusline.git
cd claude-statusline
```

**2. Copy the scripts**

```sh
cp fetch-usage.sh ~/.claude/fetch-usage.sh
cp statusline-command.sh ~/.claude/statusline-command.sh
cp statusline-config.sh ~/.claude/statusline-config.sh
cp lib.sh ~/.claude/lib.sh
chmod +x ~/.claude/fetch-usage.sh ~/.claude/statusline-command.sh ~/.claude/statusline-config.sh

mkdir -p ~/.claude/skills/statusline-theme ~/.claude/skills/statusline-config
cp skills/statusline-theme/SKILL.md ~/.claude/skills/statusline-theme/SKILL.md
cp skills/statusline-config/SKILL.md ~/.claude/skills/statusline-config/SKILL.md
```

**3. Merge `settings.json` into `~/.claude/settings.json`**

Add the `statusLine` and `hooks` blocks from `settings.json` into your existing `~/.claude/settings.json`. If you don't have one yet, copy it directly:

```sh
cp settings.json ~/.claude/settings.json
```

**4. Trigger an initial fetch (optional)**

```sh
bash ~/.claude/fetch-usage.sh
```

## Themes

Four Catppuccin flavors are included: `mocha` (default), `macchiato`, `frappe`, and `latte`. Switch with:

```sh
~/.claude/statusline-theme.sh latte     # set a theme
~/.claude/statusline-theme.sh           # list themes and show the current one
```

The change applies on the next statusline render, no restart needed. Add your own palette by dropping a `themes/<name>.sh` file that sets the same color-role variables.

Or from inside Claude Code: `/statusline-theme latte`.

## Configuration

Seven segments are available: `model`, `dir`, `branch`, `ctx`, `session` (5h usage bar), `week` (7d usage bar), `changes` (git working-tree summary, e.g. `+2 ~3 -1` for added/modified/deleted files — hidden when the tree is clean).

```sh
~/.claude/statusline-config.sh                    # show current layout + on/off status
~/.claude/statusline-config.sh disable branch     # hide a segment, wherever it is
~/.claude/statusline-config.sh enable branch      # show it again (appended to the last line)
~/.claude/statusline-config.sh enable changes     # e.g. "week ... 86% ↻ 1d 1h • +2 ~1 -0"
~/.claude/statusline-config.sh order 'model,dir;ctx;session,week'   # set the full layout at once
```

State lives in `~/.claude/.statusline-config` — a layout string where `;` separates lines and `,` separates segments on the same line, e.g. the default is `model,dir,branch;ctx;session,week` (3 lines). Delete the file to go back to that default. Changes apply on the next render — no restart needed.

Quote the argument to `order`: `;` is a shell command separator, so an unquoted layout string would run as multiple commands.

Segments can go on **any** line, in any order, and any number of lines:

```sh
# move branch to its own line, drop ctx entirely
~/.claude/statusline-config.sh order 'model,dir;branch;session,week'

# collapse everything onto a single line (no ';' at all)
~/.claude/statusline-config.sh order 'model,dir,branch,ctx,session,week'
```

```
sonnet-5 | claude-statusline
main
session ████████░░ 82% ↻ 2h 15m • week ██░░░░░░░░ 23% ↻ 3d 4h
```

`enable <segment>` appends it to the last line of the current layout (not to a fixed default line); `disable <segment>` removes it from wherever it is and drops the line if it becomes empty.

Or from inside Claude Code: `/statusline-config disable branch`, `/statusline-config order 'model,dir;ctx;session,week'`.

## Dependencies

- `jq`
- `curl`
- `git` (optional, for branch display)

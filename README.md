# Claude-statusline

![statusline](assets/statusline.svg)

A minimal, portable (Linux/macOS) Claude Code statusline showing model, folder, git branch, context window, and usage-limit bars. Themed with Catppuccin, configurable segments.

## Install

Requires `curl` and `jq`. Downloads the scripts and merges the `settings.json` blocks:

```sh
curl -fsSL https://raw.githubusercontent.com/JoseVelazcoH/claude-statusline/main/install.sh | sh
```

Restart Claude Code to see it.

<details>
<summary>Manual install</summary>

```sh
git clone https://github.com/JoseVelazcoH/claude-statusline.git
cd claude-statusline

# scripts
cp fetch-usage.sh statusline-command.sh statusline-config.sh lib.sh ~/.claude/
chmod +x ~/.claude/fetch-usage.sh ~/.claude/statusline-command.sh ~/.claude/statusline-config.sh

# skills
mkdir -p ~/.claude/skills/statusline-theme ~/.claude/skills/statusline-config
cp skills/statusline-theme/SKILL.md ~/.claude/skills/statusline-theme/SKILL.md
cp skills/statusline-config/SKILL.md ~/.claude/skills/statusline-config/SKILL.md

# settings: merge the statusLine and hooks blocks into your ~/.claude/settings.json,
# or copy it directly if you don't have one
cp settings.json ~/.claude/settings.json

bash ~/.claude/fetch-usage.sh   # optional: trigger an initial usage fetch
```

</details>

## Usage

All changes apply on the next render, no restart needed. Every command also works inside Claude Code as a slash command (e.g. `/statusline-config order '...'`).

### Themes

Catppuccin `mocha` (default), `macchiato`, `frappe`, `latte`. Add your own by dropping a `themes/<name>.sh` that sets the same color-role variables.

```sh
~/.claude/statusline-theme.sh latte   # set a theme
~/.claude/statusline-theme.sh         # list themes and show the current one
```

### Layout

State lives in `~/.claude/.statusline-config` as a layout string where `;` separates lines and `,` separates segments. Default: `model,dir,branch;ctx;session,week`. Delete the file to reset.

```sh
~/.claude/statusline-config.sh                      # show current layout + on/off status
~/.claude/statusline-config.sh disable branch       # hide a segment, wherever it is
~/.claude/statusline-config.sh enable changes       # append to the last line
~/.claude/statusline-config.sh order 'model,dir,branch,ctx,session,week'   # quote it: ';' is a shell separator
```

`enable` appends to the last line; `disable` drops the line if it becomes empty. Segments can go on any line, in any order.

### Limit style

Controls how `session` and `week` render.

```sh
~/.claude/statusline-config.sh style compact   # "reset ↻ 3h 54m • ↻ 1d 21h"
~/.claude/statusline-config.sh style full      # "session ████░░ 13% ↻ 3h 54m" (default)
```

## Segments

| Segment   | Shows                                                        |
| --------- | ----------------------------------------------------------- |
| `model`   | Model display name                                          |
| `dir`     | Current folder                                              |
| `branch`  | Git branch                                                  |
| `ctx`     | Context-window usage                                        |
| `session` | 5h usage limit                                              |
| `week`    | 7d usage limit                                              |
| `changes` | Git working tree (`+2 ~3 -1`), hidden when the tree is clean |

## Dependencies

`jq`, `curl`, `git` (optional, for branch display).

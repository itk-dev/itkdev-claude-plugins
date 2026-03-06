# itkdev-statusline

Claude Code statusline plugin showing git branch, plan progress, and context window usage.

## What it shows

```
feat/auth │ 2/5 │ ▰▰▰▰▰▱▱▱▱▱ 45%
```

| Segment | Source | Notes |
|---------|--------|-------|
| Git branch | `.git/HEAD` in `cwd` | Handles detached HEAD (short hash) |
| Plan progress | `docs/plans/*.md` in `cwd` | Newest non-VERIFIED plan, checkbox counts |
| Context % | stdin JSON `context_window.remaining_percentage` | 10-segment progress bar, color coded. Falls back to `used_percentage`. |

### Context color thresholds

- **Gray** (dim): below 80%
- **Yellow**: 80–89%
- **Red**: 90%+

## Installation

### Via Claude Code marketplace

```bash
claude install itk-dev/itkdev-claude-plugins:itkdev-statusline
```

### Setup

After installing the plugin, run the slash command:

```
/setup-statusline
```

This copies the statusline script to `~/.claude/bin/statusline.sh` and configures `~/.claude/settings.json`. Restart Claude Code for the statusline to appear.

### Manual setup

1. Copy `bin/statusline.sh` to `~/.claude/bin/statusline.sh`
2. Make it executable: `chmod +x ~/.claude/bin/statusline.sh`
3. Add to `~/.claude/settings.json`:

```json
{
  "statusLine": {
    "command": "bash ~/.claude/bin/statusline.sh"
  }
}
```

## Requirements

- `bash` 4+
- `jq`

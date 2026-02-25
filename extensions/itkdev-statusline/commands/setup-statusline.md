---
allowed-tools:
  - Bash
  - Read
  - Edit
  - Write
---

# Setup itkdev-statusline

Install the statusline script and configure Claude Code to use it.

## Steps

1. **Copy the statusline script** to `~/.claude/bin/statusline.sh`:
   - Create `~/.claude/bin/` if it does not exist
   - Copy the `bin/statusline.sh` file from this plugin's directory to `~/.claude/bin/statusline.sh`
   - Make it executable (`chmod +x`)

2. **Update `~/.claude/settings.json`** to set the `statusLine` command:
   - Read the existing `~/.claude/settings.json` (create it if missing)
   - Set `"statusLine"` to `{"command": "bash ~/.claude/bin/statusline.sh"}`
   - Preserve all other existing settings

3. **Confirm to the user** that setup is complete and they should restart Claude Code for the statusline to appear.

## Important

- Use the `statusline-setup` subagent type if available, otherwise perform the steps directly.
- The script path `~/.claude/bin/statusline.sh` is stable across plugin version updates.
- Do NOT modify the statusline script itself — only copy it.

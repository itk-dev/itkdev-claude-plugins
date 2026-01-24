# ITK Dev Claude Plugins

A Claude Code plugin marketplace for ITK Dev team tools and MCP servers.

## Structure

```
itkdev-claude-plugins/
├── .claude-plugin/
│   ├── plugin.json            # Plugin manifest
│   ├── marketplace.json       # Marketplace catalog
│   └── mcp-versions.json      # Tracked MCP dependency versions
├── .github/workflows/         # GitHub Actions workflows
│   ├── check-mcp-updates.yml  # Weekly MCP update checker
│   └── release.yml            # Automated release workflow
├── .mcp.json                   # MCP server configurations
├── commands/                   # Slash commands (Markdown files)
│   └── example.md
├── skills/                     # Skills (Markdown files with frontmatter)
│   └── itkdev-github-guidelines.md
└── README.md
```

## Installation

Team members can install the marketplace and plugins with:

```bash
# Add the marketplace
/plugin marketplace add itk-dev/itkdev-claude-plugins

# Install the itkdev-tools plugin
/plugin install itkdev-tools@itkdev-marketplace
```

## Included MCP Servers

### browser-feedback

Browser feedback collection tool from [mcp-claude-code-browser-feedback](https://github.com/itk-dev/mcp-claude-code-browser-feedback).

## Included Skills

### itkdev-github-guidelines

GitHub workflow guidelines for the ITK Dev team. Automatically activates when working with Git, branches, commits, or pull requests. Covers:
- Branch naming conventions (`feature/issue-{number}-{description}`)
- Conventional commit messages
- Changelog updates (Keep a Changelog format)
- PR requirements and templates

## Auto-Release Workflow

This plugin automatically releases new versions when MCP server dependencies publish updates.

### How it works

1. **Daily Check**: A GitHub Actions workflow runs every day at 8:30 UTC
2. **Version Comparison**: Compares latest MCP releases with tracked versions in `.claude-plugin/mcp-versions.json`
3. **Automated Release**: If updates are detected, a new patch version is released automatically

### Tracked Dependencies

| MCP Server | Repository |
|------------|------------|
| browser-feedback | [mcp-claude-code-browser-feedback](https://github.com/itk-dev/mcp-claude-code-browser-feedback) |
| docker | [mcp-itkdev-docker](https://github.com/itk-dev/mcp-itkdev-docker) |

### Manual Trigger

You can manually trigger a dependency check via the GitHub Actions UI:
1. Go to **Actions** > **Check MCP Updates**
2. Click **Run workflow**

## Adding New Tools

### Adding MCP Servers

Edit `.mcp.json` to add new MCP server configurations:

```json
{
  "mcpServers": {
    "your-server": {
      "command": "npx",
      "args": ["-y", "github:org/repo"]
    }
  }
}
```

### Adding Commands

Create new Markdown files in the `commands/` directory. Each file becomes a slash command.

### Adding Skills

Create new Markdown files in the `skills/` directory with YAML frontmatter:

```markdown
---
name: skill-name
description: When this skill should be activated automatically.
---

# Skill Content

Your skill instructions here...
```

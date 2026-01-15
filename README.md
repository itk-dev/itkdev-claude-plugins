# ITK Dev Claude Plugins

A Claude Code plugin marketplace for ITK Dev team tools and MCP servers.

## Structure

```
itkdev-claude-plugins/
├── .claude-plugin/
│   ├── plugin.json            # Plugin manifest
│   └── marketplace.json       # Marketplace catalog
├── .mcp.json                   # MCP server configurations
├── commands/                   # Slash commands (Markdown files)
│   └── example.md
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

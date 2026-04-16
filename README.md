# ITK Dev Claude Plugins

A Claude Code plugin marketplace catalog for ITK Dev team tools, skills, and MCP servers.

This repository is a **pure marketplace catalog** — it references plugins hosted in their own repositories. No plugin code lives here.

## Structure

```
itkdev-claude-plugins/
├── .claude-plugin/
│   └── marketplace.json       # Marketplace catalog
├── .github/workflows/
│   └── manual-release.yml     # Manual release workflow
├── CHANGELOG.md
└── README.md
```

## Installation

Team members can install the marketplace and individual plugins:

```bash
# Add the marketplace
/plugin marketplace add itk-dev/itkdev-claude-plugins

# Install plugins individually
/plugin install itkdev-skills@itkdev-marketplace
/plugin install itkdev-browser-feedback@itkdev-marketplace
/plugin install itkdev-statusline@itkdev-marketplace
```

Or install plugins directly from their repos:

```bash
claude plugin add itk-dev/itkdev-skills
claude plugin add itk-dev/mcp-claude-code-browser-feedback
claude plugin add itk-dev/itkdev-claude-code-statusline
```

## Plugins

| Plugin | Repository | Description |
|--------|-----------|-------------|
| **itkdev-skills** | [itk-dev/itkdev-skills](https://github.com/itk-dev/itkdev-skills) | ITK Dev team conventions, workflows, and coding standards (11 skills, 3 agents) |
| **itkdev-browser-feedback** | [itk-dev/mcp-claude-code-browser-feedback](https://github.com/itk-dev/mcp-claude-code-browser-feedback) | Browser-based visual feedback and annotation MCP server |
| **itkdev-statusline** | [itk-dev/itkdev-claude-code-statusline](https://github.com/itk-dev/itkdev-claude-code-statusline) | Claude Code statusline with git branch, plan/task progress, and context window usage |

## Release Workflow

Create a new release manually via GitHub Actions:

1. Go to **Actions** > **Manual Release**
2. Click **Run workflow**
3. Select version bump type:
   - `patch` - Bug fixes (0.3.1 -> 0.3.2)
   - `minor` - New features (0.3.1 -> 0.4.0)
   - `major` - Breaking changes (0.3.1 -> 1.0.0)

The workflow will:
- Validate that `[Unreleased]` section has content
- Update `CHANGELOG.md` with version and date
- Create git tag and push
- Create GitHub release with changelog notes

## Troubleshooting

### SSH permission denied when installing plugins

If you get an error like:

```
git@github.com: Permission denied (publickey).
fatal: Could not read from remote repository.
```

Claude Code clones plugin repos via SSH by default. If you don't have SSH keys configured for GitHub, configure git to use HTTPS instead:

```bash
git config --global url."https://github.com/".insteadOf "git@github.com:"
```

## Adding a Plugin to the Marketplace

To add a new plugin to the marketplace, add an entry to `.claude-plugin/marketplace.json`:

```json
{
  "name": "your-plugin-name",
  "description": "Description of your plugin",
  "source": {
    "source": "github",
    "repo": "itk-dev/your-plugin-repo"
  }
}
```

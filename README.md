# ITK Dev Claude Plugins

A Claude Code plugin marketplace for ITK Dev team tools, skills, and MCP servers.

## Structure

```
itkdev-claude-plugins/
├── .claude-plugin/
│   ├── plugin.json            # Marketplace manifest
│   ├── marketplace.json       # Marketplace catalog
│   └── mcp-versions.json      # Tracked MCP dependency versions
├── .github/workflows/         # GitHub Actions workflows
│   ├── check-mcp-updates.yml  # Daily MCP update checker
│   ├── manual-release.yml     # Manual release workflow
│   └── release.yml            # MCP dependency release workflow
├── extensions/
│   ├── itkdev-skills/         # Skills + agents plugin
│   │   ├── .claude-plugin/
│   │   │   └── plugin.json
│   │   ├── skills/            # Skills (subdirectories with SKILL.md)
│   │   └── agents/            # Agents (flat .md files)
│   ├── itkdev-browser-feedback/  # Browser feedback MCP server plugin
│   │   ├── .claude-plugin/
│   │   │   └── plugin.json
│   │   └── .mcp.json
│   └── itkdev-statusline/     # Statusline extension
│       ├── .claude-plugin/
│       │   └── plugin.json
│       └── ...
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

## Plugins

### itkdev-skills

ITK Dev team conventions, workflows, and coding standards. Includes all skills and agents.

#### Skills

| Skill | Description |
|-------|-------------|
| `itkdev-docker` | Docker development environment (CLI reference, Compose architecture, services, Traefik, server deployments, project detection, template comparison) |
| `itkdev-docker-templates` | Project template conventions (available templates, installation, setup workflows, procedural template operations) |
| `itkdev-gh-actions` | GitHub Actions workflow templates (general, Drupal, Symfony workflows, configuration files) |
| `itkdev-taskfile` | Taskfile development workflows (task patterns, coding standards, site management, asset building) |
| `itkdev-adr` | Architecture Decision Record management |
| `itkdev-documentation` | Technical documentation and README generation following ITK Dev standards |
| `itkdev-drupal` | Drupal 10/11 development assistance (code auditing, module/theme development, configuration management) |
| `itkdev-github-guidelines` | GitHub workflow guidelines (branch naming, commits, changelogs, PRs) |
| `itkdev-issue-workflow` | Autonomous GitHub issue workflow |
| `itkdev-validate-standards` | Project standards validation against ITK Dev conventions |

#### Agents

| Agent | Description |
|-------|-------------|
| `itkdev-code-review` | Automated PR review against ITK Dev standards |
| `itkdev-issue-workflow` | Autonomous GitHub issue workflow (runs in isolated subagent context) |

### itkdev-browser-feedback

Browser-based visual feedback and annotation MCP server. Powered by [mcp-claude-code-browser-feedback](https://github.com/itk-dev/mcp-claude-code-browser-feedback).

### itkdev-statusline

Claude Code statusline displaying git branch, plan/task progress, and context window usage. Install with `/setup-statusline` after adding the marketplace. See [extensions/itkdev-statusline/README.md](extensions/itkdev-statusline/README.md) for details.

## Release Workflows

### Manual Release

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
- Update all `plugin.json` versions
- Create git tag and push
- Create GitHub release with changelog notes

### MCP Dependency Auto-Release

This marketplace automatically releases new versions when MCP server dependencies publish updates.

#### How it works

1. **Daily Check**: A GitHub Actions workflow runs every day at 8:30 UTC
2. **Version Comparison**: Compares latest MCP releases with tracked versions in `.claude-plugin/mcp-versions.json`
3. **Automated Release**: If updates are detected, a new patch version is released automatically

#### Tracked Dependencies

| MCP Server | Repository |
|------------|------------|
| browser-feedback | [mcp-claude-code-browser-feedback](https://github.com/itk-dev/mcp-claude-code-browser-feedback) |

#### Manual MCP Check

You can manually trigger a dependency check via the GitHub Actions UI:
1. Go to **Actions** > **Check MCP Updates**
2. Click **Run workflow**

## Adding New Tools

### Adding Skills

Create a subdirectory in `extensions/itkdev-skills/skills/` with a `SKILL.md` file containing YAML frontmatter:

```
extensions/itkdev-skills/skills/
└── your-skill-name/
    └── SKILL.md
```

### Adding Agents

Create a flat `.md` file in `extensions/itkdev-skills/agents/` with YAML frontmatter:

```
extensions/itkdev-skills/agents/
└── your-agent-name.md
```

### Adding MCP Servers

Create a new extension directory under `extensions/` with its own `.claude-plugin/plugin.json` and `.mcp.json`:

```
extensions/
└── your-mcp-server/
    ├── .claude-plugin/
    │   └── plugin.json
    └── .mcp.json
```

Then add the plugin to `.claude-plugin/marketplace.json`.

### Adding Extensions

Create a subdirectory in `extensions/` with its own `.claude-plugin/plugin.json` and any commands or scripts:

```
extensions/
└── your-extension-name/
    ├── .claude-plugin/
    │   └── plugin.json
    ├── bin/
    │   └── your-script.sh
    └── commands/
        └── setup-your-extension.md
```

Then add the plugin to `.claude-plugin/marketplace.json`.

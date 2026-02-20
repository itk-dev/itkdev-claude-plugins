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
│   ├── check-mcp-updates.yml  # Daily MCP update checker
│   ├── manual-release.yml     # Manual release workflow
│   └── release.yml            # MCP dependency release workflow
├── .mcp.json                   # MCP server configurations
├── agents/                     # Agents (flat .md files)
│   └── itkdev-issue-workflow.md
├── skills/                     # Skills (subdirectories with SKILL.md)
│   ├── itkdev-adr/
│   ├── itkdev-documentation/
│   ├── itkdev-drupal/
│   ├── itkdev-github-guidelines/
│   └── itkdev-issue-workflow/
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

### itkdev-docker

Docker environment management for ITK Dev projects from [mcp-itkdev-docker](https://github.com/itk-dev/mcp-itkdev-docker). Provides template detection, comparison, and setup tools for ITK Dev Docker configurations.

## Included Skills

### itkdev-adr

Architecture Decision Record management. Activates when creating, updating, or managing ADRs and documenting architectural decisions.

### itkdev-documentation

Technical documentation and README generation for ITK Dev projects. Covers README files, deployment guides, architecture docs, and API documentation following ITK Dev documentation standards.

### itkdev-drupal

Drupal 10/11 development assistance. Covers code auditing, module/theme development, drush commands, configuration management, and ITK Dev Docker environment integration.

### itkdev-github-guidelines

GitHub workflow guidelines for the ITK Dev team. Automatically activates when working with Git, branches, commits, or pull requests. Covers:
- Branch naming conventions (`feature/issue-{number}-{description}`)
- Conventional commit messages
- Changelog updates (Keep a Changelog format)
- PR requirements and templates

### itkdev-issue-workflow

Autonomous GitHub issue workflow. Works through GitHub issues with minimal user interaction — handling development, testing, review, and merge — only pausing when user review or merge approval is required.

## Included Agents

### itkdev-issue-workflow

Autonomous GitHub issue workflow agent. Runs as an isolated subagent with its own context, auto-delegated by Claude when working through GitHub issues end-to-end. Handles development, testing, code review, and merge with minimal user interaction. Preloads the `itkdev-github-guidelines` skill and uses project memory to build codebase knowledge across sessions.

> **Skill vs Agent:** The skill (`/itkdev-issue-workflow`) injects instructions into your main conversation. The agent runs in isolated context and is auto-delegated by Claude when appropriate. Both coexist — use the skill for interactive control, or let Claude delegate to the agent for fully autonomous operation.

## Release Workflows

### Manual Release

Create a new release manually via GitHub Actions:

1. Go to **Actions** > **Manual Release**
2. Click **Run workflow**
3. Select version bump type:
   - `patch` - Bug fixes (0.3.1 → 0.3.2)
   - `minor` - New features (0.3.1 → 0.4.0)
   - `major` - Breaking changes (0.3.1 → 1.0.0)

The workflow will:
- Validate that `[Unreleased]` section has content
- Update `CHANGELOG.md` with version and date
- Update `plugin.json` version
- Create git tag and push
- Create GitHub release with changelog notes

### MCP Dependency Auto-Release

This plugin automatically releases new versions when MCP server dependencies publish updates.

#### How it works

1. **Daily Check**: A GitHub Actions workflow runs every day at 8:30 UTC
2. **Version Comparison**: Compares latest MCP releases with tracked versions in `.claude-plugin/mcp-versions.json`
3. **Automated Release**: If updates are detected, a new patch version is released automatically

#### Tracked Dependencies

| MCP Server | Repository |
|------------|------------|
| browser-feedback | [mcp-claude-code-browser-feedback](https://github.com/itk-dev/mcp-claude-code-browser-feedback) |
| itkdev-docker | [mcp-itkdev-docker](https://github.com/itk-dev/mcp-itkdev-docker) |

#### Manual MCP Check

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

### Adding Skills

Create a subdirectory in `skills/` with a `SKILL.md` file containing YAML frontmatter:

```
skills/
└── your-skill-name/
    └── SKILL.md
```

```markdown
---
name: your-skill-name
description: When this skill should be activated automatically.
---

# Skill Content

Your skill instructions here...
```

### Adding Agents

Create a flat `.md` file in `agents/` with YAML frontmatter:

```
agents/
└── your-agent-name.md
```

```markdown
---
name: your-agent-name
description: When this agent should be auto-delegated.
skills:
  - skill-to-preload
memory: project
---

# Agent System Prompt

Your agent instructions here...
```

Agents run in isolated context with their own system prompt and are auto-delegated by Claude. Use agents for autonomous, multi-step workflows that benefit from isolated context.

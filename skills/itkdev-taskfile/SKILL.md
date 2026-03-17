---
name: itkdev-taskfile
description: Taskfile development workflows for ITK Dev projects. Use when working with Taskfile.yml, running task commands, setting up task automation, coding standards, site management, asset building, or asking about available tasks.
---

# ITK Dev Taskfile Workflows

You are assisting with Taskfile-based automation in ITK Dev projects. This skill covers Taskfile.yml structure, standard tasks, and development workflows.

**Convention:** Always check for and use Taskfile tasks before running raw `itkdev-docker-compose` commands. Tasks chain multiple commands and handle edge cases.

## Listing Available Tasks

```bash
task                    # List all available tasks with descriptions
task --list-all         # List all tasks including those without descriptions
```

## Taskfile.yml Structure

ITK Dev Taskfiles follow a standard structure with variables and task composition:

```yaml
version: '3'

vars:
  DOCKER: itkdev-docker-compose
  COMPOSER: "{{.DOCKER}} composer"
  DRUSH: "{{.DOCKER}} drush"
  PHP: "{{.DOCKER}} php"
  NPM: docker compose run --rm node npm

tasks:
  # Tasks defined here...
```

### Variable Hierarchy

- `vars:` at root level define global defaults
- Tasks can override with local `vars:`
- Dynamic variables use `sh:` for runtime evaluation
- CLI arguments passed via `-- <args>` syntax (e.g., `task drush -- cr`)

## Core Task Patterns

### Docker Compose Wrapper

```yaml
compose:
  desc: Run docker compose command
  cmds:
    - docker compose {{.CLI_ARGS}}
```

Usage: `task compose -- up -d`

### Compose Up

```yaml
compose-up:
  desc: Start Docker containers
  cmds:
    - docker compose up -d
```

### Site Install (Drupal)

```yaml
site-install:
  desc: Install site from scratch
  cmds:
    - "{{.COMPOSER}} install"
    - "{{.DRUSH}} site:install --existing-config --yes"
    - "{{.DRUSH}} cr"
```

### Site Update (Drupal)

```yaml
site-update:
  desc: Update site after code changes
  cmds:
    - "{{.COMPOSER}} install"
    - "{{.DRUSH}} updb --yes"
    - "{{.DRUSH}} cim --yes"
    - "{{.DRUSH}} cr"
```

## Composer and Drush Wrappers

```yaml
composer:
  desc: Run composer command
  cmds:
    - "{{.COMPOSER}} {{.CLI_ARGS}}"

drush:
  desc: Run drush command
  cmds:
    - "{{.DRUSH}} {{.CLI_ARGS}}"
```

Usage: `task composer -- require drupal/admin_toolbar` or `task drush -- cr`

## Asset Building

```yaml
npm-install:
  desc: Install Node.js dependencies
  cmds:
    - "{{.NPM}} install"

npm-build:
  desc: Build frontend assets
  cmds:
    - "{{.NPM}} run build"

npm-watch:
  desc: Watch for frontend asset changes
  cmds:
    - "{{.NPM}} run watch"
```

## Coding Standards Tasks

ITK Dev projects define tasks for checking and auto-fixing coding standards. The pattern follows `coding-standards-{type}:{check|apply}`:

### PHP (Drupal - phpcs/phpcbf)

```yaml
coding-standards-php-check:
  desc: Check PHP coding standards
  cmds:
    - "{{.DOCKER}} vendor/bin/phpcs"

coding-standards-php-apply:
  desc: Apply PHP coding standards fixes
  cmds:
    - "{{.DOCKER}} vendor/bin/phpcbf"
```

### PHP (Symfony - php-cs-fixer)

```yaml
coding-standards-php-check:
  desc: Check PHP coding standards
  cmds:
    - "{{.DOCKER}} vendor/bin/php-cs-fixer fix --dry-run"

coding-standards-php-apply:
  desc: Apply PHP coding standards fixes
  cmds:
    - "{{.DOCKER}} vendor/bin/php-cs-fixer fix"
```

### JavaScript

```yaml
coding-standards-javascript-check:
  desc: Check JavaScript coding standards
  cmds:
    - docker compose run --rm prettier --check 'web/**/*.js'

coding-standards-javascript-apply:
  desc: Apply JavaScript coding standards
  cmds:
    - docker compose run --rm prettier --write 'web/**/*.js'
```

### Markdown

```yaml
coding-standards-markdown-check:
  desc: Check Markdown coding standards
  cmds:
    - docker compose run --rm markdownlint '**/*.md'

coding-standards-markdown-apply:
  desc: Apply Markdown coding standards
  cmds:
    - docker compose run --rm markdownlint --fix '**/*.md'
```

### Styles (CSS/SCSS)

```yaml
coding-standards-styles-check:
  desc: Check CSS/SCSS coding standards
  cmds:
    - docker compose run --rm prettier --check 'web/**/*.scss'

coding-standards-styles-apply:
  desc: Apply CSS/SCSS coding standards
  cmds:
    - docker compose run --rm prettier --write 'web/**/*.scss'
```

### Twig

```yaml
coding-standards-twig-check:
  desc: Check Twig coding standards
  cmds:
    - "{{.DOCKER}} vendor/bin/twig-cs-fixer lint"

coding-standards-twig-apply:
  desc: Apply Twig coding standards
  cmds:
    - "{{.DOCKER}} vendor/bin/twig-cs-fixer lint --fix"
```

### YAML

```yaml
coding-standards-yaml-check:
  desc: Check YAML coding standards
  cmds:
    - docker compose run --rm prettier --check '**/*.yaml' '**/*.yml'

coding-standards-yaml-apply:
  desc: Apply YAML coding standards
  cmds:
    - docker compose run --rm prettier --write '**/*.yaml' '**/*.yml'
```

## Code Analysis

```yaml
code-analysis:
  desc: Run PHPStan static analysis
  cmds:
    - "{{.DOCKER}} vendor/bin/phpstan"
```

## Database Operations

```yaml
database-dump:
  desc: Dump database to file
  cmds:
    - "{{.DRUSH}} sql:dump --result-file=/app/dump.sql"
```

## Development Settings (Drupal)

```yaml
dev-settings-twig-debug:
  desc: Enable Twig debug mode
  cmds:
    - "{{.DRUSH}} state:set twig_debug true"
    - "{{.DRUSH}} cr"

dev-settings-markup-cache:
  desc: Disable render cache for development
  cmds:
    - "{{.DRUSH}} state:set system.performance css.preprocess 0"
    - "{{.DRUSH}} state:set system.performance js.preprocess 0"
    - "{{.DRUSH}} cr"
```

## Translation Tasks

```yaml
translations-import:
  desc: Import translations
  cmds:
    - "{{.DRUSH}} locale:import da /app/translations/da.po"
    - "{{.DRUSH}} cr"

translations-export:
  desc: Export translations
  cmds:
    - "{{.DRUSH}} locale:export da > /app/translations/da.po"
```

## Docker Image Management

```yaml
images-pull:
  desc: Pull latest Docker images
  cmds:
    - docker compose pull
```

## Fixtures

```yaml
fixtures-load:
  desc: Load fixture content
  cmds:
    - "{{.DRUSH}} content-fixtures:load --yes"
    - "{{.DRUSH}} cr"
```

## Task Patterns

### Prompts (interactive confirmation)

```yaml
dangerous-task:
  prompt: This will delete all data. Continue?
  cmds:
    - "{{.DRUSH}} sql:drop --yes"
```

### Silent (suppress command output)

```yaml
quiet-task:
  silent: true
  cmds:
    - echo "Only this output is shown"
```

### Dynamic Variables

```yaml
dynamic-task:
  vars:
    BRANCH:
      sh: git rev-parse --abbrev-ref HEAD
  cmds:
    - echo "Current branch: {{.BRANCH}}"
```

### CLI Arguments

```yaml
pass-through:
  cmds:
    - "{{.DRUSH}} {{.CLI_ARGS}}"
```

Usage: `task pass-through -- status`

### Task Composition (deps and cmds)

```yaml
full-setup:
  deps:
    - npm-install
  cmds:
    - task: site-install
    - task: npm-build
```

## Common Workflows

### New Developer Setup

```bash
task compose-up          # Start containers
task site-install        # Install site (or site-update for existing)
task npm-install         # Install frontend dependencies
task npm-build           # Build assets
```

### Daily Development

```bash
task compose-up          # Ensure containers running
task site-update         # Pull latest config/database changes
task npm-watch           # Watch for asset changes (if applicable)
```

### Before Committing

```bash
task coding-standards-php-check
task coding-standards-javascript-check
task coding-standards-twig-check
task coding-standards-markdown-check
task code-analysis       # PHPStan (if configured)
```

Or if a combined CI task exists:

```bash
task ci                  # Run all checks
```

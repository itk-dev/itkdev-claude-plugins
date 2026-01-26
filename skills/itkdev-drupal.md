---
name: itkdev-drupal
description: Drupal development assistance for ITK Dev projects. Use when working with Drupal 10/11 codebases, creating modules/themes, running drush commands, auditing code quality, or managing configuration. Activates for projects with *.info.yml files or web/modules structure.
---

# Drupal Development Guide

You are assisting with Drupal 10/11 development. This skill covers code auditing, module/theme development, drush commands, and configuration management.

## Project Detection

Recognize Drupal projects by:
- `*.info.yml` files in modules/themes
- `web/modules` or `web/themes` directory structure
- `composer.json` with `drupal/core` dependency
- `docker-compose.yml` with ITK Dev Docker setup
- `Taskfile.yml` with defined tasks

## ITK Dev Docker Environment

**IMPORTANT:** ITK Dev projects run in Docker containers. Never run commands directly on the host - always use `itkdev-docker-compose` or Taskfile tasks.

### itkdev-docker-compose Commands

The `itkdev-docker-compose` CLI wraps docker-compose and provides Drupal-specific commands:

```bash
# Drush (runs inside phpfpm container)
itkdev-docker-compose drush cr              # Clear cache
itkdev-docker-compose drush cex -y          # Export config
itkdev-docker-compose drush cim -y          # Import config
itkdev-docker-compose drush updb -y         # Run updates

# Composer (runs inside phpfpm container)
itkdev-docker-compose composer install
itkdev-docker-compose composer require drupal/module_name

# PHP (runs inside phpfpm container)
itkdev-docker-compose php script.php

# Database
itkdev-docker-compose sql:cli               # MySQL CLI
itkdev-docker-compose sync:db               # Sync database from remote
itkdev-docker-compose sync:files            # Sync files from remote
itkdev-docker-compose sync                  # Sync both db and files

# Utilities
itkdev-docker-compose url                   # Print site URL
itkdev-docker-compose open                  # Open site in browser

# Any vendor/bin command
itkdev-docker-compose vendor/bin/phpcs      # Run PHP CodeSniffer
itkdev-docker-compose vendor/bin/phpunit    # Run PHPUnit
```

### Taskfile.yml

Projects typically have a `Taskfile.yml` defining common workflows. **Always check for and use Taskfile tasks first** before running raw commands.

Common task patterns:
```bash
task                    # List available tasks
task dev:setup          # Initial project setup
task dev:reset          # Reset local environment
task ci                 # Run CI checks (coding standards, tests)
task ci:coding-standards
task ci:phpunit
task config:export      # Export Drupal configuration
task config:import      # Import Drupal configuration
```

**Convention:** If a Taskfile.yml exists, prefer `task <name>` over direct `itkdev-docker-compose` commands, as tasks often chain multiple commands and handle edge cases.

## Xdebug

ITK Dev Docker environments include Xdebug for step debugging PHP code.

### Enabling Xdebug

Xdebug is typically controlled via environment variables in the Docker setup:

```bash
# Check if Xdebug is enabled
itkdev-docker-compose php -m | grep xdebug

# Enable Xdebug (if using XDEBUG_MODE environment variable)
# Add to docker-compose.override.yml or .env file:
XDEBUG_MODE=debug
```

Common `XDEBUG_MODE` values:
- `off` - Disable Xdebug (default for performance)
- `debug` - Enable step debugging
- `coverage` - Enable code coverage analysis
- `debug,coverage` - Enable both

### IDE Configuration

#### VS Code

1. Install the **PHP Debug** extension by Xdebug
2. Create `.vscode/launch.json`:

```json
{
  "version": "0.2.0",
  "configurations": [
    {
      "name": "Listen for Xdebug",
      "type": "php",
      "request": "launch",
      "port": 9003,
      "pathMappings": {
        "/app": "${workspaceFolder}"
      }
    }
  ]
}
```

#### PHPStorm

1. Go to **Settings → PHP → Servers**
2. Add a server with:
   - Host: Your local Docker URL (e.g., `project.docker.localhost`)
   - Port: 80
   - Debugger: Xdebug
   - Path mappings: `/app` → project root
3. Go to **Settings → PHP → Debug**
   - Debug port: 9003
4. Click **Start Listening for PHP Debug Connections**

### Debugging Workflow

1. Set breakpoints in your IDE
2. Start listening for debug connections
3. Trigger the code (via browser, drush, or CLI)
4. Step through code using IDE controls

### Debugging Drush Commands

```bash
# Run drush with Xdebug enabled
XDEBUG_MODE=debug itkdev-docker-compose drush <command>
```

### Troubleshooting

- **Xdebug not connecting**: Check that `xdebug.client_host` points to your host machine (usually `host.docker.internal`)
- **Wrong path mappings**: Ensure IDE path mappings match Docker volume mounts (typically `/app`)
- **Performance issues**: Set `XDEBUG_MODE=off` when not debugging

## Code Audit

When reviewing Drupal code, check for:

### Drupal Coding Standards
- Follow [Drupal.org coding standards](https://www.drupal.org/docs/develop/standards)
- Use proper namespacing: `Drupal\module_name\...`
- Service-based architecture over procedural code
- Dependency injection in classes

### Security Review
- **SQL Injection**: Use Database API with placeholders, never concatenate user input
- **XSS Prevention**: Use `#markup` with `Xss::filter()`, `#plain_text`, or Twig auto-escaping
- **CSRF Protection**: Use Form API with tokens for state-changing operations
- **Access Control**: Implement proper permission checks
- **Input Sanitization**: Use `\Drupal\Component\Utility\Html::escape()`

### Debug Code Detection
Flag and remove before commit:
- `var_dump()`, `print_r()`, `dd()`
- `dpm()`, `dsm()`, `kint()`
- `\Drupal::logger()` with debug level in production code

### Deprecated API Detection

**Drupal 10 Deprecations** (removed in 11):
- `drupal_set_message()` → use `\Drupal::messenger()->addMessage()`
- `file_unmanaged_*` functions → use file system service
- `entity_load()` → use entity type manager
- `db_query()` → use Database service

**Drupal 11 Changes**:
- Symfony 7 compatibility required
- PHP 8.3+ required
- Check `*.info.yml` for `core_version_requirement`

### Code Quality
- SOLID principles in custom code
- Single responsibility for services
- Proper use of hooks vs. event subscribers
- Render arrays over direct HTML
- Configuration over hardcoded values

## Module Development

### Creating a New Module

Basic structure:
```
modules/custom/module_name/
├── module_name.info.yml
├── module_name.module
├── module_name.services.yml
├── module_name.routing.yml
├── module_name.permissions.yml
├── src/
│   ├── Controller/
│   ├── Form/
│   ├── Plugin/
│   └── Service/
├── config/
│   ├── install/
│   └── schema/
└── templates/
```

### info.yml Template
```yaml
name: 'Module Name'
type: module
description: 'Module description'
package: Custom
core_version_requirement: ^10 || ^11
dependencies:
  - drupal:node
```

### Service Definition
```yaml
services:
  module_name.example_service:
    class: Drupal\module_name\Service\ExampleService
    arguments: ['@entity_type.manager', '@current_user']
```

## Theme Development

### Creating a New Theme

Basic structure:
```
themes/custom/theme_name/
├── theme_name.info.yml
├── theme_name.libraries.yml
├── theme_name.theme
├── css/
├── js/
├── images/
└── templates/
```

### Theme info.yml Template
```yaml
name: 'Theme Name'
type: theme
description: 'Theme description'
package: Custom
core_version_requirement: ^10 || ^11
base theme: stable9
libraries:
  - theme_name/global-styling
```

## Drush Commands

**Always run drush via itkdev-docker-compose** (or use Taskfile tasks if available):

```bash
# Cache
itkdev-docker-compose drush cr                    # Clear all caches
itkdev-docker-compose drush cc render             # Clear render cache only

# Configuration
itkdev-docker-compose drush cex -y                # Export configuration
itkdev-docker-compose drush cim -y                # Import configuration
itkdev-docker-compose drush config:get system.site  # Get specific config

# Database
itkdev-docker-compose drush sql:dump > backup.sql # Database backup
itkdev-docker-compose sql:cli                     # Database CLI (direct command)

# Updates
itkdev-docker-compose drush updb -y               # Run database updates
itkdev-docker-compose drush entity:updates        # Apply entity schema updates

# Development
itkdev-docker-compose drush en module_name -y     # Enable module
itkdev-docker-compose drush pmu module_name -y    # Uninstall module

# Generate (requires drush generators)
itkdev-docker-compose drush generate module       # Generate module scaffold
itkdev-docker-compose drush generate controller   # Generate controller
```

## Configuration Management

### Workflow
1. Make changes in development environment
2. Export: `task config:export` or `itkdev-docker-compose drush cex -y`
3. Review changes in `config/sync/`
4. Commit configuration files
5. On deployment: `task config:import` or `itkdev-docker-compose drush cim -y`

### Config Split
For environment-specific configuration:
- `config/sync/` - Shared configuration
- `config/dev/` - Development overrides
- `config/prod/` - Production overrides

### Schema Definition
Always define schema for custom configuration in `config/schema/module_name.schema.yml`:
```yaml
module_name.settings:
  type: config_object
  label: 'Module settings'
  mapping:
    enabled:
      type: boolean
      label: 'Enabled'
    api_key:
      type: string
      label: 'API Key'
```

## ITK Dev Conventions

When working on ITK Dev Drupal projects:
- **Always use Docker**: Run all commands via `itkdev-docker-compose` or Taskfile tasks
- **Check Taskfile.yml first**: Use `task` to list available tasks before running raw commands
- Follow `itkdev-github-guidelines` for commits and PRs
- Check for project-specific `CLAUDE.md` guidelines
- Configuration should be exportable and version controlled
- Custom modules go in `web/modules/custom/`
- Custom themes go in `web/themes/custom/`
- Run `task ci` (or equivalent) before creating PRs to ensure code quality

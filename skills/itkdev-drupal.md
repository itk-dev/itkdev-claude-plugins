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
- `drush` commands available

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

Common commands for development:

```bash
# Cache
drush cr                          # Clear all caches
drush cc render                   # Clear render cache only

# Configuration
drush cex -y                      # Export configuration
drush cim -y                      # Import configuration
drush config:get system.site      # Get specific config

# Database
drush sql:dump > backup.sql       # Database backup
drush sql:cli                     # Database CLI

# Updates
drush updb -y                     # Run database updates
drush entity:updates              # Apply entity schema updates

# Development
drush en module_name -y           # Enable module
drush pmu module_name -y          # Uninstall module
drush cr && drush cim -y          # Common workflow: clear cache + import config

# Generate (requires drupal/console or drush generators)
drush generate module             # Generate module scaffold
drush generate controller         # Generate controller
```

## Configuration Management

### Workflow
1. Make changes in development environment
2. Export: `drush cex -y`
3. Review changes in `config/sync/`
4. Commit configuration files
5. On deployment: `drush cim -y && drush cr`

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
- Follow `itkdev-github-guidelines` for commits and PRs
- Use ITK Dev Docker setup when available
- Check for project-specific `CLAUDE.md` guidelines
- Configuration should be exportable and version controlled
- Custom modules go in `web/modules/custom/`
- Custom themes go in `web/themes/custom/`

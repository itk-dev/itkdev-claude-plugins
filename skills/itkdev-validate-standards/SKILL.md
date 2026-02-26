---
name: itkdev-validate-standards
description: |
  Validate project against itk-dev Docker and development conventions from
  itk-dev/devops_itkdev-docker. Use when: (1) auditing Docker setup, (2)
  "check itk-dev standards", (3) reviewing PR for convention compliance,
  (4) setting up a new itk-dev project, (5) upgrading Docker configuration.
  Walks through 9 validation areas: MCP tool comparison, docker-compose,
  server compose, environment, Taskfile, Symfony/PHP config, Composer,
  GitHub Actions, and miscellaneous files.
author: Claude Code
version: 1.0.0
---

# Validate itk-dev Standards

## Problem

itk-dev projects must follow conventions from the
`itk-dev/devops_itkdev-docker` template repository. Manually checking
compliance across Docker Compose files, Taskfile, GitHub Actions, PHP
tooling, and environment configuration is error-prone. This skill
provides a structured checklist to audit any Symfony project.

## Context / Trigger Conditions

Use this skill when:
- Auditing a project for itk-dev convention compliance
- Reviewing a PR that changes Docker, Taskfile, or CI configuration
- Setting up a new itk-dev Symfony project
- Upgrading from older itk-dev Docker conventions
- User asks to "check itk-dev standards" or "validate Docker setup"

## Solution

### Step 0 — MCP Tool Automated Comparison

Before manual checks, attempt automated comparison using the
`plugin:itkdev-tools:itkdev-docker` MCP tools. These provide
file-level diffs against the canonical template.

**Procedure:**

1. **Detect project type:**
   ```
   Tool: mcp__plugin_itkdev-tools_itkdev-docker__itkdev_detect_project
   Parameter: path = <project root>
   ```
   Returns: template name (e.g., `symfony-7`), PHP version, framework.

2. **Compare against template:**
   ```
   Tool: mcp__plugin_itkdev-tools_itkdev-docker__itkdev_compare_project
   Parameter: path = <project root>
   ```
   Returns: list of missing, outdated, and extra files vs. the template.

3. **Fetch canonical file content (for any diffs):**
   ```
   Tool: mcp__plugin_itkdev-tools_itkdev-docker__itkdev_get_template_content
   Parameters: template = <detected template>, file = <relative path>
   ```
   Returns: the template's version of the file for manual comparison.

4. **List available templates (if detection fails):**
   ```
   Tool: mcp__plugin_itkdev-tools_itkdev-docker__itkdev_list_templates
   ```
   Returns: all available templates with PHP versions.

**Fallback:** If MCP tools are unavailable or the project is not detected,
proceed with the manual checklist below.

---

### Step 1 — Docker Compose (`docker-compose.yml`)

Validate the development Docker Compose file.

#### Networks

- [ ] `frontend` network declared as `external: true`
- [ ] `app` network declared with `driver: bridge`

#### Images

- [ ] `phpfpm` uses `itkdev/php8.4-fpm:latest` (or appropriate PHP version)
- [ ] `mariadb` uses `itkdev/mariadb:latest`
- [ ] `nginx` uses `nginxinc/nginx-unprivileged:alpine`
- [ ] `worker` uses `itkdev/supervisor-php8.4:alpine` (matching PHP version)

#### Service Names

- [ ] Services named: `phpfpm`, `mariadb`, `nginx`, `worker`
  (plus any project-specific services)

#### Healthchecks

- [ ] Every service has a `healthcheck` block
- [ ] Each healthcheck has `start_period`, `interval`, `timeout`, `retries`
- [ ] `phpfpm` healthcheck tests TCP port 9000
- [ ] `mariadb` healthcheck uses `healthcheck.sh --connect --innodb_initialized`
- [ ] `nginx` depends_on phpfpm with `condition: service_healthy`
- [ ] `worker` depends_on mariadb and phpfpm with `condition: service_healthy`

#### Volumes

- [ ] Application volume mounted as `.:/app` (no `:Z` suffix)
- [ ] Nginx templates from `.docker/templates` (dot-prefix directory)

#### Traefik Labels

- [ ] `traefik.enable=true`
- [ ] `traefik.docker.network=frontend`
- [ ] Router rule uses `${COMPOSE_PROJECT_NAME}` and `${COMPOSE_DOMAIN}`

#### Dev Profile Services

- [ ] `node`, `markdownlint`, `prettier` services have `profiles: [dev]`

#### Remediation

| Check | Fix |
|-------|-----|
| Wrong image | Replace with `itkdev/php8.4-fpm:latest` etc. |
| Missing healthcheck | Add healthcheck block with all 4 timing fields |
| Volume uses `:Z` | Remove `:Z` suffix — not needed for standard Docker |
| Docker dir not dot-prefixed | Rename `docker/` to `.docker/` |
| Missing Traefik labels | Add labels using `${COMPOSE_PROJECT_NAME}` variables |

---

### Step 2 — Docker Compose Server (`docker-compose.server.yml`)

Validate the production/server Docker Compose override.

- [ ] File exists at project root
- [ ] All services have `restart: unless-stopped`
- [ ] Required variables use `:?` syntax (e.g., `${COMPOSE_PROJECT_NAME:?}`,
  `${COMPOSE_SERVER_DOMAIN:?}`)
- [ ] Traefik labels include HTTPS redirect middleware:
  - Router with `-http` suffix on `entrypoints=web`
  - `redirect-to-https` middleware
  - Router on `entrypoints=websecure`
- [ ] No dev-profile services (`node`, `markdownlint`, `prettier`)
- [ ] `mariadb` service is absent (server uses external/managed database,
  or is present if self-hosted DB is intended)
- [ ] Nginx volumes include `.docker/nginx.conf` mount

#### Remediation

| Check | Fix |
|-------|-----|
| Missing `restart` | Add `restart: unless-stopped` to every service |
| Variables without `:?` | Change `${VAR}` to `${VAR:?}` for required vars |
| No HTTPS redirect | Add `-http` router + `redirect-to-https` middleware labels |

---

### Step 3 — Environment (`.env`)

Validate environment file conventions.

- [ ] `.env` is committed to version control
- [ ] `.env.local` is in `.gitignore`
- [ ] First 3 lines are (in order):
  1. `COMPOSE_PROJECT_NAME=<project-name>`
  2. `COMPOSE_DOMAIN=<project>.local.itkdev.dk`
  3. `COMPOSE_SERVER_DOMAIN=<project>.<domain>`
- [ ] `COMPOSE_DOMAIN` matches `*.local.itkdev.dk` pattern
- [ ] `DATABASE_URL` uses `mariadb` as database hostname
- [ ] No secrets or real API keys in `.env` (only placeholders)

#### Remediation

| Check | Fix |
|-------|-----|
| `.env` not committed | Remove from `.gitignore`, commit with safe defaults |
| Wrong `COMPOSE_DOMAIN` | Set to `<project>.local.itkdev.dk` |
| Real secrets in `.env` | Move to `.env.local`, replace with placeholders |

---

### Step 4 — Taskfile.yml

Validate task runner configuration.

#### Header

- [ ] `version: "3"`
- [ ] `dotenv: [".env.local", ".env"]` (`.env.local` first for override priority)

#### Standard Variables

- [ ] `DOCKER_COMPOSE` defined (supports override via `CONTAINER_COMPOSE`)
- [ ] `PHP` defined as `{{.DOCKER_COMPOSE}} exec phpfpm`
- [ ] `COMPOSER` defined as `{{.PHP}} composer`
- [ ] `CONSOLE` defined as `{{.PHP}} bin/console`
- [ ] `NODE` defined as `{{.DOCKER_COMPOSE}} run --rm node`

#### Required Tasks

- [ ] `setup` — first-time project setup (calls up, install, build, migrate)
- [ ] `up` — start containers and run migrations
- [ ] `down` — stop containers (`{{.DOCKER_COMPOSE}} down`)
- [ ] `restart` — calls down then up
- [ ] `install` — install all dependencies (composer + assets)
- [ ] `ci` — run all CI checks
- [ ] `lint` — run all linters (calls subtasks)
- [ ] `lint:php` — PHP CS Fixer dry-run
- [ ] `lint:php:fix` — PHP CS Fixer fix
- [ ] `lint:twig` — Twig CS Fixer lint
- [ ] `lint:twig:fix` — Twig CS Fixer fix
- [ ] `lint:composer` — composer validate + normalize dry-run
- [ ] `lint:markdown` — markdown lint via container
- [ ] `lint:styles` — Prettier check on CSS/SCSS
- [ ] `analyze` — PHPStan analyse
- [ ] `test` — PHPUnit all tests

#### CI Task Order

- [ ] `ci` runs in order: `assets:build` -> `lint` -> `analyze` -> `test`

#### Internal Tasks

- [ ] `db:migrate` is `internal: true`
- [ ] `network:frontend` check task exists and is `internal: true`
- [ ] `up` is split: `up:start` (infrastructure) + `up:worker` (worker container)

#### Remediation

| Check | Fix |
|-------|-----|
| Missing dotenv | Add `dotenv: [".env.local", ".env"]` |
| Wrong var names | Rename to match standard: `DOCKER_COMPOSE`, `PHP`, etc. |
| Missing task | Add task following the patterns in the template |
| `db:migrate` not internal | Add `internal: true` to prevent direct invocation |
| CI order wrong | Reorder cmds: assets:build, lint, analyze, test |

---

### Step 5 — Symfony/PHP Config

Validate PHP tooling configuration.

#### PHP CS Fixer (`.php-cs-fixer.dist.php`)

- [ ] File exists at project root
- [ ] Rules include `@Symfony` and `@PHP84Migration`
  (PHP migration rule matches project PHP version)
- [ ] Finder uses `ignoreVCSIgnored(true)`
- [ ] Header comment references `itk-dev/devops_itkdev-docker` origin

#### PHPStan (`phpstan.dist.neon`)

- [ ] File exists at project root
- [ ] Level is 6 (or higher)
- [ ] `paths` includes `src`
- [ ] `excludePaths` includes `src/Kernel.php`

#### PHP Code Conventions

- [ ] All PHP files have `declare(strict_types=1)`
- [ ] Classes use `final class` pattern (where appropriate)

#### Remediation

| Check | Fix |
|-------|-----|
| Missing `.php-cs-fixer.dist.php` | Copy from template, adjust finder excludes |
| Wrong PHPStan level | Set `level: 6` in `phpstan.dist.neon` |
| Missing `Kernel.php` exclude | Add to `excludePaths` in PHPStan config |

---

### Step 6 — Composer

Validate Composer configuration.

- [ ] `ergebnis/composer-normalize` is a dev dependency
- [ ] `friendsofphp/php-cs-fixer` is a dev dependency
- [ ] `phpstan/phpstan` is a dev dependency
- [ ] `ergebnis/composer-normalize` is in `allow-plugins`
- [ ] `composer.json` is normalized (run `composer normalize --dry-run`)

#### Remediation

| Check | Fix |
|-------|-----|
| Missing dev dep | `composer require --dev <package>` |
| Not in allow-plugins | Add to `config.allow-plugins` in `composer.json` |
| Not normalized | Run `composer normalize` |

---

### Step 7 — GitHub Actions

Validate CI workflow files.

#### Expected Workflow Files

- [ ] `.github/workflows/changelog.yaml`
- [ ] `.github/workflows/composer.yaml`
- [ ] `.github/workflows/javascript.yaml`
- [ ] `.github/workflows/markdown.yaml`
- [ ] `.github/workflows/php.yaml`
- [ ] `.github/workflows/styles.yaml`
- [ ] `.github/workflows/twig.yaml`
- [ ] `.github/workflows/yaml.yaml`

#### Workflow Content Standards

- [ ] Each file starts with header comment:
  `# Do not edit this file!` (referencing `itk-dev/devops_itkdev-docker`)
- [ ] `env` section includes `COMPOSE_USER: runner`
- [ ] `composer.yaml` additionally has `COMPOSE_DOMAIN: test.itkdev.dk`
- [ ] Steps use `actions/checkout@v5`
- [ ] Steps include `docker network create frontend`
- [ ] Triggers: `pull_request` + `push` to `main` and `develop`
  (exception: `changelog.yaml` triggers only on `pull_request`)

#### Remediation

| Check | Fix |
|-------|-----|
| Missing workflow | Copy from template repo's `github/workflows/symfony/` |
| Outdated checkout | Update to `actions/checkout@v5` |
| Missing `COMPOSE_USER` | Add `env: COMPOSE_USER: runner` at workflow level |
| Missing network create | Add step: `docker network create frontend` |

---

### Step 8 — Miscellaneous

Validate supporting files.

- [ ] `CHANGELOG.md` exists at project root
- [ ] `CHANGELOG.md` follows [Keep a Changelog](https://keepachangelog.com/) format
- [ ] `.prettierrc.yaml` exists (or equivalent Prettier config)
- [ ] Markdown lint config exists (`.markdownlint.jsonc`, `.markdownlint.yml`,
  or similar)
- [ ] `.docker/` directory uses dot-prefix (not `docker/`)

#### Remediation

| Check | Fix |
|-------|-----|
| No CHANGELOG.md | Create with Keep a Changelog template |
| No Prettier config | Add `.prettierrc.yaml` from template |
| No markdown lint config | Add config file from template |
| `docker/` not dot-prefixed | Rename to `.docker/` and update all references |

---

## Verification

After completing all checks, produce a summary report in this format:

```
## itk-dev Standards Validation Report

Project: <project name>
Template: <detected template or "manual">
Date: <current date>

### Results

| Area                     | Status | Issues |
|--------------------------|--------|--------|
| Step 0: MCP Comparison   |   /    |   -    |
| Step 1: docker-compose   |   /    |   0    |
| Step 2: Server compose   |   /    |   0    |
| Step 3: Environment      |   /    |   0    |
| Step 4: Taskfile          |   /    |   0    |
| Step 5: Symfony/PHP       |   /    |   0    |
| Step 6: Composer          |   /    |   0    |
| Step 7: GitHub Actions    |   /    |   0    |
| Step 8: Miscellaneous     |   /    |   0    |

### Issues Found

(List any failing checks with remediation steps)

### Summary

X/Y checks passed. [COMPLIANT | NEEDS FIXES]
```

## Common Issues

### `docker/` directory instead of `.docker/`

**Cause:** Older itk-dev convention or custom setup.

**Fix:** Rename directory and update all references in `docker-compose.yml`,
`docker-compose.server.yml`, and any Dockerfiles.

### Missing healthchecks on services

**Cause:** Services added without following the template pattern.

**Fix:** Add healthcheck blocks. Use existing services as reference — each
needs `test`, `start_period`, `interval`, `timeout`, and `retries`.

### Taskfile uses `docker compose` directly instead of variables

**Cause:** Taskfile not updated for Podman compatibility.

**Fix:** Replace hardcoded `docker compose` with `{{.DOCKER_COMPOSE}}` and
add the standard vars block.

### GitHub Action workflows edited locally

**Cause:** Fixes applied directly instead of upstream in the template repo.

**Fix:** Revert local changes. If the fix is needed, submit a PR to
`itk-dev/devops_itkdev-docker` and re-copy the workflow file.

### `.env` contains real secrets

**Cause:** API keys or passwords committed by mistake.

**Fix:** Move secrets to `.env.local` (gitignored). Replace values in `.env`
with empty strings or placeholder text. Rotate any exposed credentials.

## Example

**Scenario:** Validate this project after PR #80 alignment

```
## itk-dev Standards Validation Report

Project: accessibility-checker
Template: symfony-7 (auto-detected)
Date: 2026-02-26

### Results

| Area                     | Status | Issues |
|--------------------------|--------|--------|
| Step 0: MCP Comparison   | PASS   |   0    |
| Step 1: docker-compose   | PASS   |   0    |
| Step 2: Server compose   | PASS   |   0    |
| Step 3: Environment      | PASS   |   0    |
| Step 4: Taskfile          | PASS   |   0    |
| Step 5: Symfony/PHP       | PASS   |   0    |
| Step 6: Composer          | PASS   |   0    |
| Step 7: GitHub Actions    | PASS   |   0    |
| Step 8: Miscellaneous     | PASS   |   0    |

### Summary

All checks passed. COMPLIANT
```

## References

- Template repository: <https://github.com/itk-dev/devops_itkdev-docker>
- MCP plugin: `plugin:itkdev-tools:itkdev-docker` (5 tools)
  - `itkdev_detect_project` — detect project type and PHP version
  - `itkdev_compare_project` — file-level diff against template
  - `itkdev_get_template_content` — fetch canonical file from template
  - `itkdev_get_template_files` — list files in a template
  - `itkdev_list_templates` — list all available templates
- Project CLAUDE.md: conventions and architecture overview
- Taskfile.dev documentation: <https://taskfile.dev>

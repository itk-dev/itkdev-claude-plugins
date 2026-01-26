# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]

### Added

- Drupal development skill for code auditing, module/theme development, and configuration management (Drupal 10/11)
- Auto-release workflow for MCP dependency updates
  - Daily scheduled check for new MCP releases (8:30 UTC)
  - Automated version bump and release creation when updates detected
  - Version tracking in `.claude-plugin/mcp-versions.json`

## [0.2.0] - 2025-01-24

### Added

- User-invocable skills for common workflows
  - `/itkdev-commit` - Create commits following ITK Dev guidelines
  - `/itkdev-pr` - Create pull requests with proper formatting
  - `/itkdev-changelog` - Update changelog entries

### Changed

- Renamed skills to use `itkdev` prefix for consistency

## [0.1.0] - 2025-01-23

### Added

- Initial plugin release
- Browser feedback MCP server integration
- GitHub guidelines skill for ITK Dev team workflows
- Plugin marketplace structure

[Unreleased]: https://github.com/itk-dev/itkdev-claude-plugins/compare/v0.2.0...HEAD
[0.2.0]: https://github.com/itk-dev/itkdev-claude-plugins/compare/v0.1.0...v0.2.0
[0.1.0]: https://github.com/itk-dev/itkdev-claude-plugins/releases/tag/v0.1.0

# Change Guide

## Overview

Guidelines for making changes to this repository: PKGBUILDs, build scripts, CLI tools, and documentation.

## Change Categories

### 1. Package Version Update
**Trigger**: Upstream release new version
**Files**: `pkg/<name>/PKGBUILD`
**Steps**:
1. Update `pkgver` in PKGBUILD
2. Reset `pkgrel=1`
3. Update `source` URLs if versioned
4. Run `updpkgsums` in package directory
5. Test build: `bash makepkgs.sh`
6. Verify: `pacman -Si --dbpath repo/ <package>`
7. Commit: `git commit -m "pkg/<name>: update to <version>"`

### 2. Package Release Bump (Rebuild)
**Trigger**: Dependency update, build fix, metadata change
**Files**: `pkg/<name>/PKGBUILD`
**Steps**:
1. Increment `pkgrel` (e.g., `1` → `2`)
2. No source URL changes needed
3. Test build
4. Commit: `git commit -m "pkg/<name>: rebuild (pkgrel=<n>)"`

### 3. Dependency Change
**Trigger**: Add/remove/change `depends`, `makedepends`, `optdepends`
**Files**: `pkg/<name>/PKGBUILD`
**Steps**:
1. Edit dependency arrays
2. Increment `pkgrel`
3. Test build (ensures new deps available)
4. Verify runtime: install and test CLI
5. Commit with clear message

### 4. Source Change
**Trigger**: Upstream URL change, add patch, change download method
**Files**: `pkg/<name>/PKGBUILD`, `pkg/<name>/src/`
**Steps**:
1. Update `source` array
2. Add/remove files in `src/`
3. Run `updpkgsums`
4. Test build
5. Commit

### 5. Build Script Change (`makepkgs.sh`)
**Trigger**: Logic improvement, new architecture, cleanup policy change
**Files**: `makepkgs.sh`
**Steps**:
1. Edit script
2. Test full pipeline: `bash makepkgs.sh`
3. Verify all packages build
4. Verify databases generate
5. Commit: `git commit -m "build: <description>"`

### 6. CLI Tool Change
**Trigger**: Feature, bug fix, behaviour change
**Files**: `pkg/<name>/src/<script>.sh`
**Steps**:
1. Edit source script
2. Test manually: run script directly
3. Rebuild package: `cd pkg/<name> && makepkg -Csrf`
4. Install and test: `pacman -U repo/<package>.pkg.tar.zst`
5. Increment `pkgrel` in PKGBUILD
6. Full pipeline test: `bash makepkgs.sh`
7. Commit

### 7. New Package
**Trigger**: Add new software to repository
**Files**: `pkg/<new-name>/PKGBUILD`, `pkg/<new-name>/src/`
**Steps**:
1. Create directory structure
2. Write PKGBUILD from template
3. Add source files to `src/`
4. Test build: `cd pkg/<new-name> && makepkg -Csrf`
5. Full pipeline: `bash makepkgs.sh`
6. Verify in repo: `pacman -Si --dbpath repo/ <new-name>`
7. Commit: `git commit -m "pkg/<new-name>: add new package"`

### 8. Remove Package
**Trigger**: Deprecate, license issue, no longer needed
**Files**: `pkg/<name>/` (entire directory)
**Steps**:
1. Remove package directory: `rm -rf pkg/<name>/`
2. Clean artifacts: `rm repo/<name>-*.pkg.tar.zst`
3. Regenerate databases: `bash makepkgs.sh`
4. Commit: `git commit -m "pkg/<name>: remove package"`

### 9. Architecture Change
**Trigger**: Add/drop architecture support
**Files**: `pkg/<name>/PKGBUILD` (arch array), `makepkgs.sh` (ARCH loop)
**Steps**:
1. Modify `arch` in PKGBUILD
2. If new arch: ensure build infrastructure exists
3. If dropping arch: clean artifacts `rm repo/<name>*-<arch>.pkg.tar.zst`
4. Full pipeline test
5. Commit

### 10. Documentation Change
**Trigger**: Fix, clarify, add missing docs
**Files**: `docs/**/*.md`
**Steps**:
1. Edit markdown files
2. Verify links: check relative paths work
3. Verify British English spelling
4. Commit: `git commit -m "docs: <description>"`

## Versioning Rules

### Package Version (`pkgver`/`pkgrel`)
| Change Type | pkgver | pkgrel |
|-------------|--------|--------|
| Upstream version bump | Update | Reset to 1 |
| Rebuild (same upstream) | Same | Increment |
| Dependency change | Same | Increment |
| Build fix | Same | Increment |
| Metadata only | Same | Increment |

### Repository Version (Git Tag)
- Single tag for entire repo: `v<major>.<minor>.<patch>`
- Increment on any package change released together
- Format: Semantic versioning

## Testing Requirements

### Minimum Testing
- [ ] `bash makepkgs.sh` completes without error
- [ ] All expected `.pkg.tar.zst` files in `repo/`
- [ ] All databases generate (`.db`, `.files`)
- [ ] `repo-add --verify` passes for all databases
- [ ] `pacman -Si --dbpath repo/` shows correct metadata for each package

### Extended Testing (for CLI changes)
- [ ] Install package locally: `pacman -U repo/<package>.pkg.tar.zst`
- [ ] Run CLI tool with test inputs
- [ ] Verify expected behaviour
- [ ] Uninstall: `pacman -R <package>`

## Commit Message Format

```
<scope>: <short description>

<longer description if needed>

Affected packages: <list>
```

### Scopes
- `pkg/<name>` — Package-specific change
- `build` — Build script (`makepkgs.sh`)
- `docs` — Documentation
- `repo` — Repository configuration
- `ci` — CI/CD (future)

### Examples
```
pkg/image-optimiser: update to 1.2.0

Upstream released 1.2.0 with new PNG optimisation flags.

Affected packages: image-optimiser
```

```
build: add aarch64 to architecture loop

Infrastructure now supports ARM64 builds via cross-compilation.

Affected packages: all
```

```
docs: add CLI reference for plex-video-optimiser

Document interactive prompts, audio/subtitle logic, filename sanitisation.
```

## Pull Request Process

1. Fork repository
2. Create feature branch: `git checkout -b <scope>/<description>`
3. Make changes following guidelines above
4. Test thoroughly
5. Commit with proper messages
6. Push to fork
7. Open PR against `main`
8. PR description: summary, testing done, affected packages
9. Maintainer reviews
10. Merge (squash or rebase)

## Release Process

### Pre-Release Checklist
- [ ] All packages build successfully
- [ ] All databases verify
- [ ] No uncommitted changes
- [ ] CHANGELOG updated (if exists)
- [ ] Version tag decided

### Release Steps
```bash
# 1. Final build
bash makepkgs.sh

# 2. Verify
repo-add --verify repo/hmlendea.db.tar.gz
repo-add --verify repo/hmlendea-x86_64.db.tar.gz
repo-add --verify repo/hmlendea-i686.db.tar.gz

# 3. Tag
git tag -a v1.0.0 -m "Release v1.0.0"
git push origin v1.0.0

# 4. Create GitHub Release (manual or Actions)
# Upload all repo/* files as assets

# 5. Verify release
# Check assets on GitHub
# Test pacman -Sy on clean machine
```

## Rollback Procedure

### Failed Release
```bash
# Delete release and tag
gh release delete v1.0.0 --yes
git tag -d v1.0.0
git push origin --delete v1.0.0

# Fix issues
# Rebuild
bash makepkgs.sh

# Re-tag with patch version
git tag -a v1.0.1 -m "Release v1.0.1 (fix)"
git push origin v1.0.1
```

### Bad Package in Release
1. Fix PKGBUILD
2. Increment `pkgrel`
3. Rebuild
4. If already released: new patch release (v1.0.1)
5. Users update with `pacman -Syu`

## Breaking Changes

### Repository-Level
- Changing `REPO_NAME` in `makepkgs.sh` → breaks pacman.conf
- Changing database naming scheme → breaks existing configs
- Removing architecture support → breaks users on that arch

### Package-Level
- Changing binary name → breaks user scripts
- Removing CLI options → breaks automation
- Changing install paths → breaks dependent packages

### Process for Breaking Changes
1. Document in PR/issue
2. Provide migration path
3. Consider deprecation period
4. Major version bump (repo tag)
5. Clear release notes

## Code Review Checklist

### PKGBUILD Changes
- [ ] `pkgver`/`pkgrel` correct
- [ ] `source` URLs use HTTPS
- [ ] `sha512sums` present and correct
- [ ] `depends`/`makedepends` minimal
- [ ] `package()` only installs to `$pkgdir`
- [ ] No hardcoded paths outside `$pkgdir`
- [ ] License declared correctly

### Script Changes
- [ ] Shebang correct (`#!/bin/bash`)
- [ ] Error handling (set -e, check return codes)
- [ ] No bashisms if POSIX required
- [ ] Variables quoted
- [ ] No secrets or tokens

### Build Script Changes
- [ ] No regression in package discovery
- [ ] Architecture loop handles all cases
- [ ] Cleanup logic preserves correct artifacts
- [ ] Database generation works for all arches
- [ ] Error messages informative

## Deprecation Policy

### Package Deprecation
1. Mark in PKGBUILD comment: `# DEPRECATED: <reason>`
2. Add to README deprecated section
3. Keep for 2 releases
4. Remove with major version bump

### Feature Deprecation (CLI)
1. Add warning message
2. Document alternative
3. Keep for 2 releases
4. Remove with major version bump
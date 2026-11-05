# Design Decisions

## Overview

Architectural Decision Records (ADRs) for significant design choices in this repository.

## ADR Format

Each decision records:
- **Status**: Proposed, Accepted, Superseded, Deprecated
- **Context**: Problem and constraints
- **Decision**: Chosen approach
- **Consequences**: Trade-offs and implications

---

## ADR-001: Single Build Script (makepkgs.sh)

**Status**: Accepted
**Date**: 2024

### Context
Need to build multiple packages for multiple architectures, manage artifacts, generate repositories.

### Decision
Single bash script (`makepkgs.sh`) orchestrates entire pipeline:
- Discovers packages in `pkg/*/`
- Extracts metadata via grep/awk
- Builds per architecture with `makepkg`
- Manages artifacts in central `repo/`
- Generates per-architecture databases with `repo-add`

### Consequences
- **Pros**: Simple, no external dependencies, portable, easy to understand
- **Cons**: No parallelisation, fragile PKGBUILD parsing, no incremental builds, sequential only

---

## ADR-002: Central Artifact Repository (repo/)

**Status**: Accepted
**Date**: 2024

### Context
Built packages need to be collected for repository generation and distribution.

### Decision
All `.pkg.tar.zst` artifacts copied to flat `repo/` directory regardless of source package.

### Consequences
- **Pros**: Simple `repo-add` invocation, easy distribution, single source of truth
- **Cons**: Name collisions possible (mitigated by unique pkgname-ver-rel-arch), no package isolation

---

## ADR-003: Per-Architecture Databases

**Status**: Accepted
**Date**: 2024

### Context
Arch Linux repositories separate packages by architecture.

### Decision
Generate four databases: `any`, `x86_64`, `i686`, `aarch64`. Architecture determined by package filename suffix.

### Consequences
- **Pros**: Standard pacman compatibility, automatic architecture selection
- **Cons**: `aarch64` database empty (no packages), filename-based detection fragile

---

## ADR-004: GitHub Releases for Distribution

**Status**: Accepted
**Date**: 2024

### Context
Need to distribute packages and databases to users.

### Decision
Publish all `repo/` artifacts as GitHub Release assets. Users configure pacman with `Server = https://github.com/.../releases/latest/download/`.

### Consequences
- **Pros**: Free hosting, HTTPS, CDN, versioned releases, easy rollback
- **Cons**: Rate limits, no package signing (yet), manual release process, 2GB file limit

---

## ADR-005: Unsigned Packages (PackageOptional)

**Status**: Accepted (Temporary)
**Date**: 2024

### Context
Package signing requires key management infrastructure.

### Decision
Distribute unsigned packages with `SigLevel = PackageOptional`.

### Consequences
- **Pros**: Simpler release process, no key management
- **Cons**: No integrity verification, MITM vulnerable, not suitable for public repos

---

## ADR-006: PKGBUILD Parsing via Grep/Awk

**Status**: Accepted
**Date**: 2024

### Context
Need to extract metadata (pkgname, pkgver, pkgrel, arch) from PKGBUILDs in bash script.

### Decision
Line-based extraction: `grep "^pkgname=" PKGBUILD | awk -F'=' '{print $2}'`

### Consequences
- **Pros**: No dependencies, works in minimal bash
- **Cons**: Fragile to formatting changes, doesn't handle arrays/complex values, no validation

---

## ADR-007: Architecture-Independent Packages as `any`

**Status**: Accepted
**Date**: 2024

### Context
Fonts, scripts, themes don't contain architecture-specific binaries.

### Decision
`hori-fonts`, `image-optimiser`, `plex-video-optimiser` use `arch=(any)`.

### Consequences
- **Pros**: Single build for all architectures, smaller repo
- **Cons**: Cannot have architecture-specific optimisations

---

## ADR-008: GRUB Theme as Architecture-Specific

**Status**: Accepted
**Date**: 2024

### Context
`grub2-theme-nuci` builds for `x86_64` and `i686` only.

### Decision
Declare `arch=(x86_64 i686)` despite theme being text/images.

### Consequences
- **Pros**: Matches GRUB module architecture requirements
- **Cons**: Duplicate builds for identical content, no `any` support

---

## ADR-009: Interactive CLI Tools

**Status**: Accepted
**Date**: 2024

### Context
`plex-video-optimiser` makes irreversible changes to video files.

### Decision
Require interactive confirmation at each destructive step.

### Consequences
- **Pros**: Prevents accidental data loss, user reviews ffmpeg arguments
- **Cons**: Cannot automate, unsuitable for batch processing, no CI testing

---

## ADR-010: In-Place Image Optimisation

**Status**: Accepted
**Date**: 2024

### Context
`image-optimiser` modifies files directly.

### Decision
Overwrite original files with optimised versions. No backup, no output directory option.

### Consequences
- **Pros**: Simple, no disk space for copies, matches user expectation
- **Cons**: Irreversible, no dry-run, risk of corruption

---

## ADR-011: Filename Sanitisation in plex-video-optimiser

**Status**: Accepted
**Date**: 2024

### Context
Plex libraries benefit from clean, consistent filenames.

### Decision
Aggressive regex-based removal of release groups, quality tags, codec info, years, etc.

### Consequences
- **Pros**: Clean Plex library, consistent naming
- **Cons**: May remove desired information, not configurable, aggressive patterns

---

## ADR-012: No CI/CD Pipeline

**Status**: Accepted (Temporary)
**Date**: 2024

### Context
Builds currently run locally on maintainer machine.

### Decision
No GitHub Actions or other CI configured. Manual `bash makepkgs.sh` and release.

### Consequences
- **Pros**: Simple, no configuration, full control
- **Cons**: No automated testing, no reproducibility guarantee, manual release burden

---

## ADR-013: Single Repository Version Tag

**Status**: Accepted
**Date**: 2024

### Context
Four packages with independent versioning.

### Decision
Single semantic version tag for entire repository (e.g., `v1.0.0`).

### Consequences
- **Pros**: Simple release, atomic repository state
- **Cons**: Package version changes require full repo tag, no independent package releases

---

## ADR-014: Source Files in Git (pkg/*/src/)

**Status**: Accepted
**Date**: 2024

### Context
PKGBUILD `source` arrays reference local files in `src/`.

### Decision
Commit source files (themes, fonts, scripts) to git rather than downloading at build time.

### Consequences
- **Pros**: Reproducible builds, offline builds, version control for sources
- **Cons**: Repository size larger, binary fonts in git, manual source updates

---

## ADR-015: Clean Build Flags (-Csrf)

**Status**: Accepted
**Date**: 2024

### Context
`makepkg` flags control build behaviour.

### Decision
Use `-C` (clean), `-s` (sync deps), `-r` (remove build deps), `-f` (force), `--noconfirm`.

### Consequences
- **Pros**: Clean reproducible builds, automatic dependency handling
- **Cons**: Slower (re-downloads deps), removes build deps each time

---

## ADR-016: No Parallel Package Builds

**Status**: Accepted
**Date**: 2024

### Context
Multiple independent packages could build concurrently.

### Decision
Sequential package processing in single loop.

### Consequences
- **Pros**: Simple, predictable resource usage, easier debugging
- **Cons**: Slower total build time, no CPU utilisation optimisation

---

## ADR-017: Artifact Existence Check for Idempotency

**Status**: Accepted
**Date**: 2024

### Context
Re-running build script should not rebuild unchanged packages.

### Decision
Check `repo/<artifact>.pkg.tar.zst` exists before building.

### Consequences
- **Pros**: Fast re-runs, safe to interrupt/resume
- **Cons**: No detection of PKGBUILD changes, stale artifacts possible

---

## ADR-018: Old Version Cleanup

**Status**: Accepted
**Date**: 2024

### Context
Multiple package versions accumulate in `repo/`.

### Decision
After each package build, remove all artifacts for that package not matching current `pkgver-pkgrel`.

### Consequences
- **Pros**: `repo/` stays clean, single version per package
- **Cons**: Cannot install older versions, no rollback via repo

---

## ADR-019: Unsupported Architecture Cleanup

**Status**: Accepted
**Date**: 2024

### Context
PKGBUILD `arch` array may change (add/drop architectures).

### Decision
Remove artifacts for architectures no longer in PKGBUILD `arch` array.

### Consequences
- **Pros**: `repo/` matches current PKGBUILD declarations
- **Cons**: Aggressive cleanup, no archive of dropped architectures

---

## ADR-020: Database Finalization (.db.tar.gz → .db)

**Status**: Accepted
**Date**: 2024

### Context
`repo-add` writes `.db.tar.gz`, but `pacman` reads `.db`.

### Decision
Copy `.db.tar.gz` to `.db` after generation. Remove `.old` backups.

### Consequences
- **Pros**: Pacman compatibility, clean repo directory
- **Cons**: Extra step, brief window where `.db` missing
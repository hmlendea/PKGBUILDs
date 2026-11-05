# State and Persistence

## Overview

This repository is a build-time system with minimal runtime state. Persistence is filesystem-based with no databases, caches, or external state stores at runtime.

## Build-Time State

### Source State (Git-Tracked)
```
pkg/<name>/
├── PKGBUILD          # Package recipe (authoritative)
├── src/              # Source files (themes, fonts, scripts)
```
- **Authority**: Git repository
- **Mutability**: Version-controlled, PR-reviewed
- **Persistence**: Permanent (git history)

### Build Staging (Ephemeral)
```
pkg/<name>/
├── pkg/              # makepkg staging directory
├── src/              # Extracted sources (downloaded)
├── <name>-<ver>-<rel>-<arch>.pkg.tar.zst  # Built artifact (before copy)
```
- **Authority**: `makepkg` during build
- **Mutability**: Created/destroyed per build
- **Persistence**: Temporary (cleaned by `makepkg -C`)

### Artifact Repository (Persistent)
```
repo/
├── *.pkg.tar.zst     # Package artifacts
├── *.db              # Package databases (pacman format)
├── *.files           # File list databases
├── *.db.tar.gz       # Temporary repo-add output
├── *.files.tar.gz    # Temporary repo-add output
├── *.db.lock         # repo-add lock (transient)
```
- **Authority**: `makepkgs.sh` + `repo-add`
- **Mutability**: Regenerated each full build
- **Persistence**: Until next clean rebuild or manual deletion
- **Backup**: GitHub Releases (immutable once published)

## Runtime State (Installed Packages)

### Package Installation (Target System)
```
/var/lib/pacman/local/<name>-<ver>-<rel>/  # Pacman database
├── desc           # Package metadata
├── files          # File list
├── install        # Install scripts (if any)
```
- **Authority**: `pacman` on target system
- **Mutability**: Modified by `pacman -S/-R/-U`
- **Persistence**: Until package removed

### Installed Files (Target System)
```
/usr/share/grub/themes/Nuci/          # grub2-theme-nuci
/usr/share/fonts/hori-fonts/          # hori-fonts
/usr/bin/image-optimiser              # image-optimiser
/usr/bin/plex-video-optimiser         # plex-video-optimiser
```
- **Authority**: Package contents
- **Mutability**: Read-only (managed by pacman)
- **Persistence**: Until package removed

## State Transitions

### Build Pipeline
```
Git (PKGBUILD + src)
    ↓ makepkg
Build Staging (pkg/, src/)
    ↓ makepkg package()
Artifact (.pkg.tar.zst)
    ↓ cp
repo/ (artifacts)
    ↓ repo-add
repo/ (databases)
    ↓ git tag + GitHub Release
GitHub Releases (immutable)
    ↓ pacman -Sy
Target System (pacman DB + files)
```

### Artifact Lifecycle
1. **Created**: `makepkg` produces `.pkg.tar.zst` in `pkg/<name>/`
2. **Copied**: `makepkgs.sh` copies to `repo/`
3. **Registered**: `repo-add` adds to databases
4. **Published**: GitHub Release upload
5. **Consumed**: `pacman` downloads, verifies, installs
6. **Removed**: Next build cleans old versions

### Database Lifecycle
1. **Deleted**: `makepkgs.sh` removes existing `.db`, `.files`, `.tar.gz`
2. **Generated**: `repo-add` creates `.db.tar.gz`, `.files.tar.gz`
3. **Finalized**: Copy `.db.tar.gz` → `.db`
4. **Cleaned**: Remove `.old` backups
5. **Published**: Upload to GitHub Release

## Persistence Guarantees

### Git-Tracked State
- **Durability**: Git history (immutable after push)
- **Recoverability**: `git checkout`, `git restore`
- **Consistency**: Single source of truth

### Artifact State (repo/)
- **Durability**: Local filesystem + GitHub Releases
- **Recoverability**: Rebuild from source, or download from Release
- **Consistency**: Regenerated atomically per build

### Target System State
- **Durability**: Pacman database (transactional)
- **Recoverability**: `pacman -U` local file, or re-download
- **Consistency**: Pacman transactions (atomic)

## State Not Persisted

### No Build Cache
- No `ccache`, `sccache` configured
- No incremental compilation
- Each build starts clean (`makepkg -C`)

### No Dependency Cache
- `makepkg -s` installs build deps fresh each run
- No shared package cache across builds
- `pacman` cache (`/var/cache/pacman/pkg/`) used but not managed

### No Configuration State
- No user configuration files
- No runtime configuration
- All behaviour hardcoded in scripts/PKGBUILDs

### No Runtime State (CLI Tools)
- `image-optimiser`: Stateless, processes files and exits
- `plex-video-optimiser`: Stateless, processes one file and exits
- No daemon, no background processes, no session state

## Backup and Recovery

### Repository Recovery
```bash
# Full rebuild from source
rm -rf repo/
bash makepkgs.sh

# Or download from GitHub Release
gh release download v1.0.0 -D repo/
```

### Target System Recovery
```bash
# Reinstall all packages from repo
pacman -S hmlendea/grub2-theme-nuci hmlendea/hori-fonts hmlendea/image-optimiser hmlendea/plex-video-optimiser

# Or from local artifacts
pacman -U repo/*.pkg.tar.zst
```

### Database Recovery
```bash
# Regenerate from artifacts
rm repo/*.db repo/*.files repo/*.db.tar.gz repo/*.files.tar.gz
bash makepkgs.sh
```

## Consistency Model

### Eventual Consistency (Distribution)
- GitHub Release → CDN propagation (seconds)
- `pacman -Sy` fetches latest
- No strong consistency guarantees

### Strong Consistency (Build)
- Single-threaded sequential execution
- Databases match artifacts at generation time
- No partial states visible (cleanup before generation)

### Transactional (Installation)
- `pacman` uses transactions
- All-or-nothing package installation
- Rollback on failure

## Data Retention

### Local (repo/)
- **Policy**: Only current `pkgver-pkgrel` per package per architecture
- **Cleanup**: Automatic in `makepkgs.sh`
- **Max age**: One build cycle

### GitHub Releases
- **Policy**: All releases retained
- **Cleanup**: Manual (delete release)
- **Max age**: Indefinite

### Target System
- **Policy**: User-controlled
- **Cleanup**: `pacman -R`, `pacman -Sc`
- **Max age**: Indefinite

## State Inspection

### Build State
```bash
# Current artifacts
ls -la repo/*.pkg.tar.zst

# Database contents
repo-add --verify repo/hmlendea.db.tar.gz
pacman -Sl --dbpath repo/
```

### Target State
```bash
# Installed packages from this repo
pacman -Sl hmlendea

# Package details
pacman -Qi image-optimiser

# File ownership
pacman -Qo /usr/bin/image-optimiser
```

### Git State
```bash
# PKGBUILD versions
grep "^pkgver=" pkg/*/PKGBUILD

# Git tags (releases)
git tag -l "v*"
```
# Browse and Search Behaviour

## Overview

This repository is a build-time package repository, not an interactive application. "Browse and search" refers to how users discover and inspect packages and their contents.

## Package Discovery

### Via GitHub Repository
- Browse `pkg/` directory for package definitions
- Each `pkg/<name>/` contains `PKGBUILD` and source files
- README.md lists all packages with descriptions

### Via Pacman (Target System)
```bash
# List all packages in repository
pacman -Sl hmlendea

# Search by name/description
pacman -Ss <query>

# Show package information
pacman -Si <package>

# List files in package
pacman -Ql <package>
```

### Via GitHub Releases
- Browse releases page for versioned artifacts
- Download individual packages or databases
- Release notes describe changes

## Package Inspection

### PKGBUILD Analysis
```bash
# View package recipe
cat pkg/grub2-theme-nuci/PKGBUILD

# Key fields to inspect:
# pkgname, pkgver, pkgrel, pkgdesc
# arch, url, license
# depends, makedepends, optdepends
# source, sha512sums
# package() function
```

### Built Package Inspection
```bash
# Extract package contents
mkdir /tmp/inspect && cd /tmp/inspect
tar -xzf /path/to/package.pkg.tar.zst

# View metadata
cat .PKGINFO

# View file list
cat .MTREE

# View install scripts
cat .INSTALL
```

### Database Inspection
```bash
# Query local database
pacman -Si --dbpath repo/ <package>

# List all packages in database
pacman -Sl --dbpath repo/

# Search database
pacman -Ss --dbpath repo/ <query>
```

## Search Capabilities

| Method | Scope | Query Type |
|--------|-------|------------|
| GitHub UI | Source code | Filename, content |
| `pacman -Ss` | Installed repo DB | Name, description |
| `pacman -Sl` | Installed repo DB | All packages |
| `grep` on PKGBUILDs | Source recipes | Dependencies, variables |
| GitHub Releases | Built artifacts | Version, architecture |

## Filtering

### By Architecture
```bash
# List x86_64 packages only
pacman -Sl hmlendea | grep x86_64

# List any-architecture packages
pacman -Sl hmlendea | grep any
```

### By Dependency
```bash
# Find packages depending on ffmpeg
grep -r "ffmpeg" pkg/*/PKGBUILD

# Find packages with optdepends on zopfli
grep -r "zopfli" pkg/*/PKGBUILD
```

### By License
```bash
# Find GPL packages
grep -r "GPL" pkg/*/PKGBUILD
```

## Navigation Patterns

### Source → Artifact
```
pkg/grub2-theme-nuci/PKGBUILD
    → pkg/grub2-theme-nuci/src/Nuci/theme.txt
    → repo/grub2-theme-nuci-1.0.0-1-x86_64.pkg.tar.zst
    → /usr/share/grub/themes/Nuci/theme.txt (installed)
```

### Artifact → Source
```
repo/hori-fonts-1.5.0-2-any.pkg.tar.zst
    → pkg/hori-fonts/PKGBUILD
    → pkg/hori-fonts/src/ (font sources)
```

## Limitations

- No web UI for package browsing
- No dependency graph visualisation
- No reverse dependency lookup (what requires X)
- No version history in pacman (only latest in repo)
- Search limited to pacman's name/description index

## Integration Points

- **GitHub**: Source browsing, release downloads
- **Pacman**: Installed system package queries
- **AUR helpers**: Could index this repo (yay, paru)
- **Custom tooling**: Scripts can parse PKGBUILDs directly
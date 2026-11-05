# API Reference

## Overview

This repository provides two command-line interfaces (CLI) via installed packages. There is no HTTP API, REST endpoint, or programmatic library interface.

## Available CLIs

| Package | Binary | Purpose |
|---------|--------|---------|
| `image-optimiser` | `image-optimiser` | Lossless JPEG/PNG optimisation |
| `plex-video-optimiser` | `plex-video-optimiser` | Video optimisation for Plex direct streaming |

## Navigation

- [image-optimiser CLI](./image-optimiser-cli.md) — Image optimisation command reference
- [plex-video-optimiser CLI](./plex-video-optimiser-cli.md) — Video optimisation command reference

## Common Patterns

### Invocation
```bash
# Direct execution (installed via pacman)
image-optimiser [options] <files...>
plex-video-optimiser [options] <files...>

# Help
image-optimiser --help
plex-video-optimiser --help
```

### Exit Codes
| Code | Meaning |
|------|---------|
| 0 | Success |
| 1 | General error |
| 2 | Invalid arguments |
| 130 | Interrupted (SIGINT) |

### Environment
- No required environment variables
- Uses standard `PATH` for dependencies (`jpegoptim`, `oxipng`, `ffmpeg`, `mkvtoolnix`, etc.)
- Respects `TMPDIR` for temporary files

## Package Management API

### Repository Access (pacman)
```bash
# Sync repository
pacman -Sy

# Install package
pacman -S image-optimiser
pacman -S plex-video-optimiser

# Query package info
pacman -Si image-optimiser
pacman -Ql image-optimiser

# Remove package
pacman -R image-optimiser
```

### Repository Configuration
```ini
# /etc/pacman.conf
[hmlendea]
Server = https://github.com/hmlendea/PKGBUILDs/releases/latest/download/
SigLevel = PackageOptional
```

## Build API (makepkgs.sh)

### Invocation
```bash
# Full build pipeline
bash makepkgs.sh

# From repository root
cd /path/to/PKGBUILDs
bash makepkgs.sh
```

### Output
- Built packages in `repo/*.pkg.tar.zst`
- Databases in `repo/*.db`, `repo/*.files`
- Console output with build status
- Final release tag recommendation

### Environment Variables
| Variable | Purpose |
|----------|---------|
| `CARCH` | Target architecture (set internally per-build) |
| `MAKEFLAGS` | Parallel build flags (passed to makepkg) |

## Repository Generation API (repo-add)

### Invocation
```bash
# Manual database regeneration
repo-add repo/hmlendea.db.tar.gz repo/*.pkg.tar.zst

# Per-architecture
repo-add repo/hmlendea-x86_64.db.tar.gz repo/*-x86_64.pkg.tar.zst
```

### Verification
```bash
repo-add --verify repo/hmlendea.db.tar.gz
```

## Versioning

### Package Versions
Each package has independent versioning in its PKGBUILD:
- `grub2-theme-nuci`: 1.0.0
- `hori-fonts`: 1.5.0
- `image-optimiser`: 1.1.0
- `plex-video-optimiser`: 1.7.0

### Repository Version
Single semantic version tag for entire repository (e.g., `v1.0.0`)

## Authentication

- No authentication for package installation (public GitHub Releases)
- `SigLevel = PackageOptional` — unsigned packages accepted
- For signed packages: `SigLevel = PackageRequired` + key management

## Rate Limits

- GitHub Releases: Standard GitHub API limits
- No application-level rate limiting
- `pacman` handles download retries
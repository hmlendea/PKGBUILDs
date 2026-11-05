# Repository Overview

## Purpose

This repository provides a personal Arch Linux package repository containing custom and unofficial packages. It serves as a build and distribution system for four packages:

1. **grub2-theme-nuci** — Personal GRUB2 theme based on Vimix
2. **hori-fonts** — Hori's fonts collection (9 fonts from various sources)
3. **image-optimiser** — Bash script for lossless image compression (JPEG/PNG)
4. **plex-video-optimiser** — Bash script for video optimisation targeting Plex direct streaming

## Scope

The repository owns:
- Build orchestration script (`makepkgs.sh`)
- Package definitions (`pkg/*/PKGBUILD` and associated source files)
- Local repository database (`repo/`) containing built packages and `.db`/`.files` databases
- GitHub Actions workflow for automated builds (implied by GitHub Releases distribution)

The repository deliberately does not own:
- Upstream source code for packaged software
- Arch Linux toolchain (`makepkg`, `repo-add`, `pacman`)
- GitHub Actions infrastructure
- End-user systems consuming packages via `pacman`

## Entry Points

### Primary Entry Point
- `makepkgs.sh` — Single build script that orchestrates the entire pipeline

### Package Entry Points
Each package in `pkg/<name>/` contains:
- `PKGBUILD` — Package metadata and build instructions
- `src/` — Source files (scripts, themes, fonts)
- `pkg/` — Built package staging area (generated during build)

### Distribution Entry Point
- GitHub Releases — Published `.pkg.tar.zst` files and repository databases consumed by `pacman`

## Principal Capabilities

1. **Multi-architecture builds** — Supports `any`, `x86_64`, `i686`, `aarch64`
2. **Automated artifact management** — Removes old versions and unsupported architectures
3. **Repository database generation** — Creates per-architecture `.db` and `.files` databases via `repo-add`
4. **Supply chain verification** — SHA512 checksums for all upstream sources
5. **Clean build environments** — Uses `makepkg -Csrf --noconfirm` for reproducible builds

## Target Audience

- Repository maintainer (builds and publishes packages)
- End users (consume packages via `pacman` after adding repository to `/etc/pacman.conf`)
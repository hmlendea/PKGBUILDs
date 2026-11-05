# Repository Structure

## Source Tree Layout

```
PKGBUILDs/
├── ARCHITECTURE.md           # Root architecture documentation
├── CODE_OF_CONDUCT.md        # Community conduct guidelines
├── CONTRIBUTING.md           # Contribution guidelines
├── makepkgs.sh               # Main build orchestration script
├── PRIVACY.md                # Privacy and data handling
├── README.md                 # Project overview and usage
├── SECURITY.md               # Security policy
├── docs/                     # Generated documentation (this directory)
├── pkg/                      # Package definitions (one subdirectory per package)
│   ├── grub2-theme-nuci/
│   │   ├── PKGBUILD          # Package metadata and build instructions
│   │   ├── src/              # Source files (theme.txt, icons/)
│   │   └── pkg/              # Build staging area (generated)
│   ├── hori-fonts/
│   │   ├── PKGBUILD
│   │   ├── src/              # Font source files (downloaded)
│   │   └── pkg/              # Build staging area (generated)
│   ├── image-optimiser/
│   │   ├── PKGBUILD
│   │   ├── src/              # optimise-image.sh script
│   │   └── pkg/              # Build staging area (generated)
│   └── plex-video-optimiser/
│       ├── PKGBUILD
│       ├── src/              # plex-video-optimiser.sh script
│       └── pkg/              # Build staging area (generated)
└── repo/                     # Built artifacts and repository databases
    ├── *.pkg.tar.zst         # Built packages for all architectures
    ├── hmlendea.db           # Main repository database (any arch)
    ├── hmlendea.files        # Main repository file list
    ├── hmlendea-aarch64.db   # aarch64 architecture database
    ├── hmlendea-aarch64.files
    ├── hmlendea-i686.db      # i686 architecture database
    ├── hmlendea-i686.files
    ├── hmlendea-x86_64.db    # x86_64 architecture database
    └── hmlendea-x86_64.files
```

## Module Organisation

### Build Pipeline (`makepkgs.sh`)
Single script owning the entire build flow:
- Iterates `pkg/*` directories
- Parses PKGBUILD metadata (`pkgname`, `pkgver`, `pkgrel`, `arch`)
- Invokes `makepkg` per architecture
- Manages artifact retention (removes old versions, unsupported arches)
- Generates per-architecture repository databases via `repo-add`

### Package Definitions (`pkg/<name>/`)
Each package is self-contained with:
- `PKGBUILD` — Declarative build recipe (Arch Linux standard)
- `src/` — Source assets (scripts, themes, fonts, downloaded archives)
- `pkg/` — Build output staging (created by `makepkg`, not committed)

### Repository Output (`repo/`)
Immutable artifact store:
- `.pkg.tar.zst` — Built packages (one per package-version-architecture)
- `.db` / `.files` — Repository databases per architecture (`any`, `aarch64`, `i686`, `x86_64`)

## Naming Conventions

| Element | Convention | Example |
|---------|------------|---------|
| Package directories | kebab-case | `grub2-theme-nuci` |
| PKGBUILD variables | lowercase with underscores | `pkgname`, `pkgver`, `sha512sums` |
| Built package files | `{pkgname}-{pkgver}-{pkgrel}-{arch}.pkg.tar.zst` | `grub2-theme-nuci-1.0.0-1-x86_64.pkg.tar.zst` |
| Repository databases | `hmlendea-{arch}.db` / `hmlendea-{arch}.files` | `hmlendea-x86_64.db` |
| Source scripts | kebab-case with `.sh` | `optimise-image.sh` |

## Generated vs Committed Files

**Committed (source control):**
- All files in `pkg/*/PKGBUILD`
- All files in `pkg/*/src/`
- `makepkgs.sh`
- Root documentation files

**Generated (not committed, created during build):**
- `pkg/*/pkg/` directories
- `pkg/*/*.pkg.tar.zst` (in package directory during build)
- `repo/*.pkg.tar.zst` (copied artifacts)
- `repo/*.db`, `repo/*.files` (repository databases)

## Package Directory Structure Detail

Each `pkg/<name>/` follows:
```
pkg/<name>/
├── PKGBUILD              # Required: package recipe
├── src/                  # Required: source files
│   ├── <asset1>          # Theme files, fonts, scripts
│   └── <asset2>
└── pkg/                  # Generated: makepkg staging
    └── <name>/
        └── usr/          # Installed file hierarchy
            ├── share/
            │   ├── grub/themes/Nuci/     # grub2-theme-nuci
            │   └── fonts/hori-fonts/     # hori-fonts
            └── bin/                      # image-optimiser, plex-video-optimiser
                └── <executable>
```
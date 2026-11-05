# Configuration

## Configuration Sources

This repository uses **implicit configuration** through PKGBUILD files and the build script. There are no external configuration files (YAML, JSON, INI, etc.).

### Configuration Hierarchy

```
┌─────────────────────────────────────────────────────────────┐
│                    CONFIGURATION LAYERS                      │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  1. BUILD SCRIPT DEFAULTS (makepkgs.sh)                     │
│     - REPODIR = ./repo                                       │
│     - REPO_NAME = hmlendea                                   │
│     - Target architectures: any, aarch64, i686, x86_64      │
│     - makepkg flags: -Csrf --noconfirm                       │
│                                                              │
│  2. PKGBUILD METADATA (per package)                         │
│     - pkgname, pkgver, pkgrel, pkgdesc                      │
│     - arch (array of supported architectures)               │
│     - url, license                                           │
│     - depends, optdepends, makedepends, checkdepends        │
│     - source (array of URLs)                                 │
│     - sha512sums (array of checksums)                       │
│     - build(), package(), prepare() functions               │
│                                                              │
│  3. ENVIRONMENT VARIABLES (runtime)                         │
│     - CARCH (set by makepkgs.sh per architecture)           │
│     - MAKEFLAGS (parallel build, from environment)          │
│     - PKGDEST, SRCDEST, SRCPKGDEST, LOGDEST (makepkg)       │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

## Build Script Configuration (`makepkgs.sh`)

### Hardcoded Defaults

| Parameter | Value | Override Mechanism |
|-----------|-------|-------------------|
| `REPODIR` | `${DIR}/repo` | Edit script |
| `REPO_NAME` | `hmlendea` | Edit script |
| Target architectures | `any aarch64 i686 x86_64` | Edit script loop |
| `makepkg` flags | `-Csrf --noconfirm` | Edit script |
| Artifact retention | Keep only latest version per package | Edit script cleanup logic |

### Runtime Variables

```bash
# Set by script for each architecture build
CARCH="${PKGARCH}"  # Passed to makepkg

# Standard makepkg environment variables (optional)
# PKGDEST="${DIR}/repo"        # Package destination
# SRCDEST="${DIR}/src"         # Source cache
# SRCPKGDEST="${DIR}/srcpkg"   # Source package cache
# LOGDEST="${DIR}/logs"        # Build logs
```

## Package Configuration (PKGBUILD)

Each package in `pkg/<name>/PKGBUILD` defines its own configuration.

### Required Fields

| Field | Type | Description | Example |
|-------|------|-------------|---------|
| `pkgname` | string | Package name | `grub2-theme-nuci` |
| `pkgver` | string | Upstream version | `1.0.0` |
| `pkgrel` | integer | Package release | `1` |
| `pkgdesc` | string | Short description | `Personal GRUB2 theme based on Vimix` |
| `arch` | array | Supported architectures | `('x86_64' 'i686')` or `('any')` |
| `source` | array | Source URLs | `("https://.../file.zip")` |
| `sha512sums` | array | SHA512 checksums | `('a6bac73fa359...')` |

### Optional Fields

| Field | Type | Description | Example |
|-------|------|-------------|---------|
| `url` | string | Project homepage | `https://github.com/hmlendea/grub2-theme-nuci` |
| `license` | array | License(s) | `('GPL')` |
| `depends` | array | Runtime dependencies | `('grub')` |
| `optdepends` | array | Optional dependencies | `('zopfli: Alternative PNG compression')` |
| `makedepends` | array | Build-time dependencies | `()` |
| `checkdepends` | array | Test dependencies | `()` |
| `install` | string | Install script | `grub2-theme-nuci.install` |
| `options` | array | Build options | `('!strip' '!emptydirs')` |

### Build Functions

| Function | Purpose | Typical Usage |
|----------|---------|---------------|
| `prepare()` | Pre-build preparation | Extract sources, apply patches |
| `build()` | Compilation/build | `make`, `cmake`, custom commands |
| `package()` | Installation to `$pkgdir` | `install -Dm644 ... "$pkgdir/..."` |
| `check()` | Run tests | `make check`, `pytest` |

## Architecture-Specific Configuration

### Supported Architectures

| Architecture | PKGBUILD `arch` Value | Repository Database |
|--------------|----------------------|---------------------|
| Any (architecture-independent) | `('any')` | `hmlendea.db` |
| x86_64 | `('x86_64')` | `hmlendea-x86_64.db` |
| i686 | `('i686')` | `hmlendea-i686.db` |
| aarch64 | `('aarch64')` | `hmlendea-aarch64.db` |

### Package Architecture Mapping

| Package | Architectures | Notes |
|---------|---------------|-------|
| `grub2-theme-nuci` | `x86_64`, `i686` | GRUB themes are architecture-specific (bootloader) |
| `hori-fonts` | `any` | Fonts are architecture-independent |
| `image-optimiser` | `any` | Bash script, architecture-independent |
| `plex-video-optimiser` | `any` | Bash script, architecture-independent |

## Dependency Configuration

### Runtime Dependencies (`depends`)

Declared in each PKGBUILD, resolved by `pacman` at install time.

| Package | Dependencies | Purpose |
|---------|--------------|---------|
| `grub2-theme-nuci` | `grub` | GRUB bootloader required |
| `hori-fonts` | (none) | Fonts only |
| `image-optimiser` | `jpegoptim`, `oxipng` | Image compression tools |
| `plex-video-optimiser` | `mkvtoolnix-cli`, `ffmpeg`, `perl-rename`, `glibc` | Video processing tools |

### Optional Dependencies (`optdepends`)

| Package | Optional Dependencies | Purpose |
|---------|----------------------|---------|
| `image-optimiser` | `zopfli: Alternative PNG compression` | Alternative PNG optimizer |

### Build Dependencies (`makedepends`)

None currently declared. All packages use simple `package()` functions without compilation.

## Source Verification Configuration

### Checksums

All packages **must** declare `sha512sums` for every entry in `source` array.

```bash
# Example from grub2-theme-nuci
source=("${url}/releases/download/v${pkgver}/${pkgname}_${pkgver}.zip")
sha512sums=('a6bac73fa3593b82471a9fa396b219abf0408ca881fdbae8b807ab9b9aaa49dca30729b2b1806862ffa664477726c6d6fbf8538da1d95cfcc3abc94754ce3885')

# Example from hori-fonts (9 sources, 9 checksums)
source=('https://dl.dafont.com/dl/?f=hesperides'
        'https://dl.dafont.com/dl/?f=optimusprinceps'
        ...)
sha512sums=('33d9ac7df86e7b69a1b71a7db5e94f6241c685f29b53819774cff76a00be5388df688dea26d29423ad652bd1bfc7b86b211147c2cff9d7e0d6e2ece017a4404d'
            '3c78a99eeb17ace573f2ddee0fa066b1aa5efab81ad80c4f6af0cb97bef4036243e7a6c9e7f0d0fdba6acf4ad6e07c1878f6fc167256ee6d3e7ee2ad03f2dbbb'
            ...)
```

### Verification Enforcement

- `makepkg` automatically verifies checksums before building
- Build fails if checksums don't match
- No mechanism to skip verification (security requirement)

## Environment-Specific Overrides

### Local Development

```bash
# Override package destination
export PKGDEST="/custom/path/repo"

# Override source cache
export SRCDEST="/custom/path/src"

# Parallel builds
export MAKEFLAGS="-j$(nproc)"
```

### CI/CD (GitHub Actions)

Typical environment variables set by GitHub Actions runner:
- `GITHUB_WORKSPACE` — Repository root
- `HOME` — Runner home directory
- Standard `PATH` with `makepkg`, `repo-add` available

## Configuration Validation

### Pre-Build Checks

The build script performs implicit validation:
1. PKGBUILD exists in each `pkg/*/` directory
2. Required metadata extractable via grep/awk
3. Architecture array parseable
4. Artifact naming convention followed

### Manual Validation

```bash
# Validate PKGBUILD syntax
cd pkg/grub2-theme-nuci
makepkg --printsrcinfo > .SRCINFO  # Validates PKGBUILD

# Check for common issues
namcap PKGBUILD  # If namcap installed

# Verify checksums
makepkg -g >> PKGBUILD  # Generates checksums for current sources
```

## Configuration Drift Prevention

### Principles

1. **Single source of truth** — PKGBUILD is authoritative for package metadata
2. **No external config files** — Avoids drift between config and implementation
3. **Version-controlled** — All configuration in git
4. **Explicit in code** — Build script logic visible, not hidden in config

### Change Process

To modify configuration:
1. Edit `makepkgs.sh` for build pipeline changes
2. Edit `pkg/<name>/PKGBUILD` for package-specific changes
3. Run `bash makepkgs.sh` to verify
4. Commit changes
5. Create new release
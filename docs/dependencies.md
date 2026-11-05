# Dependencies

## External Dependencies

### Build-Time Dependencies (Required on Build System)

| Dependency | Purpose | Source | Version Requirement |
|------------|---------|--------|---------------------|
| `bash` | Build script interpreter | `base` | Any modern version |
| `makepkg` | Package builder | `pacman` (base-devel) | Arch Linux current |
| `repo-add` | Repository database generator | `pacman` (base-devel) | Arch Linux current |
| `fakeroot` | Root simulation for packaging | `base-devel` | Any |
| `grep`, `awk`, `sed`, `find` | Text processing in build script | `base` | POSIX compliant |
| `coreutils` | File operations (cp, rm, mkdir) | `base` | Any |

### Runtime Dependencies (Required on Target Systems)

#### grub2-theme-nuci
| Dependency | Type | Purpose | Provided By |
|------------|------|---------|-------------|
| `grub` | Hard (`depends`) | GRUB bootloader installation | `grub` package |

#### hori-fonts
| Dependency | Type | Purpose | Provided By |
|------------|------|---------|-------------|
| (none) | — | Font files only | — |

#### image-optimiser
| Dependency | Type | Purpose | Provided By |
|------------|------|---------|-------------|
| `jpegoptim` | Hard (`depends`) | JPEG lossless optimization | `jpegoptim` package |
| `oxipng` | Hard (`depends`) | PNG lossless optimization | `oxipng` package |
| `zopfli` | Optional (`optdepends`) | Alternative PNG compression | `zopfli` package |

#### plex-video-optimiser
| Dependency | Type | Purpose | Provided By |
|------------|------|---------|-------------|
| `mkvtoolnix-cli` | Hard (`depends`) | MKV inspection/manipulation | `mkvtoolnix-cli` package |
| `ffmpeg` | Hard (`depends`) | Video/audio transcoding | `ffmpeg` package |
| `perl-rename` | Hard (`depends`) | Batch file renaming | `perl-rename` package |
| `glibc` | Hard (`depends`) | C library (for compiled tools) | `glibc` package |

### Upstream Source Dependencies (Fetched at Build Time)

| Package | Source URL | Type | Verification |
|---------|------------|------|--------------|
| `grub2-theme-nuci` | `https://github.com/hmlendea/grub2-theme-nuci/releases/download/v${pkgver}/${pkgname}_${pkgver}.zip` | GitHub Release | SHA512 |
| `hori-fonts` | `https://dl.dafont.com/dl/?f=hesperides` | dafont.com | SHA512 |
| `hori-fonts` | `https://dl.dafont.com/dl/?f=optimusprinceps` | dafont.com | SHA512 |
| `hori-fonts` | `https://dl.dafont.com/dl/?f=oblivion` | dafont.com | SHA512 |
| `hori-fonts` | `https://dl.dafont.com/dl/?f=planewalker` | dafont.com | SHA512 |
| `hori-fonts` | `https://dl.dafont.com/dl/?f=promised_freedom` | dafont.com | SHA512 |
| `hori-fonts` | `https://dl.dafont.com/dl/?f=soviet_style` | dafont.com | SHA512 |
| `hori-fonts` | `https://www.fontles.com/download/segoe-script-font` | fontles.com | SHA512 |
| `hori-fonts` | `https://www.1001fonts.com/download/fredericka-the-great.zip` | 1001fonts.com | SHA512 |
| `hori-fonts` | `https://raw.githubusercontent.com/ThinkDualBrain/Protomolecule/master/Protomolecule.otf` | GitHub Raw | SHA512 |
| `image-optimiser` | `https://github.com/hmlendea/image-optimiser/releases/download/v${pkgver}/optimise-image.sh` | GitHub Release | SHA512 |
| `plex-video-optimiser` | `https://github.com/hmlendea/plex-video-optimiser/releases/download/v${pkgver}/${pkgname}.sh` | GitHub Release | SHA512 |

## Internal Dependencies

### Package Interdependencies

**None.** All four packages are completely independent:
- No package depends on another
- No shared build artifacts
- No common source files
- Build order is irrelevant

### Build Script Dependencies

`makepkgs.sh` depends on:
- Existence of `pkg/*/PKGBUILD` files
- PKGBUILD metadata format (standard Arch Linux)
- `makepkg` and `repo-add` in PATH
- Write access to `repo/` directory

## Dependency Graph

```
┌─────────────────────────────────────────────────────────────────────────────┐
│                           DEPENDENCY GRAPH                                   │
├─────────────────────────────────────────────────────────────────────────────┤
│                                                                              │
│   BUILD SYSTEM                                                               │
│   ┌─────────────┐                                                            │
│   │  makepkgs.sh │                                                            │
│   └──────┬──────┘                                                            │
│          │                                                                   │
│          ▼                                                                   │
│   ┌─────────────────────────────────────────────────────────────────────┐   │
│   │                    PKGBUILD DEFINITIONS                              │   │
│   │  ┌──────────────┐ ┌────────────┐ ┌───────────────┐ ┌──────────────┐ │   │
│   │  │grub2-theme-  │ │ hori-fonts │ │ image-optimis │ │plex-video-op │ │   │
│   │  │    nuci      │ │            │ │      er       │ │   timiser    │ │   │
│   │  └──────┬───────┘ └─────┬──────┘ └───────┬───────┘ └──────┬───────┘ │   │
│   └─────────┼────────────────┼────────────────┼────────────────┼─────────┘   │
│             │                │                │                │             │
│             ▼                ▼                ▼                ▼             │
│   ┌─────────────────────────────────────────────────────────────────────┐   │
│   │                        MAKEPKG (per package, per arch)               │   │
│   │  ┌──────────────┐ ┌────────────┐ ┌───────────────┐ ┌──────────────┐ │   │
│   │  │ Fetch sources│ │ Fetch srcs │ │ Fetch script  │ │ Fetch script │ │   │
│   │  │ Verify SHA512│ │ Verify SHA512│ │ Verify SHA512 │ │ Verify SHA512│ │   │
│   │  │ Build pkg    │ │ Build pkg  │ │ Build pkg     │ │ Build pkg    │ │   │
│   │  └──────┬───────┘ └─────┬──────┘ └───────┬───────┘ └──────┬───────┘ │   │
│   └─────────┼────────────────┼────────────────┼────────────────┼─────────┘   │
│             │                │                │                │             │
│             ▼                ▼                ▼                ▼             │
│   ┌─────────────────────────────────────────────────────────────────────┐   │
│   │                      REPO/ (artifact store)                          │   │
│   │  *.pkg.tar.zst for all packages and architectures                   │   │
│   └─────────────────────────────────────────────────────────────────────┘   │
│                                    │                                         │
│                                    ▼                                         │
│   ┌─────────────────────────────────────────────────────────────────────┐   │
│   │                    REPO-ADD (per architecture)                       │   │
│   │  hmlendea.db, hmlendea-aarch64.db, hmlendea-i686.db, hmlendea-x86_64.db│   │
│   └─────────────────────────────────────────────────────────────────────┘   │
│                                    │                                         │
│                                    ▼                                         │
│   ┌─────────────────────────────────────────────────────────────────────┐   │
│   │                    GITHUB RELEASES (distribution)                    │   │
│   └─────────────────────────────────────────────────────────────────────┘   │
│                                    │                                         │
│                                    ▼                                         │
│   ┌─────────────────────────────────────────────────────────────────────┐   │
│   │                      TARGET SYSTEMS (pacman)                         │   │
│   │  ┌──────────────┐ ┌────────────┐ ┌───────────────┐ ┌──────────────┐ │   │
│   │  │grub2-theme-  │ │ hori-fonts │ │ image-optimis │ │plex-video-op │ │   │
│   │  │    nuci      │ │            │ │      er       │ │   timiser    │ │   │
│   │  │ depends: grub│ │ (none)     │ │ depends:      │ │ depends:     │ │   │
│   │  └──────────────┘ └────────────┘ │ jpegoptim,    │ │ mkvtoolnix,  │ │   │
│   │                                  │ oxipng        │ │ ffmpeg,      │ │   │
│   │                                  │ optdepends:   │ │ perl-rename, │ │   │
│   │                                  │ zopfli        │ │ glibc        │ │   │
│   │                                  └───────────────┘ └──────────────┘ │   │
│   └─────────────────────────────────────────────────────────────────────┘   │
│                                                                              │
└─────────────────────────────────────────────────────────────────────────────┘
```

## Dependency Management

### Version Pinning

- **Build tools**: Pinned to Arch Linux rolling release (always current)
- **Runtime dependencies**: No version pinning in PKGBUILDs (uses `depends=('package')` without version)
- **Upstream sources**: Pinned via explicit version in URL and SHA512 checksum

### Update Process

#### Build Tool Updates
Automatic via `pacman -Syu` on build system.

#### Runtime Dependency Updates
Handled by `pacman` on target systems during `pacman -Syu`.

#### Upstream Source Updates
Manual process:
1. Update `pkgver` in PKGBUILD
2. Update `sha512sums` (run `makepkg -g` to generate)
3. Test build with `bash makepkgs.sh`
4. Commit and release

### Dependency Verification

```bash
# Verify all PKGBUILD checksums
for pkg in pkg/*/; do
    cd "$pkg"
    makepkg --verifysource
    cd - >/dev/null
done

# Check for missing dependencies (requires pacman database)
pacman -T $(grep -h '^depends=' pkg/*/PKGBUILD | sed "s/depends=(//;s/)//;s/'//g" | tr ' ' '\n' | sort -u)

# Verify repository database integrity
repo-add --verify repo/hmlendea.db.tar.gz
```

## Supply Chain Security

### Source Verification

All upstream sources verified via SHA512 checksums declared in PKGBUILD:
- `makepkg` automatically verifies before building
- Build fails on checksum mismatch
- No unsigned/unverified sources allowed

### Trust Boundaries

| Boundary | Trust Level | Verification |
|----------|-------------|--------------|
| Upstream sources → Build | Low (external) | SHA512 checksums |
| PKGBUILD → Build | High (committed) | Git history, code review |
| Build artifacts → Repo | High (local) | Built locally, deterministic |
| Repo → GitHub Releases | Medium (transport) | HTTPS, GitHub auth |
| GitHub Releases → Target | Medium (transport) | HTTPS, `SigLevel = PackageOptional` |

### Known Supply Chain Risks

1. **Upstream source compromise** — Mitigated by SHA512 pinning
2. **GitHub Actions compromise** — Not applicable (no workflow in repo)
3. **Build system compromise** — Local builds only, maintainer-controlled
4. **Repository database tampering** — Regenerated from packages each build
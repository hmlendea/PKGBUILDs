# Architecture

This document elaborates on the root [ARCHITECTURE.md](../ARCHITECTURE.md) with implementation-level detail.

## Architectural Style: Build Pipeline

The repository implements a **linear build pipeline** orchestrated by a single shell script (`makepkgs.sh`). This is not a service-oriented or event-driven architecture; it is a deterministic, filesystem-based transformation pipeline.

### Pipeline Stages

```
┌─────────────────────────────────────────────────────────────────────┐
│                        BUILD PIPELINE                                │
├─────────────────────────────────────────────────────────────────────┤
│                                                                      │
│  ┌──────────────┐    ┌──────────────┐    ┌──────────────────────┐  │
│  │  DISCOVERY   │───▶│   BUILD      │───▶│  ARTIFACT MANAGEMENT │  │
│  │  (pkg/*)     │    │  (makepkg)   │    │  (copy, clean, prune)│  │
│  └──────────────┘    └──────────────┘    └──────────────────────┘  │
│                                                                      │
│  ┌──────────────────────────────────────────────────────────────┐   │
│  │              REPOSITORY GENERATION (repo-add)                 │   │
│  │  Per architecture: any, aarch64, i686, x86_64                │   │
│  └──────────────────────────────────────────────────────────────┘   │
│                                                                      │
└─────────────────────────────────────────────────────────────────────┘
```

### Key Architectural Properties

| Property | Description |
|----------|-------------|
| **Single entry point** | `makepkgs.sh` owns the entire flow |
| **No runtime services** | All execution is script-driven, no daemons |
| **Filesystem state** | All intermediate and final state is on disk |
| **Package isolation** | No cross-package dependencies; each PKGBUILD is independent |
| **Deterministic builds** | `makepkg -Csrf --noconfirm` ensures clean, reproducible builds |
| **Explicit architecture handling** | Per-architecture builds and databases |

## Component Boundaries

### 1. Build Script (`makepkgs.sh`)

**Owns:**
- Package discovery (`pkg/*/PKGBUILD` existence)
- Metadata extraction (`pkgname`, `pkgver`, `pkgrel`, `arch`)
- Build orchestration (loop over packages, loop over architectures)
- Artifact lifecycle (copy to `repo/`, remove old versions, remove unsupported arches)
- Repository database generation (per-architecture `repo-add`)

**Does not own:**
- Package build logic (delegated to `makepkg` and PKGBUILD)
- Upstream source fetching (delegated to `makepkg`)
- Package installation on target systems (delegated to `pacman`)

### 2. Package Definitions (`pkg/<name>/PKGBUILD`)

Each package owns its complete build definition:
- Metadata: `pkgname`, `pkgver`, `pkgrel`, `pkgdesc`, `arch`, `url`, `license`
- Dependencies: `depends`, `optdepends`, `makedepends`, `checkdepends`
- Sources: `source` array with URLs, `sha512sums` for verification
- Build logic: `build()`, `package()`, `prepare()` functions

**Boundary:** PKGBUILD is the contract between package definition and Arch Linux toolchain. The build script only reads metadata; it does not interpret build logic.

### 3. Repository Output (`repo/`)

**Owns:**
- Built package artifacts (`.pkg.tar.zst`)
- Repository databases (`.db`, `.files`) per architecture

**Characteristics:**
- Immutable once published
- Consumed by GitHub Releases for distribution
- Consumed by `pacman` on target systems

## Dependency Direction

```
makepkgs.sh
    │
    ▼ (reads metadata)
PKGBUILD files
    │
    ▼ (invokes)
makepkg (Arch Linux toolchain)
    │
    ▼ (fetches, verifies, builds)
Upstream sources
    │
    ▼ (produces)
.pkg.tar.zst artifacts
    │
    ▼ (copies)
repo/ directory
    │
    ▼ (generates databases)
repo-add
    │
    ▼ (publishes)
GitHub Releases
    │
    ▼ (consumes)
pacman (target systems)
```

**Rules:**
- Build script depends on PKGBUILD metadata only
- PKGBUILDs have no dependencies on each other
- All external dependencies flow inward (upstream sources, Arch toolchain)
- Distribution flows outward (GitHub Releases → pacman)

## Data Architecture

### Primary Data Flows

1. **Metadata Flow**: PKGBUILD → `makepkgs.sh` (pkgname, pkgver, pkgrel, arch)
2. **Source Flow**: Upstream URLs → `makepkg` → `src/` → build
3. **Artifact Flow**: `makepkg` output → `repo/` → `repo-add` → databases
4. **Distribution Flow**: `repo/` → GitHub Releases → `pacman`

### Persistent Stores

| Store | Location | Contents | Mutability |
|-------|----------|----------|------------|
| Package definitions | `pkg/*/PKGBUILD` | Build recipes | Committed, versioned |
| Source assets | `pkg/*/src/` | Theme files, fonts, scripts | Committed or downloaded |
| Build staging | `pkg/*/pkg/` | `makepkg` working area | Ephemeral, per-build |
| Artifact store | `repo/` | `.pkg.tar.zst`, `.db`, `.files` | Append-only, pruned by script |
| Distribution | GitHub Releases | Published artifacts | Immutable once released |

## Interfaces and Integrations

### Internal Interfaces

| Interface | Producer | Consumer | Contract |
|-----------|----------|----------|----------|
| PKGBUILD metadata | Package dirs | `makepkgs.sh` | Bash variable extraction via grep/awk |
| Built packages | `makepkg` | `makepkgs.sh` | `{pkgname}-{pkgver}-{pkgrel}-{arch}.pkg.tar.zst` |
| Repository DB | `repo-add` | `pacman` | Standard Arch Linux `.db.tar.gz` format |

### External Integrations

| Integration | Purpose | Interface |
|-------------|---------|-----------|
| Arch Linux toolchain | Build and repo management | `makepkg`, `repo-add`, `pacman` CLI |
| GitHub Actions | CI/CD execution | Workflow YAML (not in repo, implied) |
| GitHub Releases | Artifact hosting | HTTPS download, release API |
| Upstream sources | Package sources | HTTPS (GitHub Releases, dafont.com, fontles.com, 1001fonts.com, raw.githubusercontent.com) |

## Runtime Flow Detail

### Package Build Loop (per package, per architecture)

```
for PKGDIR in pkg/*:
    if PKGBUILD exists:
        parse pkgname, pkgver, pkgrel, arch[]
        for PKGARCH in arch[]:
            if artifact not in repo/:
                cd PKGDIR
                CARCH=PKGARCH makepkg -Csrf --noconfirm
                copy artifact to repo/
        remove old versions from repo/
        remove unsupported arches from repo/
```

### Repository Generation Loop (per architecture)

```
for ARCH in [any, aarch64, i686, x86_64]:
    count packages for ARCH in repo/
    if count > 0:
        remove existing .db, .files
        for each package file for ARCH:
            repo-add database.tar.gz package.pkg.tar.zst
        copy database.tar.gz to database.db
        clean .old files
```

## Compatibility Contracts

### PKGBUILD Format
- Must conform to Arch Linux PKGBUILD specification
- Required fields: `pkgname`, `pkgver`, `pkgrel`, `arch`, `source`, `sha512sums`
- `package()` function must install to `$pkgdir`

### Repository Database Format
- Standard Arch Linux `repo-add` output (`.db.tar.gz`)
- Compatible with `pacman` repository sync

### Package Naming
- `{pkgname}-{pkgver}-{pkgrel}-{arch}.pkg.tar.zst`
- `arch` from PKGBUILD `arch` array

## Design Constraints

1. **Single maintainer** — No multi-user coordination needed
2. **Arch Linux target** — Tied to `makepkg`/`repo-add`/`pacman` ecosystem
3. **GitHub Releases distribution** — Artifacts must fit release asset limits
4. **No cross-package deps** — Simplifies build graph to flat list
5. **Clean builds required** — `-C` flag ensures no build contamination
6. **Checksum verification** — All sources must have `sha512sums`
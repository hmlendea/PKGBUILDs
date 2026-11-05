# Invariants

## Build Pipeline Invariants

### Package Build
1. **Artifact naming**: `<pkgname>-<pkgver>-<pkgrel>-<arch>.pkg.tar.zst`
2. **Architecture suffix determines target database**: `-any`, `-x86_64`, `-i686`, `-aarch64`
3. **Single package per architecture per version**: Old versions removed after new build
4. **Unsupported architectures cleaned**: Artifacts for arches not in PKGBUILD `arch` array removed
5. **Build directory isolation**: Each package builds in its own `pkg/<name>/` directory

### Repository Generation
1. **Four databases always**: `any`, `aarch64`, `i686`, `x86_64` (if packages exist)
2. **Database naming**: `hmlendea.db` for `any`, `hmlendea-<arch>.db` for others
3. **Full regeneration**: Databases rebuilt from scratch each run
4. **`.db` is copy of `.db.tar.gz`**: Pacman reads `.db`, repo-add writes `.db.tar.gz`
5. **Package registration order**: Deterministic (filesystem iteration order)

### Artifact Management
1. **Central repo directory**: All artifacts in `repo/` regardless of source package
2. **Version retention**: Only latest `pkgver-pkgrel` per package retained
3. **Architecture retention**: Only architectures in current PKGBUILD retained
4. **No orphan artifacts**: Every artifact in `repo/` corresponds to a current PKGBUILD

## Package Definition Invariants

### PKGBUILD Structure
1. **Required fields**: `pkgname`, `pkgver`, `pkgrel`, `pkgdesc`, `arch`, `url`, `license`, `depends`, `makedepends`, `source`, `sha512sums`, `package()`
2. **Array format**: `arch=(...)`, `depends=(...)`, `source=(...)`, `sha512sums=(...)`
3. **Version format**: `pkgver` (upstream), `pkgrel` (packaging revision)
4. **Source integrity**: `sha512sums` must match downloaded sources

### Architecture Rules
1. **`any`**: Architecture-independent (fonts, scripts, themes)
2. **`x86_64`**: 64-bit Intel/AMD
3. **`i686`**: 32-bit Intel/AMD
4. **`aarch64`**: 64-bit ARM
5. **Package arch subset of build archs**: PKGBUILD `arch` must be subset of `makepkgs.sh` supported arches

## Runtime Invariants

### CLI Tools
1. **`image-optimiser`**: In-place modification, recursive directory processing
2. **`plex-video-optimiser`**: Single file, interactive, produces MKV output
3. **No daemon/service components**: All tools are one-shot CLI commands

### Repository Consumption
1. **Pacman compatibility**: Databases follow Arch Linux repository format
2. **Architecture selection**: Pacman automatically selects correct database
3. **Signature level**: `PackageOptional` (unsigned accepted)
4. **Single repository entry**: All architectures served from same base URL

## Filesystem Invariants

### Source Layout
```
pkg/<name>/
├── PKGBUILD          # Package recipe
├── src/              # Source files (tracked in git)
└── pkg/              # Build staging (gitignored, created by makepkg)
```

### Artifact Layout
```
repo/
├── *.pkg.tar.zst     # Package artifacts
├── *.db              # Package databases (pacman format)
├── *.files           # File list databases
├── *.db.tar.gz       # Temporary repo-add output
└── *.files.tar.gz    # Temporary repo-add output
```

### Installation Layout (Target System)
```
/usr/share/grub/themes/Nuci/          # grub2-theme-nuci
/usr/share/fonts/hori-fonts/          # hori-fonts
/usr/bin/image-optimiser              # image-optimiser
/usr/bin/plex-video-optimiser         # plex-video-optimiser
```

## Versioning Invariants

1. **Package version independent**: Each package has own `pkgver`/`pkgrel`
2. **Repository version unified**: Single git tag for entire repo (e.g., `v1.0.0`)
3. **Tag format**: Semantic versioning `v<major>.<minor>.<patch>`
4. **Release assets**: All artifacts from single build uploaded to one GitHub Release

## Security Invariants

1. **No secrets in PKGBUILDs**: No API keys, tokens, passwords
2. **Source verification**: `sha512sums` for all downloaded sources
3. **Unsigned packages**: `SigLevel = PackageOptional` (current state)
4. **No runtime privilege escalation**: Tools run as user, install to system via pacman

## Concurrency Invariants

1. **No parallel builds**: Sequential package, sequential architecture
2. **No shared state between packages**: Each package isolated
3. **Database generation sequential**: One architecture at a time
4. **Safe to interrupt**: Partial state cleaned on next run

## Error Handling Invariants

1. **Build failures non-fatal**: Script continues to next package/architecture
2. **Missing artifacts skipped**: Database generation skips empty architectures
3. **Checksum mismatch**: Build fails, artifact not produced
4. **Partial databases**: `.old` backup exists if `repo-add` fails mid-loop
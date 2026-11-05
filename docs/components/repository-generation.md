# Repository Generation Component

## Overview

The repository generation component creates per-architecture Arch Linux repository databases (`.db` and `.files`) from built package artifacts in `repo/`. This is the final stage of the build pipeline.

## Responsibilities

1. **Per-Architecture Database Creation** — Generate databases for `any`, `aarch64`, `i686`, `x86_64`
2. **Package Registration** — Add all matching `.pkg.tar.zst` files to each database
3. **Database Finalization** — Convert `.db.tar.gz` to `.db` (pacman expects `.db`)
4. **Cleanup** — Remove old database files (`.old`)

## Interface

### Input
- `repo/*.pkg.tar.zst` — Built package artifacts (from build pipeline)
- Architecture mapping: package filename suffix determines target database

### Output
- `repo/hmlendea.db` / `repo/hmlendea.files` — Main database (any architecture)
- `repo/hmlendea-aarch64.db` / `repo/hmlendea-aarch64.files`
- `repo/hmlendea-i686.db` / `repo/hmlendea-i686.files`
- `repo/hmlendea-x86_64.db` / `repo/hmlendea-x86_64.files`

### Side Effects
- Removes existing database files before regeneration
- Creates temporary `.db.tar.gz` during `repo-add`
- Leaves `.old` files temporarily (cleaned up in next run)

## Internal Structure

### Architecture Loop
```bash
REPO_NAME="hmlendea"

for ARCH in "any" "aarch64" "i686" "x86_64"; do
    REPODB_NAME="${REPO_NAME}-${ARCH}"
    [ "${ARCH}" == "any" ] && REPODB_NAME="${REPO_NAME}"

    REPODB_PATH="${REPODIR}/${REPODB_NAME}.db"

    # Count packages for this architecture
    PKG_COUNT=$(find "${REPODIR}" -maxdepth 1 -name "*-${ARCH}.pkg.tar.zst" | wc -l)
    [ "${PKG_COUNT}" -eq 0 ] && continue

    # Clean existing databases
    if [ -f "${REPODB_PATH}" ]; then
        rm "${REPODB_PATH}"
        rm "${REPODB_PATH}.tar.gz"
        rm "${REPODIR}/${REPODB_NAME}.files"
        rm "${REPODIR}/${REPODB_NAME}.files.tar.gz"
    fi

    # Add packages to database
    for PKGFILE in ${REPODIR}/*-${ARCH}.pkg.tar.zst; do
        echo "Registering ${PKGFILE} into ${REPODB_NAME}"
        repo-add "${REPODB_PATH}.tar.gz" "${PKGFILE}"
    done

    # Finalize: .db.tar.gz → .db
    rm "${REPODB_PATH}"
    cp "${REPODB_PATH}.tar.gz" "${REPODB_PATH}"

    # Clean old database files
    if [ -f "${REPODB_PATH}.tar.gz.old" ]; then
        rm "${REPODB_PATH}.tar.gz.old"
        rm "${REPODIR}/${REPODB_NAME}.files.tar.gz.old"
    fi
done
```

### Package-to-Architecture Mapping

| Package Filename Suffix | Target Database |
|------------------------|-----------------|
| `-any.pkg.tar.zst` | `hmlendea.db` |
| `-aarch64.pkg.tar.zst` | `hmlendea-aarch64.db` |
| `-i686.pkg.tar.zst` | `hmlendea-i686.db` |
| `-x86_64.pkg.tar.zst` | `hmlendea-x86_64.db` |

### Database File Pairs

Each architecture produces two databases:
| File | Purpose |
|------|---------|
| `hmlendea-{arch}.db` | Package metadata (name, version, depends, desc) |
| `hmlendea-{arch}.files` | File listings (every file in every package) |

## repo-add Behaviour

### Command
```bash
repo-add "${REPODB_PATH}.tar.gz" "${PKGFILE}"
```

### What repo-add Does
1. Reads package metadata from `.pkg.tar.zst`
2. Appends to database (`.db.tar.gz`)
3. Updates file list database (`.files.tar.gz`)
4. Creates `.old` backup of previous database

### Database Format
- `.db.tar.gz` — Compressed tar archive containing `desc` files per package
- Standard Arch Linux repository format
- Compatible with `pacman -Sy` / `pacman -S`

## Error Handling

| Failure Point | Behaviour |
|---------------|-----------|
| No packages for architecture | Skipped (continue) |
| `repo-add` fails | Partial database, `.old` backup remains |
| `cp` finalize fails | `.db.tar.gz` exists but `.db` missing |
| Permission denied | Script fails (no explicit handling) |

**No transactional guarantees** — if `repo-add` fails mid-loop, database is incomplete.

## Invariants

1. **Databases match artifacts** — Regenerated from current `repo/` contents each run
2. **One database per architecture** — Four databases total (including `any`)
3. **`.db` is copy of `.db.tar.gz`** — Pacman reads `.db`, `repo-add` writes `.db.tar.gz`
4. **No incremental updates** — Full regeneration each build

## Configuration

### Hardcoded
- `REPO_NAME="hmlendea"`
- Architecture list: `any aarch64 i686 x86_64`
- Database naming: `hmlendea-{arch}.db` (except `any` → `hmlendea.db`)

### Derived from Artifacts
- Which architectures have databases (based on package filename suffixes)
- Package count per architecture

## Testing

### Manual Verification
```bash
# Build and generate
bash makepkgs.sh

# Verify databases
repo-add --verify repo/hmlendea.db.tar.gz
repo-add --verify repo/hmlendea-x86_64.db.tar.gz

# Query package info
pacman -Si --dbpath repo/ grub2-theme-nuci
pacman -Si --dbpath repo/ hori-fonts

# List files in package
pacman -Ql --dbpath repo/ image-optimiser
```

### Database Contents Inspection
```bash
# Extract and examine database
mkdir /tmp/db && cd /tmp/db
tar -xzf /path/to/repo/hmlendea.db.tar.gz
# Each package has a desc file with metadata
cat grub2-theme-nuci-1.0.0-1/desc
```

## Modification Impact

| Change | Effect |
|--------|--------|
| Add architecture to loop | New database created if packages exist |
| Change `REPO_NAME` | Database filenames change |
| Change package naming | Breaks architecture detection (suffix-based) |
| Add `repo-add` flags | Affects database generation (e.g., `-n` for no color) |
| Skip cleanup | Old `.old` files accumulate |

## Integration with Distribution

### GitHub Releases
Databases published alongside packages:
- All `.db` and `.files` files uploaded as release assets
- `pacman` downloads databases from release URL

### Target System Consumption
```ini
# /etc/pacman.conf
[hmlendea]
Server = https://github.com/hmlendea/PKGBUILDs/releases/latest/download/
SigLevel = PackageOptional
```

`pacman -Sy` downloads `hmlendea.db` and uses it for package resolution.

## Troubleshooting

### Database Corruption
```bash
# Regenerate from packages
rm repo/*.db repo/*.files repo/*.db.tar.gz repo/*.files.tar.gz
bash makepkgs.sh
```

### Missing Architecture Database
- Check if packages exist for that architecture: `ls repo/*-x86_64.pkg.tar.zst`
- Verify PKGBUILD `arch` array includes the architecture
- Rebuild: `bash makepkgs.sh`

### Pacman Signature Errors
- `SigLevel = PackageOptional` allows unsigned packages
- For signed: run `repo-add --sign` and configure keys
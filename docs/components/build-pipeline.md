# Build Pipeline Component

## Overview

The build pipeline is the central orchestration component implemented in `makepkgs.sh`. It transforms package definitions into built artifacts and repository databases.

## Responsibilities

1. **Package Discovery** — Find all `pkg/*/PKGBUILD` files
2. **Metadata Extraction** — Parse `pkgname`, `pkgver`, `pkgrel`, `arch` from each PKGBUILD
3. **Build Orchestration** — Invoke `makepkg` per package per architecture
4. **Artifact Management** — Copy artifacts to `repo/`, prune old versions and unsupported arches
5. **Repository Generation** — Run `repo-add` per architecture to create `.db`/`.files`

## Interface

### Input
- Directory structure: `pkg/<name>/PKGBUILD`
- PKGBUILD metadata (extracted via grep/awk)
- Upstream sources (fetched by `makepkg`)

### Output
- `repo/*.pkg.tar.zst` — Built packages
- `repo/hmlendea{,-arch}.db` — Repository databases
- `repo/hmlendea{,-arch}.files` — File list databases

### Side Effects
- Creates `repo/` directory
- Downloads sources to `pkg/<name>/src/` (via `makepkg`)
- Creates build staging in `pkg/<name>/pkg/` (via `makepkg`)
- Modifies `repo/` contents (adds/removes packages, regenerates databases)

## Internal Structure

### Main Loop (Package Discovery)
```bash
for PKGDIR in ${DIR}/pkg/*; do
    if [ ! -f "${PKGDIR}/PKGBUILD" ]; then
        continue
    fi
    # ... process package
done
```

### Metadata Extraction
```bash
PKGNAME=$(grep "^pkgname=" "${PKGDIR}/PKGBUILD" | awk -F'=' '{print $2}')
PKGVER=$(grep "^pkgver=" "${PKGDIR}/PKGBUILD" | awk -F'=' '{print $2}')
PKGREL=$(grep "^pkgrel=" "${PKGDIR}/PKGBUILD" | awk -F'=' '{print $2}')
PKGARCHES=$(grep "^arch=" "${PKGDIR}/PKGBUILD" | sed -e 's/^arch=//g' -e 's/[\(\)]//g' -e 's/'\''//g')
```

### Build Loop (Per Architecture)
```bash
for PKGARCH in ${PKGARCHES}; do
    PACKAGE_FILE_NAME="${PKGID}-${PKGARCH}.pkg.tar.zst"
    if [ ! -f "${REPODIR}/${PACKAGE_FILE_NAME}" ]; then
        cd "${PKGDIR}"
        CARCH="${PKGARCH}" makepkg -Csrf --noconfirm
        cp "${PKGDIR}/${PACKAGE_FILE_NAME}" "${REPODIR}/${PACKAGE_FILE_NAME}"
    fi
done
```

### Cleanup (Old Versions)
```bash
for REPO_PACKAGE in $(find "${REPODIR}" -name "${PKGNAME}-*" | grep -v "/${PKGID}"); do
    rm "${REPO_PACKAGE}"
done
```

### Cleanup (Unsupported Architectures)
```bash
for REPO_PACKAGE in $(find "${REPODIR}" -name "${PKGID}-*" | grep -v "\(${PKGARCHES// /\\|}\).pkg.tar.zst"); do
    rm "${REPO_PACKAGE}"
done
```

### Repository Generation (Per Architecture)
```bash
for ARCH in "any" "aarch64" "i686" "x86_64"; do
    # ... count packages, clean old DB, repo-add, finalize
done
```

## Error Handling

| Failure Point | Behaviour |
|---------------|-----------|
| PKGBUILD missing | Skipped (continue) |
| `makepkg` fails | Script continues (error printed to stderr) |
| `repo-add` fails | Database incomplete, old `.old` files may remain |
| `cp` artifact fails | Artifact missing from `repo/` |

**No explicit error handling** — relies on `set -e` not being set, so script continues on errors.

## Configuration

### Hardcoded
- `REPODIR="${DIR}/repo"`
- `REPO_NAME="hmlendea"`
- Target architectures: `any aarch64 i686 x86_64`
- `makepkg` flags: `-Csrf --noconfirm`

### Per-Package (from PKGBUILD)
- `pkgname`, `pkgver`, `pkgrel`, `arch[]`

## Invariants

1. **Single artifact per package-version-architecture** in `repo/`
2. **Only declared architectures** have artifacts in `repo/`
3. **Databases match artifacts** — regenerated from current `repo/` contents
4. **Clean builds** — `makepkg -C` ensures no build directory contamination

## Testing

No automated tests. Manual verification:
```bash
bash makepkgs.sh
# Check repo/ contents
ls -la repo/
# Verify databases
repo-add --verify repo/hmlendea.db.tar.gz
```

## Modification Impact

| Change | Affected Areas |
|--------|----------------|
| Add new package | Create `pkg/<name>/PKGBUILD`, next build includes it |
| Change architectures | Update PKGBUILD `arch`, next build adjusts artifacts |
| Change `makepkg` flags | Edit `makepkgs.sh`, affects all packages |
| Add architecture | Edit `makepkgs.sh` ARCH loop, add to PKGBUILD `arch` |
| Change repo name | Edit `REPO_NAME`, affects database filenames |
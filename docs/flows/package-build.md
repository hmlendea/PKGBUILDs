# Package Build Flow

## Overview

End-to-end flow for building a single package across its supported architectures.

## Trigger

- Manual: `bash makepkgs.sh`
- Automated: GitHub Actions workflow (implied)

## Flow Diagram

```mermaid
flowchart TD
    Start([Start makepkgs.sh]) --> ResolveDir[Resolve script directory]
    ResolveDir --> EnsureRepo[Ensure repo/ exists]
    EnsureRepo --> LoopPackages[For each pkg/*]
    LoopPackages --> HasPKGBUILD{PKGBUILD exists?}
    HasPKGBUILD -->|No| LoopPackages
    HasPKGBUILD -->|Yes| ParseMeta[Parse pkgname, pkgver, pkgrel, arch]
    ParseMeta --> BuildLoop[For each arch in arch[]]
    BuildLoop --> ArtifactExists{Artifact in repo/?}
    ArtifactExists -->|Yes| BuildLoop
    ArtifactExists -->|No| RunMakepkg[cd PKGDIR; CARCH=arch makepkg -Csrf --noconfirm]
    RunMakepkg --> MakepkgSuccess{makepkg succeeded?}
    MakepkgSuccess -->|No| LogError[Error printed, continue]
    MakepkgSuccess -->|Yes| CopyArtifact[cp artifact to repo/]
    CopyArtifact --> BuildLoop
    BuildLoop --> CleanOldVersions[Remove old pkgver-pkgrel from repo/]
    CleanOldVersions --> CleanUnsupportedArches[Remove unsupported arches from repo/]
    CleanUnsupportedArches --> LoopPackages
    LoopPackages --> RepoGen[Repository Generation Flow]
    RepoGen --> OutputTag[Print recommended release tag]
    OutputTag --> End([End])
```

## Detailed Steps

### 1. Environment Setup
```bash
# Resolve absolute path of script (handles symlinks)
SOURCE="${BASH_SOURCE[0]}"
while [ -h "$SOURCE" ]; do
  DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
  SOURCE="$(readlink "$SOURCE")"
  [[ $SOURCE != /* ]] && SOURCE="$DIR/$SOURCE"
done
DIR="$( cd -P "$( dirname "$SOURCE" )" && pwd )"
cd "$DIR"

REPODIR="${DIR}/repo"
[ ! -d "${REPODIR}" ] && mkdir "${REPODIR}"
```

### 2. Package Discovery
Iterates `pkg/*` directories, skips non-directories and directories without `PKGBUILD`.

### 3. Metadata Extraction (Per Package)
```bash
PKGNAME=$(grep "^pkgname=" "${PKGDIR}/PKGBUILD" | awk -F'=' '{print $2}')
PKGVER=$(grep "^pkgver=" "${PKGDIR}/PKGBUILD" | awk -F'=' '{print $2}')
PKGREL=$(grep "^pkgrel=" "${PKGDIR}/PKGBUILD" | awk -F'=' '{print $2}')
PKGARCHES=$(grep "^arch=" "${PKGDIR}/PKGBUILD" | sed -e 's/^arch=//g' -e 's/[\(\)]//g' -e 's/'\''//g')
PKGID="${PKGNAME}-${PKGVER}-${PKGREL}"
```

**Parsing Method:** Line-based grep/awk — fragile to PKGBUILD formatting changes.

### 4. Build Loop (Per Architecture)
```bash
for PKGARCH in ${PKGARCHES}; do
    PACKAGE_FILE_NAME="${PKGID}-${PKGARCH}.pkg.tar.zst"
    if [ ! -f "${REPODIR}/${PACKAGE_FILE_NAME}" ]; then
        cd "${PKGDIR}"
        CARCH="${PKGARCH}" makepkg -Csrf --noconfirm
        [ -f "${REPODIR}/${PACKAGE_FILE_NAME}" ] && rm "${REPODIR}/${PACKAGE_FILE_NAME}"
        cp "${PKGDIR}/${PACKAGE_FILE_NAME}" "${REPODIR}/${PACKAGE_FILE_NAME}"
    fi
done
```

**Key Points:**
- Skips build if artifact already exists in `repo/`
- Sets `CARCH` environment variable for cross-compilation
- `makepkg` flags: `-C` (clean), `-s` (sync deps), `-r` (remove build deps), `-f` (force), `--noconfirm`
- Copies artifact from package build dir to central `repo/`

### 5. Artifact Cleanup (Per Package)

#### Remove Old Versions
```bash
for REPO_PACKAGE in $(find "${REPODIR}" -name "${PKGNAME}-*" | grep -v "/${PKGID}"); do
    rm "${REPO_PACKAGE}"
done
```
Keeps only current `pkgver-pkgrel` for this package.

#### Remove Unsupported Architectures
```bash
for REPO_PACKAGE in $(find "${REPODIR}" -name "${PKGID}-*" | grep -v "\(${PKGARCHES// /\\|}\).pkg.tar.zst"); do
    rm "${REPO_PACKAGE}"
done
```
Removes artifacts for architectures no longer in PKGBUILD `arch` array.

### 6. Repository Generation
After all packages processed, triggers [Repository Generation Flow](./repository-generation.md).

## Error Scenarios

| Scenario | Behaviour | Recovery |
|----------|-----------|----------|
| `makepkg` fails (checksum mismatch) | Error printed, script continues | Fix `sha512sums` in PKGBUILD |
| `makepkg` fails (missing dependency) | Error printed, script continues | Install dependency or add to `makedepends` |
| `makepkg` fails (build error) | Error printed, script continues | Fix `package()` function or source |
| `cp` artifact fails | Artifact missing from `repo/` | Check permissions, disk space |
| `find`/`grep` parsing fails | Wrong metadata extracted | Fix PKGBUILD formatting |

## Idempotency

- **Re-running safe**: Script skips packages already built (artifact exists in `repo/`)
- **Clean rebuild**: Remove `repo/*.pkg.tar.zst` and re-run
- **Partial rebuild**: Remove specific artifact and re-run

## Inputs and Outputs

### Inputs
- `pkg/<name>/PKGBUILD` — Package recipe
- `pkg/<name>/src/` — Source files
- Upstream sources (downloaded by `makepkg`)

### Outputs
- `repo/<name>-<ver>-<rel>-<arch>.pkg.tar.zst` — Built package
- Updated `repo/` database (via subsequent repo generation)

## Side Effects

- Downloads sources to `pkg/<name>/src/` (via `makepkg`)
- Creates build staging in `pkg/<name>/pkg/` (via `makepkg`)
- Modifies `repo/` directory

## Performance

- **Parallelisation**: None (sequential package, sequential architecture)
- **Typical duration**: 30 seconds - 5 minutes per package depending on compilation
- **Bottleneck**: `makepkg` (download, verify, build, package)

## Modification Points

| Change | Location |
|--------|----------|
| Add build flags | `makepkgs.sh` makepkg command line |
| Change artifact naming | `makepkgs.sh` PACKAGE_FILE_NAME construction |
| Add pre/post build hooks | `makepkgs.sh` around makepkg call |
| Change cleanup policy | `makepkgs.sh` cleanup loops |
| Support new architecture | `makepkgs.sh` ARCH list + PKGBUILD arch arrays |
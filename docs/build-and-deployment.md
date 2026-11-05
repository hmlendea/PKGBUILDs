# Build and Deployment

## Build Pipeline

### Overview

The build pipeline is a single script (`makepkgs.sh`) that transforms package definitions into built packages and repository databases. It runs on Arch Linux with `base-devel` installed.

### Prerequisites

- Arch Linux (or Arch-based distribution)
- `base-devel` package group (provides `makepkg`, `repo-add`, `fakeroot`, etc.)
- Network access to upstream sources
- Write access to repository directory

### Build Command

```bash
bash makepkgs.sh
```

### Build Process Detail

#### Stage 1: Environment Setup
```bash
# Resolve script directory (handles symlinks)
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

#### Stage 2: Package Discovery and Build Loop
```bash
for PKGDIR in ${DIR}/pkg/*; do
    if [ ! -f "${PKGDIR}/PKGBUILD" ]; then
        continue
    fi

    # Extract metadata from PKGBUILD
    PKGNAME=$(grep "^pkgname=" "${PKGDIR}/PKGBUILD" | awk -F'=' '{print $2}')
    PKGVER=$(grep "^pkgver=" "${PKGDIR}/PKGBUILD" | awk -F'=' '{print $2}')
    PKGREL=$(grep "^pkgrel=" "${PKGDIR}/PKGBUILD" | awk -F'=' '{print $2}')
    PKGARCHES=$(grep "^arch=" "${PKGDIR}/PKGBUILD" | sed -e 's/^arch=//g' -e 's/[\(\)]//g' -e 's/'\''//g')

    PKGID="${PKGNAME}-${PKGVER}-${PKGREL}"

    # Build per architecture
    for PKGARCH in ${PKGARCHES}; do
        PACKAGE_FILE_NAME="${PKGID}-${PKGARCH}.pkg.tar.zst"

        if [ ! -f "${REPODIR}/${PACKAGE_FILE_NAME}" ]; then
            echo "Making ${PKGID} for ${PKGARCH}..."
            cd "${PKGDIR}"
            CARCH="${PKGARCH}" makepkg -Csrf --noconfirm

            [ -f "${REPODIR}/${PACKAGE_FILE_NAME}" ] && rm "${REPODIR}/${PACKAGE_FILE_NAME}"
            cp "${PKGDIR}/${PACKAGE_FILE_NAME}" "${REPODIR}/${PACKAGE_FILE_NAME}"
        fi
    done

    # Cleanup: remove old versions
    for REPO_PACKAGE in $(find "${REPODIR}" -name "${PKGNAME}-*" | grep -v "/${PKGID}"); do
        rm "${REPO_PACKAGE}"
    done

    # Cleanup: remove unsupported architectures
    for REPO_PACKAGE in $(find "${REPODIR}" -name "${PKGID}-*" | grep -v "\(${PKGARCHES// /\\|}\).pkg.tar.zst"); do
        rm "${REPO_PACKAGE}"
    done
done
```

#### Stage 3: Repository Database Generation
```bash
REPO_NAME="hmlendea"

for ARCH in "any" "aarch64" "i686" "x86_64"; do
    REPODB_NAME="${REPO_NAME}-${ARCH}"
    [ "${ARCH}" == "any" ] && REPODB_NAME="${REPO_NAME}"

    REPODB_PATH="${REPODIR}/${REPODB_NAME}.db"

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
        repo-add "${REPODB_PATH}.tar.gz" "${PKGFILE}"
    done

    # Finalize database
    rm "${REPODB_PATH}"
    cp "${REPODB_PATH}.tar.gz" "${REPODB_PATH}"

    # Clean old database files
    if [ -f "${REPODB_PATH}.tar.gz.old" ]; then
        rm "${REPODB_PATH}.tar.gz.old"
        rm "${REPODIR}/${REPODB_NAME}.files.tar.gz.old"
    fi
done
```

### Build Output

The script outputs a recommended release tag:
```
Recommended release tag: 2026-11-05_14-30-00
```

## Deployment

### Distribution Mechanism

Packages are distributed via **GitHub Releases**. The `repo/` directory contents are published as release assets.

### Release Process

1. Run `bash makepkgs.sh` locally or via CI
2. Create a GitHub Release with the recommended tag format: `YYYY-MM-DD_HH-MM-SS`
3. Upload all files from `repo/` as release assets:
   - `*.pkg.tar.zst` (package files)
   - `*.db` (repository databases)
   - `*.files` (repository file lists)

### Target System Configuration

End users add the repository to `/etc/pacman.conf`:

```ini
# Main repository (any architecture)
[hmlendea]
Server = https://github.com/hmlendea/PKGBUILDs/releases/latest/download/
SigLevel = PackageOptional

# Optional architecture-specific repositories
[hmlendea-aarch64]
Server = https://github.com/hmlendea/PKGBUILDs/releases/latest/download/
SigLevel = PackageOptional

[hmlendea-i686]
Server = https://github.com/hmlendea/PKGBUILDs/releases/latest/download/
SigLevel = PackageOptional

[hmlendea-x86_64]
Server = https://github.com/hmlendea/PKGBUILDs/releases/latest/download/
SigLevel = PackageOptional
```

Then install packages:
```bash
pacman -Syu
pacman -S grub2-theme-nuci hori-fonts image-optimiser plex-video-optimiser
```

### GitHub Actions (Implied)

While not present in the repository, the distribution via GitHub Releases suggests a GitHub Actions workflow that:
1. Runs on schedule or push to main
2. Executes `bash makepkgs.sh`
3. Creates a release with the timestamp tag
4. Uploads `repo/` contents as assets

## Environments

| Environment | Purpose | Characteristics |
|-------------|---------|-----------------|
| Local development | Maintainer builds | Full control, manual release creation |
| GitHub Actions (CI) | Automated builds | Clean runner, automated release |
| Target systems | Package consumption | `pacman` with repository config |

## Build Verification

### Local Verification
```bash
# Build all packages
bash makepkgs.sh

# Verify packages can be installed (in clean chroot or VM)
# Check package contents
tar -tf repo/grub2-theme-nuci-1.0.0-1-x86_64.pkg.tar.zst

# Verify repository databases
repo-add --verify repo/hmlendea.db.tar.gz
```

### Package Quality Checks
- All sources have `sha512sums` verification
- Clean builds with `-C` flag (clean build directory)
- No build artifacts committed to source control
- Reproducible builds (same inputs → same outputs)

## Rollback and Recovery

### Failed Build Recovery
1. Check `makepkg` output for errors
2. Fix PKGBUILD or source issues
3. Re-run `bash makepkgs.sh` (script skips already-built packages)
4. Or manually remove problematic artifacts from `repo/` and rebuild

### Bad Release Recovery
1. Delete the GitHub Release
2. Fix the issue
3. Rebuild and create new release with new timestamp tag

### Repository Database Corruption
1. Delete `repo/*.db`, `repo/*.files`
2. Re-run `bash makepkgs.sh` (regenerates databases from packages)
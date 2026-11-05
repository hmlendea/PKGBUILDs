# Inspect, Edit, Delete Behaviour

## Overview

This repository is a build-time package repository. "Inspect, edit, delete" refers to operations on package definitions (PKGBUILDs) and built artifacts.

## Inspect Operations

### Package Definition (PKGBUILD)
```bash
# View full PKGBUILD
cat pkg/<name>/PKGBUILD

# View specific fields
grep "^pkgname=" pkg/<name>/PKGBUILD
grep "^depends=" pkg/<name>/PKGBUILD
grep "^source=" pkg/<name>/PKGBUILD

# View package() function
sed -n '/^package()/,/^}/p' pkg/<name>/PKGBUILD
```

### Source Files
```bash
# List source directory
ls -la pkg/<name>/src/

# View source files
cat pkg/<name>/src/<file>
```

### Built Artifact
```bash
# Package metadata
pacman -Qi --dbpath repo/ <package>

# Package files
pacman -Ql --dbpath repo/ <package>

# Extract and inspect
mkdir /tmp/inspect && cd /tmp/inspect
tar -xzf repo/<package>.pkg.tar.zst
cat .PKGINFO
cat .MTREE
```

### Repository Database
```bash
# All packages
pacman -Sl --dbpath repo/

# Database info
repo-add --verify repo/hmlendea.db.tar.gz
```

## Edit Operations

### Modify PKGBUILD
```bash
# Edit package version
sed -i 's/^pkgver=.*/pkgver=1.0.1/' pkg/<name>/PKGBUILD

# Edit release
sed -i 's/^pkgrel=.*/pkgrel=1/' pkg/<name>/PKGBUILD

# Add dependency
sed -i '/^depends=/s/)$/ new-dep)/' pkg/<name>/PKGBUILD

# Update checksums (after source change)
cd pkg/<name>
updpkgsums
```

### Add New Package
```bash
# Create directory structure
mkdir -p pkg/new-package/src

# Create PKGBUILD from template
cat > pkg/new-package/PKGBUILD << 'EOF'
pkgname=new-package
pkgver=1.0.0
pkgrel=1
pkgdesc="Description"
arch=(any)
url="https://example.com"
license=(MIT)
depends=()
makedepends=()
source=()
sha512sums=()

package() {
    # Installation commands
}
EOF

# Add source files to src/
# Test build
bash makepkgs.sh
```

### Modify Source Files
```bash
# Edit source file
vim pkg/<name>/src/<file>

# Regenerate checksums
cd pkg/<name>
updpkgsums

# Rebuild
bash makepkgs.sh
```

### Update Repository Databases Only
```bash
# If only databases need regeneration (artifacts exist)
# Run repository generation section of makepkgs.sh manually
# Or delete databases and re-run
rm repo/*.db repo/*.files repo/*.db.tar.gz repo/*.files.tar.gz
bash makepkgs.sh
```

## Delete Operations

### Remove Package Definition
```bash
# Delete package directory
rm -rf pkg/<name>/

# Clean artifacts from repo/
rm repo/<name>-*.pkg.tar.zst

# Regenerate databases
bash makepkgs.sh
```

### Remove Specific Artifact
```bash
# Delete one architecture build
rm repo/<name>-1.0.0-1-x86_64.pkg.tar.zst

# Rebuild that architecture
# (makepkgs.sh will rebuild missing artifacts)
bash makepkgs.sh
```

### Remove All Artifacts (Clean Rebuild)
```bash
# Remove all built packages
rm repo/*.pkg.tar.zst

# Remove all databases
rm repo/*.db repo/*.files repo/*.db.tar.gz repo/*.files.tar.gz

# Full rebuild
bash makepkgs.sh
```

### Remove Architecture Support
```bash
# Edit PKGBUILD arch array
# Before: arch=(x86_64 i686)
# After:  arch=(x86_64)
sed -i 's/arch=(x86_64 i686)/arch=(x86_64)/' pkg/<name>/PKGBUILD

# Clean old architecture artifacts
rm repo/<name>-*-i686.pkg.tar.zst

# Regenerate databases
bash makepkgs.sh
```

## Validation After Changes

### Syntax Check
```bash
# Validate PKGBUILD syntax
bash -n pkg/<name>/PKGBUILD

# Check with namcap (if installed)
namcap pkg/<name>/PKGBUILD
```

### Build Test
```bash
# Test build single package
cd pkg/<name>
makepkg -Csrf --noconfirm

# Or full pipeline test
bash makepkgs.sh
```

### Database Verification
```bash
# Verify all databases
repo-add --verify repo/hmlendea.db.tar.gz
repo-add --verify repo/hmlendea-x86_64.db.tar.gz
repo-add --verify repo/hmlendea-i686.db.tar.gz

# Query packages
pacman -Si --dbpath repo/ <package>
```

## Common Edit Patterns

### Version Bump
```bash
# 1. Update pkgver
sed -i 's/^pkgver=.*/pkgver=2.0.0/' pkg/<name>/PKGBUILD

# 2. Reset pkgrel
sed -i 's/^pkgrel=.*/pkgrel=1/' pkg/<name>/PKGBUILD

# 3. Update source URLs if versioned
sed -i 's/v1.0.0/v2.0.0/g' pkg/<name>/PKGBUILD

# 4. Regenerate checksums
cd pkg/<name> && updpkgsums

# 5. Build and test
bash makepkgs.sh
```

### Add Dependency
```bash
# Add to depends array
sed -i '/^depends=(/s/)/ new-dependency)/' pkg/<name>/PKGBUILD

# Rebuild
bash makepkgs.sh
```

### Change Architecture
```bash
# Add architecture
sed -i 's/arch=(any)/arch=(any x86_64)/' pkg/<name>/PKGBUILD

# Rebuild (will build for new arch)
bash makepkgs.sh
```

### Fix Checksum Mismatch
```bash
# Regenerate all checksums
cd pkg/<name>
updpkgsums

# Or manually update specific checksum
# sha512sum pkg/<name>/src/<file>
# Then edit PKGBUILD
```

## Safety Considerations

| Operation | Risk | Mitigation |
|-----------|------|------------|
| Delete package | Loss of definition | Git history preserves it |
| Edit PKGBUILD | Broken build | Test with `makepkg` before commit |
| Remove artifact | Missing package | Rebuild from source |
| Change arch | Incompatible binaries | Verify source is architecture-independent |
| Update version | Checksum mismatch | Run `updpkgsums` |

## Git Workflow for Edits

```bash
# 1. Create branch
git checkout -b update/<package>-<change>

# 2. Make changes
# Edit PKGBUILD, source files, etc.

# 3. Test build
bash makepkgs.sh

# 4. Verify
pacman -Si --dbpath repo/ <package>

# 5. Commit
git add pkg/<name>/
git commit -m "pkg/<name>: <description of change>"

# 6. Push and PR
git push origin update/<package>-<change>
```

## Automation

### updpkgsums
Automatically updates `sha512sums` array in PKGBUILD:
```bash
cd pkg/<name>
updpkgsums
```

### namcap
Static analysis of PKGBUILD:
```bash
namcap pkg/<name>/PKGBUILD
```

### makepkg --check
Validates PKGBUILD without building:
```bash
cd pkg/<name>
makepkg --check
```
# Quick Start

## For Users (Install Packages)

### 1. Add Repository
```bash
sudo tee -a /etc/pacman.conf << 'EOF'

[hmlendea]
Server = https://github.com/hmlendea/PKGBUILDs/releases/latest/download/
SigLevel = PackageOptional
EOF
```

### 2. Sync and Install
```bash
sudo pacman -Sy
sudo pacman -S image-optimiser plex-video-optimiser hori-fonts grub2-theme-nuci
```

### 3. Verify Installation
```bash
image-optimiser --help
plex-video-optimiser --help
fc-list | grep -i hori
ls /usr/share/grub/themes/Nuci/
```

## For Developers (Build from Source)

### 1. Prerequisites
```bash
# Arch Linux with base-devel
sudo pacman -S base-devel git

# Package-specific dependencies
sudo pacman -S jpegoptim oxipng zopfli mkvtoolnix-cli ffmpeg perl-rename
```

### 2. Clone and Build
```bash
git clone https://github.com/hmlendea/PKGBUILDs
cd PKGBUILDs
bash makepkgs.sh
```

### 3. Verify Build Output
```bash
ls repo/*.pkg.tar.zst
ls repo/*.db repo/*.files
```

### 4. Test Local Repository
```bash
# Add local repo to pacman.conf
sudo tee -a /etc/pacman.conf << 'EOF'

[hmlendea-local]
Server = file:///path/to/PKGBUILDs/repo
SigLevel = PackageOptional
EOF

sudo pacman -Sy
pacman -Sl hmlendea-local
```

## For Contributors (Modify Packages)

### 1. Fork and Branch
```bash
git clone https://github.com/<your-fork>/PKGBUILDs
cd PKGBUILDs
git checkout -b update/image-optimiser-1.2.0
```

### 2. Make Changes
```bash
# Edit PKGBUILD
vim pkg/image-optimiser/PKGBUILD

# Update checksums
cd pkg/image-optimiser
updpkgsums
```

### 3. Test Build
```bash
# From repo root
bash makepkgs.sh

# Verify
pacman -Si --dbpath repo/ image-optimiser
```

### 4. Submit PR
```bash
git add pkg/image-optimiser/
git commit -m "pkg/image-optimiser: update to 1.2.0"
git push origin update/image-optimiser-1.2.0
# Open PR on GitHub
```

## Common Commands Reference

| Task | Command |
|------|---------|
| Build all packages | `bash makepkgs.sh` |
| Build single package | `cd pkg/<name> && makepkg -Csrf --noconfirm` |
| Update checksums | `cd pkg/<name> && updpkgsums` |
| Verify database | `repo-add --verify repo/hmlendea.db.tar.gz` |
| Query package info | `pacman -Si --dbpath repo/ <package>` |
| List package files | `pacman -Ql --dbpath repo/ <package>` |
| Clean all artifacts | `rm repo/*.pkg.tar.zst repo/*.db repo/*.files repo/*.db.tar.gz repo/*.files.tar.gz` |
| Create release tag | `git tag -a v1.0.0 -m "Release v1.0.0" && git push origin v1.0.0` |

## Directory Structure
```
PKGBUILDs/
├── makepkgs.sh              # Main build script
├── pkg/                     # Package definitions
│   ├── grub2-theme-nuci/
│   ├── hori-fonts/
│   ├── image-optimiser/
│   └── plex-video-optimiser/
├── repo/                    # Built artifacts (gitignored)
│   ├── *.pkg.tar.zst
│   ├── *.db
│   └── *.files
└── docs/                    # This documentation
```

## Next Steps

- Read [Architecture Overview](../architecture.md) for system design
- Read [Build Pipeline](../components/build-pipeline.md) for build details
- Read [Package Definitions](../components/package-definitions.md) for package specifics
- Read [API Reference](../api-reference/INDEX.md) for CLI usage
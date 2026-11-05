# Package Definitions Component

## Overview

Each package in `pkg/<name>/` is a self-contained Arch Linux package definition following the PKGBUILD specification. Four packages are currently maintained.

## Common Structure

```
pkg/<name>/
├── PKGBUILD              # Required: package recipe (Arch Linux standard)
├── src/                  # Required: source files
│   └── <assets>          # Theme files, fonts, scripts, downloaded archives
└── pkg/                  # Generated: makepkg staging area (not committed)
    └── <name>/
        └── usr/          # Installed file hierarchy
```

## PKGBUILD Schema

### Required Fields (All Packages)

| Field | Type | Description |
|-------|------|-------------|
| `pkgname` | string | Unique package identifier |
| `pkgver` | string | Upstream version |
| `pkgrel` | integer | Package release (rebuild counter) |
| `pkgdesc` | string | One-line description |
| `arch` | array | Supported architectures |
| `source` | array | Source URLs (one per file) |
| `sha512sums` | array | SHA512 checksums (one per source) |

### Optional Fields (Used by Some Packages)

| Field | Type | Used By |
|-------|------|---------|
| `url` | string | grub2-theme-nuci, image-optimiser, plex-video-optimiser |
| `license` | array | All packages |
| `depends` | array | grub2-theme-nuci, image-optimiser, plex-video-optimiser |
| `optdepends` | array | image-optimiser |
| `install` | string | (none currently) |
| `options` | array | (none currently) |

### Build Functions

| Function | Used By | Purpose |
|----------|---------|---------|
| `package()` | All packages | Install files to `$pkgdir` |
| `build()` | (none) | Compilation (not needed for these packages) |
| `prepare()` | (none) | Pre-build preparation |
| `check()` | (none) | Run tests |

## Package-Specific Details

### grub2-theme-nuci

**PKGBUILD Location:** `pkg/grub2-theme-nuci/PKGBUILD`

**Metadata:**
```bash
pkgname=grub2-theme-nuci
pkgver=1.0.0
pkgrel=1
pkgdesc="Personal GRUB2 theme based on Vimix"
arch=('x86_64' 'i686')
url="https://github.com/hmlendea/${pkgname}"
license=('GPL')
depends=('grub')
source=("${url}/releases/download/v${pkgver}/${pkgname}_${pkgver}.zip")
sha512sums=('a6bac73fa3593b82471a9fa396b219abf0408ca881fdbae8b807ab9b9aaa49dca30729b2b1806862ffa664477726c6d6fbf8538da1d95cfcc3abc94754ce3885')
```

**Source:**
- Single ZIP from GitHub Releases: `grub2-theme-nuci_1.0.0.zip`
- Contains `Nuci/theme.txt`, `Nuci/*.png`, `Nuci/icons/*.png`

**Package Function:**
```bash
package() {
    local GRUB2_THEMES_DIR="/usr/share/grub/themes/Nuci"
    install -d -m755 "${pkgdir}/${GRUB2_THEMES_DIR}/icons"
    install -m644 "${srcdir}/Nuci/theme.txt" "${pkgdir}/${GRUB2_THEMES_DIR}/"
    for asset in "${srcdir}/Nuci"/*.png; do
        install -m644 "${asset}" "${pkgdir}/${GRUB2_THEMES_DIR}/"
    done
    for icon in "${srcdir}/Nuci/icons"/*.png; do
        install -m644 "${icon}" "${pkgdir}/${GRUB2_THEMES_DIR}/icons/"
    done
}
```

**Installed Files:**
```
/usr/share/grub/themes/Nuci/theme.txt
/usr/share/grub/themes/Nuci/*.png
/usr/share/grub/themes/Nuci/icons/*.png
```

**Architecture Note:** GRUB themes are architecture-specific because GRUB itself is architecture-specific (different bootloaders for x86_64 vs i686).

---

### hori-fonts

**PKGBUILD Location:** `pkg/hori-fonts/PKGBUILD`

**Metadata:**
```bash
pkgname=hori-fonts
pkgver=1.5.0
pkgrel=2
pkgdesc="Hori's fonts collection"
arch=('any')
url=""
license=('GPL')
install=
source=('https://dl.dafont.com/dl/?f=hesperides'
        'https://dl.dafont.com/dl/?f=optimusprinceps'
        'https://dl.dafont.com/dl/?f=oblivion'
        'https://dl.dafont.com/dl/?f=planewalker'
        'https://dl.dafont.com/dl/?f=promised_freedom'
        'https://dl.dafont.com/dl/?f=soviet_style'
        'https://www.fontles.com/download/segoe-script-font'
        'https://www.1001fonts.com/download/fredericka-the-great.zip'
        'https://raw.githubusercontent.com/ThinkDualBrain/Protomolecule/master/Protomolecule.otf')
sha512sums=('33d9ac7df86e7b69a1b71a7db5e94f6241c685f29b53819774cff76a00be5388df688dea26d29423ad652bd1bfc7b86b211147c2cff9d7e0d6e2ece017a4404d'
            '3c78a99eeb17ace573f2ddee0fa066b1aa5efab81ad80c4f6af0cb97bef4036243e7a6c9e7f0d0fdba6acf4ad6e07c1878f6fc167256ee6d3e7ee2ad03f2dbbb'
            '42627d505484b850d5e5170d6df80a5ebcccea6653cf7260f11a0ea7aa5fcec4a4a1d35f0bf28ec286dbf59a21efb36c36e1d3b7f9c210362c29ca6885eb6227'
            '2303133d3b5cab2b5a0749555206f30ae91a3fb5aaa7255d8799085ea371698770e6ed13c56ce89a1059640b44762b6f9ebd72513b41cb1ca95dd5533c7ead8c'
            'f29f20fb965af90c0164b3a811da383e4310265788a1262761912fd94ffbdd5de3f51c5f4f7f560e791f27f59b010fc142e26d790608154b6c782548d376dde1'
            '49eddf30f4152316f4bab2830ff56b3df43f3d33ee6995ce164e298349c5085266b432909ada7e571de1fbee4b32fe62e2313e7d3d58f8a8709658809a68ea12'
            '88b7dcdfe32f9a5c57b3088f512ecc881ce478aa2d4ae6db1484b65fd6c84e597f15b10d0b7b42b64c0a523cefb9a0023641e08ee94ec08db1b5c260909e1c4a'
            '445a13824c7793dcd0db8f80ee2ac46a8c69747ceee42bfede9dc6b498a4b6248747f25002085391991a9eae54bde90563410729dca753b7734fa01b75fc39bd'
            '94707be84b6b39e84e326d5af5969f28c8b19412afff12b833464dfeebe6fc9c43cbc5e7976f26798d236e6a96d1f46db799b0546c35ead73f5dc8f7de32f238')
```

**Sources (9 fonts from 4 domains):**
1. Hesperides — dafont.com
2. Optimus Princeps — dafont.com
3. Oblivion — dafont.com
4. Planewalker — dafont.com
5. Promised Freedom — dafont.com
6. Soviet Style — dafont.com
7. Segoe Script — fontles.com
8. Fredericka the Great — 1001fonts.com (ZIP)
9. Protomolecule — GitHub raw (ThinkDualBrain/Protomolecule)

**Package Function:**
```bash
package() {
    install -d "${pkgdir}/usr/share/fonts/${pkgname}/"
    install -m644 "${srcdir}/FrederickatheGreat-Regular.ttf" "${pkgdir}/usr/share/fonts/${pkgname}/Fredericka the Great Regular.ttf"
    install -m644 "${srcdir}/HESPD___.TTF" "${pkgdir}/usr/share/fonts/${pkgname}/Hesperides.ttf"
    install -m644 "${srcdir}/OptimusPrinceps.ttf" "${pkgdir}/usr/share/fonts/${pkgname}/Optimus Princeps.ttf"
    install -m644 "${srcdir}/oblivion-font.ttf" "${pkgdir}/usr/share/fonts/${pkgname}/Oblivion.ttf"
    install -m644 "${srcdir}/Planewalker.otf" "${pkgdir}/usr/share/fonts/${pkgname}/Planewalker.otf"
    install -m644 "${srcdir}/Promised Freedom.ttf" "${pkgdir}/usr/share/fonts/${pkgname}/Promised Freedom.ttf"
    install -m644 "${srcdir}/Protomolecule.otf" "${pkgdir}/usr/share/fonts/${pkgname}/Protomolecule.otf"
    install -m644 "${srcdir}/SovietStyle-Regular.ttf" "${pkgdir}/usr/share/fonts/${pkgname}/Soviet Style.ttf"
    install -m644 "${srcdir}/Segoe-Script_39954.ttf" "${pkgdir}/usr/share/fonts/${pkgname}/Segoe Script.ttf"
}
```

**Installed Files:**
```
/usr/share/fonts/hori-fonts/Fredericka the Great Regular.ttf
/usr/share/fonts/hori-fonts/Hesperides.ttf
/usr/share/fonts/hori-fonts/Optimus Princeps.ttf
/usr/share/fonts/hori-fonts/Oblivion.ttf
/usr/share/fonts/hori-fonts/Planewalker.otf
/usr/share/fonts/hori-fonts/Promised Freedom.ttf
/usr/share/fonts/hori-fonts/Protomolecule.otf
/usr/share/fonts/hori-fonts/Soviet Style.ttf
/usr/share/fonts/hori-fonts/Segoe Script.ttf
```

**Architecture:** `any` (fonts are architecture-independent)

**License Note:** Multiple sources with varying licenses. PKGBUILD declares `GPL` but actual font licenses vary (personal use, SIL OFL, Microsoft, unknown).

---

### image-optimiser

**PKGBUILD Location:** `pkg/image-optimiser/PKGBUILD`

**Metadata:**
```bash
pkgname=image-optimiser
pkgver=1.1.0
pkgrel=1
pkgdesc="Optimises image files for maximum lossless compression"
arch=('any')
url="https://github.com/hmlendea/${pkgname}"
license=('GPL')
depends=('jpegoptim' 'oxipng')
optdepends=('zopfli: Alternative PNG compression')
install=
source=(https://github.com/hmlendea/${pkgname}/releases/download/v${pkgver}/optimise-image.sh)
sha512sums=('65bc7de1344091b0eaf3e0503b8f08580c75f3610f526000ccd5c0e56785fa6b72724ec656de94c37c954447f860186955cd553a7a7c9e6ac9e14e03d03a8b62')
```

**Source:**
- Single script from GitHub Releases: `optimise-image.sh`

**Package Function:**
```bash
package() {
    install -d "${pkgdir}/usr/bin"
    install -m755 "${srcdir}/optimise-image.sh" "${pkgdir}/usr/bin/${pkgname}"
}
```

**Installed Files:**
```
/usr/bin/image-optimiser  (executable script)
```

**Script Behaviour:** See [data-model.md](./data-model.md#3-image-optimiser-package-image-optimiser)

**Architecture:** `any` (Bash script)

---

### plex-video-optimiser

**PKGBUILD Location:** `pkg/plex-video-optimiser/PKGBUILD`

**Metadata:**
```bash
pkgname=plex-video-optimiser
pkgver=1.7.0
pkgrel=0
pkgdesc="Optimises video files for direct streaming to most devices using Plex"
arch=('any')
url="https://github.com/hmlendea/${pkgname}"
license=('GPL')
depends=('mkvtoolnix-cli' 'ffmpeg' 'perl-rename' 'glibc')
install=
source=(https://github.com/hmlendea/${pkgname}/releases/download/v${pkgver}/${pkgname}.sh)
sha512sums=('f75ea0e46cfb543f802717c0a466ed8a7af44dfe0e4444f88f0d4557450a1da6a0fd67017ee48ca7215356ec9425d6214c20c1695f6ab699a3294be2898c22ec')
```

**Source:**
- Single script from GitHub Releases: `plex-video-optimiser.sh`

**Package Function:**
```bash
package() {
    install -d "${pkgdir}/usr/bin"
    install -m755 "${srcdir}/${pkgname}.sh" "${pkgdir}/usr/bin/${pkgname}"
}
```

**Installed Files:**
```
/usr/bin/plex-video-optimiser  (executable script)
```

**Script Behaviour:** See [data-model.md](./data-model.md#4-plex-video-optimiser-package-plex-video-optimiser)

**Architecture:** `any` (Bash script)

---

## Conventions and Patterns

### Naming
- Package directories: kebab-case (`grub2-theme-nuci`)
- PKGBUILD variables: lowercase with underscores (`pkgname`, `pkgver`, `sha512sums`)
- Source files: preserved from upstream or descriptive names
- Installed executables: match `pkgname` (via `install -m755 ... "${pkgdir}/usr/bin/${pkgname}"`)

### Source Handling
- **Single archive**: `grub2-theme-nuci` (ZIP), `hori-fonts` (one ZIP + 8 direct)
- **Single script**: `image-optimiser`, `plex-video-optimiser`
- **Checksums**: All sources have SHA512, verified by `makepkg`

### Installation
- All packages use `package()` function only (no `build()` needed)
- `install` command with explicit permissions (`-m644` for files, `-m755` for executables)
- Directory creation with `install -d -m755`

### Dependencies
- Runtime deps in `depends` (resolved by `pacman` at install)
- Optional deps in `optdepends` (informational)
- No `makedepends` (no compilation step)

## Adding a New Package

1. Create `pkg/<name>/` directory
2. Create `PKGBUILD` with required fields
3. Place source files in `src/` or reference URLs in `source`
4. Generate checksums: `cd pkg/<name> && makepkg -g >> PKGBUILD`
5. Test build: `bash makepkgs.sh`
6. Verify package contents: `tar -tf repo/<name>-*.pkg.tar.zst`
7. Commit and release

## Modification Impact

| Change | Effect |
|--------|--------|
| Update `pkgver`/`pkgrel` | New artifact built, old removed |
| Add/remove `arch` | Artifacts added/removed for those arches |
| Change `depends` | Affects target system installation |
| Change `source` URLs | New checksums required, new artifacts |
| Modify `package()` | Changes installed file layout |
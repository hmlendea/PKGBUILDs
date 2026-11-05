# Data Model

## Domain Entities

This repository manages four distinct package entities, each with its own data model.

### 1. GRUB2 Theme Package (`grub2-theme-nuci`)

#### Entity: Theme Asset
| Attribute | Type | Description | Source |
|-----------|------|-------------|--------|
| `theme.txt` | Text file | GRUB2 theme configuration (colors, layout, fonts) | `src/Nuci/theme.txt` |
| `*.png` (root) | Image files | Background, selection, terminal backgrounds | `src/Nuci/*.png` |
| `icons/*.png` | Image files | Boot entry icons (OS logos, tools) | `src/Nuci/icons/*.png` |

#### Installed Layout
```
/usr/share/grub/themes/Nuci/
├── theme.txt
├── *.png (theme backgrounds)
└── icons/
    └── *.png (boot entry icons)
```

#### Metadata
| Field | Value |
|-------|-------|
| `pkgname` | `grub2-theme-nuci` |
| `pkgver` | `1.0.0` |
| `pkgrel` | `1` |
| `arch` | `x86_64`, `i686` |
| `depends` | `grub` |
| `license` | `GPL` |

---

### 2. Fonts Package (`hori-fonts`)

#### Entity: Font File
| Attribute | Type | Description | Source |
|-----------|------|-------------|--------|
| `Fredericka the Great Regular.ttf` | TTF | Display font | `src/FrederickatheGreat-Regular.ttf` |
| `Hesperides.ttf` | TTF | Serif font | `src/HESPD___.TTF` |
| `Optimus Princeps.ttf` | TTF | Display font | `src/OptimusPrinceps.ttf` |
| `Oblivion.ttf` | TTF | Display font | `src/oblivion-font.ttf` |
| `Planewalker.otf` | OTF | Display font | `src/Planewalker.otf` |
| `Promised Freedom.ttf` | TTF | Handwriting font | `src/Promised Freedom.ttf` |
| `Protomolecule.otf` | OTF | Monospace font | `src/Protomolecule.otf` |
| `Soviet Style.ttf` | TTF | Display font | `src/SovietStyle-Regular.ttf` |
| `Segoe Script.ttf` | TTF | Handwriting font | `src/Segoe-Script_39954.ttf` |

#### Installed Layout
```
/usr/share/fonts/hori-fonts/
├── Fredericka the Great Regular.ttf
├── Hesperides.ttf
├── Optimus Princeps.ttf
├── Oblivion.ttf
├── Planewalker.otf
├── Promised Freedom.ttf
├── Protomolecule.otf
├── Soviet Style.ttf
└── Segoe Script.ttf
```

#### Metadata
| Field | Value |
|-------|-------|
| `pkgname` | `hori-fonts` |
| `pkgver` | `1.5.0` |
| `pkgrel` | `2` |
| `arch` | `any` |
| `depends` | (none) |
| `license` | `GPL` |

#### Source Provenance
| Font | Source URL | License Note |
|------|------------|--------------|
| Hesperides | dafont.com | Free for personal use |
| Optimus Princeps | dafont.com | Free for personal use |
| Oblivion | dafont.com | Free for personal use |
| Planewalker | dafont.com | Free for personal use |
| Promised Freedom | dafont.com | Free for personal use |
| Soviet Style | dafont.com | Free for personal use |
| Segoe Script | fontles.com | Microsoft font, redistributable? |
| Fredericka the Great | 1001fonts.com | SIL Open Font License |
| Protomolecule | GitHub (ThinkDualBrain) | Unknown |

---

### 3. Image Optimiser Package (`image-optimiser`)

#### Entity: CLI Script
| Attribute | Type | Description |
|-----------|------|-------------|
| `optimise-image.sh` | Bash script | Lossless JPEG/PNG optimisation |

#### Installed Layout
```
/usr/bin/image-optimiser  (symlink to optimise-image.sh)
```

#### Script Interface
```bash
image-optimiser [PATH...]
```

**Behaviour:**
- Accepts one or more file/directory paths
- Recursively finds `*.jpg`, `*.jpeg`, `*.png` files
- Optimises in-place (lossless)
- PNG: uses `oxipng -o max --preserve --alpha` or `zopflipng -y -m`
- JPEG: uses `jpegoptim --preserve --preserve-perms --all-progressive -o --strip-all`
- Reports per-file and total size reduction

#### Metadata
| Field | Value |
|-------|-------|
| `pkgname` | `image-optimiser` |
| `pkgver` | `1.1.0` |
| `pkgrel` | `1` |
| `arch` | `any` |
| `depends` | `jpegoptim`, `oxipng` |
| `optdepends` | `zopfli: Alternative PNG compression` |
| `license` | `GPL` |

---

### 4. Plex Video Optimiser Package (`plex-video-optimiser`)

#### Entity: CLI Script
| Attribute | Type | Description |
|-----------|------|-------------|
| `plex-video-optimiser.sh` | Bash script | Video optimisation for Plex direct streaming |

#### Installed Layout
```
/usr/bin/plex-video-optimiser  (symlink to plex-video-optimiser.sh)
```

#### Script Interface
```bash
plex-video-optimiser <video-file.mkv>
```

**Behaviour:**
- Single MKV file input
- Interactive (prompts for confirmation)
- Analyzes video/audio/subtitle tracks via `mkvmerge`/`mkvinfo`
- Video conversion: AV1/VP9 → H.264 (for compatibility)
- Audio normalisation: prefers AAC/MP3, converts others to AAC
- Subtitle handling: extracts SRT/SSA, removes forced/SDH unless flags set
- Filename sanitisation: removes release group tags, quality markers, etc.
- Output: `<original-name>.OPTIMISED.mkv` → replaces original on confirmation

#### Configuration Flags (Hardcoded in Script)
| Flag | Default | Purpose |
|------|---------|---------|
| `KEEP_ORIGINAL_AUDIO_TRACKS_FOR_TVSHOWS` | `false` | Keep all audio tracks for TV episodes |
| `KEEP_FORCED_SUBTITLES` | `false` | Keep forced subtitle tracks |
| `KEEP_SDH_SUBTITLES` | `false` | Keep SDH (Subtitles for Deaf/Hard of Hearing) tracks |

#### Metadata
| Field | Value |
|-------|-------|
| `pkgname` | `plex-video-optimiser` |
| `pkgver` | `1.7.0` |
| `pkgrel` | `0` |
| `arch` | `any` |
| `depends` | `mkvtoolnix-cli`, `ffmpeg`, `perl-rename`, `glibc` |
| `license` | `GPL` |

---

## Repository-Level Entities

### Built Package Artifact
| Attribute | Type | Description |
|-----------|------|-------------|
| `filename` | String | `{pkgname}-{pkgver}-{pkgrel}-{arch}.pkg.tar.zst` |
| `package_name` | String | `pkgname` from PKGBUILD |
| `version` | String | `pkgver` from PKGBUILD |
| `release` | Integer | `pkgrel` from PKGBUILD |
| `architecture` | String | One of: `any`, `x86_64`, `i686`, `aarch64` |
| `size_bytes` | Integer | File size |
| `sha256sum` | String | SHA256 checksum (in `.db`) |
| `build_date` | Timestamp | When `makepkg` created it |

### Repository Database (`.db` / `.files`)
| Attribute | Type | Description |
|-----------|------|-------------|
| `database_name` | String | `hmlendea-{arch}.db` |
| `architecture` | String | `any`, `aarch64`, `i686`, `x86_64` |
| `package_count` | Integer | Number of packages in database |
| `packages` | Array | List of package metadata (name, version, desc, depends, etc.) |
| `files` | Array | File listings per package (in `.files` database) |

### Repository Directory State (`repo/`)
| Attribute | Type | Description |
|-----------|------|-------------|
| `packages` | Map<arch, Package[]> | Built packages grouped by architecture |
| `databases` | Map<arch, Database> | Repository databases per architecture |
| `last_build` | Timestamp | Last successful `makepkgs.sh` run |
| `release_tag` | String | Recommended GitHub Release tag |

---

## Relationships

### Package → Artifact (1:M per architecture)
```
grub2-theme-nuci (1.0.0-1)
    ├── grub2-theme-nuci-1.0.0-1-x86_64.pkg.tar.zst
    └── grub2-theme-nuci-1.0.0-1-i686.pkg.tar.zst

hori-fonts (1.5.0-2)
    └── hori-fonts-1.5.0-2-any.pkg.tar.zst

image-optimiser (1.1.0-1)
    └── image-optimiser-1.1.0-1-any.pkg.tar.zst

plex-video-optimiser (1.7.0-0)
    └── plex-video-optimiser-1.7.0-0-any.pkg.tar.zst
```

### Artifact → Database (M:1 per architecture)
```
x86_64 packages → hmlendea-x86_64.db
i686 packages   → hmlendea-i686.db
aarch64 packages → hmlendea-aarch64.db
any packages    → hmlendea.db (shared across all)
```

### Database → Target System (1:M)
```
hmlendea.db → pacman on any Arch system
hmlendea-x86_64.db → pacman on x86_64 systems
hmlendea-i686.db → pacman on i686 systems
hmlendea-aarch64.db → pacman on aarch64 systems
```

---

## State Transitions

### Package Version Lifecycle
```
NEW VERSION
    │
    ▼
Update PKGBUILD (pkgver, pkgrel, sha512sums)
    │
    ▼
BUILD (makepkgs.sh)
    │
    ▼
ARTIFACT CREATED in repo/
    │
    ▼
OLD VERSIONS REMOVED from repo/
    │
    ▼
DATABASE REGENERATED (repo-add)
    │
    ▼
RELEASE PUBLISHED (GitHub Releases)
    │
    ▼
TARGET SYSTEMS UPDATE (pacman -Syu)
```

### Artifact Retention Rules
1. **Per package**: Only latest `pkgver-pkgrel` kept in `repo/`
2. **Per architecture**: Only architectures declared in current PKGBUILD `arch` array kept
3. **Databases**: Fully regenerated each build (no incremental updates)

---

## Data Integrity Constraints

| Constraint | Enforcement |
|------------|-------------|
| PKGBUILD `pkgver`/`pkgrel` matches artifact filename | `makepkgs.sh` extracts from PKGBUILD |
| All `source` entries have matching `sha512sums` | `makepkg` verifies before build |
| Artifact architecture matches PKGBUILD `arch` | `makepkgs.sh` loops over PKGBUILD `arch` |
| Database contains exactly packages in `repo/` for that arch | `repo-add` run on all matching files |
| No duplicate package-version-arch in database | `repo-add` replaces, cleanup removes old |

---

## Query Patterns

### Find all packages for architecture
```bash
find repo/ -name "*-x86_64.pkg.tar.zst"
```

### Get package metadata from database
```bash
repo-add --verify repo/hmlendea-x86_64.db.tar.gz
pacman -Si --dbpath repo/ grub2-theme-nuci
```

### List files in package
```bash
tar -tf repo/grub2-theme-nuci-1.0.0-1-x86_64.pkg.tar.zst
pacman -Ql --dbpath repo/ grub2-theme-nuci
```

### Verify checksums
```bash
sha512sum repo/grub2-theme-nuci-1.0.0-1-x86_64.pkg.tar.zst
```
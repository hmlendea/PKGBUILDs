# Frequently Asked Questions

## General

### What is this repository?
A personal Arch Linux package repository containing PKGBUILDs for four packages: `grub2-theme-nuci`, `hori-fonts`, `image-optimiser`, and `plex-video-optimiser`.

### How do I use these packages?
Add the repository to `/etc/pacman.conf` and install via `pacman`:
```ini
[hmlendea]
Server = https://github.com/hmlendea/PKGBUILDs/releases/latest/download/
SigLevel = PackageOptional
```
```bash
sudo pacman -Sy
sudo pacman -S image-optimiser
```

### Are packages signed?
Currently no. `SigLevel = PackageOptional` allows unsigned packages. Package signing is planned.

### What architectures are supported?
- `x86_64` — All packages
- `i686` — `grub2-theme-nuci` only
- `any` — `hori-fonts`, `image-optimiser`, `plex-video-optimiser`
- `aarch64` — None currently (infrastructure exists)

## Installation

### Can I install on non-Arch distributions?
These are Arch Linux packages (`.pkg.tar.zst`). They require `pacman` and Arch-compatible system. For other distributions, build from source or use the scripts directly.

### Do I need to build from source?
No. Pre-built packages are available on GitHub Releases. `pacman` downloads and installs them.

### How do I verify package integrity?
Currently: trust GitHub Releases HTTPS. Future: GPG signatures with `SigLevel = PackageRequired`.

### Can I install individual packages without the repo?
Yes, download `.pkg.tar.zst` from GitHub Releases and install:
```bash
sudo pacman -U package-name-version-arch.pkg.tar.zst
```

## Building

### How do I build packages locally?
```bash
git clone https://github.com/hmlendea/PKGBUILDs
cd PKGBUILDs
bash makepkgs.sh
```
Requires Arch Linux with `base-devel` and package dependencies.

### What are the build requirements?
- Arch Linux (or Arch-based)
- `base-devel` group
- Dependencies listed in each PKGBUILD's `makedepends` and `depends`

### Can I build on non-Arch systems?
Not directly. `makepkg` is Arch-specific. Use Docker with Arch image or build scripts manually.

### How do I build a single package?
```bash
cd pkg/image-optimiser
makepkg -Csrf --noconfirm
```

### How do I update checksums after source changes?
```bash
cd pkg/<package>
updpkgsums
```

### Why does build fail with checksum error?
Upstream source changed. Run `updpkgsums` to regenerate, or verify source URL is correct.

## Package-Specific

### grub2-theme-nuci
**Q: How do I enable the theme?**
Edit `/etc/default/grub`: `GRUB_THEME="/usr/share/grub/themes/Nuci/theme.txt"`, then `grub-mkconfig -o /boot/grub/grub.cfg`.

**Q: Why only x86_64 and i686?**
GRUB themes are architecture-specific due to GRUB module loading. `any` not supported.

### hori-fonts
**Q: Where are fonts installed?**
`/usr/share/fonts/hori-fonts/`. Run `fc-cache -f` after install.

**Q: What fonts are included?**
9 fonts from 4 sources: Hesperides, Oblivion, Optimus Princeps, Planewalker, Promised Freedom, Soviet Style, Segoe Script, and 2 more.

**Q: Are these fonts free to redistribute?**
Check individual font licenses in `pkg/hori-fonts/src/`. Some may be shareware or have restrictions.

### image-optimiser
**Q: What formats does it support?**
JPEG (`.jpg`, `.jpeg`) and PNG (`.png`). Processes recursively in directories.

**Q: Does it modify originals?**
Yes, in-place optimisation. No backup created.

**Q: Can I adjust compression level?**
No, uses fixed aggressive settings. Modify script for customisation.

**Q: Why two PNG optimisers?**
`oxipng` preferred (Rust, faster). Falls back to `zopflipng` if unavailable.

### plex-video-optimiser
**Q: What does it optimise for?**
Plex direct streaming compatibility: H.264 video, AAC audio, MKV container, sanitised filenames.

**Q: Why interactive only?**
Designed for manual review of each conversion. No batch/automated mode.

**Q: What audio tracks are kept?**
Priority: existing AAC/MP3 → convert first non-commentary to AAC → keep non-discardable others (movies only).

**Q: What are "discardable" audio formats?**
AC-3, E-AC-3, MP3, Opus, PCM, and commentary tracks.

**Q: Can I keep forced/SDH subtitles?**
Edit script: set `KEEP_FORCED_SUBTITLES=true` and/or `KEEP_SDH_SUBTITLES=true`.

**Q: Why does it rename files?**
Removes release group tags, quality markers, codec info for cleaner Plex library.

**Q: Can I disable filename sanitisation?**
Not via CLI. Modify script to skip sanitisation section.

## Troubleshooting

### pacman: signature invalid
Set `SigLevel = PackageOptional` in pacman.conf for this repo.

### pacman: database not found
Run `sudo pacman -Sy` to sync databases.

### Package not found in repo
Check `pacman -Sl hmlendea` for available packages. Verify architecture compatibility.

### Build fails with "missing dependency"
Install the dependency: `sudo pacman -S <dependency>`, or add to PKGBUILD `makedepends`.

### image-optimiser: command not found
Ensure package installed: `pacman -Q image-optimiser`. Check `/usr/bin/` in PATH.

### plex-video-optimiser: ffmpeg not found
Install dependencies: `sudo pacman -S ffmpeg mkvtoolnix-cli perl-rename`.

### plex-video-optimiser: no optimisation needed
File already meets criteria: H.264 video, AAC/MP3 audio, MKV container, no subtitles.

## Development

### How do I add a new package?
1. Create `pkg/new-package/` with `PKGBUILD` and `src/`
2. Test build: `cd pkg/new-package && makepkg -Csrf`
3. Run full pipeline: `bash makepkgs.sh`
4. Verify in `repo/`

### How do I update a package version?
1. Edit `pkg/<name>/PKGBUILD`: update `pkgver`, reset `pkgrel=1`
2. Update `source` URLs if versioned
3. Run `updpkgsums` in package directory
4. Test build

### How do I contribute?
Fork repository, create branch, make changes, submit PR. Ensure `makepkgs.sh` passes.

### Where is the CI/CD?
Not currently configured. Builds run locally. GitHub Actions workflow planned.

## Repository Management

### How are releases created?
Manual: `git tag v1.0.0 && git push origin v1.0.0`, then upload `repo/*` to GitHub Release.

### Can I use a specific release version?
Yes: `Server = https://github.com/hmlendea/PKGBUILDs/releases/download/v1.0.0/`

### How do I remove a package?
Delete `pkg/<name>/`, remove artifacts from `repo/`, rebuild.

### How do I change repository name?
Edit `REPO_NAME` in `makepkgs.sh`, rebuild, update pacman.conf.
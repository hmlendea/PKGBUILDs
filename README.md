[![Donate](https://img.shields.io/badge/-%E2%99%A5%20Donate-%23ff69b4)](https://hmlendea.go.ro/funding)
[![Latest Release](https://img.shields.io/github/v/release/hmlendea/PKGBUILDs)](https://github.com/hmlendea/PKGBUILDs/releases/latest)

# PKGBUILDs

Personal Arch Linux package repository, providing custom and unofficial packages for everyday use.

## ✨ Features

- `chromedriver-unofficial`: Electron's unofficial version of chromedriver, with support for extra CPU architectures
- `gandi-dns-updater`: CLI utility for updating Gandi.net DNS records
- `grub2-theme-nuci`: Personal GRUB2 theme based on Vimix
- `hori-fonts`: Hori's fonts collection
- `image-optimiser`: Optimises image files for maximum lossless compression
- `mouse-recorder`: Records and replays mouse and keyboard actions
- `optiprime`: Starts applications using an optimised primusrun
- `plex-video-optimiser`: Optimises video files for direct streaming to most devices via Plex
- `steam-start`: Launches Steam with compatibility fixes and support for Nvidia OPTIMUS

## 🚀 Usage

To use this repository, add the following entries to the end of `/etc/pacman.conf`.

### Main repository

Most packages are available here for the `any` architecture.

```ini
[hmlendea]
Server = https://github.com/hmlendea/PKGBUILDs/releases/latest/download/
SigLevel = PackageOptional
```

### Extra architectures

These are optional extra repository databases containing architecture-specific packages not found in the main `hmlendea` database.

**`aarch64` architecture:**
```ini
[hmlendea-aarch64]
Server = https://github.com/hmlendea/PKGBUILDs/releases/latest/download/
SigLevel = PackageOptional
```

**`i686` architecture:**
```ini
[hmlendea-i686]
Server = https://github.com/hmlendea/PKGBUILDs/releases/latest/download/
SigLevel = PackageOptional
```

**`x86_64` architecture:**
```ini
[hmlendea-x86_64]
Server = https://github.com/hmlendea/PKGBUILDs/releases/latest/download/
SigLevel = PackageOptional
```

## 🛠️ Development

### Requirements

- Arch Linux with `base-devel`

### Build

```bash
bash makepkgs.sh
```

## 🗂️ Project Structure

| Directory | Purpose |
|-----------|---------|
| `pkg/` | Contains one subdirectory per package, each with a `PKGBUILD` and any supplementary files |

## 🤝 Contributing

Contributions are welcome. Please:
- Keep the pull requests focused and consistent with the existing code style
- Update the documentation when behaviour changes

## 💝 Support

Found a bug or have a suggestion? [Open an issue](https://github.com/hmlendea/PKGBUILDs/issues)!

If you find this project useful, consider [funding it](https://hmlendea.go.ro/funding) or giving a ⭐️ on GitHub!

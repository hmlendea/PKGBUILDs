[![Donate](https://img.shields.io/badge/-%E2%99%A5%20Donate-%23ff69b4)](https://hmlendea.go.ro/funding)
[![Latest Release](https://img.shields.io/github/v/release/hmlendea/PKGBUILDs)](https://github.com/hmlendea/PKGBUILDs/releases/latest)

# PKGBUILDs

Personal Arch Linux package repository, providing custom and unofficial packages for everyday use.

## 📑 Table of Contents

- [Capabilities](#capabilities)
- [Usage](#usage)
  - [Main repository](#main-repository)
  - [Extra architectures](#extra-architectures)
- [Installation](#installation)
  - [GitHub Releases](#github-releases)
- [Development](#development)
  - [Requirements](#requirements)
  - [Build](#build)
- [Project Structure](#project-structure)
- [Privacy and Data](#privacy-and-data)
- [Contributing](#contributing)
- [Code of Conduct](#code-of-conduct)
- [Support](#support)

## ✨ Capabilities

- Provides custom and unofficial Arch Linux packages via a personal repository
- Supports multiple architectures: `any`, `aarch64`, `i686`, `x86_64`
- Automated package building and repository database generation
- Packages distributed via GitHub Releases for direct `pacman` consumption
- **Packages:** `grub2-theme-nuci`, `hori-fonts`, `image-optimiser`, `plex-video-optimiser`

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

## 📦 Installation

### GitHub Releases

Packages are published as GitHub Releases. Add the appropriate repository configuration above to `/etc/pacman.conf`, then install packages with `pacman`:

```bash
pacman -Syu
pacman -S grub2-theme-nuci hori-fonts image-optimiser plex-video-optimiser
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

## 🛡️ Privacy and Data

This repository does not collect, process, transmit, or persist user data, analytics, diagnostics, or telemetry. The packages and build scripts do not handle personal data. For details, see [PRIVACY.md](PRIVACY.md).

## 🤝 Contributing

You are welcome to submit any suggestion, feedback, or modification to this project.

When doing so, please:
- Submit focused pull requests that conform to the existing code style
- Maintain your branch synchronised with `master`
- Revise the documentation when functionality changes
- Raise a new [issue](https://github.com/hmlendea/PKGBUILDs/issues) for problems or suggestions

See the [contributing guidelines](./CONTRIBUTING.md) for details on how to report issues, suggest enhancements, and submit changes.

## 📜 Code of Conduct

See the [Code of Conduct](./CODE_OF_CONDUCT.md) for the standards of conduct expected in all project spaces.

## 💝 Support

Found a bug or have a suggestion? [Open an issue](https://github.com/hmlendea/PKGBUILDs/issues)!

If you find this project useful, consider [funding it](https://hmlendea.go.ro/funding) or giving a ⭐️ on GitHub!

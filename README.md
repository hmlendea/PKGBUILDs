[![Donate](https://img.shields.io/badge/-%E2%99%A5%20Donate-%23ff69b4)](https://hmlendea.go.ro/funding)
[![Latest Release](https://img.shields.io/github/v/release/hmlendea/PKGBUILDs)](https://github.com/hmlendea/PKGBUILDs/releases/latest)
[![Lint Status](https://github.com/hmlendea/PKGBUILDs/actions/workflows/bash.yml/badge.svg)](https://github.com/hmlendea/PKGBUILDs/actions/workflows/bash.yml)

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
- [GitHub Actions](#github-actions)
- [Project Structure](#project-structure)
- [Architecture](#architecture)
- [Documentation](#documentation)
- [Privacy and Data](#privacy-and-data)
- [Contributing](#contributing)
- [Code of Conduct](#code-of-conduct)
- [Security](#security)
- [Project Engagement](#project-engagement)

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

## ⚙️ GitHub Actions

| Workflow | Purpose | Principal Actions |
|----------|---------|-------------------|
| [Bash](.github/workflows/bash.yml) | Lint Bash scripts | Checks out repository; runs `shellcheck` on all `*.sh` files with error severity |

## 🗂️ Project Structure

| Directory | Purpose |
|-----------|---------|
| `pkg/` | Contains one subdirectory per package, each with a `PKGBUILD` and any supplementary files |
| `repo/` | Built package artifacts (`.pkg.tar.zst`) and repository databases (`.db`, `.files`) |
| `docs/` | Supplementary documentation covering architecture, components, flows, operations, and reference |

## 🏗️ Architecture

PKGBUILDs implements a build pipeline architecture orchestrated by `makepkgs.sh`, transforming PKGBUILD definitions into multi-architecture packages and repository databases distributed via GitHub Releases.

See the [Architecture Documentation](ARCHITECTURE.md) for the system context, principal components, runtime flows, ownership boundaries, dependencies, constraints, and extension points.

## 📚 Documentation

A substantive `docs/` directory exists with detailed documentation organised by topic:

- **Architecture & Design:** [Architecture](./docs/architecture.md), [Design Decisions](./docs/design-decisions.md), [Repository Structure](./docs/repository-structure.md), [Data Model](./docs/data-model.md)
- **Build & Deployment:** [Build and Deployment](./docs/build-and-deployment.md), [Configuration](./docs/configuration.md), [Dependencies](./docs/dependencies.md)
- **Components:** [Build Pipeline](./docs/components/build-pipeline.md), [Package Definitions](./docs/components/package-definitions.md), [Repository Generation](./docs/components/repository-generation.md)
- **Flows:** [Package Build Flow](./docs/flows/package-build.md), [Repository Generation Flow](./docs/flows/repository-generation.md), [Release Distribution Flow](./docs/flows/release-distribution.md)
- **Operations & Maintenance:** [Change Guide](./docs/change-guide.md), [Testing](./docs/testing.md), [Troubleshooting](./docs/troubleshooting.md), [Documentation Maintenance](./docs/documentation-maintenance.md)
- **Reference:** [API Reference Index](./docs/api-reference/INDEX.md), [Invariants](./docs/invariants.md), [Error Handling](./docs/error-handling.md), [Logging](./docs/logging.md), [Security](./docs/security.md), [FAQ](./docs/faq.md), [Quick Start](./docs/quick-start.md), [Ambiguities and Open Questions](./docs/ambiguities-and-open-questions.md)

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

## 🔒 Security

This repository provides a personal Arch Linux package repository with custom and unofficial packages distributed via GitHub Releases. The security policy covers the build pipeline, package definitions, and distribution mechanism.

See the [Security Policy](SECURITY.md) for supported versions, vulnerability reporting, scope, and disclosure policy.

## 💝 Project Engagement

Discovered a problem or have a suggestion? [Open an issue](https://github.com/hmlendea/PKGBUILDs/issues)!

If you find this project useful, consider [funding it](https://hmlendea.go.ro/funding) or starring ⭐️ it on GitHub!

[![Donate](https://raw.githubusercontent.com/hmlendea/readme-assets/master/donate_generic.png)](https://hmlendea.go.ro/funding)

# Contributing to PKGBUILDs

This document covers the guidelines and processes for contributing to this project, including how to report issues, suggest enhancements, submit code changes, and follow project standards.

## 📑 Table of Contents

- [How to Contribute](#how-to-contribute)
  - [Reporting Issues](#reporting-issues)
  - [Suggesting Enhancements](#suggesting-enhancements)
  - [Code Contributions](#code-contributions)
    - [Prerequisites](#prerequisites)
    - [Development Setup](#development-setup)
    - [Making Changes](#making-changes)
    - [Pull Request Guidelines](#pull-request-guidelines)
  - [Code Style](#code-style)
  - [Testing](#testing)
  - [Documentation](#documentation)
- [Getting Assistance](#getting-assistance)

## 🤝 How to Contribute

### Reporting Issues

- Search existing issues first.
- Use the issue templates if available.
- Provide clear reproduction steps.
- Include environment details.

### Suggesting Enhancements

- Check the roadmap and existing discussions.
- Explain the use case and expected behaviour.
- Consider implementation complexity.

### Code Contributions

#### Prerequisites

- Arch Linux with `base-devel`

#### Development Setup

```bash
# Clone the repository
git clone https://github.com/hmlendea/PKGBUILDs.git
cd PKGBUILDs

# Install dependencies
# No additional dependencies required beyond base-devel
```

#### Making Changes

1. Fork the repository.
2. Create a feature branch: `git checkout -b feature/your-feature-name`
3. Make your changes.
4. Run tests: No automated tests exist.
5. Run linters: No linters configured.
6. Commit with clear and descriptive messages.
7. Push to your fork.
8. Open a Pull Request.

#### Pull Request Guidelines

- Target the `main` branch.
- Keep PRs focused and atomic.
- Revise documentation if applicable.
- Include tests for any new functionality.
- Ensure the CI checks pass.

### Code Style

Follow the project's coding standards:
- Keep pull requests focused and consistent with the existing code style
- Run `bash makepkgs.sh` to verify builds succeed before committing.

### Testing

No automated tests exist. Verify changes by building packages locally:

```bash
# Build all packages
bash makepkgs.sh
```

### Documentation

- Revise relevant docs for changes.
- Follow the documentation style guide.
- Preview changes locally if possible.

## 📋 Code of Conduct

This project follows the [Code of Conduct](./CODE_OF_CONDUCT.md).

## ❓ Getting Assistance

- [Open an issue](https://github.com/hmlendea/PKGBUILDs/issues)
- Check existing discussions and documentation first.
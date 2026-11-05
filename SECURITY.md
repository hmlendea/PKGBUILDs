# Security Policy

This repository provides a personal Arch Linux package repository with custom and unofficial packages distributed via GitHub Releases. The security policy covers the build pipeline, package definitions, and distribution mechanism.

## 📑 Table of Contents

- [Supported Versions](#-supported-versions)
- [Reporting a Vulnerability](#-reporting-a-vulnerability)
- [Scope](#-scope)
- [Disclosure Policy](#-disclosure-policy)

## 🛡️ Supported Versions

Use this table to indicate which project versions currently receive security maintenance.

| Version | Distribution Channel | Supported |
|---------|--------------------|-----------|
| Latest version | GitHub Releases | ✅ |
| Latest version | Direct repository clone | ✅ |
| Preceding versions | Any distribution channel | ❌ |

## 🚨 Reporting a Vulnerability

Please do not disclose suspected vulnerabilities publicly before maintainers have had an opportunity to validate and remediate them.

To report a vulnerability:
- [GitHub Security Advisories](https://github.com/hmlendea/PKGBUILDs/security/advisories)
- Contact the maintainers directly

## 📌 Scope

The original maintainers are not responsible for changes, modifications, or security issues introduced by downstream forks.

The subsequent report categories are in scope for this repository:
- Build pipeline vulnerabilities (makepkgs.sh)
- Package definition vulnerabilities (PKGBUILD files)
- Supply chain integrity (upstream source verification via sha512sums)
- Repository database generation (repo-add)

The subsequent categories are out of scope unless explicitly stated to the contrary:
- Vulnerabilities in upstream software packaged by this repository (report to upstream)
- Vulnerabilities in Arch Linux toolchain (makepkg, repo-add, pacman)
- Vulnerabilities in GitHub Actions infrastructure
- Issues arising from modified or unofficial forks of this repository

## 📢 Disclosure Policy

This project follows coordinated disclosure:
1. Vulnerabilities are investigated privately.
2. A remediation plan is prepared and validated.
3. Public disclosure is published after a fix, mitigation, or agreed risk decision is available.
4. Credit is attributed in accordance with reporter preference and project policy.